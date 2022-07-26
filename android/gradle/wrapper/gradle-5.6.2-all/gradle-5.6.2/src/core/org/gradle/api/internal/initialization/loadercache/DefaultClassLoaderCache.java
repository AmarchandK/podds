/*
 * Copyright 2013 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.gradle.api.internal.initialization.loadercache;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Joiner;
import com.google.common.base.Objects;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import com.google.common.collect.Sets;
import org.gradle.api.Action;
import org.gradle.initialization.SessionLifecycleListener;
import org.gradle.internal.classloader.ClassLoaderUtils;
import org.gradle.internal.classloader.ClasspathHasher;
import org.gradle.internal.classloader.FilteringClassLoader;
import org.gradle.internal.classloader.HashingClassLoaderFactory;
import org.gradle.internal.classpath.ClassPath;
import org.gradle.internal.concurrent.Stoppable;
import org.gradle.internal.hash.HashCode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.annotation.Nullable;
import java.util.Map;
import java.util.Set;

public class DefaultClassLoaderCache implements ClassLoaderCacheInternal, Stoppable, SessionLifecycleListener {
    private static final Logger LOGGER = LoggerFactory.getLogger(DefaultClassLoaderCache.class);

    private final Object lock = new Object();
    private final Map<ClassLoaderId, CachedClassLoader> byId = Maps.newHashMap();
    private final Map<ClassLoaderSpec, CachedClassLoader> bySpec = Maps.newHashMap();
    private final Set<ClassLoaderId> usedInThisBuild = Sets.newHashSet();
    private final ClasspathHasher classpathHasher;
    private final HashingClassLoaderFactory classLoaderFactory;

    public DefaultClassLoaderCache(HashingClassLoaderFactory classLoaderFactory, ClasspathHasher classpathHasher) {
        this.classLoaderFactory = classLoaderFactory;
        this.classpathHasher = classpathHasher;
    }

    @Override
    public ClassLoader get(ClassLoaderId id, ClassPath classPath, @Nullable ClassLoader parent, @Nullable FilteringClassLoader.Spec filterSpec) {
        return get(id, classPath, parent, filterSpec, null);
    }

    @Override
    public ClassLoader get(ClassLoaderId id, ClassPath classPath, @Nullable ClassLoader parent, @Nullable FilteringClassLoader.Spec filterSpec, HashCode implementationHash) {
        usedInThisBuild.add(id);
        if (implementationHash == null) {
            implementationHash = classpathHasher.hash(classPath);
        }
        ManagedClassLoaderSpec spec = new ManagedClassLoaderSpec(id.toString(), parent, classPath, implementationHash, filterSpec);

        synchronized (lock) {
            CachedClassLoader cachedLoader = byId.get(id);
            if (cachedLoader == null || !cachedLoader.is(spec)) {
                CachedClassLoader newLoader = getAndRetainLoader(classPath, spec, id);
                byId.put(id, newLoader);

                if (cachedLoader != null) {
                    LOGGER.debug("Releasing previous classloader for {}", id);
                    cachedLoader.release(id);
                }
                return newLoader.classLoader;
            } else {
                return cachedLoader.classLoader;
            }
        }
    }

    @Override
    public <T extends ClassLoader> T put(ClassLoaderId id, T classLoader) {
        synchronized (lock) {
            remove(id);
            ClassLoaderSpec spec = new UnmanagedClassLoaderSpec(classLoader);
            CachedClassLoader cachedClassLoader = new CachedClassLoader(classLoader, spec, null);
            cachedClassLoader.retain(id);
            byId.put(id, cachedClassLoader);
            bySpec.put(spec, cachedClassLoader);
            usedInThisBuild.add(id);
        }
        return classLoader;
    }

    @Override
    public void remove(ClassLoaderId id) {
        synchronized (lock) {
            CachedClassLoader cachedClassLoader = byId.remove(id);
            if (cachedClassLoader != null) {
                cachedClassLoader.release(id);
            }
            usedInThisBuild.remove(id);
        }
    }

    private CachedClassLoader getAndRetainLoader(ClassPath classPath, ManagedClassLoaderSpec spec, ClassLoaderId id) {
        CachedClassLoader cachedLoader = bySpec.get(spec);
        if (cachedLoader == null) {
            ClassLoader classLoader;
            CachedClassLoader parentCachedLoader = null;
            if (spec.isFiltered()) {
                parentCachedLoader = getAndRetainLoader(classPath, spec.unfiltered(), id);
                classLoader = classLoaderFactory.createFilteringClassLoader(parentCachedLoader.classLoader, spec.filterSpec);
            } else {
                classLoader = classLoaderFactory.createChildClassLoader(spec.name, spec.parent, classPath, spec.implementationHash);
            }
            cachedLoader = new CachedClassLoader(classLoader, spec, parentCachedLoader);
            bySpec.put(spec, cachedLoader);
        }

        return cachedLoader.retain(id);
    }

    @VisibleForTesting
    public int size() {
        synchronized (lock) {
            return bySpec.size();
        }
    }

    @Override
    public void stop() {
        synchronized (lock) {
            for (CachedClassLoader cachedClassLoader : byId.values()) {
                ClassLoaderUtils.tryClose(cachedClassLoader.classLoader);
            }
            byId.clear();
            bySpec.clear();
            usedInThisBuild.clear();
        }
    }

    @Override
    public void afterStart() {

    }

    @Override
    public void beforeComplete() {
        synchronized (lock) {
            Set<ClassLoaderId> unused = Sets.newHashSet(byId.keySet());
            unused.removeAll(usedInThisBuild);
            for (ClassLoaderId id : unused) {
                remove(id);
            }
            usedInThisBuild.clear();
        }
        assertInternalIntegrity();
    }

    @Override
    public void visitClassLoadersUsedInThisBuild(Action<ClassLoader> action) {
        synchronized (lock) {
            for (ClassLoaderId id : usedInThisBuild) {
                action.execute(byId.get(id).classLoader);
            }
        }
    }

    private static abstract class ClassLoaderSpec {
    }

    private static class UnmanagedClassLoaderSpec extends ClassLoaderSpec {
        private final ClassLoader loader;

        public UnmanagedClassLoaderSpec(ClassLoader loader) {
            this.loader = loader;
        }
    }

    private static class ManagedClassLoaderSpec extends ClassLoaderSpec {
        private final String name;
        private final ClassLoader parent;
        private final ClassPath classPath;
        private final HashCode implementationHash;
        private final FilteringClassLoader.Spec filterSpec;

        public ManagedClassLoaderSpec(String name, ClassLoader parent, ClassPath classPath, HashCode implementationHash, FilteringClassLoader.Spec filterSpec) {
            this.name = name;
            this.parent = parent;
            this.classPath = classPath;
            this.implementationHash = implementationHash;
            this.filterSpec = filterSpec;
        }

        public ManagedClassLoaderSpec unfiltered() {
            return new ManagedClassLoaderSpec(name, parent, classPath, implementationHash, null);
        }

        public boolean isFiltered() {
            return filterSpec != null;
        }

        @Override
        public boolean equals(Object o) {
            if (o == this) {
                return true;
            }
            if (o == null || o.getClass() != getClass()) {
                return false;
            }
            ManagedClassLoaderSpec that = (ManagedClassLoaderSpec) o;
            return Objects.equal(this.parent, that.parent)
                && this.implementationHash.equals(that.implementationHash)
                && this.classPath.equals(that.classPath)
                && Objects.equal(this.filterSpec, that.filterSpec);
        }

        @Override
        public int hashCode() {
            int result = implementationHash.hashCode();
            result = 31 * result + classPath.hashCode();
            result = 31 * result + (filterSpec != null ? filterSpec.hashCode() : 0);
            result = 31 * result + (parent != null ? parent.hashCode() : 0);
            return result;
        }
    }

    private class CachedClassLoader {
        private final ClassLoader classLoader;
        private final ClassLoaderSpec spec;
        private final CachedClassLoader parent;
        private final Multiset<ClassLoaderId> usedBy = HashMultiset.create();

        private CachedClassLoader(ClassLoader classLoader, ClassLoaderSpec spec, @Nullable CachedClassLoader parent) {
            this.classLoader = classLoader;
            this.spec = spec;
            this.parent = parent;
        }

        public boolean is(ClassLoaderSpec spec) {
            return this.spec.equals(spec);
        }

        public CachedClassLoader retain(ClassLoaderId loaderId) {
            usedBy.add(loaderId);
            return this;
        }

        public void release(ClassLoaderId loaderId) {
            if (usedBy.isEmpty()) {
                throw new IllegalStateException("Cannot release already released classloader: " + classLoader);
            }

            if (usedBy.remove(loaderId)) {
                if (usedBy.isEmpty()) {
                    if (parent != null) {
                        parent.release(loaderId);
                    }
                    bySpec.remove(spec);
                }
            } else {
                throw new IllegalStateException("Classloader '" + this + "' not used by '" + loaderId + "'");
            }
        }
    }

    private void assertInternalIntegrity() {
        synchronized (lock) {
            Map<ClassLoaderId, CachedClassLoader> orphaned = Maps.newHashMap();
            for (Map.Entry<ClassLoaderId, CachedClassLoader> entry : byId.entrySet()) {
                if (!bySpec.containsKey(entry.getValue().spec)) {
                    orphaned.put(entry.getKey(), entry.getValue());
                }
            }

            if (!orphaned.isEmpty()) {
                throw new IllegalStateException("The following class loaders are orphaned: " + Joiner.on(",").withKeyValueSeparator(":").join(orphaned));
            }
        }
    }
}

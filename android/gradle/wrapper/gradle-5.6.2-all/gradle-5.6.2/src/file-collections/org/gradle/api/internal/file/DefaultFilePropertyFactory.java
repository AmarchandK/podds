/*
 * Copyright 2019 the original author or authors.
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

package org.gradle.api.internal.file;

import org.gradle.api.file.Directory;
import org.gradle.api.file.DirectoryProperty;
import org.gradle.api.file.FileSystemLocation;
import org.gradle.api.file.FileSystemLocationProperty;
import org.gradle.api.file.FileTree;
import org.gradle.api.file.RegularFile;
import org.gradle.api.file.RegularFileProperty;
import org.gradle.api.internal.provider.AbstractCombiningProvider;
import org.gradle.api.internal.provider.AbstractMappingProvider;
import org.gradle.api.internal.provider.AbstractReadOnlyProvider;
import org.gradle.api.internal.provider.DefaultProperty;
import org.gradle.api.internal.provider.ProviderInternal;
import org.gradle.api.internal.provider.Providers;
import org.gradle.api.provider.Provider;
import org.gradle.internal.file.PathToFileResolver;
import org.gradle.internal.state.Managed;

import javax.annotation.Nullable;
import java.io.File;

public class DefaultFilePropertyFactory implements FilePropertyFactory {
    private final FileResolver fileResolver;

    public DefaultFilePropertyFactory(FileResolver resolver) {
        this.fileResolver = resolver;
    }

    @Override
    public DirectoryProperty newDirectoryProperty() {
        return new DefaultDirectoryVar(fileResolver);
    }

    @Override
    public RegularFileProperty newFileProperty() {
        return new DefaultRegularFileVar(fileResolver);
    }

    static class FixedDirectory extends DefaultFileSystemLocation implements Directory, Managed {
        final FileResolver fileResolver;

        FixedDirectory(File value, FileResolver fileResolver) {
            super(value);
            this.fileResolver = fileResolver;
        }

        @Override
        public boolean immutable() {
            return true;
        }

        @Override
        public Class<?> publicType() {
            return Directory.class;
        }

        @Override
        public Object unpackState() {
            return getAsFile();
        }

        @Override
        public int getFactoryId() {
            return ManagedFactories.DirectoryManagedFactory.FACTORY_ID;
        }

        @Override
        public Directory dir(String path) {
            File newDir = fileResolver.resolve(path);
            return new FixedDirectory(newDir, fileResolver.newResolver(newDir));
        }

        @Override
        public FileTree getAsFileTree() {
            return fileResolver.resolveFilesAsTree(this);
        }

        @Override
        public Provider<Directory> dir(Provider<? extends CharSequence> path) {
            return new ResolvingDirectory(fileResolver, Providers.internal(path));
        }

        @Override
        public RegularFile file(String path) {
            return new FixedFile(fileResolver.resolve(path));
        }

        @Override
        public Provider<RegularFile> file(Provider<? extends CharSequence> path) {
            return new ResolvingRegularFileProvider(fileResolver, Providers.internal(path));
        }
    }

    static class FixedFile extends DefaultFileSystemLocation implements RegularFile, Managed {
        FixedFile(File file) {
            super(file);
        }

        @Override
        public boolean immutable() {
            return true;
        }

        @Override
        public Class<?> publicType() {
            return RegularFile.class;
        }

        @Override
        public Object unpackState() {
            return getAsFile();
        }

        @Override
        public int getFactoryId() {
            return ManagedFactories.RegularFileManagedFactory.FACTORY_ID;
        }
    }

    static class ResolvingRegularFileProvider extends AbstractMappingProvider<RegularFile, CharSequence> {
        private final PathToFileResolver resolver;

        ResolvingRegularFileProvider(PathToFileResolver resolver, ProviderInternal<? extends CharSequence> path) {
            super(RegularFile.class, path);
            this.resolver = resolver;
        }

        @Override
        protected RegularFile map(CharSequence path) {
            return new FixedFile(resolver.resolve(path));
        }
    }

    static abstract class AbstractFileVar<T extends FileSystemLocation> extends DefaultProperty<T> implements FileSystemLocationProperty<T> {

        public AbstractFileVar(Class<T> type) {
            super(type);
        }

        @Override
        public void setFromAnyValue(Object object) {
            if (object instanceof File) {
                set((File) object);
            } else {
                super.setFromAnyValue(object);
            }
        }

        @Override
        public Provider<T> getLocationOnly() {
            return new AbstractReadOnlyProvider<T>() {
                @Nullable
                @Override
                public Class<T> getType() {
                    return AbstractFileVar.this.getType();
                }

                @Nullable
                @Override
                public T getOrNull() {
                    return AbstractFileVar.this.getOrNull();
                }
            };
        }
    }

    static class DefaultRegularFileVar extends AbstractFileVar<RegularFile> implements RegularFileProperty, Managed {
        private final PathToFileResolver fileResolver;

        DefaultRegularFileVar(PathToFileResolver fileResolver) {
            super(RegularFile.class);
            this.fileResolver = fileResolver;
        }

        @Override
        public Class<?> publicType() {
            return RegularFileProperty.class;
        }

        @Override
        public Provider<File> getAsFile() {
            return new ToFileProvider(this);
        }

        @Override
        public int getFactoryId() {
            return ManagedFactories.RegularFilePropertyManagedFactory.FACTORY_ID;
        }

        @Override
        public void set(File file) {
            if (file == null) {
                set((RegularFile) null);
                return;
            }
            set(new FixedFile(fileResolver.resolve(file)));
        }

        @Override
        public RegularFileProperty value(RegularFile value) {
            super.value(value);
            return this;
        }

        @Override
        public RegularFileProperty value(Provider<? extends RegularFile> provider) {
            super.value(provider);
            return this;
        }

        @Override
        public RegularFileProperty convention(RegularFile value) {
            super.convention(value);
            return this;
        }

        @Override
        public RegularFileProperty convention(Provider<? extends RegularFile> valueProvider) {
            super.convention(valueProvider);
            return this;
        }
    }

    static class ResolvingDirectory extends AbstractMappingProvider<Directory, CharSequence> {
        private final FileResolver resolver;

        ResolvingDirectory(FileResolver resolver, ProviderInternal<? extends CharSequence> valueProvider) {
            super(Directory.class, valueProvider);
            this.resolver = resolver;
        }

        @Override
        protected Directory map(CharSequence path) {
            File dir = resolver.resolve(path);
            return new FixedDirectory(dir, resolver.newResolver(dir));
        }
    }

    static class DefaultDirectoryVar extends AbstractFileVar<Directory> implements DirectoryProperty, Managed {
        private final FileResolver resolver;

        DefaultDirectoryVar(FileResolver resolver) {
            super(Directory.class);
            this.resolver = resolver;
        }

        DefaultDirectoryVar(FileResolver resolver, Object value) {
            super(Directory.class);
            this.resolver = resolver;
            resolveAndSet(value);
        }

        @Override
        public Class<?> publicType() {
            return DirectoryProperty.class;
        }

        @Override
        public int getFactoryId() {
            return ManagedFactories.DirectoryPropertyManagedFactory.FACTORY_ID;
        }

        @Override
        public FileTree getAsFileTree() {
            return resolver.resolveFilesAsTree(this);
        }

        @Override
        public Provider<File> getAsFile() {
            return new ToFileProvider(this);
        }

        void resolveAndSet(Object value) {
            File resolved = resolver.resolve(value);
            set(new FixedDirectory(resolved, resolver.newResolver(resolved)));
        }

        @Override
        public void set(File dir) {
            if (dir == null) {
                set((Directory) null);
                return;
            }
            File resolved = resolver.resolve(dir);
            set(new FixedDirectory(resolved, resolver.newResolver(resolved)));
        }

        @Override
        public DirectoryProperty value(Directory value) {
            super.value(value);
            return this;
        }

        @Override
        public DirectoryProperty value(Provider<? extends Directory> provider) {
            super.value(provider);
            return this;
        }

        @Override
        public DirectoryProperty convention(Directory value) {
            super.convention(value);
            return this;
        }

        @Override
        public DirectoryProperty convention(Provider<? extends Directory> valueProvider) {
            super.convention(valueProvider);
            return this;
        }

        @Override
        public Provider<Directory> dir(final String path) {
            return new AbstractMappingProvider<Directory, Directory>(Directory.class, this) {
                @Override
                protected Directory map(Directory dir) {
                    return dir.dir(path);
                }
            };
        }

        @Override
        public Provider<Directory> dir(final Provider<? extends CharSequence> path) {
            return new AbstractCombiningProvider<Directory, Directory, CharSequence>(Directory.class, this, path) {
                @Override
                protected Directory map(Directory b, CharSequence v) {
                    return b.dir(v.toString());
                }
            };
        }

        @Override
        public Provider<RegularFile> file(final String path) {
            return new AbstractMappingProvider<RegularFile, Directory>(RegularFile.class, this) {
                @Override
                protected RegularFile map(Directory dir) {
                    return dir.file(path);
                }
            };
        }

        @Override
        public Provider<RegularFile> file(final Provider<? extends CharSequence> path) {
            return new AbstractCombiningProvider<RegularFile, Directory, CharSequence>(RegularFile.class, this, path) {
                @Override
                protected RegularFile map(Directory b, CharSequence v) {
                    return b.file(v.toString());
                }
            };
        }
    }

    static class ToFileProvider extends AbstractMappingProvider<File, FileSystemLocation> {
        ToFileProvider(ProviderInternal<? extends FileSystemLocation> provider) {
            super(File.class, provider);
        }

        @Override
        protected File map(FileSystemLocation provider) {
            return provider.getAsFile();
        }
    }
}

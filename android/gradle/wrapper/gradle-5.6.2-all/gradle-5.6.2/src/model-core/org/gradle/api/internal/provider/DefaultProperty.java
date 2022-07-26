/*
 * Copyright 2017 the original author or authors.
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

package org.gradle.api.internal.provider;

import org.gradle.api.Transformer;
import org.gradle.api.internal.tasks.TaskDependencyResolveContext;
import org.gradle.api.provider.Property;
import org.gradle.api.provider.Provider;

import javax.annotation.Nullable;

public class DefaultProperty<T> extends AbstractProperty<T> implements Property<T> {
    private final Class<T> type;
    private final ValueSanitizer<T> sanitizer;
    private ProviderInternal<? extends T> convention = Providers.notDefined();
    private ProviderInternal<? extends T> provider;

    public DefaultProperty(Class<T> type) {
        applyDefaultValue();
        this.type = type;
        this.sanitizer = ValueSanitizers.forType(type);
    }

    @Override
    public Class<?> publicType() {
        return Property.class;
    }

    @Override
    public int getFactoryId() {
        return ManagedFactories.PropertyManagedFactory.FACTORY_ID;
    }

    @Override
    public Class<T> getType() {
        return type;
    }

    @Override
    public boolean maybeVisitBuildDependencies(TaskDependencyResolveContext context) {
        if (super.maybeVisitBuildDependencies(context)) {
            return true;
        }
        return provider.maybeVisitBuildDependencies(context);
    }

    @Override
    public void setFromAnyValue(Object object) {
        if (object instanceof Provider) {
            set((Provider<T>) object);
        } else {
            set((T) object);
        }
    }

    @Override
    public void set(T value) {
        if (value == null) {
            if (beforeReset()) {
                this.provider = convention;
            }
            return;
        }

        if (beforeMutate()) {
            value = sanitizer.sanitize(value);
            if (!type.isInstance(value)) {
                throw new IllegalArgumentException(String.format("Cannot set the value of a property of type %s using an instance of type %s.", type.getName(), value.getClass().getName()));
            }
            this.provider = Providers.of(value);
        }
    }

    @Override
    public Property<T> value(@Nullable T value) {
        set(value);
        return this;
    }

    @Override
    public Property<T> value(Provider<? extends T> provider) {
        set(provider);
        return this;
    }

    @Override
    public void set(Provider<? extends T> provider) {
        if (!beforeMutate()) {
            return;
        }
        if (provider == null) {
            throw new IllegalArgumentException("Cannot set the value of a property using a null provider.");
        }
        ProviderInternal<? extends T> p = Providers.internal(provider);
        if (p.getType() != null && !type.isAssignableFrom(p.getType())) {
            throw new IllegalArgumentException(String.format("Cannot set the value of a property of type %s using a provider of type %s.", type.getName(), p.getType().getName()));
        } else if (p.getType() == null) {
            p = p.map(new Transformer<T, T>() {
                @Override
                public T transform(T t) {
                    t = sanitizer.sanitize(t);
                    if (type.isInstance(t)) {
                        return t;
                    }
                    throw new IllegalArgumentException(String.format("Cannot get the value of a property of type %s as the provider associated with this property returned a value of type %s.", type.getName(), t.getClass().getName()));
                }
            });
        }

        this.provider = p;
    }

    @Override
    public Property<T> convention(T value) {
        ProviderInternal<T> provider = Providers.of(value);
        return convention(provider);
    }

    @Override
    public Property<T> convention(Provider<? extends T> valueProvider) {
        ProviderInternal<? extends T> providerInternal = Providers.internal(valueProvider);
        if (shouldApplyConvention()) {
            this.provider = providerInternal;
        }
        this.convention = providerInternal;
        return this;
    }

    @Override
    protected void applyDefaultValue() {
        provider = Providers.notDefined();
    }

    @Override
    protected void makeFinal() {
        provider = provider.withFinalValue();
        convention = Providers.notDefined();
    }

    @Override
    public T get() {
        beforeRead();
        return provider.get();
    }

    @Override
    public T getOrNull() {
        beforeRead();
        return provider.getOrNull();
    }

    @Override
    public T getOrElse(T defaultValue) {
        beforeRead();
        T t = provider.getOrNull();
        if (t == null) {
            return defaultValue;
        }
        return t;
    }

    @Override
    public boolean isPresent() {
        beforeRead();
        return provider.isPresent();
    }

    @Override
    public String toString() {
        // NOTE: Do not realize the value of the Provider in toString().  The debugger will try to call this method and make debugging really frustrating.
        return String.format("property(%s, %s)", type, provider);
    }
}

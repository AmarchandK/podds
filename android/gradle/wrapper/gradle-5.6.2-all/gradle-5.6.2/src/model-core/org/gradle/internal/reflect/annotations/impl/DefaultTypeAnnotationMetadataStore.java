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

package org.gradle.internal.reflect.annotations.impl;

import com.google.common.base.Equivalence;
import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.ImmutableSortedSet;
import com.google.common.collect.Iterables;
import com.google.common.collect.ListMultimap;
import com.google.common.collect.Ordering;
import com.google.common.collect.SetMultimap;
import com.google.common.collect.Sets;
import org.gradle.cache.internal.CrossBuildInMemoryCache;
import org.gradle.cache.internal.CrossBuildInMemoryCacheFactory;
import org.gradle.internal.reflect.AnnotationCategory;
import org.gradle.internal.reflect.ParameterValidationContext;
import org.gradle.internal.reflect.PropertyAccessorType;
import org.gradle.internal.reflect.annotations.PropertyAnnotationMetadata;
import org.gradle.internal.reflect.annotations.TypeAnnotationMetadata;
import org.gradle.internal.reflect.annotations.TypeAnnotationMetadataStore;

import javax.annotation.Nullable;
import javax.inject.Inject;
import java.lang.annotation.Annotation;
import java.lang.reflect.AnnotatedElement;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Consumer;
import java.util.function.Predicate;
import java.util.stream.Stream;

import static java.util.stream.Collectors.joining;
import static org.gradle.internal.reflect.AnnotationCategory.TYPE;
import static org.gradle.internal.reflect.Methods.SIGNATURE_EQUIVALENCE;

public class DefaultTypeAnnotationMetadataStore implements TypeAnnotationMetadataStore {
    private static final TypeAnnotationMetadata EMPTY_TYPE_ANNOTATION_METADATA = new TypeAnnotationMetadata() {
        @Override
        public ImmutableSet<Annotation> getAnnotations() {
            return ImmutableSet.of();
        }

        @Override
        public boolean isAnnotationPresent(Class<? extends Annotation> annotationType) {
            return false;
        }

        @Override
        public ImmutableSortedSet<PropertyAnnotationMetadata> getPropertiesAnnotationMetadata() {
            return ImmutableSortedSet.of();
        }

        @Override
        public void visitValidationFailures(@Nullable String ownerPath, ParameterValidationContext validationContext) {
        }
    };

    private final Set<Class<? extends Annotation>> recordedTypeAnnotations;
    private final ImmutableMap<Class<? extends Annotation>, AnnotationCategory> propertyAnnotationCategories;
    private final CrossBuildInMemoryCache<Class<?>, TypeAnnotationMetadata> cache;
    private final Set<String> potentiallyIgnoredMethodNames;
    private final Set<Equivalence.Wrapper<Method>> globallyIgnoredMethods;
    private final Set<Class<?>> mutableNonFinalClasses;
    private final Class<? extends Annotation> ignoredMethodAnnotation;
    private final Predicate<? super Method> generatedMethodDetector;

    /**
     * Constructs the store.
     *
     * @param recordedTypeAnnotations Annotations on the type itself that should be gathered.
     * @param propertyAnnotationCategories Annotations on the properties that should be gathered. They are mapped to {@linkplain AnnotationCategory annotation categories}. The {@code ignoreMethodAnnotation} and the {@literal @}{@link Inject} annotations are automatically mapped to the {@link AnnotationCategory#TYPE TYPE} category.
     * @param ignoredSuperTypes Super-types to ignore. Ignored super-types are considered having no type annotations nor any annotated properties.
     * @param ignoreMethodsFromTypes Methods to ignore: any methods declared by these types are ignored even when overriden by a given type. This is to avoid detecting methods like {@code Object.equals()} or {@code GroovyObject.getMetaClass()}.
     * @param ignoredMethodAnnotation Annotation to use to explicitly ignore a method/property.
     * @param generatedMethodDetector Predicate to test if a method was generated (vs. being provided explicitly by the user).
     * @param mutableNonFinalClasses Mutable classes that shouldn't need explicit setters
     * @param cacheFactory A factory to create cross-build in-memory caches.
     */
    public DefaultTypeAnnotationMetadataStore(
        Collection<Class<? extends Annotation>> recordedTypeAnnotations,
        Map<Class<? extends Annotation>, ? extends AnnotationCategory> propertyAnnotationCategories,
        Collection<Class<?>> ignoredSuperTypes,
        Collection<Class<?>> ignoreMethodsFromTypes,
        Collection<Class<?>> mutableNonFinalClasses,
        Class<? extends Annotation> ignoredMethodAnnotation,
        Predicate<? super Method> generatedMethodDetector,
        CrossBuildInMemoryCacheFactory cacheFactory
    ) {
        this.recordedTypeAnnotations = ImmutableSet.copyOf(recordedTypeAnnotations);
        this.propertyAnnotationCategories = getBuild(propertyAnnotationCategories, ignoredMethodAnnotation);
        this.cache = initCache(ignoredSuperTypes, cacheFactory);
        this.potentiallyIgnoredMethodNames = allMethodNamesOf(ignoreMethodsFromTypes);
        this.globallyIgnoredMethods = allMethodsOf(ignoreMethodsFromTypes);
        this.mutableNonFinalClasses = ImmutableSet.copyOf(mutableNonFinalClasses);
        this.ignoredMethodAnnotation = ignoredMethodAnnotation;
        this.generatedMethodDetector = generatedMethodDetector;
    }

    private static ImmutableMap<Class<? extends Annotation>, AnnotationCategory> getBuild(Map<Class<? extends Annotation>, ? extends AnnotationCategory> propertyAnnotationCategories, Class<? extends Annotation> ignoredMethodAnnotation) {
        return ImmutableMap.<Class<? extends Annotation>, AnnotationCategory>builder()
            .putAll(propertyAnnotationCategories)
            .put(Inject.class, TYPE)
            .put(ignoredMethodAnnotation, TYPE)
            .build();
    }

    private static CrossBuildInMemoryCache<Class<?>, TypeAnnotationMetadata> initCache(Collection<Class<?>> ignoredSuperTypes, CrossBuildInMemoryCacheFactory cacheFactory) {
        CrossBuildInMemoryCache<Class<?>, TypeAnnotationMetadata> result = cacheFactory.newClassCache();
        for (Class<?> ignoredSuperType : ignoredSuperTypes) {
            result.put(ignoredSuperType, EMPTY_TYPE_ANNOTATION_METADATA);
        }
        return result;
    }

    private static ImmutableSet<String> allMethodNamesOf(Iterable<Class<?>> classes) {
        ImmutableSet.Builder<String> methods = ImmutableSet.builder();
        for (Class<?> clazz : classes) {
            for (Method method : clazz.getMethods()) {
                methods.add(method.getName());
            }
        }
        return methods.build();
    }

    private static ImmutableSet<Equivalence.Wrapper<Method>> allMethodsOf(Iterable<Class<?>> classes) {
        ImmutableSet.Builder<Equivalence.Wrapper<Method>> methods = ImmutableSet.builder();
        for (Class<?> clazz : classes) {
            for (Method method : clazz.getMethods()) {
                methods.add(SIGNATURE_EQUIVALENCE.wrap(method));
            }
        }
        return methods.build();
    }

    @Override
    public TypeAnnotationMetadata getTypeAnnotationMetadata(Class<?> type) {
        return cache.get(type, t -> createTypeAnnotationMetadata(type));
    }

    private TypeAnnotationMetadata createTypeAnnotationMetadata(Class<?> type) {
        ImmutableSet.Builder<Annotation> typeAnnotations = ImmutableSet.builder();
        for (Annotation typeAnnotation : type.getDeclaredAnnotations()) {
            if (recordedTypeAnnotations.contains(typeAnnotation.annotationType())) {
                typeAnnotations.add(typeAnnotation);
            }
        }

        Map<String, PropertyAnnotationMetadataBuilder> methodBuilders = new HashMap<>();

        inheritMethods(type, methodBuilders);

        ValidationErrorsBuilder errorsBuilder = new ValidationErrorsBuilder(type);
        ImmutableSortedSet<PropertyAnnotationMetadata> propertiesMetadata;
        if (!type.isSynthetic()) {
            propertiesMetadata = extractPropertiesFrom(type, methodBuilders, errorsBuilder);
        } else {
            ImmutableSortedSet.Builder<PropertyAnnotationMetadata> propertiesMetadataBuilder = ImmutableSortedSet.naturalOrder();
            for (PropertyAnnotationMetadataBuilder propertyMetadataBuilder : methodBuilders.values()) {
                propertiesMetadataBuilder.add(propertyMetadataBuilder.build());
            }
            propertiesMetadata = propertiesMetadataBuilder.build();
        }

        return new DefaultTypeAnnotationMetadata(typeAnnotations.build(), propertiesMetadata, errorsBuilder.build());
    }

    private void inheritMethods(Class<?> type, Map<String, PropertyAnnotationMetadataBuilder> methodBuilders) {
        visitSuperTypes(type, superType -> {
            for (PropertyAnnotationMetadata superProperty : superType.getPropertiesAnnotationMetadata()) {
                getOrCreateBuilder(superProperty.getPropertyName(), superProperty.getMethod(), methodBuilders)
                    .inheritAnnotations(superProperty);
            }
        });
    }

    private PropertyAnnotationMetadataBuilder getOrCreateBuilder(String propertyName, Method getter, Map<String, PropertyAnnotationMetadataBuilder> propertyBuilders) {
        return propertyBuilders.computeIfAbsent(getter.getName(), methodName -> new PropertyAnnotationMetadataBuilder(propertyName, getter));
    }

    private ImmutableSortedSet<PropertyAnnotationMetadata> extractPropertiesFrom(Class<?> type, Map<String, PropertyAnnotationMetadataBuilder> methodBuilders, ValidationErrorsBuilder errorsBuilder) {
        Method[] methods = type.getDeclaredMethods();
        // Make sure getters end up before the setters
        Arrays.sort(methods, (a, b) -> a.getName().compareTo(b.getName()));
        for (Method method : methods) {
            processMethodAnnotations(method, methodBuilders, errorsBuilder);
        }

        ImmutableList<PropertyAnnotationMetadataBuilder> propertyBuilders = convertMethodToPropertyBuilders(methodBuilders);
        ImmutableMap<String, ImmutableMap<Class<? extends Annotation>, Annotation>> fieldAnnotationsByPropertyName = collectFieldAnnotations(type);
        return mergePropertiesAndFieldMetadata(propertyBuilders, fieldAnnotationsByPropertyName, errorsBuilder);
    }

    private ImmutableList<PropertyAnnotationMetadataBuilder> convertMethodToPropertyBuilders(Map<String, PropertyAnnotationMetadataBuilder> methodBuilders) {
        Map<String, PropertyAnnotationMetadataBuilder> propertyBuilders = new LinkedHashMap<>();
        List<PropertyAnnotationMetadataBuilder> metadataBuilders = Ordering.<PropertyAnnotationMetadataBuilder>from(
            Comparator.comparing(metadataBuilder -> metadataBuilder.getMethod().getName()))
            .sortedCopy(methodBuilders.values());
        for (PropertyAnnotationMetadataBuilder metadataBuilder : metadataBuilders) {
            String propertyName = metadataBuilder.getPropertyName();
            PropertyAnnotationMetadataBuilder previouslySeenBuilder = propertyBuilders.putIfAbsent(propertyName, metadataBuilder);
            // Do we have an 'is'-getter as well as a 'get'-getter?
            if (previouslySeenBuilder != null) {
                // It is okay to have redundant generated 'is'-getters
                if (generatedMethodDetector.test(metadataBuilder.method)) {
                    continue;
                }
                // The 'is'-getter is ignored, we can skip it in favor of the 'get'-getter
                if (metadataBuilder.hasAnnotation(ignoredMethodAnnotation)) {
                    continue;
                }
                // The 'get'-getter was ignored, we can override it with the 'is'`-getter
                if (previouslySeenBuilder.hasAnnotation(ignoredMethodAnnotation)) {
                    propertyBuilders.put(propertyName, metadataBuilder);
                    continue;
                }
                previouslySeenBuilder.recordError(String.format("has redundant getters: '%s()' and '%s()'",
                    previouslySeenBuilder.method.getName(),
                    metadataBuilder.method.getName()));
            }
        }
        return ImmutableList.copyOf(propertyBuilders.values());
    }

    private ImmutableMap<String, ImmutableMap<Class<? extends Annotation>, Annotation>> collectFieldAnnotations(Class<?> type) {
        ImmutableMap.Builder<String, ImmutableMap<Class<? extends Annotation>, Annotation>> fieldAnnotationsByPropertyName = ImmutableMap.builder();
        for (Field declaredField : type.getDeclaredFields()) {
            if (declaredField.isSynthetic()) {
                continue;
            }
            fieldAnnotationsByPropertyName.put(declaredField.getName(), collectRelevantAnnotations(declaredField));
        }
        return fieldAnnotationsByPropertyName.build();
    }

    private ImmutableSortedSet<PropertyAnnotationMetadata> mergePropertiesAndFieldMetadata(ImmutableList<PropertyAnnotationMetadataBuilder> propertyBuilders, ImmutableMap<String, ImmutableMap<Class<? extends Annotation>, Annotation>> fieldAnnotationsByPropertyName, ValidationErrorsBuilder errorsBuilder) {
        ImmutableSortedSet.Builder<PropertyAnnotationMetadata> propertiesMetadataBuilder = ImmutableSortedSet.naturalOrder();
        ImmutableSet.Builder<String> fieldsSeenBuilder = ImmutableSet.builderWithExpectedSize(fieldAnnotationsByPropertyName.size());
        for (PropertyAnnotationMetadataBuilder metadataBuilder : propertyBuilders) {
            String propertyName = metadataBuilder.getPropertyName();
            ImmutableMap<Class<? extends Annotation>, Annotation> fieldAnnotations = fieldAnnotationsByPropertyName.get(propertyName);
            if (fieldAnnotations != null) {
                fieldsSeenBuilder.add(propertyName);
                for (Annotation annotation : fieldAnnotations.values()) {
                    metadataBuilder.declareAnnotation(annotation);
                }
            }
            propertiesMetadataBuilder.add(metadataBuilder.build());
        }
        ImmutableSortedSet<PropertyAnnotationMetadata> propertiesMetadata = propertiesMetadataBuilder.build();

        // Report fields with annotations that have not been seen while processing properties
        ImmutableSet<String> fieldsSeen = fieldsSeenBuilder.build();
        if (fieldsSeen.size() != fieldAnnotationsByPropertyName.size()) {
            fieldAnnotationsByPropertyName.entrySet().stream()
                .filter(entry -> {
                    String fieldName = entry.getKey();
                    ImmutableMap<Class<? extends Annotation>, Annotation> fieldAnnotations = entry.getValue();
                    return !fieldAnnotations.isEmpty()
                        && !fieldsSeen.contains(fieldName)
                        // @Inject is allowed on fields only
                        && !fieldAnnotations.containsKey(Inject.class);
                })
                .forEach(entry -> {
                    String fieldName = entry.getKey();
                    ImmutableMap<Class<? extends Annotation>, Annotation> fieldAnnotations = entry.getValue();
                    errorsBuilder.recordError(String.format("field '%s' without corresponding getter has been annotated with %s",
                        fieldName,
                        simpleAnnotationNames(fieldAnnotations.keySet().stream())));
                });
        }
        return propertiesMetadata;
    }

    private void processMethodAnnotations(Method method, Map<String, PropertyAnnotationMetadataBuilder> methodBuilders, ValidationErrorsBuilder errorsBuilder) {
        if (method.isSynthetic()) {
            return;
        }
        if (method.isBridge()) {
            return;
        }
        // As an optimization first check if the method name is among the candidates before we construct an equivalence wrapper
        if (potentiallyIgnoredMethodNames.contains(method.getName())
            && globallyIgnoredMethods.contains(SIGNATURE_EQUIVALENCE.wrap(method))) {
            return;
        }

        ImmutableMap<Class<? extends Annotation>, Annotation> annotations = collectRelevantAnnotations(method);

        if (Modifier.isStatic(method.getModifiers())) {
            validateNotAnnotated("static", method, annotations.keySet(), errorsBuilder);
            return;
        }

        PropertyAccessorType accessorType = PropertyAccessorType.of(method);
        if (accessorType == null) {
            validateNotAnnotated("non-property", method, annotations.keySet(), errorsBuilder);
            return;
        }

        String propertyName = accessorType.propertyNameFor(method);
        if (accessorType == PropertyAccessorType.SETTER) {
            validateNotAnnotated("setter", method, annotations.keySet(), errorsBuilder);
            validateSetterForMutableType(method, accessorType, errorsBuilder, propertyName);
            return;
        }

        // After this point we only see getters

        // Ignore private getters without annotations
        boolean privateGetter = Modifier.isPrivate(method.getModifiers());
        if (privateGetter && annotations.isEmpty()) {
            return;
        }

        PropertyAnnotationMetadataBuilder metadataBuilder = getOrCreateBuilder(propertyName, method, methodBuilders);
        metadataBuilder.overrideMethod(method);

        if (privateGetter) {
            // At this point we must have annotations on this private getter
            metadataBuilder.recordError(String.format("is private and annotated with %s",
                simpleAnnotationNames(annotations.keySet().stream())));
        }

        Annotation ignoredAnnotation = annotations.get(ignoredMethodAnnotation);
        if (ignoredAnnotation != null) {
            if (annotations.size() != 1) {
                metadataBuilder.recordError(String.format("getter '%s()' annotated with @%s should not be also annotated with %s",
                    method.getName(),
                    ignoredMethodAnnotation.getSimpleName(),
                    simpleAnnotationNames(annotations.keySet().stream()
                        .filter(annotationType -> !annotationType.equals(ignoredMethodAnnotation)))
                ));
            }
        }

        for (Annotation annotation : annotations.values()) {
            metadataBuilder.declareAnnotation(annotation);
        }
    }

    private void validateSetterForMutableType(Method setterMethod, PropertyAccessorType setterAccessorType, ValidationErrorsBuilder errorsBuilder, String propertyName) {
        Class<?> setterType = setterAccessorType.propertyTypeFor(setterMethod);
        if (isSetterProhibitedForType(setterType)) {
            String typeName = setterType.getName();
            errorsBuilder.recordError(String.format("property '%s' of mutable type '%s' is writable. Properties of this type should be read-only and mutated via the value itself", propertyName, typeName));
        }
    }

    private boolean isSetterProhibitedForType(Class<?> setter) {
        return mutableNonFinalClasses.stream()
            .anyMatch(prohibited -> prohibited.isAssignableFrom(setter));
    }

    private void visitSuperTypes(Class<?> type, Consumer<? super TypeAnnotationMetadata> visitor) {
        Arrays.stream(type.getInterfaces())
            .map(iface -> getTypeAnnotationMetadata(iface))
            .forEach(visitor);
        Class<?> superclass = type.getSuperclass();
        if (superclass != null) {
            visitor.accept(getTypeAnnotationMetadata(superclass));
        }
    }

    private static void validateNotAnnotated(String methodKind, Method method, Set<Class<? extends Annotation>> annotationTypes, ValidationErrorsBuilder errorsBuilder) {
        if (!annotationTypes.isEmpty()) {
            errorsBuilder.recordError(String.format("%s method '%s()' should not be annotated with: %s",
                methodKind, method.getName(), simpleAnnotationNames(annotationTypes.stream())
            ));
        }
    }

    private static String simpleAnnotationNames(Stream<Class<? extends Annotation>> annotationTypes) {
        return annotationTypes
            .map(annotationType -> "@" + annotationType.getSimpleName())
            .collect(joining(", "));
    }

    private ImmutableMap<Class<? extends Annotation>, Annotation> collectRelevantAnnotations(AnnotatedElement element) {
        Annotation[] annotations = element.getDeclaredAnnotations();
        if (annotations.length == 0) {
            return ImmutableMap.of();
        }
        ImmutableMap.Builder<Class<? extends Annotation>, Annotation> relevantAnnotations = ImmutableMap.builderWithExpectedSize(annotations.length);
        for (Annotation annotation : annotations) {
            Class<? extends Annotation> annotationType = annotation.annotationType();
            if (propertyAnnotationCategories.containsKey(annotationType)
                || ignoredMethodAnnotation.equals(annotationType)) {
                relevantAnnotations.put(annotationType, annotation);
            }
        }
        return relevantAnnotations.build();
    }

    private class PropertyAnnotationMetadataBuilder implements Comparable<PropertyAnnotationMetadataBuilder> {
        private final String propertyName;
        private Method method;
        private final ListMultimap<AnnotationCategory, Annotation> declaredAnnotations = ArrayListMultimap.create();
        private final SetMultimap<AnnotationCategory, Annotation> inheritedAnnotations = HashMultimap.create();
        private final ImmutableList.Builder<String> problems = ImmutableList.builder();

        public PropertyAnnotationMetadataBuilder(String propertyName, Method method) {
            this.propertyName = propertyName;
            this.method = method;
        }

        public String getPropertyName() {
            return propertyName;
        }

        public Method getMethod() {
            return method;
        }

        public void overrideMethod(Method method) {
            this.method = method;
        }

        public void declareAnnotation(Annotation annotation) {
            AnnotationCategory category = propertyAnnotationCategories.get(annotation.annotationType());
            declaredAnnotations.put(category, annotation);
        }

        public void inheritAnnotations(PropertyAnnotationMetadata superProperty) {
            superProperty.getAnnotations().forEach((category, annotation) -> inheritedAnnotations.put(category, annotation));
        }

        public void recordError(String problem) {
            problems.add(problem);
        }

        public PropertyAnnotationMetadata build() {
            return new DefaultPropertyAnnotationMetadata(propertyName, method, mergeAnnotations(), problems.build());
        }

        private ImmutableMap<AnnotationCategory, Annotation> mergeAnnotations() {
            List<Annotation> declaredTypes = declaredAnnotations.get(TYPE);
            for (Annotation declaredType : declaredTypes) {
                if (declaredType.annotationType().equals(ignoredMethodAnnotation)) {
                    return ImmutableMap.of(TYPE, declaredType);
                }
            }

            ImmutableMap.Builder<AnnotationCategory, Annotation> builder = ImmutableMap.builder();
            for (AnnotationCategory category : Sets.union(declaredAnnotations.keySet(), inheritedAnnotations.keySet())) {
                Collection<Annotation> declaredAnnotationsForCategory = declaredAnnotations.get(category);
                Annotation firstAnnotation;
                if (!declaredAnnotationsForCategory.isEmpty()) {
                    firstAnnotation = getFirstAnnotation("declared", category, declaredAnnotationsForCategory);
                } else {
                    firstAnnotation = getFirstAnnotation("inherited", category, inheritedAnnotations.get(category));
                }
                builder.put(category, firstAnnotation);
            }
            return builder.build();
        }

        private Annotation getFirstAnnotation(String source, AnnotationCategory category, Collection<Annotation> annotationsForCategory) {
            Iterator<Annotation> iDeclaredAnnotationForCategory = annotationsForCategory.iterator();
            // Ignore all but the first recorded annotation
            Annotation declaredAnnotationForCategory = iDeclaredAnnotationForCategory.next();
            if (iDeclaredAnnotationForCategory.hasNext()) {
                recordError(String.format("has conflicting %s annotations %s: %s; assuming @%s",
                    category.getDisplayName(),
                    source,
                    simpleAnnotationNames(annotationsForCategory.stream()
                        .map(Annotation::annotationType)),
                    declaredAnnotationForCategory.annotationType().getSimpleName()
                ));
            }
            return declaredAnnotationForCategory;
        }

        public boolean hasAnnotation(Class<? extends Annotation> annotationType) {
            for (Annotation annotation : Iterables.concat(declaredAnnotations.values(), inheritedAnnotations.values())) {
                if (annotation.annotationType().equals(annotationType)) {
                    return true;
                }
            }
            return false;
        }

        @Override
        public int compareTo(PropertyAnnotationMetadataBuilder o) {
            return propertyName.compareTo(o.propertyName);
        }
    }

    private static class ValidationErrorsBuilder {
        private final Class<?> type;
        private final ImmutableList.Builder<String> errors = ImmutableList.builder();

        public ValidationErrorsBuilder(Class<?> type) {
            this.type = type;
        }

        public void recordError(String error) {
            errors.add("Type '" + type.getName() + "': " + error);
        }

        public ImmutableList<String> build() {
            return errors.build();
        }
    }
}

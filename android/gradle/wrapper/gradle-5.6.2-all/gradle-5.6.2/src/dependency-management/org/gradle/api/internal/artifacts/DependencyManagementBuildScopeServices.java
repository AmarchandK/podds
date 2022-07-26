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

package org.gradle.api.internal.artifacts;

import com.google.common.collect.Sets;
import org.gradle.StartParameter;
import org.gradle.api.capabilities.Capability;
import org.gradle.api.internal.ClassPathRegistry;
import org.gradle.api.internal.FeaturePreviews;
import org.gradle.api.internal.artifacts.component.ComponentIdentifierFactory;
import org.gradle.api.internal.artifacts.component.DefaultComponentIdentifierFactory;
import org.gradle.api.internal.artifacts.dsl.CapabilityNotationParserFactory;
import org.gradle.api.internal.artifacts.dsl.dependencies.DependencyFactory;
import org.gradle.api.internal.artifacts.ivyservice.ArtifactCacheLockingManager;
import org.gradle.api.internal.artifacts.ivyservice.ArtifactCacheMetadata;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.ConnectionFailureRepositoryBlacklister;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.RepositoryBlacklister;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.ResolveIvyFactory;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.ResolverProviderFactory;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.StartParameterResolutionOverride;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.CachingVersionSelectorScheme;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.DefaultVersionSelectorScheme;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.VersionComparator;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.VersionParser;
import org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.VersionSelectorScheme;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.InMemoryModuleMetadataCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.ModuleComponentResolveMetadataSerializer;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.ModuleMetadataSerializer;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.ModuleRepositoryCacheProvider;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.ModuleRepositoryCaches;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.PersistentModuleMetadataCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.SuppliedComponentMetadataSerializer;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.artifacts.DefaultModuleArtifactCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.artifacts.DefaultModuleArtifactsCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.artifacts.InMemoryModuleArtifactCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.artifacts.InMemoryModuleArtifactsCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.dynamicversions.DefaultModuleVersionsCache;
import org.gradle.api.internal.artifacts.ivyservice.modulecache.dynamicversions.InMemoryModuleVersionsCache;
import org.gradle.api.internal.artifacts.ivyservice.moduleconverter.LocalComponentMetadataBuilder;
import org.gradle.api.internal.artifacts.ivyservice.moduleconverter.dependencies.DependencyDescriptorFactory;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.DefaultLocalComponentRegistry;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.DefaultProjectLocalComponentProvider;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.DefaultProjectPublicationRegistry;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.LocalComponentProvider;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.LocalComponentRegistry;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.ProjectDependencyResolver;
import org.gradle.api.internal.artifacts.ivyservice.projectmodule.ProjectPublicationRegistry;
import org.gradle.api.internal.artifacts.ivyservice.resolveengine.DefaultArtifactDependencyResolver;
import org.gradle.api.internal.artifacts.ivyservice.resolveengine.excludes.ModuleExclusions;
import org.gradle.api.internal.artifacts.ivyservice.resolveengine.result.AttributeContainerSerializer;
import org.gradle.api.internal.artifacts.ivyservice.resolveengine.result.DesugaredAttributeContainerSerializer;
import org.gradle.api.internal.artifacts.mvnsettings.DefaultLocalMavenRepositoryLocator;
import org.gradle.api.internal.artifacts.mvnsettings.DefaultMavenFileLocations;
import org.gradle.api.internal.artifacts.mvnsettings.DefaultMavenSettingsProvider;
import org.gradle.api.internal.artifacts.mvnsettings.LocalMavenRepositoryLocator;
import org.gradle.api.internal.artifacts.mvnsettings.MavenSettingsProvider;
import org.gradle.api.internal.artifacts.repositories.metadata.IvyMutableModuleMetadataFactory;
import org.gradle.api.internal.artifacts.repositories.metadata.MavenMutableModuleMetadataFactory;
import org.gradle.api.internal.artifacts.repositories.resolver.DefaultExternalResourceAccessor;
import org.gradle.api.internal.artifacts.repositories.resolver.ExternalResourceAccessor;
import org.gradle.api.internal.artifacts.repositories.transport.RepositoryTransport;
import org.gradle.api.internal.artifacts.repositories.transport.RepositoryTransportFactory;
import org.gradle.api.internal.attributes.ImmutableAttributesFactory;
import org.gradle.api.internal.file.FileLookup;
import org.gradle.api.internal.file.TemporaryFileProvider;
import org.gradle.api.internal.file.TmpDirTemporaryFileProvider;
import org.gradle.api.internal.file.collections.DirectoryFileTreeFactory;
import org.gradle.api.internal.filestore.ivy.ArtifactIdentifierFileStore;
import org.gradle.api.internal.model.NamedObjectInstantiator;
import org.gradle.api.internal.notations.ClientModuleNotationParserFactory;
import org.gradle.api.internal.notations.DependencyConstraintNotationParser;
import org.gradle.api.internal.notations.DependencyNotationParser;
import org.gradle.api.internal.notations.ProjectDependencyFactory;
import org.gradle.api.internal.project.ProjectInternal;
import org.gradle.api.internal.project.ProjectRegistry;
import org.gradle.api.internal.project.ProjectStateRegistry;
import org.gradle.api.internal.runtimeshaded.RuntimeShadedJarFactory;
import org.gradle.authentication.Authentication;
import org.gradle.cache.CacheRepository;
import org.gradle.cache.internal.GeneratedGradleJarCache;
import org.gradle.cache.internal.InMemoryCacheDecoratorFactory;
import org.gradle.cache.internal.ProducerGuard;
import org.gradle.initialization.ProjectAccessListener;
import org.gradle.internal.build.BuildState;
import org.gradle.internal.build.BuildStateRegistry;
import org.gradle.internal.component.external.model.ModuleComponentArtifactMetadata;
import org.gradle.internal.component.external.model.PreferJavaRuntimeVariant;
import org.gradle.internal.file.FileAccessTimeJournal;
import org.gradle.internal.installation.CurrentGradleInstallation;
import org.gradle.internal.instantiation.InstantiatorFactory;
import org.gradle.internal.logging.progress.ProgressLoggerFactory;
import org.gradle.internal.operations.BuildOperationExecutor;
import org.gradle.internal.reflect.Instantiator;
import org.gradle.internal.resolve.caching.ComponentMetadataRuleExecutor;
import org.gradle.internal.resolve.caching.ComponentMetadataSupplierRuleExecutor;
import org.gradle.internal.resolve.caching.DesugaringAttributeContainerSerializer;
import org.gradle.internal.resource.ExternalResourceName;
import org.gradle.internal.resource.TextResourceLoader;
import org.gradle.internal.resource.cached.ByUrlCachedExternalResourceIndex;
import org.gradle.internal.resource.cached.ExternalResourceFileStore;
import org.gradle.internal.resource.connector.ResourceConnectorFactory;
import org.gradle.internal.resource.local.FileResourceRepository;
import org.gradle.internal.resource.local.LocallyAvailableResourceFinder;
import org.gradle.internal.resource.local.ivy.LocallyAvailableResourceFinderFactory;
import org.gradle.internal.resource.transfer.DefaultUriTextResourceLoader;
import org.gradle.internal.service.ServiceRegistry;
import org.gradle.internal.snapshot.ValueSnapshotter;
import org.gradle.internal.typeconversion.NotationParser;
import org.gradle.util.BuildCommencedTimeProvider;
import org.gradle.util.internal.SimpleMapInterner;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;

/**
 * The set of dependency management services that are created per build.
 */
class DependencyManagementBuildScopeServices {
    DependencyManagementServices createDependencyManagementServices(ServiceRegistry parent) {
        return new DefaultDependencyManagementServices(parent);
    }

    ComponentIdentifierFactory createComponentIdentifierFactory(BuildState currentBuild, BuildStateRegistry buildRegistry) {
        return new DefaultComponentIdentifierFactory(buildRegistry.getBuild(currentBuild.getBuildIdentifier()));
    }

    DependencyFactory createDependencyFactory(
        Instantiator instantiator,
        ProjectAccessListener projectAccessListener,
        StartParameter startParameter,
        ClassPathRegistry classPathRegistry,
        CurrentGradleInstallation currentGradleInstallation,
        FileLookup fileLookup,
        RuntimeShadedJarFactory runtimeShadedJarFactory,
        ImmutableAttributesFactory attributesFactory,
        SimpleMapInterner stringInterner) {
        NotationParser<Object, Capability> capabilityNotationParser = new CapabilityNotationParserFactory(false).create();
        DefaultProjectDependencyFactory factory = new DefaultProjectDependencyFactory(
            projectAccessListener, instantiator, startParameter.isBuildProjectDependencies(), capabilityNotationParser, attributesFactory);
        ProjectDependencyFactory projectDependencyFactory = new ProjectDependencyFactory(factory);

        return new DefaultDependencyFactory(
            DependencyNotationParser.parser(instantiator, factory, classPathRegistry, fileLookup, runtimeShadedJarFactory, currentGradleInstallation, stringInterner),
                DependencyConstraintNotationParser.parser(instantiator, factory, stringInterner),
                new ClientModuleNotationParserFactory(instantiator, stringInterner).create(),
                capabilityNotationParser, projectDependencyFactory,
            attributesFactory);
    }

    RuntimeShadedJarFactory createRuntimeShadedJarFactory(GeneratedGradleJarCache jarCache, ProgressLoggerFactory progressLoggerFactory, DirectoryFileTreeFactory directoryFileTreeFactory, BuildOperationExecutor executor) {
        return new RuntimeShadedJarFactory(jarCache, progressLoggerFactory, directoryFileTreeFactory, executor);
    }

    BuildCommencedTimeProvider createBuildTimeProvider() {
        return new BuildCommencedTimeProvider();
    }

    ModuleExclusions createModuleExclusions() {
        return new ModuleExclusions();
    }

    MavenMutableModuleMetadataFactory createMutableMavenMetadataFactory(ImmutableModuleIdentifierFactory moduleIdentifierFactory,
                                                                        ImmutableAttributesFactory attributesFactory,
                                                                        NamedObjectInstantiator instantiator,
                                                                        PreferJavaRuntimeVariant schema) {
        return new MavenMutableModuleMetadataFactory(moduleIdentifierFactory, attributesFactory, instantiator, schema);
    }

    IvyMutableModuleMetadataFactory createMutableIvyMetadataFactory(ImmutableModuleIdentifierFactory moduleIdentifierFactory, ImmutableAttributesFactory attributesFactory, PreferJavaRuntimeVariant schema) {
        return new IvyMutableModuleMetadataFactory(moduleIdentifierFactory, attributesFactory, schema);
    }

    AttributeContainerSerializer createAttributeContainerSerializer(ImmutableAttributesFactory attributesFactory, NamedObjectInstantiator instantiator) {
        return new DesugaredAttributeContainerSerializer(attributesFactory, instantiator);
    }

    ModuleRepositoryCacheProvider createModuleRepositoryCacheProvider(BuildCommencedTimeProvider timeProvider, ArtifactCacheLockingManager artifactCacheLockingManager, ImmutableModuleIdentifierFactory moduleIdentifierFactory,
                                                                      ArtifactCacheMetadata artifactCacheMetadata, AttributeContainerSerializer attributeContainerSerializer, MavenMutableModuleMetadataFactory mavenMetadataFactory, IvyMutableModuleMetadataFactory ivyMetadataFactory, SimpleMapInterner stringInterner,
                                                                      ArtifactIdentifierFileStore artifactIdentifierFileStore) {
        ModuleRepositoryCaches caches = new ModuleRepositoryCaches(
            new InMemoryModuleVersionsCache(timeProvider, new DefaultModuleVersionsCache(
                timeProvider,
                artifactCacheLockingManager,
                moduleIdentifierFactory)),
            new InMemoryModuleMetadataCache(timeProvider, new PersistentModuleMetadataCache(
                timeProvider,
                artifactCacheLockingManager,
                artifactCacheMetadata,
                moduleIdentifierFactory,
                attributeContainerSerializer,
                mavenMetadataFactory,
                ivyMetadataFactory,
                stringInterner)),
            new InMemoryModuleArtifactsCache(timeProvider, new DefaultModuleArtifactsCache(
                timeProvider,
                artifactCacheLockingManager
            )),
            new InMemoryModuleArtifactCache(timeProvider, new DefaultModuleArtifactCache(
                "module-artifact",
                timeProvider,
                artifactCacheLockingManager,
                artifactIdentifierFileStore.getFileAccessTracker()
            ))
        );
        ModuleRepositoryCaches inMemoryCaches = new ModuleRepositoryCaches(
            new InMemoryModuleVersionsCache(timeProvider),
            new InMemoryModuleMetadataCache(timeProvider),
            new InMemoryModuleArtifactsCache(timeProvider),
            new InMemoryModuleArtifactCache(timeProvider)
        );
        return new ModuleRepositoryCacheProvider(caches, inMemoryCaches);
    }

    ByUrlCachedExternalResourceIndex createArtifactUrlCachedResolutionIndex(BuildCommencedTimeProvider timeProvider, ArtifactCacheLockingManager artifactCacheLockingManager, ExternalResourceFileStore externalResourceFileStore) {
        return new ByUrlCachedExternalResourceIndex(
            "resource-at-url",
            timeProvider,
            artifactCacheLockingManager,
            externalResourceFileStore.getFileAccessTracker()
        );
    }

    ArtifactIdentifierFileStore createArtifactRevisionIdFileStore(ArtifactCacheMetadata artifactCacheMetadata, FileAccessTimeJournal fileAccessTimeJournal) {
        return new ArtifactIdentifierFileStore(artifactCacheMetadata.getFileStoreDirectory(), new TmpDirTemporaryFileProvider(), fileAccessTimeJournal);
    }

    ExternalResourceFileStore createExternalResourceFileStore(ArtifactCacheMetadata artifactCacheMetadata, FileAccessTimeJournal fileAccessTimeJournal) {
        return new ExternalResourceFileStore(artifactCacheMetadata.getExternalResourcesStoreDirectory(), new TmpDirTemporaryFileProvider(), fileAccessTimeJournal);
    }

    TextResourceLoader createTextResourceLoader(ExternalResourceFileStore resourceFileStore, RepositoryTransportFactory repositoryTransportFactory) {
        HashSet<String> schemas = Sets.newHashSet("https", "http");
        RepositoryTransport transport = repositoryTransportFactory.createTransport(schemas, "http auth", Collections.<Authentication>emptyList());
        ExternalResourceAccessor externalResourceAccessor = new DefaultExternalResourceAccessor(resourceFileStore, transport.getResourceAccessor());
        return new DefaultUriTextResourceLoader(externalResourceAccessor, schemas);
    }

    MavenSettingsProvider createMavenSettingsProvider() {
        return new DefaultMavenSettingsProvider(new DefaultMavenFileLocations());
    }

    LocalMavenRepositoryLocator createLocalMavenRepositoryLocator(MavenSettingsProvider mavenSettingsProvider) {
        return new DefaultLocalMavenRepositoryLocator(mavenSettingsProvider);
    }

    LocallyAvailableResourceFinder<ModuleComponentArtifactMetadata> createArtifactRevisionIdLocallyAvailableResourceFinder(ArtifactCacheMetadata artifactCacheMetadata, LocalMavenRepositoryLocator localMavenRepositoryLocator, ArtifactIdentifierFileStore fileStore) {
        LocallyAvailableResourceFinderFactory finderFactory = new LocallyAvailableResourceFinderFactory(
            artifactCacheMetadata,
            localMavenRepositoryLocator,
            fileStore);
        return finderFactory.create();
    }

    RepositoryTransportFactory createRepositoryTransportFactory(StartParameter startParameter,
                                                                ProgressLoggerFactory progressLoggerFactory,
                                                                TemporaryFileProvider temporaryFileProvider,
                                                                ByUrlCachedExternalResourceIndex externalResourceIndex,
                                                                BuildCommencedTimeProvider buildCommencedTimeProvider,
                                                                ArtifactCacheLockingManager artifactCacheLockingManager,
                                                                List<ResourceConnectorFactory> resourceConnectorFactories,
                                                                BuildOperationExecutor buildOperationExecutor,
                                                                ProducerGuard<ExternalResourceName> producerGuard,
                                                                FileResourceRepository fileResourceRepository) {
        StartParameterResolutionOverride startParameterResolutionOverride = new StartParameterResolutionOverride(startParameter);
        return new RepositoryTransportFactory(
            resourceConnectorFactories,
            progressLoggerFactory,
            temporaryFileProvider,
            externalResourceIndex,
            buildCommencedTimeProvider,
            artifactCacheLockingManager,
            buildOperationExecutor,
            startParameterResolutionOverride,
            producerGuard,
            fileResourceRepository);
    }

    RepositoryBlacklister createRepositoryBlacklister() {
        return new ConnectionFailureRepositoryBlacklister();
    }

    ResolveIvyFactory createResolveIvyFactory(StartParameter startParameter, ModuleRepositoryCacheProvider moduleRepositoryCacheProvider,
                                              BuildCommencedTimeProvider buildCommencedTimeProvider,
                                              VersionComparator versionComparator,
                                              ImmutableModuleIdentifierFactory moduleIdentifierFactory,
                                              RepositoryBlacklister repositoryBlacklister,
                                              VersionParser versionParser,
                                              InstantiatorFactory instantiatorFactory) {
        StartParameterResolutionOverride startParameterResolutionOverride = new StartParameterResolutionOverride(startParameter);
        return new ResolveIvyFactory(
            moduleRepositoryCacheProvider,
            startParameterResolutionOverride,
            buildCommencedTimeProvider,
            versionComparator,
            moduleIdentifierFactory,
            repositoryBlacklister,
            versionParser,
            instantiatorFactory);
    }

    ArtifactDependencyResolver createArtifactDependencyResolver(ResolveIvyFactory resolveIvyFactory,
                                                                DependencyDescriptorFactory dependencyDescriptorFactory,
                                                                VersionComparator versionComparator,
                                                                List<ResolverProviderFactory> resolverFactories,
                                                                ProjectDependencyResolver projectDependencyResolver,
                                                                ModuleExclusions moduleExclusions,
                                                                BuildOperationExecutor buildOperationExecutor,
                                                                ComponentSelectorConverter componentSelectorConverter,
                                                                ImmutableAttributesFactory attributesFactory,
                                                                VersionSelectorScheme versionSelectorScheme,
                                                                VersionParser versionParser,
                                                                ComponentMetadataSupplierRuleExecutor componentMetadataSupplierRuleExecutor) {
        return new DefaultArtifactDependencyResolver(
            buildOperationExecutor,
            resolverFactories,
            projectDependencyResolver,
            resolveIvyFactory,
            dependencyDescriptorFactory,
            versionComparator,
            moduleExclusions,
            componentSelectorConverter,
            attributesFactory,
            versionSelectorScheme,
            versionParser,
            componentMetadataSupplierRuleExecutor);
    }

    ProjectPublicationRegistry createProjectPublicationRegistry() {
        return new DefaultProjectPublicationRegistry();
    }

    LocalComponentProvider createProjectComponentProvider(ProjectStateRegistry projectStateRegistry, ProjectRegistry<ProjectInternal> projectRegistry, LocalComponentMetadataBuilder metaDataBuilder, ImmutableModuleIdentifierFactory moduleIdentifierFactory, BuildState currentBuild) {
        return new DefaultProjectLocalComponentProvider(projectStateRegistry, projectRegistry, metaDataBuilder, moduleIdentifierFactory, currentBuild.getBuildIdentifier());
    }

    LocalComponentRegistry createLocalComponentRegistry(List<LocalComponentProvider> providers) {
        return new DefaultLocalComponentRegistry(providers);
    }

    ProjectDependencyResolver createProjectDependencyResolver(LocalComponentRegistry localComponentRegistry, ComponentIdentifierFactory componentIdentifierFactory, ProjectStateRegistry projectStateRegistry) {
        return new ProjectDependencyResolver(localComponentRegistry, componentIdentifierFactory, projectStateRegistry);
    }

    ComponentSelectorConverter createModuleVersionSelectorFactory(ImmutableModuleIdentifierFactory moduleIdentifierFactory, ComponentIdentifierFactory componentIdentifierFactory, LocalComponentRegistry localComponentRegistry) {
        return new DefaultComponentSelectorConverter(componentIdentifierFactory, localComponentRegistry);
    }

    VersionParser createVersionParser() {
        return new VersionParser();
    }

    VersionSelectorScheme createVersionSelectorScheme(VersionComparator versionComparator, VersionParser versionParser) {
        return new CachingVersionSelectorScheme(new DefaultVersionSelectorScheme(versionComparator, versionParser));
    }

    SimpleMapInterner createStringInterner() {
        return SimpleMapInterner.threadSafe();
    }

    ModuleComponentResolveMetadataSerializer createModuleComponentResolveMetadataSerializer(ImmutableAttributesFactory attributesFactory, MavenMutableModuleMetadataFactory mavenMetadataFactory, IvyMutableModuleMetadataFactory ivyMetadataFactory, ImmutableModuleIdentifierFactory moduleIdentifierFactory, NamedObjectInstantiator instantiator) {
        DesugaringAttributeContainerSerializer attributeContainerSerializer = new DesugaringAttributeContainerSerializer(attributesFactory, instantiator);
        return new ModuleComponentResolveMetadataSerializer(new ModuleMetadataSerializer(attributeContainerSerializer, mavenMetadataFactory, ivyMetadataFactory), attributeContainerSerializer, moduleIdentifierFactory);
    }

    SuppliedComponentMetadataSerializer createSuppliedComponentMetadataSerializer(ImmutableModuleIdentifierFactory moduleIdentifierFactory, AttributeContainerSerializer attributeContainerSerializer) {
        ModuleVersionIdentifierSerializer moduleVersionIdentifierSerializer = new ModuleVersionIdentifierSerializer(moduleIdentifierFactory);
        return new SuppliedComponentMetadataSerializer(moduleVersionIdentifierSerializer, attributeContainerSerializer);
    }

    ComponentMetadataRuleExecutor createComponentMetadataRuleExecutor(ValueSnapshotter valueSnapshotter,
                                                                      CacheRepository cacheRepository,
                                                                      InMemoryCacheDecoratorFactory cacheDecoratorFactory,
                                                                      BuildCommencedTimeProvider timeProvider,
                                                                      ModuleComponentResolveMetadataSerializer serializer,
                                                                      FeaturePreviews featurePreviews) {
        return new ComponentMetadataRuleExecutor(cacheRepository, cacheDecoratorFactory, valueSnapshotter, timeProvider, serializer);
    }

    ComponentMetadataSupplierRuleExecutor createComponentMetadataSupplierRuleExecutor(ValueSnapshotter snapshotter,
                                                                                      CacheRepository cacheRepository,
                                                                                      InMemoryCacheDecoratorFactory cacheDecoratorFactory,
                                                                                      final BuildCommencedTimeProvider timeProvider,
                                                                                      SuppliedComponentMetadataSerializer suppliedComponentMetadataSerializer) {
        return new ComponentMetadataSupplierRuleExecutor(cacheRepository, cacheDecoratorFactory, snapshotter, timeProvider, suppliedComponentMetadataSerializer);
    }
}

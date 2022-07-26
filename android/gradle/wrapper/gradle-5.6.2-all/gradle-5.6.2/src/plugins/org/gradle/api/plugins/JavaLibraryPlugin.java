/*
 * Copyright 2016 the original author or authors.
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
package org.gradle.api.plugins;

import org.gradle.api.Plugin;
import org.gradle.api.Project;
import org.gradle.api.artifacts.ConfigurationContainer;
import org.gradle.api.attributes.Usage;
import org.gradle.api.tasks.SourceSet;
import org.gradle.api.tasks.SourceSetContainer;

import static org.gradle.api.plugins.internal.JvmPluginsHelper.addApiToSourceSet;
import static org.gradle.api.plugins.internal.JvmPluginsHelper.configureClassesDirectoryVariant;

/**
 * <p>A {@link Plugin} which extends the capabilities of the {@link JavaPlugin Java plugin} by cleanly separating
 * the API and implementation dependencies of a library.</p>
 *
 * @since 3.4
 */
public class JavaLibraryPlugin implements Plugin<Project> {

    @Override
    public void apply(Project project) {
        project.getPluginManager().apply(JavaPlugin.class);

        SourceSetContainer sourceSets = project.getExtensions().getByType(SourceSetContainer.class);
        ConfigurationContainer configurations = project.getConfigurations();
        SourceSet sourceSet = sourceSets.getByName("main");
        addApiToSourceSet(sourceSet, configurations);
        configureClassesDirectoryVariant(sourceSet, project, sourceSet.getApiElementsConfigurationName(), Usage.JAVA_API);
    }

}

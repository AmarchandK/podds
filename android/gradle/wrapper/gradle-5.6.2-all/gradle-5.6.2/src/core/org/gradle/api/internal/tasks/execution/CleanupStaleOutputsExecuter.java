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

package org.gradle.api.internal.tasks.execution;

import org.gradle.api.file.FileCollection;
import org.gradle.api.internal.TaskInternal;
import org.gradle.api.internal.tasks.TaskExecuter;
import org.gradle.api.internal.tasks.TaskExecuterResult;
import org.gradle.api.internal.tasks.TaskExecutionContext;
import org.gradle.api.internal.tasks.TaskStateInternal;
import org.gradle.api.internal.tasks.properties.FilePropertySpec;
import org.gradle.api.internal.tasks.properties.TaskProperties;
import org.gradle.internal.cleanup.BuildOutputCleanupRegistry;
import org.gradle.internal.execution.OutputChangeListener;
import org.gradle.internal.execution.history.OutputFilesRepository;
import org.gradle.internal.operations.BuildOperationContext;
import org.gradle.internal.operations.BuildOperationDescriptor;
import org.gradle.internal.operations.BuildOperationExecutor;
import org.gradle.internal.operations.RunnableBuildOperation;
import org.gradle.util.GFileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.HashSet;
import java.util.Set;

public class CleanupStaleOutputsExecuter implements TaskExecuter {

    public static final String CLEAN_STALE_OUTPUTS_DISPLAY_NAME = "Clean stale outputs";

    private final Logger logger = LoggerFactory.getLogger(CleanupStaleOutputsExecuter.class);
    private final BuildOperationExecutor buildOperationExecutor;
    private final OutputChangeListener outputChangeListener;
    private final TaskExecuter executer;
    private final OutputFilesRepository outputFilesRepository;
    private final BuildOutputCleanupRegistry cleanupRegistry;

    public CleanupStaleOutputsExecuter(BuildOutputCleanupRegistry cleanupRegistry, OutputFilesRepository outputFilesRepository, BuildOperationExecutor buildOperationExecutor, OutputChangeListener outputChangeListener, TaskExecuter executer) {
        this.cleanupRegistry = cleanupRegistry;
        this.buildOperationExecutor = buildOperationExecutor;
        this.outputChangeListener = outputChangeListener;
        this.executer = executer;
        this.outputFilesRepository = outputFilesRepository;
    }

    @Override
    public TaskExecuterResult execute(final TaskInternal task, TaskStateInternal state, TaskExecutionContext context) {
        final Set<File> filesToDelete = new HashSet<File>();
        TaskProperties properties = context.getTaskProperties();
        for (FilePropertySpec outputFileSpec : properties.getOutputFileProperties()) {
            FileCollection files = outputFileSpec.getPropertyFiles();
            for (File file : files) {
                if (cleanupRegistry.isOutputOwnedByBuild(file) && !outputFilesRepository.isGeneratedByGradle(file) && file.exists()) {
                    filesToDelete.add(file);
                }
            }
        }
        if (!filesToDelete.isEmpty()) {
            outputChangeListener.beforeOutputChange();
            buildOperationExecutor.run(new RunnableBuildOperation() {
                @Override
                public void run(BuildOperationContext context) {
                    for (File file : filesToDelete) {
                        if (file.exists()) {
                            logger.info("Deleting stale output file: {}", file.getAbsolutePath());
                            GFileUtils.forceDelete(file);
                        }
                    }
                }

                @Override
                public BuildOperationDescriptor.Builder description() {
                    return BuildOperationDescriptor
                        .displayName(CLEAN_STALE_OUTPUTS_DISPLAY_NAME)
                        .progressDisplayName("Cleaning stale outputs");
                }
            });
        }
        return executer.execute(task, state, context);
    }

}

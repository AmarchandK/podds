/*
 * Copyright 2018 the original author or authors.
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

package org.gradle.api.internal.tasks.compile.incremental.recomp;

import org.gradle.api.tasks.incremental.InputFileDetails;

import java.io.File;
import java.util.Collection;

class ResourceChangeProcessor {
    private final Collection<File> processorPath;

    ResourceChangeProcessor(Collection<File> processorPath) {
        this.processorPath = processorPath;
    }

    public void processChange(InputFileDetails input, RecompilationSpec spec) {
        if (processorPath.isEmpty()) {
            return;
        }
        if (input.isRemoved()) {
            spec.setFullRebuildCause(input.getFile().getName() + " has been removed", null);
        }
        if (!input.getFile().isDirectory()) {
            spec.setFullRebuildCause(input.getFile().getName() + " has been changed", null);
        }
    }
}

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

package org.gradle.performance.results

import groovy.transform.CompileStatic
import groovy.transform.TypeChecked
import groovy.transform.TypeCheckingMode
import org.gradle.ci.common.model.FlakyTest
import org.gradle.ci.github.GitHubIssuesClient
import org.gradle.ci.tagging.flaky.KnownFlakyTestProvider
import org.gradle.performance.results.ScenarioBuildResultData.ExecutionData
import org.kohsuke.github.GHIssue
import org.kohsuke.github.GHIssueState

import static org.apache.commons.lang3.StringUtils.isNoneBlank
import static org.gradle.ci.github.GitHubIssuesClient.CI_TRACKED_FLAKINESS_LABEL
import static org.gradle.ci.github.GitHubIssuesClient.FROM_BOT_PREFIX
import static org.gradle.ci.github.GitHubIssuesClient.MESSAGE_PREFIX
import static org.gradle.ci.github.GitHubIssuesClient.TEST_NAME_PREFIX

@CompileStatic
class DefaultPerformanceFlakinessAnalyzer implements PerformanceFlakinessAnalyzer {
    static final String BRANCH_PROPERTY_NAME = "org.gradle.performance.execution.branch";
    static final String GITHUB_FIX_IT_LABEL = "fix-it"
    static final String GITHUB_IN_PERFORMANCE_LABEL = "in:performance"
    private final GitHubIssuesClient gitHubIssuesClient
    private final KnownFlakyTestProvider provider
    private List<FlakyTest> knownInvalidFailures

    DefaultPerformanceFlakinessAnalyzer(GitHubIssuesClient gitHubIssuesClient, KnownFlakyTestProvider provider) {
        this.gitHubIssuesClient = gitHubIssuesClient
        this.provider = provider
    }

    void report(ScenarioBuildResultData flakyScenario) {
        FlakyTest knownFlakyTest = findKnownFlakyTest(flakyScenario)
        if (knownFlakyTest) {
            if (issueClosed(knownFlakyTest)) {
                knownFlakyTest.issue.reopen()
            }
            if (!hasFixItLabel(knownFlakyTest)) {
                knownFlakyTest.issue.addLabels(GITHUB_FIX_IT_LABEL)
            }
        } else {
            knownFlakyTest = openNewFlakyTestIssue(flakyScenario)
        }

        commentCurrentFailureToIssue(flakyScenario, knownFlakyTest.issue)
    }

    FlakyTest findKnownFlakyTest(ScenarioBuildResultData scenario) {
        return getKnownInvalidFailures().find { isNoneBlank(it.name) && scenario.flakyIssueTestName.contains(it.name) }
    }

    private List<FlakyTest> getKnownInvalidFailures() {
        if (knownInvalidFailures == null) {
            knownInvalidFailures = provider.knownInvalidFailures
        }
        return knownInvalidFailures
    }

    @TypeChecked(TypeCheckingMode.SKIP)
    static void commentCurrentFailureToIssue(ScenarioBuildResultData scenario, GHIssue issue) {
        issue.comment("""
${FROM_BOT_PREFIX}

Coordinator url: https://builds.gradle.org/viewLog.html?buildId=${System.getenv("BUILD_ID")}
Branch: ${System.getProperty(BRANCH_PROPERTY_NAME)}
Worker url: ${scenario.webUrl}
Agent: [${scenario.agentName}](${scenario.agentUrl})
Details:

| Iteration | Difference | Confidence |
|---|---|---|
${assembleTable(scenario)}
""")
    }

    private static String assembleTable(ScenarioBuildResultData scenario) {
        scenario.executions.withIndex().collect { ExecutionData execution, int index ->
            "|${index + 1}|${execution.differenceDisplay}|${execution.formattedConfidence}|"
        }.join('\n')
    }

    private FlakyTest openNewFlakyTestIssue(ScenarioBuildResultData flakyScenario) {
        String title = "Flaky performance test: ${flakyScenario.flakyIssueTestName}"
        String message = "we're slower than"
        String body = """
${FROM_BOT_PREFIX}

${TEST_NAME_PREFIX}${flakyScenario.flakyIssueTestName}

${MESSAGE_PREFIX}$message
"""

        GHIssue issue = gitHubIssuesClient.createBuildToolInvalidFailureIssue(title, body, [CI_TRACKED_FLAKINESS_LABEL, GITHUB_IN_PERFORMANCE_LABEL])
        return new FlakyTest(issue: issue)
    }


    private static boolean issueClosed(FlakyTest flakyTest) {
        return flakyTest.issue.state == GHIssueState.CLOSED
    }

    private static boolean hasFixItLabel(FlakyTest flakyTest) {
        return flakyTest.issue.getLabels().collect { it.name }.contains(GITHUB_FIX_IT_LABEL)
    }
}

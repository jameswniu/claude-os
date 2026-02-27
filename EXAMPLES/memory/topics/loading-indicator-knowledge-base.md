# Loading Indicator Knowledge Base

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1443201091

## Strategic Guide for AI Tooling Development

* * *

## Table of Contents

  1. [Executive Summary & Strategic Vision](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#1-executive-summary--strategic-vision)

  2. [Pattern Inventory Matrix](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#2-pattern-inventory-matrix)

  3. [UI Pattern Gallery](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#3-ui-pattern-gallery)

  4. [Scenario-Based Test Cases](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#4-scenario-based-test-cases)

  5. [Tool Development Requirements](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#5-tool-development-requirements)

  6. [Decision Framework](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#6-decision-framework)

  7. [Anti-Patterns & Gotchas](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#7-anti-patterns--gotchas)

  8. [Migration Playbook](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#8-migration-playbook)

  9. [Current State Analysis](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#9-current-state-analysis)

  10. [Tool Validation Matrix](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#10-tool-validation-matrix)

  11. [Appendix: Complete Pattern Reference](https://claude.ai/chat/f8c6b0ae-fe54-400e-af89-60fba5286a73#11-appendix-complete-pattern-reference)

* * *

## 1. Executive Summary & Strategic Vision

### 1.1 Problem Statement

**Why we need standardized loading/error patterns:**

[Describe the current problems]

### 1.2 Current State

**Existing patterns in the codebase:**

  * **State Management Approaches:** 5 different approaches

    * React Query: ~45 instances

    * Transis: ~60 instances

    * Manual useState: ~30 instances

    * [Add details...]

  * **UI Display Approaches:** 6 different components/patterns

    * CircularLoader: ~70 instances

    * SkeletonLoader: ~25 instances

    * [Add details...]

**Key Issues:**

  * [Issue 1]

  * [Issue 2]

### 1.3 Target State

**Our preferred patterns for new development:**

**Loading Indicators:**

  * ✅ **PREFERRED:** React Query for all data fetching

  * 🔶 **ACCEPTABLE:** useState for pure UI state only

  * ⚠️ **AVOID:** Manual loading state for API calls

  * 🔴 **NEVER:** New Transis models

**Error Handling:**

  * ✅ **PREFERRED:** [Fill in]

  * 🔶 **ACCEPTABLE:** [Fill in]

  * ⚠️ **AVOID:** [Fill in]

  * 🔴 **NEVER:** [Fill in]

### 1.4 Success Criteria

**What "good" AI-generated code looks like:**

  * [ ] Uses preferred state management patterns

  * [ ] Includes appropriate loading indicators for context

  * [ ] Has error boundaries for critical sections

  * [ ] Includes accessibility features

  * [ ] [Add more...]

### 1.5 Tool Requirements

**What our AI tooling needs to handle:**

**Must Have:**

  * [ ] Pattern recognition (identify existing patterns)

  * [ ] Pattern generation (create new code with preferred patterns)

  * [ ] Pattern validation (verify code follows standards)

  * [ ] Anti-pattern detection (flag problematic code)

**Nice to Have:**

  * [ ] Automated migration (refactor legacy -> modern)

  * [ ] Contextual suggestions

  * [ ] [Add more...]

* * *

## 2. Pattern Inventory Matrix

## Loading UI State Management Approaches

### 1. Model `.isBusy` Property (Transis.js)

  * `components/ui/app/assets/javascripts/ui/models/organization.js:351-360`

  * `components/ui/app/assets/javascripts/ui/models/dsp/dsp_first_party_audience.js:214-222`

  * `components/ui/app/assets/javascripts/ui/models/dsp/dsp_tactic_creative_set.js:66-72`

  * `components/ui/app/assets/javascripts/ui/components/OrganizationManagement/OrganizationManagement.jsx:36`

  * `components/ui/app/assets/javascripts/ui/components/Dsp/Assets/Creatives/CreativeEdit.jsx:306`

  * `components/ui/app/assets/javascripts/ui/components/Direct/PlanningGrid/ProposalHeaderRow.jsx:240`

### 2. React Query/TanStack Query States

  * `components/ui/app/assets/javascripts/ui/components/Reports/Dashboard/DashboardPage.jsx:70-78`

  * `components/ui/app/assets/javascripts/ui/SearchTools/BuildManager/AllBuilds/BuildList.jsx:56-87`

  * `components/ui/app/assets/javascripts/ui/CreativeLibrary/creatives/CreativesBrands.jsx:134-148`

### 3. Component `useState` Hook  

  * `components/ui/app/assets/javascripts/ui/StrategyGenerator/UploadBrief/UploadBrief.jsx:26`

  * `components/ui/app/assets/javascripts/ui/components/Accounting/ManageDatasets/ConfigureDatasetFlow/ConfigureDatasetForm/ConfigureDatasetForm.jsx:27`

### 4. Custom `useApi` Hook (react-async)

  * `components/ui/app/assets/javascripts/ui/components/Settings/ThirdPartyApps.jsx:20-55`

  * `components/ui/app/assets/javascripts/ui/components/Settings/APIAppCredentials.jsx:61-64`

  * `components/ui/app/assets/javascripts/ui/components/Settings/MediaAuthOrganizationTerms.jsx:32`

### 5. Props-based Loading State  

  * `components/ui/app/assets/javascripts/ui/components/Accounting/ManageDatasets/ConfigureDatasetFlow/ConfigureDatasetForm/ConfigureDatasetForm.jsx:22`

  * `components/ui/CreativeLibrary/creatives/CreativesTableTopBar.jsx:42-89`

  * `components/ui/task-management/src/TaskManagement/TaskDetails.jsx:7-12`

## Loading UI Display Approaches

### 1. Loader Component (CircularLoader)  

  * `components/ui/app/assets/javascripts/ui/components/Dsp/Assets/Creatives/CreativeEdit.jsx:306`

  * `components/ui/app/assets/javascripts/ui/components/Reports/Dashboard/DashboardPage.jsx:202-203`

  * `components/ui/basis-ui/components/Grid/Grid.jsx:356-359`

### 2. SkeletonLoader Component  

  * `components/ui/task-management/src/TaskManagement/TaskDetails.jsx:12-13`

  * `components/ui/app/assets/javascripts/ui/SearchTools/BuildManager/PreviousExports/ExportHistory.jsx:39`

  * `components/ui/app/assets/javascripts/ui/SearchTools/BuildManager/AllBuilds/VersionPanel.jsx:22`

### 3. InlineLoader Component (Ellipsis Animation)  

  * `components/ui/app/assets/javascripts/ui/StrategyGenerator/UploadBrief/UploadBrief.jsx:147-161`

  * `components/ui/app/assets/javascripts/ui/components/GlobalCards/DealsTable.jsx:51`

  * `components/ui/app/assets/javascripts/ui/components/Dsp/TacticEditor/DetailsTab/DspComponents/BidMultiplier.jsx:96`

### 4. Conditional Text Changes  

  * `components/ui/app/assets/javascripts/ui/components/Direct/PlanningGrid/ProposalHeaderRow.jsx:519`

  * `components/ui/app/assets/javascripts/ui/components/Direct/PlanningGrid/Dsp/DspHeaderPrimaryRow.jsx:260`

  * `components/ui/app/assets/javascripts/ui/components/Direct/PlanningGrid/ProposalHeaderRow.jsx:240`

  * `components/ui/app/assets/javascripts/ui/components/GlobalSearch/GlobalSearchDealResults.jsx:284`

  * `components/ui/CreativeLibrary/creatives/CreativesTableTopBar.jsx:89`

### 5. Disabled Buttons  

  * `components/ui/app/assets/javascripts/ui/StrategyGenerator/UploadBrief/UploadBrief.jsx:143`

  * `components/ui/task-management/src/TaskManagement/TaskDetailPanel.jsx:218`

  * `components/ui/app/assets/javascripts/ui/components/Reports/common/ActionModals/Download/DownloadDashboardModal.jsx:150`

  * `components/ui/app/assets/javascripts/ui/SearchTools/BuildManager/EditBuild/ToggleDiscrepancies.jsx:38`

## 6. Grid Loading Rows  

  * `components/ui/task-management/src/TaskManagement/Tasks.jsx:186-196`

  * `components/ui/app/assets/javascripts/ui/SearchTools/BuildManager/AllBuilds/BuildList.jsx:86-87`

Use Case| State Management| UI Display| Status| Files/Examples| Migration Priority  
---|---|---|---|---|---  
Initial page load| React Query `isLoading`| SkeletonLoader| ✅ PREFERRED| `TaskDetails.jsx`| N/A - Keep  
Initial page load| Transis `.isBusy`| CircularLoader| 🔶 LEGACY ONLY| `OrganizationManagement.jsx`| HIGH - 60 instances  
Form submission| `useMutation` \+ `useState`| Disabled + InlineLoader| ✅ PREFERRED| `UploadBrief.jsx`| N/A - Keep  
[Add rows...]| | | | |   
  
**Summary:**

  * Total patterns identified: [NUMBER]

  * Preferred patterns: [NUMBER] ([PERCENT]%)

  * Migration effort estimate: [HIGH/MEDIUM/LOW]

### 2.2 Error Handling Patterns

Error Type| State Management| UI Display| Status| Files/Examples| Migration Priority  
---|---|---|---|---|---  
Critical runtime error| ErrorBoundary| Full fallback UI| ✅ PREFERRED| `TaskManagement.jsx`| N/A - Keep  
Form validation error| React Hook Form| Inline error message| ✅ PREFERRED| `ClientFormField.jsx`| N/A - Keep  
[Add rows...]| | | | |   
  
**Summary:**

  * Total patterns identified: [NUMBER]

  * Critical gaps: [NUMBER]

* * *

## 3. UI Pattern Gallery

### 3.1 [Pattern Name - e.g., CircularLoader]

wide760

### 3.2 [Next Pattern]

[Copy template above...]

* * *

## 4. Scenario-Based Test Cases

### 4.1 Test Case: [Scenario Name - e.g., "Build a User List Page"]

wide760

### 4.2 Test Case: [Next Scenario]

[Copy template above...]

* * *

## 5. Tool Development Requirements

### 5.1 Pattern Recognition Capabilities

**The tool must be able to identify:**

  * [ ] Transis `.isBusy` patterns

    * Detection: Look for `model.isBusy = true/false`

    * Files: [List common file patterns]

    * Confidence level needed: [High/Medium/Low]

  * [ ] React Query patterns

    * Detection: Look for `useQuery`, `useMutation`

    * [Add details...]

  * [ ] [Add more patterns...]

### 5.2 Pattern Generation Capabilities

**The tool must be able to generate: </**

  * [ ] React Query implementations

    * Template: [Link to code template]

    * Variants: [List different contexts - page load, mutation, etc.]

  * [ ] Loading UI components

    * CircularLoader: [When to use]

    * SkeletonLoader: [When to use]

    * InlineLoader: [When to use]

  * [ ] [Add more...]

### 5.3 Pattern Migration Capabilities

**The tool must be able to refactor:**

  * [ ] Transis -> React Query

    * Detection regex: [Add pattern]

    * Replacement template: [Add template]

    * Test strategy: [How to verify]

  * [ ] [Add more migrations...]

### 5.4 Pattern Validation Capabilities

**The tool must verify:**

  * [ ] No anti-patterns present (see section 7)

  * [ ] Accessibility requirements met

  * [ ] Proper error boundary usage

  * [ ] [Add more checks...]

* * *

## 6. Decision Framework

### 6.1 Loading State Decision Tree

wide760

### 6.2 Error Handling Decision Tree

wide760

### 6.3 Migration Decision Tree

wide760

* * *

## 7. Anti-Patterns & Gotchas

### 7.1 Anti-Pattern: [Name - e.g., "Manual Loading State for API Calls"]

wide760

### 7.2 Anti-Pattern: [Next Anti-Pattern]

[Copy template above...]

* * *

## 8. Migration Playbook

### 8.1 Migration: [Name - e.g., "Transis .isBusy -> React Query"]

wide760

### 8.2 Migration: [Next Migration Type]

[Copy template above...]

* * *

## 9. Current State Analysis

### 9.1 Loading Patterns - Statistics

wide760

### 9.2 Error Patterns - Statistics

wide760

### 9.3 Gap Analysis

**Critical Gaps:**

  1. **Missing Error Boundaries**

     * Current: 15 components with ErrorBoundary

     * Needed: ~40+ critical sections identified

     * Priority: CRITICAL

     * Effort: [Estimate]

  2. **[Next Gap]**

     * [Details...]

* * *

## 10. Tool Validation Matrix

### 10.1 How to Test AI Tools

Test Type| Scenario| Pass Criteria| Validation Method  
---|---|---|---  
**Generation**|  "Create user list page"| Uses React Query + SkeletonLoader + ErrorBoundary| Run tool -> inspect output -> compare to TC-001  
**Migration**|  Refactor Transis -> React Query| Removes .isBusy, adds useQuery, tests pass| Run on sample file -> verify tests  
**Recognition**|  Identify anti-patterns| Flags manual useState + fetch| Run on codebase -> check finds known issues  
**Validation**|  Check PR for standards| Rejects CircularLoader on tables| Run on PR diff -> verify catches issues  
[Add more...]| | |   
  
### 10.2 Test Files Repository

**Location of test files for validation:**

  * `/tests/ai-tooling/loading-patterns/`

  * `/tests/ai-tooling/error-patterns/`

**Test files should include:**

  * [ ] Good examples (follow standards)

  * [ ] Bad examples (violate standards)

  * [ ] Edge cases

  * [ ] Real-world examples from codebase

* * *

## 11. Appendix: Complete Pattern Reference

### 11.1 Loading State Management

#### React Query (TanStack Query)

**Status:** ✅ PREFERRED for all new data fetching

**Properties:**

  * `isLoading` \- Initial load (no data yet)

  * `isFetching` \- Any fetch (including refetch)

  * `isPending` \- Used in mutations

  * `error` \- Error object if failed

  * `isError` \- Boolean error flag

**Usage:**

wide760

**When to use:**

  * All new API data fetching

  * All CRUD operations

  * Anywhere you need caching/refetching

**Files:** [List key examples]

* * *

#### [Next Pattern]

[Copy template above for each pattern...]

### 11.2 Loading UI Components

#### [Component Name]

[Add details...]

### 11.3 Error State Management

#### [Pattern Name]

[Add details...]

### 11.4 Error UI Components

#### [Component Name]

[Add details...]

* * *

## Change Log

Date| Version| Changes| Author  
---|---|---|---  
[DATE]| 1.0| Initial template created| [NAME]  
| | |   
  
* * *

## Notes & Open Questions

**Open Questions:**

  * [ ] [Question 1]

  * [ ] [Question 2]

**Future Considerations:**

  * [ ] [Item 1]

  * [ ] [Item 2]



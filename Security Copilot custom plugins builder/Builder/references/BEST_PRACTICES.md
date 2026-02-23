# Best Practices & Validation Checklists

> Naming conventions, validation checklists, common mistakes, and security guidelines for Security Copilot plugins and agents.

---

## Naming

- `Name`: use PascalCase, no spaces. E.g.: `DefenderDailyOperations`
- `DisplayName`: use a readable and descriptive name. E.g.: `Defender Daily Operations`
- `operationId` (API): use PascalCase, descriptive of the action. E.g.: `GetAlertIdsFromIncidentId`

## Description and DescriptionForModel

- `Description` is shown in the UI and used for selection (if `DescriptionForModel` is not set)
- `DescriptionForModel` is used ONLY for skill selection by the AI model
- Descriptions should be verbose and understandable by someone with reasonable domain knowledge
- Include **what** the skill does and **why** someone would want to use it
- Good example: _"Gets reputation information for an IP address. Enables users to determine if an IP address is risky."_

## Avoiding Skill Collisions

- Don't create multiple skills that return the same type of response and only differ by inputs
- Prefer a single skill with multiple inputs: `GetDevices` with inputs `deviceId`, `userId`, `userName` instead of 3 separate skills
- Use optional inputs where possible

## KQL and GPT Templates

- Use `|-` for multi-line templates (YAML block scalar)
- Parameters are referenced with `{{parameterName}}`
- For production, prefer `TemplateUrl` or `PackageUrl` over inline `Template`

## OpenAPI Spec

- Supported version: only **OpenAPI 3.0** or **3.0.1**
- Always include a unique `operationId` for each endpoint
- Include detailed `description` for operations and parameters
- Use `ExamplePrompt` to guide the model in correct invocation
- Always define response schema where possible

## Security

- **NEVER** include real credentials in YAML files
- Use placeholders like `<YOUR-TENANT-ID>`, `<YOUR-SUBSCRIPTION-ID>`
- For Basic auth, only use with HTTPS endpoints
- For API keys, prefer `Location: Header` over `QueryParams`

## Writable Plugins

- Writable plugins are plugins that perform write actions in your environment
- No writable plugins are built-in; they must be created as custom
- Methods to create writable plugins: Broker architecture, OAuth authentication, Logic App plugin
- Use cases: send emails, submit incident reports, governance actions on users/devices/applications

---

## KQL Query Validation

> **MANDATORY STEP**: Before finalizing any KQL plugin, the agent **MUST** validate every KQL query for both syntactic and semantic correctness. A plugin with an invalid query will fail at runtime in Security Copilot.

### Step 0: Live Schema Verification (MANDATORY — DO THIS FIRST)

> **Before running the syntactic and semantic checklists below**, the agent **MUST** have already executed the live schema discovery tools described in KQL_PLUGINS.md. Specifically:

- [ ] **For Defender targets**: Called `FetchAdvancedHuntingTablesOverview` to verify table existence, then called `FetchAdvancedHuntingTablesDetailedSchema` for each table used in the query to verify column names and types
- [ ] **For Sentinel / LogAnalytics targets**: Called `search_tables` with relevant natural language queries to discover table schemas and verify column names
- [ ] **Cross-referenced every table name** in the KQL query against the tool results — if a table is not returned by the tools, it does NOT exist and must not be used
- [ ] **Cross-referenced every column name** (in `project`, `where`, `summarize`, `extend`, `join on`, `sort by`, `top ... by`) against the detailed schema — if a column is not in the schema, it does NOT exist and must not be used
- [ ] **Verified column data types** — e.g., do not compare a `datetime` column with a string without `todatetime()`, do not use `==` on a `dynamic` column without `todynamic()`

> If the live schema tools are not available (e.g., no MCP connection), fall back to the static table/column reference lists below and clearly warn the user that the query has NOT been validated against the live environment.

### Syntactic Validation Checklist

Verify that each KQL query follows correct KQL syntax:

- [ ] **Pipe operator**: every statement after the table name uses `|` to chain operators
- [ ] **String literals**: strings are enclosed in single quotes `'...'` or double quotes `"..."` (not backticks)
- [ ] **Timespan literals**: durations use valid KQL format (`ago(7d)`, `ago(8h)`, `ago(30m)`, `ago(1d)`) — the unit must be one of: `d` (days), `h` (hours), `m` (minutes), `s` (seconds), `ms` (milliseconds), `tick` (ticks)
- [ ] **Operator spelling**: all KQL operators are spelled correctly (e.g., `summarize` not `sumarize`, `project` not `select`, `extend` not `add_column`)
- [ ] **Function parentheses**: all functions have matching opening and closing parentheses (e.g., `count()`, `make_set(Column)`, `ago(7d)`)
- [ ] **let statements**: `let` variable declarations end with a semicolon `;` and the variable name does not conflict with KQL reserved keywords
- [ ] **Comma separation**: column lists in `project`, `summarize`, `extend`, etc. use commas between columns
- [ ] **No trailing pipes**: the query does not end with a dangling `|` on the last line
- [ ] **Parameter placeholders**: input parameters use `{{parameterName}}` (double curly braces), and every `{{parameterName}}` corresponds to an entry in the skill's `Inputs` array
- [ ] **String interpolation with parameters**: parameters inside string contexts are properly quoted (e.g., `"{{deviceName}}"` or `'{{fromDateTime}}'`)
- [ ] **join syntax**: `join` uses the correct syntax: `join kind=<jointype> (SubQuery) on <column>` — valid join types: `inner`, `leftouter`, `rightouter`, `fullouter`, `leftanti`, `rightanti`, `leftsemi`, `rightsemi`
- [ ] **Balanced brackets**: all `(`, `[`, `{` have matching closing brackets

### Semantic Validation Checklist

Verify that each KQL query is logically correct and will return meaningful results:

- [ ] **Table existence**: the table name exists in the target environment. Common tables per target:
  - **Defender**: `DeviceInfo`, `DeviceEvents`, `DeviceProcessEvents`, `DeviceNetworkEvents`, `DeviceFileEvents`, `DeviceRegistryEvents`, `DeviceLogonEvents`, `DeviceImageLoadEvents`, `AlertInfo`, `AlertEvidence`, `EmailEvents`, `EmailAttachmentInfo`, `EmailUrlInfo`, `IdentityLogonEvents`, `IdentityQueryEvents`, `IdentityDirectoryEvents`, `AADSignInEventsBeta`, `CloudAppEvents`, `UrlClickEvents`, `BehaviorInfo`, `BehaviorEntities`
  - **Sentinel**: `SecurityAlert`, `SecurityIncident`, `SigninLogs`, `AADNonInteractiveUserSignInLogs`, `AuditLogs`, `Heartbeat`, `Syslog`, `CommonSecurityLog`, `Usage`, `AzureActivity`, `ThreatIntelligenceIndicator`, `OfficeActivity`, `DeviceEvents` (if M365D connector is enabled)
  - **LogAnalytics**: depends on the workspace data sources (verify with the user)
  - **Kusto/ADX**: depends on the database schema (verify with the user)
- [ ] **Column existence**: all projected, filtered, or summarized columns exist in the referenced table. Common column names per key table:
  - `DeviceInfo`: `DeviceName`, `DeviceId`, `DeviceCategory`, `OSPlatform`, `OSVersionInfo`, `OnboardingStatus`, `SensorHealthState`, `ExposureLevel`, `LoggedOnUsers`, `Timestamp`, `JoinType`
  - `AlertInfo`: `AlertId`, `Title`, `Severity`, `Category`, `AttackTechniques`, `Timestamp`, `ServiceSource`, `DetectionSource`
  - `AlertEvidence`: `AlertId`, `EntityType`, `RemoteIP`, `AccountUpn`, `AccountName`, `AccountDomain`, `DeviceName`, `Timestamp`, `EvidenceRole`
  - `AADSignInEventsBeta`: `AccountUpn`, `AccountDisplayName`, `Timestamp`, `RiskLevelDuringSignIn`, `RiskLevelAggregated`, `RiskState`, `RiskDetail`, `RiskEventTypes`, `ErrorCode`, `Country`, `City`, `IPAddress`, `Application`, `SessionId`
  - `IdentityLogonEvents`: `AccountUpn`, `AccountDisplayName`, `ActionType`, `LogonType`, `DeviceName`, `DestinationDeviceName`, `IPAddress`, `Timestamp`
- [ ] **Aggregation consistency**: columns in `summarize ... by` must not overlap with aggregation functions; every non-aggregated column in the output must appear in the `by` clause
- [ ] **Time filter presence**: queries should include a time filter (`where Timestamp > ago(...)` or `where TimeGenerated > ago(...)`) to avoid scanning unlimited data. Use `Timestamp` for Defender tables and `TimeGenerated` for Sentinel/LogAnalytics tables
- [ ] **Parameter type correctness**: parameters are used in the right context — e.g., a string parameter compared with `==` or `=~` is quoted, a datetime parameter is wrapped in `todatetime('{{param}}')`, a numeric parameter is not quoted
- [ ] **Logical filter consistency**: `where` clauses are logically possible (e.g., don't filter `ExposureLevel == 'Critical'` when the valid values are `High`, `Medium`, `Low`, `None`)
- [ ] **join column match**: the `on` column in a `join` must exist in both the left and right tables
- [ ] **Result set size**: the query includes `take`, `top`, or `limit` to cap the result set (recommended max: 50 rows) to prevent excessive data transfer to Security Copilot
- [ ] **No destructive or management operations**: KQL queries in Security Copilot are read-only; do not use `.set`, `.append`, `.drop`, `.create`, or any management command (commands starting with `.`)

### Common KQL Mistakes to Avoid

| Mistake | Wrong | Correct |
|---------|-------|--------|
| Wrong time unit | `ago(7days)` | `ago(7d)` |
| Missing semicolon after let | `let x = 5` | `let x = 5;` |
| Using SQL syntax | `SELECT * FROM table` | `table` |
| Wrong string comparison | `where Name = "value"` | `where Name == "value"` or `where Name =~ "value"` |
| Unquoted parameter in string context | `where Name == {{param}}` | `where Name == "{{param}}"` |
| Using `contains` for exact match | `where Status contains "High"` | `where Status == "High"` |
| Wrong column name for time | `where TimeGenerated > ago(1d)` (Defender) | `where Timestamp > ago(1d)` (Defender) |
| Trailing pipe | `table \| where x == 1 \|` | `table \| where x == 1` |
| Aggregation without by clause | `summarize count(), Name` | `summarize count() by Name` |

---

## Output Validation Checklist

### General Checks

- [ ] The `Name` in Descriptor has no spaces or special characters `/\?#@`
- [ ] Each skill's `Name` has no spaces or dots
- [ ] `Description` is not empty
- [ ] Parameters in templates use `{{parameterName}}` syntax
- [ ] Multi-line templates use `|-` as YAML block scalar
- [ ] Placeholders for sensitive values use `<YOUR-...>` and not real values

### KQL-Specific Checks (MANDATORY for every KQL skill)

- [ ] Every KQL query passes the **Syntactic Validation Checklist**
- [ ] Every KQL query passes the **Semantic Validation Checklist**
- [ ] All table names exist in the specified Target (Defender / Sentinel / LogAnalytics / Kusto)
- [ ] All column names are valid for the referenced tables
- [ ] Time filters are present (`Timestamp` for Defender, `TimeGenerated` for Sentinel/LogAnalytics)
- [ ] Result set is capped with `take`, `top`, or `limit`
- [ ] `let` statements end with `;`
- [ ] `join` operations use valid join types and correct `on` columns
- [ ] Parameters in string context are properly quoted
- [ ] No management commands (`.set`, `.drop`, `.create`, etc.) are used
- [ ] For KQL Sentinel, `TenantId`, `SubscriptionId`, `ResourceGroupName`, `WorkspaceName` are present
- [ ] For KQL Kusto/ADX, `Cluster` and `Database` are present

### API-Specific Checks

- [ ] For API plugins, the OpenAPI spec uses version `3.0.0` or `3.0.1`
- [ ] For API plugins, each operation has a unique `operationId`
- [ ] For authenticated plugins, `SupportedAuthTypes` and `Authorization` are consistent

### LogicApp / MCP Checks

- [ ] For LogicApp, `SubscriptionId`, `ResourceGroup`, `WorkflowName`, `TriggerName` are present
- [ ] For MCP, `Endpoint` is present

### Agent-Specific Checks (MANDATORY for every Agent)

- [ ] `AgentDefinitions` is present with at least one entry
- [ ] `AgentDefinitions[].Name` has no whitespace and no dots
- [ ] `AgentDefinitions[].Publisher` and `AgentDefinitions[].Product` are set
- [ ] `RequiredSkillsets` includes the Descriptor `Name` of the current manifest and all external skillsets
- [ ] At least one `Trigger` is defined with `Name` and `ProcessSkill`
- [ ] `ProcessSkill` follows the format `SkillsetName.SkillName`
- [ ] If `FetchSkill` is used, it follows the format `SkillsetName.SkillName` and the skill exists
- [ ] The Agent skill in `SkillGroups` has `Format: Agent`
- [ ] The Agent skill has `Interfaces: [Agent]` or `Interfaces: [InteractiveAgent]`
- [ ] The Agent skill has `Instructions` in Settings
- [ ] The Agent skill has `ChildSkills` listing all skills it invokes
- [ ] Every skill in `ChildSkills` is either defined inline (in another SkillGroup of the same manifest) or available from a skillset in `RequiredSkillsets`
- [ ] **No GPT child skills for text tasks**: report generation, summarization, and analysis are handled directly in the agent's `Instructions` — not via a separate GPT skill. GPT child skills should only exist if they serve a reusable, standalone purpose outside the agent.
- [ ] For interactive agents: `PromptSkill` is set in `AgentDefinitions`, input is named `UserRequest`, `OrchestratorSkill: DefaultAgentOrchestrator` is set
- [ ] For interactive agents: `SuggestedPrompts` has at least one starter prompt with `IsStarterAgent: true`, `Title`, and `Personas`

---

## KQL Query Authoring Workflow (MANDATORY for KQL skills)

When generating a KQL skill, the agent **MUST** follow this workflow to produce valid queries:

```
1. GATHER REQUIREMENTS
   → Ask the user what data they need and which target (Defender, Sentinel, etc.)

2. DISCOVER TABLES (use live tools)
   → Defender: call FetchAdvancedHuntingTablesOverview(tableNames: [])
   → Sentinel:  call search_tables(query: "<natural language description>")

3. GET DETAILED SCHEMA (use live tools)
   → Defender: call FetchAdvancedHuntingTablesDetailedSchema(tableNames: ["Table1", "Table2"])
   → Sentinel:  use schema from search_tables results

4. WRITE KQL QUERY
   → Use ONLY table names and column names confirmed by the tools
   → Apply correct data types, time columns, and filters

5. VALIDATE QUERY
   → Run Syntactic Validation Checklist
   → Run Semantic Validation Checklist
   → Cross-reference ALL tables/columns against live schema from Step 3

6. GENERATE YAML
   → Produce the final plugin/agent YAML manifest
   → Run Output Validation Checklist
```

> **NEVER skip Steps 2-3.** Writing KQL queries from memory or static lists leads to runtime errors due to non-existent tables or misspelled column names.

---

## Official References

- [Create custom plugins](https://learn.microsoft.com/en-us/copilot/security/custom-plugins)
- [Agent Manifest](https://learn.microsoft.com/en-us/copilot/security/developer/agent-manifest)
- [Build Agents with Multiple Tools](https://learn.microsoft.com/en-us/copilot/security/developer/build-agent-multiple-tools)
- [Build Interactive Agents](https://learn.microsoft.com/en-us/copilot/security/developer/build-interactive-agents)
- [Build Agent API Sample](https://learn.microsoft.com/en-us/copilot/security/developer/build-agent-api-sample)
- [Create Agent Tools](https://learn.microsoft.com/en-us/copilot/security/developer/create-agent-tool)
- [Interactive Agents Chat](https://learn.microsoft.com/en-us/copilot/security/developer/interactive-agents-chat)
- [API Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-api)
- [KQL Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-kql)
- [GPT Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-gpt)
- [Non-Microsoft Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-other)
- [Manage Plugins](https://learn.microsoft.com/en-us/copilot/security/manage-plugins)
- [Plugin Error Codes](https://learn.microsoft.com/en-us/copilot/security/plugin-error-codes)
- [Security Copilot GitHub](https://github.com/Azure/Copilot-For-Security)

### Security Copilot Connector (Automations)
- [Security Copilot Connector](https://learn.microsoft.com/en-us/connectors/securitycopilot/)
- Available actions: **Submit a Security Copilot prompt** and **Run a Security Copilot promptbook**
- Submit prompt parameters: `Prompt Content`, `SessionId`, `Plugins Skillsets`, `Direct Skill`, `Direct Skill Inputs`

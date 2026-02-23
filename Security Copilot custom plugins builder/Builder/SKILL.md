---
name: security-copilot-plugin-builder
description: Generates custom plugins and agents for Microsoft Security Copilot. Produces correct, validated YAML manifests for KQL, API, GPT, LogicApp, MCP, and Agent skill formats — including multi-format plugins and interactive agents.
license: MIT
compatibility:
  - microsoft-security-copilot
metadata:
  version: "1.0"
  author: mariocuomo
  tags:
    - security-copilot
    - plugins
    - agents
    - kql
    - yaml
allowed-tools:
  - FetchAdvancedHuntingTablesOverview
  - FetchAdvancedHuntingTablesDetailedSchema
  - search_tables
  - search_for_tools
  - get_evaluation
---

# Security Copilot Custom Plugins & Agents Builder

> Build correct, production-ready YAML manifest files for Microsoft Security Copilot custom plugins and agents.

## What This Skill Does

This skill guides an AI agent through the **complete lifecycle** of generating Security Copilot custom plugins and agents:

1. Gather requirements from the user
2. Select the appropriate format(s) (KQL, API, GPT, LogicApp, MCP, Agent)
3. Discover and validate schemas (live tools when targeting KQL)
4. Generate the YAML manifest
5. Validate the output against checklists

## Supported Formats

| Format | Purpose | Files Needed |
|--------|---------|--------------|
| **KQL** | Kusto queries against Defender, Sentinel, ADX, Log Analytics | Manifest YAML only |
| **API** | REST API calls to external or Microsoft services | Manifest YAML + OpenAPI spec |
| **GPT** | Direct GPT model interaction (prompts, reports, analysis) | Manifest YAML only |
| **LogicApp** | Trigger Azure Logic Apps (emails, workflows, write ops) | Manifest YAML (+ ARM template) |
| **MCP** | Connect to MCP Servers and use their tools | Manifest YAML only |
| **Agent** | Orchestrate other skills (including other agents) via AI agent with Instructions | Manifest YAML (+ optional child plugin) |

> A single manifest can combine **multiple formats** in different SkillGroups. See [MIXED_FORMAT_PLUGINS.md](references/MIXED_FORMAT_PLUGINS.md) for examples.

## Core Concepts

### Plugin Structure
Every plugin has a **Descriptor** (identity + auth) and one or more **SkillGroups** (each with its own Format). See [YAML_FORMAT.md](references/YAML_FORMAT.md) for the complete manifest schema.

### Agent Structure
Agents add **AgentDefinitions** (triggers, required skillsets) and use `Format: Agent` skills with **Instructions** (natural language) and **ChildSkills**. ChildSkills can include KQL, API, GPT, MCP, LogicApp, already available skills, **and other Agent skills** — enabling agent-to-agent communication. See [AGENT_PLUGINS.md](references/AGENT_PLUGINS.md).

### Authentication
API plugins require authentication configuration. Supported types: None, Basic, ApiKey, AAD, AADDelegated, OAuth flows. See [AUTHENTICATION.md](references/AUTHENTICATION.md).

---

## Generation Workflow

When asked to create a plugin or agent, follow these steps:

### Step 0: Check Already Available Tools First

> **Before building anything**, use `search_for_tools` followed by `get_evaluation` to check whether Security Copilot already has available skills, agents, or MCP tools that can satisfy the user's request.

This is a **two-step process**:

#### Step 0a: Submit the search

Call `search_for_tools` with the user's query or intent (e.g., *"Analyze Defender incidents"*, *"Get threat intelligence for an IP"*).

`search_for_tools` is an **asynchronous** operation. It submits the query to the Security Copilot evaluation engine and returns an evaluation receipt containing `evaluationId`, `sessionId`, and `promptId` — but **not** the actual results.

#### Step 0b: Retrieve the results

Call `get_evaluation` passing the `evaluationID`, `sessionID`, and `promptID` from the receipt returned by `search_for_tools`.

`get_evaluation` returns the completed evaluation with:
- **`result.outputComponents`**: the list of matching already available skills (SkillName, SkillsetName, DescriptionForModel, Inputs)
- **`result.suggestedPrompts`**: additional suggested skills with their inputs and descriptions

> **IMPORTANT**: Always call `get_evaluation` after `search_for_tools`. The `search_for_tools` response alone does NOT contain the discovered skills — it only confirms the evaluation was created. The actual skill discovery results are only available via `get_evaluation`.

```
search_for_tools(userQuery) → receipt {evaluationId, sessionId, promptId}
        ↓
get_evaluation(evaluationID, sessionID, promptID) → full results with discovered skills
```

#### Decision logic

| Scenario | Action |
|----------|--------|
| Already available tools **fully cover** the need | Recommend the already available tools to the user. Explain what they do and how to use them. **Do not create a custom plugin.** |
| Already available tools **partially cover** the need | Explain which parts are already covered. Create a custom plugin only for the **gap** — the functionality not available out of the box. |
| **No relevant** already available tools exist | Proceed to Step 1 and build a custom plugin from scratch. |

> Use your judgment: if an already available tool does 90% of what the user needs, suggest it first. Only build custom plugins when they add clear value beyond what's already available.

### Step 1: Gather Requirements

Ask the user:

1. **Type**: Plugin, agent, or both?
2. **Format(s)**: KQL, API, GPT, LogicApp, MCP, Agent? (can mix multiple)
3. **Purpose**: What should it do?
4. **Target** (KQL): Defender, Sentinel, ADX, LogAnalytics?
5. **Endpoint** (API): Service URL, which endpoints?
6. **Authentication** (API): None, Basic, ApiKey, AAD, AADDelegated, OAuth?
7. **Parameters**: Any user inputs needed?
8. **Agent workflow** (Agent): Mission, steps, child skills?
9. **Agent type** (Agent): Standard (scheduled) or Interactive (chat)?

### Step 2: Discover Schema (KQL only — MANDATORY)

> **CRITICAL**: Before writing ANY KQL query, use the live schema tools.

| Target | Tool | Usage |
|--------|------|-------|
| Defender | `FetchAdvancedHuntingTablesOverview` | Pass `[]` to list all tables, or specific names to filter |
| Defender | `FetchAdvancedHuntingTablesDetailedSchema` | Pass table names to get columns, types, descriptions |
| Sentinel / LogAnalytics | `search_tables` | Pass natural language query to find relevant tables |

```
DISCOVER TABLES → GET DETAILED SCHEMA → WRITE QUERY → VALIDATE
```

If live tools are unavailable, fall back to static references in [BEST_PRACTICES.md](references/BEST_PRACTICES.md) and **warn the user**.

### Step 3: Generate YAML

Load the appropriate reference file(s) for the format:

| Format | Reference |
|--------|-----------|
| KQL | [KQL_PLUGINS.md](references/KQL_PLUGINS.md) |
| API | [API_PLUGINS.md](references/API_PLUGINS.md) |
| GPT | [GPT_PLUGINS.md](references/GPT_PLUGINS.md) |
| LogicApp | [LOGICAPP_PLUGINS.md](references/LOGICAPP_PLUGINS.md) |
| MCP | [MCP_PLUGINS.md](references/MCP_PLUGINS.md) |
| Agent | [AGENT_PLUGINS.md](references/AGENT_PLUGINS.md) |
| Mixed | [MIXED_FORMAT_PLUGINS.md](references/MIXED_FORMAT_PLUGINS.md) |
| Auth | [AUTHENTICATION.md](references/AUTHENTICATION.md) |

For the base YAML structure (Descriptor, SkillGroups, AgentDefinitions fields), always refer to [YAML_FORMAT.md](references/YAML_FORMAT.md).

### Step 4: Validate

Run the validation checklists from [BEST_PRACTICES.md](references/BEST_PRACTICES.md):

- **General checks**: naming, descriptions, parameter syntax, YAML formatting
- **KQL checks**: syntactic + semantic validation, live schema cross-reference
- **API checks**: OpenAPI version, operationId uniqueness, auth consistency
- **Agent checks**: AgentDefinitions, RequiredSkillsets, ChildSkills completeness
- **LogicApp/MCP checks**: required settings present

### Step 5: Deliver

Return the complete YAML manifest(s) to the user. If multiple files are needed (e.g., agent manifest + child skills plugin, or API manifest + OpenAPI spec), provide all files.

### Step 6: Generate Plugin Card (HTML)

After delivering the YAML, generate a **Plugin Card** — an HTML file that provides a visual summary of the plugin/agent and its skills.

Use the template at [output/plugin_card_template.html](output/plugin_card_template.html) as a base. **Copy the template** into a new file in the `output/` folder named `<PluginName>_card.html` (using the Descriptor `Name`), and fill in the `PLUGIN_DATA` JavaScript object at the top of the file with the actual plugin data.

#### How to fill `PLUGIN_DATA`

Map the generated YAML fields to the `PLUGIN_DATA` object as follows:

| `PLUGIN_DATA` field | Source (from YAML) |
|---|---|
| `type` | `"Plugin"` if no AgentDefinitions, `"Agent"` if standard agent, `"Agent (Interactive)"` if interactive |
| `name` | `Descriptor.Name` |
| `displayName` | `Descriptor.DisplayName` |
| `description` | `Descriptor.Description` |
| `auth.type` | Authorization type (e.g. `"None"`, `"ApiKey"`, `"AAD"`, etc.) |
| `auth.details` | Extra info (e.g. header name for ApiKey, scope for AAD) |
| `skillGroups[]` | One entry per SkillGroup — set `format` and `skills[]` |
| `skillGroups[].skills[].name` | `Skills[].Name` |
| `skillGroups[].skills[].displayName` | `Skills[].DisplayName` |
| `skillGroups[].skills[].description` | `Skills[].Description` |
| `skillGroups[].skills[].inputs[]` | `Skills[].Inputs[]` — each with `name`, `description`, `required`, `defaultValue` |
| `agent.name` | `AgentDefinitions[].Name` |
| `agent.displayName` | `AgentDefinitions[].DisplayName` |
| `agent.publisher` | `AgentDefinitions[].Publisher` |
| `agent.model` | Agent skill `Settings.Model` |
| `agent.constraint` | `AgentDefinitions[].AgentSingleInstanceConstraint` |
| `agent.triggerName` | `AgentDefinitions[].Triggers[].Name` |
| `agent.pollPeriod` | `AgentDefinitions[].Triggers[].DefaultPollPeriodSeconds` |
| `agent.fetchSkill` | `AgentDefinitions[].Triggers[].FetchSkill` |
| `agent.processSkill` | `AgentDefinitions[].Triggers[].ProcessSkill` |
| `agent.promptSkill` | `AgentDefinitions[].PromptSkill` (interactive only) |
| `agent.childSkills` | Agent skill `ChildSkills[]` |
| `agent.requiredSkillsets` | `AgentDefinitions[].RequiredSkillsets[]` |
| `agent.suggestedPrompts` | Agent skill `SuggestedPrompts[]` — each with `text` and `isStarter` |

> **IMPORTANT**: Always generate the Plugin Card after delivering the YAML. The HTML file is self-contained — it can be opened in any browser and requires no server.

---

## Key Rules

1. **Always check already available tools first** — before creating a custom plugin, use `search_for_tools` followed by `get_evaluation` to verify whether Security Copilot already provides skills that satisfy the user's need. `search_for_tools` submits the query asynchronously; `get_evaluation` retrieves the actual results. Both calls are required. Prefer already available tools when they fully cover the requirement; build custom plugins only for gaps or net-new functionality
2. **Never skip live schema discovery** for KQL plugins — queries built from memory fail at runtime
3. **Never include real credentials** — use `<YOUR-TENANT-ID>`, `<YOUR-API-KEY>` placeholders
4. **One plugin can have multiple SkillGroups** with different formats
5. **Agent ChildSkills** must be verifiable: either inline in the same manifest or in a RequiredSkillset
6. **Interactive agents** need `Interfaces: [InteractiveAgent]`, `PromptSkill`, `UserRequest` input, `OrchestratorSkill: DefaultAgentOrchestrator`, `SuggestedPrompts` (starter prompts with `IsStarterAgent: true`, `Title`, `Personas` + follow-up suggestions without those fields). ChildSkills can include other Agent skills for agent-to-agent communication.
7. **KQL time columns**: `Timestamp` for Defender, `TimeGenerated` for Sentinel/LogAnalytics
8. **OpenAPI**: only version 3.0 or 3.0.1 supported
9. **YAML multi-line**: use `|-` for templates, `>-` for long descriptions
10. **Agents should not use GPT child skills for text tasks** — when an agent needs to generate reports, summaries, or analysis from collected data, embed those instructions directly in the agent's `Instructions` field instead of creating a separate GPT skill. The agent's model already handles natural language tasks; a GPT child skill adds unnecessary overhead. Reserve GPT skills for standalone plugins (without agents) or for specialized text transformations that need to be reusable independently.
11. **Always generate the Plugin Card** — after delivering the YAML, generate a `<PluginName>_card.html` file in the `output/` folder using the [plugin_card_template.html](output/plugin_card_template.html) template. Fill in the `PLUGIN_DATA` object with the actual data from the generated plugin. This gives the user a visual overview of the plugin/agent and its skills.

---

## Reference Files

| File | Content |
|------|---------|
| [YAML_FORMAT.md](references/YAML_FORMAT.md) | Plugin & Agent architecture, YAML manifest schema, all field definitions |
| [KQL_PLUGINS.md](references/KQL_PLUGINS.md) | KQL targets, settings, live schema tools, full examples |
| [API_PLUGINS.md](references/API_PLUGINS.md) | API settings, OpenAPI spec structure, auth patterns, full examples |
| [GPT_PLUGINS.md](references/GPT_PLUGINS.md) | GPT settings, models, template options, full examples |
| [LOGICAPP_PLUGINS.md](references/LOGICAPP_PLUGINS.md) | LogicApp settings, ARM templates, full examples |
| [MCP_PLUGINS.md](references/MCP_PLUGINS.md) | MCP settings, DescriptionForModel guidance, full examples |
| [AGENT_PLUGINS.md](references/AGENT_PLUGINS.md) | Agent types, FetchSkill/ProcessSkill, Instructions, Interactive agents (step-by-step guide), Agent-to-Agent communication, full examples |
| [MIXED_FORMAT_PLUGINS.md](references/MIXED_FORMAT_PLUGINS.md) | Combining KQL+GPT, KQL+API in one plugin, auth notes |
| [AUTHENTICATION.md](references/AUTHENTICATION.md) | All auth types with configuration examples |
| [BEST_PRACTICES.md](references/BEST_PRACTICES.md) | Naming, validation checklists (syntactic, semantic, output), common mistakes |
| [plugin_card_template.html](output/plugin_card_template.html) | HTML template for generating a visual Plugin Card summary |

---

## Examples Summary

| # | Type | Name | Auth |
|---|------|------|------|
| 1 | KQL | DefenderDailyOperations | — |
| 2 | KQL | Sentinel Cost Details | — |
| 3 | KQL | InteractWithADX | — |
| 4 | KQL | DefenderViaTemplate | — |
| 5 | API | Nitrix (NoAuth) | None |
| 6 | API | VirusTotal (ApiKey) | ApiKey |
| 7 | API | Censys (Basic) | Basic |
| 8 | API | Graph Alerts (AADDelegated) | AADDelegated |
| 9 | API | Graph Users (OAuthAuthCodeFlow) | OAuthAuthorizationCodeFlow |
| 10 | API | Graph Users (OAuthClientCreds) | OAuthClientCredentialsFlow |
| 11 | API | MDE Writable (POST) | OAuthClientCredentialsFlow |
| 12 | GPT | DefangUrls | — |
| 13 | GPT | CustomIncidentReport | — |
| 14 | LogicApp | SendEmailStandard | — |
| 15 | LogicApp | NitrxLogicApp | — |
| 16 | MCP | MSLearn MCP | None |
| 17 | KQL+GPT | IncidentInvestigationToolkit | — |
| 18 | KQL+API | ThreatIntelEnrichment | ApiKey |
| 19 | Agent | CVEAnalyser | — |
| 20 | Agent+GPT+KQL | URL Geolocation Agent | — |
| 21 | Agent (Interactive) | SecurityCopilotDocsAgent | — |
| 22 | Agent (Interactive + Agent-to-Agent) | UserAndDeviceInvestigationAgents | — |

---

## Official References

- [Create custom plugins](https://learn.microsoft.com/en-us/copilot/security/custom-plugins)
- [Agent Manifest](https://learn.microsoft.com/en-us/copilot/security/developer/agent-manifest)
- [Build Agents with Multiple Tools](https://learn.microsoft.com/en-us/copilot/security/developer/build-agent-multiple-tools)
- [Build Interactive Agents](https://learn.microsoft.com/en-us/copilot/security/developer/build-interactive-agents)
- [API Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-api)
- [KQL Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-kql)
- [GPT Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-gpt)
- [Security Copilot GitHub](https://github.com/Azure/Copilot-For-Security)

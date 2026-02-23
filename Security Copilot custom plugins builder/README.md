# Security Copilot Custom Plugins & Agents Builder

> A VS Code / GitHub Copilot skill that generates production-ready YAML manifests for **Microsoft Security Copilot** custom plugins and agents.

## Overview

Building custom plugins and agents for Security Copilot requires writing YAML manifest files that follow a precise schema — with different structures depending on the skill format (KQL, API, GPT, LogicApp, MCP, Agent) and authentication type.

This project is an **AI skill** (for use with GitHub Copilot in VS Code or compatible agents) that automates the entire process: from gathering requirements and discovering live schemas, to generating validated YAML manifests and visual Plugin Cards.

## Features

- **Full format coverage** — supports all Security Copilot skill formats:

  | Format | Purpose |
  |--------|---------|
  | **KQL** | Kusto queries against Defender, Sentinel, ADX, Log Analytics |
  | **API** | REST API calls to external or Microsoft services |
  | **GPT** | Direct GPT model interaction (prompts, reports, analysis) |
  | **LogicApp** | Trigger Azure Logic Apps (emails, workflows, write ops) |
  | **MCP** | Connect to MCP Servers and use their tools |
  | **Agent** | Orchestrate other skills via AI agent with Instructions |

- **Mixed-format plugins** — combine multiple formats (e.g., KQL + GPT, KQL + API) in a single manifest
- **Agent orchestration** — standard agents with FetchSkill/ProcessSkill triggers, interactive agents with chat experience, and agent-to-agent communication
- **All authentication types** — None, Basic, ApiKey, AAD, AADDelegated, OAuthAuthorizationCodeFlow, OAuthClientCredentialsFlow, OAuthPasswordGrantFlow, ServiceHttp
- **Live schema discovery** — uses Microsoft Sentinel and Defender tools to discover tables and columns before writing KQL queries
- **Built-in tool check** — searches Security Copilot's existing skills before creating custom plugins, avoiding duplication
- **Validation checklists** — syntactic, semantic, and output validation for every generated manifest
- **Plugin Card generation** — produces a self-contained HTML card with a visual summary of the plugin/agent and its skills

## How It Works

The skill follows a structured workflow:

```
Check built-in tools → Gather requirements → Discover schema (KQL) → Generate YAML → Validate → Deliver + Plugin Card
```

1. **Check built-in tools first** — queries Security Copilot to see if existing skills already cover the user's need
2. **Gather requirements** — asks about format, purpose, target, authentication, parameters, agent workflow
3. **Discover schema** (KQL only) — uses live tools to fetch table schemas before writing queries
4. **Generate YAML** — produces the complete manifest following the official schema and best practices
5. **Validate** — runs format-specific validation checklists
6. **Deliver + Plugin Card** — returns the YAML manifest and generates an HTML Plugin Card

## Project Structure

```
├── SKILL.md                              # Main skill definition (entry point)
├── README.md                             # This file
├── output/
│   └── plugin_card_template.html         # HTML template for Plugin Card generation
└── references/
    ├── YAML_FORMAT.md                    # YAML manifest schema and field definitions
    ├── KQL_PLUGINS.md                    # KQL plugin guide, targets, settings, examples
    ├── API_PLUGINS.md                    # API plugin guide, OpenAPI spec, auth patterns
    ├── GPT_PLUGINS.md                    # GPT plugin guide, models, templates
    ├── LOGICAPP_PLUGINS.md               # LogicApp plugin guide, ARM templates
    ├── MCP_PLUGINS.md                    # MCP plugin guide, DescriptionForModel
    ├── AGENT_PLUGINS.md                  # Agent guide (standard, interactive, agent-to-agent)
    ├── MIXED_FORMAT_PLUGINS.md           # Multi-format plugin examples (KQL+GPT, KQL+API)
    ├── AUTHENTICATION.md                 # All authentication types with examples
    └── BEST_PRACTICES.md                 # Naming conventions, validation checklists, common mistakes
```

## Included Examples

The reference files contain **22 complete examples** covering every format and authentication type:

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

## Usage

### Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension
- Access to [Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/microsoft-security-copilot)
- [Microsoft Security Copilot MCP Server](https://aka.ms/yourSecurityCopilotMCPServer) — provides the live tools used by this skill for schema discovery and built-in skill lookup

#### MCP Server Collections & Tools

The skill relies on three collections from the Security Copilot MCP Server:

| Collection | Tool | Purpose |
|------------|------|---------|
| **Advanced Hunting** | `FetchAdvancedHuntingTablesOverview` | Lists available Advanced Hunting tables and their descriptions |
| **Advanced Hunting** | `FetchAdvancedHuntingTablesDetailedSchema` | Returns complete column schemas (names, types, descriptions) for specified tables |
| **Sentinel** | `search_tables` | Discovers Sentinel / Log Analytics tables relevant to a natural language query |
| **Security Copilot Agent** | `search_for_tools` | Finds existing built-in skills, agents, and MCP tools in Security Copilot that match a given intent |
| **Security Copilot Agent** | `get_evaluation` | Retrieves the results of a `search_for_tools` evaluation (the actual discovered skills) |

> These tools are declared in the skill's `allowed-tools` list and are called automatically during the generation workflow — `search_for_tools` + `get_evaluation` to check for existing built-in tools (Step 0), and `FetchAdvancedHuntingTablesOverview` / `FetchAdvancedHuntingTablesDetailedSchema` / `search_tables` to discover table schemas before writing KQL queries (Step 2).

### Getting Started

1. Clone the repository
2. Open the folder in VS Code
3. Start a GitHub Copilot chat session and ask to create a plugin or agent — for example:
   - *"Create a KQL plugin that queries Defender for recent sign-in failures"*
   - *"Build an API plugin for VirusTotal with ApiKey auth"*
   - *"Create an interactive agent that investigates security incidents"*
   - *"Build a mixed KQL+GPT plugin for incident investigation"*

The skill will walk through the workflow automatically — checking built-in tools, gathering details, generating the YAML, validating it, and producing the Plugin Card.

## Official References

- [Create custom plugins](https://learn.microsoft.com/en-us/copilot/security/custom-plugins)
- [Agent Manifest](https://learn.microsoft.com/en-us/copilot/security/developer/agent-manifest)
- [Build Agents with Multiple Tools](https://learn.microsoft.com/en-us/copilot/security/developer/build-agent-multiple-tools)
- [Build Interactive Agents](https://learn.microsoft.com/en-us/copilot/security/developer/build-interactive-agents)
- [API Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-api)
- [KQL Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-kql)
- [GPT Plugins](https://learn.microsoft.com/en-us/copilot/security/plugin-gpt)
- [Security Copilot GitHub](https://github.com/Azure/Copilot-For-Security)

## License

MIT

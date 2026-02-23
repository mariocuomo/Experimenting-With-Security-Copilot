# Plugin & Agent Architecture — YAML Manifest Format

> Complete reference for the YAML manifest structure used by all Security Copilot custom plugins and agents.

---

## Plugin & Agent Architecture

A Security Copilot custom plugin (or agent) consists of **a YAML manifest file** that describes:
- **Who the plugin/agent is** (metadata via `Descriptor`)
- **What it can do** (skills via `SkillGroups`)
- **How to authenticate** (optional, via `Authorization` in `Descriptor`)
- **Agent behavior** (optional, via `AgentDefinitions` — only for agents)

> **IMPORTANT**: A single plugin can contain **multiple SkillGroups with different Formats**. For example, the same plugin can have a KQL skill group, an API skill group, and a GPT skill group. The `Format` field is defined at the **SkillGroup level**, not at the plugin level.

> **WHAT IS AN AGENT?** An agent is a Security Copilot skill that **orchestrates other skills**. Technically, an agent is defined by:
> 1. A `SkillGroup` with `Format: Agent` containing the orchestration logic (Instructions, ChildSkills)
> 2. An `AgentDefinitions` section that registers the agent with Security Copilot (triggers, required skillsets)
>
> The child skills used by the agent can be defined **in the same manifest** (inline) or in a **separate plugin** referenced via `RequiredSkillsets`.

### Conceptual Structure — Plugin (without Agent)
```
Plugin
├── Descriptor          → Plugin identity (name, description, auth)
└── SkillGroups[]       → Array of skill groups (each can have a DIFFERENT Format)
    ├── SkillGroup[0]
    │   ├── Format      → e.g. KQL
    │   ├── Settings    → Group-level settings for this format
    │   └── Skills[]    → Skills of this format
    ├── SkillGroup[1]
    │   ├── Format      → e.g. API (different from group 0)
    │   ├── Settings    → Group-level settings for this format
    │   └── Skills[]    → Skills of this format
    └── SkillGroup[N]
        ├── Format      → e.g. GPT | LogicApp | MCP
        ├── Settings    → Group-level settings for this format
        └── Skills[]    → Skills of this format
            ├── Name        → Internal name (no spaces)
            ├── DisplayName → User-facing name
            ├── Description → What the skill does
            ├── Inputs[]    → Input parameters (optional)
            └── Settings    → Skill-specific configuration
```

### Conceptual Structure — Agent
```
Agent Manifest
├── Descriptor              → Agent/plugin identity (name, description, auth)
├── AgentDefinitions[]      → Agent registration (triggers, required skillsets)
│   └── AgentDefinition
│       ├── Name            → Agent install name (no spaces, no dots)
│       ├── DisplayName     → User-facing name
│       ├── Description     → What the agent does
│       ├── Publisher       → Who published the agent
│       ├── Product         → Source product (e.g. Security)
│       ├── RequiredSkillsets → Skillsets the agent depends on
│       ├── AgentSingleInstanceConstraint → None | Workspace | Tenant
│       ├── Settings        → User-configurable settings (applied to FetchSkill)
│       ├── Triggers[]      → How/when the agent runs
│       │   ├── Name
│       │   ├── DefaultPollPeriodSeconds (or DefaultPeriodSeconds)
│       │   ├── FetchSkill   → Skill invoked first to gather data
│       │   └── ProcessSkill → Agent skill invoked to process each result
│       └── PromptSkill     → (Interactive agents only) enables chat experience
└── SkillGroups[]           → Skills used by the agent
    ├── SkillGroup (Format: Agent)
    │   └── Skills[]
    │       ├── Name
    │       ├── Interfaces   → [Agent] or [InteractiveAgent]
    │       ├── Inputs[]
    │       ├── Settings
    │       │   ├── Instructions → Natural language instructions for the agent
    │       │   └── Model        → gpt-4o | gpt-4.1
    │       ├── ChildSkills[]    → List of skills the agent can invoke
    │       └── SuggestedPrompts → (Interactive agents only) starter/follow-up prompts
    ├── SkillGroup (Format: KQL)   → Optional: inline tool skills
    ├── SkillGroup (Format: GPT)   → Optional: inline tool skills
    └── SkillGroup (Format: API)   → Optional: inline tool skills
```

### Supported Formats
| Format | Description | Required Files |
|--------|-------------|----------------|
| **KQL** | Runs KQL queries against Defender, Sentinel, Log Analytics, or Azure Data Explorer | Manifest YAML only |
| **API** | Calls external or Microsoft REST APIs | Manifest YAML + OpenAPI spec YAML |
| **GPT** | Direct interaction with the GPT model (gpt-4o / gpt-4.1) | Manifest YAML only |
| **LogicApp** | Triggers an Azure Logic App | Manifest YAML (+ ARM template for Logic App deployment) |
| **MCP** | Connects to an external MCP Server | Manifest YAML only |
| **Agent** | Orchestrates other skills via an AI agent with Instructions and ChildSkills | Manifest YAML only (+ optional separate plugin for child skills) |

---

## Base YAML Structure — Plugin

```yaml
Descriptor:
  Name: <InternalName>                   # REQUIRED - No spaces, no / \ ? # @, max 100 chars
  DisplayName: <UserFacingName>          # Recommended - Max 40 chars
  Description: <Description>             # REQUIRED - Max 16,000 chars
  DescriptionForModel: <AIDescription>   # Optional - Used by the model for skill selection

SkillGroups:
  - Format: <KQL|API|GPT|LogicApp|MCP>   # REQUIRED - Format for THIS skill group
    Skills:
      - Name: <SkillName>                # REQUIRED - No spaces
        DisplayName: <UserFacingName>     # Recommended
        Description: <Description>        # Recommended

  - Format: <DifferentFormat>            # OPTIONAL - Additional skill group with a different format
    Skills:
      - Name: <AnotherSkillName>
        DisplayName: <UserFacingName>
        Description: <Description>
```

## Base YAML Structure — Agent

```yaml
Descriptor:
  Name: <InternalName>                   # REQUIRED - No spaces, no / \ ? # @, max 100 chars
  DisplayName: <UserFacingName>          # Recommended - Max 40 chars
  Description: <Description>             # REQUIRED - Max 16,000 chars

AgentDefinitions:
  - Name: <AgentName>                    # REQUIRED - No spaces, no dots
    DisplayName: <UserFacingName>        # REQUIRED
    Description: <Description>           # REQUIRED
    Publisher: <PublisherName>            # REQUIRED
    Product: <ProductName>               # REQUIRED
    RequiredSkillsets:                    # REQUIRED - Skillsets the agent depends on
      - <SkillsetName>
    AgentSingleInstanceConstraint: None  # None | Workspace | Tenant
    Triggers:                            # REQUIRED - At least one trigger
      - Name: Default
        DefaultPollPeriodSeconds: 0      # 0 = manual trigger only; >0 = scheduled (seconds)
        FetchSkill: ''                   # Optional: skill to gather data before processing
        ProcessSkill: <SkillsetName>.<AgentSkillName>  # REQUIRED
    PromptSkill: <SkillsetName>.<AgentSkillName>  # Optional: only for interactive agents

SkillGroups:
  - Format: Agent                        # REQUIRED for agent orchestration skill
    Skills:
      - Name: <AgentSkillName>           # REQUIRED - No spaces, no dots
        DisplayName: <UserFacingName>
        Description: <Description>
        Interfaces:
          - Agent                        # "Agent" or "InteractiveAgent"
        Inputs:                          # Optional
          - Name: <parameterName>
            Description: <description>
            Required: true
        Settings:
          Model: gpt-4.1                 # or gpt-4o
          Instructions: >-               # REQUIRED - Natural language instructions
            <Agent instructions here>
        ChildSkills:                     # REQUIRED - Skills the agent can invoke
          - <SkillName1>
          - <SkillName2>

  - Format: <KQL|GPT|API|...>           # OPTIONAL - Inline child skills
    Skills:
      - Name: <ChildSkillName>
        # ...
```

> **NOTE**: You can have **one or more SkillGroups** in a single plugin. Each SkillGroup has its own `Format`, so a single plugin can mix KQL, API, GPT, LogicApp, MCP, and Agent skills together.

---

## Field Reference

### Descriptor Fields
| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `Name` | string | Unique internal name. No `/`, `\`, `?`, `#`, `@`. No whitespace. | Yes |
| `DisplayName` | string | Human-readable name. Max 40 chars. | Recommended |
| `Description` | string | Human-readable description. Cannot be null or empty. | Yes |
| `DescriptionForModel` | string | Description used by the AI model for skill selection. Can be more verbose and technical. Max 16,000 chars. | No |
| `SupportedAuthTypes` | array | List of supported authentication types. | Required for API |
| `Authorization` | object | Pre-configured authentication settings. | Required for API with auth |
| `Settings` | array of objects | User-configurable settings (e.g. InstanceURL). | No |

### AgentDefinitions Fields
| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `Name` | string | Name used for installing the agent. No whitespace, no dots. | Yes |
| `DisplayName` | string | User-friendly name for UI display. | Yes |
| `Description` | string | Human-readable summary of the agent's purpose and functionality. | Yes |
| `Publisher` | string | Name of the agent's publisher. | Yes |
| `Product` | string | Source product associated with the agent (e.g. `Security`, `SecurityCopilot`). Used for filtering. | Yes |
| `RequiredSkillsets` | array of strings | Skillsets required for the agent to function. Must include the Descriptor `Name` of the current manifest and any external plugin/skillset used by child skills. | Yes |
| `AgentSingleInstanceConstraint` | string | Deployment constraint: `None` (no restriction), `Workspace` (one per workspace), `Tenant` (one per tenant). | No (defaults to None) |
| `Settings` | array of objects | User-configurable settings applied to FetchSkill invocation. Each has `Name`, `Label`, `Description`, `HintText`, `SettingType`, `Required`. | No |
| `Triggers` | array of objects | Defines how/when the agent is triggered. At least one trigger is required. | Yes |
| `PromptSkill` | string | Enables interactive chat experience. Format: `SkillsetName.SkillName`. | Only for interactive agents |

### Triggers Fields
| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `Name` | string | Descriptive name for the trigger (e.g. `Default`). No whitespace. | Yes |
| `DefaultPollPeriodSeconds` (or `DefaultPeriodSeconds`) | integer | Interval in seconds for scheduled execution. Set to `0` to disable scheduled triggers (manual only). Does not prevent concurrent executions. | Yes |
| `FetchSkill` | string | Skill invoked first to gather data. Format: `SkillsetName.SkillName`. Returns an array of objects; each object is passed as input to ProcessSkill. Set to `''` if not needed. | No |
| `ProcessSkill` | string | Agent skill invoked to process each result from FetchSkill (or the direct trigger). Format: `SkillsetName.SkillName`. | Yes |

### Skills Fields
| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `Name` | string | Internal name. No spaces, no dots. | Yes |
| `DisplayName` | string | Human-readable name. | Recommended |
| `Description` | string | Skill description. Cannot be null or empty. | Recommended |
| `ExamplePrompt` | array of strings | Example prompts that trigger the skill. | No (API only) |
| `Inputs` | array of objects | Input parameters. Each has `Name`, `Description`, `Required`. | No |
| `Settings` | object | Skill-specific settings (vary by format). | Yes |
| `ChildSkills` | array of strings | List of skill names the agent invokes. | Required for Format: Agent |
| `Interfaces` | array of strings | Set to `[Agent]` for standard agents or `[InteractiveAgent]` for interactive agents. | Required for Format: Agent |
| `SuggestedPrompts` | array of objects | Starter and follow-up prompts for interactive agents. Each has `Prompt`, `Title`, `Personas`, `IsStarterAgent`. | Only for interactive agents |

### Inputs Fields
```yaml
Inputs:
  - Name: <parameterName>         # Parameter name (used in template as {{parameterName}})
    Description: <description>     # Description for the user and model
    Required: true                 # true | false
```

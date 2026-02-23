# Agent Plugins

An **Agent** in Security Copilot is a skill that **orchestrates other skills — including other agents**. An agent receives instructions in natural language, invokes child skills (KQL, GPT, API, MCP, other Agent skills, or skills from other plugins), and produces a consolidated result. Agents are ideal for:
- **Multi-step workflows**: chaining multiple skills in a defined sequence
- **Automated investigations**: periodically fetching data and processing it
- **Interactive experiences**: enabling a chat-style interaction with the user
- **Report generation**: consolidating data from multiple sources into a structured report
- **Agent-to-agent orchestration**: delegating subtasks to other specialized agents

---

## How Agents Work

1. The `AgentDefinitions` section registers the agent with Security Copilot, defining triggers, required skillsets, and metadata.
2. The `SkillGroups` section with `Format: Agent` contains the orchestration skill with `Instructions` (natural language mission and workflow) and `ChildSkills` (list of skills to invoke).
3. Child skills can be **inline** (defined in the same manifest in other SkillGroups), **external** (defined in separate plugins, referenced via `RequiredSkillsets`), or **other Agent skills** (enabling agent-to-agent communication).

## Agent Types

| Type | Interface | Description |
|------|-----------|-------------|
| **Standard Agent** | `Agent` | Runs via triggers (scheduled or manual). No direct user interaction during execution. |
| **Interactive Agent** | `InteractiveAgent` | Enables a "Chat with agent" experience. Users can converse with the agent. |

## Agent Settings (Format: Agent)

| Setting | Type | Description | Required |
|---------|------|-------------|----------|
| `Instructions` | string | Natural language directions defining the agent's behavior, mission, and workflow. Typically written in markdown with sections like Mission, Workflow, Output format. | Yes |
| `Model` | string | The model to use for agent orchestration. Use `gpt-4o` or `gpt-4.1`. | Yes |
| `OrchestratorSkill` | string | Orchestrator skill name. Set to `DefaultAgentOrchestrator` for interactive agents. | Only for interactive agents |

## ChildSkills

The `ChildSkills` field is an array of skill names that the agent can invoke. These can be:
- **Inline skills**: defined in the same manifest under other SkillGroups (KQL, API, etc.)
- **External skills**: defined in separate plugins. The external plugin's Descriptor `Name` must be listed in `RequiredSkillsets` of the `AgentDefinitions`.
- **Built-in Security Copilot skills**: skills from pre-installed plugins (e.g., `ThreatIntelligence.DTI` provides `GetCvesByIdsDti`)
- **Other Agent skills**: an agent can call another agent as a child skill, enabling **agent-to-agent communication**. The called agent's skillset must be listed in `RequiredSkillsets`. This allows building hierarchical agent architectures where a parent agent delegates subtasks to specialized child agents.

> **IMPORTANT — Do NOT create GPT child skills for agents**: The agent itself is powered by a GPT model (`gpt-4o` or `gpt-4.1`). Tasks like report generation, summarization, analysis, formatting, and consolidation should be described directly in the agent's `Instructions` field — not delegated to a separate GPT skill. Creating a GPT child skill for these tasks adds unnecessary overhead and an extra model invocation. Only use KQL, API, LogicApp, MCP, or built-in skills as child skills. The agent handles all natural-language reasoning and text generation natively.

> **IMPORTANT**: For external skills, the skill is referenced by its `operationId` (for API skills) or `Name` (for KQL/GPT/Agent skills). The skillset containing the skill must be listed in `RequiredSkillsets`.

## RequiredSkillsets

The `RequiredSkillsets` field lists **all skillsets** the agent depends on:
- The **Descriptor `Name`** of the current manifest (so the agent can access its own inline skills)
- Any **external plugin** Descriptor `Name` (e.g., `CVEAnalysis`, `DCA_SampleAPIPlugin`)
- Any **built-in skillset** (e.g., `ThreatIntelligence.DTI`, `SecurityCopilot`)
- Any **external agent plugin** whose Agent skill is used as a child skill (for agent-to-agent scenarios)

## Agent-to-Agent Communication

Security Copilot supports **agent-to-agent communication**: an agent can list another agent's skill as a child skill, enabling hierarchical orchestration. This allows you to build specialized agents and compose them into more complex workflows.

### How It Works

1. **Child Agent**: Define a standalone agent plugin (with its own `AgentDefinitions`, `SkillGroups`, and `ChildSkills`).
2. **Parent Agent**: In the parent agent's `ChildSkills`, reference the child agent's skill name. Add the child agent's Descriptor `Name` to `RequiredSkillsets`.
3. When the parent agent's instructions invoke the child agent skill, Security Copilot dispatches execution to the child agent, which runs its own orchestration and returns results to the parent.

### When to Use Agent-to-Agent

| Scenario | Benefit |
|----------|---------|
| **Separation of concerns** | Each agent focuses on a specific domain (e.g., one for vulnerability analysis, another for threat intel) |
| **Reusability** | A child agent can be reused by multiple parent agents |
| **Complex pipelines** | Break down large workflows into manageable, composable agents |
| **Team collaboration** | Different teams can own different agents and compose them |

### Example: Parent Agent Calling a Child Agent

**Child Agent Plugin (ThreatIntelAgent):**
```yaml
Descriptor:
  Name: ThreatIntelAgent
  DisplayName: Threat Intel Agent
  Description: >-
    An agent specialized in gathering and analyzing threat intelligence
    for a given indicator (IP, domain, hash).

AgentDefinitions:
  - Name: ThreatIntelAgent
    DisplayName: Threat Intel Agent
    Description: >-
      Gathers threat intelligence for a given indicator using multiple sources.
    Publisher: Custom
    Product: Security
    RequiredSkillsets:
      - ThreatIntelAgent
      - ThreatIntelligence.DTI
    AgentSingleInstanceConstraint: None
    Triggers:
      - Name: Default
        DefaultPollPeriodSeconds: 0
        ProcessSkill: ThreatIntelAgent.AnalyzeIndicator
        FetchSkill: ''

SkillGroups:
  - Format: Agent
    Skills:
      - Name: AnalyzeIndicator
        DisplayName: Analyze Indicator
        Description: >-
          Analyzes a threat indicator (IP, domain, or hash) by querying
          threat intelligence sources and producing a risk summary.
        Interfaces:
          - Agent
        Inputs:
          - Name: Indicator
            Description: The indicator to analyze (IP address, domain, or file hash)
            Required: true
        Settings:
          Model: gpt-4o
          Instructions: |
            # Mission
            You are a threat intelligence analyst agent. Given an indicator,
            gather intelligence from available sources and produce a risk assessment.

            # Workflow
            1. Use GetReputationForIndicator to get the reputation of the indicator.
            2. Use GetArticlesForIndicator to find related threat articles.
            3. Consolidate findings into a risk summary.

            # Output
            Provide a structured risk assessment with:
            - Indicator details
            - Reputation score and verdict
            - Related threat articles
            - Risk level (Critical / High / Medium / Low / Informational)
        ChildSkills:
          - GetReputationForIndicator
          - GetArticlesForIndicator
```

**Parent Agent Plugin (IncidentResponseAgent):**
```yaml
Descriptor:
  Name: IncidentResponseAgent
  DisplayName: Incident Response Agent
  Description: >-
    A parent agent that orchestrates an end-to-end incident response workflow,
    delegating threat intelligence analysis to a child agent.

AgentDefinitions:
  - Name: IncidentResponseAgent
    DisplayName: Incident Response Agent
    Description: >-
      Orchestrates incident response by gathering incident data,
      delegating threat intel analysis to ThreatIntelAgent,
      and producing a comprehensive response report.
    Publisher: Custom
    Product: Security
    RequiredSkillsets:
      - IncidentResponseAgent
      - ThreatIntelAgent
    AgentSingleInstanceConstraint: None
    Triggers:
      - Name: Default
        DefaultPollPeriodSeconds: 0
        ProcessSkill: IncidentResponseAgent.RespondToIncident
        FetchSkill: ''

SkillGroups:
  - Format: Agent
    Skills:
      - Name: RespondToIncident
        DisplayName: Respond to Incident
        Description: >-
          Orchestrates the full incident response workflow, including
          threat intel analysis via a child agent.
        Interfaces:
          - Agent
        Inputs:
          - Name: IncidentId
            Description: The ID of the incident to investigate
            Required: true
        Settings:
          Model: gpt-4o
          Instructions: |
            # Mission
            You are an incident response orchestrator. Investigate the given incident
            and produce a comprehensive response report.

            # Workflow
            1. Use GetIncidentDetails to retrieve the incident information.
            2. Extract indicators (IPs, domains, hashes) from the incident.
            3. For each indicator, call AnalyzeIndicator (the ThreatIntelAgent)
               to get a threat intelligence assessment.
            4. Consolidate all findings into a response report.

            # Output
            Produce a structured incident response report with:
            - Incident Summary
            - Indicators Found
            - Threat Intelligence Analysis (from ThreatIntelAgent)
            - Impact Assessment
            - Recommended Response Actions
        ChildSkills:
          - GetIncidentDetails
          - AnalyzeIndicator

  - Format: KQL
    Skills:
      - Name: GetIncidentDetails
        DisplayName: Get Incident Details
        Description: Retrieves details for a specific incident by ID.
        Inputs:
          - Name: IncidentId
            Description: The incident ID to look up
            Required: true
        Settings:
          Target: Defender
          Template: |-
            SecurityIncident
            | where IncidentNumber == {{IncidentId}}
            | take 1
```

> **KEY POINTS for Agent-to-Agent**:
> - `AnalyzeIndicator` is an **Agent skill** from `ThreatIntelAgent`, referenced as a child skill of `IncidentResponseAgent`
> - `ThreatIntelAgent` must be listed in `RequiredSkillsets` of the parent agent
> - The parent agent's `Instructions` describe **when and how** to call the child agent (just like any other skill)
> - The child agent runs its own full orchestration (with its own model, instructions, and child skills) and returns results to the parent

## FetchSkill and ProcessSkill Pattern

A common pattern for agents is the **Fetch + Process** pattern:
1. **FetchSkill**: A KQL or API skill that retrieves a list of items (e.g., recent alerts, clicked URLs)
2. **ProcessSkill**: The Agent skill that processes each item from the FetchSkill output

The FetchSkill returns an array of objects. For each object, the ProcessSkill is invoked with the object's values as inputs.

If no FetchSkill is needed, set `FetchSkill: ''` and the ProcessSkill will be invoked directly.

## Instructions Best Practices

The `Instructions` field should be structured with clear sections:
```
# Mission
Describe the agent's overall purpose and role.

# Workflow
1. Step 1: describe what to do and which skill to invoke
2. Step 2: describe the next action
3. Step 3: consolidate and generate output

# Output
Describe the expected output format (tables, sections, report structure).
```

> **Agent as the report generator**: Since the agent is powered by a GPT model, it can natively perform all text generation tasks — summarization, report formatting, analysis, recommendations. Include the desired output structure and formatting rules directly in the `Instructions` (typically under the `# Output` section) instead of creating a separate GPT skill. This reduces complexity and avoids unnecessary model invocations.
>
> For example, instead of creating a `GenerateReport` GPT child skill, describe the report format in the Instructions:
> ```
> # Output
> After collecting all data, generate a structured report with:
> - Executive Summary
> - Detailed Findings (with tables)
> - Risk Assessment
> - Recommendations
> ```

For interactive agents, Instructions can use the chat template format:
```
<|im_start|>system
You are an AI agent that...
<|im_end|>
<|im_start|>user
{{UserRequest}}
<|im_end|>
```

---

## Interactive Agents

Interactive agents add a **"Chat with agent"** experience in Security Copilot. Users interact with the agent through the **Chat with agent** feature, enabling dynamic, task-focused conversations.

> **Reference**: [Build Security Copilot agents with an interactive chat experience](https://learn.microsoft.com/en-us/copilot/security/developer/build-interactive-agents)

### Key Differences from Standard Agents

| Feature | Standard Agent | Interactive Agent |
|---------|---------------|-------------------|
| `Interfaces` | `[Agent]` | `[InteractiveAgent]` |
| `PromptSkill` | Not set | Required: `SkillsetName.SkillName` |
| `SuggestedPrompts` | Not applicable | Starter prompts + follow-up suggestions |
| Input | Via FetchSkill or trigger | Must have a single input named `UserRequest` |
| `OrchestratorSkill` | Not needed | Set to `DefaultAgentOrchestrator` |

### Steps to Build an Interactive Agent

#### Step 1: Plan for Your Interactive Agent

Interactive agents are useful when agents and users need to collaborate for a guided experience. Articulate the goals and instructions, specify the tools (skills) available, and define how to handle user requests.

#### Step 2: Add PromptSkill

The `PromptSkill` attribute creates the **Chat with agent** option. It defines the user experience by specifying goals, instructions, and capabilities.

- Format: `SkillsetName.SkillName` (where `SkillsetName` = `Descriptor.Name` and `SkillName` = the Agent skill name)
- The PromptSkill can reference different tool types: **Agent** (recommended), GPT, KQL, and API
- The `Interfaces` field must be set to `[InteractiveAgent]`
- Input must be a single parameter named `UserRequest`

```yaml
# In AgentDefinitions:
PromptSkill: MyAgentPlugin.MyAgentSkill

# In the Agent skill:
Interfaces:
  - InteractiveAgent
Inputs:
  - Name: UserRequest
    Description: The user's question or request.
    DefaultValue: ''
    Required: true
```

#### Step 3: Add Prompts

**Starter Prompts** help set context and appear at the beginning of the interactive experience. They help users understand what the agent can do.

```yaml
SuggestedPrompts:
  - Prompt: Investigate risky user john.doe@company.com
    Title: User Risk Investigation       # Required for starter prompts
    Personas:                              # Required for starter prompts
      - 1
    IsStarterAgent: true                   # Required for starter prompts
```

**Prompt Suggestions** are follow-on prompts displayed after the output of a prompt. They ensure users stay within a guided experience. Omit `IsStarterAgent`, `Title`, and `Personas` for these.

```yaml
  - Prompt: What are the current risk factors for this user?
  - Prompt: Show me recent risky events for this user
  - Prompt: Analyze geographical sign-in patterns
```

> **NOTE**: The orchestrator dynamically generates and ranks prompt suggestions based on session context, using the `SuggestedPrompts` as a starting template. The orchestrator does NOT check if a tool required by the dynamically generated prompt is enabled — ensure all relevant tools are enabled and configured.

#### Step 4: Provide Instructions

`Instructions` are directions that define the agent's goals, how to handle requests, workflows, limitations, and detail its outcome. For interactive agents, Instructions should describe conversational behavior (listening, clarifying, suggesting follow-ups).

#### Step 5: Set Child Skills

Child skills are tools the agent can apply. They can be KQL, API, MCP, LogicApp, built-in skills, **or other Agent skills** (for agent-to-agent communication). List all required skillsets in `RequiredSkillsets`.

#### Step 6: Upload the YAML

Upload the YAML as a custom plugin to enable the **Chat with agent** feature.

### SuggestedPrompts Reference

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `Prompt` | string | The prompt text to display. | Yes |
| `Title` | string | Title of the prompt (for starter prompts). | Required for starter prompts |
| `Personas` | array of integers | Persona types the prompt is aligned to. | Required for starter prompts |
| `IsStarterAgent` | boolean | Set to `true` for starter prompts (shown at the beginning). | Yes for starter prompts |
| `Recommendation` | string | Short recommendation text (max 2 sentences). | No |

### Persona Type IDs

| ID | Persona |
|----|---------|
| 0 | CISO |
| 1 | SOC Analyst |
| 2 | Threat Intel Analyst |
| 3 | ITAdmin |
| 4 | Identity Admin |
| 5 | Data Security Admin |
| 6 | Cloud Admin |

### Known Limitations

- An interactive agent supports only **one input**, which must be named `UserRequest`.
- Users set up interactive chat by selecting **Chat with agent** and authenticating. This doesn't set up the agent for others — an appropriate user must **Set up the agent** in Active Agents for others to use.
- Agent memory isn't included in the chat context.

### Testing Prompts

- Before defining a prompt as a starter prompt, **run it as the first prompt in a new session** and verify there are no errors and the output is valid.
- Not all prompts are suitable as starter prompts. Prompts that require prior context aren't suitable since there is no context available at the start.

---

## Full Examples

### Standard Agent with External Child Skills (CVE Analyser)

This example shows an agent that uses a KQL skill defined in a **separate plugin** (`CVEAnalysis`) and a built-in skill from `ThreatIntelligence.DTI`. Two YAML files are needed.

**Agent Manifest (main file):**
```yaml
Descriptor:
  Name: CVEAnalyser
  DisplayName: CVEAnalyser
  Description: >-
    This agent provides an analysis on Common Vulnerabilities and Exposures
    (CVE) data to identify potential security risks and vulnerabilities within
    an organization's IT infrastructure.
  Icon: ''

AgentDefinitions:
  - Name: CVEAnalyser
    DisplayName: CVEAnalyser
    Description: >-
      This agent provides an analysis on Common Vulnerabilities and Exposures
      (CVE) data to identify potential security risks and vulnerabilities within
      an organization's IT infrastructure.
    Product: Security
    AgentSingleInstanceConstraint: None
    Publisher: MCDev
    RequiredSkillsets:
      - CVEAnalysis
      - ThreatIntelligence.DTI
    Triggers:
      - Name: Default
        DefaultPollPeriodSeconds: 0
        ProcessSkill: CVEAnalyser.CVEAnalyser
        FetchSkill: ''

SkillGroups:
  - Format: Agent
    Skills:
      - Name: CVEAnalyser
        DisplayName: CVEAnalyser
        Description: >-
          This agent provides an analysis on Common Vulnerabilities and Exposures
          (CVE) data to identify potential security risks and vulnerabilities within
          an organization's IT infrastructure.
        Settings:
          Instructions: >-
            # Mission

            You are an assistant that provides an analysis
            of vulnerabilities associated with devices and recommend mitigation
            actions.


            Each time the agent is triggered, perform the following Workflow


            # Workflow

            1. **Identify Exploitable Vulnerabilities and Impacted Devices**

            - Execute the skill
            IdentifyExploitableVulnerabilitiesAndImpactedDevices to retrieve the
            list of vulnerabilities and impacted devices.

            - The skill returns data in tabular format
            (CVE,PublishedDate,Severity, SoftwareOnDevice, AffectedDevices)

            2. **Retrieve CVE Details**

            - For each CVE identified in Step 1, execute the skill
            GetCvesByIdsDti.

            - This skill requires two parameters:
                CveIdList: A comma-separated list of CVE IDs (example: 'CVE-2024-24149, CVE-2024-9621')
                ResponseType: Always set to 'Summary'

            3. **Generate a Comprehensive Report**

            Consolidate all analysis into a structured report. The report should
            include the following sections:

            - Executive Summary
            - Vulnerability Details for the organization
            - Vulnerability Insights
            - Risk Assessment
            - Mitigation Recommendations
        ChildSkills:
          - IdentifyExploitableVulnerabilitiesAndImpactedDevices
          - GetCvesByIdsDti
```

**Child Skills Plugin (separate file — CVEAnalysis):**
```yaml
Descriptor:
  Name: CVEAnalysis
  DisplayName: CVE Analysis
  Description: >-
    This plugin contains skills to perform a comprehensive analysis of Common Vulnerabilities and
    Exposures (CVE) data to identify potential security risks and vulnerabilities within an organization's IT infrastructure.

SkillGroups:
  - Format: KQL
    Skills:
      - Name: IdentifyExploitableVulnerabilitiesAndImpactedDevices
        DisplayName: Identify Exploitable Vulnerabilities and Impacted Devices
        Description: >-
          This skill analyzes devices in the environment to identify software vulnerabilities 
          with a CVSS score above a defined threshold (CVSS == 3) and an available exploit. 
          It provides a list of affected devices, associated CVEs, severity levels, publication dates, and impacted software, 
          cross-referencing with the software inventory for a complete risk overview.
        Settings:
          Target: Defender
          Template: |-
            let CvssMinimum = 3;
            let VulnerabiltiesList = ( DeviceTvmSoftwareVulnerabilitiesKB
            | where CvssScore > CvssMinimum
            and IsExploitAvailable == true
            | join DeviceTvmSoftwareVulnerabilities on CveId
            | where isnotempty(DeviceId)
            | summarize AffectedSoftware=make_set(SoftwareName) by DeviceName, CVE=CveId, Severity=VulnerabilitySeverityLevel, PublishedDate
            );
            let SoftwareInEnvironment = ( DeviceTvmSoftwareInventory
            | distinct SoftwareName, DeviceName
            | summarize SoftwareInventory=make_set(SoftwareName) by DeviceName
            );
            VulnerabiltiesList
            | join SoftwareInEnvironment on DeviceName
            | extend SoftwareOnDevice = set_intersect(todynamic(tostring(AffectedSoftware)), SoftwareInventory)
            | project-away SoftwareInventory, AffectedSoftware
            | summarize AffectedDevices=make_set(DeviceName) by CVE, PublishedDate, Severity, tostring(SoftwareOnDevice)
```

> **NOTE**: The `CVEAnalyser` agent references `CVEAnalysis` (the KQL plugin) and `ThreatIntelligence.DTI` (a built-in skillset) in `RequiredSkillsets`. The child skills `IdentifyExploitableVulnerabilitiesAndImpactedDevices` (from CVEAnalysis) and `GetCvesByIdsDti` (from ThreatIntelligence.DTI) are listed in `ChildSkills`.

### Agent with Multiple Tool Types (URL Geolocation)

This example shows an agent with **inline GPT and KQL skills** plus **external API and built-in skills**, all in a single manifest.

```yaml
Descriptor:
  Name: Contoso.SecurityOperations.Samples-090925
  Description: DCA URL Geolocation Agent
  DisplayName: DCA URL Geolocation Agent

SkillGroups:
  - Format: Agent
    Skills:
      - Name: URL_Location_DCA_Agent_Entrypoint-090925
        Description: The entrypoint into the URL Location Agent
        Interfaces:
          - Agent
        Inputs:
          - Required: true
            Name: URL
            Description: A URL the agent should investigate
        Settings:
          Model: gpt-4.1
          Instructions: |
            <|im_start|>system
            You are an AI agent that helps a security analyst understand the hosting situation of a URL (the input).
            You'll do this by following a three-step process:
            1) Use ExtractHostname to find the hostname from the URL provided as input
            2) Use GetDnsResolutionsByIndicators to extract IP Addresses that the hostname has been observed resolving to. This may produce a list of IP Addresses.
            3) One-at-a time, use lookupIpAddressGeolocation to look up the geolocation of an IP address.

            Produce a simply formatted response telling the security analyst which locations that URL is being served from.
            If you encounter an error share that.
            Always return something the user knows that something happened.
            <|im_end|>
            <|im_start|>user
            {{URL}}
            <|im_end|>
        ChildSkills:
          - lookupIpAddressGeolocation
          - ExtractHostname_DCA-090925
          - GetDnsResolutionsByIndicators

  - Format: GPT
    Skills:
      - Name: ExtractHostname_DCA-090925
        DisplayName: ExtractHostname_DCA-090925
        Description: Extracts the hostname component from a URL
        Inputs:
          - Name: URL
            Description: A URL string
            Required: true
        Settings:
          ModelName: gpt-4.1
          Template: |-
            <|im_start|>system
            Return the hostname component of the URL provided as input.  For example:
            - If the input is 'https://www.mlb.com/', return 'www.mlb.com'
            - If the input is 'http://dev.mycompany.co.uk/sign-up/blah?a=12&b=12&c=32#23', return 'dev.mycompany.co.uk'
            - If the input is 'ftp:/x.espon.com', return 'x.espon.com'
            <|im_end|>
            <|im_start|>user
            {{URL}}
            <|im_end|>

  - Format: KQL
    Skills:
      - Name: RecentUrlClicks_DCA-090925
        Description: Returns 10 recently clicked URLs
        Settings:
          Target: Defender
          Template: UrlClickEvents | sort by TimeGenerated desc | limit 10 | project Url

AgentDefinitions:
  - Name: URLLocationAgent-090925
    DisplayName: URLLocationAgent
    Description: An agent to help an analyst understand URL hosting
    Publisher: Contoso
    Product: SecurityOperations
    RequiredSkillsets:
      - Contoso.SecurityOperations.Samples-090925
      - ThreatIntelligence.DTI
      - DCA_SampleAPIPlugin
    AgentSingleInstanceConstraint: None
    Settings:
      - Name: LookbackWindowMinutes
        Label: Max Lookback Window in minutes
        Description: The maximum number of minutes to find clicked URLs
        HintText: You should probably enter 5
        SettingType: String
        Required: true
    Triggers:
      - Name: Default
        DefaultPeriodSeconds: 300
        FetchSkill: Contoso.SecurityOperations.Samples-090925.RecentUrlClicks_DCA-090925
        ProcessSkill: Contoso.SecurityOperations.Samples-090925.URL_Location_DCA_Agent_Entrypoint-090925
```

> **NOTE on this example**:
> - `ExtractHostname_DCA-090925` is an inline GPT skill in the same manifest
> - `RecentUrlClicks_DCA-090925` is an inline KQL skill used as FetchSkill
> - `GetDnsResolutionsByIndicators` comes from the built-in `ThreatIntelligence.DTI` skillset
> - `lookupIpAddressGeolocation` comes from the external `DCA_SampleAPIPlugin` plugin
> - The `FetchSkill` retrieves recently clicked URLs, then the `ProcessSkill` (the Agent) investigates each URL
> - The trigger runs every 300 seconds (5 minutes)

### Interactive Agent (Security Copilot Docs Agent)

This example shows a basic interactive agent that enables a chat experience with a single MCP child skill.

```yaml
Descriptor:
  Name: SecurityCopilotDocsAgent
  DisplayName: Security Copilot Docs Agent
  Description: >-
    Answers user questions about Microsoft Security Copilot by searching
    Microsoft Docs and returning relevant guidance.
  Icon: ''

AgentDefinitions:
  - Name: SecurityCopilotDocsAgent
    DisplayName: Security Copilot Docs Agent
    Description: >-
      Answers user questions about Microsoft Security Copilot by searching
      Microsoft Docs and returning relevant guidance.
    Publisher: Custom
    Product: SecurityCopilot
    RequiredSkillsets:
      - MCP.MSDocs
      - SecurityCopilotDocsAgent
    AgentSingleInstanceConstraint: None
    Triggers:
      - Name: Default
        DefaultPollPeriodSeconds: 0
        ProcessSkill: SecurityCopilotDocsAgent.SecurityCopilotDocsAgent
    PromptSkill: SecurityCopilotDocsAgent.SecurityCopilotDocsAgent

SkillGroups:
  - Format: Agent
    Skills:
      - Name: SecurityCopilotDocsAgent
        DisplayName: Security Copilot Docs Agent
        Description: Uses Microsoft Docs to answer questions about Security Copilot usage.
        Interfaces:
          - InteractiveAgent
        Inputs:
          - Name: UserRequest
            Description: The user's question about how to use Microsoft Security Copilot.
            DefaultValue: ''
            Required: true
        SuggestedPrompts:
          - Prompt: Show me areas in which Security Copilot can help me?
            Title: Security Copilot Overview
            Personas:
              - 3
            IsStarterAgent: true
          - Prompt: How do I build agents in Security Copilot?
            Title: Building Agents
            Personas:
              - 3
            IsStarterAgent: true
          - Prompt: How do I get details on a specific Defender incident?
            Title: Incident Knowledge
            Personas:
              - 3
            IsStarterAgent: true
          - Prompt: Give me more details on the above
          - Prompt: Where do I get troubleshooting information
          - Prompt: How do I build an API plugin?
          - Prompt: How do I build a promptbook?
          - Prompt: Can I run a Security Copilot prompt from LogicApp?
        Settings:
          OrchestratorSkill: DefaultAgentOrchestrator
          Instructions: >
            # Mission
            You are an expert assistant for Microsoft Security Copilot.
            When a user asks a question about how to use Security Copilot,
            search Microsoft Docs for the most relevant and up-to-date guidance.

            # Workflow
            1. Receive the user's question as input.
            2. Call the microsoft_docs_search skill with the user's question.
            3. Review the returned documentation results.
            4. Summarize the key guidance and steps for the user.
            5. If the answer is not found, state that no relevant documentation was found.

            # Output
            Provide a concise, accurate answer with references to Microsoft Docs where possible.
        ChildSkills:
          - microsoft_docs_search
```

> **KEY DIFFERENCES for Interactive Agents**:
> - `Interfaces: [InteractiveAgent]` instead of `[Agent]`
> - `PromptSkill` is set in `AgentDefinitions` to enable the chat experience
> - Input must be a single parameter named `UserRequest`
> - `SuggestedPrompts` provides starter prompts (with `IsStarterAgent: true`, `Title`, `Personas`) and follow-up suggestions (without those fields)
> - `OrchestratorSkill: DefaultAgentOrchestrator` is set in the Agent skill Settings

### Interactive Agent with Agent-to-Agent Communication (User & Device Investigation)

This real-world example demonstrates **agent-to-agent communication** within an interactive agent. A single manifest (`UserAndDeviceInvestigationAgents`) defines:
- **RiskyUserInvestigationAgent** — an interactive agent that investigates risky users and can delegate device investigation to a child agent
- **DeviceInvestigationAgent** — a child agent that performs comprehensive device security analysis

The parent interactive agent (`RiskyUserInvestigationAgent`) lists the child agent (`DeviceInvestigationAgent`) in its `ChildSkills`. Both agents are defined in the same manifest under separate `Format: Agent` SkillGroups. Both `AgentDefinitions` reference the same Descriptor name in `RequiredSkillsets`.

```yaml
Descriptor:
  Name: UserAndDeviceInvestigationAgents
  DisplayName: User and Device Investigation Agents
  Description: >-
    Performs comprehensive analysis of users at risk by retrieving detailed
    user risk information, suspicious activities, and behavioral patterns to
    provide security analysts with complete user risk assessment. Additionally,
    it generates detailed device security reports by analyzing device status.
  Icon: ''
  CatalogScope: UserWorkspace

AgentDefinitions:
  - Name: RiskyUserInvestigationAgent
    DisplayName: Risky User Investigation Agent
    Description: >-
      User risk analysis agent that investigates risky users through AAD risk
      signals, sign-in patterns, and identity information.
    Publisher: MarioCuomo
    Product: SecurityCopilot
    RequiredSkillsets:
      - Fusion
      - Sentinel
      - M365
      - Generic
      - ThreatIntelligence.DTI
      - MCP.MSDocs
      - UserAndDeviceInvestigationAgents   # Own manifest — to access inline skills AND the child agent
    AgentSingleInstanceConstraint: None
    Triggers:
      - Name: Default
        DefaultPollPeriodSeconds: 0
        ProcessSkill: UserAndDeviceInvestigationAgents.RiskyUserInvestigationAgent
    PromptSkill: UserAndDeviceInvestigationAgents.RiskyUserInvestigationAgent

  - Name: DeviceInvestigationAgent
    DisplayName: Device Investigation Agent
    Description: >-
      Device analysis agent that investigates device security status, compliance,
      and activity patterns through Defender for Endpoint data.
    Publisher: MarioCuomo
    Product: SecurityCopilot
    RequiredSkillsets:
      - Fusion
      - Sentinel
      - M365
      - Generic
      - ThreatIntelligence.DTI
      - MCP.MSDocs
      - UserAndDeviceInvestigationAgents
    Settings:
      - Name: DeviceName
        Description: The device name to investigate.
        Required: true
    AgentSingleInstanceConstraint: None
    Triggers:
      - Name: Default
        DefaultPollPeriodSeconds: 0
        ProcessSkill: UserAndDeviceInvestigationAgents.DeviceInvestigationAgent
        FetchSkill: ''

SkillGroups:
  # --- Parent Interactive Agent ---
  - Format: Agent
    Skills:
      - Name: RiskyUserInvestigationAgent
        DisplayName: Risky User Investigation Agent
        Description: Performs comprehensive analysis of users at risk.
        Interfaces:
          - InteractiveAgent
        Inputs:
          - Name: UserRequest
            Description: The analyst's request for user investigation.
            DefaultValue: ''
            Required: true
        SuggestedPrompts:
          - Prompt: Investigate risky user john.doe@company.com
            Title: User Risk Investigation
            Personas:
              - 3
            IsStarterAgent: true
          - Prompt: Investigate suspicious sign-in patterns for specific user
            Title: Sign-in Analysis
            Personas:
              - 3
            IsStarterAgent: true
          - Prompt: What are the current risk factors for this user?
          - Prompt: Show me recent risky events for this user
          - Prompt: Can you investigate the device LAPTOP-ABC123?
          - Prompt: How do I remediate a risky user according to Microsoft documentation?
        Settings:
          OrchestratorSkill: DefaultAgentOrchestrator
          Instructions: >
            # Mission
            You are an interactive Microsoft Azure AD identity risk analysis specialist.

            # Interactive Approach
            - Listen and respond to the analyst's specific questions
            - Ask clarifying questions when the request is ambiguous
            - Provide targeted answers rather than comprehensive reports
            - Offer follow-up suggestions based on findings

            # Available Investigation Skills
            - GetRiskyUserInformation: Current risk status
            - GetRiskyUserEvents: Historical risk events
            - GetUserSignInActivity: Recent sign-in patterns
            - GetUserIdentityInfo: Identity and organizational context
            - GetUserFailedSignIns: Failed authentication attempts
            - GetReputationsForIndicators: IP address reputation checks
            - microsoft_docs_search: Microsoft documentation search

            # Device Investigation (Agent-to-Agent)
            - DeviceInvestigationAgent: Delegate device analysis to a specialized child agent
            When the analyst asks about a device, call DeviceInvestigationAgent
            and present its complete report to the analyst.
        ChildSkills:
          - UserAndDeviceInvestigationAgents.GetRiskyUserInformation
          - UserAndDeviceInvestigationAgents.GetRiskyUserEvents
          - UserAndDeviceInvestigationAgents.GetUserSignInActivity
          - UserAndDeviceInvestigationAgents.GetUserIdentityInfo
          - UserAndDeviceInvestigationAgents.GetUserFailedSignIns
          - UserAndDeviceInvestigationAgents.DeviceInvestigationAgent    # <-- Agent-to-Agent!
          - microsoft_docs_search
          - GetReputationsForIndicators

  # --- Child Agent (called by parent) ---
  - Format: Agent
    Skills:
      - Name: DeviceInvestigationAgent
        DisplayName: Device Investigation Agent
        Description: Generates comprehensive device security reports.
        Inputs:
          - Name: DeviceName
            Description: The device name to investigate.
            DefaultValue: ''
            Required: true
        Settings:
          OrchestratorSkill: DefaultAgentOrchestrator
          Instructions: >
            # Mission
            You are a Microsoft Defender for Endpoint device analysis specialist.

            # Workflow
            1. Use GetDeviceName to resolve the actual DeviceName
            2. Gather device details using GetDeviceInfo and GetDefenderDeviceSummary
            3. Analyze security alerts using GetDeviceSecurityAlerts
            4. Review vulnerabilities using GetDeviceVulnerabilities
            5. Examine logon activity using GetDeviceLogonActivity
            6. Review network activity using GetDeviceNetworkActivity
            7. Search microsoft_docs_search for remediation guidance
            8. Compile findings into a structured report

            # Output
            - Executive Summary
            - Device Overview
            - Security Analysis
            - Vulnerability Assessment
            - Activity Analysis
            - Risk Assessment
            - Recommendations
        ChildSkills:
          - UserAndDeviceInvestigationAgents.GetDeviceName
          - UserAndDeviceInvestigationAgents.GetDeviceInfo
          - GetDefenderDeviceSummary
          - UserAndDeviceInvestigationAgents.GetDeviceSecurityAlerts
          - UserAndDeviceInvestigationAgents.GetDeviceVulnerabilities
          - UserAndDeviceInvestigationAgents.GetDeviceLogonActivity
          - UserAndDeviceInvestigationAgents.GetDeviceNetworkActivity
          - microsoft_docs_search

  # --- KQL skills used by both agents ---
  - Format: KQL
    Skills:
      - Name: GetRiskyUserInformation
        DisplayName: Get Risky User Information
        Description: Fetches risky user details from Azure AD.
        Inputs:
          - Name: useridentifier
            Description: User Principal Name (UPN) or Display Name
            Required: true
        Settings:
          Target: Sentinel
          Template: |-
            AADRiskyUsers
            | where UserPrincipalName == '{{useridentifier}}' or UserDisplayName == '{{useridentifier}}'
            | summarize arg_max(TimeGenerated, *) by UserPrincipalName
            | project TimeGenerated, UserPrincipalName, UserDisplayName, RiskLevel, RiskState,
                      RiskLastUpdatedDateTime, RiskDetail

      # ... additional KQL skills (GetRiskyUserEvents, GetUserSignInActivity, etc.)
      # ... device KQL skills (GetDeviceSecurityAlerts, GetDeviceVulnerabilities, etc.)
```

> **KEY POINTS for Interactive Agent-to-Agent**:
> - **Same manifest**: Both agents are defined in the same `Descriptor` (`UserAndDeviceInvestigationAgents`), with separate `AgentDefinitions` and separate `Format: Agent` SkillGroups
> - **Agent-to-Agent**: `RiskyUserInvestigationAgent` lists `UserAndDeviceInvestigationAgents.DeviceInvestigationAgent` in its `ChildSkills`
> - **Interactive parent, non-interactive child**: The parent is `InteractiveAgent` (with `UserRequest`, `SuggestedPrompts`, `PromptSkill`), while the child is a standard Agent skill with specific `Inputs`
> - **Delegated orchestration**: The parent's `Instructions` describe when to call the child agent and to present the child's complete report
> - **Shared KQL skills**: Both agents use KQL skills from the same manifest, each referencing them via `SkillsetName.SkillName`
> - **Multiple AgentDefinitions**: A single manifest can define multiple `AgentDefinitions`, each with its own triggers, settings, and `RequiredSkillsets`

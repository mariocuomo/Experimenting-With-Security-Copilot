# Mixed-Format Plugins (Multiple SkillGroups)

A single plugin can combine **multiple SkillGroups with different Formats**. This is useful when you want to group related skills that use different data sources or techniques under one plugin.

> **KEY CONCEPT**: The `Format` field is defined at the **SkillGroup level**, not at the plugin level. Each SkillGroup in the `SkillGroups` array can have a different `Format`. All skills within the same SkillGroup share the same Format and group-level Settings.

> **NOTE on Agents and GPT skills**: The mixed-format examples below show KQL+GPT combinations in **standalone plugins** (without an agent). When building an **agent**, do NOT create a separate GPT skill for report generation, summarization, or analysis — the agent handles these tasks natively via its `Instructions`. GPT SkillGroups in mixed-format plugins are appropriate only when there is no agent orchestrating the workflow (i.e., the GPT skill is invoked directly by the user or another prompt).

---

## Full Examples

### Mixed KQL + GPT Plugin (Incident Investigation)

```yaml
Descriptor:
  Name: IncidentInvestigationToolkit
  DisplayName: Incident Investigation Toolkit
  Description: >
    A comprehensive incident investigation plugin that combines KQL queries
    to gather data from Defender XDR and GPT skills to analyze and summarize findings.
  DescriptionForModel: >
    Use this plugin for incident investigation workflows. It provides KQL skills
    to retrieve alerts, device info, and sign-in data from Defender XDR, and GPT skills
    to generate summaries and recommendations based on the collected data.

SkillGroups:
  - Format: KQL
    Skills:
      - Name: GetIncidentAlerts
        DisplayName: Get Incident Alerts
        Description: Retrieves all alerts related to a specific incident from Defender XDR for the last 30 days.
        Inputs:
          - Name: incidentId
            Description: The incident ID to investigate
            Required: true
        Settings:
          Target: Defender
          Template: |-
            AlertInfo
            | where Timestamp > ago(30d)
            | where AttackTechniques != ""
            | join kind=inner (
                AlertEvidence
                | where Timestamp > ago(30d)
              ) on AlertId
            | project Timestamp, AlertId, Title, Severity, Category, AttackTechniques, EntityType, AccountUpn, DeviceName, RemoteIP
            | sort by Timestamp desc

      - Name: GetRelatedDeviceActivity
        DisplayName: Get Related Device Activity
        Description: Retrieves recent device activity for a specific device involved in an incident.
        Inputs:
          - Name: deviceName
            Description: The device name to investigate
            Required: true
        Settings:
          Target: Defender
          Template: |-
            let targetDevice = "{{deviceName}}";
            DeviceEvents
            | where Timestamp > ago(7d)
            | where DeviceName =~ targetDevice
            | summarize EventCount = count() by ActionType
            | sort by EventCount desc
            | take 20

  - Format: GPT
    Skills:
      - Name: GenerateIncidentSummary
        DisplayName: Generate Incident Summary
        Description: >
          Generates a structured incident summary report based on the investigation data
          collected in the current session. Run this after gathering alerts and device activity.
        Settings:
          ModelName: gpt-4o
          Template: |-
            Based on the incident investigation data collected in this session, generate a structured incident summary report with the following sections:

            1. **Incident Overview**: Brief summary of what happened, when, and which entities were involved.
            2. **Timeline**: Chronological sequence of events based on the alerts and evidence.
            3. **Affected Assets**: List of users, devices, and IP addresses involved.
            4. **Attack Techniques**: MITRE ATT&CK techniques identified, with brief explanations.
            5. **Severity Assessment**: Overall risk assessment based on the findings.
            6. **Recommended Actions**: Prioritized list of remediation and containment steps.

            Format the report in a clear, professional style suitable for sharing with management and the SOC team.
```

### Mixed KQL + API Plugin (Threat Intelligence)

```yaml
Descriptor:
  Name: ThreatIntelEnrichment
  DisplayName: Threat Intelligence Enrichment
  Description: >
    Combines internal Defender XDR data with external threat intelligence lookups.
    Uses KQL to extract IOCs from the environment and API calls to enrich them
    with external reputation data.
  DescriptionForModel: >
    Use this plugin to enrich threat intelligence. It extracts IOCs (IPs, domains, hashes)
    from Defender XDR via KQL and looks up their reputation via external APIs.
  SupportedAuthTypes:
    - ApiKey
  Authorization:
    Type: APIKey
    Key: x-apikey
    Location: Header
    AuthScheme: ''

SkillGroups:
  - Format: KQL
    Skills:
      - Name: ExtractSuspiciousIPs
        DisplayName: Extract Suspicious IPs
        Description: Extracts external IP addresses from Defender alerts in the last 7 days that may be malicious.
        Settings:
          Target: Defender
          Template: |-
            AlertEvidence
            | where Timestamp > ago(7d)
            | where EntityType == "Ip"
            | where isnotempty(RemoteIP)
            | summarize AlertCount = count(), Alerts = make_set(Title) by RemoteIP
            | sort by AlertCount desc
            | take 20

  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/ThreatIntel_API.yaml
```

> **NOTE on Authentication in Mixed-Format Plugins**: When a plugin contains both API and non-API skill groups (e.g., KQL + API), the `SupportedAuthTypes` and `Authorization` fields in the Descriptor apply to the API skill groups. KQL, GPT, LogicApp, MCP, and Agent skill groups do not require these authentication fields at the Descriptor level.

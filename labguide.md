# 🔬 Security Copilot Lab Guide

A hands-on, step-by-step guide to learning Microsoft Security Copilot custom plugins, integrations, and automations.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Lab Overview](#lab-overview)
3. [Day 1: KQL Plugins](#day-1-kql-plugins)
4. [Day 2: API Plugins](#day-2-api-plugins)
5. [Day 3: GPT and Logic App Plugins](#day-3-gpt-and-logic-app-plugins)
6. [Day 4: Automations](#day-4-automations)
7. [Day 5: MCP Server Integration](#day-5-mcp-server-integration)
8. [Advanced Labs](#advanced-labs)
9. [Monitoring & Operations](#monitoring--operations)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Access
- [ ] Microsoft Security Copilot license and access
- [ ] Azure subscription with appropriate permissions
- [ ] Microsoft Sentinel workspace (for KQL labs)
- [ ] Microsoft Defender XDR access (for Defender KQL labs)

### Recommended Tools
- [ ] Visual Studio Code with YAML extension
- [ ] Azure CLI installed and configured
- [ ] PowerShell 5.1+ (for monitoring scripts)

### Placeholder Configuration
Throughout these labs, you'll need to replace placeholders with your environment values:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `<YOUR_TENANT_ID>` | Azure AD Tenant ID | `12345678-1234-1234-1234-123456789abc` |
| `<YOUR_SUBSCRIPTION_ID>` | Azure Subscription ID | `87654321-4321-4321-4321-cba987654321` |
| `<YOUR_RESOURCE_GROUP_NAME>` | Resource Group name | `rg-sentinel-prod` |
| `<YOUR_WORKSPACE_NAME>` | Log Analytics Workspace name | `law-sentinel-prod` |
| `<YOUR_ADX_CLUSTER_ENDPOINT>` | ADX cluster URL | `https://mycluster.eastus.kusto.windows.net` |
| `<YOUR_ADX_DATABASE_NAME>` | ADX database name | `SecurityLogs` |

---

## Lab Overview

This lab series is organized as a **5-day skilling journey**, progressing from basic to advanced concepts:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Copilot Plugin Types                │
├─────────────────────────────────────────────────────────────────┤
│  Day 1: KQL        │  Query your security data                  │
│  Day 2: API        │  Integrate external services               │
│  Day 3: GPT/Logic  │  AI augmentation & workflows               │
│  Day 4: Automation │  End-to-end automated workflows            │
│  Day 5: MCP        │  Model Context Protocol servers            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Day 1: KQL Plugins

**Objective:** Learn to create plugins that execute KQL queries against Defender, Sentinel, and ADX.

### Lab 1.1: Defender KQL Plugin (Beginner)

**Time:** 15 minutes  
**File:** `skilling series/Day 1 - KQL/Defender_KQL/Defender_KQL.yaml`

#### Steps:

1. **Open the manifest file** and review the structure:
   ```yaml
   Descriptor:
     Name: DefenderDailyOperations
     DisplayName: Defender Daily Operations
     Description: XDR Scenarios for daily operations
   ```

2. **Understand the KQL settings:**
   ```yaml
   Settings:
     Target: Defender  # No additional config needed!
     Template: |-
       DeviceInfo
       | where ExposureLevel == 'High'
       | where Timestamp > ago(8h)
   ```

3. **Upload to Security Copilot:**
   - Navigate to Security Copilot → Settings → Plugins
   - Click "Add plugin" → "Custom plugin"
   - Upload `Defender_KQL.yaml`

4. **Test the plugin:**
   - In Security Copilot, type: *"Get Defender devices with high exposure"*
   - Verify results return device information

#### ✅ Success Criteria:
- Plugin uploads without errors
- Query returns device data from Defender XDR

---

### Lab 1.2: Sentinel KQL Plugin (Intermediate)

**Time:** 20 minutes  
**File:** `skilling series/Day 1 - KQL/Sentinel_KQL/Sentinel_KQL.yaml`

#### Steps:

1. **Configure your Sentinel workspace** by editing the manifest:
   ```yaml
   Settings:
     Target: Sentinel
     TenantId: <YOUR_TENANT_ID>
     SubscriptionId: <YOUR_SUBSCRIPTION_ID>
     ResourceGroupName: <YOUR_RESOURCE_GROUP_NAME>
     WorkspaceName: <YOUR_WORKSPACE_NAME>
   ```

2. **Review the cost estimation query:**
   ```kql
   // Cost rate: $4.30/GB - verify at https://azure.microsoft.com/pricing/details/microsoft-sentinel/
   let costPerGB = 4.3;
   Usage
   | where IsBillable == true 
   | where TimeGenerated between (ago(7d) .. now())
   | summarize size = sum(Quantity)/1024 by DataType
   | project ['Table Name'] = DataType, ['Estimated cost'] = size * costPerGB
   ```

3. **Upload and test:**
   - Upload the configured manifest
   - Ask: *"What are my Sentinel costs for the last 7 days?"*

#### ✅ Success Criteria:
- Query returns table-by-table cost breakdown
- Results show estimated costs in USD

---

### Lab 1.3: Parameterized KQL Plugin (Intermediate)

**Time:** 20 minutes  
**File:** `skilling series/Day 1 - KQL/Parameters_KQL/SentinelParameters_KQL.yaml`

#### Steps:

1. **Understand input parameters:**
   ```yaml
   Inputs:
     - Name: fromDateTime
       Description: The from time and date
       Required: true
     - Name: toDateTime
       Description: The to time and date
       Required: true
   ```

2. **See how parameters are used in the template:**
   ```kql
   let fromDateTime=todatetime('{{fromDateTime}}');
   let toDateTime=todatetime('{{toDateTime}}');
   ```

3. **Test with specific dates:**
   - Ask: *"Get Sentinel costs from January 1, 2026 to January 15, 2026"*

#### ✅ Success Criteria:
- Plugin prompts for date range or extracts from natural language
- Results are scoped to the specified time window

---

### Lab 1.4: Azure Data Explorer Plugin (Advanced)

**Time:** 25 minutes  
**File:** `skilling series/Day 1 - KQL/ADX_KQL/ADX_KQL.yaml`

#### Steps:

1. **Configure your ADX cluster:**
   ```yaml
   Settings:
     Target: Kusto
     Cluster: <YOUR_ADX_CLUSTER_ENDPOINT>
     Database: <YOUR_ADX_DATABASE_NAME>
   ```

2. **Review the parameterized IP hunting query:**
   ```kql
   let targetIP = '{{ipAddress}}';
   let lookback = {{lookbackDays}}d;
   SigninLogs
   | where TimeGenerated > ago(lookback)
   | where IPAddress == targetIP
   | summarize 
       SignInCount = count(),
       Users = make_set(UserPrincipalName, 50)
   ```

3. **Test historical investigation:**
   - Ask: *"Search ADX for sign-ins from IP 10.0.0.1 in the last 30 days"*

#### ✅ Success Criteria:
- Query executes against your ADX cluster
- Results include bounded aggregations (no timeouts)

---

## Day 2: API Plugins

**Objective:** Learn to create plugins that call external APIs with various authentication methods.

### Lab 2.1: No Authentication API (Beginner)

**Time:** 15 minutes  
**Files:** 
- `skilling series/Day 2 - API/NoAuth_API/NoAuth_API.yaml`

#### Steps:

1. **Review the OpenAPI specification:**
   ```yaml
   openapi: 3.0.0
   info:
     title: MD5 Hash Lookup API
   servers:
     - url: https://www.nitrxgen.net/
   paths:
     /md5db/{md5hash}.json:
       get:
         operationId: LookupMD5Hash
   ```

2. **Create a manifest that references the OpenAPI spec:**
   ```yaml
   Descriptor:
     Name: MD5Lookup
     SupportedAuthTypes:
       - None
   SkillGroups:
     - Format: API
       Settings:
         OpenApiSpecUrl: <URL_TO_YOUR_OPENAPI_SPEC>
   ```

3. **Test hash lookup:**
   - Ask: *"Look up MD5 hash 5d41402abc4b2a76b9719d911017c592"*

#### ✅ Success Criteria:
- API call executes without authentication
- Results show the hash lookup response

---

### Lab 2.2: API Key Authentication (Intermediate)

**Time:** 25 minutes  
**Files:**
- `skilling series/Day 2 - API/ApiKey_API/Manifest_ApiKey_API.yaml`
- `skilling series/Day 2 - API/ApiKey_API/ApiKey_API.yaml`

#### Steps:

1. **Get a VirusTotal API key** from [virustotal.com](https://www.virustotal.com)

2. **Review the authorization configuration:**
   ```yaml
   Descriptor:
     SupportedAuthTypes:
       - ApiKey
     Authorization:
       Type: ApiKey
       Key: x-apikey        # Header name
       Location: Header     # Where to send it
       AuthScheme: ''       # No prefix needed
   ```

3. **Upload the plugin** - Security Copilot will prompt for your API key

4. **Test threat intelligence lookups:**
   - *"Check domain example.com in VirusTotal"*
   - *"Get VirusTotal report for IP 8.8.8.8"*
   - *"Analyze file hash abc123... in VirusTotal"*

#### ✅ Success Criteria:
- Plugin prompts for API key on first use
- VirusTotal returns threat intelligence data

---

### Lab 2.3: Basic Authentication (Intermediate)

**Time:** 20 minutes  
**Files:** `skilling series/Day 2 - API/Basic_API/`

#### Steps:

1. **Review basic auth configuration:**
   ```yaml
   Authorization:
     Type: Basic
     Username: <will prompt>
     Password: <will prompt>
   ```

2. **Understand how credentials are sent:**
   - Base64 encoded as `Authorization: Basic <encoded>`

3. **Test with your own basic-auth protected API**

---

### Lab 2.4: OAuth/AAD Delegated (Advanced)

**Time:** 30 minutes  
**Files:** `skilling series/Day 2 - API/AADDelegated_API/`

#### Steps:

1. **Review the AAD Delegated flow:**
   ```yaml
   SupportedAuthTypes:
     - AADDelegated
   Authorization:
     Type: AADDelegated
     EntraScopes: https://graph.microsoft.com/.default
   ```

2. **Understand the flow:**
   - User authenticates via Microsoft Entra ID
   - Token acquired with user's delegated permissions
   - API called with bearer token

3. **Use case:** Call Microsoft Graph API as the signed-in user

---

### Lab 2.5: Writable API Plugin (Advanced)

**Time:** 25 minutes  
**Files:** `skilling series/Day 2 - API/Writable/`

#### Steps:

1. **Understand POST operations:**
   ```yaml
   paths:
     /api/isolate:
       post:
         operationId: IsolateMachine
   ```

2. **Security consideration:** Writable plugins can modify data!

3. **Test with caution** in non-production environments

---

## Day 3: GPT and Logic App Plugins

**Objective:** Augment Security Copilot with custom GPT prompts and Logic App workflows.

### Lab 3.1: GPT Plugin - Defang URLs (Beginner)

**Time:** 15 minutes  
**File:** `skilling series/Day 3 - GPT and LogicApp/SecuritySkill_GPT/Defang_GPT.yaml`

#### Steps:

1. **Review the GPT template:**
   ```yaml
   Settings:
     ModelName: gpt-4o
     Template: |-
       To 'defang' a URL means to change the scheme to hxxp/hxxps 
       and replace '.' with '[.]' in the domain...
       
       Defang any URLs in the following text:
       {{text}}
   ```

2. **Upload and test:**
   - Ask: *"Defang this URL: https://malicious-site.com/payload"*
   - Expected: `hxxps://malicious-site[.]com/payload`

#### ✅ Success Criteria:
- URLs are properly defanged
- Path dots are preserved (not replaced)

---

### Lab 3.2: GPT Plugin - Custom Incident Report (Intermediate)

**Time:** 20 minutes  
**File:** `skilling series/Day 3 - GPT and LogicApp/CustomIncidentReport_GPT/`

#### Concept:
Use session context to generate formatted reports based on previous investigation steps.

1. **First, investigate an incident** using standard prompts
2. **Then call the custom report skill** to format findings
3. **GPT uses session context** to create the report

---

### Lab 3.3: Logic App Plugin (Intermediate)

**Time:** 30 minutes  
**Files:** `skilling series/Day 3 - GPT and LogicApp/EmailStandard_LogicApp/`

#### Steps:

1. **Deploy the Logic App** to Azure

2. **Configure the plugin manifest:**
   ```yaml
   SkillGroups:
     - Format: LogicApp
       Skills:
         - Name: SendEmail
           Settings:
             SubscriptionId: <YOUR_SUBSCRIPTION_ID>
             ResourceGroup: <YOUR_RESOURCE_GROUP>
             WorkflowName: SendEmailWorkflow
             TriggerName: manual
   ```

3. **Test workflow triggering:**
   - Ask: *"Send an email to security@company.com with incident summary"*

#### ✅ Success Criteria:
- Logic App triggers successfully
- Email is sent with content from Security Copilot

---

## Day 4: Automations

**Objective:** Build end-to-end automated workflows using the Security Copilot Logic App connector.

### Lab 4.1: Security Copilot Connector (Intermediate)

**Time:** 30 minutes  
**Concept:** Use Logic Apps to automate Security Copilot interactions

#### Architecture:
```
┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   Trigger   │────▶│ Security Copilot│────▶│  Action/Output   │
│ (Schedule,  │     │   Connector     │     │  (Sentinel,      │
│  Incident)  │     │                 │     │   Email, etc.)   │
└─────────────┘     └─────────────────┘     └──────────────────┘
```

#### Connector Actions:
| Action | Description |
|--------|-------------|
| **Submit a prompt** | Send natural language to Security Copilot |
| **Run a promptbook** | Execute a predefined promptbook |

#### Key Parameters:
- `PromptContent` - The natural language prompt
- `SessionId` - Continue existing session (for multi-turn)
- `Skillsets` - Plugins to enable
- `SkillName` - Direct skill invocation
- `SkillInputs` - Parameters for the skill

---

### Lab 4.2: Automated Incident Analysis (Advanced)

**Time:** 45 minutes  
**File:** `integrations/Sentinel AI generated incident/deployment.json`

#### Steps:

1. **Deploy the Logic App:**
   ```bash
   az deployment group create \
     --resource-group <YOUR_RG> \
     --template-file deployment.json \
     --parameters \
       sentinelSubscriptionId=<SUB_ID> \
       sentinelResourceGroupName=<SENTINEL_RG> \
       sentinelWorkspaceName=<WORKSPACE>
   ```

2. **Review the workflow:**
   - Runs weekly (configurable)
   - Executes KQL to find risky users
   - Sends data to Security Copilot for analysis
   - Creates Sentinel incident with AI insights

3. **Enable and test:**
   - Enable the Logic App
   - Run manually or wait for scheduled trigger
   - Check Sentinel for new incident with tag `AIGENERATED`

#### ✅ Success Criteria:
- Incident created automatically
- AI-generated insights in incident comments

---

## Day 5: MCP Server Integration

**Objective:** Connect Security Copilot to Model Context Protocol (MCP) servers.

### Lab 5.1: Microsoft Learn MCP Server (Beginner)

**Time:** 15 minutes  
**File:** `skilling series/Day 5 - MCP/NoAuth_MCP/MSLearn_MCP.yaml`

#### Steps:

1. **Review the MCP plugin manifest:**
   ```yaml
   Descriptor:
     Name: MSLearnDocumentationMCPServer
     DescriptionForModel: >
       You have access to MCP tools called microsoft_docs_search 
       and microsoft_docs_fetch...
   SkillGroups:
     - Format: MCP
       Settings:
         Endpoint: https://learn.microsoft.com/api/mcp
         TimeoutInSeconds: 120
         AllowedTools: microsoft_docs_search, microsoft_docs_fetch
   ```

2. **Upload and test:**
   - Ask: *"Search Microsoft Learn for Sentinel analytics rules"*
   - Ask: *"Fetch the documentation for KQL time functions"*

#### ✅ Success Criteria:
- MCP tools appear as skills
- Documentation is retrieved and summarized

---

## Advanced Labs

### Custom Agents

**Time:** 45 minutes  
**File:** `custom agents/daily suggestion/dailySuggestion.yaml`

Build autonomous agents that combine multiple skills with orchestration logic.

#### Architecture:
```yaml
AgentDefinitions:
  - Name: SecurityDailySuggestionMS
    RequiredSkillsets:
      - MSLearnDocumentationMCPServer
      - RandomNumber
    Triggers:
      - Name: Default
        ProcessSkill: SecurityDailySuggestionAgentMS

SkillGroups:
  - Format: Agent
    Skills:
      - Name: SecurityDailySuggestionAgentMS
        Settings:
          Instructions: |-
            # Workflow
            1. Randomly select a topic using GetRandomNumber
            2. Call microsoft_docs_search for that topic
            3. Present actionable security tip
```

---

### Incident Graph Visualization

**Time:** 30 minutes  
**Files:** `integrations/IncidentGraph/`

Create visual incident diagrams using Mermaid syntax.

#### Workflow:
1. Investigate incident in Security Copilot
2. Call Mermaid Diagram plugin
3. Render interactive graph in browser

---

## Monitoring & Operations

### Lab: Manifest Validation

**Time:** 10 minutes  
**File:** `monitoring/Manifest Checker/Analysis.ps1`

Validate your plugin manifests before deployment:

```powershell
# Validate a manifest
.\Analysis.ps1 -script "path/to/manifest.yaml"

# The script checks:
# - Required keys (Name, Description, etc.)
# - Valid Format values (KQL, GPT, API, LogicApp)
# - Correct Settings for each format
# - Input parameter definitions
```

---

### Lab: SCU Consumption Analysis

**Time:** 20 minutes  
**Files:** `monitoring/Consumption Analysis Workbook/`

Track Security Copilot usage and costs:

1. **Export usage data** from Security Copilot portal
2. **Run the formatting script:**
   ```powershell
   .\formatUsageData.ps1
   ```
3. **Import to Sentinel watchlist**
4. **Deploy the workbook** for visualization

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Plugin won't upload | Validate YAML syntax; check required fields |
| KQL query timeout | Add `make_set()` limits; filter early |
| API returns 401 | Verify authentication configuration |
| Logic App not triggering | Check workflow is enabled; verify permissions |
| MCP tools not appearing | Check `AllowedTools` matches server capabilities |

### Validation Checklist

Before uploading any plugin:

- [ ] YAML syntax is valid (use a linter)
- [ ] All placeholders replaced with real values
- [ ] Required fields present (`Name`, `Description`, `DisplayName`)
- [ ] `DescriptionForModel` added for better LLM accuracy
- [ ] KQL queries have bounded aggregations
- [ ] API auth type matches `SupportedAuthTypes`

---

## Next Steps

1. **Explore the custom plugins folder** for production-ready examples
2. **Join the Security Copilot community** for updates
3. **Contribute back** - submit improvements via pull request!

---

> **Note:** This lab guide is based on community examples and is not officially maintained by Microsoft. Always verify configurations against official documentation.

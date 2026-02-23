# KQL Plugins

KQL plugins execute Kusto Query Language queries against different targets.

---

## Supported Targets

| Target | Description | Additional Settings |
|--------|-------------|---------------------|
| `Defender` | Microsoft Defender XDR - Advanced Hunting | None |
| `Sentinel` | Microsoft Sentinel | `TenantId`, `SubscriptionId`, `ResourceGroupName`, `WorkspaceName` |
| `SentinelDataLake` | Sentinel Data Lake | None |
| `LogAnalytics` | Log Analytics Workspace | Similar to Sentinel |
| `Kusto` | Azure Data Explorer (ADX) | `Cluster`, `Database` |

## KQL Settings

| Setting | Type | Description | Required |
|---------|------|-------------|----------|
| `Target` | string | One of: `Defender`, `Sentinel`, `SentinelDataLake`, `LogAnalytics`, `Kusto` | Yes |
| `Template` | string | Inline KQL query. Max 80,000 chars. | Yes (if no `TemplateUrl`) |
| `TemplateUrl` | string | Public URL to download the KQL template from. | Alternative to `Template` |
| `TenantId` | string | AAD tenant ID (Sentinel only). | Yes for Sentinel |
| `SubscriptionId` | string | Azure subscription ID (Sentinel only). | Yes for Sentinel |
| `ResourceGroupName` | string | Resource Group name (Sentinel only). | Yes for Sentinel |
| `WorkspaceName` | string | Sentinel workspace name. | Yes for Sentinel |
| `Cluster` | string | ADX cluster URL (Kusto only). | Yes for Kusto |
| `Database` | string | ADX database name (Kusto only). | Yes for Kusto |

## Using Parameters in KQL Queries

Parameters defined in `Inputs` are inserted into the template using the `{{parameterName}}` syntax.

---

## Live Schema Discovery for KQL Queries (MANDATORY)

> **CRITICAL**: Before writing ANY KQL query for a Defender or Sentinel plugin, the agent **MUST** use the live schema discovery tools described below to verify table names, column names, and column types. **Do NOT rely solely on static table/column lists** — always validate against the live schema.

Three tools are available:

### Tool 1: `FetchAdvancedHuntingTablesOverview`

**Purpose**: Get a high-level overview of all available Advanced Hunting tables (Defender XDR) with brief descriptions.

**When to use**:
- At the **beginning** of KQL plugin creation, to understand which tables are available
- When the user asks for a query and you need to identify the right table(s)
- To verify that a table name you intend to use actually exists

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tableNames` | array of strings | No | List of specific table names to filter. Pass an empty array `[]` to get ALL tables. |

**Example usage**:
- Pass `[]` → returns overview of ALL Advanced Hunting tables
- Pass `["AlertInfo", "AlertEvidence"]` → returns overview of only those two tables

### Tool 2: `FetchAdvancedHuntingTablesDetailedSchema`

**Purpose**: Get the **complete column schema** (column names, data types, descriptions) for one or more Advanced Hunting tables.

**When to use**:
- **After identifying the tables** you need (via Tool 1 or user request)
- **Before writing any KQL query** — to get the exact column names and types
- To validate that columns used in `project`, `where`, `summarize`, `extend`, `join on` actually exist
- To check column data types (string, datetime, dynamic, int, etc.) for correct filter syntax

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tableNames` | array of strings | Yes | List of table names to get detailed schema for. |

**Example usage**:
- Pass `["AlertInfo"]` → returns all columns of AlertInfo with types and descriptions
- Pass `["DeviceInfo", "DeviceEvents", "AlertEvidence"]` → returns schemas for all three tables

### Tool 3: `search_tables`

**Purpose**: Search Sentinel workspace tables by natural language query. Returns matching table schemas from the Sentinel data lake.

**When to use**:
- When the target is **Sentinel**, **SentinelDataLake**, or **LogAnalytics**
- When you need to find which Sentinel tables contain specific types of data
- To discover Sentinel-specific tables and their schemas

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Natural language description of the data you're looking for |
| `workspaceId` | string | No | Sentinel workspace ID to scope the search |

### Mandatory Workflow for KQL Query Authoring

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: DISCOVER TABLES                                       │
│                                                                │
│ If Target = Defender:                                          │
│   → Call FetchAdvancedHuntingTablesOverview with []             │
│                                                                │
│ If Target = Sentinel / SentinelDataLake / LogAnalytics:        │
│   → Call search_tables with a natural language query            │
│                                                                │
│ Outcome: identify which table(s) to query                      │
├─────────────────────────────────────────────────────────────────┤
│ STEP 2: GET DETAILED SCHEMA                                    │
│                                                                │
│ If Target = Defender:                                          │
│   → Call FetchAdvancedHuntingTablesDetailedSchema               │
│     with the table names identified in Step 1                  │
│                                                                │
│ If Target = Sentinel / SentinelDataLake / LogAnalytics:        │
│   → Use the schema returned by search_tables from Step 1       │
│                                                                │
│ Outcome: know exact column names, types, and descriptions      │
├─────────────────────────────────────────────────────────────────┤
│ STEP 3: WRITE THE KQL QUERY                                    │
│                                                                │
│ Using ONLY the validated table and column names from Steps 1-2 │
│                                                                │
│ Outcome: a KQL query that uses only real tables and columns    │
├─────────────────────────────────────────────────────────────────┤
│ STEP 4: VALIDATE (see BEST_PRACTICES.md)                       │
│                                                                │
│   → Run Syntactic Validation Checklist                         │
│   → Run Semantic Validation Checklist                          │
│   → Cross-reference every table/column against Step 2 schemas  │
│                                                                │
│ Outcome: a validated, production-ready KQL query                │
└─────────────────────────────────────────────────────────────────┘
```

> **IMPORTANT**: The static table and column lists in BEST_PRACTICES.md are a **fallback reference only**. The live schema tools are the **authoritative source of truth**.

---

## Template Formats

### Inline KQL Template
```yaml
Settings:
  Target: Defender
  Template: |-
    DeviceInfo
    | where ExposureLevel == 'High'
    | where Timestamp > ago(8h)
    | project DeviceName, DeviceCategory, OnboardingStatus
    | top 10 by Timestamp desc
```

### External KQL Template
```yaml
Settings:
  Target: Defender
  TemplateUrl: https://gist.githubusercontent.com/.../query.txt
```

---

## Full Examples

### KQL Defender (no parameters)
```yaml
Descriptor:
  Name: DefenderDailyOperations
  DisplayName: Defender Daily Operations
  Description: XDR Scenarios we use repeatedly for daily operations.

SkillGroups:
  - Format: KQL
    Skills:
      - Name: GetDefenderDevices
        DisplayName: Get Defender Devices
        Description: Get the top 10 devices from Defender based on device state, exposure etc for the last 8 hours
        Settings:
          Target: Defender
          Template: |-
            DeviceInfo
            | where ExposureLevel == 'High'
            | where Timestamp > ago(8h)
            | project DeviceName, DeviceCategory, OnboardingStatus, SensorHealthState, LoggedOnUsers, ExposureLevel, JoinType, Timestamp
            | top 10 by Timestamp desc

      - Name: GetAlertsCountByCategory
        DisplayName: Get count of Defender alerts by category
        Description: Get how many Defender alerts by category for the last 7 days
        Settings:
          Target: Defender
          Template: |-
            AlertInfo
            | where Timestamp > ago(7d)
            | summarize count() by Category
```

### KQL Sentinel (with parameters)
```yaml
Descriptor:
  Name: Summarize Sentinel Cost details for a specified time and date range.
  DisplayName: "Sentinel KQL: Sentinel Cost Details"
  Description: Skills that lookup recent Sentinel Cost Details from Sentinel workspace.

SkillGroups:
  - Format: KQL
    Skills:
      - Name: GetSentinelCostParametrized
        DisplayName: Get Sentinel Cost Parametrized
        Description: Fetches all the Sentinel Cost details for each table for the specified time and date range from Sentinel.
        Inputs:
          - Name: fromDateTime
            Description: The from time and date
            Required: true
          - Name: toDateTime
            Description: The to time and date
            Required: true
        Settings:
          Target: Sentinel
          TenantId: <YOUR-TENANT-ID>
          SubscriptionId: <YOUR-SUBSCRIPTION-ID>
          ResourceGroupName: <YOUR-RESOURCE-GROUP-NAME>
          WorkspaceName: <YOUR-WORKSPACE-NAME>
          Template: |-
            let fromDateTime=todatetime('{{fromDateTime}}');
            let toDateTime=todatetime('{{toDateTime}}');
            Usage
            | where IsBillable == true
            | where TimeGenerated between ( fromDateTime .. toDateTime )
            | where DataType <> "AzureDiagnostics"
            | summarize size = sum(Quantity)/1024, sizeOther = sumif(Quantity,(DataType !contains "_CL" and TimeGenerated between ( fromDateTime .. toDateTime )))/1024 by DataType
            | project ['Table Name'] = DataType, ['Table Size'] = size, ['Estimated cost'] = size*4.3
            | order by ['Estimated cost'] desc
            | take 20
```

### KQL Azure Data Explorer (ADX/Kusto)
```yaml
Descriptor:
  Name: InteractWithADX
  DisplayName: Plugin to interact with ADX corporate
  Description: Skills to interact with ADX corporate

SkillGroups:
  - Format: KQL
    Skills:
      - Name: HuntIPColdData
        DisplayName: Hunting IP historical data
        Description: Skill to search on cold storage on Azure Data Explorer
        Settings:
          Target: Kusto
          Cluster: <YOUR-ADX-CLUSTER-ENDPOINT>
          Database: <YOUR-ADX-DATABASE-NAME>
          Template: SigninLogs
```

### KQL with External Template
```yaml
Descriptor:
  Name: DefenderDailyOperationsViaTemplate
  DisplayName: Defender Daily Operations Via Template
  Description: XDR Scenarios we use repeatedly for daily operations via Template.

SkillGroups:
  - Format: KQL
    Skills:
      - Name: GetDefenderDevices
        DisplayName: Get Defender Devices
        Description: Get the top 10 devices from Defender based on device state, exposure etc for the last 8 hours
        Settings:
          Target: Defender
          TemplateUrl: https://gist.githubusercontent.com/user/id/raw/hash/query.txt
```

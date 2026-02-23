# MCP Plugins

MCP (Model Context Protocol) plugins allow Security Copilot to connect to external MCP Servers and use their tools as skills.

---

## MCP Settings

| Setting | Type | Description | Required |
|---------|------|-------------|----------|
| `Endpoint` | string | MCP Server endpoint URL. | Yes |
| `TimeoutInSeconds` | integer | Timeout in seconds for calls. | No (reasonable default) |
| `AllowedTools` | string | Comma-separated list of allowed MCP tools. | No (but recommended) |

---

## Full Example — MCP without authentication (Microsoft Learn)

```yaml
Descriptor:
  Name: MSLearnDocumentationMCPServer
  DisplayName: Microsoft Learn MCP Server developer reference documentation
  Description: Microsoft Learn MCP Server developer reference documentation
  DescriptionForModel: >
    You have access to MCP tools called `microsoft_docs_search` and `microsoft_docs_fetch`.
    These tools allow you to search through and fetch Microsoft's latest official documentation, and that information might be more detailed or newer than what's in your training data set.
    If a question includes a Microsoft product, service, or technology, you should leverage these tools

SkillGroups:
  - Format: MCP
    Settings:
      Endpoint: https://learn.microsoft.com/api/mcp
      TimeoutInSeconds: 120
      AllowedTools: microsoft_docs_search, microsoft_docs_fetch
```

> **NOTE on DescriptionForModel for MCP**: It's particularly important to provide a detailed `DescriptionForModel` for MCP plugins, as it guides the model on when and how to use the MCP tools.

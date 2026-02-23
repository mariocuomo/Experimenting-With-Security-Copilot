# LogicApp Plugins

LogicApp plugins trigger an Azure Logic App directly from Security Copilot. They are useful for:
- Sending emails
- Running complex workflows
- Interacting with external services not directly supported
- Write operations

---

## LogicApp Settings

| Setting | Type | Description | Required |
|---------|------|-------------|----------|
| `SubscriptionId` | string | Azure subscription ID of the Logic App. Must be in the same tenant as the Security Copilot user. | Yes |
| `ResourceGroup` | string | Resource Group where the Logic App resides. | Yes |
| `WorkflowName` | string | Name of the Logic App resource. | Yes |
| `TriggerName` | string | Name of the trigger in the Logic App. | Yes |

> **NOTE**: Parameters defined in `Inputs` are passed in the request body to the Logic App. The Logic App must have a Parse JSON action to extract parameters from the HTTP trigger body.

---

## Full Examples

### LogicApp without parameters (static email)
```yaml
Descriptor:
  Name: SendEmailStandard
  DisplayName: SendEmailStandard
  Description: This is a plugin to send a Heartbeat email via Logic App

SkillGroups:
  - Format: LogicApp
    Skills:
      - Name: SendEmailViaLogicAppStandard
        DisplayName: Send Email Via LogicApp Standard
        Description: Send a defined standard email to a defined email address
        Settings:
          SubscriptionId: <YOUR-SUBSCRIPTION-ID>
          ResourceGroup: <YOUR-RESOURCE-GROUP>
          WorkflowName: PluginLogicApp_EmailStandard
          TriggerName: manual
```

### LogicApp with parameters
```yaml
Descriptor:
  Name: NitrxLogicApp
  DisplayName: NitrxLogicApp
  Description: This is a look-up tool for typical unsalted MD5 cryptographic hashes

SkillGroups:
  - Format: LogicApp
    Skills:
      - Name: LookupMD5Hash
        DisplayName: LookupMD5Hash
        Description: Retrieves the original value of a given MD5 hash
        Inputs:
          - Name: md5hash
            Description: MD5 hash to lookup
            Required: true
        Settings:
          SubscriptionId: <YOUR-SUBSCRIPTION-ID>
          ResourceGroup: <YOUR-RESOURCE-GROUP>
          WorkflowName: PluginLogicApp_Nitrxgen
          TriggerName: manual
```

---

## ARM Template for Logic App (email sending example)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "emailAddress": {
      "defaultValue": "admin@contoso.com",
      "type": "String"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Web/connections",
      "apiVersion": "2016-06-01",
      "name": "office365",
      "location": "[resourceGroup().location]",
      "properties": {
        "displayName": "Office 365",
        "api": {
          "id": "[concat(subscription().id, '/providers/Microsoft.Web/locations/', resourceGroup().location, '/managedApis/', 'office365')]"
        }
      }
    },
    {
      "type": "Microsoft.Logic/workflows",
      "apiVersion": "2017-07-01",
      "name": "PluginLogicApp_EmailStandard",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Web/connections', 'office365')]"
      ],
      "properties": {
        "state": "Enabled",
        "definition": {
          "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
          "triggers": {
            "manual": {
              "type": "Request",
              "kind": "Http",
              "inputs": { "schema": {} }
            }
          },
          "actions": {
            "Send_an_email_(V2)": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['office365']['connectionId']"
                  }
                },
                "method": "post",
                "body": {
                  "To": "[parameters('emailAddress')]",
                  "Subject": "[TEST] Heartbeat email",
                  "Body": "<p>[TEST] Heartbeat email</p>",
                  "Importance": "Normal"
                },
                "path": "/v2/Mail"
              }
            }
          }
        }
      }
    }
  ]
}
```

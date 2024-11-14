# API plugin - Writable
This is an example of a plugin that performs a **GraphAPI** API call with OAuthClientCredentialsFlow Authentication. <br>
**API POST https://api.securitycenter.microsoft.com/api/machines/{id}/setDeviceValue**

## REQUIREMENTS
- It is necessary to **register an Enterprise Application** in Entra.
- Add the following **callback uri** https://securitycopilot.microsoft.com/auth/v1/callback.
- Add the following **Application Permissions**: _WindowsDefenderATP -> Machine.ReadWrite.All_ permissions to the application.
- Create an **Application Secret**

## SKILLS
| SkillName | Description |
|     :---         |     :---      |
| setDeviceValue | Set a device value (Low, Medium, High)  |

---
## SCREENSHOTS
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_writable_example.png" width="600"> </img>
</div>

> [!WARNING]  
> Remember to change the **TokenEndpoint** value with your TenantID <br>
> **Scopes** is https://api.securitycenter.microsoft.com/.default



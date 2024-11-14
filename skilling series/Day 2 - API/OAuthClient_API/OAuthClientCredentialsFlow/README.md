# API plugin - OAuth Authentication (OAuthClientCredentialsFlow)
This is like _Basic Auth_ but used for server-to-server communication instead or when accessing public data that doesn't require user-specific permissions.	
This is an example of a plugin that performs a **GraphAPI** API call with OAuthClientCredentialsFlow Authentication. <br>
**API GET https://graph.microsoft.com/v1.0/users**

## REQUIREMENTS
- It is necessary to **register an Enterprise Application** in Entra.
- Add the following **callback uri** https://securitycopilot.microsoft.com/auth/v1/callback.
- Add the following **Application Permissions**: _Microsoft Graph -> User.Read and User.Read.All_ permissions to the application.
- Create an **Application Secret**

## SKILLS
| SkillName | Description |
|     :---         |     :---      |
| GetUsers | List all Users in Entra  |

---
## SCREENSHOTS
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/oauthcredentials.png" width="600"> </img>
</div>

> [!WARNING]  
> **clientId** is you Enterprise App clientId <br>
> **clientSecret** is the secret generated <br>
> **Scopes** is https://graph.microsoft.com/.default <br>

> [!WARNING]  
> Remember to change the **TokenEndpoint** value with your TenantID


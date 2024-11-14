# API plugin - OAuth Authentication (OAuthAuthorizationCodeFlow)
OAuth 2.0 Authorization Code Flow is a more secure and complex authentication method used to grant access to non-Microsoft applications without sharing user credentials.
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
> **Scopes** is offline_access User.Read.All <br>
The **offline_access** scope gives your app access to resources on behalf of the user for an extended time. On the consent page, this scope appears as the Maintain access to data you have given it access to permission.

> [!WARNING]  
> Remember to change the **TokenEndpoint** and **AuthorizationEndpoint** value with your TenantID


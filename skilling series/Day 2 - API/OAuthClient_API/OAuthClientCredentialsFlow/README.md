# API plugin - OAuth Authentication (OAuthClientCredentialsFlow)
This is like _Basic Auth_ but used for server-to-server communication instead or when accessing public data that doesn't require user-specific permissions.	
This is an example of a plugin that performs a **GraphAPI** API call with OAuthClientCredentialsFlow Authentication. <br>
**API GET https://graph.microsoft.com/v1.0/users**

## REQUIREMENTS
- It necessary to **register an Enterprise Application** in Entra.
- Add the following **callback uri** https://securitycopilot.microsoft.com/auth/v1/callback.
- Add the following **Application Permissions**: _Microsoft Graph -> User.Read and User.Read.All_ permissions to the application.
- Create an **Application Secret**


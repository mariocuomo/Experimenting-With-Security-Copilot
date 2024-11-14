# API plugin - OAuth Authentication
The **OAuth 2.0 authorization framework** enables a third-party application to obtain limited access to an HTTP service, either on behalf of a resource owner by orchestrating an approval interaction between the resource owner and the HTTP service, or by allowing the third-party application to obtain access on its own behalf.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/oauth.png" width="1000"> </img>
</div>

Microsoft Security Copilot offers two distinct authentication and authorization schemes for OAuth 2 that are **OAuthAuthorizationCodeFlow** and **OAuthClientCredentialsFlow**.

**User Involvement** <br>
_OAuthAuthorizationCodeFlow_: Requires user interaction for authentication. <br>
_OAuthClientCredentialsFlow_: No user interaction required. <br>

**Use Case** <br>
_OAuthAuthorizationCodeFlow_: Ideal for applications that need to access resources on behalf of a user. <br>
_OAuthClientCredentialsFlow_: Suitable for server-to-server interactions where the application itself needs to authenticate. <br>

**Security** <br>
_OAuthAuthorizationCodeFlow_: More secure as it involves user authentication and authorization. <br>
_OAuthClientCredentialsFlow_: Relies on the application's credentials, making it suitable for background services and daemons. <br>

This folder contains two examples:
- [OAuthAuthorizationCodeFlow](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/OAuthClient_API/OAuthAuthorizationCodeFlow)
- [OAuthClientCredentialsFlow](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/OAuthClient_API/OAuthClientCredentialsFlow)

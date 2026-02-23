# Authentication

> Complete reference for all authentication types supported by Security Copilot custom plugins.

---

## Supported Authentication Types

| Type | Description | File Upload | URL Upload |
|------|-------------|-------------|------------|
| `None` | No authentication | Yes | Yes |
| `Basic` | Username and password | Yes | No |
| `ApiKey` | API key in header or query parameter | Yes | Yes* |
| `ServiceHttp` | Provided token | Yes | Yes |
| `OAuthAuthorizationCodeFlow` | OAuth 2.0 Authorization Code (interactive user) | Yes | Yes |
| `OAuthClientCredentialsFlow` | OAuth 2.0 Client Credentials (server-to-server) | Yes | No |
| `AAD` | Microsoft Entra ID — application only | Yes | Yes* |
| `AADDelegated` | Microsoft Entra ID — user + application | Yes | Yes* |

---

## Configuration by Type

### None
```yaml
Descriptor:
  Name: MyPlugin
  SupportedAuthTypes:
    - None
```

### Basic
```yaml
Descriptor:
  Name: MyPlugin
  SupportedAuthTypes:
    - Basic
```
> The user will enter username and password at installation time.

### ApiKey
```yaml
Descriptor:
  Name: MyPlugin
  SupportedAuthTypes:
    - ApiKey
  Authorization:
    Type: APIKey
    Key: x-apikey              # Name of the header or query parameter
    Location: Header           # Header | QueryParams
    AuthScheme: ''             # '' | Bearer | Basic
```
> The user will enter the API key value at installation time.

### AAD (application only)
```yaml
Descriptor:
  Name: MyPlugin
  SupportedAuthTypes:
    - AAD
  Authorization:
    Type: AAD
    EntraScopes: https://graph.microsoft.com/.default
```

### AADDelegated (user + application)
```yaml
Descriptor:
  Name: MyPlugin
  SupportedAuthTypes:
    - AADDelegated
  Authorization:
    Type: AADDelegated
    EntraScopes: https://graph.microsoft.com/.default
```

### OAuthAuthorizationCodeFlow
```yaml
Descriptor:
  Name: MyPlugin
  Authorization:
    Type: OAuthAuthorizationCodeFlow
    ClientId: <CLIENT-ID>
    AuthorizationEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/authorize
    TokenEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/token
    Scopes: <SCOPES>
    AuthorizationContentType: application/x-www-form-urlencoded
```
> **Requirements**: Register an Enterprise Application in Entra, add callback URI `https://securitycopilot.microsoft.com/auth/v1/callback`, create an Application Secret.
> **Typical Scopes**: `offline_access User.Read.All`

### OAuthClientCredentialsFlow
```yaml
Descriptor:
  Name: MyPlugin
  Authorization:
    Type: OAuthClientCredentialsFlow
    TokenEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/token
    AuthorizationContentType: application/x-www-form-urlencoded
```
> **Typical Scopes**: `https://graph.microsoft.com/.default` or `https://api.securitycenter.microsoft.com/.default`

---

## Authentication Fields Summary

| Auth Type | Fields |
|-----------|--------|
| AAD / AADDelegated | `EntraScopes` |
| Basic | `Username`, `Password` (entered by user) |
| ApiKey | `Key`, `AuthScheme`, `Location`, `Value` |
| ServiceHttp | `AccessToken` |
| OAuthAuthorizationCodeFlow | `TokenEndpoint`, `AuthorizationEndpoint`, `Scopes`, `ClientId`, `ClientSecret`, `AuthorizationContentType` |
| OAuthClientCredentialsFlow | `TokenEndpoint`, `Scopes`, `ClientId`, `ClientSecret`, `AuthorizationContentType` |

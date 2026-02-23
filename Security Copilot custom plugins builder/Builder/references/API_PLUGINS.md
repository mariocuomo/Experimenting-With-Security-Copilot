# API Plugins

API plugins call external REST endpoints. They require **two files**:
1. **Manifest YAML** — Descriptor + authentication + reference to the OpenAPI spec
2. **OpenAPI Specification YAML** (OpenAPI 3.0 or 3.0.1) — Describes the API endpoints

---

## API Manifest Structure

```yaml
Descriptor:
  Name: <PluginName>
  DisplayName: <UserFacingName>
  Description: <Description>
  SupportedAuthTypes:
    - <AuthType>                    # None | Basic | ApiKey | AAD | AADDelegated | OAuthAuthorizationCodeFlow | OAuthClientCredentialsFlow
  Authorization:
    Type: <AuthType>
    # ... type-specific fields (see AUTHENTICATION.md)

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: <URL-to-the-OpenAPI-spec>
```

## API Settings

| Setting | Type | Description | Required |
|---------|------|-------------|----------|
| `OpenApiSpecUrl` | string | Public URL of the OpenAPI specification. | Yes |
| `EndpointUrl` | string | Endpoint URL (if different from the spec). | No |
| `EndpointUrlSettingName` | string | Name of the configurable setting for the URL. | No |

## OpenAPI Specification Structure

```yaml
openapi: 3.0.0
info:
  title: <API Title>
  description: <Description>
  version: "<version>"
servers:
  - url: <service-base-URL>
paths:
  /<endpoint-path>:
    get:                              # or post
      operationId: <UniqueOperationName>
      summary: <Short description>
      description: |
        Detailed description.
        #ExamplePrompts Example prompt 1
        #ExamplePrompts Example prompt 2
      parameters:
        - in: path                    # or query, header
          name: <parameterName>
          schema:
            type: string
          required: true
          description: <Parameter description>
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  # ... response schema
```

## Supported HTTP Methods

- **GET** — For retrieving data
- **POST** — For sending data (also supported for write operations)

> **NOTE**: Security Copilot only supports GET and POST. For other HTTP methods (PUT, PATCH, DELETE), use a broker pattern or Logic App.

## ExamplePrompts

Example prompts can be placed in the operation `description` with the `#ExamplePrompts` tag or as a separate field:
```yaml
ExamplePrompt:
  - 'show me alert ids for the specified incident id'
  - 'Get me all alert ids where incident id is provided'
```

## User-Configurable Endpoint URL

```yaml
Descriptor:
  Name: Example
  Settings:
    - Name: InstanceURL
      Label: Instance URL
      Description: The URL of the instance to connect to
      HintText: "e.g. https://example.com"
      SettingType: String
      Required: true

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecURL: https://example.com/openapi.json
      EndpointUrlSettingName: InstanceURL
```

## Broker Pattern

The **broker pattern** places an intermediary (Azure Function, Logic App, App Service) between Security Copilot and the target service. Benefits:
- **API masking**: hides the final endpoint from Security Copilot
- **Business Logic**: adds audit, security layers, additional operations
- **Integration**: supports HTTP methods not natively supported (PUT, PATCH, DELETE)

---

## Full Examples

### API with No Authentication
**Manifest:**
```yaml
Descriptor:
  Name: Nitrix
  DisplayName: Nitrix
  Description: This is a look-up tool for typical unsalted MD5 cryptographic hashes
  SupportedAuthTypes:
    - None

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/NoAuth_API.yaml
```

**OpenAPI Spec:**
```yaml
openapi: 3.0.0
info:
  title: MD5 Hash Lookup API
  version: "1.0"
servers:
  - url: https://www.nitrxgen.net/
paths:
  /md5db/{md5hash}.json:
    get:
      operationId: LookupMD5Hash
      summary: Retrieves the original value of a given MD5 hash
      parameters:
        - in: path
          name: md5hash
          schema:
            type: string
          required: true
          description: The MD5 hash to look up
      responses:
        "200":
          description: Information about the hash
          content:
            application/json:
              schema:
                type: object
                properties:
                  result:
                    type: object
                    properties:
                      found:
                        type: boolean
                      hash:
                        type: string
                      pass:
                        type: string
```

### API with ApiKey (VirusTotal)
**Manifest:**
```yaml
Descriptor:
  Name: VirusTotalReports
  DisplayName: Virus Total Reports
  Description: Skills for looking up reports using the Free Virus Total API
  SupportedAuthTypes:
    - ApiKey
  Authorization:
    Type: APIKey
    Key: x-apikey
    Location: Header
    AuthScheme: ''

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/ApiKey_API.yaml
```

**OpenAPI Spec:**
```yaml
openapi: 3.0.0
info:
  title: Virus Total Reports
  description: Virus Total Reports
  version: "v2"
servers:
  - url: https://www.virustotal.com/
paths:
  /api/v3/domains/{domain}:
    get:
      operationId: VTDomainReport
      summary: Lookup domain information
      parameters:
        - in: path
          name: domain
          schema:
            type: string
          required: true
          description: The domain address to lookup
      responses:
        "200":
          description: OK
  /api/v3/ip_addresses/{ip}:
    get:
      operationId: VTIPReport
      summary: Lookup IP information
      parameters:
        - in: path
          name: ip
          schema:
            type: string
          required: true
          description: The IP address to lookup
      responses:
        "200":
          description: OK
  /api/v3/files/{id}:
    get:
      operationId: VTFileReport
      summary: Submit a File Hash for Reporting
      parameters:
        - in: path
          name: id
          schema:
            type: string
          required: true
          description: The File Hash (SHA-256, SHA-1 or MD5) to report
      responses:
        "200":
          description: OK
        "400":
          description: No File found
```

### API with Basic Auth (Censys)
**Manifest:**
```yaml
Descriptor:
  Name: Censys
  DisplayName: Censys
  Description: Censys is a platform that helps information security practitioners discover, monitor, and analyze devices accessible from the Internet.
  SupportedAuthTypes:
    - Basic

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/Basic_API.yaml
```

**OpenAPI Spec:**
```yaml
openapi: 3.0.0
info:
  title: Censys
  description: Censys is a platform that helps information security practitioners discover, monitor, and analyze devices accessible from the Internet.
  version: "1.0"
servers:
  - url: https://search.censys.io/api/
paths:
  /v2/hosts/{ip}:
    get:
      operationId: CensysHosts
      summary: Fetches the entire host entity by IP address and returns the most recent Censys view of the host and its services.
      parameters:
        - in: path
          name: ip
          schema:
            type: string
          required: true
      responses:
        200:
          description: Successful response.
```

### API with AADDelegated (Microsoft Graph)
**Manifest:**
```yaml
Descriptor:
  Name: AADDelegatedDefenderAlertDetailsPlugin
  DisplayName: AADDelegated Defender Specific Alert Details Plugin
  Description: Skills to get Defender alert details via Graph API Call
  DescriptionForModel: Skills to get specific defender alert details based on provided incident or alert id.
  SupportedAuthTypes:
    - AADDelegated
  Authorization:
    Type: AADDelegated
    EntraScopes: https://graph.microsoft.com/.default

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/AADDelegated_API.yaml
```

**OpenAPI Spec:**
```yaml
openapi: 3.0.0
info:
  title: Defender Specific Alert Details Plugin
  description: Skills for getting alert details via Graph API Call
  version: "v1"
servers:
  - url: https://graph.microsoft.com/v1.0/security
paths:
  /alerts_v2?$select=id,title:
    get:
      operationId: GetAlertIdsFromIncidentIdAADDelegated
      description: List all alert id's based on a user provided incident id
      ExamplePrompt:
        - 'show me alert ids for the specified incident id'
        - 'Get me all alert ids where incident id is provided'
      parameters:
        - in: query
          name: $filter
          schema:
            type: string
          required: true
          description: A filter in the format of "incidentid eq id" where ID is an incident ID provided by the user.
      responses:
        "200":
          description: OK
          content:
            application/json:
```

> **AADDelegated permissions**: Security Copilot uses its own Enterprise Application (Medeina Service, Client ID: `bb3d68c2-d09e-4455-94a0-e323996dbaa3`). The final permission set is the intersection of the application's permissions and the user's own permissions.

### API with OAuthAuthorizationCodeFlow
**Manifest:**
```yaml
Descriptor:
  Name: ListOfUserGraphViaOAuth
  DisplayName: List Of User Graph via OAuth Plugin
  Description: The skills in this plugin will help get list Of User Graph via OAuth
  DescriptionForModel: The skills in this plugin will help get list Of User Graph via OAuth
  Authorization:
    Type: OAuthAuthorizationCodeFlow
    AuthorizationEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/authorize
    TokenEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/token
    AuthorizationContentType: application/x-www-form-urlencoded

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/OAuth_API.yaml
```

> **NOTE**: The user must provide `ClientId`, `ClientSecret`, and `Scopes` at installation time.
> **Callback URI**: `https://securitycopilot.microsoft.com/auth/v1/callback`
> **Typical Scopes**: `offline_access User.Read.All`

### API with OAuthClientCredentialsFlow
**Manifest:**
```yaml
Descriptor:
  Name: ListOfUserGraphViaOAuth
  DisplayName: List Of User Graph via OAuth Plugin
  Description: The skills in this plugin will help get list Of User Graph via OAuth
  DescriptionForModel: The skills in this plugin will help get list Of User Graph via OAuth
  Authorization:
    Type: OAuthClientCredentialsFlow
    TokenEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/token
    AuthorizationContentType: application/x-www-form-urlencoded

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/OAuth_API.yaml
```

### Writable API (POST with OAuthClientCredentialsFlow)
**Manifest:**
```yaml
Descriptor:
  Name: WritablePlugin
  DisplayName: WritablePlugin
  Description: Plugin to set Device Value in MDE
  Authorization:
    Type: OAuthClientCredentialsFlow
    TokenEndpoint: https://login.microsoftonline.com/<TENANT-ID>/oauth2/v2.0/token
    AuthorizationContentType: application/x-www-form-urlencoded

SkillGroups:
  - Format: API
    Settings:
      OpenApiSpecUrl: https://example.com/MDE_Writable.yaml
```

**OpenAPI Spec (with POST and requestBody):**
```yaml
openapi: 3.0.0
info:
  title: Microsoft Defender for Endpoint API
  version: 1.0.0
  description: API to set device value in Microsoft Defender for Endpoint.
servers:
  - url: https://api.securitycenter.microsoft.com
paths:
  /api/machines/{id}/setDeviceValue:
    post:
      summary: Set a device value.
      operationId: setDeviceValue
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
          description: The ID of the device
      requestBody:
        description: Device value object that needs to be set
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                DeviceValue:
                  type: string
                  description: The value to set for the device (Low, Medium, High)
      responses:
        '200':
          description: Device value set successfully
        '400':
          description: Bad request
        '401':
          description: Unauthorized
```

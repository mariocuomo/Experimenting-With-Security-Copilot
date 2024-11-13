# Skilling Series - API plugins

**Security Copilot** custom plugins allow you to perform API call to third party services.<br>
(Nov 2023) the only available HTTP methods are **GET** and **POST**. <br>

API calls are performed to achieve different uses cases:
- Retrieve Data from a Microsoft service
- Retrieve Data from a 3rd party service
- Post Data into another service
- Execute external workflow

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/KQL%20plugins.png" width="200"> </img>
</div>


This folder contains different example:
- [NoAuth_API](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/NoAuth_API) <br>
  Manifest and OpenAPI specification files to perform an API call without authentication
- [Basic_API](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/Basic_API) <br>
  Manifest and OpenAPI specification files to perform an API call with basic authentication (username and password)
- [ApiKey_API](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/ApiKey_API) <br>
  Manifest and OpenAPI specification files to perform an API call with authentication in the header
- [AADDelegated_API](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/AADDelegated_API) <br>
  Manifest and OpenAPI specification files to perform an API call with AADDelegated
- [OAuthClient_API](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/OAuthClient_API) <br>
  Manifest and OpenAPI specification files to perform an API call with OAuthAuthenticationworkflow
- [Writable](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/Writable) <br>
  Manifest and OpenAPI specification files to perform a post API call (_writable plugins_)
- [Broker_API](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/Broker_API) <br>
  Manifest and OpenAPI specification files to showcase a _broker architecture_




# API plugin - Writable
Writable plugins are a concept. <br>
A **writable plugin** is any plugin that is capable of performing write actions in your environment. <br>
There are no writable plugins built-in to Security Copilot, but they can be easily created with one of the following methods:
- [Broker architecture](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/Broker_API)
- [OAuth authentication](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/OAuthClient_API)
- Logic App plugin

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_writable.png" width="800"> </img>
</div>

Some use cases:
- send an email directly with a prompt
- submit an incident summary
- apply governance actions against users/devices/applications

This folder contains a writable plugin example to change the [Microsoft Defender Vulnerability Management Device Value](https://learn.microsoft.com/en-us/defender-vulnerability-management/tvm-assign-device-value) via prompt - using OAuthClientCredentialsFlow. 
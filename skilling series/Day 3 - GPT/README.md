# Skilling Series - GPT and LogicApp plugins

**Security Copilot** custom plugins allow you to interact directly with GPT knowledge.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_broker.png" width="1000"> </img>
</div>

There are at least 3 good reasons to interact with Azure Open AI with a custom plugin:
- **Context (PAST)** <br>
In the natural language prompt, you can reference past information and reference session context. See the custom incident report custom plugin.
- **Context (Future)** <br>
The GPT response can be used by subsequent prompts.
- **Easy to do** <br>
The integration is ready, there is no need to create your own Azure OpenAI instance, define access, do auditing, etc.

This folder contains two examples:
- [Defender_KQL](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%201%20-%20KQL/Defender_KQL) <br>
  Manifest to perform KQL query against Advanced Hunting Tables
- [Sentinel_KQL](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%201%20-%20KQL/Sentinel_KQL) <br>
  Manifest to perform KQL query against Sentinel instance
- [ADX_KQL](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%201%20-%20KQL/ADX_KQL) <br>
  Manifest to perform KQL query against Azure Data Explorer
- [ExternalTemplate_KQL](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%201%20-%20KQL/ExternalTemplate_KQL) <br>
  Manifest to perform KQL query based on an external template
- [Parameters_KQL](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%201%20-%20KQL/Parameters_KQL) <br>
  Manifest to perform different KQL queries based on parameters



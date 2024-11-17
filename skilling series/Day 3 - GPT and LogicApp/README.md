# Skilling Series - GPT and LogicApp plugins


## GPT
**Security Copilot** custom plugins allow you to interact directly with GPT knowledge.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/GPT%20plugins.png" width="800"> </img>
</div>

There are at least 3 good reasons to interact with Azure Open AI with a custom plugin:
- **Context (Past)** <br>
In the natural language prompt, you can reference past information and reference session context. See the custom incident report custom plugin.
- **Context (Future)** <br>
The GPT response can be used by subsequent prompts.
- **Easy to integrate** <br>
The integration is ready, there is no need to create your own Azure OpenAI instance, define access, do auditing, etc.

This folder contains 2 example of GPT plugin:
- [Custom Incident Report](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%203%20-%20GPT%20and%20LogicApp/CustomIncidentReport_GPT) <br>
  GPT Skill to create a custom incident report that is based on the previous investigation
- [DefangUrls](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%203%20-%20GPT%20and%20LogicApp/SecuritySkill_GPT) <br>
  GPT Skill to defang a URL (explained in the official [GitHub repo](https://github.com/Azure/Copilot-For-Security/tree/main/Technical%20Workshops/Custom%20Plugin%20Workshop/Task02_Defang_URL))
  

## Logic App
TBD
# Send an email with Security Copilot - Logic App plugin

This plugin is simply for illustrative purposes of how to trigger a Logic App from Security Copilot. <br>
Simply what you do is define the following information in the plugin manifest:

- **SubscriptionId**
- **ResourceGroup**
- **WorkflowName**
- **TriggerName**

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/logicapp_sendemail.png" width="800"> </img>
</div>

---
To test this plugin you need to deploy the Logic App. <br>
After the deployment you shoul see a new Logic App named **PluginLogicApp_EmailStandard**.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmariocuomo%2FExperimenting-With-Security-Copilot%2Frefs%2Fheads%2Fmain%2Fskilling%20series%2FDay%203%20-%20GPT%20and%20LogicApp%2FEmailStandard_LogicApp%2Fdeployment.json" target="_blank">
<img src="https://aka.ms/deploytoazurebutton"/>
</a>


# Lookup external data with Logic App plugin

This plugin example shows how to pass parameters to a Logic App. The Logic App looks up an MD5Hash on Nitrxgen. The same example but with a plugin API is shown [here](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/skilling%20series/Day%202%20-%20API/NoAuth_API).

Simply what you do is define the following information in the plugin manifest:

- **Inputs**
- **SubscriptionId**
- **ResourceGroup**
- **WorkflowName**
- **TriggerName**

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/logicapp_nitrixgen.png" width="800"> </img>
</div>

Note how the *md5hash* parameter is passed in the request body.


<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/logicapp_nitrixgenskill.png" width="1000"> </img>
</div>

---

To test this plugin you need to deploy the Logic App. <br>
After the deployment you shoul see a new Logic App named **PluginLogicApp_Nitrxgen**.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmariocuomo%2FExperimenting-With-Security-Copilot%2Frefs%2Fheads%2Fmain%2Fskilling%20series%2FDay%203%20-%20GPT%20and%20LogicApp%2FNitrxgend_LogicApp%2Fdeployment.json" target="_blank">
<img src="https://aka.ms/deploytoazurebutton"/>
</a>

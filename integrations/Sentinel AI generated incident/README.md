# Sentinel AI Generated incident
version: _1.0_

Sections in this page
- [What is](#WHAT) <br>
- [Schema](#SCHEMA) <br>
- [Deploy](#DEPLOY) <br>
- [Considerations](#CONSIDERATIONS) <br>


# What is
<a name="WHAT"></a>
This is a simple experiment of creating a Sentinel Incident after Security Copilot investigation and analysis. The idea is to create an _informational_ incident based insights detected by Security Copilot. <br>
I was inspired by this blog post [Accelerating the Anomalous Sign-Ins detection with Microsoft Entra ID and Security Copilot](https://techcommunity.microsoft.com/blog/securitycopilotblog/accelerating-the-anomalous-sign-ins-detection-with-microsoft-entra-id-and-securi/4365435).

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/SecurityCopilotIncidentGeneration/result.png" width="1000"> </img>
</div>


# Schema
<a name="SCHEMA"></a>
The solution is composed of two main parts:
- a Security Copilot plugin to retrieve data using a KQL query and a Security Copilot prompt to analyse them to find anomalies
- a scheduled Logic App to interact with Security Copilot and create Sentinel Incident

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/SecurityCopilotIncidentGeneration/schema.png" width="900"> </img>
</div>

The workflow is simple:
1. Every week <br>

2. Execute KQL query to retrieve logs from **AADUserRiskEvents** table.
`AADUserRiskEvents | where TimeGenerated > ago(7d) | project UserPrincipalName, TimeGenerated, Location, IpAddress, RiskState, Id, RiskEventType; riskyusers | join kind=inner ( riskyusers | extend TimeGenerated1 = TimeGenerated, LocationDetails1 = Location ) on UserPrincipalName | where TimeGenerated < TimeGenerated1 and datetime_diff('hour', TimeGenerated1, TimeGenerated) <= 3 | extend latyy = Location.geoCoordinates.latitude | extend longy= Location.geoCoordinates.longitude | extend latyy1 = LocationDetails1.geoCoordinates.latitude | extend longy1 = LocationDetails1.geoCoordinates.longitude | extend distance = geo_distance_2points(todouble(Location.geoCoordinates.latitude), todouble(Location.geoCoordinates.longitude), todouble(LocationDetails1.geoCoordinates.latitude), todouble(LocationDetails1.geoCoordinates.longitude)) | where distance >= 50000 | summarize arg_max(TimeGenerated, *) by Id | where RiskState != \"dismissed\" | project UserPrincipalName, TimeGenerated, IpAddress, Location, TimeGenerated1, IpAddress1, LocationDetails1, RiskEventType, distance` <br>
3. Ask Security Copilot to analyze the retrieved data <br>
_`Provide your insights as Security Analyst about what anomalies or similarity patterns you identify in the data retrieved from the KQL query. Create the response in four sections **ANOMALIES** It is a description in natural language about the identified anomalies with evidences. **USERS** Provide the list of the involved users as string. UserPrincipalName separated by comma. **IPs** Provide the list of the involved IPs as string. IPs separated by comma. **RECOMMENDATIONS** list of recommendations to investigate. Create it in html format and not use header tags`_ <br>
4. Create the Sentinel incident


# Deploy
<a name="DEPLOY"></a>
To test this solution, perform the following steps:
1. Deploy the Logic App using the ARM template found in this folder. The file is [_deployment.json_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/integrations/Sentinel%20AI%20generated%20incident/deployment.json). <br>
The ARM template deploys the Logic App and two new connections: one for Security Copilot, one for Microsoft Sentinel (remember to authenticate them).
2. Upload the ExecuteKQL plugin in Security Copilot. You can find it [here](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/custom%20plugins/CustomKQL).


# Considerations
<a name="CONSIDERATIONS"></a>
This is a Proof Of Concepts and **not ready to be used in production**. <br>
Some things to consider:
- Refine your KQL query to not exceed the tokens limit
- Tune the prompt for analysis by enabling Security Copilot with a role model approach
- Experiment, as always

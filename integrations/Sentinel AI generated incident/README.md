# Sentinel AI Generated incident
version: _1.0_

Sections in this page
- [What is](#WHAT) <br>
- [Schema](#SCHEMA) <br>
- [Deploy](#DEPLOY) <br>
- [Considerations](#CONSIDERATIONS) <br>


# What is
<a name="WHAT"></a>
This is a simple experiment of creating a Sentinel Incident after Security Copilot investigation and analysis. The idea is to create an _informational_ incident based insights detected by Security Copilot.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/MermaidDiagram/webpage.png" width="1000"> </img>
</div>


# Schema
<a name="SCHEMA"></a>
The solution is composed of two main parts:
- a Security Copilot plugin to retrieve data using a KQL query and a Security Copilot prompt to analyse them to find anomalies
- a scheduled Logic App to interact with Security Copilot and create Sentinel Incident

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/MermaidDiagram/high-level-schema.png" width="900"> </img>
</div>

The workflow is simple:
1. Every week
3. Execute KQL query to retrieve logs from **AADUserRiskEvents** table.
4. Ask Security Copilot to analyze the retrieved data
5. Create the Sentinel incident


# Deploy
<a name="DEPLOY"></a>
To test this solution, perform the following steps:
1. Deploy the Logic App using the ARM template found in this folder. The file is [_deployment.json_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/integrations/IncidentGraph/deployment.json). <br>
The ARM template deploys the Logic App and a new Security Copilot connection, remember to authenticate it.
2. Edit the web page to point to your Logic App `response = await fetch('<INSERT-YOUR-ENDPOINT>'`. The web page is the file [_site.html_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/integrations/IncidentGraph/site.html).
3. Upload the MermaidDiagram plugin in Security Copilot. You can find it [here](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/custom%20plugins/MermaidDiagram).
4. Open the _site.html_ file with your browser, insert a Defender XDR incident ID and enjoy the result.


# Considerations
<a name="CONSIDERATIONS"></a>
This is a Proof Of Concepts and **not ready to be used in production**. <br>
Some things to consider:
- Secure the Logic App endpoint. Currently endpoint exposed with signature in the URL. Possible approach? Register an Enterprise App and authenticate the API with Bearer Token in the request header.
- Modify the custom plugin manifest to better instruct GPT on how to create the Mermaid diagram
- Experiment, as always

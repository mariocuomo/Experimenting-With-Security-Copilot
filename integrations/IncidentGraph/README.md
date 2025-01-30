# Incident Graph
version: _1.0_

Sections in this page
- [What is](#WHAT) <br>
- [Schema](#SCHEMA) <br>
- [Deploy](#DEPLOY) <br>


# What is
<a name="WHAT"></a>
This is a simple experiment of creating an incident graph with Security Copilot. The idea is to investigate a Defender XDR incident with Security Copilot and then use Generative AI to create a graph from the investigation summary.
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/MermaidDiagram/webpage.png" width="1000"> </img>
</div>


# Schema
<a name="SCHEMA"></a>
The solution is composed of three main parts:
- a simple html web page
- a Logic App waiting for an api call
- a custom plugin with a GPT skill

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/MermaidDiagram/high-level-schema.png" width="900"> </img>
</div>

The workflow is simple:
1. You enter the **Defender XDR incident ID** that you want to investigate
3. The "**Generate Diagram**" button triggers a Logic App
4. The Logic App uses the **Security Copilot connector** to investigate the incident <br>
  (<i>in this first version it is just the incident summary</i>)
5. The last step of the Logic App is the execution of the **MermaidDiagramCreation** skill
6. The Logic App returns the graph expressed with **Mermaid's syntax**
7. The Mermaid graph is **rendered** and displayed


# Deploy
<a name="DEPLOY"></a>
To test this solution, perform the following steps:
1. Deploy the Logic App using the ARM template found in this folder. The file is [_deployment.json_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/integrations/IncidentGraph/deployment.json). <br>
The ARM template deploys the Logic App and a new Security Copilot connection, remember to authenticate it.
2. Edit the web page to point to your Logic App `response = await fetch('<INSERT-YOUR-ENDPOINT>'`. The web page is the file [_site.html_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/integrations/IncidentGraph/site.html).
3. Upload the MermaidDiagram plugin in Security Copilot. You can find it [here](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/tree/main/custom%20plugins/MermaidDiagram).
4. Open the _site.html_ file with your browser, insert a Defender XDR incident ID and enjoy the result.

> [!IMPORTANT]  
> Under Construction 🧰

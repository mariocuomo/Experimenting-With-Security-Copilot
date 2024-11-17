# Custom Incident Report

Security Copilot offers a dedicated skill to summarize a data set. This skill is included in the **Generic** plugin and is named **Summarize Data**. <br>
This skill is often used at the end of an investigation. <br>
An example is the **Suspicious Script Analysis promptbook**. It contains several prompts to investigate the intent of a script, identify Indicators of Compromise (IoCs) and associated Threat Actors, and create recommendations to mitigate its unintended effects. An executive summary is generated at the end of the promptbook.

> _Summarize the findings from this analysis into an executive report. Begin with an assessment of the script. Include confidence and supporting evidence for the assessment. Below that, generate paragraph sections for a "Script Overview", "Threat Intelligence", and "Response Suggestions". It should be suitable for a less technical audience._

The prompt above is a great example of **prompt engineering** as it comprehensively describes the structure of the executive report.<br>
The same happens at the end of the **Microsoft 365 Defender incident investigation promptbook**.

> _Write an executive report summarizing this investigation. It should be suited for a non-technical audience._

The question now is: what if you want a specific report format? Do you need to define it every time in the prompt? <br>
The solution is to **create a custom GPT plugin!**

This folder shows the plugin **CustomIncidentReportPlugin** that contains the skill **CustomIncidentReport**. <br>
The skill does not require any parameters as the incident report is created from the **data collected in the session**.

This is the prompt submitted to GPT when this skill is used:

> _The incident report should always include the Incident Summary, Technical Details, and Recommendations._ <br>
> **_The incident summary should be based on the investigation._** <br>
> _The technical details should expand upon the incident summary including as much detail as possible._ <br>
> _The recommendations section should include recommendations about how to mitigate and resolve the incident._ <br>
> _The recommendations should be listed using bulleted format for easier reading._ <br>
> _Additionally, where possible please provide links for the recommendations provided, so anyone that needs to get additional details on how to complete those recommendations._ <br>
> _Also, please make sure the incident report includes the contact details for our company._ <br>
> _Our company is Contoso. We can be reached via email at publicSOC@contoso.com_ <br>
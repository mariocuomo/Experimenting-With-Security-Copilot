# Execute a KQL query in ADX

## DESCRIPTION
Security Copilot enables KQL queries against Defender XDR and Sentinel using the **Natural language to KQL for Microsoft Sentinel** and **Natural language to KQL for Defender XDR** plugins. <br>
This folder contains a custom plugin to perform a KQL query against an ADX database. <br> 
Even though the KQL query can be executed directly in ADX, creating a plugin to do it can be useful in at least two scenarios:
- In an automation or promptbook execution scenario, the result of the KQL query is taken as input by the next prompt.
- Creating session context, for investigation summary

---

## TYPE AND REQUIREMENTS
**TYPE**: KQL (Kusto) <br>
**SOURCE**: any ADX database and cluster <br>
**REQUIREMENTS**: any ADX database and cluster

---

## SKILLS

| SkillName | Description |
|     :---         |     :---      |
| ExecuteADXQuery | Skill used to execute a KQL query against an ADX database   |

---

## SAMPLE PROMPTS

- `«Execute the following ADX kql query: <YOUR-KQL-QUERY>»`
---

## SCREENSHOTS
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/GenerativeAIAppsAnalysis/result.png" width="700"> </img>
</div>

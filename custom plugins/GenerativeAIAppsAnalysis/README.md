# Generative AI Apps Analysis

## DESCRIPTION
This folder contains a custom plugin to analyze and reason on Generative AI Cloud Apps used in you environment. <br>
It could be a good starting point to analyze which risky Generative AI apps are used, how many bytes are exchanged with them - from which user and ip. <br>
The investigation can continue later with MDTI and Entra plugins.

---

## TYPE AND REQUIREMENTS
**TYPE**: KQL (Sentinel) <br>
**SOURCE**: Defender for Cloud Apps data (McasShadowItReporting table) <br>
**REQUIREMENTS**: Defender for Cloud Apps connected to Microsoft Sentinel (explained [here](https://learn.microsoft.com/en-us/defender-cloud-apps/siem-sentinel))

---

## SKILLS

| SkillName | Description |
|     :---         |     :---      |
| GenerativeAIAppsAccessedByRisk | Skill used to retrieve the list of generative AI apps accessed in the last week     |
| HowManyBytesForEachGenerativeAIApp | Skill used to retrieve calculate how many bytes are exchanged with Generative AI Apps in the last week |
| StatisticsGenerativeAIApp | Skill used to retrieve statistics regarding a specific Generative AI App in the last week |

---

## SAMPLE PROMPTS

- `«Provide me more statistics for Generative AI app named Neural style»`
- `«Which High risk generative applications are my users accessing to?»`

---

## SCREENSHOTS
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/GenerativeAIAppsAnalysis/result.png" width="700"> </img>
</div>

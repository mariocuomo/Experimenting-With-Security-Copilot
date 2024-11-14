# API plugin - AADDelegated Authentication

This is an example of a plugin that performs a **GraphAPI** API call with AADDelegated Authentication. <br>
**API GET https://graph.microsoft.com/v1.0/security/alerts_v2?$select=id,title**

## PREREQUISITES
It necessary to register an Enterprise Application in Entra. <br>
Add the following callback uri https://securitycopilot.microsoft.com/auth/v1/callback. <br>
Add the _SecurityAlert.Read.All_ permission to the application.<br>
AADDelegated scheme is User + Application only access. <br>

## SKILLS

| SkillName | Description |
|     :---         |     :---      |
| VTDomainReport | Skill used to lookup domain information  |
| VTIPReport | Skill used to lookup IP information  |
| VTUrlSubmission | Skill used to submit a URL for scanning  |
| ... | ...  |

---

## SCREENSHOTS
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_apikey.png" width="700"> </img>
</div>

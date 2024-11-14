# API plugin - AADDelegated Authentication

This is an example of a plugin that performs a **GraphAPI** API call with AADDelegated Authentication. <br>
**API GET https://graph.microsoft.com/v1.0/security/alerts_v2?$select=id,title**

## PREREQUISITES
AADDelegated scheme is User + Application only access. <br>
This means that the final permission set is the intersection of Security Copilot's application permissions and the user's own permissions. <br>

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_AADDelegated.png" width="500"> </img>
</div>


But what are application permissions? Check out this interesting [blog post](https://www.bluevoyant.com/blog/building-graph-api-custom-plugins-for-copilot-for-security) from BlueVoyant.
Security Copilot is using its own **Entra ID Enterprise Application** (Medeina Service, Client ID: bb3d68c2-d09e-4455-94a0-e323996dbaa3) to make the call to the GraphAPI on behalf of the user. <br>
These are the permissions it has

AccessReview.Read.All  | 
AdministrativeUnit.Read.All |
Agreement.Read.All |
Application.Read.All |
AuditLog.Read.All |
CloudPC.Read.All |
DelegatedPermissionGrant.Read.All |
Device.Read.All |
DeviceManagementApps.Read.All |
DeviceManagementConfiguration.Read.All |
DeviceManagementManagedDevices.Read.All |
DeviceManagementRBAC.Read.All |
DeviceManagementServiceConfig.Read.All |
DirectoryRecommendations.Read.All |
Email |
EntitlementManagement.Read.All |
Group.Read.All |
GroupMember.Read.All |
IdentityRiskEvent.Read.All |
IdentityRiskyServicePrincipal.Read.All |
IdentityRiskyUser.Read.All |
LifecycleWorkflows.Read.All |
Openid |
Organization.Read.All |
Policy.Read.All |
Profile |
RoleAssignmentSchedule.Read.Directory |
RoleEligibilitySchedule.Read.Directory |
RoleManagement.Read.Directory |
RoleManagementPolicy.Read.Directory |
SecurityAlert.Read.All |
SecurityIncident.Read.All |
ThreatHunting.Read.All |
ThreatIntelligence.Read.All |
User.Read |
User.Read.All |
UserAuthenticationMethod.Read.All |


## SKILLS
| SkillName | Description |
|     :---         |     :---      |
| GetAlertIdsFromIncidentIdAADDelegated | List all alert id's based on a user provided incident id  |

---

## SCREENSHOTS
Below are two screenshots: invoking the same skill has two different results based on the user's permissions. The first user is a Security Admin and has the _SecurityAlert.Read.All_ permission, the second user does not.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_AADDelegatedSecurityAdmin.png" width="700"> </img>
</div>
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/api_AADDelegatedNoAdmin.png" width="700"> </img>
</div>

Inspired by [Chaitanya Belwal](https://techcommunity.microsoft.com/blog/securitycopilotblog/using-microsoft-graph-as-a-microsoft-copilot-for-security-plugin-with-delegated-/4198148)
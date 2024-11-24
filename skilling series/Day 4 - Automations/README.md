# Skilling Series - Automations

> [!IMPORTANT]  
> Under Construction **COMING SOON** 29/11/2024 🧰


It is possible to interact with Security Copilot via Azure Logic App using the [Security Copilot Connector](https://learn.microsoft.com/en-us/connectors/securitycopilot/). <br>
This unlocks the ability to create automations that leverage the Security Copilot integration. <br>

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/automation.png" width="800"> </img>
</div>


The connector offers two actions:
- **Submit a Security Copilot prompt**
- **Run a Security Copilot promptbook**	

As for the action _submit a prompt to Security Copilot_ it offers interesting parameters to contextualize and optimize the interaction. <br>

<div align="center">
  
| Name	| Description |
| ------------- | ------------- |
| **Prompt Content**	| Prompt to be evaluated by security copilot |
| **SessionId** | The ID for an existing Copilot session |
| **Plugins	Skillsets** | Plugins to enable for this Copilot session |
| **Direct Skill** | Skill to invoke |
| **Direct Skill Inputs**	| Skill required inputs |

</div>

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/logic%20app%20connector.png" width="500"> </img>
</div>



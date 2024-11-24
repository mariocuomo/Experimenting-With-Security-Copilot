# Security Copiloty SCUs Consumption Analysis Workbook
The **Security Copiloty SCUs Consumption Analysis Workbook** is designed to help you understand Secure Compute Unit consumption. <br>
It uses data from the **Usage Monitoring Dashboard** and performs analysis based on users, plugins and sessions. <br>

version: _1.0_

Sections in this page
- [Prerequisites](#PREREQUISITES) <br>
- [Deployment](#DEPLOYMENT) <br>
- [Use it](#USE) <br>


<a name="PREREQUISITES"></a>
# PREREQUISITES
_Version 1.0_ uses a Sentinel workbook. <br>
The _CapacityUsage.xlsx_ file is uploaded as a **Sentinel Watchlist** and is the database for the visualization created with the workbook. <br>
The SCUs consumption data is monitoring data rather than security data - for this reason _Version 2.0_ (in roadmap) will use Azure Monitor Log Analytics Workspace. <br>
_Version 1.0_ is designed to provide a quick **Proof Of Concept for analyzing Usage Dashboard data**.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/SecurityCopilotUsageDataWorkbook/schema.png" width="800">
</div>

<a name="DEPLOYMENT"></a>
# DEPLOYMENT
## Step #1
[Download](https://learn.microsoft.com/en-us/copilot/security/manage-usage#export-data) the _CapacityUsage.xlsx_ report from the Security Copilot Standalone portal. <br>
Convert the _.xlsx_ file to _.csv_. <br>
You can use [Microsoft 365 apps for free on the web](https://www.microsoft.com/en-us/microsoft-365/free-office-online-for-the-web?msockid=3bacf9dd7b706ea223c0eb007a476fc6)

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/SecurityCopilotUsageDataWorkbook/UsageDashboard.png" width="1000">
</div>

## Step #2
Run the [_formatUsageData.ps1_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/monitoring/Consumption%20Analysis%20Workbook/formatUsageData.ps1) PowerShell Script. <br>

```PowerShell
.\formatUsageData.ps1
```

## Step #3
The PowerShell Script creates a new file (_rawContent.txt_)<br>
Copy the contents of the file and past it into the _rawContent_ property in the _deployment.json_ file.
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/SecurityCopilotUsageDataWorkbook/rawContent.png" width="800">
</div>

## Step #4
Deploy the _deployment.json_ file to Azure (in the same Resourge Group where Sentinel is deployed). <br>

The deployment creates two Azure Resources:
- the **Security Copiloty SCUs Consumption Analysis Workbook**
- the **_SecurityCopilotUsageData_ Watchlist**

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/SecurityCopilotUsageDataWorkbook/Deployment.png" width="1000">
</div>

<a name="USE"></a>
# USE

> [!IMPORTANT]
> Under Construction 🧰

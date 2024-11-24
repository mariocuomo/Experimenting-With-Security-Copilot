# Security Copiloty SCUs Consumption Analysis Workbook
The **Security Copiloty SCUs Consumption Analysis Workbook** is designed to help you understand Secure Compute Unit consumption. <br>
It uses data from the **Usage Monitoring Dashboard** and performs analysis based on users, plugins and sessions. <br>

version: _1.0_

## PREREQUISITES
_Version 1.0_ uses a Sentinel workbook. <br>
The _CapacityUsage.xlsx_ file is uploaded as a **Sentinel Watchlist** and is the database for the visualization created with the workbook. <br>
The SCUs consumption data is monitoring data rather than security data - for this reason _Version 2.0_ (in roadmap) will use Azure Monitor Log Analytics Workspace. <br>
_Version 1.0_ is designed to provide a quick **Proof Of Concept for analyzing Usage Dashboard data**.

# STEP 1
[Download](https://learn.microsoft.com/en-us/copilot/security/manage-usage#export-data) the _CapacityUsage.xlsx_ report from the Security Copilot Standalone portal.

# STEP 2
Convert the _.xlsx_ file to _.csv._ <br>
You can use [Microsoft 365 apps for free on the web](https://www.microsoft.com/en-us/microsoft-365/free-office-online-for-the-web?msockid=3bacf9dd7b706ea223c0eb007a476fc6)

# STEP 3
Run the [_formatUsageData.ps1_](TBD) PowerShell Script. <br>




> [!IMPORTANT]
> Under Construction 🧰

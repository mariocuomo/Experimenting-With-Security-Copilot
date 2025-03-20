# Sentinel Security Copilot Assistant

version: _1.0_

Sections in this page
- [What is](#WHAT) <br>
- [Schema](#SCHEMA) <br>
- [Deploy](#DEPLOY) <br>
- [Considerations](#CONSIDERATIONS) <br>

# What is
<a name="WHAT"></a>
**Sentinel Security Copilot Assistant (SSCA)** is a collection of robust playbooks designed to seamlessly integrate Microsoft Security Copilot with Microsoft Sentinel. By leveraging the power of AI-driven insights and automation, SSCA enhances security operations by enabling capabilities such as entity enrichment, incident summarization, and more.

**📌 Key Features**
- **Entity Lookup**: Quickly retrieve and enrich information about IPs, domains, users, and devices, streamlining investigation workflows.
- **Incident Summary**: Generate both brief and expanded summaries of incidents, providing clear and actionable insights for security teams.
- **Scheduled Updates**: Deliver regular updates on incident situations, Microsoft Sentinel's health, and SOC efficiency metrics, keeping your team informed and proactive.

**🛠 Prerequisites** <br>
Before you begin, ensure you have:
- A valid **Microsoft Sentinel** instance.
- Access to **Microsoft Security Copilot**.
- Necessary permissions to configure and run Sentinel playbooks.

# Schema
<a name="SCHEMA"></a>
The SSCA solution deploys several Azure Logic Apps, categorized by their intended functionality. <br>
Below is a description of each resource: <br>

**Entity Lookup** <br>
These Logic Apps are designed to enrich security investigations by providing detailed information about specific entities and posted them as Sentinel incident Comment.
- **SSCA-IPLookupComment** <br>
Enriches incident investigations with contextual information about IP addresses (e.g., geolocation, threat intelligence).
- **SSCA-DomainLookupComment** <br>
Retrieves data about domains, such as reputation, WHOIS details, and DNS information.
- **SSCA-UserLookupComment** <br>
Provides insights into user activities and account-related data for faster security triage.
- **SSCA-DeviceLookupComment** <br>
Supplies detailed device-related information, including device compliance, vulnerabilities, and configuration.

**Incident Summary** <br>
These Logic Apps generate concise and comprehensive summaries for security incidents to improve situational awareness and post the summary as Sentinel incident comment.
- **SSCA-IncidentSummary-Brief** <br>
Creates a quick, high-level summary of incidents for immediate insights and faster decision-making.
- **SSCA-IncidentSummary-Expanded** <br>
Produces a detailed, in-depth summary of incidents, including key findings and recommendations.

**Scheduled Updates**
These Logic Apps deliver periodic reports and summaries to keep security teams informed about various operational metrics via email.
- **SSCA-IncidentsSituationEmail** <br>
Sends a scheduled overview of the current incident situation, highlighting trends and unresolved cases.
- **SSCA-SentinelHealthEmail** <br>
Provides updates on the health status of Microsoft Sentinel to ensure continued optimal performance.
- **SSCA-SOCOptimizationEmail** <br>
Reports on SOC efficiency metrics, offering insights into workflow optimization and performance improvements.

# Deploy
<a name="DEPLOY"></a>

# Considerations
<a name="CONSIDERATIONS"></a>

> [!IMPORTANT]  
> Under Construction 🧰

# KQL queries via Natural Language 
Generative AI and Security Copilot can help tremendously in **developing**, **analyzing**, and **optimizing** KQL queries.

### Devlopment
Security Copilot offers the **Natural language to KQL for Microsoft Defender XDR** and **Natural language to KQL for Microsoft Sentinel** plugins to generate KQL queries from natural language. <br>

### Analysis
Secuirty Copilot can be used to understand the intent of a KQL query, which will be explained line-by-line. <br>

### Optimization
Secuirty Copilot can be used to optimize a KQL query to be executed efficiently. <br>

```mermaid
flowchart TD
    A["Security Copilot"]
    A-->B(Development)
    style B fill:#f9f,stroke:#333,stroke-width:4px
    B-->E(«Supply KQL to help identify Midnight Blizzard on my network»)
    A-->C(Analysis)
    style C fill:#f9f,stroke:#333,stroke-width:4px
    C-->F(«Tell me the intent of the following KQL query»)
    A-->D(Optimization)
    style D fill:#f9f,stroke:#333,stroke-width:4px
    D-->G(«Tell me how to optimize the following KQL query»)
```

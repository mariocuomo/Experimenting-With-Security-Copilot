# MCP Server plugin - No Authentication

This is an example of a plugin that uses [Microsoft Learn MCP Server](https://github.com/microsoftdocs/mcp?tab=readme-ov-file). <br>
Microsoft Learn MCP Server offers the tools:
- _microsoft_docs_search_ <br>
Performs semantic search against Microsoft official technical documentation	
- _microsoft_docs_fetch_ <br>
Fetch and convert a Microsoft documentation page into markdown format	

**MCP Server endpoint https://learn.microsoft.com/api/mcp** <br>
The server doesn't require authentication.

## SKILLS

| SkillName | Description | Input Parameters
|     :---         |     :---      |     :---      | 
| microsoft_docs_search | Performs semantic search against Microsoft official technical documentation | _query_ : The search query for retrieval |
| microsoft_code_sample_search	 | Search for official Microsoft/Azure code snippets and examples | _query_: Search query for Microsoft/Azure code snippets and _language_ : Programming language filter. |


---

## SAMPLE PROMPTS

- `«Using Microsoft Learn, I want to know more Defender for Cloud Apps Reverse Proxy capability. What is it, how can I use it and what is the benefit of using it. I understood that it can be used to protect in real-time, is it correct?»`
---

## SCREENSHOTS
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/MCP_Learn.png" width="1000"> </img>
</div>


Inspired by [Stefano Pescosolido](https://www.linkedin.com/in/stefanopescosolido/)



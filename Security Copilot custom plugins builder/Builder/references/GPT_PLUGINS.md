# GPT Plugins

GPT plugins interact directly with the already available GPT model in Security Copilot. They are useful for:
- **Context (Past)**: in the GPT prompt you can reference information and context from the current session
- **Context (Future)**: the GPT response can be used by subsequent prompts
- **Easy to integrate**: no need to create a separate Azure OpenAI instance

---

## GPT Settings

| Setting | Type | Description | Required |
|---------|------|-------------|----------|
| `ModelName` | string | GPT model to use. | Yes |
| `Template` | string | Inline prompt template. Max 80,000 chars. | Yes (if no `TemplateUrl`) |
| `TemplateUrl` | string | Public URL of the template. | Alternative to `Template` |
| `PackageUrl` | string | URL of a ZIP file containing the template. | Alternative |
| `TemplateFile` | string | Relative path to the template inside the ZIP. | Yes if `PackageUrl` |

## Available Models

| Model Name | Description | Context Window |
|------------|-------------|----------------|
| `gpt-4o` | GPT 4o | 128k |
| `gpt-4.1` | GPT 4.1 (latest available) | 128k |

## Using Parameters in GPT Templates

Parameters defined in `Inputs` are inserted into the template using `{{parameterName}}`.

---

## Full Examples

### GPT Defang URL
```yaml
Descriptor:
  Name: DefangUrls
  DisplayName: DefangUrls
  Description: Skills for defanging URLs in the given text

SkillGroups:
  - Format: GPT
    Skills:
      - Name: DefangUrls
        DisplayName: Defang URLs
        Description: Defangs URLs in the given text
        Inputs:
          - Name: text
            Description: The text containing URLs to be defanged
            Required: true
        Settings:
          ModelName: gpt-4o
          Template: |-
            To 'defang' a URL means to change the scheme to either hxxp or hxxps and replace '.' with '[.]' in the domain so that the URL is still easily readable by a human but doesn't automatically render as a hyperlink if rendered in a rich client such as Outlook. This is often done when sharing potentially malicious links to prevent the reader accidentally clicking on them and visiting a malicious website.

            Some examples of defanging URLs:
            1. https://example.com --> hxxps://example[.]com
            2. http://subdomain.example.com/path.with.dots/ --> hxxp://subdomain[.]example[.]com/path.with.dots/

            Defang any URLs in the following text and return the new text:
            {{text}}
```

### GPT Custom Incident Report (no parameters — uses session context)
```yaml
Descriptor:
  Name: CustomIncidentReportPlugin
  DisplayName: Custom Incident Report Plugin
  Description: Custom Incident Report Plugin

SkillGroups:
  - Format: GPT
    Skills:
      - Name: CustomIncidentReport
        DisplayName: CustomIncidentReport
        Description: Create a custom incident report interacting directly with GPT
        Settings:
          ModelName: gpt-4o
          Template: |-
            The incident report should always include the Incident Summary, Technical Details, and Recommendations.
            The incident summary should be based on the investigation.
            The technical details should expand upon the incident summary including as much detail as possible.
            The recommendations section should include recommendation about how to mitigate and resolve the incident.
            The recommendations should be listed using bulleted format for easier reading.
            Additionally, where possible please provide links for the recommendations provided, so anyone that needs to get additional details on how to complete those recommendations.
            Also, please make sure the incident report includes the contact details for our company.
            Our company is Contoso. We can be reached via email at publicSOC@contoso.com
```

> **IMPORTANT NOTE on GPT plugins without inputs**: When no Inputs are defined, the GPT template runs in the context of the current session. This is particularly useful for creating reports based on previous investigations in the same session.

### GPT with TemplateUrl
```yaml
Descriptor:
  Name: SampleGPTTemplate
  DisplayName: My Sample GPT Skillset With Template
  Description: Skills for defanging URLs

SkillGroups:
  - Format: GPT
    Skills:
      - Name: DefangUrls
        DisplayName: Defang URLs
        Description: Defangs URLs in the given text
        Inputs:
          - Name: text
            Description: The text containing URLs to be defanged
        Settings:
          ModelName: gpt-4o
          TemplateUrl: https://example.com/template.txt
```

### GPT with PackageUrl
```yaml
Descriptor:
  Name: SampleGPTTemplateWithPackageUrl
  DisplayName: My Sample GPT Skillset With PackageUrl
  Description: Skills for defanging URLs

SkillGroups:
  - Format: GPT
    Settings:
      PackageUrl: https://example.com/GPTTemplates.zip
    Skills:
      - Name: DefangUrls
        DisplayName: Defang URLs
        Description: Defangs URLs in the given text
        Inputs:
          - Name: text
            Description: The text containing URLs to be defanged
        Settings:
          ModelName: gpt-4o
          TemplateFile: GPTTemplates/SampleGPTTemplate.txt
```

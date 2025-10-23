# Security Copilot Plugin Builder

A comprehensive web-based tool for creating custom plugins for Microsoft Security Copilot. This interactive YAML generator simplifies the complex process of building Security Copilot plugins by providing an intuitive interface with real-time preview capabilities.

## Overview

The Security Copilot Plugin Builder is a standalone HTML application that enables security professionals, developers, and analysts to create custom plugins for Microsoft Security Copilot without deep knowledge of YAML syntax or plugin architecture. The tool provides a user-friendly interface that generates properly formatted plugin manifests compatible with Security Copilot's requirements.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/custom%20plugins/Custom%20Plugin%20Builder/image.png" width="1000">
</div>

### Key Features

- **Interactive Form Builder**: Simple form-based interface for defining plugin metadata and capabilities
- **Real-time YAML Preview**: Live preview of the generated YAML manifest as you build your plugin
- **Multiple Skill Formats**: Support for KQL, API, GPT, and Logic App skill types
- **Authentication Configuration**: Built-in support for various authentication methods including API Key, OAuth, and Azure AD
- **Validation & Feedback**: Real-time validation with warnings and success indicators
- **Copy-to-Clipboard**: One-click copying of the generated YAML manifest
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices

## How It Works

The tool is organized into intuitive sections that guide you through the plugin creation process:

### 1. Plugin Descriptor
Define the basic metadata for your plugin:
- **Name**: Unique identifier for your plugin
- **Display Name**: Human-readable name shown in the Security Copilot interface  
- **Description**: User-friendly description for the plugin catalog
- **Description for Model**: Technical description that helps the AI understand when to use your plugin

### 2. Skill Configuration
Create and configure the capabilities your plugin provides:

#### **KQL Skills**
- Target different data sources (Sentinel, Log Analytics, Azure Data Explorer, Defender)
- Configure workspace and connection parameters
- Define KQL queries with proper parameterization

#### **API Skills**  
- Set up REST API endpoints with full OpenAPI specification support
- Configure authentication (None, Basic, API Key, OAuth flows, Azure AD)
- Define request/response schemas and error handling

#### **GPT Skills**
- Create AI-powered capabilities using natural language processing
- Define prompts and conversation flows
- Configure model parameters and constraints

#### **Logic App Skills**
- Integrate with Azure Logic Apps for complex workflows
- Configure triggers and actions
- Set up data transformation and routing

### 3. Real-time Preview
The right panel displays a live preview of your YAML manifest, featuring:
- Syntax highlighting for better readability
- Automatic formatting and structure validation
- Real-time updates as you modify configurations
- Validation warnings and success indicators

### 4. Export and Deploy
Once your plugin is configured:
- Copy the generated YAML manifest to your clipboard
- Save the YAML file for deployment to Security Copilot
- Share configurations with your team for collaborative development

## Benefits

### **Accelerated Development**
- Reduces plugin creation time from hours to minutes
- Eliminates the need to manually write complex YAML configurations
- Provides instant feedback on configuration validity

### **Reduced Errors**
- Built-in validation prevents common syntax and structure errors
- Real-time preview helps catch issues before deployment
- Guided interface ensures all required fields are populated

### **Enhanced Accessibility**
- No programming experience required for basic plugin creation
- Visual interface abstracts away technical complexity
- Comprehensive help text and tooltips guide users through each step

### **Improved Collaboration**
- Shareable configurations enable team collaboration
- Standardized output ensures consistency across plugin developments
- Easy iteration and modification of existing plugins

### **Professional Output**
- Generates industry-standard YAML manifests
- Follows Microsoft Security Copilot best practices
- Includes proper documentation and metadata

### **Flexibility and Extensibility**
- Supports all major Security Copilot skill types
- Accommodates various authentication methods
- Handles complex scenarios like multi-tenant deployments

## Getting Started

1. **Open the Tool**: Simply open the `security-copilot-plugin-builder.html` file in any modern web browser or surf <a href="https://mariocuomo.github.io/view/pluginbuilder.html">here</a>
2. **Define Your Plugin**: Fill out the basic plugin information in the Descriptor section
3. **Add Skills**: Click "Add First Skill" to begin defining your plugin's capabilities
4. **Configure Authentication**: Set up any required authentication for API-based skills
5. **Review & Export**: Check the real-time preview and copy your YAML manifest
6. **Deploy**: Use the generated YAML to deploy your plugin to Security Copilot

## Conclusion

The Security Copilot Plugin Builder democratizes the creation of custom Security Copilot plugins by providing an intuitive, visual approach to plugin development. Whether you're a security analyst looking to integrate custom data sources, a developer building sophisticated API integrations, or an administrator creating organizational workflows, this tool streamlines the entire process.

By abstracting away the technical complexity of YAML manifest creation while maintaining the full power and flexibility of Security Copilot's plugin architecture, the Plugin Builder enables teams to focus on their security objectives rather than configuration syntax. The result is faster time-to-value, reduced development overhead, and more reliable plugin deployments.

Start building your custom Security Copilot plugins today and unlock the full potential of your security operations with tailored, intelligent automation.

---

*Built with ❤️ for the Security Community*


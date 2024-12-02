# Manifest Checker
version: _1.0_

Sections in this page
- [What is](#WHAT) <br>
- [Use](#USE) <br>
- [Functions](#FUNCTIONS) <br>
- [Understand the Output](#OUTPUT) 

# What is
<a name="WHAT"></a>
This script allows you to analyze a **Security Copilot manifest** (yaml format) to understand if the file structure is correct with syntactic checks (_i_), understand if all the Required keys have been inserted (_ii_), understand if optional and suggested keys are missing (_iii_) or if superfluous keys have been inserted (_iv_)

The [_Analysis.ps1_](https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/monitoring/Manifest%20Checker/Analysis.ps1) script takes as input a parameter (**$script**) which is the filepath of the yaml file you want to check. <br>
The result is printed on the command line.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/ScriptAnaliser/schema.png" width="700">
</div>



# Use
<a name="USE"></a>
```PowerShell
.\Analysis.ps1 -script manifest.yaml
```

# Functions
<a name="FUNCTIONS"></a>

The function _Main_ has the following flow:
1. It reads the manifest via the _Read-YamlFile_ function. <br>
   If the file cannot be parsed in yaml format, an error is raised
2. The Skill Groups key is analyzed first because the _Descriptor key_ is different based on the _Target_ value
3. The _Descriptor key_ is analyzed

_Confirm-SkillGroups_ and _Confirm-Descriptor_ functions use the _Test-ExtraKeys_, _Test-WarningKeys_ and _Test-ErrorKeys_ functions to analyze the presence of the required, optional and unnecessary subkeys.
<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/ScriptAnaliser/functions-schema.png" width="800">
</div>



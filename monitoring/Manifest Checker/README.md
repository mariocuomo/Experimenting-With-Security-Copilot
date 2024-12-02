# Manifest Checker

This script allows you to analyze a **Security Copilot manifest** (yaml format) to understand if the file structure is correct with syntactic checks (_i_), understand if all the Required keys have been inserted (_ii_), understand if optional and suggested keys are missing (_iii_) or if superfluous keys have been inserted (_iv_)

The _Analysis.ps1_ script takes as input a parameter (**$script**) which is the filepath of the yaml file you want to check. <br>
The result is printed on the command line.

<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/ScriptAnaliser/schema.png" width="700">
</div>


<div align="center">
  <img src="https://github.com/mariocuomo/Experimenting-With-Security-Copilot/blob/main/img/ScriptAnaliser/functions-schema.png" width="800">
</div>


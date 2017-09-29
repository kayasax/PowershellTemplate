# PowershellTemplate
An attempt to create a templating system for powershell. 

###### The main goals of this set of scripts are:
- Improve scripts consistency among your scripters team
- Provide a solid fundation for new script
- Ease the reuse of existing functions without copy/paste code extracts

###### The workflow for creating a new script will be:
1. Create a new template in template repository  
  `PS> Newtemplate.ps1 -name MyTemplate`  
  This will create MyTemplate.ps1t in the repository (defined in *preferences.ps1*)
2. Insert your code in the previously generated template  
  You can use the `<include>` tag to reuse existing code from the function repository  
  eg: `<include logging/log>`  
  The content of the file *log.ps1* found in the *logging* directory of the function repo will be inserted here at step 3
3. Generate the script  
  `PS>NewScriptFromTemplate.ps1 -template MyTemplate -name MyScript.ps1`  
  will create MyScript.ps1 in the current directory

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
2. Edit error handling preferences and insert your code in the previously generated template  
  You can use the `<include>` tag to reuse existing code from the function repository  
  eg: `<include logging/log>`  
  The content of the file *log.ps1* found in the *logging* directory of the function repo will be inserted here at step 3
3. Generate the script  
  `PS>NewScriptFromTemplate.ps1 -template MyTemplate -name MyScript.ps1`  
  will create MyScript.ps1 in the current directory

###### Error handling
Basicaly your code will be executed in a giant try/catch statement and *$ErrorActionPreference* is set to `STOP`  
This means every error encountered will be a terminated error and the instructions in the catch block will be executed.

By setting *$EmailAlert* to `$true` an email will be sent when an error occured.
The mail will look like this  
![Email alert sample](https://user-images.githubusercontent.com/1241767/31053970-a5038382-a6a8-11e7-8e63-c8f120f4252f.png)

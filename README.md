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

You can also set *$EventLogAlert* tp `$true` to create an event log which will produce something similar in application event log
![eventlog alert](https://user-images.githubusercontent.com/1241767/31054010-649bdb22-a6a9-11e7-8882-78a6ff072271.png)

###### Logging feature
You can use the provided log function to record message on file and screen with basic colour highlights
![log to screen](https://user-images.githubusercontent.com/1241767/31054109-d2442e52-a6ab-11e7-96ed-c4e77f4c98b6.png)  
![log to file](https://user-images.githubusercontent.com/1241767/31054110-d56ecce0-a6ab-11e7-92f6-1d975779c224.png)

The log function include a rotating system : you can specify a maxsize for logfile if logfile exceed this limit it will be rename and a new file will be created. You can specify how much old files you want to keep

<#
.Synopsis
 This script will create a new template file (.ps1t) in the template repository ( defined in Preferences.ps1 ).
 Please keep it in this place when editing so it can be find by NewScriptFromTemplate function
.Description
 A template containing predefined placeholders will be created, the goal is to improve script consistency among your organisation scripters.
.Parameter name
 Name of the template to create 
.Parameter force
 Allow overwrite of existing template
.Example
 PS>NewTemplate.ps1 MyfirstTemplate
  Will create a MyFirstTemplate.ps1t file in the template repository
.Example
 PS>NewTemplate.ps1 MyfirstTemplate -force
 Will create a MyFirstTemplate.ps1t file in the template repository, overwriting previous version
.Link
 https://github.com/kayasax/PowershellTemplate
.Notes
#>

[CmdletBinding()] #make script react as cmdlet (-verbose etc..)
param(
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $name,
    [switch]$force
)

# ERROR HANDLING
$ErrorActionPreference="STOP" # make all errors terminating ones so they can be catch
$EmailAlert=$false # set to $true if you want to send fatal error by mail
$EventLogAlert=$false # set to $true if you want to log the fatal error in Application EventLog
$to="recipient@domain.tld" # email recipients  you can use several addresses like this "user1@dom.com","user2@dom.com"  
$description="Template generation script" #The description will be use in the mail subject if email alert is enable

# PRIVATE VARIABLES DON'T TOUCH
###################
$_ScriptFullName=$MyInvocation.myCommand.definition
$_ScriptName=Split-Path -Leaf $_ScriptFullName
$_ScriptPath=split-path -Parent   $_ScriptFullName
$_HostFQDN=[System.Net.Dns]::GetHostEntry([string]$Env:computername).HostName

try{
    $TemplateVersion="0.1"
    # Load preferences
    . "$_ScriptPath\preferences.ps1"

    # Add ps1t extention to template name if not provided
    if (!($name -match "\.ps1t$")){$name+=".ps1t"} 
    $TemplatePath=join-path "$_TemplateRepository" -childpath "$name"

    # Verify repo
    if (!(test-path $_TemplateRepository -PathType Container)){
        Throw "Error the template repository $_TemplateRepository does not exist, please create it"
    }
    # Don't overwrite template unless -force is used
    if( (test-path $TemplatePath) -and ($force -ne $true) ){
        Throw "Template $TemplatePath allready exists, please use -force parameter to overwrite it"
    } 

    $TemplateContent="<include template/Comments>"
    $TemplateContent |Out-File $TemplatePath

    $ParamBlock="<include template/Parameters>"
    $ParamBlock |Out-File $TemplatePath -Append

    $ScriptBody="<include template/ScriptBody>"
    $ScriptBody |Out-File $TemplatePath -Append
    
    $ScriptBody=@'


if( $EventLogAlert){
    if($Env -eq 'PROD'){
        $EventSource=
'@
$ScriptBody+=@"
"$_PRODSource"

"@

$ScriptBody+=@'
    }
    else{
        if ($Env -ne 'DEV'){
            log "Warning the environment $Env is unknow, failing back to DEV mode"
        }
        $EventSource=
'@

$ScriptBody+=@"
"$_DEVSource"

"@
$ScriptBody+=@'
    }

    # Check if Source exists in event logs otherwise, add it
    # Ref: http://msdn.microsoft.com/en-us/library/system.diagnostics.eventlog.sourceexists(v=vs.110).aspx

    if (! ([System.Diagnostics.EventLog]::SourceExists($EventSource))){
        New-EventLog -LogName application -Source "$EventSource"
    }
}
$_SMTPServer='
'@

$ScriptBody+=@"
$_SMTPServer
"@

$scriptBody+=@'
'
$_Enc=
'@

$ScriptBody+=@"
$_enc
"@

$scriptBody+=@'


# PRIVATE VARIABLES DON'T TOUCH !
$_ScriptFullName=$MyInvocation.myCommand.definition
$_ScriptName=Split-Path -Leaf $_ScriptFullName
$_ScriptPath=split-path -Parent   $_ScriptFullName
$_HostFQDN=[System.Net.Dns]::GetHostEntry([string]$Env:computername).HostName

try{
    # You can include existing functions from the function repository (defined in Preferences.ps1) like this :
    # <include path/to/function> 
    # Example :  
    # the <include ...> line will be replaced by the function.ps1 content when script will be generate using the NewScriptFromTemplate script

    # !!! INCLUDE FUNCTIONS FROM REPOSITORY HERE !!! (log function is included by default) 
    <include logging/log>

    # !!! WRITE YOUR CODE HERE !!!
    log "`n******************************************`nInfo : script is starting`n******************************************"
    
}
catch{
    $_ # echo the exception
    $message="Error : $description ($_ScriptFullName)" # subject of mails 

    # MAIL
    if ($EmailAlert){
        
        $from="$_HostFQDN"+"@localhost" # sender
        send-mailmessage -SmtpServer $_SMTPServer  -encoding $_enc -subject $message -bodyasHTML  "$($_.Exception.message )<br/><br/> $($_.ScriptStackTrace) " -to $to -from $from #-attachments $logdir\trace2.txt
    }
    
    # EVENTLOG
    if ($EventLogAlert){
        $msg="New message from $(whoami) invoked from $_ScriptFullName :`nError:`n"+$($_.Exception.Message)+"`n"+$($_.ScriptStackTrace |out-string)
        # Create event in application eventlog
        Write-EventLog application -EntryType error -Source $EventSource -eventID 1 -Message $msg
    }
    Log "Error, script did not terminate normaly"
    exit 1
}

log "Success script ended normally`n******************************************"
if ($EventLogAlert){
    Write-EventLog application -EntryType Information -Source $EventSource -eventID 0 -Message "Success Script ended normally"
}  

exit 0
'@    

    $scriptBody |Out-File $TemplatePath -Append
    Write-Output "Template successfully created in $Templatepath"
    
}
catch{
    log "A fatal error occured : $($_.Exception.message)"
    # MAIL
    $message="Error : $description ($_ScriptFullName)" # subject of mails
    $from="$_HostFQDN" # sender
    if ($EmailAlert){
        send-mailmessage -SmtpServer $SMTPServer -encoding $_enc -subject $message -bodyasHTML  "$($_.Exception.message )<br/><br/> $($_.ScriptStackTrace) " -to $to -from $from #-attachments $logdir\trace2.txt
    }

    # Create event in application eventlog
    if ($EventLogAlert){
        Write-EventLog application -EntryType error -Source $EventSource -eventID 2 -Message $msg
    }   
    Write-Output "Error, script did not terminate normaly"
    exit 1
}






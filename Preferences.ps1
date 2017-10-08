<# Adjust default variables if needed#>

#Paths
$_TemplateRepository= join-path "$_ScriptPath" -childpath "Templates"
$_FunctionRepository=join-path "$_ScriptPath" -childpath "Functions"

#Error Handling
$_env="DEV" #choose the default environment (PROD or DEV)
$_EmailAlert=$true
$_EventLogAlert=$false # set to $true if you want to log the fatal error in Application EventLog


#Email
$_SMTPServer="localhost"
$_to='user@domain.tld' # email recipients  you can use several addresses like this 'user1@dom.com','user2@dom.com'  
$_enc='[system.text.encoding]::UTF8' # encoding for mail

#EventLog
$_PRODSource="POWERSHELL_PROD"
$_DEVSource="POWERSHELL_DEV"
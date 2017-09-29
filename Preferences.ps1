<# Adjust default variables if needed#>

#Paths
$_TemplateRepository= join-path "$_ScriptPath" -childpath "Templates"
$_FunctionRepository=join-path "$_ScriptPath" -childpath "Functions"

#Email
$_SMTPServer="smtp.domain.com"
$_enc=[system.text.encoding]::UTF8 # encoding for mail

#EventLog
$_PRODSource="POWERSHELL_PROD"
$_DEVSource="POWERSHELL_DEV"
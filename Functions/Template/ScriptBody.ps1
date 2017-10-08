# ERROR HANDLING
# Choose your environment : DEV while testing your code or PROD in production 
# This will permit to create custom repsonse to fatal errors 
$ErrorActionPreference='STOP' # make all errors terminating ones so they can be catch
$Env="<%$_env%>"
$EmailAlert=<%$_EmailAlert%> # set it to $true if you want to send fatal error by email
$EventLogAlert=<%$_EventLogAlert%>
$to="<%$_to%>"

$description='Describe the script main object' #The description will be use in the email subject if $EmailAlert is enable
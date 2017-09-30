<# 
 .Synopsis
  Log message to file and display it on screen with basic colour hilights.
  The function include a log rotate feature.
 .Description
  Write $msg to screen and file with additional informations : date and time, 
  name of the script from where the function was called, line number and user who ran the script.
  If logfile path isn't specified it will default to current working directory and with name <scriptname>.ps1.log
  You can use $Maxsize and $MaxFile to specified the size and number of logfiles to keep (default is 3MB, and 3files)
  Use the switch $NoEcho if you dont want the message be displayed on screen
 .Parameter Msg 
  The message to log
 .Parameter Logfile
  Name of the logfile to use (default = <scriptname>.ps1.log)
 .Parameter Logdir
  Path to the logfile's directory (defaut = current working dir)
 .Parameter NoEcho 
  Don't print message on screen
 .Parameter MaxSize
  Maximum size (in bytes) before logfile is rotate (default is 3MB)
 .Parameter MaxFile
  Number of logfile history to keep (default is 3)
 .Example
  log "A message to display on screen and file"
 .Example
  log "this message will not appear on screen" -NoEcho
 .Link
  https://github.com/kayasax/PowershellTemplate
 .Notes
 	Changelog :
    * 30/09/2017 version initiale	
 	Todo : 
#>
function log{
    [CmdletBinding()]
    param(
        [string]$Msg,
        $Logfile = "",
        $Logdir="",# Path to logfile
        [switch]$NoEcho, # if set dont display output to screen, only to logfile
        $MaxSize = 3145728, # 3MB
        #$MaxSize = 1,
        $Maxfile = 3 # how many files to keep
    )

    # When no logfile is specified use script path and append .log to the scriptname 
    if( "" -eq $logfile ){ 
        if($null -eq $MyInvocation.ScriptName){
            $dir=resolve-path $MyInvocation.InvocationName |Select-Object -ExpandProperty path
        }
        else{
            $dir=$MyInvocation.ScriptName
        }

        $logfile =  $(Split-Path -Leaf $dir)+".log"
    }
  
    # Create folder if needed
    if( ("" -ne $logdir) -and !(test-path  $logdir) ){
        $null=New-Item -ItemType Directory -Path $logdir  -Force
    }
    
    # Ensure logfile will be save in logdir
    if( $logfile -notmatch [regex]::escape($logdir)) {
        $logfile=join-path "$logdir" -childpath "$logfile"
    }
    
    # Create file
    if( !(Test-Path $logfile) ){
        write-verbose "$logfile not found, creating it"
        $null=New-Item -ItemType file $logfile -Force  
    }
    else{ # file exists, do size exceeds limit ?
        if ( (Get-ChildItem $logfile | select -expand length) -gt $Maxsize){
            Write-Verbose "Logfile exceeds Maxsize, create a new file"
            Write-Output "$(Get-Date -Format yyy-MM-dd-HHmm) - $(whoami) - $($MyInvocation.ScriptName) (L $($MyInvocation.ScriptLineNumber)) : Log size exceed $MaxSize, creating a new file." >> $logfile 
            
            # rename current logfile
            $LogFileName = split-path $LogFile -leaf
            $basename = Get-ChildItem $LogFile |select -expand basename
            $dirname = Get-ChildItem $LogFile |select -expand directoryname

            Write-Verbose "Rename-Item $LogFileName to $basename-$(Get-Date -format yyyddMM-HHmmss).log"
            Rename-Item $LogFile (join-path $dirname -childpath "$basename-$(Get-Date -format yyyddMM-HHmmss).log")

            # keep $Maxfile  logfiles and delete the older ones
            $filesToDelete = Get-ChildItem  "$dirname\$basename*.log" | Sort-Object LastWriteTime -desc | Select -Skip $Maxfile 
            Write-Verbose "Files to delete : $filesToDelete"
            if( ( $filesToDelete |Measure-Object |Select-Object -ExpandProperty sum ) -gt 0)
            {
                $filesToDelete | remove-item  -force
            }
        }
    }

    Write-Output "$(Get-Date -Format yyy-MM-dd-HHmm) - $(whoami) - $($MyInvocation.ScriptName) (L $($MyInvocation.ScriptLineNumber)) : $msg" >> $logfile

    # Display $msg if $NoEcho is not set
    if( $NoEcho -eq $false){
        #colour it up...
        if( $msg -match "error"){
            write-host $msg -ForegroundColor red
        }
        elseif ($msg -match "warn|warning") {
            write-host $msg -ForegroundColor yellow
        }
        elseif ($msg -match "info|information") {
            write-host $msg -ForegroundColor cyan
        }    
        elseif ($msg -match "succedeed|success|OK" ) {
            write-host $msg -ForegroundColor green
        }
        else{
            write-host $msg 
        }
    }
} #end function log


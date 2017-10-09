<# 
 .Synopsis
  Transform a template (.ps1t) to fonctional script (.ps1)
 .Description
  The goal is to replace the <include> tag with the script content from the function _Functionrepository 
  For example if a line contains <include logging/log> the generated .ps1 will replace this tag with the content
  of log.ps1 found in the logging directory of the function repo
 .Parameter Template
  Name of the template to use 
 .Parameter OutputPath
  Path to the generated script
 .Parameter Force 
  Allow overwriting previously generated script
 .Example
   # Create a test.ps1 script in the current directory from test.ps1t template
   PS>NewScriptFromTemplate test
 .Example
   # Create mytest.ps1 from  mytest.ps1t template  in the output directory c:\temp, overwrite mytest.ps1 file if it exists 
   PS>NewScriptFromTemplate -template mytest -OutputPath c:\temp\mytest.ps1 -force
 .Link
  https://github.com/kayasax/PowershellTemplate
 .Notes
   Changelog
   * 30/09/2017 initial version
#>

[CmdletBinding()] #make script react as cmdlet (-verbose etc..)
param(
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $Template,
    [Parameter(Position=1)]
    [System.string]
    $OutputPath="",
    [Switch]$Force
)

$ErrorActionPreference = "STOP" # Considérer toute erreur comme bloquante afin qu'elle puisse être intercepté

try{
    # load preferences
    $_ScriptFullName=$MyInvocation.myCommand.definition
    $_ScriptPath=split-path -Parent   $_ScriptFullName
    . (join-path (split-path  $_ScriptFullName -Parent  ) -ChildPath 'Preferences.ps1')
    

    # If template extension was not provide, add it
    if( !($Template -match ".+\.ps1t$" )){
        Write-Verbose ".ps1t extenstion was not set, adding it"
         $Template=$Template+'.ps1t'
    }
    # Do template exist ?
    if( !( test-path "$_TemplateRepository\$Template" -PathType Leaf ))
    {
        Throw "Error : The template $Template was not found in $_TemplateRepository !"
    }
    else{write-verbose "template $Template found!"}

    if( $OutputPath -ne "" ){
        write-verbose "specified OutputPath : $OutputPath"
        if( !($OutputPath -match ".+\.ps1$")) {Throw "You must specified a .ps1 file for `$OutputPath parameter"} 
        if (! (Test-Path $OutputPath -PathType leaf) ){ #Create output file if not exists
            $null=New-Item -ItemType File $OutputPath -force 
        }    
    }
    else{ 
        Write-Verbose "No Outputpath specified, using current working directory"
        $OutputPath=$Template -replace('.ps1t','.ps1')
    }
    if( !($force) -and (Test-Path $Outputpath -Type Leaf )){
        Throw "Output file ($OutputPath) allready exists, please use -Force parameter to overwrite it"
    }
    
    write-verbose "Removing previously generated file"
    $null = Remove-Item $OutputPath -force -ErrorAction SilentlyContinue

    $output ="<# This script was automatically generated on $(get-date -Format 'yyyy/MM/dd - HH:mm') with template $Template #>`n`n" | Out-File $OutputPath -Encoding utf8

    $Template_content = Get-Content (join-path "$_TemplateRepository" -ChildPath "$Template")
    $Template_content | ForEach-Object{ 
        #Replace include tag with script content
        if ($_ -match "(^\s*)<include (.*)>") { #find lines begining with the include tag
            $indent=$matches[1] #save the current indentation 
            $include=$matches[2]
            write-verbose "Include found : $include"
            #check if content exist in the function repo
            $function=join-path "$_Functionrepository" -ChildPath "$include.ps1"
            if ( !(Test-Path $function -PathType Leaf)){
                Throw "Error could $function was not found "
            }
            
            $content=get-content  "$function"
           # $matches = $null
            $content |%{
                $line=$_
                if($_ -match '<%(.*)%>'){ #replace variable placeholder with actual value
                    $tag=$Matches[0]
                    Write-Verbose "found variable placeholder: $tag"
                    $variablename=$matches[1] -replace '^\$','' #remove $ char so we can use it in get-variable
                    Write-Verbose "variablename: $variablename"
                    $newvalue = get-variable $variablename -ValueOnly
                    if ($newvalue -is [bool]) {
                        $newvalue = "`$$newvalue"
                    }

                    Write-Verbose "new-value: $newvalue"
                    $newline=$_ -replace [regex]::escape($tag) , $newvalue
                   
                }
                else{

                    $newline=$_
                }
                
                $newcontent+="$newline`n"
            }
            #remove the last new line
            $newcontent[-1] -replace '`n',''
            $output =$indent + [string]::Join("`n", $newcontent) -replace "`n","`n$indent"   #copy function content and maintain indentation
            $newcontent=""
            #write-verbose "$output"
        } 
        else { 
            $output="$_"
        }
        $output | Out-File $OutputPath -Append -Encoding utf8 
    } # End of template parsing
    Write-Host "Success: script was generated in $Outputpath"
}
catch{
     Write-error "Error script ended prematuraly ! `n 
     $($_.exception.message) `n`n
     `t$($_.ScriptStackTrace)"
}

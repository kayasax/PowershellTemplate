[CmdletBinding()] #make script react as cmdlet (-verbose etc..)
param(
    <# Sample parameters
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $service,
    [Parameter(Position=1)]
    [System.string]
    $computername='local'

    Validation  examples : 
    Param( 
        [ValidateSet('Tom','Dick','Jane')]  #choice list
        [String] 
        $Name , 
        [ValidateRange(21,65)] # range
        [Int] 
        $Age , 
        [ValidateScript({Test-Path $_ -PathType 'Container'})]  #validate an existing directory
        [string] 
        $Path 
    )
    #>
)

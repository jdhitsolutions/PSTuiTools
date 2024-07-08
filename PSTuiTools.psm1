
#TODO: handle assembly conflicts on import

#region Main

#dot source the module commands
Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 |
ForEach-Object { . $_.FullName }

#endregion

Function Get-PSTuiTools {
    [cmdletbinding()]
    [OutputType('psTuiTool')]
    Param()

    $mod = Get-Module -Name PSTuiTools
    foreach ($cmd in $mod.ExportedFunctions.Keys) {
        [PSCustomObject]@{
            PSTypeName = 'psTuiTool'
            Name       = $cmd
            Alias      = (Get-Alias -Definition $cmd -ErrorAction SilentlyContinue).name
            Module     = 'PSTuiTools'
            Version    = $mod.Version
            Synopsis   = 'In development'
        }
    }
}
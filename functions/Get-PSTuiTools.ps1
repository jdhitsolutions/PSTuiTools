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
            Synopsis   = $((Get-Help $cmd).Synopsis)
        }
    }
}
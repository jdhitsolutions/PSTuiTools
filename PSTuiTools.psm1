
#region Main

Get-ChildItem -path $PSScriptRoot\functions\*.ps1 |
ForEach-Object { . $_.FullName }

#endregion


Function Get-PSTuiTools {
    [cmdletbinding()]
    Param()

    Get-Command -module PSTuiTools -verb Invoke |
    Select-Object Name,@{Name="Alias";Expression={(Get-Alias -Definition $_.name).name}}
}
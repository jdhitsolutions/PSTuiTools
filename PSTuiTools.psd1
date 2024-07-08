#
# Module manifest for module 'PSTuiTools'
#


@{

    RootModule           = 'PSTuiTools.psm1'
    ModuleVersion        = '0.2.0'
    CompatiblePSEditions = @('Core')
    GUID                 = '06aa991b-490e-44e6-aa6c-4fa9b8f28639'
    Author               = 'Jeff Hicks'
    CompanyName          = 'JDH Information Technology Solutions, Inc.'
    Copyright            = '2023-2024 JDH Information Technology Solutions, Inc.'
    Description          = 'A collection of PowerShell 7.x tools written using Terminal.Gui v1.11. These commands should be run from the console host.'
    PowerShellVersion    = '7.3'
    PowerShellHostName   = 'ConsoleHost'
    RequiredAssemblies   = @('assemblies\NStack.dll', 'assemblies\Terminal.Gui')
    # TypesToProcess = @()
    FormatsToProcess = @('formats\PSTuiTools.format.ps1xml')
    FunctionsToExport    = 'Invoke-ProcessPeeker', 'Invoke-ServiceInfo','Get-TuiCredential','Get-PSTuiTools'
    CmdletsToExport      = ''
    VariablesToExport    = ''
    AliasesToExport      = 'ProcessPeeker', 'ServiceInfo'
    PrivateData          = @{

        PSData = @{
            Tags = @('tui', 'terminal.gui')
            # LicenseUri = ''
            # ProjectUri = ''
            # IconUri = ''
            # ReleaseNotes = ''
            # Prerelease = ''
            # RequireLicenseAcceptance = $false
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # DefaultCommandPrefix = ''

}


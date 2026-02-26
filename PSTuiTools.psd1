#
# Module manifest for module 'PSTuiTools'
#

@{

    RootModule           = 'PSTuiTools.psm1'
    ModuleVersion        = '0.4.0'
    CompatiblePSEditions = 'Core'
    GUID                 = '06aa991b-490e-44e6-aa6c-4fa9b8f28639'
    Author               = 'Jeff Hicks'
    CompanyName          = 'JDH Information Technology Solutions, Inc.'
    Copyright            = '2023-2026 JDH Information Technology Solutions, Inc.'
    Description          = 'A collection of PowerShell 7.x TUI-based tools written using Terminal.Gui v1.19. The commands are intended as reference samples for your TUI related samples. These commands should be run from the  PowerShell console host.'
    PowerShellVersion    = '7.5'
    PowerShellHostName   = 'ConsoleHost'
    RequiredAssemblies   = @()
    # TypesToProcess = @()
    FormatsToProcess     = @('formats\PSTuiTools.format.ps1xml')
    FunctionsToExport    = @(
        'Invoke-ProcessPeeker',
        'Invoke-ServiceInfo',
        'Get-TuiCredential',
        'Get-PSTuiTools',
        'Invoke-TuiTemplate',
        'Invoke-TuiColorDemo',
        'Save-TuiAssembly',
        'Invoke-SystemStatus',
        'Invoke-HelloWorld',
        'Invoke-PSTuiTools',
        'Invoke-TuiMp3'
    )
    CmdletsToExport      = ''
    VariablesToExport    = ''
    AliasesToExport      = @(
        'ProcessPeeker',
        'ServiceInfo',
        'TuiTemplate',
        'TuiStatus',
        'TuiColorDemo',
        'helloworld',
        'pstuitools',
        'tuimp3'
    )
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


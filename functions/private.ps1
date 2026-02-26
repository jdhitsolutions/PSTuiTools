#private helper functions

Function ShowAbout {
    [CmdletBinding()]
    Param()
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Starting $($MyInvocation.MyCommand)"
    #$TerminalGuiVersion = [System.Reflection.Assembly]::GetAssembly([Terminal.Gui.Application]).GetName().version
`   #7 Nov 2025 Pull the product version from the assembly file
    $TerminalGuiVersion = (Get-Item ([System.Reflection.Assembly]::GetAssembly([Terminal.Gui.Application]).location)).VersionInfo.ProductVersion -split "\+" | Select-Object -first 1
    $NStackVersion = [System.Reflection.Assembly]::GetAssembly([NStack.UString]).GetName().version

    $about = @"

          PSTuiTools: $((Get-Module PSTuiTools).version)
           PSVersion: $($PSVersionTable.PSVersion)
        Terminal.Gui: $TerminalGuiVersion
              NStack: $NStackVersion
"@

    $dialog = [Terminal.Gui.Dialog]@{
        Title         = 'About PSTuiTools'
        TextAlignment = 'Left'
        Width         = 40
        Height        = 12
        Text          = $about
    }
    $ok = [Terminal.Gui.Button]@{
        Text = 'OK'
    }
    $ok.Add_Clicked({ $dialog.RequestStop() })
    $dialog.AddButton($ok)
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Invoking dialog"
    [Terminal.Gui.Application]::Run($dialog)

#Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Show message box"
# Replaced 24 Feb 2024 with a dialog which allows for better formatting
#[Terminal.Gui.MessageBox]::Query('About Open-PSWorkItemConsole', $About, @('Ok'))
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Ending $($MyInvocation.MyCommand)"
}

Function ShowMp3About {
    [CmdletBinding()]
    Param()
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Starting $($MyInvocation.MyCommand)"
    #$TerminalGuiVersion = [System.Reflection.Assembly]::GetAssembly([Terminal.Gui.Application]).GetName().version
`   #7 Nov 2025 Pull the product version from the assembly file
    $TerminalGuiVersion = (Get-Item ([System.Reflection.Assembly]::GetAssembly([Terminal.Gui.Application]).location)).VersionInfo.ProductVersion -split "\+" | Select-Object -first 1
    $NStackVersion = [System.Reflection.Assembly]::GetAssembly([NStack.UString]).GetName().version
    $TagLibVersion = [System.Reflection.Assembly]::GetAssembly([TagLib.File]).GetName().Version

    $about = @"

          PSTuiTools: $((Get-Module PSTuiTools).version)
           PSVersion: $($PSVersionTable.PSVersion)
        Terminal.Gui: $TerminalGuiVersion
              NStack: $NStackVersion
         TagLibSharp: $TagLibVersion
"@

    $dialog = [Terminal.Gui.Dialog]@{
        Title         = 'About Invoke-TuiMP3'
        TextAlignment = 'Left'
        Width         = 40
        Height        = 12
        Text          = $about
    }
    $ok = [Terminal.Gui.Button]@{
        Text = 'OK'
    }
    $ok.Add_Clicked({ $dialog.RequestStop() })
    $dialog.AddButton($ok)
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Invoking dialog"
    [Terminal.Gui.Application]::Run($dialog)

#Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Show message box"
# Replaced 24 Feb 2024 with a dialog which allows for better formatting
#[Terminal.Gui.MessageBox]::Query('About Open-PSWorkItemConsole', $About, @('Ok'))
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Ending $($MyInvocation.MyCommand)"
}

Function OpenFile {
    [CmdletBinding(  )]
    Param(
        [string]$Title ="Open File",
        #specify the allowed file types
        [string]$Filter = ".*",
        #specify the starting folder
        [string]$Path = $Home,
        [Switch]$MultiSelect
    )
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Starting $($MyInvocation.MyCommand)"
    $Dialog = [Terminal.Gui.OpenDialog]::new($Title, '')
    $Dialog.CanChooseDirectories = $false
    $Dialog.CanChooseFiles = $true
    $Dialog.AllowsMultipleSelection = $MultiSelect

    $Dialog.DirectoryPath = $Path
    $Dialog.AllowedFileTypes = @($Filter)
    [Terminal.Gui.Application]::Run($Dialog)
    If (-Not $Dialog.Canceled -AND $dialog.FilePath.ToString()) {
        #return the path of the selected file
        $dialog.FilePath.ToString()
    }
    Write-Verbose "[$((Get-Date).TimeOfDay) PRIVATE] Starting $($MyInvocation.MyCommand)"
}
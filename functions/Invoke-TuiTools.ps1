#requires -version 7.5

using namespace Terminal.Gui

#display PSTuiTools in a TUI

function Invoke-PSTuiTools {
    [cmdletbinding()]
    [OutputType('None')]
    [Alias('PSTuiTools')]
    param()

    #region initialize
    #You MUST invoke Init()
    [Application]::Init()
    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'

    $tools = Get-PSTuiTools
    $helpInfo = @{}
    foreach ($t in $tools) {
        $helpText = (Get-Help $t.name).Description.Text | Out-String
        $helpInfo.Add($t.Name, $helpText )
    }
    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = "PSTuiTools v$(($tools)[0].Version)"
    }

    #endregion

    #region add controls

    $x = 3
    $y = 1
    $tab = 0

    $note = [Label]@{
        X       = $x
        Y       = $y
        TabStop = $False
        Text    = @'
Tab or use the arrow keys to navigate the list of TUIs in this module. This will update the help
description. Pressing Enter on a command name will launch the TUI. When that TUI finishes this TUI
will be re-shown. Click the Quit button or use the Alt+Q shortcut to quit.

The commands Get-PSTuiTools,Invoke-PSTuiTools, and Save-TuiAssembly will be skipped and not invoked
although you will see the help description.
'@
    }
    $window.Add($note)

    $Y = $note.Frame.Bottom + 1
    $x++

    $header = [Textfield]@{
        X       = $x
        Y       = $Y
        TabStop = $False
        Width   = [dim]::Percent(85)
        Text    = 'Command                  Alias                Synopsis'
    }
    $window.Add($header)
    $y++

    <#
    Because I am using a closure on the Enter event, I need to define the help frame
    and description view before I create the event. At least, that seems to be how
    this works.
    #>
    $helpFrame = [FrameView]@{
        x       = 2
        Y       = $header.Frame.Bottom + $tools.count + 1#20
        Width   = [dim]::Percent(85)
        Height  = 7
        TabStop = $False
        Title   = 'Description'
    }
    $txtDescription = [TextView]@{
        X         = 1
        Y         = 1
        Width     = [dim]::Percent(98)
        Height    = [dim]::Percent(98)
        AutoSize  = $True
        Multiline = $True
        WordWrap  = $True
        ReadOnly  = $True
        TabStop   = $False
        Text      = 'Command help description goes here'
    }
    $n = [Terminal.Gui.Attribute]::new('White', 'Blue')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $cs.Focus = $n
    $txtDescription.ColorScheme = $cs
    $helpFrame.Add($txtDescription)
    #dynamically add controls
    foreach ($tool in $tools) {
        $varName = "lbl_$($tool.Name)"
        Set-Variable -Name $varName -Value ([Label]@{
                X        = $x
                Y        = $Y
                TabStop  = $true
                TabIndex = $tab
                CanFocus = $True
                Text     = $Tool.Name
            })

        #Add click event
        $control = (Get-Variable $varName).Value
        $window.Add($control)

        $control.Add_Enter({
                $helpFrame.Title = $control.Text.ToString()
                $txtDescription.Text = $helpInfo[$control.Text.ToString()]
                $txtDescription.TextFormatter.NeedsFormat = $True
                [Application]::Refresh()
            }.GetNewClosure())
            $control.Add_KeyDown({
                param($e)
                if ( ($e.KeyEvent.Key -eq 'Enter') -AND ($control.Text.ToString() -notMatch '\-(TuiAssembly)|(PSTuiTools)' )) {
                    [Application]::RequestStop()
                    [Application]::ShutDown()
                    & $control.Text.ToString()
                    #re-run this command
                    & Invoke-PSTuiTools
                    break
                }
            }.GetNewClosure())

        #alias
        $varAlias = "alias_$($tool.Name)"
        Set-Variable -Name $varAlias -Value ([Label]@{
                X    = 25
                Y    = $Y
                Text = "$($Tool.alias)"
            })
        $window.Add((Get-Variable $varAlias).Value)

        #synopsis
        $varHelp = "alias_$($tool.Synopsis)"
        Set-Variable -Name $varHelp -Value ([Label]@{
                X    = 25 + 16
                Y    = $Y
                Text = "$($Tool.synopsis)"
            })
        $window.Add((Get-Variable $varHelp).Value)
        #bump values
        $Y++
        $tab++
    }

    $y++

    $window.Add($helpFrame)

    $btnQuit = [Button]@{
        #set the position relative to the Copy button
        X        = 3
        Y        = $helpFrame.Frame.Bottom + 1
        TabIndex = $tab
        TabStop  = $True
        Text     = '_Quit'
    }

    $btnQuit.Add_Clicked({
            #stop the TUI application
            [Application]::RequestStop()
        })

    $window.Add($btnQuit)

    #endregion

    #region display
    #Add the Window and its nested controls to the TUI application
    [Application]::Top.Add($window)
    #Invoke the TUI
    [Application]::Run()
    #When the TUI ends it will shutdown
    [Application]::ShutDown()

    #endregion
}


using namespace Terminal.Gui

function Invoke-TuiColorDemo {
    [cmdletbinding()]
    [Alias('TuiColorDemo')]
    param()

    if ($host.name -ne 'ConsoleHost') {
        Write-Warning 'This should be run in a PowerShell console host.'
        return
    }

    #region initialize

    [Application]::Init()
    [Application]::QuitKey = 27 #ESC

    #helper function to update displayed code snippet
    function refreshCode {
        @"
`$new = [Terminal.Gui.Attribute]::new('{0}', '{1}')
`$cs = [Terminal.Gui.ColorScheme]::new()
`$cs.Focus = `$new
`$cs.Normal = `$new
`$cs.HotNormal = `$new
`$Window.ColorScheme = `$cs
"@ -f $src[$comboFore.SelectedItem], $src[$comboBack.SelectedItem]
    }

    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = 'TUI Color Demonstration'
    }

    #update the status bar on Window loaded
    $window.Add_Loaded({
        $fg = $src[$comboFore.SelectedItem]
        $bg = $src[$comboBack.SelectedItem]
        $n = [Terminal.Gui.Attribute]::new($fg, $bg)
        $cs = [Terminal.Gui.ColorScheme]::new()
        $cs.focus = $n
        $cs.normal = $n
        $cs.HotNormal = $n
        $cs.Disabled = $n
        $Window.ColorScheme = $cs
        [Application]::Refresh()
        #save original color scheme
        $script:savedColor = $window.ColorScheme
        })

    $window.Add_LayoutComplete({
        $StatusBar.Items[2].Title = "Foreground: $($src[$($comboFore.SelectedItem)]) Background: $($src[$($comboBack.SelectedItem)])"
        $StatusBar.Items[0].Title = Get-Date -Format g
        })

    #define a color scheme for the window
    <#
    Valid colors:
    Black
    Blue
    BrightBlue
    BrightCyan
    BrightGreen
    BrightMagenta
    BrightRed
    BrightYellow
    Brown
    Cyan
    DarkGray
    Gray
    Green
    Magenta
    Red
    White
    #>

    $StatusBar = [StatusBar]::New(
        @(
            [StatusItem]::New('Unknown', $(Get-Date -Format g), {}),
            [StatusItem]::New('Unknown', 'ESC to quit', {}),
            [StatusItem]::New('Unknown', 'Ready', {})
        )
    )

    [Application]::Top.add($StatusBar)

    #endregion

    #region add controls

    $tvHowTo = [TextView]@{
        X             = 1
        Y             = 1
        Multiline     = $True
        TextAlignment = 'Left'
        ReadOnly      = $True
        Visible       = $True
        width         = [Dim]::Percent(90)
        Height        = 2
        TabStop       = $False
        Text          = @'
Select color options and click the Try It button. Color rendering will depend on the
terminal's color scheme. Use the arrow keys to select different colors.
'@
    }
    $window.Add($tvHowTo)

    $lblFG = [Label]@{
        X       = 1
        Y       = $tvHowTo.Frame.Bottom +1
        TabStop = $False
        Text    = 'Foreground:'
    }

    $window.Add($lblFG)

    $src = [System.Collections.Generic.list[string]]::New()
    $src.AddRange([string[]]([enum]::GetNames([Terminal.gui.color])))
    $comboFore = [Combobox]@{
        Visible  = $true
        Width    = 15
        Height   = 10
        ReadOnly = $True
        X        = $lblFG.Frame.Width + 2
        Y        = $lblFG.Y
        TabIndex = 0
        TabStop  = $True
    }

    $comboFore.SetSource($src)
    $comboFore.SelectedItem = $src.FindIndex({ $args[0] -eq 'White' })
    $comboFore.Add_MouseEnter({
        $comboFore.Expand()
        $codeFrame.Visible = $False
        [Application]::Refresh()
        })
    $comboFore.Add_MouseLeave({
        $comboFore.Collapse()
        $codeFrame.Visible = $True
        [Application]::Refresh()
        })

    $comboFore.add_KeyPress({
        param($e)
        switch ($e.KeyEvent.Key) {
            'CursorDown' {
                #if at the bottom of the list start at the top
                if ($comboFore.SelectedItem -eq $comboFore.Source.Count - 1) {
                    $comboFore.SelectedItem = 0
                }
                else {
                    $comboFore.SelectedItem = $comboFore.SelectedItem + 1
                }
            }
            'CursorUp' {
                #if at the top of the list start at the bottom
                if ($comboFore.SelectedItem -eq 0) {
                    $comboFore.SelectedItem = $comboFore.Source.Count - 1
                }
                else {
                    $comboFore.SelectedItem = $comboFore.SelectedItem - 1
                }
            }
            'Tab' {
                #because I'm catching keys, I have to code tabbing
                $comboBack.SetFocus()
            }
            'BackTab' {
                $btnTry.SetFocus()
            }
            default {
                #for future use
            }
        }

        $comboFore.SetNeedsDisplay()
        [Application]::Refresh()
        $e.handled = $True
        })

    $comboFore.Add_SelectedItemChanged({
        $StatusBar.Items[2].Title = "Foreground: $($src[$($comboFore.SelectedItem)]) Background: $($src[$($comboBack.SelectedItem)])"
        $comboFore.SetNeedsDisplay()
        $txtSample.Text = refreshCode
        [Application]::Refresh()
        })
    $window.Add($comboFore)

    $lblBG = [Label]@{
        X       = $comboFore.Frame.Width + $lblFG.Frame.Width + 3
        Y       = $lblFG.Y
        TabStop = $False
        Text    = 'Background:'
    }
    $window.Add($lblBG)

    $comboBack = [Combobox]@{
        Visible  = $true
        Width    = 15
        Height   = 10
        X        = $comboFore.Frame.Width + $lblFG.Frame.Width + $lblBG.Frame.Width + 4
        Y        = $lblBG.Y
        TabIndex = 1
        TabStop  = $True
    }

    $comboBack.SetSource($src)
    $comboBack.SelectedItem = $src.FindIndex({ $args[0] -eq 'Blue' })
    $comboBack.Add_SelectedItemChanged({
        $StatusBar.Items[2].Title = "Foreground: $($src[$($comboFore.SelectedItem)]) Background: $($src[$($comboBack.SelectedItem)])"
        $comboBack.SetNeedsDisplay()
        $txtSample.Text = refreshCode
        [Application]::Refresh()
        })
    $comboBack.Add_MouseEnter({
        $comboBack.Expand()
        $codeFrame.Visible = $False
        [Application]::Refresh()
        })
    $comboBack.Add_MouseLeave({
        $comboBack.Collapse()
        $codeFrame.Visible = $True
        [Application]::Refresh()
        })
    $comboBack.add_KeyPress({
        param($e)
        #$comboBack.SelectedItem = -1
        switch ($e.KeyEvent.Key) {
            'CursorDown' {
                #if at the bottom of the list start at the top
                if ($comboBack.SelectedItem -eq $comboBack.Source.Count - 1) {
                    $comboBack.SelectedItem = 0
                }
                else {
                    $comboBack.SelectedItem = $comboBack.SelectedItem + 1
                }
            }
            'CursorUp' {
                #if at the top of the list start at the bottom
                if ($comboBack.SelectedItem -eq 0) {
                    $comboBack.SelectedItem = $comboBack.Source.Count - 1
                }
                else {
                    $comboBack.SelectedItem = $comboBack.SelectedItem - 1
                }
            }
            'BackTab' {
                $comboFore.SetFocus()
            }
            'Tab' {
                $btnTry.SetFocus()
            }
            default {
                #for future use
            }
        }
        $comboBack.SetNeedsDisplay()
        [Application]::Refresh()
        $e.handled = $True
    })
    $window.add($comboBack)

    #display a code sample text box
    $txtSample = [TextView]@{
        X             = 1
        Y             = 1
        Multiline     = $True
        Visible       = $True
        Height        = 6
        Width         = 60
        TextAlignment = 'Left'
        ReadOnly      = $True
        TabStop       = $False
        Text          = refreshCode
    }

    $codeFrame = [FrameView]@{
        X       = 1
        Y       = 6 #$comboFore.Frame.Bottom + 2
        Width   = 60
        Height  = 10
        TabStop = $False
        Title   = 'Sample Reference Code'
    }
    $codeFrame.Add($txtSample)
    $window.Add($codeFrame)

    $btnTry = [Button]@{
        X        = 1
        Y        = $codeFrame.Frame.Bottom
        Text     = '_Try It!'
        TabIndex = 2
    }
    $btnTry.Add_Clicked({
        $StatusBar.Items[2].Title = 'Refreshing color selections'
        $txtSample.Text = refreshCode
        $fg = $src[$comboFore.SelectedItem]
        $bg = $src[$comboBack.SelectedItem]
        $n = [Terminal.Gui.Attribute]::new($fg, $bg)
        $cs = [Terminal.Gui.ColorScheme]::new()
        $cs.focus = $n
        $cs.normal = $n
        $cs.HotNormal = $n
        $cs.Disabled = $n
        $Window.ColorScheme = $cs
        [Application]::Refresh()
        $StatusBar.Items[2].Title = "Foreground: $($src[$($comboFore.SelectedItem)]) Background: $($src[$($comboBack.SelectedItem)])"
        $StatusBar.Items[0].Title = $(Get-Date -Format g)
        [Application]::Refresh()
        })
    $window.Add($btnTry)

    $btnReset = [Button]@{
        X        = $btnTry.X + $btnTry.Frame.Width + 2
        Y        = $btnTry.Y
        Text     = '_Reset'
        TabIndex = $btnTry.TabIndex+1
    }

    $btnReset.Add_Clicked({
        $window.ColorScheme.Disabled = $script:savedColor.Disabled
        $window.ColorScheme.Focus = $script:savedColor.Focus
        $window.ColorScheme.HotFocus = $script:savedColor.HotFocus
        $window.ColorScheme.HotNormal = $script:savedColor.HotNormal
        $window.ColorScheme.Normal = $script:savedColor.Normal
        $comboFore.SelectedItem = $src.FindIndex({ $args[0] -eq 'White' })
        $comboBack.SelectedItem = $src.FindIndex({ $args[0] -eq 'Blue' })
        [Application]::Refresh()
        })
    $window.Add($btnReset)

    $btnQuit = [Button]@{
        X        = $btnReset.X + $btnReset.Frame.Width + 2
        Y        = $btnTry.Y
        Text     = '_Quit'
        TabIndex = $btnReset.TabIndex+1
    }

    $btnQuit.Add_Clicked({[Application]::RequestStop()})
    $window.Add($btnQuit)
    #endregion

    #region display
    [Application]::Top.Add($window)
    [Application]::Run()
    [Application]::ShutDown()

    #endregion
}
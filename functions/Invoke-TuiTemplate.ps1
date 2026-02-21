using namespace Terminal.Gui

#Get the path to this file. You don't need this in your project.
$dir = Split-Path $MyInvocation.MyCommand.source -Parent
$script:templatePath = Join-Path -Path $dir -ChildPath .\tui-template.ps1

#define your own function
function Invoke-TuiTemplate {
    [cmdletbinding()]
    [Alias('TuiTemplate')]
    param()

    If ($host.name -ne 'ConsoleHost') {
        Write-Warning 'This should be run in a PowerShell console host.'
        Return
    }
    #region initialize
    #You MUST invoke Init()
    [Application]::Init()
    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'

    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = 'My TUI Template'
    }

    <# Use this code if you want to customize the Window color scheme
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
                                       New(Foreground,Background)
        $n = [Terminal.Gui.Attribute]::new('BrightYellow', 'Black')
        $cs = [ColorScheme]::new()
        $cs.normal = $n
        $Window.ColorScheme = $cs
    #>

    #Create a status bar at the bottom of the TUI
    $StatusBar = [StatusBar]::New(
        @(
            [StatusItem]::New('Unknown', $(Get-Date -Format g), {}),
            [StatusItem]::New('Unknown', 'ESC to quit', {}),
            [StatusItem]::New('Unknown', 'Ready', {})
        )
    )

    #Add the control to the application
    [Application]::Top.Add($StatusBar)

    #endregion

    #region add controls

    $lblHello = [Label]@{
        #X and Y are relative positions in the window
        X    = 1
        Y    = 1
        Text = 'Hello World'
    }
    #add the control to the window
    $window.Add($lblHello)

    $btnDemo = [Button]@{
        X        = 1
        Y        = 4
        Text     = 'Click _Me'
        TabIndex = 0
    }

    #define an action when the button is clicked
    $btnDemo.Add_Clicked({
            $lblHello.Text = 'I clicked a button!'
            $StatusBar.Items[2].Title = 'I am doing something'
            [Application]::Refresh()
            Start-Sleep -Seconds 2
            $lblHello.Text = 'Hello World'
            $StatusBar.Items[2].Title = 'Ready'
            $StatusBar.Items[0].Title = $(Get-Date -Format g)
            [Application]::Refresh()
        })
    $window.Add($btnDemo)

    $btnCopy = [Button]@{
        X        = $btnDemo.Frame.Width + 2
        Y        = 4
        Text     = '_Copy Code to Clipboard'
        TabIndex = 1
    }

    $btnCopy.Add_Clicked({
            Get-Content $script:templatePath | Set-Clipboard
            $StatusBar.Items[2].Title = 'Template code has been copied to the clipboard'
            [Application]::Refresh()
            Start-Sleep -Seconds 2
            $StatusBar.Items[2].Title = 'Ready'
            $StatusBar.Items[0].Title = $(Get-Date -Format g)
            [Application]::Refresh()
        })
    $window.Add($btnCopy)

    $btnQuit = [Button]@{
        #set the position relative to the Copy button
        X    = $btnCopy.Frame.Right + 1
        Y    = $btnCopy.Y
        Text = '_Quit'
    }

    $btnQuit.Add_Clicked({
            #stop the TUI application
            [Application]::RequestStop()
        })

    $window.Add($btnQuit)

    $codeFrame = [FrameView]@{
        X      = 1
        Y      = $btnDemo.Y + 2
        Width  = [Dim]::Percent(99)
        Height = [Dim]::Percent(80)
        Title  = $script:templatePath
    }

    $tvCode = [TextView]@{
        Text     = Get-Content $script:templatePath | Out-String
        ReadOnly = $True
        x        = 1
        Width    = [Dim]::Fill()
        Height   = [Dim]::Fill()
    }

    $n = [Terminal.Gui.Attribute]::new('BrightGreen', 'black')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $cs.HotNormal = $n
    $cs.Focus = $n
    $cs.HotFocus = $n
    $cs.Disabled = $n
    $tvCode.ColorScheme = $cs

    $codeFrame.Add($tvCode)
    $window.Add($codeFrame)

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
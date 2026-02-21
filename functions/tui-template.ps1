#requires -version 7.5

using namespace Terminal.Gui

#TODO: Add code to load the required assemblies if not already loaded

#define your TUI function
function Verb-Noun {
    [cmdletbinding()]
    [Alias('vn')]
    param()

    #region initialize
    #You MUST invoke Init()
    [Application]::Init()
    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'

    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = "My Window Title"
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

    $btnQuit = [Button]@{
        #set the position relative to the Copy button
        X    = $btnDemo.Frame.Right + 1
        Y    = $btnDemo.Y
        Text = '_Quit'
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
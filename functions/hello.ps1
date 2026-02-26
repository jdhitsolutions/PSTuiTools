#requires -version 7.5

using namespace Terminal.Gui

#TODO: Add code to load the required assemblies if not already loaded

#define your TUI function
function Invoke-HelloWorld {
    [cmdletbinding()]
    [Alias('HelloWorld')]
    param()

    #region initialize
    #You MUST invoke Init()
    [Application]::Init()
    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'

    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = "Hello World"
    }

    #endregion

    #region add controls

    $lblHello = [Label]@{
        #X and Y are relative positions in the window
        X    = 1
        Y    = 1
        Text = "Hello, $([System.Environment]::UserName)"
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
            $lblHello.Text = "So glad to meet you! It is now $(Get-Date). Resetting in 5 seconds."
            [Application]::Refresh()
            Start-Sleep -Seconds 5
            $lblHello.Text =  "Hello, $([System.Environment]::UserName)"
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
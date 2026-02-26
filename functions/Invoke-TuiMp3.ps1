using namespace Terminal.Gui

# A sample MP3 player TUI

function Invoke-TuiMp3 {
    [cmdletbinding()]
    [OutputType("None")]
    [Alias('tuimp3')]
    param(
        [parameter(Position = 0, HelpMessage = 'Specify the path to an MP3 file.')]
        [Alias('Path')]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('\.mp3$', ErrorMessage = '{0} does not appear to be an MP3 file.')]
        [ValidateScript({ Test-Path -Path $_ }, ErrorMessage = 'Failed to find or validate {0}.')]
        [string]$FilePath,

        [Parameter(HelpMessage = 'Specify the window title.')]
        [validateNotNullOrEmpty()]
        [string]$Title = 'Mp3 Player',

        [Parameter(HelpMessage = "Specify the default folder to open for MP3 files.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ }, ErrorMessage = 'Failed to find or validate {0}.')]
        [string]$DefaultLibrary = $HOME
    )

    if ($IsLinux -or $IsMacOS) {
        Write-Warning 'This command requires a Windows platform.'
        return
    }

    #region initialize
    #need this type for the media player
    Add-Type -AssemblyName PresentationCore
    $MediaPlayer = New-Object System.Windows.Media.MediaPlayer

    $ver = $((Get-Module PSTuiTools).version)
    #You MUST invoke Init()
    [Application]::Init()
    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'

    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = $Title
    }

    <#
    add an event handler to stop the player when
    the window closes if running
    #>

    $window.Add_Unloaded({
        if ($script:isPlaying) {
            $MediaPlayer.Stop()
        }
    })

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
            [StatusItem]::New('Unknown', "v$Ver", {}),
            [StatusItem]::New('Unknown', 'Ready', {})
        )
    )

    #Add the control to the application
    [Application]::Top.Add($StatusBar)

    #endregion

    #region add menu

    #the menu bar actions are running private helper functions

    $MenuItem0 = [MenuItem]::New('_Open File', '', {
        $open = OpenFile -filter .mp3 -path $DefaultLibrary
        if ($open) {
            #update the field if a file was selected
            $txtFile.Text = $open
        }
    })
    $MenuItem1 = [MenuItem]::New('_Quit', '', { quitMP3 })
    $MenuBarItem0 = [MenuBarItem]::New('_File', @($MenuItem0, $MenuItem1))

    $MenuItem3 = [MenuItem]::New('_Documentation', '', { ShowMp3Help })
    $MenuItem4 = [MenuItem]::New('_About', '', { ShowMp3About })
    $MenuBarItem1 = [MenuBarItem]::New('_Help', @($MenuItem3, $MenuItem4))

    $MenuBar = [MenuBar]::New(@($MenuBarItem0, $MenuBarItem1))
    $Window.Add($MenuBar)
    #endregion

    #region add controls

    $txtFile = [TextField]@{
        #X and Y are relative positions in the window
        X           = 1
        Y           = 2
        Width       = [Dim]::Percent(80)
        Height      = 1
        ColorScheme = $window.ColorScheme
        Text        = 'Select an MP3 file from the menu'
    }
    $n = [Terminal.Gui.Attribute]::new('White', 'Blue')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $cs.Focus = $n
    $txtFile.ColorScheme = $cs

    $txtFile.Add_TextChanged({ UpdateMP3Info })
    #add the control to the window
    $window.Add($txtFile)

    $progFrame = [FrameView]@{
        X      = 2
        Y      = 4
        Width  = [Dim]::Percent(50)
        Height = 5
        Title  = ''
    }

    $progBar = [ProgressBar]@{
        X                 = 1
        Y                 = 1
        ProgressBarFormat = 'SimplePlusPercentage'
        ProgressBarStyle  = 'Continuous'
        Fraction          = 0
        Width             = [Dim]::Percent(98)
    }

    $progBar.Add_MouseClick({
            param($m)
            $totalSeconds = $MediaPlayer.NaturalDuration.TimeSpan.TotalSeconds
            if ($totalSeconds -gt 0) {
                $clickX = $m.MouseEvent.X
                $fraction = $clickX / $progBar.Frame.Width
                $newPosition = [TimeSpan]::FromSeconds($fraction * $totalSeconds)
                $MediaPlayer.Position = $newPosition
                if ($script:isPlaying) { $MediaPlayer.Play() }
                $progBar.Fraction = $fraction
                [Application]::Refresh()
            }
        }.GetNewClosure())

    $progFrame.Add($progBar)
    # use a timeout token instead
    $script:timeoutToken = $null

    # Define the update action as a scriptblock returning $true to repeat
    $updateProgress = {
        $totalSeconds = $MediaPlayer.NaturalDuration.TimeSpan.TotalSeconds
        if ($totalSeconds -gt 0) {
            $progBar.Fraction = $MediaPlayer.Position.TotalSeconds / $totalSeconds
        }
        else {
            $progBar.Fraction = 0
        }
        $status = '{0} - {1:mm\:ss}' -f $(Split-Path $MediaPlayer.Source.LocalPath -leaf), $MediaPlayer.Position
        $StatusBar.Items[2].Title = $status
        $StatusBar.Items[0].Title = ((Get-Date -format g))
        if ($MediaPlayer.Position.TotalSeconds -ge $totalSeconds) {
            $script:timeoutToken = $null
            $script:isPlaying = $false
            $MediaPlayer.Stop()   # reset position so Play() restarts from beginning
            $progBar.Fraction = 0
            $StatusBar.Items[2].Title = 'Finished'
            [Application]::Refresh()
            return $false  # stop repeating
        }
        return $true  # keep repeating
    }.GetNewClosure()

    $window.Add($progFrame)

    $tvInfo = [TextView]@{
        X         = 62 #$progFrame.Frame.Width + 2
        Y         = $progFrame.Y - 1
        Width     = 60
        Height    = 10
        Multiline = $true
        Visible   = $False
        Text      = @'
'@
    }
    $tvInfo.ColorScheme = $cs

    $window.add($tvInfo)

    $btnPlay = [Button]@{
        X        = 1
        Y        = $progFrame.Frame.Bottom + 2
        Text     = '_Play'
        TabIndex = 0
    }

    #define an action when the button is clicked
    $btnPlay.Add_Clicked({
        $script:isPlaying = $true
        $MediaPlayer.Play()
        $StatusBar.Items[0].Title = $(Get-Date -Format g)
        $StatusBar.Items[2].Title = "Playing $(Split-Path $MediaPlayer.Source.LocalPath -leaf)"
        $progFrame.Title = $script:musicTitle
        # Register a 1-second repeating callback on the main loop
        if ($null -eq $script:timeoutToken) {
            $script:timeoutToken = [Application]::MainLoop.AddTimeout(
                [TimeSpan]::FromSeconds(1), $updateProgress)
        }
        [Application]::Refresh()
    })
    $window.Add($btnPlay)

    $btnPause = [Button]@{
        X        = $btnPlay.Frame.Right + 1
        Y        = $btnPlay.Y
        Text     = 'Pa_use'
        TabIndex = 0
    }
    $btnPause.Add_Clicked({
        $script:isPlaying = $false
        $MediaPlayer.Pause()
        if ($null -ne $script:timeoutToken) {
            [Application]::MainLoop.RemoveTimeout($script:timeoutToken)
            $script:timeoutToken = $null
        }
        $StatusBar.Items[2].Title = "$script:MusicTitle - Paused"
        $StatusBar.Items[0].Title = $(Get-Date -Format g)
        [Application]::Refresh()
    })
    $window.Add($btnPause)
    $btnStop = [Button]@{
        X        = $btnPause.Frame.Right + 1
        Y        = $btnPlay.Y
        Text     = '_Stop'
        TabIndex = 0
    }
    $btnStop.Add_Clicked({
        $script:isPlaying = $false
        $MediaPlayer.Stop()
        if ($null -ne $script:timeoutToken) {
            [Application]::MainLoop.RemoveTimeout($script:timeoutToken)
            $script:timeoutToken = $null
        }
        $progBar.Fraction = 0
        $StatusBar.Items[0].Title = $(Get-Date -Format g)
        $StatusBar.Items[2].Title = 'Stopped'
        [Application]::Refresh()
    })
    $window.Add($btnStop)

    $btnQuit = [Button]@{
        #set the position relative to the Copy button
        X    = $btnStop.Frame.Right + 1
        Y    = $btnPlay.Y
        Text = '_Quit'
    }

    $btnQuit.Add_Clicked({quitMP3})

    $window.Add($btnQuit)

    $txtLyrics = [TextView]@{
        X         = $btnQuit.X +5
        Y         = $btnQuit.Frame.Bottom + 1
        Width     = [Dim]::Percent(95)
        Height    = 25
        Multiline = $True
        Visible   = $false
        WordWrap  = $True
        Text      = 'scooby dooby doo'
    }

    $txtLyrics.ColorScheme = $cs

    $window.Add($txtLyrics)
    #endregion

    #region display
    #Update the form if a file was specified
    if ($PSBoundParameters.ContainsKey('FilePath')) {
        $txtFile.Text = (Convert-Path $PSBoundParameters['FilePath'])
        UpdateMP3Info
    }
    #Add the Window and its nested controls to the TUI application
    [Application]::Top.Add($window)
    #Invoke the TUI
    [Application]::Run()
    #When the TUI ends it will shutdown
    [Application]::ShutDown()

    #endregion
}

#helper functions
function ShowMp3Help {
    #define help information
    [CmdletBinding()]
    param()

    $title = 'TUI MP3 player Help'

    $help = @'

 If you didn't specify the path to an MP3 file when you launched this
 TUI, you can select one from the File menu. Use the file dialog to
 navigate to a folder and select an MP3 file.

 Select file properties will be displayed.

 Use the buttons to play the file. You can also click in the progress
 bar to jump ahead and backwards. The highlighted letters are shortcut
 keys, i.e. Alt+P or Alt+Q.

 If the file has lyrics, they will be displayed.

 Use the Quit button or menu choice to exit.
'@
    $dialog = [Dialog]@{
        Title         = $title
        TextAlignment = 'Left'
        Width         = 75
        Height        = 30
        Text          = $help
    }
    $ok = [Terminal.Gui.Button]@{
        Text = 'OK'
    }
    $ok.Add_Clicked({ $dialog.RequestStop() })
    $dialog.AddButton($ok)
    [Application]::Run($dialog)

}

#get mp3 information
function getMP3Info {
    [cmdletbinding()]
    param([string]$Path)
    $file = [TagLib.File]::Create((Convert-Path $Path))
    Write-Information $file
    [PSCustomObject]@{
        Path     = $file.Name
        Size     = (Get-Item $File.Name).Length
        Duration = New-TimeSpan -Seconds $file.Properties.Duration.TotalSeconds
        Title    = $file.Tag.Title
        Subtitle = $file.Tag.Subtitle
        Album    = $file.Tag.Album
        Track    = $file.Tag.Track
        Year     = $file.Tag.Year
        Genre    = $file.Tag.JoinedGenres
        Artist   = $file.Tag.JoinedArtists
        Lyrics   = $file.Tag.Lyrics
    }
}

#refresh MP3 info
function updateMP3Info {
    $script:FilePath = $txtFile.Text.toString()
    $script:musicTitle = Split-Path $script:FilePath -Leaf
    $ProgFrame.title = $script:musicTitle
    $MediaPlayer.Open($script:FilePath)
    $StatusBar.Items[2].Title = "Loaded $script:FilePath"

    #update details
    $script:mp3Info = getMP3Info $txtFile.Text.ToString()
    $tvInfo.Text = $script:mp3Info | Format-List Title, Subtitle, Album, Track, Year, Genre, Artist, Duration | Out-String
    $tvInfo.Visible = $True

    if ($script:mp3Info.Lyrics) {
        $txtLyrics.Visible = $True
        #expand lyrics
        $txtLyrics.Text = $script:mp3Info.Lyrics -replace "\r","`n"
    }
    else {
        $txtLyrics.Visible = $False
    }
    [Application]::Refresh()
}

Function quitMP3 {
    if ($MediaPlayer.position.totalSeconds -ge 1) {
        $MediaPlayer.Stop()
    }

    if ($null -ne $script:timeoutToken) {
        [Application]::MainLoop.RemoveTimeout($script:timeoutToken)
        $script:timeoutToken = $null
    }
    [Application]::RequestStop()
}
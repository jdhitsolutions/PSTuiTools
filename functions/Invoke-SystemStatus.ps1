using namespace Terminal.Gui

function Invoke-SystemStatus {
    [cmdletbinding()]
    [Alias('TuiStatus')]
    param(
        [Parameter(Position = 0, HelpMessage = 'The name of the computer to monitor. You must have admin rights.')]
        [Alias('CN')]
        [ValidateNotNullOrEmpty()]
        [string]$Computername = $env:COMPUTERNAME,

        [Parameter(HelpMessage = 'Alternate credentials for a remote computer.')]
        [Alias('RunAs')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(HelpMessage = 'Specify the window foreground color. The background will be Black.')]
        [Alias('color')]
        [ValidateNotNullOrEmpty()]
        [Terminal.Gui.Color]$WindowColor = 'BrightYellow'
    )

    if ($IsMacOS -OR $IsLinux) {
        Write-Warning "This command requires a Windows platform."
        return
    }
    If ($host.name -ne 'ConsoleHost') {
        Write-Warning 'This should be run in a PowerShell console host.'
        Return
    }
    #region initialize
    #define the main Window title here
    $windowTitle = 'System Status Report'

    #Emojis don't always display as expected.
    #Not all of these will be used in this function
    $gear = '⚙'
    $wrench = '🔧'
    $info = 'ℹ'
    $disk = '💽'

    #helper functions
    function ConvertTo-DataTable {
        [cmdletbinding()]
        [OutputType('System.Data.DataTable')]
        param(
            [Parameter(
                Mandatory,
                Position = 0,
                ValueFromPipeline
            )]
            [ValidateNotNullOrEmpty()]
            [object]$InputObject
        )

        begin {
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
            $data = [System.Collections.Generic.List[object]]::New()
            $Table = [System.Data.DataTable]::New('PSData')
        } #begin

        process {
            $Data.Add($InputObject)
        } #process

        end {
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Building a table of $($data.count) items"
            #define columns
            foreach ($item in $data[0].PSObject.Properties) {
                Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Defining column $($item.name)"
                [void]$table.Columns.Add($item.Name, $item.TypeNameOfValue)
            }
            #add rows
            for ($i = 0; $i -lt $Data.count; $i++) {
                $row = $table.NewRow()
                foreach ($item in $Data[$i].PSObject.Properties) {
                    $row.Item($item.name) = $item.Value
                }
                [void]$table.Rows.Add($row)
            }
            #This is a trick to return the table object
            #as the output and not the rows
            , $table
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
        } #end

    } #close ConvertTo-DataTable
    function GetData {
        param()

        $splat = @{
            Computername = $txtCN.Text.ToString()
            ErrorAction  = 'Stop'
        }
        if ($credential) {
            $splat.Add('Credential', $Credential)
        }
        elseif (($txtUser.Text.length -gt 0) -and ($txtPass.Text.length -gt 0)) {
            $pw = ConvertTo-SecureString -String $($txtPass.Text.ToString()) -AsPlainText -Force
            $username = $txtUser.Text.ToString()
            $tmpCred = [PSCredential]::new($username, $pw)
            $splat.Add('Credential', $tmpCred)
        }

        try {
            $cimSess = New-CimSession @splat

            $script:online = $True
            $script:cDrive = Get-CimInstance Win32_LogicalDisk -Property Size, Freespace -Filter "DeviceID='C:'" -CimSession $cimSess
            $script:os = Get-CimInstance Win32_OperatingSystem -Property FreePhysicalMemory, TotalVisibleMemorySize, LastBootUpTime, Caption, OSArchitecture -CimSession $cimSess
            $script:svc = Get-CimInstance Win32_Service -Filter "State='Running'" -Property Name -CimSession $cimSess
            $script:cs = Get-CimInstance Win32_ComputerSystem -Property SystemFamily, Manufacturer, Model -CimSession $cimSess
            $script:proc = Get-CimInstance Win32_Process -Property ProcessID, Name, WorkingSetSize, CreationDate -CimSession $cimSess
            $script:topProc = $script:proc | Sort-Object -Property WorkingSetSize -Descending | Select-Object -First 10 -Property @{Name = 'ID'; Expression = { $_.ProcessID } },
            Name,
            @{Name = 'Runtime'; Expression = { '{0:dd\.hh\:mm\:ss}' -f (New-TimeSpan -Start $_.CreationDate -End (Get-Date)) } },
            @{Name = 'WS(M)'; Expression = { $_.WorkingSetSize / 1MB -as [int] } }
            $script:hardware = $script:cs.SystemFamily ? $script:cs.SystemFamily : "$($script:cs.Manufacturer): $($script:cs.Model)"
            $script:uptime = New-TimeSpan -Start $script:os.LastBootUpTime -End (Get-Date)
            #this code has not been validated against a machine with multiple physical processors
            $script:cpu = Get-CimInstance Win32_Processor -Property LoadPercentage, Name, NumberOfCores, NumberOfLogicalProcessors -CimSession $cimSess

            Remove-CimSession $cimSess

        }
        catch {
            $script:online = $false
            $StatusBar.Items[2].Title = "Failed to get system information from $($splat.Computername)"
            $tvInfo.Text = 'Error: {0}' -f $_.Exception.Message
            $n = [Terminal.Gui.Attribute]::new('BrightRed', 'Black')
            $cs = [ColorScheme]::new()
            $cs.disabled = $n
            $cs.HotNormal = $n
            $tvInfo.ColorScheme = $cs
            [Application]::Refresh()
        }

        #clear credentials
        if ($txtUser.Text.Length -gt 0) {
            $txtUser.Text = ''
        }
        if ($txtPass.Text.Length -gt 0) {
            $txtPass.Text = ''
        }
    }
    function refresh {
        param()

        $CN = $txtCN.Text.ToString()
        $StatusBar.Items[2].Title = "Refreshing system information from $CN"

        $tvInfo.Text = ''
        $lblRun.Text = ''
        $lblUsed.Text = ''
        $progC.Fraction = 0
        $progC.Visible = $False
        $progMem.Visible = $False
        $progCPU.Visible = $false
        $lblCPU.Text = ''
        $lblCPULoad.Text = ''
        $lblMemUsed.Text = ''
        $tableView.Table = ''
        $TableView.SetNeedsDisplay()
        $procFrame.SetNeedsDisplay()

        [application]::Refresh()
        GetData
        if ($script:online) {

            $tvInfo.Text = @"

$($script:os.Caption)
$($script:hardware)
$($script:os.OSArchitecture)
"@

            $n = [Terminal.Gui.Attribute]::new('BrightGreen', 'Black')
            $cs = [ColorScheme]::new()
            $cs.normal = $n
            $cs.Disabled = $n
            $tvInfo.ColorScheme = $cs

            $lblRun.Text = @'

 Running Processes: {0}
 Running Services : {1}
 System Uptime    : {2:dd\.hh\:mm\:ss}
'@ -f $script:proc.count, $script:svc.count, $script:Uptime

            $TableView.table = $script:topProc | ConvertTo-DataTable
            #set table style
            $tableStyle = [TableView+TableStyle]@{
                ShowVerticalCellLines         = $False
                ShowVerticalHeaderLines       = $False
                AlwaysShowHeaders             = $True
                ShowHorizontalHeaderOverline  = $False
                ShowHorizontalHeaderUnderline = $True
                ExpandLastColumn              = $False
            }
            $tableStyle.ColumnStyles.Add(
                $TableView.Table.Columns['ID'],
                [TableView+ColumnStyle]@{
                    Alignment = 'Left'
                    MinWidth  = 6
                }
            )
            $tableStyle.ColumnStyles.Add(
                $TableView.Table.Columns['Name'],
                [TableView+ColumnStyle]@{
                    Alignment = 'Left'
                    MinWidth  = 15
                    MaxWidth  = 30
                }
            )
            $tableStyle.ColumnStyles.Add(
                $TableView.Table.Columns['WS(M)'],
                [TableView+ColumnStyle]@{
                    Alignment = 'Right'
                    MinWidth  = 5
                }
            )
            $TableView.Style = $tableStyle
            $TableView.SetNeedsDisplay()
            $procFrame.SetNeedsDisplay()

            $cUsed = $script:cDrive.size - $Script:cDrive.Freespace
            $progC.Fraction = $cUsed / $script:cDrive.Size
            $lblUsed.Text = 'Used: {0:N2}GB          Free: {1:n2}GB' -f ($cUsed / 1gb), ($script:cDrive.Freespace / 1gb)
            $progC.Visible = $True

            #FreePhysicalMemory, TotalVisibleMemorySize
            $memUsed = $script:os.TotalVisibleMemorySize - $script:os.FreePhysicalMemory
            $progMem.Fraction = $memUsed / $script:os.TotalVisibleMemorySize
            $lblMemUsed.Text = 'Used: {0:N2}GB          Free: {1:n2}GB' -f ($memUsed / 1mb), ($script:os.FreePhysicalMemory / 1mb)
            $progMem.Visible = $True

            $progCPU.Visible = $True
            $progCPU.Fraction = $script:cpu.LoadPercentage / 100
            $lblCPU.Text = $script:cpu.Name
            $lblCPULoad.Text = 'Load: {0}% Cores: {1} Logical CPUs: {2}' -f $script:cpu.LoadPercentage, $script:cpu.NumberOfCores, $script:cpu.NumberOfLogicalProcessors
        } #online
        else {
            #items should have already been cleared
        }

        [Application]::Refresh()
    } #refresh

    function Stop-RefreshTimer {
        if ($script:refreshToken) {
            [Application]::MainLoop.RemoveTimeout($script:refreshToken)
            $script:refreshToken = $null
        }
    }

    function Start-RefreshTimer {
        $seconds = $script:refreshDefaultSeconds

        $script:refreshToken = [Application]::MainLoop.AddTimeout(
            [TimeSpan]::FromSeconds($Seconds),
            {
                refresh
                $StatusBar.Items[2].Title = 'Ready'
                $StatusBar.Items[0].Title = "Last update: $(Get-Date -Format T)"
                [Application]::Refresh()
                $true
            }
        )
    }

    [Application]::Init()
    [Application]::QuitKey = 'Esc'

    #endregion

    #region create the main window and status bar
    $window = [Window]@{
        Title = $windowTitle
    }
    $window.add_Loaded({
            refresh
            $StatusBar.Items[2].Title = 'Ready'
            $script:refreshToken = $null
            $script:refreshDefaultSeconds = $txtInterval.text.ToString()
        })

    #customize the Window color
    $n = [Terminal.Gui.Attribute]::new($WindowColor, 'Black')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $Window.ColorScheme = $cs

    $StatusBar = [StatusBar]::New(
        @(
            [StatusItem]::New('Unknown', "Last update: $(Get-Date -Format T)", {}),
            [StatusItem]::New('Unknown', 'ESC to quit', {}),
            [StatusItem]::New('Unknown', 'Ready', {})
        )
    )

    #Set the status bar color the same as the window
    $StatusBar.ColorScheme = $cs

    [Application]::Top.add($StatusBar)

    #endregion

    #region add controls

    #region computername
    $lblCN = [Label]@{
        X    = 1
        Y    = 1
        Text = 'Computername:'
    }
    $window.Add($lblCN)

    $txtCN = [TextField]@{
        X     = $lblCN.Frame.Width + 2
        Y     = 1
        Width = 20
        Text  = $Computername.ToUpper()
    }

    $txtCN.Add_TextChanged({
            $txtCN.Text = $txtCN.Text.ToUpper()
        })

    $window.Add($txtCN)
    #endregion

    #region alternate credentials
    $CredentialFrame = [FrameView]@{
        X      = 1
        Y      = 2
        width  = 35
        Height = 4
        Title  = 'Credentials'
    }

    $lblUser = [Label]@{
        Text = 'Username:'
        X    = 1
        Y    = 0
    }
    $CredentialFrame.Add($lblUser)

    $txtUser = [TextField]@{
        X     = $lblUser.Frame.Width + 2
        Y     = $lblUser.Y
        Width = 25
    }
    $CredentialFrame.Add($txtUser)

    $lblPass = [Label]@{
        Text = 'Password:'
        X    = 1
        Y    = 1
    }
    $CredentialFrame.Add($lblPass)
    $txtPass = [TextField]@{
        X      = $lblUser.Frame.Width + 2
        Y      = $lblPass.Y
        Width  = 25
        Secret = $True
    }
    $CredentialFrame.Add($txtPass)

    $Window.Add($CredentialFrame)
    #endregion

    #region info view
    $tvInfo = [TextView]@{
        X        = $CredentialFrame.Frame.Width + 2
        Y        = 0
        Height   = 5
        Width    = 50
        WordWrap = $True
        ReadOnly = $True
        AutoSize = $True
        Text     = ''
    }

    #set the info text to Green
    $n = [Terminal.Gui.Attribute]::new('Green', 'Black')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $tvInfo.ColorScheme = $cs
    $window.Add($tvInfo)
    #endregion

    #region run info
    $runFrame = [FrameView]@{
        X      = 1
        Y      = $Credential.Frame.Height + 6
        Width  = 35
        Height = 7
        Title  = 'ℹ  Run Information'
    }

    $lblRun = [Label]@{
        Text = @'

 Running Processes: {0}
 Running Services : {1}
 System Uptime    : {2:dd\.hh\:mm\:ss}
'@ -f 0, 0, 0
    }
    $n = [Terminal.Gui.Attribute]::new('BrightCyan', 'Black')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $lblRun.ColorScheme = $cs
    $runFrame.Add($lblRun)
    $window.Add($runFrame)
    #endregion

    #region process info
    $procFrame = [FrameView]@{
        X        = 1
        Y        = $runFrame.Frame.Height + 6
        Width    = 60
        Height   = 15
        AutoSize = $True
        Title    = "$gear  Top 10 Processes"
    }

    #define a table
    $TableView = [TableView]@{
        X             = 1
        Y             = 1
        Width         = [Dim]::Fill()
        Height        = [Dim]::Fill()
        TabStop       = $False
        MultiSelect   = $False
        FullRowSelect = $True
        TextAlignment = 'Center'
    }

    $n = [Terminal.Gui.Attribute]::new('BrightMagenta', 'Black')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $TableView.ColorScheme = $cs

    $procFrame.Add($TableView)

    $window.Add($procFrame)
    #endregion

    #region physical info
    $physFrame = [FrameView]@{
        X      = $procFrame.Frame.Width + 2
        Y      = $runFrame.Y - 3
        Width  = 52
        Height = 15
        Title  = '🌟Physical Information'
    }

    $lblDisk = [Label]@{
        X    = 1
        Y    = 1
        Text = 'Disk Usage C:\'
    }
    $physFrame.Add($lblDisk)

    $progC = [ProgressBar]@{
        X                 = 1
        Y                 = 2
        Text              = 'C:\'
        Fraction          = 1
        # Simple, SimplePlusPercentage, Framed, FramedPlusPercentage, FramedProgressPadded
        ProgressBarFormat = 'simple'
        #Blocks, Continuous, MarqueeBlocks, MarqueeContinuous""
        ProgressBarStyle  = 'continuous'
        Width             = $physFrame.Frame.width - 5
    }
    $n = [Terminal.Gui.Attribute]::new('red', 'green')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $progC.ColorScheme = $cs
    $physFrame.Add($progC)

    $lblUsed = [Label]@{
        X    = 5 #$progC.X + 1
        Y    = $progC.y + 1
        Text = 'Used: {0}GB          Free: {1}GB' -f 0, 0
    }
    $physFrame.Add($lblUsed)

    $lblMem = [Label]@{
        X    = $lblDisk.X
        Y    = $lblUsed.Y + 2
        Text = 'Memory Usage'
    }
    $physFrame.Add($lblMem)

    $progMem = [ProgressBar]@{
        X                 = 1
        Y                 = $lblMem.Y + 1
        Text              = 'Memory'
        Fraction          = 1
        # Simple, SimplePlusPercentage, Framed, FramedPlusPercentage, FramedProgressPadded
        ProgressBarFormat = 'simple'
        #Blocks, Continuous, MarqueeBlocks, MarqueeContinuous""
        ProgressBarStyle  = 'continuous'
        Width             = $physFrame.Frame.width - 5
    }
    $n = [Terminal.Gui.Attribute]::new('red', 'green')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $progMem.ColorScheme = $cs

    $physFrame.Add($progMem)
    $lblMemUsed = [Label]@{
        X    = 5
        Y    = $progMem.y + 1
        Text = 'Used: {0}GB          Free: {1}GB' -f 0, 0
    }
    $physFrame.Add($lblMemUsed)

    $lblCPU = [Label]@{
        X    = 1
        Y    = $lblMemUsed.Y + 2
        Text = 'CPU Load:'
    }

    $physFrame.Add($lblCPU)
    $progCPU = [ProgressBar]@{
        X                 = 1
        Y                 = $lblCpu.Y + 1
        Text              = 'LoadPercentage'
        Fraction          = 0
        # Simple, SimplePlusPercentage, Framed, FramedPlusPercentage, FramedProgressPadded
        ProgressBarFormat = 'simple'
        #Blocks, Continuous, MarqueeBlocks, MarqueeContinuous""
        ProgressBarStyle  = 'continuous'
        Width             = $physFrame.Frame.width - 5
    }
    $n = [Terminal.Gui.Attribute]::new('red', 'green')
    $cs = [ColorScheme]::new()
    $cs.normal = $n
    $progCPU.ColorScheme = $cs
    $physFrame.Add($progCPU)

    $lblCPULoad = [Label]@{
        X    = 5
        Y    = $progCPU.Y + 1
        Text = 'LoadPercentage'
    }
    $physFrame.Add($lblCPULoad)
    $window.Add($physFrame)
    #endregion

    #region help info
    $usage = @'
 Instructions:
 Enter a computer name and alternate credentials
 if necessary. Click the Refresh button or the
 Alt+R shortcut to manually refresh information.

 You can also set an automatic refresh interval.
 Click the Timer button to stop and start. If you
 change the computer, you should stop the timer
 first. Restart it after changing the computer name.

 Use the Quit button or Alt+Q to exit.

 Click these instructions to hide them.
'@

    $showUsage = @'





                Click to show help
'@
    $txtHelp = [TextView]@{
        X        = $procFrame.Frame.Right + 1
        Y        = $physFrame.Frame.Bottom
        Width    = [Dim]::Percent(80)
        Height   = 14
        ReadOnly = $True
        Text     = $usage
    }
    $script:showUsage = $True
    $window.Add($txtHelp)

    $txtHelp.Add_MouseClick({
            if ($script:showUsage) {
                $txtHelp.Text = $showUsage
                $script:showUsage = $False
            }
            else {
                $txtHelp.Text = $usage
                $script:showUsage = $True
            }
            [Application]::Refresh()
        })

    #endregion

    #region buttons
    $btnRefresh = [Button]@{
        X        = 1
        Y        = 30
        Text     = 'Refresh'
        TabIndex = 0
    }

    $btnRefresh.Add_Clicked({
            $cn = $txtCN.Text.ToString()
            refresh $cn
            if ($script:online) {
                $StatusBar.Items[2].Title = 'Ready'
            }
            $StatusBar.Items[0].Title = "Last update: $(Get-Date -Format T)"
            [Application]::Refresh()
        })
    $window.Add($btnRefresh)

    $btnQuit = [Button]@{
        X        = $btnRefresh.Frame.Width + 2
        Y        = 30
        Text     = '_Quit'
        TabIndex = 1
    }

    $btnQuit.Add_Clicked({
            [Application]::RequestStop()
        })
    $window.Add($btnQuit)
    #endregion

    #region timer controls
    $lblInterval = [Label]@{
        X    = $runFrame.Frame.Width + 2
        Y    = $runFrame.Frame.Top - 1
        Text = 'Auto refresh (sec):'
    }
    $window.Add($lblInterval)

    $txtInterval = [TextField]@{
        X     = $lblInterval.Frame.Right + 1
        Y     = $lblInterval.Y
        Width = 4
        Text  = '30'
    }
    $script:refreshDefaultSeconds = $txtInterval.Text.ToString()

    $txtInterval.Add_Leave({
            $script:refreshDefaultSeconds = $txtInterval.Text.ToString()
            $StatusBar.Items[2].Title = "Auto refresh set to $script:refreshDefaultSeconds seconds"
            [Application]::Refresh()
            if ($script:refreshToken) {
                $StatusBar.Items[2].Title = 'Restarting Timer'
                Stop-RefreshTimer
                Start-RefreshTimer
            }
            else {
                Start-Sleep -Seconds 2
                $StatusBar.Items[2].Title = 'Ready'
            }
            [Application]::Refresh()
        })
    $window.Add($txtInterval)

    $btnSetTimer = [Button]@{
        X        = $lblInterval.X
        Y        = $txtInterval.Y + 1
        Text     = 'Start Timer'
        TabIndex = 2
    }
    $btnSetTimer.Add_Clicked({
            #toggle the button text
            if ($btnSetTimer.Text.ToString() -match 'Start') {
                $btnSetTimer.Text = 'Stop Timer'
                $seconds = $txtInterval.Text.ToString()
                $txtInterval.Text = $seconds.ToString()
                Start-RefreshTimer
                $StatusBar.Items[2].Title = "Starting $seconds seconds refresh timer"
            }
            else {
                $btnSetTimer.Text = 'Start Timer'
                Stop-RefreshTimer
            }
            [Application]::Refresh()
        })
    $window.Add($btnSetTimer)

    #endregion

    #endregion controls

    #region display

    [Application]::Top.Add($window)
    [Application]::Run()
    [Application]::ShutDown()

    #endregion
}


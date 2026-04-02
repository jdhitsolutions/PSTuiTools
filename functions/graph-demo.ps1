using namespace Terminal.Gui

function Invoke-TuiGraphDemo {
    [cmdletbinding()]
    [Alias('tuiGraph')]
    [OutputType("None")]
    param()

    #region initialize
    #You MUST invoke Init()
    [Application]::Init()

    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'

    #endregion
    #region create the main window and status bar
    $window = [Window]@{
        Title = 'TUI Bar Chart Demo'
    }

    #Create a status bar at the bottom of the TUI
    $StatusBar = [StatusBar]::New(
        @(
            [StatusItem]::New('Unknown', $(Get-Date -Format g), {}),
            [StatusItem]::New('Unknown', 'ESC or Alt+Q to quit', {}),
            [StatusItem]::New('Unknown', 'Ready', {})
        )
    )

    [Application]::Top.Add($StatusBar)
    #endregion

    #region add controls

    <#
        [Graphs.BarSeries]	The series that holds all bars
        [Graphs.BarSeries+Bar]	A nested type - one bar per data entry
        $bar.ColorScheme.Normal	Sets the fill color for each bar
        $barSeries.BarSpacing = 3	Blank columns between each bar
        $graphView.CellSize	Maps data units -> screen cells; controls bar height scaling
        $graphView.AxisY.Increment = 10	Y-axis tick every 10 units
        [Graphs.LegendAnnotation]	Floating legend box showing keys + values
        # Wider bars -- increase the first PointF argument
        $graphView.CellSize = [PointF]::new(2, ...)

        # Move the legend -- args are (X, Y, Width, Height) in graph cell units
        [Rect]::new(1, 1, 12, $chartData.Count + 2)
    #>

    #I'm using percentages in the demo
    $chartData = [ordered]@{
        ps1    = 22
        psd1   = 11
        psm1   = 11
        txt    = 17
        json   = 5
        yml    = 3
        ps1xml = 2
        xml    = 4
        png    = 12
        md     = 16
    }

    # Graph at the top of the window
    $graphView = [GraphView]@{
        X            = 1
        Y            = 1
        Width        = 100
        Height       = $chartData.count + 2
        CanFocus     = $false   # prevents keyboard scrolling
        MarginLeft   = 0
        MarginBottom = 1
    }

    # For a horizontal bar chart:
    #   AxisX = the value axis (numbers)  -- shown along the bottom
    #   AxisY = the category axis (labels) -- shown on the left

    #I'm adjusting where the X axis starts so things align nicer
    #AxisX is a graphView property
    $graphView.AxisX.Minimum = 1.4
    $graphView.AxisX.Text = '% Usage (0-100)'
    $graphView.AxisX.Increment = 5   # tick every 5% on a 0-100 scale
    #Although I'm hiding the Axis lines for this demo. You can enable them
    #if you want to see them.
    $graphView.AxisX.Visible = $false

    #AxisY is a graphView property
    $graphView.AxisY.Minimum = 0
    $graphView.AxisY.Text = 'Extension'
    $graphView.AxisY.Visible = $False
    $graphView.AxisY.Increment = 1

    $graphView.CellSize = [Terminal.Gui.PointF]::new(.5, 1)

    # Pin the view so X=0 is always the left edge
    $graphView.ScrollOffset = [Terminal.Gui.PointF]::new(0, 0)

    # Build a horizontal BarSeries
    $barSeries = [Graphs.BarSeries]::new()
    $barSeries.Orientation = [Graphs.Orientation]::Horizontal
    $barSeries.OffSet = 0    # blank rows between bars

    $fills = @(
        [Terminal.Gui.Attribute]::new('Cyan', 'Black'),
        [Terminal.Gui.Attribute]::new('BrightGreen', 'Black'),
        [Terminal.Gui.Attribute]::new('BrightYellow', 'Black'),
        [Terminal.Gui.Attribute]::new('BrightCyan', 'Black'),
        [Terminal.Gui.Attribute]::new('Brown', 'Black')
        [Terminal.Gui.Attribute]::new('Green', 'Black')
        [Terminal.Gui.Attribute]::new('Magenta', 'Black')
        [Terminal.Gui.Attribute]::new('Red', 'Black')
        [Terminal.Gui.Attribute]::new('BrightMagenta', 'Black')
        [Terminal.Gui.Attribute]::new('Gray', 'Black')
    )

    #what is the longest extension name? Will use this later for padding.
    $maxKeyLen = ($chartData.Keys | Measure-Object -Maximum -Property Length).Maximum

    $i = 0
    foreach ($key in $chartData.Keys) {
        #get a color from the array of fills
        $cell = [Graphs.GraphCellToRender]::new([System.Char]0x2588, $fills[$i % $fills.Count])
        #scale the values
        #pad the text in the bar
        $bar = [Graphs.BarSeries+Bar]::new($key.PadRight($maxKeyLen + 1), $cell, ($chartData[$key] * 2))
        $barSeries.Bars.Add($bar)
        $i++
    }

    #add the bars to the graph view
    $graphView.Series.Add($barSeries)

    $window.Add($graphView)

    # Legend directly below the graph
    $lblLegend = [Label]@{
        X    = 1
        Y    = $graphView.Frame.Bottom + 1
        Text = 'Legend:'
    }
    $window.Add($lblLegend)

    $i = 0
    foreach ($key in $chartData.Keys) {
        $lbl = [Label]@{
            X    = 3
            Y    = $lblLegend.Frame.Bottom + $i
            Text = ([System.Char]0x2588).ToString() + "  $key  ($($chartData[$key])%)"
        }
        # Apply the matching bar color to the legend swatch
        $cs = [ColorScheme]::new()
        $cs.Normal = $fills[$i % $fills.Count]
        $lbl.ColorScheme = $cs
        $window.Add($lbl)
        $i++
    }

    $btnQuit = [Button]@{
        X    = [pos]::Center()
        Y    = $lblLegend.Frame.Bottom + $chartData.Count + 1
        Text = '_Quit'
    }

    $btnQuit.Add_Clicked({[Application]::RequestStop()})

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
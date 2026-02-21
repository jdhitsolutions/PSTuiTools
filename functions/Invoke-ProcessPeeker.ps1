using namespace Terminal.Gui
function Invoke-ProcessPeeker {
    [cmdletbinding()]
    [alias('ProcessPeeker')]
    param()

    If ($host.name -ne 'ConsoleHost') {
        Write-Warning 'This should be run in a PowerShell console host.'
        Return
    }
    #Get process information
    $AllProcesses = Get-Process -IncludeUserName |
    Where-Object { $_.name -notmatch 'Idle|System' }

    $ProcessHash = $AllProcesses | Group-Object -Property ID -AsHashTable -AsString

    $list = [System.Collections.Generic.List[object]]::New()
    $AllProcesses | Select-Object -Property @{Name = 'PID'; Expression = { $_.id.toString().PadRight(7) } }, name |
    ForEach-Object { $list.add("$($_.pid) $($_.Name)") }

    [Application]::Init()
    [Application]::QuitKey = 27  #Esc

    # Create a window to add frames
    $Window = [Window]::New()
    $Window.Title = 'Process Peeker (Esc to quit)'
    $Window.Height = [Dim]::Fill()
    $Window.Width = [Dim]::Fill()

    $Frame1 = [FrameView]::New()
    $Frame1.Width = [Dim]::Percent(35)
    $Frame1.Height = [Dim]::Fill()
    $Frame1.Title = 'Process List'

    $ListView = [ListView]::New()
    $ListView.x = 2
    $ListView.Y = 2
    $listView.Width = [Dim]::Fill()
    $ListView.Height = [Dim]::Fill()
    $listView.AllowsMultipleSelection = $False
    $ListView.SetSource($List)

    #add an event handler when the selected list item changes
    $ListView.Add_SelectedItemChanged({
            $selected = $ListView.Source.ToList()[$listView.SelectedItem]
            [string]$selectedID = $selected.split(' ')[0].Trim()
            $selectedProcess = $($ProcessHash[$SelectedID]).PSObject.properties |
            Where-Object value | Format-Table @{Name = 'Property'; Expression = { $_.Name } }, Value -AutoSize | Out-String
            $txtDetail.Text = $SelectedProcess
        })
    $Frame1.Add($ListView)

    $Window.Add($Frame1)

    $Frame2 = [FrameView]::New()
    $Frame2.Width = [Dim]::Fill()
    #[Dim]::Percent(65)
    $Frame2.Height = [Dim]::Fill()

    # Set position relative to frame1
    $Frame2.X = [Pos]::Right($Frame1)
    $Frame2.Title = 'Process Details'

    $Label1 = [Label]::New()
    $Label1.Text = 'Select a process to view its details.'
    $Label1.Height = 1
    $Label1.Width = 20
    $Frame1.Add($Label1)

    $txtDetail = [TextView]::New()
    $txtDetail.Text = 'Select a process and details will appear here'
    $txtDetail.ReadOnly = $True
    $txtDetail.x = 1
    $txtDetail.Width = [Dim]::Fill()
    $txtDetail.Height = [Dim]::Fill()

    #change the color scheme of the text view
    $n = [Terminal.Gui.Attribute]::new('BrightGreen', 'Black')
    $cs = [Terminal.Gui.ColorScheme]::new()
    $cs.focus = $n
    $cs.Disabled = $n
    $TxtDetail.ColorScheme = $cs
    $Frame2.Add($txtDetail)

    $Window.Add($Frame2)

    [Application]::Top.Add($Window)
    [Application]::Run()
    [Application]::Shutdown()
}
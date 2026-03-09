# https://gui-cs.github.io/Terminal.GuiV1Docs/docs/treeview.html

using namespace Terminal.Gui

#define your TUI function
function Invoke-TuiTreeDemo {
    [cmdletbinding()]
    [Alias('tuiTree')]

    param(
        [Parameter(position = 0, HelpMessage = 'Specify a path to display.')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ }, ErrorMessage = 'Failed to find or validate {0}.')]
        [ValidateScript({ (Get-Item $_).PSProvider.Name -eq 'FileSystem' }, ErrorMessage = 'The path {0} does not appear to be a filesystem location.')]
        [String]$Path = $Home,

        [Parameter(HelpMessage = 'Specify the number of levels to display. The higher the value the longer it will take to display the tree.')]
        [ValidateRange(1, 7)]
        [int]$Depth = 4
    )

    #region initialize
    #convert to a file system path
    $Path = (Convert-Path $Path)

    #You MUST invoke Init()
    [Application]::Init()
    #I recommend setting a QuitKey
    [Application]::QuitKey = 'Esc'
    #endregion

    #region helper functions
    function toggle {
        param()
        if ($btnToggle.Text.ToString() -match 'Expand') {
            $tree.ExpandAll()
            $btnToggle.Text = 'Collapse All'
            $btnQuit.X = $btnQuit.X + 2
        }
        else {
            $tree.CollapseAll()
            $btnToggle.Text = 'Expand All'
            $btnQuit.X = $btnQuit.X - 2
        }
        [Application]::Refresh()
    }

    # Helper function to create tree nodes from directory structure
    function New-DirectoryTree {
        param(
            [string]$Path,
            [int]$MaxDepth = $Depth,
            [int]$CurrentDepth = 0,
            [switch]$IsRoot
        )

        if ($CurrentDepth -ge $MaxDepth) { return $null }

        try {
            $item = Get-Item -LiteralPath $Path -ErrorAction Stop

            # Create node for this item
            $node = [Trees.TreeNode]::new($item.Name)
            $node.Tag = $item.FullName
            $StatusBar.items[0].Title = "Loading $($item.Fullname)"
            [Application]::Refresh()
            if ($isRoot) {
                $node.Text = $item.FullName.ToUpper()
            }
            if ($item.PSIsContainer) {
                # If it's a directory, add children
                $children = Get-ChildItem -LiteralPath $Path -ErrorAction SilentlyContinue
                foreach ($child in $children) {
                    $childNode = New-DirectoryTree -Path $child.FullName -MaxDepth $Depth -CurrentDepth ($CurrentDepth + 1)
                    if ($childNode) {
                        [void]($node.Children.Add($childNode))
                    }
                }
            }
            #the function output is the tree
            $node
        }
        catch {
            Write-Warning "Cannot access: $Path"
        }
    }

    function updateDetail {
        param( [string]$Path = $txtPath.Text.ToString()  )

        #a helper for the helper
        function _node {
            param([string]$name)
            [Trees.TreeNode]::new($name)
        }

        $treeDetail.ClearObjects()
        $item = Get-Item $Path
        $node = _node $item.FullName
        #add property nodes
        $node.Children.Add((_node "Created         $($item.CreationTime)"))
        $node.Children.Add((_node "Modified        $($item.LastWriteTime)"))
        $age = '{0:dd\.hh\:mm\:ss}' -f (New-TimeSpan -Start $item.LastWriteTime -End (Get-Date))
        $node.Children.Add((_node "Age             $age"))
        if ($item.PSIsContainer) {
            $node.Children.Add((_node "Root Files      $($item.GetFiles().count)"))
            $node.Children.Add((_node "Root Folders    $($item.GetDirectories().count)"))
            #get total size
            $sz = $item.EnumerateFiles('*', 'AllDirectories') | measure length -Sum
            $node.Children.Add((_node "Total File      $($sz.Count)"))
            $node.Children.Add((_node "Total Size      $($sz.Sum)"))
            if ($sz.sum -ge 1MB) {
                $node.Children.Add((_node "Total Size (MB) $($sz.Sum/1MB -as [int])"))
            }
        }
        else {
            $node.Children.Add((_node "Extension       $($item.Extension)"))
            $node.Children.Add((_node "Size            $($item.Length)"))
            $node.Children.Add((_node "SizeKB          $([int]($item.Length/1KB))"))
            #add file version if detected
            if ($item.VersionInfo.ProductVersion -or $item.VersionInfo.FileInfo) {
                $ver = _node VersionInfo
                #pad names
                $pad = 18
                $item.VersionInfo.PSObject.properties | ForEach-Object {
                    $n = '{0} {1}' -f $_.name.PadRight($pad), $_.Value
                    $ver.Children.Add((_node $n))
                }
                $node.Children.Add($ver)
                Remove-Variable ver
            }
            else {
                switch -regex ($item.Extension) {
                    '(txt)|(md)|(ps(d|m)?1)' {
                        #add text measurements
                        $stat = _node FileStatics
                        $measure = Get-Content $item.FullName -Raw | Measure-Object -Word -Line
                        $stat.children.Add(( _node "Words  $($measure.Words)" ))
                        $stat.children.Add(( _node "Lines  $($measure.Lines)" ))
                        $node.children.add($stat)
                        Remove-Variable stat
                    }
                    'zip' {
                        $zip = _node ZipStatistics
                        #open the zip in read only mode
                        $zipArchive = [System.IO.Compression.ZipFile]::Open($item.FullName, 'Read')
                        #measure the contents
                        $measure = $zipArchive.Entries | Measure-Object -Property Length, CompressedLength -Sum
                        $zip.Children.Add(( _node "Total Entries         $($measure[0].count)" ))
                        $zip.Children.Add(( _node "Total Compressed Size $($measure[1].Sum)" ))
                        $zip.Children.Add(( _node "Total Size            $($measure[0].Sum)" ))
                        $node.Children.Add($zip)
                        #  $zipArchive.Dispose()
                        Remove-Variable zip
                    }
                    '(mp3)|(m4a)' {
                        $pad = 15
                        $media = _node MediaStatistics
                        $tagFile = [Taglib.File]::Create($item.Fullname)
                        $length = '{0:hh\:mm\:ss}' -f $tagFile.Properties.Duration
                        $media.Children.Add((_node "Duration        $length") )
                        ($tagFile.tag | Select-Object Album, title, joinedArtists, year, joinedGenres).PSObject.Properties.ForEach({
                                $media.Children.Add((_node "$($_.Name.PadRight($pad)) $($_.value)"))
                            })
                        $tagFile.Dispose()
                        $node.Children.Add($media)
                        Remove-Variable media
                    }
                '(png)|(bmp)|(gif)|(jp(e)?g)' {
                    $imgNode = _node "ImageDetails"
                    $img = [System.Drawing.Image]::FromFile($item.FullName)
                    $imgNode.Children.Add((_node "Width                 $($img.Width)"))
                    $imgNode.Children.Add((_node "Height                $($img.Height)"))
                    $imgNode.Children.Add((_node "HorizontalResolution  $($img.HorizontalResolution -as [int])"))
                    $imgNode.Children.Add((_node "VerticalResolution    $($img.VerticalResolution -as [int])"))
                    $imgNode.Children.Add((_node "RawFormat             $($img.RawFormat)"))
                    $img.Dispose()
                    $node.Children.Add($imgNode)
                    Remove-Variable imgNode
                }
                } #close Switch
            }

        }
        $node.Children.Add((_node "Target          $($item.ResolvedTarget)"))
        $node.Children.Add((_node "LinkType        $($item.LinkType)"))

        $treeDetail.AddObject($node)
        $treeDetail.ExpandAll()

    }
    #endregion

    #region create the main window and status bar

    $StatusBar = [StatusBar]::New( @([StatusItem]::New('Unknown', 'Ready', {})))

    #Add the control to the application
    [Application]::Top.Add($StatusBar)

    $window = [Window]@{Title = 'Directory TUI Tree Demo' }

    $window.Add_Initialized({
            $lblNote.Text = "Building tree for $Path. Please wait. This may take a minute or two."
            $frameDetail.Visible = $False
            $btnUpdate.Enabled = $false
            $btnToggle.Enabled = $false
            [Application]::Refresh()
        })
    $window.Add_Ready({
            $StatusBar.items[0].Title = "Loading $($txtPath.Text.ToString())"
            [Application]::Refresh()
            $rootNode = New-DirectoryTree -Path $txtPath.Text.ToString() -MaxDepth $Depth -isRoot

            if ($rootNode) {
                # Expand each of the root node's direct children
                foreach ($child in $rootNode.Children) {
                    $tree.Expand($child)
                }
                $tree.AddObject($rootNode)
            }

            updateDetail
            $treeDetail.ExpandAll()
            $lblNote.Text = "The tree view is limited to a depth of $Depth."
            $frameDetail.Visible = $True
            $btnUpdate.Enabled = $True
            $btnToggle.Enabled = $True
            $StatusBar.items[0].Title = 'Ready'

            [Application]::Refresh()
            $Tree
        })
    #endregion

    #region add controls

    $txtPath = [TextField]@{
        X     = 1
        Y     = 1
        Text  = (Convert-Path $Path)
        Width = 50
    }
    $window.Add($txtPath)

    $btnUpdate = [button]@{
        X    = 1
        Y    = 3
        Text = '_Update'
    }

    $btnUpdate.Add_Clicked({
            $lblSelected.Text = ''
            toggle
            #remove the existing tree
            $tree.ClearObjects()
            $treeDetail.ClearObjects()

            if (Test-Path $txtPath.Text.ToString()) {
                #rebuild
                $rootNode = New-DirectoryTree -Path $txtPath.Text.ToString() -MaxDepth $Depth -isRoot
                if ($rootNode) {
                    # Expand each of the root node's direct children
                    foreach ($child in $rootNode.Children) {
                        $tree.Expand($child)
                    }
                }
                $tree.AddObject($rootNode)
                updateDetail $txtPath.Text.ToString()
            }
            else {
                $StatusBar.Items[0].Title = "Failed to find $($txtPath.Text.ToString())"
            }
            [Application]::Refresh()

        })

    $Window.Add($btnUpdate)

    $btnToggle = [Button]@{
        X    = $btnUpdate.Frame.Right + 1
        Y    = $btnUpdate.Frame.Y
        Text = 'Expand All'
    }

    $btnToggle.Add_Clicked({
            #call a helper function
            toggle
        })

    $window.Add($btnToggle)

    $btnQuit = [Button]@{
        X    = $btnToggle.Frame.Right + 1
        Y    = $btnToggle.Frame.Y
        Text = '_Quit'
    }

    $btnQuit.Add_Clicked({
            #stop the TUI application
            [Application]::RequestStop()
        })
    $window.Add($btnQuit)
    $lblSelected = [Label]@{
        X     = $txtPath.Frame.Right + 1
        Y     = $txtPath.Frame.Y
        Text  = 'Selected:'
        Width = [Dim]::Percent(99)
    }
    $window.add($lblSelected)

    $treeDetail = [TreeView]@{
        X      = 2
        Y      = 1
        Width  = [Dim]::Percent(90)
        Height = [Dim]::Percent(90)
        Text   = 'Detail TBA'
        Style  = [Trees.TreeStyle]@{
            ShowBranchLines          = $True
            ColorExpandSymbol        = $True
            HighlightModelTextOnly   = $True
            InvertExpandSymbolColors = $False
        }
    }

    $frameDetail = [FrameView]@{
        X      = $txtPath.Frame.Right + 6
        Y      = $btnQuit.Frame.Y
        Title  = 'Selected Details'
        Width  = [Dim]::Percent(55)
        Height = [Dim]::Percent(90)
    }

    $frameDetail.Add($treeDetail)
    $window.Add($frameDetail)

    $lblNote = [Label]@{
        X    = 1
        Y    = $btnUpdate.Frame.Bottom + 1
        Text = "The tree view is limited to a depth of $Depth"
    }
    $window.Add($lblNote)

    # Create TreeView
    $tree = [TreeView]@{
        X      = 1
        Y      = $lblNote.Frame.Bottom + 2
        Width  = [Dim]::Percent(35)
        Height = [Dim]::Percent(80)
        Text   = Split-Path $Path -Parent
        Style  = [Trees.TreeStyle]@{
            ShowBranchLines          = $True
            ColorExpandSymbol        = $True
            HighlightModelTextOnly   = $True
            InvertExpandSymbolColors = $False
        }
    }

    # Add selection event handler
    $tree.Add_SelectionChanged({
            $selected = $tree.SelectedObject
            if ($selected) {
                $lblSelected.Text = "Selected: $($selected.Tag)"
                updateDetail $selected.Tag
                [Application]::Refresh()
            }
        })

    $tree.Add_MouseClick({
            param($e)
            # Get the node at the clicked position using the mouse event row
            $clickedNode = $tree.GetObjectOnRow($e.MouseEvent.Y)

            if ($clickedNode) {
                # Move focus to the clicked node
                $tree.SelectedObject = $clickedNode
                [Application]::Refresh()
            }
            #button1 is left click
            #button3 is right click
            #display content from selected file types in a dialog box with a right mouse click
            if ($e.MouseEvent.Flags -eq 'Button3clicked') {
                if ($clickedNode.Text -match '(txt)|(ps(d|m)?1)|(md)|(yml)|(json)|(csv)|(xml)$') {
                    $content = [Dialog]@{
                        Title  = "Preview: $($clickedNode.Tag)"
                        Width  = [Dim]::Percent(90)
                        Height = [Dim]::Percent(80)
                    }

                    # TextView fills the dialog and is read-only
                    $cv = [TextView]@{
                        X        = 0
                        Y        = 0
                        Width    = [Dim]::Fill()
                        Height   = [Dim]::Fill(2)   # leave room for the button
                        ReadOnly = $true
                        Text     = (Get-Content $clickedNode.Tag -Raw)
                    }

                    $ok = [Button]@{
                        Text      = 'OK'
                        IsDefault = $true
                    }

                    $ok.Add_Clicked({ $content.RequestStop() })
                    $content.Add($cv)
                    $content.AddButton($ok)
                    [Application]::Run($content)
                }
            }
        })

    $window.Add($tree)

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
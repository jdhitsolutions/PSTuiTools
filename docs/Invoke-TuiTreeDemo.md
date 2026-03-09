---
external help file: PSTuiTools-help.xml
Module Name: PSTuiTools
online version: https://jdhitsolutions.com/yourls/fe54a9
schema: 2.0.0
---

# Invoke-TuiTreeDemo

## SYNOPSIS

Run a TreeView demo TUI.

## SYNTAX

```yaml
Invoke-TuiTreeDemo [[-Path] <String>] [-Depth <Int32>] [<CommonParameters>]
```

## DESCRIPTION

This command will run a sample TUI that uses the TreeView control. It will display a specified path as a tree showing files and folders. You can control the depth. The default is 4. The more levels, the longer it will take to open the TUI, especially for large folders.

Default path is $HOME, but you can specify a folder.

You can manually click in the tree to expand and collapse nodes or use the toggle button. Details from the selected tree item will be displayed in another detail tree on the right. You might see different detail information depending on the file.

If you right click a file in the main tree, depending on the file extension, the contents will be displayed in a dialog box. Most text files should be displayed.

Enter a new path in the text field and click the Update button to show a new tree. This will use the existing depth value.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-TuiTreeDemo
```

Launch the demo using default values.

### Example 2

```powershell
PS C:\> tuiTree c:\scripts -depth 2
```

Open the demo using C:\Scripts and limit the display to 2 levels.

## PARAMETERS

### -Path

Specify a filesystem path to display.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: $HOME
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth

Specify the number of levels to display.
The higher the value the longer it will take to display the tree.
Specify a value between 1 and 7.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 4
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

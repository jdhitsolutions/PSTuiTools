---
external help file: PSTuiTools-help.xml
Module Name: PSTuiTools
online version: https://jdhitsolutions.com/yourls/d411aa
schema: 2.0.0
---

# Invoke-TuiMp3

## SYNOPSIS

Launch a TUI MP3 player.

## SYNTAX

```yaml
Invoke-TuiMp3 [[-FilePath] <String>] [-Title <String>] [-DefaultLibrary <String>]
[<CommonParameters>]
```

## DESCRIPTION

This command will launch a TUI MP3 player. You can specify the path to a .mp3 or .m4a file. This will load the file into the player. Use the buttons to control playback. Selected metadata and lyrics will be displayed if found in the MP3 file.

You can also open a file from the menu. The file dialog will filter on .mp3 and .m4a files. You will need to select the extension from the dropdown.

When you start the command, you can set a default library folder to open to simplify navigation. If this is a value you want to use all the time, add an entry into $PSDefaultParameterValues.

You can control the volume by clicking the volume bar, the +/- buttons, or using Ctrl+Up or Ctrl+Down.

Beginning with v0.5.0, the player will keep a most recently played list. As new songs are played, they will be added to the list. The maximum number of entries is 10. After that, the oldest entry is removed. The list is persisted in a file called tuiMp3-most-recent.txt under $HOME. If you uninstall the module, you will need to manually remove the file.

Note that there is a limitation in the file dialog. You cannot load a file if it has a comma in the name because it gets processed as an array. This is a limitation in Terminal.Gui. However, you can specify a file with commas in the name with the FilePath parameter.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-TuiMp3 -FilePath "C:\Music\MySong.mp3"
```

Launch the TUI MP3 player and load the specified MP3 file. You will need to click the Play button.

### Example 2

```powershell
PS C:\> Invoke-TuiMp3 -DefaultLibrary "C:\Music"
```

Launch the TUI MP3 player and set the default library to the specified folder. You can then navigate to your MP3 files more easily. This parameter has an alias of Library.

## PARAMETERS

### -DefaultLibrary

Specify the default folder to open for .mp3 and .m4a files. You will have to manually select the appropriate extension from the drop down. UNC paths are supported.

Note that there is a limitation in the file dialog. You cannot load a file if it has a comma in the name because it gets processed as an array. This is a limitation in Terminal.Gui. However, you can specify a file with commas in the name with the FilePath parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Library

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath

Specify the path to .mp3 or .m4a file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title

Specify the window title.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PSMusic Player
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

This command has an alias of tuimp3.

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

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

This command will launch a TUI MP3 player. You can specify the path to an MP3 file to play or open a file from the menu. You can set a default library folder to open to simplify navigation. Use the buttons to control playback. Selected metadata and lyrics will be displayed if found in the MP3 file.

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

Launch the TUI MP3 player and set the default library to the specified folder. You can then navigate to your MP3 files more easily.

## PARAMETERS

### -DefaultLibrary

Specify the default folder to open for MP3 files. UNC paths are supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath

Specify the path to an MP3 file.

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
Default value: None
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

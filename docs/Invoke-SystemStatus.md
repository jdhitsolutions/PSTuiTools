---
external help file: PSTuiTools-help.xml
Module Name: PSTuiTools
online version: https://jdhitsolutions.com/yourls/cdf5f3
schema: 2.0.0
---

# Invoke-SystemStatus

## SYNOPSIS

Run a system status TUI monitor.

## SYNTAX

```yaml
Invoke-SystemStatus [[-Computername] <String>] [-Credential <PSCredential>] [-WindowColor <Color>]
 [<CommonParameters>]
```

## DESCRIPTION

This function will launch a system status monitor TUI. Enter a computer name and alternate credentials if necessary. Click the Refresh button or the Alt+R shortcut to manually refresh information.

You can also set an automatic refresh interval. Click the Timer button to stop and start. If you change the computer, you should stop the timer first. Restart it after changing the computer name.

Use the Quit button or Alt+Q to exit.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-SystemStatus
```

Launch the system status monitor for the local computer.

### Example 2

```powershell
PS C:\> Invoke-SystemStatus -Computername SRV1 -credential administrator -color Cyan
```

Launch the system status monitor for the remote computer SRV1 using alternate credentials. Use Cyan as the TUI foreground color.

## PARAMETERS

### -Computername

The name of the computer to monitor. You must have admin rights.

```yaml
Type: String
Parameter Sets: (All)
Aliases: CN

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Alternate credentials for a remote computer.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: RunAs

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WindowColor

Specify the window foreground color. The background will be Black.

```yaml
Type: Color
Parameter Sets: (All)
Aliases: color
Accepted values: Black, Blue, Green, Cyan, Red, Magenta, Brown, Gray, DarkGray, BrightBlue, BrightGreen, BrightCyan, BrightRed, BrightMagenta, BrightYellow, White

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

### System.Object

## NOTES

This command has an alias of tuiStatus.

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

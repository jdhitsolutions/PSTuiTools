---
external help file: PSTuiTools-help.xml
Module Name: PSTuiTools
online version: https://jdhitsolutions.com/yourls/cc0520
schema: 2.0.0
---

# Invoke-ServiceInfo

## SYNOPSIS

A TUI for displaying service information.

## SYNTAX

```yaml
Invoke-ServiceInfo [<CommonParameters>]
```

## DESCRIPTION

Use this TUI to display information about services on the local or a remote computer. The TUI uses PowerShell remoting over WsMan to retrieve the service information and supports alternate credentials.

This command has an alias of ServiceInfo.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-ServiceInfo
```

Click Get Info to retrieve the service information from the specified computer. You can also filter on the service status. Click Get Info after changing the filter to retrieve the updated service information.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

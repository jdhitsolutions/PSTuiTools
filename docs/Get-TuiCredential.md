---
external help file: PSTuiTools-help.xml
Module Name: PSTuiTools
online version: https://jdhitsolutions.com/yourls/0f96c5
schema: 2.0.0
---

# Get-TuiCredential

## SYNOPSIS

Prompt for credentials in a TUI.

## SYNTAX

```yaml
Get-TuiCredential [[-Username] <String>] [<CommonParameters>]
```

## DESCRIPTION

This is an alternative to Get-Credential that prompts for credentials in a TUI. Use Show to display the password in plaintext in the TUI. The output will be a PSCredential object.

## EXAMPLES

### Example 1

```powershell
PS C:\> $cred = Get-TuiCredential
```

This will prompt for credentials in a TUI. Use Show to display the password in plaintext in the TUI.The output will be a PSCredential object.

## PARAMETERS

### -Username

Enter the username in the format <machine\>|<domain\>\username

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PSCredential

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

---
external help file: PSTuiTools-help.xml
Module Name: PSTuiTools
online version: https://jdhitsolutions.com/yourls/c2f989
schema: 2.0.0
---

# Save-TuiAssembly

## SYNOPSIS

Download Terminal.GUI and NStack assemblies.

## SYNTAX

```yaml
Save-TuiAssembly [[-Package] <String[]>] -DestinationPath <String>  [<CommonParameters>]
```

## DESCRIPTION

To create a TUI application in PowerShell, you will need the Terminal.Gui and NStack assemblies. This function will download the latest versions of these assemblies from NuGet and save them to a specified location on your computer. You can specify which assemblies to download by using the -Package parameter, or you can download both assemblies by omitting the parameter.

The DestinationPath should be the top level folder where you want the assemblies to be saved. The function will create a subfolder for each assembly and save the corresponding DLL files in that subfolder.

## EXAMPLES

### Example 1

```powershell
PS C:\> Save-TuiAssembly -DestinationPath "C:\Tools\"
```

This will download and save the NStack and Terminal.Gui assemblies to the C:\Tools folder. There will be two sub-folders created: C:\Tools\Terminal.Gui and C:\Tools\NStack, each containing the respective DLL files.

## PARAMETERS

### -DestinationPath

Specify the location to save the downloaded assemblies.
It will be created for you.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Package

The name of the related assembly.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Terminal.Gui, NStack

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

### System.IO.FileInfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

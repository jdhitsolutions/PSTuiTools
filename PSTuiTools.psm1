#region Assembly Loading for Terminal.Gui

<#
Trying to gracefully handle problems when an existing version of the Terminal.Gui
assembly is already loaded, such as when using Out-ConsoleGridView. I am not sure
this is the best way or if I am even doing it the right way. This code appears
to have an impact on loading the module. I expect this code to change. Some of this
code was generated with AI.
#>
$TuiLoadContext = $null

$assemblyPath = Join-Path $PSScriptRoot 'assemblies'
$nstackDll = Join-Path $assemblyPath 'NStack.dll'
$terminalGuiDll = Join-Path $assemblyPath 'Terminal.Gui.dll'
$tagLibDll = Join-Path $assemblyPath .\TagLibSharp.dll

[System.Reflection.Assembly]::LoadFrom($tagLibDll)

# Only create custom load context if assemblies aren't already loaded
$existingTerminalGui = [AppDomain]::CurrentDomain.GetAssemblies().Where({$_.GetName().Name -eq 'Terminal.Gui'})

$RequiredVersion = "1.19.0"

if (-not $existingTerminalGui) {
    # Create isolated load context for Terminal.Gui assemblies
   # $TuiLoadContext = [System.Runtime.Loader.AssemblyLoadContext]::new('PSTuiTools', $true)

   # Load assemblies into isolated context
   # [void]$TuiLoadContext.LoadFromAssemblyPath($nstackDll)
   # [void]$TuiLoadContext.LoadFromAssemblyPath($terminalGuiDll)

    #Write-Host "Loaded Terminal.Gui assemblies in isolated context" -fore magenta
    [System.Reflection.Assembly]::LoadFrom($nStackDll)
    [System.Reflection.Assembly]::LoadFrom($terminalGUIDll)
}

#get the actual version of the currently loaded assembly
$TerminalGuiVersion = (Get-Item ([System.Reflection.Assembly]::GetAssembly([Terminal.Gui.Application]).location)).VersionInfo.ProductVersion -split "\+" | Select-Object -first 1

if ($terminalGuiVersion -ne $RequiredVersion) {
    Write-Warning "Terminal.Gui v$terminalGuiVersion is already loaded in this session. This does not match the expected version of $RequiredVersion. Some functionality might not work as expected."
}

#endregion
#region Main

#dot source the module commands
(Get-ChildItem -Path $PSScriptRoot\functions\*.ps1).ForEach({ . $_.FullName })

#endregion


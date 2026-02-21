#download required TUI-related assemblies

function Save-TuiAssembly {
    [cmdletbinding()]
    [OutputType('System.IO.FileInfo')]
    param(
        [Parameter(
            Position = 0,
            HelpMessage = 'The name of the related assembly'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Terminal.Gui', 'NStack')]
        [string[]]$Package = @('Terminal.Gui', 'NStack'),

        [Parameter(Mandatory, HelpMessage = 'Specify the location to save the downloaded assemblies. It will be created for you.')]
        [ValidateScript({ Test-Path (Split-Path $_ -Parent) }, ErrorMessage = "Can't find or verify the parent part of the path {0}")]
        [string]$DestinationPath
    )

    begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
        $dl = @{
            'Terminal.Gui' = 'https://www.nuget.org/api/v2/package/Terminal.Gui/1.19.0'
            NStack         = 'https://www.nuget.org/api/v2/package/NStack.Core/1.1.1'
        }

        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Saving files to $DestinationPath"
    } #begin

    process {
        foreach ($item in $package) {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Downloading $item from $($dl[$item])"
            $tmpZip = Join-Path -Path $env:TEMP -ChildPath "$item.zip"
            $tmpPath = Join-Path -Path $env:TEMP -ChildPath $item
            try {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Saving temporary zip file $tmpZip"
                Invoke-WebRequest -Uri $dl[$item] -OutFile $tmpZip -ErrorAction Stop
            }
            catch {
                throw $_
            }
            if (Test-Path $tmpZip) {
                Expand-Archive -Path $tmpZip -DestinationPath $tmpPath -Force
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Copying assemblies"
                Copy-Item -path (Join-Path  $tmpPath -ChildPath lib) -Destination "$DestinationPath\$item" -Container -Recurse -Force -PassThru
                #clean up
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Removing temporary files and folders"
                Remove-Item $tmpPath -Force -Recurse
                Remove-Item $tmpZip
            }
        }
    } #process

    end {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Save-TuiAssembly
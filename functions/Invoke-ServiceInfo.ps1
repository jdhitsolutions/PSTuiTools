
Function Invoke-ServiceInfo {
[cmdletbinding()]
Param(

)

Begin {
    Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
} #begin

Process {
    Write-Verbose "[PROCESS] Processing"

} #process

End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
} #end

} #close Invoke-ServiceInfo



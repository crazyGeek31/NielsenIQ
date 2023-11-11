$LogicalProcessors = (Get-WmiObject -class Win32_processor -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors;
function myTopFunc () {
## Check user level of PowerShell
date >> 'D:\Temp\cpu_utilization.log'
if (
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
)
{
    $procTbl = get-process -IncludeUserName | select ID, Name
} else {
    $procTbl = get-process | select ID, Name
}

Get-Counter `
    '\Process(*)\ID Process',`
    '\Process(*)\% Processor Time',`
    '\Process(*)\Working Set - Private'`
    -ea SilentlyContinue |
    foreach CounterSamples |
    where InstanceName -notin "_total","memory compression" |
    group { $_.Path.Split("\\")[3] } |
    foreach {
        [pscustomobject]@{
        Name = $_.Group[0].InstanceName;
        ID = $_.Group[0].CookedValue;
        CPU = if($_.Group[0].InstanceName -eq "idle") {
            $_.Group[1].CookedValue / $LogicalProcessors
            } else {
            $_.Group[1].CookedValue
        };
        }
    } |
    sort -des $SortCol |
    select -f 5 @(
        "Name", "ID",
        @{ n = "CPU"; e = { ("{0:N1}%" -f $_.CPU) } }
    ) | ft -a >> 'D:\Temp\cpu_utilization.log'
}

myTopFunc
add-pssnapin Citrix*
$servers = Get-content -Path "C:\Temp\servers.txt"

function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

$logpath = "C:\Temp\VDAServers\"
$logfile = "C:\Temp\VDAServers\VDAPowerMgmt.log"


Try{

If( -not (test-path -path $logpath -ErrorAction stop))
{

New-Item -ItemType Directory -path $logpath -ErrorAction stop | out-null
New-Item -ItemType file -path $logfile -ErrorAction stop | out-null

Add-Content -path $logfile -Value "--------------------------------Date----------------------------------------"
Add-Content -Path $logfile -Value "                        Started@ $(Get-TimeStamp)                             "
Add-Content -path $logfile -Value "--------------------------------Date----------------------------------------"


Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]-- File directory and log File created successfully"
}
else {
Add-Content -path $logfile -Value "--------------------------------Date----------------------------------------"
Add-Content -Path $logfile -Value "                        Started@ $(Get-TimeStamp)                             "
Add-Content -path $logfile -Value "--------------------------------Date----------------------------------------"

Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]-- File directories and log File is already existed"
}

}

Catch{
Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Error]-- Having issues to create file and log Directory"
break

}


foreach($server in $servers){

$session = Get-BrokerSession -MachineName $server | select -ExpandProperty UserName

if(!($session -eq $null)){

write-host "$server is having sessions"

Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]-- Active sessions: $session in $server"

$MM = Set-BrokerMachineMaintenanceMode -InputObject $server $true

Start-Sleep -Seconds 2

#$SessionName = $session | select -ExcludeProperty UserName

$sessions = Get-BrokerSession -UserName $session

$Messgae1 = Send-BrokerSessionMessage -InputObject $sessions -MessageStyle Information -Title testwarning -Text "Reminder1: Due to Server maintanance please save your works and logoff"
Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  $Messgae1: sent to $session in $server"

start-sleep -Seconds 10


$sessions15min = Get-BrokerSession -MachineName AHS\AWS01MCSAHSD02P | select -ExpandProperty UserName

if(!($sessions15min -eq $null)){

write-host "$server is having sessions"

Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  Active Sessions: $sessions15min in $server"

Start-Sleep -Seconds 2
$session15min = Get-BrokerSession -UserName $sessions15min

$Messgae2 = Send-BrokerSessionMessage -InputObject $session15min -MessageStyle Information -Title testwarning -Text "Final Reminder: Machine is going to shutdown in 15mins, please logoff to save your workloads"

Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  $Messgae2: sent to $sessions15min in $server"

start-sleep -Seconds 10

$Messgae3 = Send-BrokerSessionMessage -InputObject $sessions -MessageStyle Information -Title testwarning -Text "Shutdown Reminder: Machine is going to shutdown!!!!"

Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  $Messgae3: sent to $sessions15min in $server"

$shutdown = New-BrokerHostingPowerAction -Action shutdown -MachineName "$server"

$shutdown

write-host "$server got shutdown succesfully "
Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  $server got shutdown succesfully"


}

else{

$shutdown = New-BrokerHostingPowerAction -Action shutdown -MachineName "$server"

$shutdown

write-host "$server got shutdown succesfully "
Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  $server got shutdown succesfully"

}

}

else{


$shutdown = New-BrokerHostingPowerAction -Action shutdown -MachineName "$server"

$shutdown

write-host "$server got shutdown succesfully "

Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  $server got shutdown succesfully"


}


}

$Servers1= Get-content -path "C:\Temp\servers.txt"
ForEach($machine in $Servers1){

Get-BrokerMachine -MachineName $machine | select MachineName, MachineInternalState, PowerState

$PoweredOffList = Get-BrokerMachine -MachineName $machine | where-object {$_.PowerState -eq "off"} | select -expandproperty MachineName |out-file $logpath = "C:\Temp\VDAServers\poweredoff.txt"
Add-Content -Path $logfile -Value "$(Get-TimeStamp)--[Info]--  Powered off machines list created"

}

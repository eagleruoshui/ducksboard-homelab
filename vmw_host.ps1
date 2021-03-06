#=======================================================================#
#	List of API destinations:
#
#	esx0c#	 	= cpu util, cpu ready, mem used, and swap rate for esx0
#	esx1c#	 	= cpu util, cpu ready, mem used, and swap rate for esx1
#	esx2c#	 	= cpu util, cpu ready, mem used, and swap rate for esx2
#	esxm1c#	 	= cpu util, cpu ready, mem used, and swap rate for esxmgmt
#	clustercpu 	= cluster CPU used in N-1 scenario
#	clustermem	= cluster RAM used in N-1 scenario
#
#=======================================================================#

# Snapins
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction:SilentlyContinue

# Creds
Invoke-Expression ($PSScriptRoot + "\creds.ps1")

# Connect to vCenter
Connect-VIServer $global:vc -Credential $global:vc_cred -ErrorAction:Stop

# Set body var
$body = @{}

# ESX0 Vitals (custom_numeric_absolute_area_graph4)
$n = "esx0.glacier.local"
$body.Add("esx0c1",[Math]::Round((Get-VMHost $n).CpuUsageMhz / (Get-VMHost $n).CpuTotalMhz, 2) * 100)
$body.Add("esx0c2",((Get-Stat -Entity (Get-VMHost $n) -Stat 'cpu.ready.summation' -Realtime -MaxSamples 1).Value / (20 * 1000)) * 100)
$body.Add("esx0c3",[Math]::Round((Get-VMHost $n).MemoryUsageGB / (Get-VMHost $n).MemoryTotalGB, 2) * 100)
$body.Add("esx0c4",(Get-Stat -Entity (Get-VMHost $n) -Stat 'mem.swapused.average' -Realtime -MaxSamples 1).Value)

# ESX1 Vitals (custom_numeric_absolute_area_graph4)
$n = "esx1.glacier.local"
$body.Add("esx1c1",[Math]::Round((Get-VMHost $n).CpuUsageMhz / (Get-VMHost $n).CpuTotalMhz, 2) * 100)
$body.Add("esx1c2",((Get-Stat -Entity (Get-VMHost $n) -Stat 'cpu.ready.summation' -Realtime -MaxSamples 1).Value / (20 * 1000)) * 100)
$body.Add("esx1c3",[Math]::Round((Get-VMHost $n).MemoryUsageGB / (Get-VMHost $n).MemoryTotalGB, 2) * 100)
$body.Add("esx1c4",(Get-Stat -Entity (Get-VMHost $n) -Stat 'mem.swapused.average' -Realtime -MaxSamples 1).Value)

# ESX2 Vitals (custom_numeric_absolute_area_graph4)
$n = "esx2.glacier.local"
$body.Add("esx2c1",[Math]::Round((Get-VMHost $n).CpuUsageMhz / (Get-VMHost $n).CpuTotalMhz, 2) * 100)
$body.Add("esx2c2",((Get-Stat -Entity (Get-VMHost $n) -Stat 'cpu.ready.summation' -Realtime -MaxSamples 1).Value / (20 * 1000)) * 100)
$body.Add("esx2c3",[Math]::Round((Get-VMHost $n).MemoryUsageGB / (Get-VMHost $n).MemoryTotalGB, 2) * 100)
$body.Add("esx2c4",(Get-Stat -Entity (Get-VMHost $n) -Stat 'mem.swapused.average' -Realtime -MaxSamples 1).Value)

# ESXM1 Vitals (custom_numeric_absolute_area_graph4)
$n = "172.16.20.59"
$body.Add("esx9c1",[Math]::Round((Get-VMHost $n).CpuUsageMhz / (Get-VMHost $n).CpuTotalMhz, 2) * 100)
$body.Add("esx9c2",((Get-Stat -Entity (Get-VMHost $n) -Stat 'cpu.ready.summation' -Realtime -MaxSamples 1).Value / (20 * 1000)) * 100)
$body.Add("esx9c3",[Math]::Round((Get-VMHost $n).MemoryUsageGB / (Get-VMHost $n).MemoryTotalGB, 2) * 100)
$body.Add("esx9c4",(Get-Stat -Entity (Get-VMHost $n) -Stat 'mem.swapused.average' -Realtime -MaxSamples 1).Value)

# N-1 Resources Used (custom_numeric_gauges)
$body.Add("clustercpu",((($body.get_Item("esx0c1")) + ($body.get_Item("esx1c1")) + ($body.get_Item("esx2c1"))) / 2) / 100)
$body.Add("clustermem",((($body.get_Item("esx0c3")) + ($body.get_Item("esx1c3")) + ($body.get_Item("esx2c3"))) / 2) / 100)

# Push to API
$bodyjson = $body | ConvertTo-Json
$r = Invoke-WebRequest -Uri 'https://push.ducksboard.com/values/' -Headers $db_head -Body $bodyjson -Method:Post -ContentType "application/json"

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false
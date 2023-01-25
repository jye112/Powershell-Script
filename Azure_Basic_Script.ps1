## Azure 로그인 ##
Connect-AzAccount
Connect-AzureRmAccount
az login

## Azure 구독 목록 확인 ##
Get-AzSubscription
Get-AzureRmSubscription
az account list --output table

## Default 구독 변경 ##
Select-AzSubscription -Subscription "<subsciption>"
Select-AzureRmSubscription -Subscription "<subsciption>"
az account set --subscription "<subsciption>"

## Resource List ##
Get-AzureRmResource | Select-Object ResourceGroupName, Name, ResourceType | Export-Csv -Path "D:\Resource_List.csv"


## VMName     PrivateIpAddress     PrivateIpAllocationMethod ##
$vms = Get-AzVM
$nics = Get-AzNetworkInterface | where VirtualMachine -ne $null #skip Nics with no VM
foreach($nic in $nics)
{
    $vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
    $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
    $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod

    if ($vm.Name -NE $null) {
        Write-Host $vm.Name, $prv, $alloc
    }
}

## NICName     PrivateIpAddress     PrivateIpAllocationMethod ##
Get-AzNetworkInterface | where-object {$_.Ipconfigurations[0].PrivateIpAddress -ne $null } | `
where-object {$_.Ipconfigurations[0].PrivateIpAllocationMethod -ne $null } | `
Select-Object Name, @{label = "Private IP Address"; expression = { $_.Ipconfigurations[0].PrivateIpAddress } }, @{label = "Allocation Method"; expression = { $_.Ipconfigurations[0].PrivateIpAllocationMethod } }


## VPN P2S Session Overlap VpnUserName ##
$b = Get-AzVirtualNetworkGatewayVpnClientConnectionHealth -ResourceName $Gateway -ResourceGroupName $RG
$a = $b | Select-Object VpnUserName, PublicIpAddress, PrivateIpAddress | Group-object VpnUserName | Where-Object {$_.Count -gt 1}
$a.Group

$b = Get-AzVirtualNetworkGatewayVpnClientConnectionHealth -ResourceName $Gateway -ResourceGroupName $RG
Function Get-Duplicate($b)
{
    $a = $b | Select-Object VpnUserName, PublicIpAddress, PrivateIpAddress | Group-object VpnUserName | Where-Object {$_.Count -gt 1}
    $a.Group
}

#Function Get-Duplicate($Array) 
#{
#    $Unique = $Array | Get-unique | Select-Object VpnUserName
#    $Duplicates = (Compare-Object -ReferenceObject $Array -DifferenceObject $Unique | where { $_.sideIndicator -like "<=" }).inputobject
#    $UniqueDuplicates = $Duplicates | Get-unique | Select-Object VpnUserName
#    Foreach ($Duplicate in $UniqueDuplicates)
#    {
#        $Duplicate
#    }
#}



## Dissociated NIC ##
Get-AzNetworkInterface | where-object { $_.VirtualMachine -eq $null } | Select-Object Name


## Dissociated NSG ##
Get-AzNetworkSecurityGroup | where-object { $_.Networkinterfaces -ne $null } | Select-Object Name
Get-AzNetworkSecurityGroup | where-object { $_.Subnets[0] -eq $null } | where-object { $_.NetworkInterfaces[0] -eq $null } | Select-object Name


## Dissociated Public IP ##
Get-AzPublicIpAddress | where-object { $_.IpConfiguration -eq $null } | `
Select-Object @{label = "Public IP Name"; expression = {$_.Name} }, @{label = "IP Address"; expression = { $_.IpAddress } }


## Detached Disk ##
Get-AzDisk | where-object { $_.DiskState -ne "Attached" } | Select-object Name, DiskState

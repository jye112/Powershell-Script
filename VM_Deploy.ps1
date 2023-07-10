$lists = @(
    # 해당 변수는 반드시 리소스 설정값에 맞게 변경해야 합니다.
    @{ "RGName"=""; "Location"=""; "VnetName"=""; "VnetAddrPrefix"=""; "SubnetName"=""; "SubnetAddrPrefix"=""; "VMName"=""; "VMSize"=""; "NICName"=""; "DiskSize"=""; "DiskSku"=""; "DiskName"=""; "USER"=""; "PWD"=""; },
    @{ "RGName"=""; "Location"=""; "VnetName"=""; "VnetAddrPrefix"=""; "SubnetName"=""; "SubnetAddrPrefix"=""; "VMName"=""; "VMSize"=""; "NICName"=""; "DiskSize"=""; "DiskSku"=""; "DiskName"=""; "USER"=""; "PWD"=""; }
)

Select-Azsubscription -subscription ""

foreach($list in $lists){
    # ID & PW
    $VMAdminUser = $list.USER
    $VMAdminSecurePassword = ConvertTo-SecureString $list.PWD -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($VMAdminUser, $VMAdminSecurePassword);

    # Network
    $vnet = Get-AzVirtualNetwork -Name $list.VnetName
    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $list.SubnetName

    # NIC
    $nic = New-AzNetworkInterface -Name $list.NICName -ResourceGroupName $list.RGName -Location $list.Location -Subnet $subnet

    # VM Config
    $vmConfig = New-AzVMConfig -VMName $list.VMName -VMSize $list.VMSize |
    Set-AzVMOperatingSystem -Linux -ComputerName $list.VMName -Credential $cred | 
    Set-AzVMSourceImage -PublisherName "OpenLogic" -Offer "CentOS" -Skus "7_9-gen2" -Version "latest"

    Set-AzVMOSDisk -VM $vmConfig -Name $list.DiskName -DiskSizeInGB $list.DiskSize -CreateOption FromImage -StorageAccountType $list.DiskSku -Caching ReadWrite -Linux

    # Add NIC to VM
    Add-AzVMNetworkInterface -Id $nic.Id -VM $vmConfig

    # Create VM
    New-AzVm -ResourceGroupName $list.RGName -Location $list.Location -VM $vmConfig
}

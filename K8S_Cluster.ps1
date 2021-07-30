$RGName = ""
$Location = "korea central"

# Resource Group
New-AzResourceGroup -Name $RGName -Location $Location

# Network
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
-Name "nsgRuleSSH" `
-Protocol "Tcp" `
-Direction "Inbound" `
-Priority 1000 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 22 `
-Access "Allow"

$nsg = New-AzNetworkSecurityGroup `
-ResourceGroupName $RGName `
-Location $Location `
-Name "k8s-nsg" `
-SecurityRules $nsgRuleSSH

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
-Name "k8s-subnet-01" `
-AddressPrefix 192.168.1.0/24 `
-NetworkSecurityGroup $nsg

$vnet = New-AzVirtualNetwork `
-ResourceGroupName $RGName `
-Location $Location `
-Name "k8s-vnet-01" `
-AddressPrefix 192.168.0.0/16 `
-Subnet $subnetConfig

# Master Node VM
$masterpip = New-AzpublicIpAddress `
-ResourceGroupName $RGName `
-Location $Location `
-AllocationMethod Static `
-IdleTimeoutInMinutes 4 `
-Name "master-pip"

$masterNIC = New-AzNetworkInterface `
-Name "master-nic" `
-ResourceGroupName $RGName `
-Location $Location `
-SubnetID $vnet.Subnets[0].Id `
-PublicIpAddressId $masterpip.Id

$securePassword = ConvertTo-SecureString "qwer1234!@#$" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword) 

$vmConfig = New-AzVMConfig `
-VMName "master-node" `
-VMSize "Standard_D2s_v3" | `
Set-AzVMOperatingSystem `
-Linux `
-ComputerName "master-node" `
-Credential $cred `
-DisablePasswordAuthentication | `
Set-AzVMSourceImage `
-PublisherName "Canonical" `
-Offer "UbuntuServer" `
-Skus "18.04-LTS" `
-Version "latest" | `
Add-AzVMNetworkInterface `
-Id $masterNIC.Id

$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
-VM $vmconfig `
-KeyData $sshPublicKey `
-Path "/home/azureuser/.ssh/authorized_keys"

New-AzVM `
-ResourceGroupName $RGName `
-Location $Location -VM $vmConfig

# Worker Node01 VM
$workerpip = New-AzpublicIpAddress `
-ResourceGroupName $RGName `
-Location $Location `
-AllocationMethod Static `
-IdleTimeoutInMinutes 4 `
-Name "worker-pip"

$worker01NIC = New-AzNetworkInterface `
-Name "worker-node-01-nic" `
-ResourceGroupName $RGName `
-Location $Location `
-SubnetID $vnet.Subnets[0].Id `
-PublicIpAddressId $workerpip.Id

$securePassword = ConvertTo-SecureString 'qwer1234!@#$' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword) 

$vmConfig = New-AzVMConfig `
-VMName "worker-node-01" `
-VMSize "Standard_D2s_v3" | `
Set-AzVMOperatingSystem `
-Linux `
-ComputerName "worker-node-01" `
-Credential $cred `
-DisablePasswordAuthentication | `
Set-AzVMSourceImage `
-PublisherName "Canonical" `
-Offer "UbuntuServer" `
-Skus "18.04-LTS" `
-Version "latest" | `
Add-AzVMNetworkInterface `
-Id $worker01NIC.Id

$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
-VM $vmconfig `
-KeyData $sshPublicKey `
-Path "/home/azureuser/.ssh/authorized_keys"

New-AzVM `
-ResourceGroupName $RGName `
-Location $Location -VM $vmConfig

# Worker Node02 VM
$worker02NIC = New-AzNetworkInterface `
-Name "worker-node-02-nic" `
-ResourceGroupName $RGName `
-Location $Location `
-SubnetID $vnet.Subnets[0].Id 

$securePassword = ConvertTo-SecureString 'qwer1234!@#$' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword) 

$vmConfig = New-AzVMConfig `
-VMName "worker-node-02" `
-VMSize "Standard_D2s_v3" | `
Set-AzVMOperatingSystem `
-Linux `
-ComputerName "worker-node-02" `
-Credential $cred `
-DisablePasswordAuthentication | `
Set-AzVMSourceImage `
-PublisherName "Canonical" `
-Offer "UbuntuServer" `
-Skus "18.04-LTS" `
-Version "latest" | `
Add-AzVMNetworkInterface `
-Id $worker02NIC.Id

$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
-VM $vmconfig `
-KeyData $sshPublicKey `
-Path "/home/azureuser/.ssh/authorized_keys"

New-AzVM `
-ResourceGroupName $RGName `
-Location $Location -VM $vmConfig
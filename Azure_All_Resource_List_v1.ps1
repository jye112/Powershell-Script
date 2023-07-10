
## All Resource List ##
Get-AzResource | Select-Object Name, ResourceGroupName, Type, Location


############    1. Compute    ############

####     1-1. Virtual Machine     ####
$vms = Get-AzVM
$nics = Get-AzNetworkInterface | where VirtualMachine -ne $null
$disks = Get-AzDisk 

foreach($nic in $nics)
{
    $vm = $vms | Where-object {$_.Id -eq $nic.VirtualMachine.id}
    $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
    $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod

    % {[PSCustomObject]@{
        Name = $vm.Name
        ResourceGroup = $vm.ResourceGroupName
        VMSize = $vm.HardwareProfile.VmSize
        NIC = $nic.Name
        PrivateIP = $prv
        Allocation = $alloc
        Location = $vm.Location
    }
}}

$All_VM = @()
$vms = Get-AzVM
$nics = Get-AzNetworkInterface | where VirtualMachine -ne $null
foreach($nic in $nics)
{
    $vm = $vms | Where-object {$_.Id -eq $nic.VirtualMachine.id}
    $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
    $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod

    $VMList = New-Object -TypeName PSObject
    $VMList | Add-Member -MemberType NoteProperty -Name "VMName" -Value $vm.Name
    $VMList | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $vm.ResourceGroupName
    $VMList | Add-Member -MemberType NoteProperty -Name "VMSize" -Value $vm.HardwareProfile.VmSize
    $VMList | Add-Member -MemberType NoteProperty -Name "NIC" -Value $nic.Name
    $VMList | Add-Member -MemberType NoteProperty -Name "PrivateIP" -Value $prv
    $VMList | Add-Member -MemberType NoteProperty -Name "Allocation" -Value $alloc
    $VMList | Add-Member -MemberType NoteProperty -Name "Location" -Value $vm.Location
    $ALL_VM += $VMList
}
$All_VM | Export-Excel -Path "D:\resource.xlsx" -WorksheetName VirtualMachine -AutoSize


####     1-2. Virtual Machine Scale Set     ####
Get-AzVMSS


####     1-3. Disk     ####
Get-AzDisk | Select-Object Name, ResourceGroup, OsType, DiskSzieGB, DiskState, Location 

$disks = Get-AzDisk
$vms = Get-AzVM
foreach($disk in $disks)
{
    % {[PSCustomObject]@{
        Name = $disk.Name
        ResourceGroup = $disk.ResourceGroupName
        OsType = $disk.OsType
        DiskSizeGB = $disk.DiskSizeGB
        DiskState = $disk.DiskState
        VM = $disk.ManagedBy # ID 말고 Name으로 할 수는 없을까?
        Location = $disk.Location
    }
}}


$ALL_DISK = @()
$disks = Get-AzDisk
$vms = Get-AzVM
foreach($disk in $disks)
{
    $DiskList = New-Object -TypeName PSObject
    $DiskList | Add-Member -MemberType NoteProperty -Name "DiskName" -Value $disk.Name
    $DiskList | Add-Member -MemberType NoteProperty -Name "OsType" -Value $disk.OsType
    $DiskList | Add-Member -MemberType NoteProperty -Name "DiskSize(GB)" -Value $disk.DiskSizeGB
    $DiskList | Add-Member -MemberType NoteProperty -Name "DiskState" -Value $disk.DiskState
    $DiskList | Add-Member -MemberType NoteProperty -Name "VMName" -Value $disk.ManagedBy
    $DiskList | Add-Member -MemberType NoteProperty -Name "Location" -Value $disk.Location
    $ALL_DISK += $DiskList
}
$All_VNET | Export-Excel "D:\resource.xlsx"


############    2. Networking   ############

####    2-1. Virtual Network    ####
$vnets = Get-AzVirtualNetwork
foreach($vnet in $vnets){
    $address = $vnet.AddressSpace | Select-Object -ExpandProperty AddressPrefixes
    $peering = $vnet.VirtualNetworkPeerings | Select-Object -ExpandProperty Name
    $subnets = $vnet.Subnets | Select-Object -ExpandProperty Name
    $subnetips = $vnet.Subnets | Select-Object -ExpandProperty AddressPrefix
    $gwtransit = $vnet.VirtualNetworkPeerings | Select-Object -ExpandProperty AllowGatewayTransit
    
    % {[PSCustomObject]@{
        Name = $vnet.Name
        ResourceGroup = $vnet.ResourceGroupName
        AddressSpace = $address
        Subnet = $subnets
        SubnetAddressSpace = $subnetips
        Peering = $peering
        Location = $vnet.Location
        GatewayTransit = $gwtransit
    }
}}

$ALL_VNET = @()
$vnets = Get-AzVirtualNetwork
foreach($vnet in $vnets){
    $address = $vnet.AddressSpace | Select-Object -ExpandProperty AddressPrefixes
    $peering = $vnet.VirtualNetworkPeerings | Select-Object -ExpandProperty Name
    $subnets = $vnet.Subnets | Select-Object -ExpandProperty Name
    $subnetips = $vnet.Subnets | Select-Object -ExpandProperty AddressPrefix
    $gwtransit = $vnet.VirtualNetworkPeerings | Select-Object -ExpandProperty AllowGatewayTransit

    $VnetList = New-Object -TypeName PSObject
    $VnetList | Add-Member -MemberType NoteProperty -Name "VnetName" -Value $vnet.Name
    $VnetList | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $vnet.ResourceGroupName
    $VnetList | Add-Member -MemberType NoteProperty -Name "AddressSpace" -Value $address
    $VnetList | Add-Member -MemberType NoteProperty -Name "Subnet" -Value $subnets
    $VnetList | Add-Member -MemberType NoteProperty -Name "SubnetAddressSpace" -Value $subnetips
    $VnetList | Add-Member -MemberType NoteProperty -Name "Peering" -Value $peering
    $VnetList | Add-Member -MemberType NoteProperty -Name "Location" -Value $vnet.Location
    $VnetList | Add-Member -MemberType NoteProperty -Name "GatewayTransit" -Value $gwtransit
    $ALL_VNET += $VnetList
}
$All_VNET | Export-Excel "D:\resource.xlsx"


####    2-2. Public IP    ####
$pips = Get-AzPublicIpAddress
foreach($pip in $pips){
    $sku = $pip.Sku | Select-Object -ExpandProperty Name
    $resource = $pip.IpConfiguration | Select-Object -ExpandProperty Id
    
    % {[PSCustomObject]@{
        Name = $pip.Name
        ResourceGroup = $pip.ResourceGroupName
        AddressSpace = $pip.IpAddress
        Allocation = $pip.PublicIpAllocationMethod
        Resource = $resource
        Location = $vnet.Location
    }
}}

$ALL_PIP = @()
$pips = Get-AzPublicIpAddress
foreach($pip in $pips){
    $sku = $pip.Sku | Select-Object -ExpandProperty Name
    $resource = $pip.IpConfiguration | Select-Object -ExpandProperty Id
    
    $PIPList = New-Object -TypeName PSObject
    $PIPList | Add-Member -MemberType NoteProperty -Name "PIPName" -Value $pip.Name
    $PIPList | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $pip.ResourceGroupName
    $PIPList | Add-Member -MemberType NoteProperty -Name "AddressSpace" -Value $pip.Ipaddress
    $PIPList | Add-Member -MemberType NoteProperty -Name "Allocation" -Value $pip.PublicIpAllocationMethod
    $PIPList | Add-Member -MemberType NoteProperty -Name "Resource" -Value $resource
    $PIPList | Add-Member -MemberType NoteProperty -Name "Location" -Value $pip.Location
    $ALL_PIP += $PIPList
}
$All_PIP | Export-Excel "D:\resource.xlsx"



####    2-3. NSG    ####
$azNsgs = Get-AzNetworkSecurityGroup
foreach( $azNsg in $azNsgs ) {
    Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
        Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
        @{label = 'Rule Name'; expression = { $_.Name} }, `
        @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
        @{label = 'Source Port Range'; expression = { $_.SourcePortRanges } }, Access, Priority, Direction, `
        @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
        @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
        @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } }
}

$ALL_NSG = @()
$azNsgs = Get-AzNetworkSecurityGroup
$NSGInfos=Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg
foreach($NSGInfo in $NSGInfos){
    $NSGRules = New-Object -TypeName psobject
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "NSGName" -Value $azNsg.Name
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "RuleName" -Value $NSGInfo.Name
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "SourceAddressPrefix" -Value ($NSGInfo.SourceAddressPrefix -join ' ')
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "SourcePortRange" -Value ($NSGInfo.SourcePortRange -join ' ')
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "DestinationAddressPrefix" -Value ($NSGInfo.DestinationAddressPrefix -join ' ')
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "DestinationPortRange" -Value ($NSGInfo.DestinationPortRange -join ' ')
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "Access" -Value $NSGInfo.Access
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "Priority" -Value $NSGInfo.Priority
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "Direction" -Value $NSGInfo.Direction
    $NSGRules | Add-Member  -MemberType NoteProperty -Name "ResourceGroupName" -Value $azNsg.ResourceGroupName
    $All_NSGInfos += $NSGRules
}
$All_NSG | Export-Excel "D:\resource.xlsx"



####    2-4. UDR    ####
$udrs = Get-AzRouteTable
foreach($udr in $udrs){
    Get-AzRouteConfig -RouteTable $udr | `
    Select-Object @{label = 'Route Table Name'; expression = { $udr.Name }}, `
    @{label = 'Rule Name'; expression = { $_.Name}}, `
    @{label = 'Address'; expression = { $_.AddressPrefix}} `
    @{label = 'Next Hop Type'; expression = { $_.NextHopType}} `
    @{label = 'Next Hop IP Address'; expression = { $_.NextHopIpAddress}}
}


$ALL_UDR = @()
$udrs = Get-AzRouteTable
$udrInfos = Get-AzRouteConfig -RouteTable $udr
foreach($udrInfo in $udrInfos){
    $UDRList = New-Object -TypeName PSObject
    $UDRList | Add-Member  -MemberType NoteProperty -Name "RouteTableName" -Value $udrInfo.Name
    $UDRList | Add-Member  -MemberType NoteProperty -Name "Address" -Value $udrInfo.AddressPrefix
    $UDRList | Add-Member  -MemberType NoteProperty -Name "NextHopType" -Value $udrInfo.NextHopType
    $UDRList | Add-Member  -MemberType NoteProperty -Name "NextHopIPAddress" -Value $udrInfo.NextHopIpAddress
    $ALL_UDR += $UDRList
}
$All_UDR | Export-Excel "D:\resource.xlsx"



####    2-5. Private Link    ####
$pendpoints = Get-AzPrivateEndpoint 
foreach($pendpoint in $pendpoints){
    % {[PSCustomObject]@{
        Name = $pendpoint.Name
        ResourceGroup = $pendpoint.ResourceGroupName
        Location = $pendpoint.Location
    }
}}


$ALL_PL = @()
$pendpoints = Get-AzPrivateEndpoint 
foreach($pendpoint in $pendpoints){
    $PEList = New-Object -TypeName PSObject
    $PEList | Add-Member  -MemberType NoteProperty -Name "Name" -Value $pendpoint.Name
    $PEList | Add-Member  -MemberType NoteProperty -Name "ResourceGroupName" -Value $pendpoint.ResourceGroupName
    $PEList | Add-Member  -MemberType NoteProperty -Name "Location" -Value $pendpoint.Location
    $ALL_PL += $PEList
}
$All_PL | Export-Excel "D:\resource.xlsx"



####    2-6. Load Balancer   ####
# 1) 기본정보
$lbs = Get-AzLoadBalancer
foreach($lb in $lbs){
    $sku = $lb.Sku | Select-Object -ExpandProperty Name
    $backendaddress = $lb.BackendAddressPools | Select-Object -ExpandProperty Name

    % {[PSCustomObject]@{
        Name = $lb.Name
        ResourceGroup = $lb.ResourceGroupName
        SKU = $sku
        BackendAddressPool = $backendaddress
        Location = $lb.Location
    }
}}

# 2) Frontend IP
foreach($lb in $lbs){
    $frontend = $lb | Select-Object -ExpandProperty FrontendIpConfigurations
    $name = $frontend.Name
    $publicIpAddress = $frontend.PublicIpAddress
    $privateIpAddress = $frontend.PrivateIpAddress
    $subnet = $frontend.subnet

    % {[PSCustomObject]@{
        LBName = $lb.Name
        Name = $name
        PublicIpAddress = $publicIpAddress.Id
        PrivateIpAddress = $privateIpAddress
        Subnet = $subnet
    }
}}


# 3) Backend Pool
foreach($lb in $lbs){
    $backend = $lb | Select-Object -ExpandProperty BackendAddressPools
    $name = $backend.Name
    #$backendIpConfig = $backend.BackendIpConfigurations
    #$address = $backend.LoadBalancerBackendAddresses
    #$lbrules = $backend.LoadBalancingRules

    % {[PSCustomObject]@{
        LBName = $lb.Name
        Name = $name
        #VMIP = $backendIpConfig
        #Address = $address
        #LoadBalancingRules = $lbrules
    }
}}


# 4) Health Probes
foreach($lb in $lbs){
    $probe = $lb | Select-Object -ExpandProperty Probes
    $name = $probe.Name
    $protocol = $probe.Protocol
    $port = $probe.Port
    $rules = $probe.LoadBalancingRules

    % {[PSCustomObject]@{
        LBName = $lb.Name
        Name = $name
        Protocol = $protocol
        Port = $port
        LoadBalancingRules = $rules
    }
}}

# 5) Load Balancing Rules
foreach($lb in $lbs){
    $lbrule = $lb | Select-Object -ExpandProperty LoadBalancingRules
    $name = $lbrule.Name
    $protocol = $lbrule.Protocol
    $frontendport = $lbrule.FrontendPort
    $backendport = $lbrule.BackendPort

    % {[PSCustomObject]@{
        LBName = $lb.Name
        Name = $name
        Protocol = $protocol
        Port = $port
        LoadBalancingRules = $rules
    }
}}

# 6) Inbound NAT Rules
Get-AzLoadBalancer | Select-Object -ExpandProperty InboundNatRules








#### 3. Storage ####
Get-AzStorageAccount | `
Select-Object | Select-Object StorageAccountName, ResourceGroupName, `
@{label = 'Location'; expression = {$_.PrimaryLocation}}, `
@{label = 'SKU'; expression = {$_.SkuName}}, `
Kind, AccessTier 


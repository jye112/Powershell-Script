$date = Get-Date -Format "yyyyMMdd"
$title = ("Azure_All_Resource_List_" + $date)

# VirtualMachine
$All_VM_NIC_infos = @()
$vnets = Get-AzVirtualNetwork
$vms = Get-AzVM
@( foreach ($vm in $vms) {
        $vmIPId = $vm.NetworkProfile.NetworkInterfaces.Id
        foreach ($vnet in $vnets) {
            $VMnicMatch = New-Object -TypeName psobject
 
            $vnetIPId = $vnet.Subnets.IpConfigurations.Id
            if ($vnetIPId.Startswith($vmIPId) ) {
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "VM_Name" -Value $vm.Name
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "vNet_Name" -Value $vnet.Name
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "vNet_Location" -Value $vnet.Location
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "vNet_RG_Name" -Value $vnet.ResourceGroupName
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "vNet_AddressPrefix" -Value $vnet.AddressSpace.AddressPrefixes[0]
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "Subnet_Name" -Value $vnet.Subnets[0].Name
                $VMnicMatch | Add-Member  -MemberType NoteProperty -Name "Subnet_AddressPrefix" -Value $vnet.Subnets[0].AddressPrefix[0]
                $All_VM_NIC_infos += $VMnicMatch 
            }
        }
    }
)
$ALL_VM_infos= az vm list -d --query "[].{ResourceGroup:resourceGroup, VM_Name:name, UUID:vmId, SKUs:hardwareProfile.vmSize, Status:powerState, Location:location, PrivateIP:privateIps, AvailabilitySet:availabilitySet.id, BootDiagStorageAccount:diagnosticsProfile.bootDiagnostics.storageUri, NICName:networkProfile.networkInterfaces[0].id, OSType:storageProfile.osDisk.osType, OSOffer:storageProfile.imageReference.offer, OSPublisher:storageProfile.imageReference.publisher, OSSKU:storageProfile.imageReference.sku, OSVersion:storageProfile.imageReference.exactVersion, OSDiskName:storageProfile.osDisk.name, OSDiskSize:storageProfile.osDisk.diskSizeGb, OSDiskType:storageProfile.osDisk.managedDisk.storageAccountType}" -o json | ConvertFrom-Json `
| Select-Object VM_Name, ResourceGroup, UUID, SKUs, Status, Location, PrivateIP, @{N='AvailabilitySet'; E={$_.AvailabilitySet.Split("/")[8]}},@{N='NICName'; E={$_.NICName.Split("/")[8]}}, OSType, OSOffer, OSPublisher, OSSKU, OSVersion, OSDiskName, OSDiskSize, OSDiskType, @{N='BootDiagStorageAccountName';E={($_.BootDiagStorageAccount.Split("https://")[1]).Split(".")[0]}}

Join-Object -Left $ALL_VM_infos -Right $All_VM_NIC_infos -LeftJoinProperty VM_Name -RightJoinProperty VM_Name -Type AllInLeft -ExcludeRightProperties "VM_Name"| Export-Excel -Path "D:\$title.xlsx" -WorksheetName VirtualMachine


# Storage Account
$sas = az storage account list --query "[].{ResourceGroup:resourceGroup, AccessTier:accessTier, Kind:kind, Location:location, Name:name, SKUName:sku.name, SKUTier:sku.tier}" -o json | ConvertFrom-Json
$ALL_SA = @()
foreach($sa in $sas){
    $SA_List = New-Object -TypeName PSObject
    $SA_List | Add-Member -MemberType NoteProperty -Name "ResourceGroup" -Value $sa.ResourceGroup
    $SA_List | Add-Member -MemberType NoteProperty -Name "Name" -Value $sa.Name
    $SA_List | Add-Member -MemberType NoteProperty -Name "Location" -Value $sa.Location
    $SA_List | Add-Member -MemberType NoteProperty -Name "AccessTier" -Value $sa.AccessTier
    $SA_List | Add-Member -MemberType NoteProperty -Name "Kind" -Value $sa.Kind
    $SA_List | Add-Member -MemberType NoteProperty -Name "SKUName" -Value $sa.SKUName
    $SA_List | Add-Member -MemberType NoteProperty -Name "SKUTier" -Value $sa.SKUTier
    if ($sa.Name.Contains('vm')) {
        $SA_List | Add-Member -MemberType NoteProperty -Name "Description" -Value 'VM Boot Diag'
    }
    else {
        $SA_List | Add-Member -MemberType NoteProperty -Name "Description" -Value 'Network Diag'
    }
    $ALL_SA += $SA_List
} 
$ALL_SA | Export-Excel -Path "D:\$title.xlsx" -WorksheetName StorageAccount


# Network(Vnet, Subnet)
$ALL_VNET = @()
$vnets = Get-AzVirtualNetwork
foreach($vnet in $vnets){
    $address = $vnet.AddressSpace | Select-Object -ExpandProperty AddressPrefixes
    $peering = $vnet.VirtualNetworkPeerings | Select-Object -ExpandProperty Name
    $subnets = $vnet.Subnets | Select-Object -ExpandProperty Name
    $subnetips = $vnet.Subnets | Select-Object -ExpandProperty AddressPrefix
    $gwtransit = $vnet.VirtualNetworkPeerings | Select-Object -ExpandProperty AllowGatewayTransit

    $VnetList = New-Object -TypeName PSObject
    $VnetList | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $vnet.ResourceGroupName
    $VnetList | Add-Member -MemberType NoteProperty -Name "Location" -Value $vnet.Location
    $VnetList | Add-Member -MemberType NoteProperty -Name "vNet_Name" -Value $vnet.Name
    $VnetList | Add-Member -MemberType NoteProperty -Name "vNet_AddressPrefix" -Value $address
    $VnetList | Add-Member -MemberType NoteProperty -Name "Subnet_Name" -Value $subnets
    $VnetList | Add-Member -MemberType NoteProperty -Name "Subnet_AddressPrefix" -Value $subnetips
    # $VnetList | Add-Member  -MemberType NoteProperty -Name "Perring_Name" -Value $vnet.VirtualNetworkPeerings[0].Name
    # $VnetList | Add-Member  -MemberType NoteProperty -Name "Peering_vNet_Name" -Value $vnet.VirtualNetworkPeerings[0].RemoteVirtualNetwork.Id.Split("/")[8]
    # $VnetList | Add-Member  -MemberType NoteProperty -Name "Peering_vNet_Address" -Value $vnet.VirtualNetworkPeerings[0].RemoteVirtualNetworkAddressSpace.AddressPrefixes[0]
    $ALL_VNET += $VnetList
}
$ALL_VNET | Export-Excel -Path "D:\$title.xlsx" -WorksheetName Network


# Network Security Group
$azNsgs=Get-AzNetworkSecurityGroup
$ALL_NSG=foreach( $azNsg in $azNsgs ) {
    Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
        Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
        @{label = 'Rule Name'; expression = { $_.Name} }, `
        @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
        @{label = 'Source Port Range'; expression = { $_.SourcePortRanges } }, Access, Priority, Direction, `
        @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
        @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
        @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } }
}
$ALL_NSG | Export-Excel -Path "D:\$title.xlsx" -WorksheetName NetworkSecurityGroup


# vWAN/vHub
$All_vHub_infos = @()
$vHubs = az network vhub list --resource-group secc-net-krc-vwan-rg --query "[].{AddressPrefix:addressPrefix, Location:location, VirtualHubName:name, ResourceGroup:resourceGroup, SKU:sku, VirtualRouterASN:virtualRouterAsn, VirtualRouterIPs:virtualRouterIps, VirtualWAN:virtualWan.id, VPNGateway:vpnGateway.id}" -o json `
| ConvertFrom-Json `
| Select-Object ResourceGroup, @{N='vWan_Name';E={$_.VirtualWAN.Split("/")[8]}}, @{N='vWan_SKU';E={$_.SKU}}, @{N='vHub_Name';E={$_.VirtualHubName}}, @{l='vHub_AddressPrefix';E={$_.AddressPrefix}}, @{l='vHub_VirtualRouterIPs';E={$_.VirtualRouterIPs -Join(", ")}}, @{N='vHub_VPNGateway_Name';E={$_.VPNGateway.Split("/")[8]}}
 
@(foreach ($vHub_Name in $vHubs.vHub_Name) {
    $vHubMatch = New-Object -TypeName psobject
    $vHub_vnet_connection = az network vhub connection list --resource-group secc-net-krc-vwan-rg --vhub-name $vHub_Name --query "[].{ConnectionName:name, RemoteVNet:remoteVirtualNetwork.id}" -o json | ConvertFrom-Json| Select-Object ConnectionName, @{N='RemoteVNet';E={$_.RemoteVNet.Split("/")[8]}}
    $vHubMatch | Add-Member  -MemberType NoteProperty -Name "vHub_Name" -Value $vHub_Name
    $vHubMatch | Add-Member  -MemberType NoteProperty -Name "vHub_to_vNet_ConnectionName" -Value $vHub_vnet_connection.ConnectionName
    $vHubMatch | Add-Member  -MemberType NoteProperty -Name "vHub_to_vNet_RemoteVNet" -Value $vHub_vnet_connection.RemoteVNet
    $All_vHub_infos += $vHubMatch 
})
Join-Object -Left $vHubs -Right $All_vHub_infos -LeftJoinProperty $vHubs.vHub_Name -RightJoinProperty $All_vHub_infos.vHub_Name -ExcludeRightProperties "vHub_Name" -Type OnlyIfInBoth | Export-Excel -Path "D:\$title.xlsx" -WorksheetName vWAN-vHub


# VPN Site
az network vpn-site list --resource-group secc-net-krc-vwan-rg --query "[].{VPNSiteName:name, AddressPrefix:addressSpace.addressPrefixes[0], DeviceVendor:deviceProperties.deviceVendor, Location:location, ResourceGroup:resourceGroup, VirtualWAN:virtualWan.id, VPNSiteLinkName:vpnSiteLinks[0].name, VPNSiteLinkASN:vpnSiteLinks[0].bgpProperties.asn, VPNSiteLinkBGPAddress:vpnSiteLinks[0].bgpProperties.bgpPeeringAddress, VPNSiteLinkIPAddress:vpnSiteLinks[0].ipAddress, VPNSiteLinkProvider:vpnSiteLinks[0].linkProperties.linkProviderName, VPNSiteLinkSpeed:vpnSiteLinks[0].linkProperties.linkSpeedInMbps}" -o json `
| ConvertFrom-Json `
| Select-Object ResourceGroup, Location, @{N='VirtualWAN';E={($_.VirtualWAN.Split("/")[8])}}, VPNSiteName, AddressPrefix, DeviceVendor, VPNSiteLinkName, VPNSiteLinkASN, VPNSiteLinkBGPAddress, VPNSiteLinkIPAddress, VPNSiteLinkProvider, VPNSiteLinkSpeed `
| Export-Excel -Path "D:\$title.xlsx" -WorksheetName vWAN-vHub-VPNSite


# Express Route
$ER_Left = az network express-route list --query "[].{ER_Circuit_Location:location, ER_Circuit_Name:name, ER_Circuit_ResourceGroup:resourceGroup, ER_Circuit_AzureASN:peerings[0].azureAsn, ER_Circuit_PeerASN:peerings[0].peerAsn, ER_Circuit_PeeringType:peerings[0].peeringType, ER_Circuit_PrimaryAzurePort:peerings[0].primaryAzurePort, ER_Circuit_PrimaryPeerAddressPrefix:peerings[0].primaryPeerAddressPrefix, ER_Circuit_SecondaryAzurePort:peerings[0].secondaryAzurePort, ER_Circuit_SecondaryPeerAddressPrefix:peerings[0].secondaryPeerAddressPrefix, ER_Circuit_VlanID:peerings[0].vlanId, ER_Circuit_ServiceProviderName:serviceProviderProperties.serviceProviderName, ER_Circuit_ServiceProviderBandwith:serviceProviderProperties.bandwidthInMbps, ER_Circuit_ServiceProviderLocation:serviceProviderProperties.peeringLocation}" -o json | ConvertFrom-Json `
| Select-Object ER_Circuit_ResourceGroup, ER_Circuit_Location, ER_Circuit_Name, ER_Circuit_AzureASN, ER_Circuit_PeerASN, ER_Circuit_PeeringType, ER_Circuit_PrimaryAzurePort, ER_Circuit_PrimaryPeerAddressPrefix, ER_Circuit_SecondaryAzurePort, ER_Circuit_SecondaryPeerAddressPrefix, ER_Circuit_VlanID, ER_Circuit_ServiceProviderName, ER_Circuit_ServiceProviderBandwith, ER_Circuit_ServiceProviderLocation

$ER_Right=az network express-route gateway list --query "value[].{ER_Connection_Name:expressRouteConnections[0].name, ER_Circuit_Name:expressRouteConnections[0].expressRouteCircuitPeering.id,ER_Circuit_PeeringType:expressRouteConnections[0].expressRouteCircuitPeering.id, location:location, name:name, RG:resourceGroup, vHub_Name:virtualHub.id}"-o json `
| ConvertFrom-Json `
| Select-Object ER_Connection_Name, @{N='ER_Circuit_Name'; E={$_.ER_Circuit_Name.Split("/")[8]}}, @{N='ER_Gateway_vHubName';E={$_.vHub_Name.Split("/")[8]}}, @{N='ER_Gateway_location';E={$_.location}}, @{N='ER_Gateway_Name';E={$_.name}}

Join-Object -Left $ER_Left -Right $ER_Right -LeftJoinProperty ER_Circuit_Name -RightJoinProperty ER_Circuit_Name -Type AllInLeft -ExcludeRightProperties "ER_Circuit_Name" | Export-Excel -Path "D:\$title.xlsx" -WorksheetName ExpressRoute



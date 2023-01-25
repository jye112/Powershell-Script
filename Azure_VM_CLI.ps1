$SUB_ID=""
$RG=""
$location=""
$vnet=""
$subnet=""
$nsg=""

# Subscription 등록
az account set -s $SUB_ID

# Resource Group 생성
az group create -l $location -n $RG

# VNet01 생성
az network vnet create --resource-group $RG --location $location -n $vnet --address-prefixes 10.0.0.0/8

# NSG01 생성
az network nsg create --resource-group $RG --name $nsg

# Subnet01 생성
az network vnet subnet create --resource-group $RG --vnet-name $vnet --name $subnet --address-prefixes 10.1.0.0/16 --network-security-group $nsg

# NSG01 Rule 생성
az network nsg rule create --resource-group $RG --nsg-name $nsg -n RDP --protocol 'tcp' --direction inbound --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 3389 --access allow --priority 200

# VM01-NIC 생성
az network nic create --resource-group $RG --name test-nic-01 --vnet-name $vnet --subnet $subnet 

# VM02-NIC 생성
az network nic create --resource-group $RG --name test-nic-02 --vnet-name $vnet --subnet $subnet 

# VM03-NIC 생성
az network nic create --resource-group $RG --name test-nic-03 --vnet-name $vnet --subnet $subnet 

# VM04-NIC 생성
az network nic create --resource-group $RG --name test-nic-04 --vnet-name $vnet --subnet $subnet 

# VM 01 생성
az vm create --resource-group $RG --name test-vm-01 --nics test-nic-01 --image UbuntuLTS --admin-username testuser --admin-password password

# VM 02 생성
az vm create --resource-group $RG --name test-vm-02 --nics test-nic-02 --image UbuntuLTS --admin-username testuser --admin-password password

# VM 03 생성
az vm create --resource-group $RG --name test-vm-03 --nics test-nic-03 --image UbuntuLTS --admin-username testuser --admin-password password

# VM 04 생성
az vm create --resource-group $RG --name test-vm-04 --nics test-nic-04 --image UbuntuLTS --admin-username testuser --admin-password password

# Public IP 생성
az network public-ip create --resource-group $RG --name test-pip-01 --sku Standard

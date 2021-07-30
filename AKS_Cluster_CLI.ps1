################ Azure CLI ################

### 변수 설정 ###
$SUB_ID=""

$VNET_RG="aks-cluster-rg"
$VNET="aks-vnet"

$AKS_SERVICE_RG="aks-cluster-rg"
$AKS_SERVICE="aks-cluster"
$AKS_SERVICE_SUBNET="aks-subnet"

az account set -s $SUB_ID


### VNET 생성 ###
az group create -n $VNET_RG -l Koreacentral
az network vnet create -n $VNET -g $VNET_RG --address-prefixes 10.0.0.0/16


### AKS 생성 ###
az group create -g $AKS_SERVICE_RG -l koreacentral

$AKS_SUBNET=az network vnet subnet create -g $VNET_RG -n $AKS_SERVICE_SUBNET --address-prefixes 10.0.1.0/24 --vnet-name $VNET | ConvertFrom-Json

az aks create -n $AKS_SERVICE -g $AKS_SERVICE_RG `
            --load-balancer-sku Standard --enable-rbac `
            --network-plugin azure --node-count 3 `
            --node-vm-size Standard_D4s_v3 --vnet-subnet-id $AKS_SUBNET.id `
            --service-cidr 10.255.0.0/24  --dns-service-ip 10.255.0.10 `
            --docker-bridge-address 10.255.1.1/24 --enable-managed-identity

$MC_AKS_RG=$(az aks show -n $AKS_SERVICE -g $AKS_SERVICE_RG --query "nodeResourceGroup" -o tsv)


### Managed Identity info ###
$MID=az identity show -n $AKS_SERVICE-agentpool -g $MC_AKS_RG | ConvertFrom-Json
$MID_ID=$MID.id
$MID_CLIENT_ID=$MID.clientId


### Managed Identity Role Assignment ###
$aksVmssId=$(az vmss list -g $MC_AKS_RG --query "[0].id" -o tsv)
az role assignment create --role Reader --assignee $MID_CLIENT_ID --scope $aksVmssId


### Get AKS Credential ###
az aks get-credentials -n $AKS_SERVICE -g $AKS_SERVICE_RG


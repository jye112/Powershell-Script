################ Powershell ################

$ResourceGroup = "aks-cluster-rg"
$AKSClusterName = "aks-cluster"

# Resource Group 생성
New-AzResourceGroup -Name $ResourceGroup -Location koreacentral

## AKS 클러스터 생성
New-AzAksCluster -ResourceGroupName $ResourceGroup -Name $AKSClusterName -NodeCount 3 -NodeVmSize Standard_D2s_v3

## 클러스터를 로컬 환경과 연결
Install-AzAksKubectl
Import-AzAksCredential -ResourceGroupName $ResourceGroup -Name $AKSClusterName

# Container Registry 생성
$registry = New-AzContainerRegistry -ResourceGroupName $ResourceGroup -Name "jyeContainerRegistry" -EnableAdminUser -Sku Basic

# Container Registry 서비스 주체 인증
$creds = Get-AzContainerRegistryCredential -Registry $registry
$creds.Password | docker login $registry.LoginServer -u $creds.Username --password-stdin



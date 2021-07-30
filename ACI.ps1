# Resource Group 생성
New-AzResourceGroup -Name $ResourceGroup -Location EastUS

# Docker Hub Repository의 이미지로 Azure Container Instance 생성
New-AzContainerGroup -ResourceGroupName $ResourceGroup -Name jyeContainer -Image mcr.microsoft.com/windows/servercore/iis:nanoserver -OsType Windows -DnsNameLabel aci-demo-win
Get-AzContainerGroup -ResourceGroupName $ResourceGroup -Name jyeContainer
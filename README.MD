## 목적
- Azure 리소스를 리스트업하고 리소스 배포 및 관리를 자동화하기 위해 Powershell 및 CLI 스크립트를 작성하였다.

## 설명
* ACI.ps1 : Azure Container Instance 배포를 위한 스크립트
* AKS_Cluster_CLI.ps1 : Azure Kubernetes Service를 CLI 명령어로 배포하기 위한 스크립트
* AKS_Cluster_psh.ps1 : Azure Kubernetes Service를 Powershell 명령어로 배포하기 위한 스크립트
* Azure_All_Resource_List_v1.ps1 : Azure 상에 배포된 리소스(Compute, Network 등)에 대한 상세 정보들을 액셀로 리스트업하기 위한 스크립트 version 1
* Azure_All_Resource_List_v2.ps1 : Azure 상에 배포된 리소스(Compute, Network 등)에 대한 상세 정보들을 액셀로 리스트업하기 위한 스크립트 version 2
* Azure_Basic_Script.ps1 : Azure 상에 배포된 리소스(Compute, Network 등)에 대한 상세 정보들을 액셀로 리스트업하기 위한 스크립트 (Basic)
* Azure_Unused_Resource_List_for_Slack.ps1 : Azure 상에 배포된 리소스 중 사용하지 않는 리소스들에 대해 Slack으로 알림을 주기 위한 스크립트
* Azure_VM_CLI.ps1 : Azure VM을 CLI 명령어로 배포하기 위한 스크립트
* Certificate.ps1 : Powershell 인증서를 만들기 위한 스크립트
* K8S_Cluster.ps1 : Azure IaaS 리소스들로 Kubernetes 클러스터를 배포하기 위한 스크립트
* NSG_ChangeChecker.ps1 : Azure Network Security Group(NSG) 상 변경 사항이 있을 때 Slack에 알림을 주기 위한 스크립트
* NSG_Rule_Setting.ps1 : Azure NSG 상에 규칙을 일괄 적용하기 위한 스크립트
* VM-to-Image.ps1 : Azure VM을 이미지로 만들기 위한 스크립트
* Windows Features.ps1 : Windows 상에 설치된 Windows Feature를 확인하거나 새롭게 설치하기 위한 스크립트

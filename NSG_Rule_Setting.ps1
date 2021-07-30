SELECT-AzureRmSubscription ""

$TemplateNSGRules1 =  Get-AzureRmNetworkSecurityGroup -Name krz-m-ath-central-nic-ext-nsg -ResourceGroupName RG-krz-m-Auth-central | Get-AzureRmNetworkSecurityRuleConfig
$TemplateNSGRules2 =  Get-AzureRmNetworkSecurityGroup -Name krz-m-ath-central-nic-int-nsg -ResourceGroupName RG-krz-m-Auth-central | Get-AzureRmNetworkSecurityRuleConfig
$TemplateNSGRules3 =  Get-AzureRmNetworkSecurityGroup -Name krz-m-ath-central-sub-ext-nsg -ResourceGroupName RG-krz-m-Auth-central | Get-AzureRmNetworkSecurityRuleConfig
$TemplateNSGRules4 =  Get-AzureRmNetworkSecurityGroup -Name krz-m-ath-central-sub-int-nsg -ResourceGroupName RG-krz-m-Auth-central  | Get-AzureRmNetworkSecurityRuleConfig



SELECT-AzureRmSubscription ""

$NSG1 = Get-AzureRmNetworkSecurityGroup -Name efz-c-ath-nic-ext-nsg -ResourceGroupName RG-efz-c-auth
$NSG2 = Get-AzureRmNetworkSecurityGroup -Name efz-c-ath-nic-int-nsg -ResourceGroupName RG-efz-c-auth
$NSG3 = Get-AzureRmNetworkSecurityGroup -Name efz-c-ath-sub-ext-nsg -ResourceGroupName RG-efz-c-auth
$NSG4 = Get-AzureRmNetworkSecurityGroup -Name efz-c-ath-sub-int-nsg -ResourceGroupName RG-efz-c-auth

 

foreach ($rule in $TemplateNSGRules1) {
    $NSG1 | Add-AzureRmNetworkSecurityRuleConfig -Name $rule.Name -Direction $rule.Direction -Priority $rule.Priority -Access $rule.Access -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange $rule.SourcePortRange -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange -Protocol $rule.Protocol # -Description $rule.Description
    $NSG1 | Set-AzureRmNetworkSecurityGroup
}

foreach ($rule in $TemplateNSGRules2) {
    $NSG2 | Add-AzureRmNetworkSecurityRuleConfig -Name $rule.Name -Direction $rule.Direction -Priority $rule.Priority -Access $rule.Access -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange $rule.SourcePortRange -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange -Protocol $rule.Protocol # -Description $rule.Description
    $NSG2 | Set-AzureRmNetworkSecurityGroup
}

foreach ($rule in $TemplateNSGRules3) {
    $NSG3 | Add-AzureRmNetworkSecurityRuleConfig -Name $rule.Name -Direction $rule.Direction -Priority $rule.Priority -Access $rule.Access -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange $rule.SourcePortRange -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange -Protocol $rule.Protocol # -Description $rule.Description
    $NSG3 | Set-AzureRmNetworkSecurityGroup
}


foreach ($rule in $TemplateNSGRules4) {
    $NSG4 | Add-AzureRmNetworkSecurityRuleConfig -Name $rule.Name -Direction $rule.Direction -Priority $rule.Priority -Access $rule.Access -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange $rule.SourcePortRange -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange -Protocol $rule.Protocol # -Description $rule.Description
    $NSG4 | Set-AzureRmNetworkSecurityGroup
}

 

$NSGRules = Import-Excel 

$NSG = ""
$NSGInfos = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG
foreach ($NSGRule in $NSGRules){
    $NSGInfos | Add-AzNetworkSecurityRuleConfig -Name $NSGRules[$NSGRule.Index].RuleName -SourceAddressPrefix $NSGRules[$NSGRule.Index] -SourcePortRange $NSGRules[$NSGRule.Index] -DestinationAddressPrefix $NSGRules[$NSGRule.Index] -DestinationPortRange $NSGRules[$NSGRule.Index].DestinationPortRange
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

Add-AzNetworkSecurityRuleConfig -Name
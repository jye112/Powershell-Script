#Install-Module PSSlack -Force
#Import-Module PSSlack
$appid = ""
$secret= ConvertTo-SecureString "" -AsPlainText -Force
$psCred= New-Object System.Management.Automation.PSCredential($appid,$secret)
$tenantid= ""

Login-AzAccount -ServicePrincipal -Credential $psCred -TenantId $tenantid




$Subscriptions=Get-AzSubscription
$date = Get-Date -Format "yyyy-MM-dd"

#WebhookURI
#$Uri = "https://hooks.slack.com/services/(블라블라)"

Foreach ($subscription in $Subscriptions) {
    Select-AzSubscription -Subscription $subscription.Name
    # Select-AzSubscription -Subscription "jdp_multiverse"

    $result = @()
    $title = ($date + "/" + $subscription.name + "/Unused Azure Resource")

    # unused rg
    $AllRGs = (Get-AzResourceGroup).ResourceGroupName
    $UsedRGs = (Get-AzResource | Group-Object ResourceGroupName).Name
    $EmptyRGs = @($AllRGs | Where-Object {$_ -notin $UsedRGs})
    
    if($EmptyRGs -ne $null){        
        $EmptyRG = @()
        $result += foreach($num in 0..($EmptyRGs.Count-1)) {
            $EmptyRG = [ordered]@{
                Name = $null
                ResourceGroup = $EmptyRGs[$num]
                Type = "ResourceGroup"
            }
            New-Object -TypeName PSObject -Property $EmptyRG
        }
    }

    # unattached nic list
    
    $nics = @(Get-AzNetworkInterface | Where-Object {$PSItem.VirtualMachine -eq $null} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "NIC"
        }
    })    
    
    if($nics -ne $null){
        $nic = @()
        $result += foreach($num in 0..($nics.count-1)) {
            $nic = [ordered]@{
                Name = $nics[$num].Name
                ResourceGroup = $nics[$num].ResourceGroup
                Type = $nics[$num].Type
            }
            New-Object -TypeName PSObject -Property $nic
        }
    }

    # unassociated pip
    $pips = @(Get-AzPublicIpAddress | Where-Object {$PSItem.Ipconfiguration -eq $null} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "PIP"
        }
    })

    if($pips -ne $null){
        $pip = @()
        $result += foreach($num in 0..($pips.Count-1)) {
            $pip = [ordered]@{
                Name = $pips[$num].Name
                ResourceGroup = $pips[$num].ResourceGroup
                Type = $pips[$num].Type
            }
            New-Object -TypeName PSObject -Property $pip
        }
    }

    # unattached disk
    $disks = @(Get-AzDisk | Where-Object {$PSItem.ManagedBy -eq $null} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "Disk"
        }
    })

    if($disks -ne $null){
        $disk = @()
        $result += foreach($num in 0..($disks.Count-1)) {
            $disk = [ordered]@{
                Name = $disks[$num].Name
                ResourceGroup = $disks[$num].ResourceGroup
                Type = $disks[$num].Type
            }
            New-Object -TypeName PSObject -Property $disk
        }
    }

    # unused avset

    $RGs = Get-AzResourceGroup
    foreach ($RG in $RGs){
        $avss += @(Get-AzAvailabilitySet -ResourceGroupName $RG.ResourceGroupName | Where-Object {$PSItem.VirtualMachinesReferences.Count -eq 0} | % {[PSCustomObject]@{
            Name = $_.Name
            ResourceGroup = $_.ResourceGroupName
            Type = "Avs"
            }
        })
    }

    if($avss -ne $null){
        $avs = @()
        $result += foreach($num in 0..($avss.Count-1)) {
            $avs = [ordered]@{
                Name = $avss[$num].Name
                ResourceGroup = $avss[$num].ResourceGroup
                Type = $avss[$num].Type
            }
            New-Object -TypeName PSObject -Property $avs
        }        
    }

       
    # unused vnet

    $vnets = @(Get-AzVirtualNetwork | Where-Object {$PSItem.Subnets.IpConfigurations.count -eq 0 -and $PSItem.Subnets.ResourceNavigationLinks -eq $null} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "Vnet"
        }
    })

    if($vnets -ne $null){
        $vnet = @()
        $result += foreach($num in 0..($vnets.Count-1)) {
            $vnet = [ordered]@{
                Name = $vnets[$num].Name
                ResourceGroup = $vnets[$num].ResourceGroup
                Type = $vnets[$num].Type
            }
            New-Object -TypeName PSObject -Property $vnet
        }
    }

    # unused nsg

    $nsgs = @(Get-AzNetworkSecurityGroup | Where-Object {$PSItem.NetworkInterfaces.Count -eq 0 -and $PSItem.Subnets.count -eq 0} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "NSG"
        }
    })

    if($nsgs -ne $null){
        $nsg = @()
        $result += foreach($num in 0..($nsgs.Count-1)) {
            $nsg = [ordered]@{
                Name = $nsgs[$num].Name
                ResourceGroup = $nsgs[$num].ResourceGroup
                Type = $nsgs[$num].Type
            }
            New-Object -TypeName PSObject -Property $nsg
        }
    }

    # unused lb

    $lbs = @(Get-AzLoadBalancer| Where-Object {$PSItem.BackendAddressPools.BackendIpConfigurations.Count -eq 0} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "LB"
        }
    })

    if($lbs -ne $null){
        $lb = @()
        $result += foreach($num in 0..($lbs.Count-1)) {
            $lb = [ordered]@{
                Name = $lbs[$num].Name
                ResourceGroup = $lbs[$num].ResourceGroup
                Type = $lbs[$num].Type
            }
            New-Object -TypeName PSObject -Property $lb
        }
    }

    # unused agw
    $agws = @(Get-AzApplicationGateway | Where-Object {$PSItem.BackendAddressPools.BackendAddresses.Count -eq 0 -and $PSItem.BackendAddressPools.BackendIpConfigurations.Count -eq 0} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "AGW"
        }
    })

    if($agws -ne $null){
        $agw = @()
        $result += foreach($num in 0..($agws.Count-1)) {
            $agw = [ordered]@{
                Name = $agws[$num].Name
                ResourceGroup = $agws[$num].ResourceGroup
                Type = $agws[$num].Type
            }
            New-Object -TypeName PSObject -Property $agw
        }
    }

    # Remove Unused Resource 확인 후 사용할 것(자신없으면 쓰지마세요!)
    <# 

    foreach($num in 0..($result.Count -1)){
        if($result[$num].Name.length -gt 0){
            $resourceId = (Get-AzResource -Name $result[$num].Name -ResourceGroupName $result[$num].ResourceGroup).Id
            Write-Host "Removing - Resource : "$result[$num].Name" ResourceGroup : "$result[$num].ResourceGroup
            Remove-AzResource -ResourceId $resourceId -Force
        }        
    }
    #>
    
    $results = $result | Format-Table -HideTableHeaders -GroupBy "Type" -AutoSize -Wrap `
        @{Expression={$_.Name}; Align = "Left"},`
        @{Expression={$_.ResourceGroup}; Align = "Right"} | Out-String
    
    # Send Message
    if($results.Length -gt 0){
        $results = $results.Insert(0, '```')
        $results = $results.Insert(($results.Length), '```')
        New-SlackMessageAttachment -Color $_PSSlackColorMap.red -Text $results -Title $Title -Fallback "Unused Azure resource" |
        New-SlackMessage -Channel '@test' -IconEmoji :no_entry_sign: -AsUser -Username "Unuse_Resource_Checker"  | Send-SlackMessage -Uri $Uri
    }   
}
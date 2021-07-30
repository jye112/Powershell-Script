
Login-AzureRmAccount -ServicePrincipal -Credential $psCred -TenantId $tenantid

Select-AzureRmSubscription -Subscription ""

#(Get-AzureRmNetworkSecurityGroup -ResourceGroupName RG-eaz-m-web -Name eaz-m-web-sub-ext-nsg).Id
$url = "" #slack webhook url
$token ="" #slack token

$NSGs = Get-AzureRmNetworkSecurityGroup

New-SlackMessageAttachment -Color $_PSSlackColorMap.red `
                                                    -Title 'NSG alert start' `
                                                    -Fallback 'NSG alert start' |
                            New-SlackMessage -Channel '#vm_valid_check' `
                                            -Username "NSG_Checker_US" `
                                            -IconEmoji :us: |
                            Send-SlackMessage -Uri $url

while($true)
{

    foreach($NSG in $NSGs)
    {
        start-sleep -s 5
        #초기의 activity log 체크후 data 가지고 있기 
        $alllogs = get-azurermlog -ResourceId $NSG.Id -MaxRecord 2 #subscriptionid, resourcegroup name, nsg name
        $alllasttime = $alllogs[0].EventTimestamp.AddHours(9)

        $ErrorActionPreference = "SilentlyContinue"
        $IsUpdate = $flase
        $starttime = (get-date).AddMinutes(-10)
        $endtime = (get-date -format s)
        $lastlogs =get-azurermlog -ResourceId $NSG.Id -StartTime $starttime -EndTime $endtime

        #10분동안 업데이트 된 것이 없음 
        if($lastlogs -eq $null){
            
            Write-host $NSG.Name" is OK"
        }

        else #업데이트 된 것이 있음 
        {
            $numofupdate = $lastlogs.Length
            if($numofupdate -eq '1'){
                $lasteventtime = $lastlogs[0].EventTimestamp.AddHours(9)
                $lastupdatecontent = $lastlogs[0].OperationName.LocalizedValue
                $alllasttime = $lasteventtime
                $ISupdate = $true
                $lastruleName = $lastlogs[0].ResourceId.Split("/")[10]
                $logformat = [pscustomobject]@{
                    NSGname = $NSG.Name
                    Operation = $lastupdatecontent
                    CurrentTime = get-date -Format u
                    LastUpdatetime = $lasteventtime.ToString("yyyy-MM-dd HH:mm:ss")
                    Operator = $reallog[0].Caller
                    Rule = $lastruleName
                }

                # Create an array from the properties in our fail object
                $Fields = @()
                foreach($Prop in $logformat.psobject.Properties.Name)
                {
                    $Fields += @{
                        title = $Prop
                        value = $logformat.$Prop
                        short = $true
                    }
                }
                
                #NSG Config Store
                $NSGName = $NSG.Name
                $timestamp=$lasteventtime.ToString("yyyy-MM-dd_HH_mm_ss")
                $fileName = "$NSGName$timestamp.txt"
                Get-AzureRmNetworkSecurityGroup -Name $NSG.Name -ResourceGroupName $NSG.ResourceGroupName | Get-AzureRmNetworkSecurityRuleConfig | Select Name, Protocol,SourceAddressPrefix, SourcePortRange,DestinationAddressPrefix, DestinationPortRange, Access | Out-File "C:\temp\NSG\$fileName"
                            
                # Construct and send the message!
                New-SlackMessageAttachment -Color $_PSSlackColorMap.orange `
                                            -Title 'NSG Change Tracking' `
                                            -Fields $Fields `
                                            -Fallback 'Nsg is change' |
                New-SlackMessage -Channel '#vm_valid_check' `
                                    -Username "NSG_Checker_US" `
                                    -IconEmoji :us: |
                Send-SlackMessage -Uri $url

            }
        
            else
            {
                $reallog = $lastlogs | ? {($_.Status.Value -imatch "Succeeded" -or $_.Status.Value -imatch "Accepted") -and ($_.HttpRequest -ne $null)}
                $lasteventtime = $reallog.EventTimestamp.AddHours(9)
                $Isupdate = $true
                $alllasttime = $lasteventtime
                for($i=0; $i -lt $reallog.Length; $i++)
                {
                        $lasteventtime = $reallog[$i].EventTimestamp.AddHours(9)
                        $lastupdatecontent = $reallog[$i].OperationName.LocalizedValue
                        $lastruleName = $reallog[$i].ResourceId.Split("/")[10]

                        $logformat = [pscustomobject]@{
                            NSGname = $NSG.Name
                            Operation = $lastupdatecontent
                            CurrentTime = get-date -Format u
                            LastUpdatetime = $lasteventtime.ToString("yyyy-MM-dd HH:mm:ss")
                            Operator = $reallog[$i].Caller
                            rule = $lastruleName
                        }

                        # Create an array
                        $Fields = @()
                        foreach ($Prop in $logformat.psobject.Properties.Name)
                        {
                            $Fields += @{
                                title = $Prop
                                value = $logformat.$Prop
                                short = $true
                            }
                        }
                        #NSG Config Store
                        $NSGName = $NSG.Name
                        $timestamp=$lasteventtime.ToString("yyyy-MM-dd_HH_mm_ss")
                        $fileName = "$NSGName$timestamp.txt"
                        Get-AzureRmNetworkSecurityGroup -Name $NSG.Name -ResourceGroupName $NSG.ResourceGroupName | Get-AzureRmNetworkSecurityRuleConfig |Select Name, Protocol,SourceAddressPrefix, SourcePortRange,DestinationAddressPrefix, DestinationPortRange, Access | Out-File "C:\temp\NSG\$fileName"
                            
                        # Construct and send the message!
                        New-SlackMessageAttachment -Color $_PSSlackColorMap.red `
                                                -Title 'NSG Change Tracking' `
                                                -Fields $Fields `
                                                -Fallback 'NSG updates' |
                        New-SlackMessage -Channel '#vm_valid_check' `
                                        -Username "NSG_Checker_US" `
                                        -IconEmoji :us: |
                        Send-SlackMessage -Uri $url
                }
            }
    
        }

        
    }

    Start-Sleep -s 180
}
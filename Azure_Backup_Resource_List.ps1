#### Backup Required Resource List ####

## VM  ##

$vault = @(Get-AzRecoveryServicesVault)
$backup_vms = for($i=0; $i -lt $vault.Count; $i++) {
    Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -BackupManagementType AzureVM -VaultId $vault[$i].ID
}


$backup_vms_name = $backup_vms.FriendlyName
$no_backup_vms = @(Get-AzVm | Where-Object {$_.Name -notin $backup_vms_name} | % {[PSCustomObject]@{
    Name = $_.Name
    ResourceGroup = $_.ResourceGroupName
    Type = "Virtual Machine"
}
})

if($no_backup_vms -ne $null) {
    $no_backup_vm = @()
    $result += foreach($num in 0..($no_backup_vms.Count-1)){
        $no_backup_vm = [ordered]@{
            Name = $no_backup_vms[$num].Name
            ResourceGroup = $no_backup_vms[$num].ResourceGroup
            Type = $no_backup_vms[$num].Type
        }
        New-Object -TypeName PSObject -Property $no_backup_vm
    }
}



## Azure Disk ##

#Install-Module -Name Az.DataProtection
$disks = (Get-AzDisk).Name
$rg = ""
$vault = Get-AzDataProtectionBackupVault
$backup_disks = Get-AzDataProtectionBackupInstance -ResourceGroupName $rg -VaultName $vault.Name

$backup_disks_name = (Get-AzDataProtectionBackupInstance -ResourceGroupName $rg -VaultName $vault.Name).Name
$no_backup_disks = @(Get-AzDisk | Where-Object {$_.Name -notin $backup_disks_name} | % {[PSCustomObject]@{
        Name = $_.Name
        ResourceGroup = $_.ResourceGroupName
        Type = "Disk"
        }
})

if($no_backup_disks -ne $null) {
    $no_backup_disk = @()
    $result += foreach($num in 0..($no_backup_disks.Count-1)){
        $no_backup_disk = [ordered]@{
            Name = $no_backup_disks[$num].Name
            ResourceGroup = $no_backup_disks[$num].ResourceGroup
            Type = $no_backup_disks[$num].Type
        }
        New-Object -TypeName PSObject -Property $no_backup_disk
    }
}



## Azure Files ##

$vault = @(Get-AzRecoveryServicesVault) 
$Container = @(for($i=0; $i -lt $vault.Count; $i++){
    Get-AzRecoveryServicesBackupContainer -ContainerType AzureStorage -Status Registered -VaultId $vault[$i].ID
})
$backup_files = for($i=0; $i -lt $Container.Count; $i++){
    for($j=0; $j -lt $vault.Count; $j++){
        Get-AzRecoveryServicesBackupItem -Container $Container[$i] -WorkloadType AzureFiles -VaultId $vault[$j].ID
    }
}

## Result ##
$result | Export-Excel -Path "D:\Backup_Resource_List.xlsx" -WorksheetName BackupRequiredResource -AutoSize




#### Backup Resource List ####

## VM ##
$vault = @(Get-AzRecoveryServicesVault)
$backup_vms = for($i=0; $i -lt $vault.Count; $i++) {
    Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -BackupManagementType AzureVM -VaultId $vault[$i].ID
}

$result += $backup_vms | % {[PSCustomObject]@{
    Name = $_.FriendlyName
    ResourceGroup = $_.ResourceGroupName
    Type = "Virtual Machine"
}}


## Azure Disk ##
$rg = ""
$vault = Get-AzDataProtectionBackupVault
$backup_disks = Get-AzDataProtectionBackupInstance -ResourceGroupName $rg -VaultName $vault.Name
$result += $backup_disks | % {[PSCustomObject]@{
    Name = $_.Name
    ResourceGroup = ""
    Type = "AzureDisk"
}}


## Azure Files ##
$vault = @(Get-AzRecoveryServicesVault) 
$Container = @(for($i=0; $i -lt $vault.Count; $i++){
    Get-AzRecoveryServicesBackupContainer -ContainerType AzureStorage -Status Registered -VaultId $vault[$i].ID
})
$backup_files = for($i=0; $i -lt $Container.Count; $i++){
    for($j=0; $j -lt $vault.Count; $j++){
        Get-AzRecoveryServicesBackupItem -Container $Container[$i] -WorkloadType AzureFiles -VaultId $vault[$j].ID
    }
}
$result += $backup_files | % {[PSCustomObject]@{
    Name = $_.Name
    ResourceGroup = $_.ResourceGroupName
    Type = "AzureFiles"
}} 


## Result ##
$result | Export-Excel -Path "D:\Backup_Resource_List.xlsx" -WorksheetName BackupResource -AutoSize







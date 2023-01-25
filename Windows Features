## Installed WindowsFeatures Checking ##

Get-windowsfeature | where-object {$_.installed -eq $true} | select-object name | export-csv -path ~/desktop/$env:computername-installed_modules.csv

$machines = import-csv -path ./data/machines.csv
$chk = $true
foreach ( $machine in $machines ) {
    write-output $machine.hostname 
    $export_features = import-csv -path ./data/WinFeature_export_$($machine.oldhostname).csv
    $installed_features = import-csv -path ./data/$($machine.hostname)-installed_modules.csv
    foreach ($export_feature in $export_features) {
        foreach ($installed_feature in $installed_features) {
            if ($export_feature.Installed -eq "TRUE") {
                if ($export_feature.name -eq $installed_feature.name) {
                    $chk = $false
                }
            }
            else {
                $chk = $false
            }
        }
        if ($chk) {
            write-output $export_feature.name
        }
        $chk = $true
    }
}

## Install WindowsFeatures ##

param(
    [Parameter(Mandatory)] 
    [string]$installed_features
)
$features=import-csv $installed_features
echo "install Start" > install_result
foreach ($feature in $features)
{
    if($feature.Installed -eq "TRUE"){
        echo $feature.name >> install_result
        echo $(install-windowsfeature -name $feature.name) >> install_result
    }
}

foreach ($feature in $features)
{
    echo $feature.name >> install_result
    echo $(install-windowsfeature -name $feature.name) >> install_result
    
}


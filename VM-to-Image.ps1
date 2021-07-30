$resourceGroup = "test-rg"
$location = "koreacentral"
$galleryName = "hwtestgallery"
$sourceVMName = "test-vm"
$imagedefName = "test-image-definition"

## Image Gallery 생성 ##
New-AzGallery `
  -GalleryName $galleryName `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Description 'Shared Image Gallery'

## Image Gallery 가져오기 ##
$gallery = Get-AzGallery `
-Name $galleryName `
-ResourceGroupName $resourceGroup

## VM 가져오기 ##
$sourceVM = Get-AzVM `
-Name $sourceVMName `
-ResourceGroupName $resourceGroup

## VM 중단 -> Image로 만들기 위해서는 잠시 중단 ##
Stop-AzVM `
-ResourceGroupName $resourceGroup `
-Name $sourceVMName `
-Force

## Image Definition 생성 ##
New-AzGalleryImageDefinition `
-GalleryName $galleryName `
-ResourceGroupName $resourceGroup `
-Location $location `
-Name $imagedefName `
-OsState specialized `
-OsType Linux `
-Publisher 'test-publisher' `
-Offer 'test-offer' `
-Sku 'test-sku'

## Image Version 생성 ##
$region1 = @{Name='Korea Central';ReplicaCount=1}
$region2 = @{Name='Korea Central';ReplicaCount=2}
$targetRegions = @($region1,$region2)

$job = $imageVersion = New-AzGalleryImageVersion `
-GalleryImageDefinitionName $imagedefName `
-GalleryImageVersionName '1.0.0' `
-GalleryName $galleryName `
-ResourceGroupName $resourceGroup `
-Location $location `
-TargetRegion $location `
-SourceImageId $sourceVM.Id.ToString() `
-PublishingProfileEndOfLifeDate '2021-12-01' `
-asJob

$job.State
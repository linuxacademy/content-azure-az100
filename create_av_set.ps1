$rgName = "70533Infrastructure"
$avSetName = "LAToysMidWareAS"
$location = "South Central US"
New-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $avSetName - Location $location -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 3 -Sku "Aligned"


$rgName="70533Infrastructure"
$avSetName="LAToysWeb2AS"
$location="South Central US"
az vm availability-set create --name $avSetName --resource-group $rgName --platform-fault-domain-count 3 --platform-update-domain-count 5

New-AzureRmVm -ResourceGroupName "70533Infrastructure" -Name "LAToysWeb4" -Location "South Central US" -AvailabilitySetName $avSetName -VirtualNetworkName "LAToysAzureNetwork" -SubnetName "LA-Toys-DMZ" -SecurityGroupName "LAToysWeb-nsg"
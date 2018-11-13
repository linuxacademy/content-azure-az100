$resourceGroup = "70533Infrastructure"
$newSize = "Standard_B2s"
$as = Get-AzureRmAvailabilitySet -ResourceGroupName $resourceGroup -Name "LAToysProcessAS"
$vmIds = $as.VirtualMachinesReferences
foreach ($vmId in $vmIDs){
    $string = $vmID.Id.Split("/")
    $vmName = $string[8]
    $vm = Get-AzureRmVM -ResourceGroupName $resourceGroup -Name $vmName
    $vm.HardwareProfile.VmSize = $newSize
    Update-AzureRmVM -ResourceGroupName $resourceGroup -VM $vm
    Start-AzureRmVM -ResourceGroupName $resourceGroup -Name $vmName
}


$resourceGroup="70533Infrastructure"
$vmName="LAToysWeb4"
az vm list-vm-resize-options --resource-group $resourceGroup --name $vmName --output table
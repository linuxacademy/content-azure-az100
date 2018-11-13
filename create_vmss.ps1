$resourceGroup = "70533Infrastructure"
$location = "South Central US"
$vmSize = "Standard_B2s"
$capacity = 2

$vmssConfig = New-AzureRmVmssConfig `
    -Location $location `
    -SkuCapacity $capacity `
    -SkuName $vmSize `
    -UpgradePolicyMode Automatic


$publicSettings = @{
    "fileUris" = (,"http://latoysoperations.blob.core.windows.net/armtemplates/course_mats/install_iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File install-iis.ps1"
}
Add-AzureRmVmssExtension -VirtualMachineScaleSet $vmssConfig `
    -Name "customScript" `
    -Publisher "Microsoft.Compute" `
    -Type "CustomScriptExtension" `
    -TypeHandlerVersion 1.8 `
    -Setting $publicSettings

$publicIPName = "LAToysWebVMSSIP"
$publicIP = New-AzureRmPublicIpAddress `
  -ResourceGroupName $resourceGroup  `
  -Location $location `
  -AllocationMethod Static `
  -Name $publicIPName


$frontEndPoolName = "LAToysWebFrontEndPool"
$backendPoolName = "LAToysWebBackEndPool"

$frontendIP = New-AzureRmLoadBalancerFrontendIpConfig `
  -Name $frontEndPoolName `
  -PublicIpAddress $publicIP
$backendPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backendPoolName

$lbName = "LAToysWebVMSSLB"
$lb = New-AzureRmLoadBalancer `
  -ResourceGroupName $resourceGroup  `
  -Name $lbName `
  -Location $location `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool

$probeName = "LAToysWebVMSSHTTPProbe"
Add-AzureRmLoadBalancerProbeConfig -Name $probeName `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2

Add-AzureRmLoadBalancerRuleConfig `
  -Name "LAToysWebLBHTTPRule" `
  -LoadBalancer $lb `
  -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
  -BackendAddressPool $lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80


Set-AzureRmLoadBalancer -LoadBalancer $lb

$userName = "LAToysAdmin"
$password = "LAT0yz1234!!s"
$vmPrefix = "LAToysWebVMSS"

Set-AzureRmVmssOsProfile $vmssConfig `
  -AdminUsername $userName `
  -AdminPassword $password `
  -ComputerNamePrefix $vmPrefix 

Set-AzureRmVmssStorageProfile $vmssConfig `
  -OsDiskCreateOption 'FromImage' `
  -ImageReferencePublisher MicrosoftWindowsServer `
  -ImageReferenceOffer WindowsServer `
  -ImageReferenceSku 2016-Datacenter `
  -ImageReferenceVersion latest `
  -VhdContainer $VHDContainer

$vNetName = "LAToysAzureNetwork"
$subnetName = "LA-Toys-DMZ"
$vNetwork = Get-AzureRmVirtualNetwork `
  -ResourceGroup 70533Infrastructure `
  -Name "LAtoysAzureNetwork"

# $subnet = Get-AzureRmVirtualNetworkSubnetConfig `
#   -Name $subnetName `
#   -VirtualNetwork $vNetwork

$ipConfig = New-AzureRmVmssIpConfig `
  -Name "LAToysWebVMSSIPConfig" `
  -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools[0].Id `
  -SubnetId $vNetwork.subnets[1].Id


$nicConfigName = "LAToysWebVMSSNicConfig" 
Add-AzureRmVmssNetworkInterfaceConfiguration `
  -VirtualMachineScaleSet $vmssConfig `
  -Name $nicConfigName `
  -Primary $true `
  -IPConfiguration $ipConfig

 # Add-AzureRmVmssDataDisk `
 #  -VirtualMachineScaleSet $vmssConfig `
 #  -CreateOption Attach `
 #  -Lun 2 `
 #  -DiskSizeGB 128

$scaleSetName = "LAToysWebVMSS"
New-AzureRmVmss `
  -ResourceGroupName $resourceGroup `
  -Name $scaleSetName `
  -VirtualMachineScaleSet $vmssConfig
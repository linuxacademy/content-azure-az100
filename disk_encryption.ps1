az keyvault lists

# Update Existing KeyVault to allow disk encryption
az keyvault update --name LAToysKeyVault
                   --enabled-for-disk-encryption true



# Region and location params
$keyVaultName = "LAToysKeyVault"
$rgName = "70533Infrastructure"
$location = "South Central US"


# Create context for disk encryption
$appName = "LAToysProcessing2"
$securePassword = ConvertTo-SecureString -String "Password" -AsPlainText -Force

$app = New-AzureRmADApplication -DisplayName $appName -Password $securePassword
New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

# Create Access Policy
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName 254bb3a5-4d06-408c-97b1-119e9841de6c -PermissionsToKeys "WrapKey" -PermissionsToSecrets "Set"

Add-AzureKeyVaultKey -VaultName $keyVaultName -Name "LAToysWindows2EncryptionKey" -Destination "Software"



$keyVault = Get-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri
$keyVaultResourceId = $keyVault.ResourceId
$keyEncryptionKeyUrl = (Get-AzureKeyVaultKey -VaultName $keyVaultName -Name LAToysWindowsEncryptKey2).Key.kid

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $rgName `
    -VMName "LAToysWindows2" `
    -AadClientID $app.ApplicationId `
    -AadClientSecret (New-Object PSCredential "user",$securePassword).GetNetworkCredential().Password `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $keyVaultResourceId `
    -KeyEncryptionKeyUrl $keyEncryptionKeyUrl `
    -KeyEncryptionKeyVaultId $keyVaultResourceId




Remove-AzureRmVMDiskEncryptionExtension -ResourceGroupName $rgName `
    -VMName "LAToysWindows2"

# Create New Resource Group
Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
New-AzureRmResourceGroup -Location $location -Name $rgName

# Create New Key Vault
$keyVaultName = "myUniqueKeyVaultName"
New-AzureRmKeyVault -Location $location `
    -ResourceGroupName $rgName `
    -VaultName $keyVaultName `
    -EnabledForDiskEncryption

Remove-AzureRmADServicePrincipal --
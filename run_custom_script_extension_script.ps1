Set-AzureRmVMCustomScriptExtension -ResourceGroupName 70533Infrastructure `
    -VMName LAToysWinTest`
    -StorageAccountName 'latoysoperations' `
    -StorageAccountKey 'dsW8ADgyu+aWiD6oy6yTznQR7h8nhuxYPplAJpawVL6tLQFoLjUa8bsyOS35I/CeyAfw8J1VaPg/CQamBxw0hg==' `
    -FileName 'custom_extension_sample.ps1' `
    -ContainerName 'armtemplates' `
    -Location 'South Central US' `
    -Run 'custom_extension_sample.ps1' `
    -Name "WinConfFileSetup"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName 70533InfrastructureEast `
    -VMName LAToysWindows2 `
    -StorageAccountName 'latoysoperations' `
    -StorageAccountKey 'dsW8ADgyu+aWiD6oy6yTznQR7h8nhuxYPplAJpawVL6tLQFoLjUa8bsyOS35I/CeyAfw8J1VaPg/CQamBxw0hg==' `
    -FileName 'custom_extension_sample.ps1' `
    -ContainerName 'armtemplates' `
    -Location 'East US' `
    -Run 'custom_extension_sample.ps1' `
    -Name "WinConfFileSetup"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName 70533Infrastructure `
    -VMName LAToysWinTest `
    -Location 'South Central US' `
    -FileUri 'https://latoysoperations.blob.core.windows.net/armtemplates/custom_extension_sample.ps1' `
    -Run 'custom_extension_sample.ps1' `
    -Name "WinConfFileSetup"
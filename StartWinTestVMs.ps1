Param
(
    [Parameter (Mandatory = $false)]
    [object] $WebhookData
)

if($WebhookData){
    write-output $WebhookData

    if(-Not $WebhookData.RequestBody) {
        $WebhookData = (ConvertFrom-Json -InputObject $WebhookData)
        write-output "test $WebhookData" 
    }
    
    $vms = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

    Write-Output "Authentication to Azure with service principal and certificate"
    $ConnectionAssetName = "AzureRunAsConnection"
    Write-Output "Get connection asset: $ConnectionAssetName"
    
    $Conn = Get-AutomationConnection -Name $ConnectionAssetName
        if ($Conn -eq $null)
        {
            throw "Could not retrieve connection asset: $ConnectionAssetName. Check that this asset exists in the Automation Account."
        }
        Write-Output "Authentication to Azure with Service Principal"
        $TenantId = $Conn.TenantId
        $ApplicationId = $Conn.ApplicationId
        Add-AzureRmAccount -ServicePrincipal -Tenant $TenantId -ApplicationId $ApplicationId -CertificateThumbprint $Conn.CertificateThumbprint | Write-Output

        # Start each VM
        foreach ($vm in $vms)
        {   
            $vmName = $vm.Name
            Write-Output "Starting $vmName"
            Start-AzureRMVM -Name $vm.Name -ResourceGroup $vm.ResourceGroup
        }
}
else {
    # error
    Write-Error "This runbook is meant to be started from an Azure webhook"
}
 # ---------------------------------------------------
# Script: C:\scripts\topAzureVM.ps1
# Version: 0.1
# Author: Stefan Stranger
# Date: 11/18/2016 16:06:47
# Description: Stop Azure VM PowerShell Script Runbook triggered by WebHook
# Comments:
# Changes:  
# Disclaimer: 
# This example is provided "AS IS" with no warranty expressed or implied. Run at your own risk. 
# **Always test in your lab first**  Do this at your own risk!! 
# The author will not be held responsible for any damage you incur when making these changes!
# ---------------------------------------------------

<# 
    The values ResourceGroup name and VM Name are sent in the body response from the webrequest.
    The body should look like this:
    @{ ResourcegroupName="ResourceGroupName";VMName="SimpleWindowsVM"}
#>
[CmdletBinding()]
param (
        [object]$WebhookData
    )

#Verify if Runbook is started from Webhook.

# If runbook was called from Webhook, WebhookData will not be null.
if ($WebhookData){

    # Collect properties of WebhookData
    $WebhookName     =     $WebhookData.WebhookName
    $WebhookHeaders =     $WebhookData.RequestHeader
    $WebhookBody     =     $WebhookData.RequestBody

    # Collect individual headers. VMList converted from JSON.
    $From = $WebhookHeaders.From
    $VMInfo = ConvertFrom-Json -InputObject $WebhookBody
    Write-Output -InputObject ('Runbook started from webhook {0} by {1}.' -f $WebhookName, $From)
    }
else
    {
        Write-Error -Message 'Runbook was not started from Webhook' -ErrorAction stop
    }



#region Variables
$connectionName = 'AzureRunAsConnection'
#endregion

#region Connect to Azure
try
{
       
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    'Logging in to Azure...'
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = ('Connection {0} not found.' -f $connectionName)
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
#endregion


#region shutdown vm
#Retrieve VM with Status information
$VM = Get-AzureRmVM -ResourceGroupName $($VMInfo.ResourceGroupName) -Name $($VMInfo.VMName) -Status 
if ($vm.statuses | where-object {$_.code -eq 'PowerState/deallocated' }) {
    Write-output -InputObject ('VM {0} is already in PowerState Deallocated' -f $VM.name)
}
else
{
    Write-output -InputObject ('Shutting down VM {0}' -f $VM.name)
    $VM | Stop-AzureRMVM -Force
}
#endregion
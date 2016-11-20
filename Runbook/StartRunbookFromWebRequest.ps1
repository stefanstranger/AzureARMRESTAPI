# ---------------------------------------------------
# Script: C:\Users\stefstr\Documents\GitHub\AzureARMRESTAPI\Runbook\StartRunbookFromWebRequest.ps1
# Version: 0.1
# Author: Stefan Stranger
# Date: 11/20/2016 09:32:22
# Description: Example script on how to call the Runbook webhook from PowerShell
# Comments:
# Changes:  
# Disclaimer: 
# This example is provided “AS IS” with no warranty expressed or implied. Run at your own risk. 
# **Always test in your lab first**  Do this at your own risk!! 
# The author will not be held responsible for any damage you incur when making these changes!
# ---------------------------------------------------

$webhookuri = 'Enter Webhook URL'

$headers = @{"From"="user@contoso.com";"Date"=$(get-date)}

$vm  = @{ ResourcegroupName="mydemorg";VMName="SimpleWindowsVM"}

$body = ConvertTo-Json -InputObject $vm

$response = Invoke-RestMethod -Method Post -Uri $webhookuri -Headers $headers -Body $body

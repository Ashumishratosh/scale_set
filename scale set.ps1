New-AzResourceGroup -ResourceGroupName "RGSS" -Location "EastUS"


New-AzVmss -ResourceGroupName "RGSS" -Location "EastUS" -VMScaleSetName "myScaleSet" -VirtualNetworkName "myVnet" -SubnetName "mySubnet" -PublicIpAddressName "myPublicIPAddress" -LoadBalancerName "myLoadBalancer" -UpgradePolicyMode "Automatic"



# Define the script for your Custom Script Extension to run
$publicSettings = @{
    "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
}


$vmss = Get-AzVmss -ResourceGroupName "RGSS" -VMScaleSetName "myScaleSet"



Add-AzVmssExtension -VirtualMachineScaleSet $vmss -Name "customScript" -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion 1.8 -Setting $publicSettings


Update-AzVmss -ResourceGroupName "RGSS" -Name "myScaleSet" -VirtualMachineScaleSet $vmss




# Get information about the scale set
$vmss = Get-AzVmss -ResourceGroupName "RGSS" -VMScaleSetName "myScaleSet"


$nsgFrontendRule = New-AzNetworkSecurityRuleConfig -Name myFrontendNSGRule -Protocol Tcp -Direction Inbound -Priority 200 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow


$nsgFrontend = New-AzNetworkSecurityGroup -ResourceGroupName  "RGSS" -Location EastUS -Name myFrontendNSG -SecurityRules $nsgFrontendRule


$vnet = Get-AzVirtualNetwork -ResourceGroupName  "RGSS" -Name myVnet


$frontendSubnet = $vnet.Subnets[0]

$frontendSubnetConfig = Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name mySubnet -AddressPrefix $frontendSubnet.AddressPrefix -NetworkSecurityGroup $nsgFrontend


Set-AzVirtualNetwork -VirtualNetwork $vnet

Update-AzVmss -ResourceGroupName "RGSS" -Name "myScaleSet" -VirtualMachineScaleSet $vmss


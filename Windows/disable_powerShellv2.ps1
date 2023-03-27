if ((Get-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2Root" -Online | Select-Object -ExpandProperty State) -eq "Enabled"){
    Disable-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2Root" -Online
}
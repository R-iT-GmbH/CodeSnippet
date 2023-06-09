if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown") -eq $true) {
    New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown' -Name 'bDisableJavaScript' -Value '1' -PropertyType DWord -Force -ea SilentlyContinue;
};
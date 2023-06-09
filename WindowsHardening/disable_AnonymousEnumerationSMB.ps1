if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa") -eq $true) {
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'RestrictAnonymous' -Value '1' -PropertyType DWord -Force -ea SilentlyContinue;
};
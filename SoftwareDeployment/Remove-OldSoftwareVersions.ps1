<# 
.SYNOPSIS
    Removes old versions of a specified software product.

.DESCRIPTION 
    Checks if there are multiple installations of a specified software and removes all older versions.

.NOTES 
    Version:        1.0
    Author:         Tobias Nawrocki | R.iT GmbH
    Creation Date:  2022/07/28
    Purpose/Change: Initial script development

.Parameter Product 
    Specifies the name of the product that will be used.

.EXAMPLE
    Remove-OldSoftwareVersions -product "MailStore*"
#>

# Set the software product name
$product = "MailStore Outlook*"

function Remove-OldSoftwareVersions {
    param (
        [Parameter()]
        [string] $product
    )
    
    $filteredSoftwareList = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like $product)
    Write-Host ($filteredSoftwareList | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate)

    # Check if two or more versions are installed
    $countVersions = ($filteredSoftwareList | Measure-Object).Count
    Write-Host "Versions found:" $countVersions


    # Uninstall older version
    if ($countVersions -gt 1) {
        Write-Host "More than one version found, trying to remove the oldest one"
        $oldestVersion = $filteredSoftwareList | Sort-Object -Property Version | Select-Object -First 1
        Write-Host Removing $oldestVersion.DisplayName $oldestVersion.Version

        if ([bool]$oldestVersion.PSObject.Properties['UninstallString']) {
            Write-Host Uninstall string found: $oldestVersion.UninstallString
            $uninstallString = $oldestVersion.UninstallString
            $isExeOnly = Test-Path -LiteralPath $uninstallString

            if ($isExeOnly) { 
                $uninstallString = "`"$uninstallString`"" } 
            $uninstallString += ' /quiet /norestart'
            try {
                Write-Host "Starting removal with uninstall string" $uninstallString
                & "C:\Windows\SYSTEM32\cmd.exe" /c $uninstallString
            }
            catch {
                Write-Host "Uninstall string not provided, removal failed"
            }
        }
        else {
            Write-Host "Uninstall string not provided."
            exit 0
        }        
    }
    else {
        Write-Host "No old software versions found."
    }

}

# Call Function
Remove-OldSoftwareVersions -product $product
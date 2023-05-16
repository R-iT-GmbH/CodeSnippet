<# 
.SYNOPSIS
    Copies the content of a user home drive to OneDrive for Business

.DESCRIPTION 
    Checks for the 

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


function Move-UserHomeToOneDrive {
    param (
        [Parameter()]
        [string] $sourceDrive
    )
    
    $homeDrive = $sourceDrive + ":\"
    $homeDriveExists = Test-Path -Path $homeDrive

    if ($homeDriveExists) {
        $homeDrivePath = (Get-PSDrive -Name $sourceDrive).DisplayRoot
        Write-Host "Home drive found:"
        Write-Host $homeDrivePath
    }
    else {
        Write-Host "No home drive detected"
    }

}

# Call Function
Move-UserHomeToOneDrive -sourceDrive "I"


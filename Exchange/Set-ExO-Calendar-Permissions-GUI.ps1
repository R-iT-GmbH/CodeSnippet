﻿<#
.Synopsis
   GUI for changing Mailbox Calendar Permissions in Exchange Online
.DESCRIPTION
    This script provides a GUI for changing Mailbox Calendar Permissions in Exchange Online.
    It uses the Exchange Online Management PowerShell module.
.NOTES
   Author: R.iT GmbH - Tobias Nawrocki
   Version: 1.0
#>

# Connect to Exchange Online PowerShell
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Function for getting current Permissions
function Get-CalendarPermissions {
    param (
        [string]$Mailbox,
        [string]$CalendarFolderName
    )
    $Identity = $Mailbox + ":\" + $CalendarFolderName
    Get-MailboxFolderPermission -Identity $Identity
}

# Function for setting Permissions
function Set-CalendarPermissions {
    param (
        [string]$Mailbox,
        [string]$User,
        [string]$AccessRights,
        [string]$CalendarFolderName
    )

    $Identity = $Mailbox + ":\" + $CalendarFolderName

    # Prüfung, ob Berechtigung bereits vorhanden ist
    $Permission = Get-MailboxFolderPermission -Identity $Identity -User $User -ErrorAction SilentlyContinue
    if ($Permission -ne $null) {
        Set-MailboxFolderPermission -Identity $Identity -User $User -AccessRights $AccessRights
    }
    else {
        Add-MailboxFolderPermission -Identity $Identity -User $User -AccessRights $AccessRights
    }
    Write-Host "Berechtigungen erfolgreich gesetzt."
}

# Function for removing Permissions
function Remove-CalendarPermissions {
    param (
        [string]$Mailbox,
        [string]$User,
        [string]$AccessRights,
        [string]$CalendarFolderName
    )

    $Identity = $Mailbox + ":\" + $CalendarFolderName

    # Prüfung, ob Berechtigung bereits vorhanden ist
    $Permission = Get-MailboxFolderPermission -Identity $Identity -User $User -ErrorAction SilentlyContinue
    if ($Permission -ne $null) {
        try {
            Remove-MailboxFolderPermission -Identity $Identity -User $User -Confirm:$false
        }
        catch {
            Write-Host "Fehler beim Entfernen der Berechtigung. $($_.Exception.Message)"
        }
        Write-Host "Berechtigungen erfolgreich entfernt."
    }
    else {
        Write-Host "Berechtigung nicht vorhanden."
    }
}


# create GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Exchange Online Calendar Permissions"
$Form.Size = New-Object System.Drawing.Size(400, 250)

$LabelMailbox = New-Object System.Windows.Forms.Label
$LabelMailbox.Text = "Postfach:"
$LabelMailbox.Location = New-Object System.Drawing.Point(10, 20)
$Form.Controls.Add($LabelMailbox)

$TextBoxMailbox = New-Object System.Windows.Forms.TextBox
$TextBoxMailbox.Location = New-Object System.Drawing.Point(150, 20)
$TextBoxMailbox.Width = 200
$Form.Controls.Add($TextBoxMailbox)

$ButtonGetPermissions = New-Object System.Windows.Forms.Button
$ButtonGetPermissions.Text = "Abrufen von Berechtigungen"
$ButtonGetPermissions.Location = New-Object System.Drawing.Point(10, 60)
$ButtonGetPermissions.Width = 170
$ButtonGetPermissions.add_Click({
    $Mailbox = $TextBoxMailbox.Text
    $CalendarFolderName = Get-CalendarFolderName
    Get-CalendarPermissions -Mailbox $Mailbox -CalendarFolderName $CalendarFolderName | Out-GridView
})
$Form.Controls.Add($ButtonGetPermissions)

$LabelGetMailbox = New-Object System.Windows.Forms.Label
$LabelGetMailbox.Text = "(leer lassen für eigenen Kalender)"
$LabelGetMailbox.Location = New-Object System.Drawing.Point(185, 60)
$LabelGetMailbox.Width = 300
$Form.Controls.Add($LabelGetMailbox)

$LabelUser = New-Object System.Windows.Forms.Label
$LabelUser.Text = "Benutzer:"
$LabelUser.Location = New-Object System.Drawing.Point(10, 100)
$Form.Controls.Add($LabelUser)

$TextBoxUser = New-Object System.Windows.Forms.TextBox
$TextBoxUser.Location = New-Object System.Drawing.Point(150, 100)
$TextBoxUser.Width = 200
$Form.Controls.Add($TextBoxUser)

$LabelAccessRights = New-Object System.Windows.Forms.Label
$LabelAccessRights.Text = "Berechtigungen:"
$LabelAccessRights.Location = New-Object System.Drawing.Point(10, 140)
$Form.Controls.Add($LabelAccessRights)

$ComboBoxAccessRights = New-Object System.Windows.Forms.ComboBox
$ComboBoxAccessRights.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$ComboBoxAccessRights.Location = New-Object System.Drawing.Point(150, 140)
$ComboBoxAccessRights.Width = 150
$ComboBoxAccessRights.Items.AddRange(@("Editor", "Reviewer", "Author", "PublishingEditor", "Owner"))
$Form.Controls.Add($ComboBoxAccessRights)

$ButtonSetPermissions = New-Object System.Windows.Forms.Button
$ButtonSetPermissions.Text = "Berechtigungen setzen"
$ButtonSetPermissions.Location = New-Object System.Drawing.Point(10, 180)
$ButtonSetPermissions.Width = 170
$ButtonSetPermissions.add_Click({
    $Mailbox = $TextBoxMailbox.Text
    $User = $TextBoxUser.Text
    $AccessRights = $ComboBoxAccessRights.SelectedItem.ToString()
    $CalendarFolderName = Get-CalendarFolderName
    Set-CalendarPermissions -Mailbox $Mailbox -User $User -AccessRights $AccessRights -CalendarFolderName $CalendarFolderName
})
$Form.Controls.Add($ButtonSetPermissions)

$ButtonRemovePermissions = New-Object System.Windows.Forms.Button
$ButtonRemovePermissions.Text = "Berechtigungen entfernen"
$ButtonRemovePermissions.Location = New-Object System.Drawing.Point(200, 180)
$ButtonRemovePermissions.Width = 170
$ButtonRemovePermissions.add_Click({
    $Mailbox = $TextBoxMailbox.Text
    $User = $TextBoxUser.Text
    $CalendarFolderName = Get-CalendarFolderName
    Remove-CalendarPermissions -Mailbox $Mailbox -User $User -CalendarFolderName $CalendarFolderName
})
$Form.Controls.Add($ButtonRemovePermissions)

# Function for getting Calendar Folder Name - German or English only
function Get-CalendarFolderName {
    if ([System.Threading.Thread]::CurrentThread.CurrentUICulture.Name -eq "de-DE") {
        return "Kalender"
    }
    else {
        return "Calendar"
    }
}

$Form.ShowDialog()
# SIG # Begin signature block
# MIImqAYJKoZIhvcNAQcCoIImmTCCJpUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbDDfmo2CUhEzgluFpTCvhSeh
# DmKggh+6MIIFbzCCBFegAwIBAgIQSPyTtGBVlI02p8mKidaUFjANBgkqhkiG9w0B
# AQwFADB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEh
# MB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTIxMDUyNTAwMDAw
# MFoXDTI4MTIzMTIzNTk1OVowVjELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5n
# IFJvb3QgUjQ2MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAjeeUEiIE
# JHQu/xYjApKKtq42haxH1CORKz7cfeIxoFFvrISR41KKteKW3tCHYySJiv/vEpM7
# fbu2ir29BX8nm2tl06UMabG8STma8W1uquSggyfamg0rUOlLW7O4ZDakfko9qXGr
# YbNzszwLDO/bM1flvjQ345cbXf0fEj2CA3bm+z9m0pQxafptszSswXp43JJQ8mTH
# qi0Eq8Nq6uAvp6fcbtfo/9ohq0C/ue4NnsbZnpnvxt4fqQx2sycgoda6/YDnAdLv
# 64IplXCN/7sVz/7RDzaiLk8ykHRGa0c1E3cFM09jLrgt4b9lpwRrGNhx+swI8m2J
# mRCxrds+LOSqGLDGBwF1Z95t6WNjHjZ/aYm+qkU+blpfj6Fby50whjDoA7NAxg0P
# OM1nqFOI+rgwZfpvx+cdsYN0aT6sxGg7seZnM5q2COCABUhA7vaCZEao9XOwBpXy
# bGWfv1VbHJxXGsd4RnxwqpQbghesh+m2yQ6BHEDWFhcp/FycGCvqRfXvvdVnTyhe
# Be6QTHrnxvTQ/PrNPjJGEyA2igTqt6oHRpwNkzoJZplYXCmjuQymMDg80EY2NXyc
# uu7D1fkKdvp+BRtAypI16dV60bV/AK6pkKrFfwGcELEW/MxuGNxvYv6mUKe4e7id
# FT/+IAx1yCJaE5UZkADpGtXChvHjjuxf9OUCAwEAAaOCARIwggEOMB8GA1UdIwQY
# MBaAFKARCiM+lvEH7OKvKe+CpX/QMKS0MB0GA1UdDgQWBBQy65Ka/zWWSC8oQEJw
# IDaRXBeF5jAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUE
# DDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEMGA1Ud
# HwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0FBQUNlcnRpZmlj
# YXRlU2VydmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUAA4IBAQASv6Hvi3Sa
# mES4aUa1qyQKDKSKZ7g6gb9Fin1SB6iNH04hhTmja14tIIa/ELiueTtTzbT72ES+
# BtlcY2fUQBaHRIZyKtYyFfUSg8L54V0RQGf2QidyxSPiAjgaTCDi2wH3zUZPJqJ8
# ZsBRNraJAlTH/Fj7bADu/pimLpWhDFMpH2/YGaZPnvesCepdgsaLr4CnvYFIUoQx
# 2jLsFeSmTD1sOXPUC4U5IOCFGmjhp0g4qdE2JXfBjRkWxYhMZn0vY86Y6GnfrDyo
# XZ3JHFuu2PMvdM+4fvbXg50RlmKarkUT2n/cR/vfw1Kf5gZV6Z2M8jpiUbzsJA8p
# 1FiAhORFe1rYMIIGGjCCBAKgAwIBAgIQYh1tDFIBnjuQeRUgiSEcCjANBgkqhkiG
# 9w0BAQwFADBWMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVk
# MS0wKwYDVQQDEyRTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYw
# HhcNMjEwMzIyMDAwMDAwWhcNMzYwMzIxMjM1OTU5WjBUMQswCQYDVQQGEwJHQjEY
# MBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0aWdvIFB1Ymxp
# YyBDb2RlIFNpZ25pbmcgQ0EgUjM2MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIB
# igKCAYEAmyudU/o1P45gBkNqwM/1f/bIU1MYyM7TbH78WAeVF3llMwsRHgBGRmxD
# eEDIArCS2VCoVk4Y/8j6stIkmYV5Gej4NgNjVQ4BYoDjGMwdjioXan1hlaGFt4Wk
# 9vT0k2oWJMJjL9G//N523hAm4jF4UjrW2pvv9+hdPX8tbbAfI3v0VdJiJPFy/7Xw
# iunD7mBxNtecM6ytIdUlh08T2z7mJEXZD9OWcJkZk5wDuf2q52PN43jc4T9OkoXZ
# 0arWZVeffvMr/iiIROSCzKoDmWABDRzV/UiQ5vqsaeFaqQdzFf4ed8peNWh1OaZX
# nYvZQgWx/SXiJDRSAolRzZEZquE6cbcH747FHncs/Kzcn0Ccv2jrOW+LPmnOyB+t
# AfiWu01TPhCr9VrkxsHC5qFNxaThTG5j4/Kc+ODD2dX/fmBECELcvzUHf9shoFvr
# n35XGf2RPaNTO2uSZ6n9otv7jElspkfK9qEATHZcodp+R4q2OIypxR//YEb3fkDn
# 3UayWW9bAgMBAAGjggFkMIIBYDAfBgNVHSMEGDAWgBQy65Ka/zWWSC8oQEJwIDaR
# XBeF5jAdBgNVHQ4EFgQUDyrLIIcouOxvSK4rVKYpqhekzQwwDgYDVR0PAQH/BAQD
# AgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYD
# VR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEEATBLBgNVHR8ERDBCMECgPqA8hjpodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ1Jvb3RS
# NDYuY3JsMHsGCCsGAQUFBwEBBG8wbTBGBggrBgEFBQcwAoY6aHR0cDovL2NydC5z
# ZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdSb290UjQ2LnA3YzAj
# BggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEM
# BQADggIBAAb/guF3YzZue6EVIJsT/wT+mHVEYcNWlXHRkT+FoetAQLHI1uBy/YXK
# ZDk8+Y1LoNqHrp22AKMGxQtgCivnDHFyAQ9GXTmlk7MjcgQbDCx6mn7yIawsppWk
# vfPkKaAQsiqaT9DnMWBHVNIabGqgQSGTrQWo43MOfsPynhbz2Hyxf5XWKZpRvr3d
# MapandPfYgoZ8iDL2OR3sYztgJrbG6VZ9DoTXFm1g0Rf97Aaen1l4c+w3DC+IkwF
# kvjFV3jS49ZSc4lShKK6BrPTJYs4NG1DGzmpToTnwoqZ8fAmi2XlZnuchC4NPSZa
# PATHvNIzt+z1PHo35D/f7j2pO1S8BCysQDHCbM5Mnomnq5aYcKCsdbh0czchOm8b
# kinLrYrKpii+Tk7pwL7TjRKLXkomm5D1Umds++pip8wH2cQpf93at3VDcOK4N7Ew
# oIJB0kak6pSzEu4I64U6gZs7tS/dGNSljf2OSSnRr7KWzq03zl8l75jy+hOds9TW
# SenLbjBQUGR96cFr6lEUfAIEHVC1L68Y1GGxx4/eRI82ut83axHMViw1+sVpbPxg
# 51Tbnio1lB93079WPFnYaOvfGAA0e0zcfF/M9gXr+korwQTh2Prqooq2bYNMvUoU
# KD85gnJ+t0smrWrb8dee2CvYZXD5laGtaAxOfy/VKNmwuWuAh9kcMIIGPDCCBKSg
# AwIBAgIQARob6WqXk8OyUG4p7T41tDANBgkqhkiG9w0BAQwFADBUMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2MB4XDTIzMDUwMjAwMDAwMFoXDTI2
# MDYwMzIzNTk1OVowUzELMAkGA1UEBhMCREUxHDAaBgNVBAgME05vcmRyaGVpbi1X
# ZXN0ZmFsZW4xEjAQBgNVBAoMCVIuaVQgR21iSDESMBAGA1UEAwwJUi5pVCBHbWJI
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvmpeRmYGVUctQGkKS02R
# Yg/nDF1D5drJUdg5D+SOHcSgRSTL9MQxKxKDQ4mdMt6BdO+B6ynKKHLDlrPE62Jo
# JvUmzcEnkqF5aEFQ9BvbxTz3SNm1MABjRuNhv+eFJBB9KJChA1lfgxPyz2quZIV7
# TBuv+Hbu7ZQre+m1iJW9ccrxj81TQVt9iikdygmsyXEa/7Sh9SL/yAHc1ndl4pNe
# TXiDeI/8h+K78imL5+jlHXTY3HXKz0Jk4pS5AH3Fgdbht7l94BbRolnHoViX6RU5
# 2Ovqb1Qe4mEQJp9NfPDn5objcEmOfCySy7tk3OV/kLMInDGVScZunrww2FwJ3SLp
# jchjjUgfNexX0ji8w+uFTndZY0SeNc+vk7UcigiYUHQ5skftlfwpDKWj75o30NUe
# sf+b4WHa6r9Oxd2Q5EYY+UmDRPVf/4HYtyR4VqgfZcJH5QxOu1zfdMYeI4o27PnU
# ADgBmoWosicvtcLaGzGbH7oyZekLJvDogPAYFbd7w6SljqUp4Eo/WZ46bnJtf7Vn
# 1g9YXMzWZFg+t9aLbgbdG1YKDrlPLyMqMquaDM4IB3usb3IcjjoBmvJnodCtAlwt
# /Vainp1VUZd0sLaFzRzbihKcw0nMqh0sSjZl9FVpla7frfOdH34n366GyA/ZBhVC
# tAoez3INRYKGi9P9n2QL/pECAwEAAaOCAYkwggGFMB8GA1UdIwQYMBaAFA8qyyCH
# KLjsb0iuK1SmKaoXpM0MMB0GA1UdDgQWBBQJ8dZc30QKtD3Q89l71pOiRJ0C5TAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcD
# AzBKBgNVHSAEQzBBMDUGDCsGAQQBsjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRw
# czovL3NlY3RpZ28uY29tL0NQUzAIBgZngQwBBAEwSQYDVR0fBEIwQDA+oDygOoY4
# aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdD
# QVIzNi5jcmwweQYIKwYBBQUHAQEEbTBrMEQGCCsGAQUFBzAChjhodHRwOi8vY3J0
# LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNydDAj
# BggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEM
# BQADggGBAAnRGKjtc7WIjVtiF3jCJIYJ1snc2ZwyDs3ZGKpKnmEoCPRCgvVFmUP1
# zD8/0oxASWE9vBRVdv07pb5xfx31YOD0hCcv5sZaXAsFeHCoOi59XYhk7DrBw1xw
# QtfWOLG/HDmQzbNYrXiYFRifZq8pa2YIK7/o42t9M3iB0ZH8kwuWPzEYhMRRD63O
# 8ZghKJs8xLoBRR/pjW6A+ZUWZcpY2oQISWOJwyvKep79x6ibYSaZPTBbi50JNsGW
# YiyzqD3G3zIpqVfLLSxkiRpT+XjSiWCeOPjCJ6k8igpzbbUj19Jbz3BfstSQs/o8
# ErbCOBlw+uvaOHbKKP7M3xy32WFnnbRu85w655u0GD1EgkG8wnME06EVQvrVNn4v
# IpoyNuo2UsXlpctOp86jWxihqPxuIdZl14taX84tLo9oh428O/tqX+D3rRHUT9R7
# yPN04kQjrpBrNDTCLubKY8QHXV7IbYmYLIFKsNz5kSMPJfluSBWtLG4GpB7qfxGn
# JbBxBanIUDCCBuwwggTUoAMCAQICEDAPb6zdZph0fKlGNqd4LbkwDQYJKoZIhvcN
# AQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYD
# VQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3Jr
# MS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5
# MB4XDTE5MDUwMjAwMDAwMFoXDTM4MDExODIzNTk1OVowfTELMAkGA1UEBhMCR0Ix
# GzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEY
# MBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBU
# aW1lIFN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# yBsBr9ksfoiZfQGYPyCQvZyAIVSTuc+gPlPvs1rAdtYaBKXOR4O168TMSTTL80Vl
# ufmnZBYmCfvVMlJ5LsljwhObtoY/AQWSZm8hq9VxEHmH9EYqzcRaydvXXUlNclYP
# 3MnjU5g6Kh78zlhJ07/zObu5pCNCrNAVw3+eolzXOPEWsnDTo8Tfs8VyrC4Kd/wN
# lFK3/B+VcyQ9ASi8Dw1Ps5EBjm6dJ3VV0Rc7NCF7lwGUr3+Az9ERCleEyX9W4L1G
# nIK+lJ2/tCCwYH64TfUNP9vQ6oWMilZx0S2UTMiMPNMUopy9Jv/TUyDHYGmbWApU
# 9AXn/TGs+ciFF8e4KRmkKS9G493bkV+fPzY+DjBnK0a3Na+WvtpMYMyou58NFNQY
# xDCYdIIhz2JWtSFzEh79qsoIWId3pBXrGVX/0DlULSbuRRo6b83XhPDX8CjFT2SD
# AtT74t7xvAIo9G3aJ4oG0paH3uhrDvBbfel2aZMgHEqXLHcZK5OVmJyXnuuOwXhW
# xkQl3wYSmgYtnwNe/YOiU2fKsfqNoWTJiJJZy6hGwMnypv99V9sSdvqKQSTUG/xy
# pRSi1K1DHKRJi0E5FAMeKfobpSKupcNNgtCN2mu32/cYQFdz8HGj+0p9RTbB942C
# +rnJDVOAffq2OVgy728YUInXT50zvRq1naHelUF6p4MCAwEAAaOCAVowggFWMB8G
# A1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQaofhhGSAP
# w0F3RSiO0TVfBhIEVTAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADATBgNVHSUEDDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0f
# BEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJT
# QUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/Bggr
# BgEFBQcwAoYzaHR0cDovL2NydC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUFk
# ZFRydXN0Q0EuY3J0MCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQBtVIGlM10W4bVTgZF13wN6MgstJYQRsrDb
# Kn0qBfW8Oyf0WqC5SVmQKWxhy7VQ2+J9+Z8A70DDrdPi5Fb5WEHP8ULlEH3/sHQf
# j8ZcCfkzXuqgHCZYXPO0EQ/V1cPivNVYeL9IduFEZ22PsEMQD43k+ThivxMBxYWj
# TMXMslMwlaTW9JZWCLjNXH8Blr5yUmo7Qjd8Fng5k5OUm7Hcsm1BbWfNyW+QPX9F
# csEbI9bCVYRm5LPFZgb289ZLXq2jK0KKIZL+qG9aJXBigXNjXqC72NzXStM9r4MG
# OBIdJIct5PwC1j53BLwENrXnd8ucLo0jGLmjwkcd8F3WoXNXBWiap8k3ZR2+6rzY
# QoNDBaWLpgn/0aGUpk6qPQn1BWy30mRa2Coiwkud8TleTN5IPZs0lpoJX47997FS
# kc4/ifYcobWpdR9xv1tDXWU9UIFuq/DQ0/yysx+2mZYm9Dx5i1xkzM3uJ5rloMAM
# cofBbk1a0x7q8ETmMm8c6xdOlMN4ZSA7D0GqH+mhQZ3+sbigZSo04N6o+TzmwTC7
# wKBjLPxcFgCo0MR/6hGdHgbGpm0yXbQ4CStJB6r97DDa8acvz7f9+tCjhNknnvsB
# Zne5VhDhIG7GrrH5trrINV0zdo7xfCAMKneutaIChrop7rRaALGMq+P5CslUXdS5
# anSevUiumDCCBvUwggTdoAMCAQICEDlMJeF8oG0nqGXiO9kdItQwDQYJKoZIhvcN
# AQEMBQAwfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSUw
# IwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENBMB4XDTIzMDUwMzAw
# MDAwMFoXDTM0MDgwMjIzNTk1OVowajELMAkGA1UEBhMCR0IxEzARBgNVBAgTCk1h
# bmNoZXN0ZXIxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAwwjU2Vj
# dGlnbyBSU0EgVGltZSBTdGFtcGluZyBTaWduZXIgIzQwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCkkyhSS88nh3akKRyZOMDnDtTRHOxoywFk5IrNd7Bx
# ZYK8n/yLu7uVmPslEY5aiAlmERRYsroiW+b2MvFdLcB6og7g4FZk7aHlgSByIGRB
# bMfDCPrzfV3vIZrCftcsw7oRmB780yAIQrNfv3+IWDKrMLPYjHqWShkTXKz856vp
# HBYusLA4lUrPhVCrZwMlobs46Q9vqVqakSgTNbkf8z3hJMhrsZnoDe+7TeU9jFQD
# kdD8Lc9VMzh6CRwH0SLgY4anvv3Sg3MSFJuaTAlGvTS84UtQe3LgW/0Zux88ahl7
# brstRCq+PEzMrIoEk8ZXhqBzNiuBl/obm36Ih9hSeYn+bnc317tQn/oYJU8T8l58
# qbEgWimro0KHd+D0TAJI3VilU6ajoO0ZlmUVKcXtMzAl5paDgZr2YGaQWAeAzUJ1
# rPu0kdDF3QFAaraoEO72jXq3nnWv06VLGKEMn1ewXiVHkXTNdRLRnG/kXg2b7HUm
# 7v7T9ZIvUoXo2kRRKqLMAMqHZkOjGwDvorWWnWKtJwvyG0rJw5RCN4gghKiHrsO6
# I3J7+FTv+GsnsIX1p0OF2Cs5dNtadwLRpPr1zZw9zB+uUdB7bNgdLRFCU3F0wuU1
# qi1SEtklz/DT0JFDEtcyfZhs43dByP8fJFTvbq3GPlV78VyHOmTxYEsFT++5L+wJ
# EwIDAQABo4IBgjCCAX4wHwYDVR0jBBgwFoAUGqH4YRkgD8NBd0UojtE1XwYSBFUw
# HQYDVR0OBBYEFAMPMciRKpO9Y/PRXU2kNA/SlQEYMA4GA1UdDwEB/wQEAwIGwDAM
# BgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMEoGA1UdIARDMEEw
# NQYMKwYBBAGyMQECAQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5j
# b20vQ1BTMAgGBmeBDAEEAjBEBgNVHR8EPTA7MDmgN6A1hjNodHRwOi8vY3JsLnNl
# Y3RpZ28uY29tL1NlY3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcmwwdAYIKwYBBQUH
# AQEEaDBmMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3Rp
# Z29SU0FUaW1lU3RhbXBpbmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3Nw
# LnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBMm2VY+uB5z+8VwzJt3jOR
# 63dY4uu9y0o8dd5+lG3DIscEld9laWETDPYMnvWJIF7Bh8cDJMrHpfAm3/j4MWUN
# 4OttUVemjIRSCEYcKsLe8tqKRfO+9/YuxH7t+O1ov3pWSOlh5Zo5d7y+upFkiHX/
# XYUWNCfSKcv/7S3a/76TDOxtog3Mw/FuvSGRGiMAUq2X1GJ4KoR5qNc9rCGPcMMk
# eTqX8Q2jo1tT2KsAulj7NYBPXyhxbBlewoNykK7gxtjymfvqtJJlfAd8NUQdrVgY
# a2L73mzECqls0yFGcNwvjXVMI8JB0HqWO8NL3c2SJnR2XDegmiSeTl9O048P5RNP
# WURlS0Nkz0j4Z2e5Tb/MDbE6MNChPUitemXk7N/gAfCzKko5rMGk+al9NdAyQKCx
# GSoYIbLIfQVxGksnNqrgmByDdefHfkuEQ81D+5CXdioSrEDBcFuZCkD6gG2UYXvI
# brnIZ2ckXFCNASDeB/cB1PguEc2dg+X4yiUcRD0n5bCGRyoLG4R2fXtoT4239xO0
# 7aAt7nMP2RC6nZksfNd1H48QxJTmfiTllUqIjCfWhWYd+a5kdpHoSP7IVQrtKcMf
# 3jimwBT7Mj34qYNiNsjDvgCHHKv6SkIciQPc9Vx8cNldeE7un14g5glqfCsIo0j1
# FfwET9/NIRx65fWOGtS5QDGCBlgwggZUAgEBMGgwVDELMAkGA1UEBhMCR0IxGDAW
# BgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMg
# Q29kZSBTaWduaW5nIENBIFIzNgIQARob6WqXk8OyUG4p7T41tDAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUIsYYDERHIQ6X1soUz/Y1HidK+IkwDQYJKoZIhvcNAQEBBQAEggIAYiso
# IYiLbQI79VaegFaUFHF8r898T2AeJo6lG4wSkB9WnadrFKsEGKT1rLq30RQTLVSU
# M5/pQc7XrPN8VXQjgl7CyVUTh7/RiD1wrsgZMilrBtH1poR64BXxmUaYn7nYPiRx
# uco6rABY/A1tBOE3HRWjWcjfxSA23jthFljUdgTPvZh684U8S10GjYe83eWDGrce
# bGCEgEoDHIVs9eSdSCtjwA8Q8fTvR4rswpk7wPVZOZPLMRh7MskEx+BNcgwkKkas
# 7P8bVgdP4rY321ui1fjMQjizwkvj7myHv1Pu+d9U6VQU0E4g02d8R6usGsAGhdRr
# Hby6QPlAiZJKa+zCEN8a0TouslyPfbe6fH9RFHH/9psAc/9sMdg4lHYFtSHDyia6
# nD9bzEiVHy2mZRQ4Ssg5OH5KFxdPA+FXZHaUx1j4Xf0RnK4dbjdysD7XpvYgrZMF
# lv5TqQVAnQlQi/NW4OpQaGBWO5YBiwlydXXiepZTFCS5XL55HkxKesuxMT+91rEB
# /P6JAiCwPFFBKNwadqsCrEqLYa43GQUz3eImFA1exxwDNGGtEhKghmDuy1cZvGoi
# +Kf6UJuMLJRKLdpSg/5EsfajIIgEgUilmZgYolkEBHBC9mYXxHXMovCJDN4xu3VH
# a8Fw/fNBQfsVGsfYCCU4PR4MzIVD8JLxPEj+kJahggNLMIIDRwYJKoZIhvcNAQkG
# MYIDODCCAzQCAQEwgZEwfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIg
# TWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBM
# aW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENBAhA5
# TCXhfKBtJ6hl4jvZHSLUMA0GCWCGSAFlAwQCAgUAoHkwGAYJKoZIhvcNAQkDMQsG
# CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjMwODIxMTQxMzMwWjA/BgkqhkiG
# 9w0BCQQxMgQwet+8z5ad9BScwVg+djR+cTK8qUpGtuO6OM7lLtLBIi/zNDR7mRvG
# UZe83MHX8vrfMA0GCSqGSIb3DQEBAQUABIICAIA5jpfk1uCs3H6j9h0hM1vZ+5tm
# BltOSbt4vPEGQjl6S6pop7+Q7k2uPKPX+DIdwaftaYCJiD+364eHA+JBAEEOGFda
# 8vf0WY63NZq4CJQ6IOo5J01rHAjiw7XMLsaaUxnQ0zzhSJdo+ryy+rtXanpsR3L3
# t3jJeb/lXrnzQx+RWWL5ug1G6BA7Jrp91jqhm7UdHWfnPZl4C6G7b3sRi6tjQwAM
# rY98HxPGTouh6PR3vnktp/cveHhS222Dkf5dWxt0hbDcwjrqynzaasEBEGY1fvis
# +WRxUNu2zQS9k7vr1fDCvjT2kPp5/KuVYaZUrcuRwmQh7fdMhaH6UTJVYhrvqLhU
# YT94kRqtFdXG8Pqz6BIO2zEHXZQl4CtEs7nsYvODyYy9IgQYSooHbM1mZLZzrdSj
# 8fpXuj5l5hAAhHzamBRqClTAKnEZYkzbWfWpLnIpdqj04yCBFk/Kh5BmkVdrQZLp
# 8sZ0QjxLbhIPc6meSH6UcLGaDiqgRoFM6vnyi0Ul9xXgY08x4eW4FI5SVLCYrmH2
# ci7Aa/TFU0UBiUzZ3tDwKujVF58VgXcl9HJjmLk9rW8Z2PwSPdxLcMwmlr1RiLVI
# BApb0nDqMbpu8v1XPTqbv+dExEDW/fe1FDC3GPs4IQ4K4a7R3OO/8cF3Tj6Zl5f4
# JgRG+ZCoT3X2nFjt
# SIG # End signature block

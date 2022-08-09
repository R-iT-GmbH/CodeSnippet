<# 
.SYNOPSIS
    Generates a selfsignd certifiacte

.DESCRIPTION 
    Generates a selfsignd certificate to configure Microsoft Azure Active Directory Domain Services Sercure LDAP.

.NOTES 
    Version:        1.0
    Author:         Niklas Zistler | R.iT GmbH
    Creation Date:  2022/08/09
    Purpose/Change: Initial script development
#>

# Define your own DNS name used by your managed domain
$dnsName=""


# Get the current date to set a one-year expiration
$lifetime=Get-Date

# Create a self-signed certificate for use with Azure AD DS
New-SelfSignedCertificate -Subject *.$dnsName `
  -NotAfter $lifetime.AddDays(365) -KeyUsage DigitalSignature, KeyEncipherment `
  -Type SSLServerAuthentication -DnsName *.$dnsName, $dnsName

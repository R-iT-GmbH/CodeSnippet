
#Exchange Online Login 
$credential = Get-Credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber

# Pfad f�r Ausgabe definieren und ggf erstellen
$outputPath = "C:\Protokolle\"+(Get-Date -Format yyyy-MM)
If(!(test-path $outputPath))
{
      New-Item -ItemType Directory -Force -Path $outputPath
}

# Dateinamen f�r Ausgabe definieren
$outputFile = $outputPath+"\ExchangeOnlineUserMailboxSizes.csv"

$Mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object @{Name="Benutzer";expression={$_.DisplayName}}, @{Name=�Akt. Postfachgr��e (in MB)�;expression={(Get-MailboxStatistics $_).TotalItemSize}}, @{Name="MailboxMaxSize";expression={$_.ProhibitSendQuota}}
#$Mailboxes = Get-Mailbox | Get-MailboxStatistics | Select-Object DisplayName, TotalItemSize, 
$Mailboxes | Export-Csv $outputFile -NoTypeInformation
$Mailboxes | Out-GridView -Title "Postf�cher (1. Alle ausw�hlen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einf�gen)"

Write-Host -NoNewLine "Beliebige Taste zum Beenden dr�cken";

#Close all PS-Sessions
Get-PSSession | Where-Object ConfigurationName -eq "Microsoft.Exchange" | Remove-PSSession

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
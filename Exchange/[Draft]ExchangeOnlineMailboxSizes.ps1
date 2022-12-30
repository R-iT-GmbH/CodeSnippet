
#Exchange Online Login 
$credential = Get-Credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber

# Pfad für Ausgabe definieren und ggf erstellen
$outputPath = "C:\Protokolle\"+(Get-Date -Format yyyy-MM)
If(!(test-path $outputPath))
{
      New-Item -ItemType Directory -Force -Path $outputPath
}

# Dateinamen für Ausgabe definieren
$outputFile = $outputPath+"\ExchangeOnlineUserMailboxSizes.csv"

$Mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object @{Name="Benutzer";expression={$_.DisplayName}}, @{Name=“Akt. Postfachgröße (in MB)“;expression={(Get-MailboxStatistics $_).TotalItemSize}}, @{Name="MailboxMaxSize";expression={$_.ProhibitSendQuota}}
#$Mailboxes = Get-Mailbox | Get-MailboxStatistics | Select-Object DisplayName, TotalItemSize, 
$Mailboxes | Export-Csv $outputFile -NoTypeInformation
$Mailboxes | Out-GridView -Title "Postfächer (1. Alle auswählen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfügen)"

Write-Host -NoNewLine "Beliebige Taste zum Beenden drücken";

#Close all PS-Sessions
Get-PSSession | Where-Object ConfigurationName -eq "Microsoft.Exchange" | Remove-PSSession

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
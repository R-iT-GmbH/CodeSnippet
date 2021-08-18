# R.iT GmbH | Dirk Martin
# Version 1.0 | 18.08.2021

# Pfad für Ausgabe definieren und ggf erstellen
$outputPath = "C:\Protokolle\"+(Get-Date -Format yyyy-MM)
If(!(test-path $outputPath))
{
      New-Item -ItemType Directory -Force -Path $outputPath
}

# Dateinamen für Ausgabe definieren
$outputFile = $outputPath+"\Zertifikate.csv"

#Zertifikate abfragen und Ausgabe formatieren
$CertList = Get-ChildItem -Path cert:\LocalMachine\My -Recurse | Select-Object Subject, Issuer, NotAfter

#Zerifikate in CSV-Datei exportieren
$CertList | Export-Csv $outputFile -NoTypeInformation

#Zertifikate zum Kopieren auf in einem neuen Fenster ausgeben
$CertList | Out-GridView -Title "Serverzertifikate (1. Alle auswählen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfügen)"

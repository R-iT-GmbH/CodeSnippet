#Paramters to file in
$rootSourceFolder = '' #source folder
$rootDestinationFolder ='' #destination folder 
$filter = '*.csv'  #filertype
$logPath = 'C:\Scripts\Robocopy_Log\' #logpath
$logFile= 'RoboCopyLog_'+(Get-Date -Format "yyyyMMdd-HHmm")+'.txt'
$currentDay = Get-Date -Format "yyyyMMdd"
$currentDate = Get-Date
$destinationFolder = $rootDestinationFolder+'\'

#Result of checking that the path exists
$resultTestDestinationPath = Test-Path -Path $destinationFolder
$resultTestSourchPath = Test-Path -Path $rootSourceFolder

#Result of checking that the logpath exists. If not the missing directory will be created
$resultTestLogPath = Test-Path -Path $logPath
if ($resultTestLogPath -eq $False){
        New-Item -path "$logPath" -ItemType Directory
}
 
#check if destination and source exists. If both are ture, "*.cvs" files with timestamp today will be copied from source to destination. 
if ($resultTestDestinationPath -eq $True -and $resultTestSourchPath -eq $True){
        robocopy $rootSourceFolder $destinationFolder $filter /XO /MAXAGE:$currentDay /LOG:$logPath$logFile
    }
    elseif($resultTestDestinationPath -eq $False){
        $text = $currentDate.ToString()+": The destination path does not exist"
        $text | Out-File $logPath$logFile 
    }
    elseif($resultTestSourchPath -eq $False){
        $text = $currentDate.ToString()+": The source path does not exist"
        $text | Out-File $logPath$logFile 
    }

#delete logfiles older than 30 days. 
Get-ChildItem -path $logPath*.txt | Where-Object LastWriteTime -lt (Get-Date).AddDays(-30) | Remove-Item
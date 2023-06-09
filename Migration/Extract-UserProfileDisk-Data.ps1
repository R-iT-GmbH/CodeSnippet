<############################################################
This script extracts data out of all UDP files in a directory

Modify lines [ 12 & 13 ] for source and target directory
Modify lines [ 53-70 ] as desired for what you want backed up

Written by: Dan Westby
Updated: 3/4/2021
#############################################################>

# Modify these two directories
$liveUPDDir = "\\NAS\e$\RDSUDPs"
$BackupDir = "\\NAS\e$\UDPextracted"

$updGuidwExt = Get-ChildItem -Path $liveUPDDir -Filter *.vhdx

# Where all the magic happens on each file in array
ForEach($Name in $updGuidwExt){

    # Mount upd vhdx and get drive letter
    $DriveLetter = (Mount-VHD -Path "$liveUPDDir\$Name" -PassThru | Get-Disk | Get-Partition | Get-Volume).DriveLetter
    $Drive = $DriveLetter + ":\"
	# Trim off file extension
	$uNoExt = [io.path]::GetFileNameWithoutExtension($Name)
	# Create user SID name variable from trucated uNoExt
    $sid = $uNoExt.substring(5)    

    &{ Clear-Variable UPDUser }
    # Check if backup folder for UPDuser exists, else create it
	$UPDuser = Get-ADUser -filter {SID -like $sid} | select -property samaccountname | ft -HideTableHeaders
    $createPath = $BackupDir + "\"
    $UPDuser = Get-ADUser -Identity $sid -Properties SamAccountName | select -Expand SamAccountName
    $createPath = "$createPath$UPDuser"
    $createPath
    If(Test-Path $createPath){}Else{
        New-Item -path $createPath -ItemType Directory
    }

    # Function for backup folder logic
    Function CopyFolderBackup ($a, $b){
        remove-item -Path "$tempBackupDir\$UPDuser\$b" -Recurse -Force
        New-Item -Path "$tempBackupDir\$UPDuser\$b" -ItemType Directory
        Robocopy.exe $a "$tempBackupDir\$UPDuser\$b" /E /COPY:DAT /R:1 /W:1
    }

    $LocalRoot = $DriveLetter + ":\"

    #####################
    #  Modify below as desired #
    #####################

    # Source locations
    $desktop = $LocalRoot + "Desktop" 
    $downloads = $LocalRoot + "Downloads"
    $documents = $LocalRoot + "Documents"
    $favorites = $LocalRoot + "Favorites"
    $links = $LocalRoot + "Links"
    $icaclient = $LocalRoot + "appdata\Roaming\ICAClient"
    $IEuserdata = $LocalRoot + "appdata\Roaming\Microsoft\Internet Explorer\UserData"
    $Chromeuserdata = $LocalRoot + "AppData\Local\Google\Chrome\User Data"
	
    # Execute the source location backup
    CopyFolderBackup $desktop "\Desktop"
    CopyFolderBackup $downloads "\Downloads"
    CopyFolderBackup $documents "\Documents"
    CopyFolderBackup $favorites "\Favorites"
    CopyFolderBackup $links "\Links"
    CopyFolderBackup $icaclient "\AppData\Roaming\ICAClient"
    CopyFolderBackup $IEuserdata "\AppData\Roaming\Microsoft\Internet Explorer"
    CopyFolderBackup $Chromeuserdata "\AppData\Local\Google\Chrome\User Data"

    ###########
    #  End modify #
    ###########

    # Done with UPD, disconnect
    Dismount-VHD -path "$liveUPDDir\$Name"
}
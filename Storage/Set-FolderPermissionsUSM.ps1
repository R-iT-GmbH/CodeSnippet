# Get the local user group name
$group = [System.Security.Principal.SecurityIdentifier]'S-1-5-32-545'
$groupname = $group.Translate([System.Security.Principal.NTAccount]).Value

# Get the folder path
$folder = "C:\Program Files (x86)\virtual.USM-4"

# add if directory $folder exists
if (Test-Path $folder) {
    # Create a new access rule for the group
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($groupname, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

    # Get the current access control of the folder
    $acl = Get-Acl $folder

    # Add the rule to the access control
    $acl.AddAccessRule($rule)

    # Set the new access control to the folder
    Set-Acl $folder $acl
    
} else {
    Write-Host "Folder $folder does not exist"
    exit 0
}

exit 0
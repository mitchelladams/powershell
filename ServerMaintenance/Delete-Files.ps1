[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$folderPath,
	
	[Parameter(Mandatory=$true)]
	[int]$daysOlderThanToDelete
)


$files = Get-ChildItem -Path $folderPath
foreach($file in $files)
{
	$days = ((Get-Date) - $file.CreationTime).Days
	
	if ($days -gt $daysOlderThanToDelete -and $file.PSIsContainer -ne $true)
	{
		$file.Delete()
	}
}



<#

.SYNOPSIS
This PowerShell script will delete all files in the specified folder older than the number of days specified.

.DESCRIPTION
This PowerShell script takes a folder path and goes through all files in the folder. Any file older than the number of days specified will be deleted.

.PARAMETER folderPath
The full path to a folder of files.

.PARAMETER daysOlderThanToDelete
The number of days used to determine whether or not to delete the file. If 5 days are specified, then any file older than 5 days from the current date is deleted.

.EXAMPLE
.\Delete-Files -folderPath "C:\temp\files" -daysOlderThanToDelete 15 

#>
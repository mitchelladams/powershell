[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$sqlServerName,
	
	[Parameter(Mandatory=$true)]
	[string]$sqlServerDatabase,
	
	[Parameter(Mandatory=$true)]
	[string]$folderSource,	
	
	[Parameter(Mandatory=$true)]
	[string]$folderDestination,
	
	[Parameter(Mandatory=$true)]
	[string]$logDirectory
)


$logName = Get-Date -Format "yyyy_MM_dd_mmss"
$LogPath = $logDirectory + "$logName.txt"

$global:totalFilesMoved = 0
$global:totalFoldersMoved = 0
$global:totalErrors = 0

#Function to log errors to a text file
function LogAction($result)
{		
	Add-Content -Path $LogPath -Value $result
}

#This function creates directories, moves files and deletes empty directories.
function MoveFiles($Identifier)
{	
	$sourcePath = Join-Path -Path $folderSource -ChildPath $Identifier
	$destPath = Join-Path -Path $folderDestination -ChildPath $Identifier
	
	#Test if the source directory exists
	if ((Test-Path -Path $sourcePath) -eq $true)
	{
		#Get list of files in directory
		$fileList = Get-ChildItem $sourcePath -Recurse
		$fCount = [System.IO.Directory]::GetFiles($sourcePath).Length;
		
		#If the folder has any files, then move them
		if ($fCount -gt 0)
		{			
			LogAction("File Count $Identifier `t$fCount")
		
			#Check to see if the destination directory needs to be created.
			if ((Test-Path -Path $destPath) -ne $true)
			{
				#Create Directory
				New-Item $destPath -type directory
				LogAction("Created Dir `t$destPath for $fCount files")
			}
			
			#Loop through each file in the directory
			foreach ($file in $fileList)
			{					
				$sourceFile = Join-Path -Path $sourcePath -ChildPath $file.Name
				$destFile = Join-Path -Path $destPath -ChildPath $file.Name
				
				if ((Test-Path -Path $destFile) -eq $true)
				{
					LogAction("Destination File Exists `t$destFile")
					#File with the same name already exists so prepend name with COPY-
					$destFile = Join-Path -Path $destPath -ChildPath  "COPY-$file"
					
					#Check again. If a file still exists, prepend with a partial GUID-
					if ((Test-Path -Path $destFile) -eq $true)
					{
						LogAction("Destination File Exists Renamed `t$destFile")
						$tmpGUID = ([GUID]::NewGuid()).GUID.Substring(0,8)
						$destFile = Join-Path $destPath -ChildPath "$tmpGUID-$file"
					}
				}
				
				try
				{
					$f1 = [IO.File]::Open($sourceFile, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
					#If the above does not fail, then close it and move the file.
					$f1.Close()
					$f1.Dispose()
				
					Move-Item -Path $sourceFile -Destination $destFile -Force				
					LogAction("Moved File `t$sourceFile to $destFile")
					$global:totalFilesMoved++
				}
				catch [System.IO.IOException]
				{
					$errMsg = $_.Exception.Message
					LogAction("Error Moving $sourceFile `t$errMsg")
					$global:totalErrors++
				}
			}								
			
			#Delete empty source folder
			$numFiles = Get-ChildItem $sourcePath -Recurse -Force
			$cntTwo = [System.IO.Directory]::GetFiles($sourcePath).Length;
			LogAction("Files Remain $Identifier `t$cntTwo")
			
			if ($cntTwo -le 0)
			{
				try
				{
					Remove-Item $sourcePath -Recurse -Force	
					LogAction("Removed Dir `t$sourcePath")
					$global:totalFoldersMoved++
				}
				catch
				{
					$errFoldDel =  $_.Exception.Message
					LogAction("Error Deleting Directory `t$errFoldDel")
					$global:totalErrors++
				}
			}		
			
			LogAction("`n")
		}		
	}
}


#Fill a DataTable with folder identifiers to move
$cn = New-Object system.Data.SqlClient.SqlConnection("Data Source=" + $sqlServerName + ";Integrated Security=TRUE;Initial Catalog=" + $sqlServerDatabase);
$dt = New-Object "System.Data.DataTable"
$q = "SELECT IDENTIFIER FROM TABLE_HOLDING_IDENTIFER;"
$da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($q, $cn)
$da.Fill($dt)

	
#Loop through each row and move any files assigned to that Identifier	
foreach ($Row in $dt.Rows)
{	
	MoveFiles($Row[0])
}

LogAction("Total files moved `t$global:totalFilesMoved")
LogAction("Total folders moved `t$global:totalFoldersMoved")
LogAction("Total errors `t$global:totalErrors")




<#

.SYNOPSIS
This PowerShell script retrieves a list of identifiers (folder names, id numbers, etc.) from a database and uses those identifiers to 
move folder objects named with the same identifier and the folder's files to a new location.

.DESCRIPTION
This PowerShell script uses a SQL Statement to generate a list of folder identifiers from a MS SQL Server database and using that list locates folders to move to a new location.
For example, if the identifier is 'madams', any folder found in the source directory titled 'madams' is moved along with its contents to the destination directory.

.PARAMETER sqlServerName
The Microsoft SQL Server Instance where the database resides.

.PARAMETER sqlServerDatabase
The Microsoft SQL Server Database name.

.PARAMETER folderSource
The full path directory where the source folders are located.

.PARAMETER folderDestination
The full path to the directory where you want to move the folders and files.

.PARAMETER logDirectory
The directory where a log file of all actions is stored.

.EXAMPLE
.\Move-Files-SQL-Query -sqlServerName "MSSQLINSTANCE" -sqlServerDatabase "MyDatabase" -folderSource "C:\temp\source\" -folderDestination "C:\temp\destination\" -logDirectory "C:\temp\logs\"

#>
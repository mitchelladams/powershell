[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$serverName,
	
	[Parameter(Mandatory=$true)]
	[string]$databaseName,
	
	[Parameter(Mandatory=$true)]
	[string]$scriptFilePath,	
	
	[Parameter(Mandatory=$true)]
	[string]$saveDirectory,
	
	[Parameter(Mandatory=$false)]
	[string]$fileNames	
)



$ErrorActionPreference = "Stop"

#Test if the saveDirectory exists
if ((Test-Path -Path $saveDirectory) -ne $true)
{
	throw "The -saveDirectory does not exist"
}
else
{
	#Add a trailing slash if there isn't one supplied on the saveDirectory parameter.
	if (!($saveDirectory.SubString($saveDirectory.Length-1,1) -eq "\")) { $saveDirectory += "\" }
}

#Test SQL Script exists
if ((Test-Path -Path $scriptFilePath -Include "*.sql") -ne $true) 
{	
	throw "The -scriptFilePath either does not exist or is not a .sql file" 
}

#Load assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

#Get SQL Server instance
$server = New-Object ("Microsoft.SqlServer.Management.SMO.Server") ($serverName)

#Load the SQL Script
$item = Get-Item($scriptFilePath)

#Execute the script and store in dataset
$dataset = $server.Databases[$databaseName].ExecuteWithResults("$(Echo $item.OpenText().ReadToEnd())")

#Counter for number of data tables
$cnt = 0

#If file names are supplied and the count doesn't match, then default to number naming of the files
if (Test-Path variable:fileNames)
{
	$arrNames = $fileNames.Split(',')	
	if ($arrNames.Count -ne $dataset.Tables.Count)
	{
		$arrNames = ""
	}	
}

#Loop through each table and export to a csv file
foreach ($dt in $dataset.Tables)
{
	if ($arrNames -ne "")
	{
		$saveName = $arrNames[$cnt]
		$cnt++
	}
	else
	{
		$cnt++
		$saveName = $cnt.ToString()
	}		
	$file = $saveDirectory + $saveName + ".csv"
	$dt | Export-Csv $file -NoTypeInformation
}



<#

.SYNOPSIS
This PowerShell script will take a T-SQL file and export the results to a .csv file

.DESCRIPTION
This PowerShell script takes a T-SQL file containing one or more SELECT statements separated by the GO keyword
and execute the SQL scripts against the supplied Microsoft SQL Server Instance and Database.
The results are then saved as .csv files to the directory supplied. You can optionally assign a name to each file as well.

.PARAMETER serverName
The Microsoft SQL Server Instance where the database resides.

.PARAMETER databaseName
The Microsoft SQL Server Database name.

.PARAMETER scriptFilePath
The full path to the *.sql file containing the SELECT queries retrieving data.

.PARAMETER saveDirectory
The full path to the directory where you want to save the generated .csv files.

.PARAMETER fileNames
A comma separated list of strings to be used for file names. Number of strings should match the number of SELECT statements.
They should also be in the same order as the statements.

.EXAMPLE
.\SQL-Export-To-CSV -serverName "MSSQLINSTANCE" -databaseName "MyDatabase" -scriptFilePath "C:\temp\query.sql" -saveDirectory "C:\temp\Data\" -fileNames "nameone,nametwo"

#>
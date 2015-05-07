[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$logFilePath	
)

#Checks to see if a log file exists
if (Test-Path $logFilePath) 
{
	#Gets the last line of the log file with each row only containing a datetime value.
	$lastLine = (Get-Content $logPath | Select-Object -Last 1) 
	$lastRunDate = [datetime]::Parse($lastLine.Trim())		
	Write-Host $lastRunDate
}
else
{
	Write-Host "File not found"	
}


<#

.SYNOPSIS
This PowerShell script will get the last datetime value from a log file.

.DESCRIPTION
This PowerShell script will load a text file containing a list of datetime values and return the last value of the file.
This is useful if you want a simple way to keep track of when another PowerShell script was last successfully run and use that value to perform 
some other operation.

.PARAMETER logFilePath	
Path to the log file.

.EXAMPLE
.\Get-LastRuntimeFromLog -logFilePath "C:\temp\importlog.txt"

#>

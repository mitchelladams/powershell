<#
.SYNOPSIS
   Enable a task or list of tasks in Scheduled Tasks on a Windows Server.
.DESCRIPTION
   Enable a task or list of tasks in Scheduled Tasks on a Windows Server.
.PARAMETER -serverName
   Name of the server on the network.
.PARAMETER -taskNames
   Comma delimited list of task names to enable on the server.
.EXAMPLE
   .\Enable-Scheduled-Tasks -serverName myserver -taskNames "task name 1,task name 2,task3"
#>


[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$serverName,
	
	[Parameter(Mandatory=$true)]
	[string]$taskNames
)

$arrNames = $taskNames.Split(',')	

foreach ($name in $arrNames)
{
	Write-Host "Executing command:  SCHTASKS /S $serverName /Change /ENABLE /TN \$name" -ForegroundColor Yellow
	
	try
	{
		SCHTASKS /S $serverName /Change /ENABLE /TN \$name
	}
	catch [System.Exception]
	{
		$errMsg = $_.Exception.Message		
		Write-Host "Enabling task $name on $serverName failed: " $errMsg -ForegroundColor Red
	}	
	
	
}

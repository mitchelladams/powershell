<#
.SYNOPSIS
   Disable a task or lists of tasks within Scheduled Tasks on a Windows Server.
.DESCRIPTION
   Disable a task or lists of tasks within Scheduled Tasks on a Windows Server.
.PARAMETER -serverName
   Name of the server on the network.
.PARAMETER -taskNames
   Comma delimited list of task names to disable on the server.
.EXAMPLE
   .\Disable-Scheduled-Tasks -serverName myserver -taskNames "task name 1,task name 2,task3"
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
	Write-Host "Executing command:  SCHTASKS /S $serverName /Change /DISABLE /TN \$name" -ForegroundColor Yellow
	
	try
	{
		SCHTASKS /S $serverName /Change /DISABLE /TN \$name
	}
	catch [System.Exception]
	{
		$errMsg = $_.Exception.Message		
		Write-Host "Disabling task $name on $serverName failed: " $errMsg -ForegroundColor Red
	}		
}

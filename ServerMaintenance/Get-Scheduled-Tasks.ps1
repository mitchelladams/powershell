<#
.SYNOPSIS
   Get a list of Scheduled Tasks from a Windows Server.
.DESCRIPTION
   Get a list of Scheduled Tasks from a Windows Server.
.PARAMETER -serverName
   Name of the server on the network.
.EXAMPLE
   .\Get-Scheduled-Tasks -serverName myserver   
#>


[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$serverName
)


$tasks = & SCHTASKS /S $serverName  /Query /V /FO CSV | ConvertFrom-Csv


foreach ($task in $tasks)
{
	Write-Host $task.TaskName
}

# Note: See commands below on disabling and enabling scheduled tasks on the server.

# To disable: 	SCHTASKS /S $serverName /Change /DISABLE /TN "task name goes here"
# To enable:	SCHTASKS /S $serverName /Change /ENABLE /TN "task name goes here"


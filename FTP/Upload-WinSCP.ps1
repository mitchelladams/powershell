[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$ftpHostName,
	
	[Parameter(Mandatory=$true)]
	[string]$ftpRemoteDirectory,
	
	[Parameter(Mandatory=$true)]
	[string]$ftpUser,	
	
	[Parameter(Mandatory=$true)]
	[string]$ftpPass,
	
	[Parameter(Mandatory=$true)]
	[string]$fileToUpload
)


#Log file settings. Use location of script invocation to create log directory and store log files.
$scriptPath = Split-Path $MyInvocation.MyCommand.Path
$logName = Get-Date -Format "yyyy_MM_dd_mmss"
$logFolder = Join-Path -Path $scriptPath -ChildPath "logs"
$logPath = Join-Path -Path $logFolder -ChildPath "$logName.txt"

$global:totalErrors = 0


#Function to log errors to a text file
function LogAction($result)
{		
	Add-Content -Path $LogPath -Value $result
}

function UploadFile()
{
	try
	{	
		# http://winscp.net/eng/docs/library_powershell
		Add-Type -Path "WinSCPnet.dll"
		$sessionOptions = New-Object WinSCP.SessionOptions
    	$sessionOptions.Protocol = [WinSCP.Protocol]::Ftp
    	$sessionOptions.HostName = $ftpHostName
    	$sessionOptions.UserName = $ftpUser
    	$sessionOptions.Password = $ftpPass
		$sessionOptions.FtpSecure = [WinSCP.FtpSecure]::Implicit
		$sessionOptions.GiveUpSecurityAndAcceptAnyTlsHostCertificate = $true
		
		$session = New-Object WinSCP.Session
		
		try
		{
			# Connect
        	$session.Open($sessionOptions)
 
        	# Upload files
        	$transferOptions = New-Object WinSCP.TransferOptions
        	$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
 			# http://winscp.net/eng/docs/library_session_putfiles
        	$transferResult = $session.PutFiles($fileToUpload, $ftpRemoteDirectory, $False, $transferOptions)
 
        	# Throw on any error
        	$transferResult.Check()			
			
			# Delete the file once uploaded. Simply delete these lines if you do not want to delete the local file.
			$deleteFile = Get-Item -Path $fileToUpload
			$deleteFile.Delete()

		}
		finally
		{
		 	# Disconnect, clean up
        	$session.Dispose()
		}		
	}
	catch [System.Exception]
	{
		$errMsg = $_.Exception.Message
		LogAction("FTP Upload Failed `t$errMsg")			
		$global:totalErrors++
	}
}

function PurgeLogs()
{
	$logs = Get-ChildItem -Path $logFolder
	foreach($file in $logs)
	{
		$days = ((Get-Date) - $file.CreationTime).Days		
		if ($days -gt 15 -and $file.PSIsContainer -ne $true)
		{
			$file.Delete()
		}
	}	
}


LogAction("Script started `t" + (Get-Date).ToString())
UploadFile
PurgeLogs
LogAction("Total errors `t$global:totalErrors")
LogAction("Script completed `t" + (Get-Date).ToString())



<#

.SYNOPSIS
This PowerShell script transmits a file over Implicit Secure FTP using WinSCP. Why? For kicks.

.DESCRIPTION
This PowerShell script transmits a file using Implicit Secure FTP to the specified destination. Before use, WinSCP should be configured in the environment where 
the PowerShell script is being run. For more information visit the WinSCP website for the installation media and/or appropriate .dll files. Once uploaded, the original
file is deleted in cases of sensitve data being used.

.PARAMETER ftpHostName
Host name of the FTP server

.PARAMETER ftpRemoteDirectory
Remote directory where the file is to be uploaded.

.PARAMETER ftpUser
The FTP account user name.

.PARAMETER ftpPass
The FTP account password.

.PARAMETER fileToUpload
Location of file to be uploaded.

.EXAMPLE
.\Upload-WinSCP -ftpHostName "ftp.mysite.biz" -ftpRemoteDirectory "/directory/subdirectory/" -ftpUser "username" -ftpPass "password" -fileToUpload "C:\temp\ftp\myfile.csv"

#>
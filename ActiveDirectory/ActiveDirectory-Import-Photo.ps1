
$SAMName=Read-Host "Enter a username"

$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $domain.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root
$search.Filter = "(&(objectclass=user)(objectcategory=person)(sAMAccountName=$SAMName))"		
$result = $search.FindOne()

function Select-FileDialog
{
	param([string]$Title,[string]$Directory,[string]$Filter="All Files (*.*)|*.*")
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	$objForm = New-Object System.Windows.Forms.OpenFileDialog
	$objForm.InitialDirectory = $Directory
	$objForm.Filter = $Filter
	$objForm.Title = $Title
	$objForm.ShowHelp = $true
	$Show = $objForm.ShowDialog()
	if ($Show -eq "OK")
	{
		Return $objForm.FileName
	}
	else
	{
		Write-Error "Operation cancelled by user."
	}
}


if ($result -ne $null)
{
	$user = $result.GetDirectoryEntry()	
	
	$photo = Select-FileDialog -Title "Select a photo" -Directory "%userprofile%" -Filter "JPG Images (*.jpg)|*.jpg"
	
	#The user's photo
	$thumbnailPhoto = $user.thumbnailPhoto 
	
	[byte[]]$jpg = Get-Content $photo -encoding byte 

	# Clear previous image if exist 
	$user.Properties["thumbnailPhoto"].Clear()

	# Write the image to the user's thumbnailPhoto attribute by converting the byte[] to Base64String 
	$user.Properties["thumbnailPhoto"].Add([System.Convert]::ToBase64String($jpg))

	# Commit the changes to AD 
	$user.CommitChanges()					
}
else
{
	Write-Host "Username" $SAMName "not found"
}


<#

.SYNOPSIS
This PowerShell script will import and assign a .jpg photo to an Active Directory user. 

.DESCRIPTION
This PowerShell script locates an Active Directory user by username (sAMAccountName) and prompts for a .jpg image to assign as the thumbnailPhoto.
The .jpg image should be resized and scaled down BEFORE running this script. The image size should be approximately 96 pixels and be less than 10KB in size.
The user executing the script should have the necessary privledges to update Active Directory.

#>


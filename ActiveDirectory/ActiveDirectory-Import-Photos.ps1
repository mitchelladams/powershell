[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$pathToPictures	
)


#Only .jpg files are looked at.
$fileFilter = "*.jpg"	

#Maximum file size in bytes : 10KB = 10240 bytes
$maxPictureSize = "10240"	

#Get a list of all the pictures
$pictures = Get-ChildItem $pathToPictures -Filter $fileFilter -ErrorAction Stop

#Begin looping through each photo
foreach($pic in $pictures)
{
	#Get the username from the file name
	$userName = $pic.basename.Trim()
		
	if ($pic.Length -le $maxPictureSize) #File size is small enough	
	{																		
		#Search for a user with a matching username in AD
		$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
		$root = $domain.GetDirectoryEntry()
		$search = [System.DirectoryServices.DirectorySearcher]$root
		$search.Filter = "(&(objectclass=user)(objectcategory=person)(sAMAccountName=$userName))"		
		$result = $search.FindOne()
		
		if ($result -ne $null)
		{
			Write-Host "User Found: " + $userName
				
			#The user in question
			$user = $result.GetDirectoryEntry()		
			
			#The user's photo
			$thumbnailPhoto = $user.thumbnailPhoto		
			
			# Get the image as bytes
			[byte[]]$jpg = Get-Content $pic.FullName -encoding byte
			
			# Clear previous image if exist 
			$user.Properties["thumbnailPhoto"].Clear()

			# Write the image to the user's thumbnailPhoto attribute by converting the byte[] to Base64String 
			$user.Properties["thumbnailPhoto"].Add([System.Convert]::ToBase64String($jpg))

			# commit the changes to AD 
			$user.CommitChanges()		
			
			Write-Host "User updated"
		}					
	}
}



<#

.SYNOPSIS
This PowerShell script will import a folder of .jpg photos into AD User objects.

.DESCRIPTION
This PowerShell script takes a folder of .jpg images which are named in the format of sAMAccountName.jpg and assign each photo to that user in AD.
Photos should be 96 pixels and under 10KB in size. Any pictures larger than 10KB are not processed.
The user running the script should have the appropriate privledges to modify Active Directory

.PARAMETER pathToPictures
The Microsoft SQL Server Instance where the database resides.

.EXAMPLE
.\ActiveDirectory-Import-Photos -pathToPictures "C:\temp\photos\"

#>


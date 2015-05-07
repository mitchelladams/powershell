[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$userName
)


#Search for a user with a matching username in AD
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $domain.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root
$search.Filter = "(&(objectclass=user)(objectcategory=person)(sAMAccountName=$userName))"
$result = $search.FindOne()
			
if ($result -ne $null)
{			
	#A user matching the ID was found in AD
	$user = $result.GetDirectoryEntry()			#The user in question
					
	# Clear previous image if exist 
	$user.Properties["thumbnailPhoto"].Clear()
	
	# commit the changes to AD 
	$user.CommitChanges()			
	
	Write-Host "Photo removed for " $userName
}			
else
{
	Write-Host "User not found for " $userName
}



<#

.SYNOPSIS
This PowerShell script will remove the thumbnail photo from a user in Active Directory.

.DESCRIPTION
This PowerShell script takes a username as a parameter then attempts to locate the user in AD and then remove any thumbnail photo.
The account executing the script will need to have necessary privledges to modify AD objects.

.PARAMETER userName
The username of the Active Directory User.


.EXAMPLE
.\ActiveDirectory-Remove-Photo -userName "adamsml"

#>


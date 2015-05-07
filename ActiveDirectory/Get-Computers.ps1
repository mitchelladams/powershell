#Get computers with a certain operating system.

Import-Module ActiveDirectory
Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*2003*"} -Property * | Format-Table Name,OperatingSystem,OperatingSystemServicePack -Wrap -Auto
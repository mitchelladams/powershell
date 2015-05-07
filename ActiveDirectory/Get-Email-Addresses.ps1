
Get-ADUser -Filter * -SearchBase "DC=ENTERVALUE,DC=ENTERVALUE" -Properties mail | Select mail,DistinguishedName,SID | Export-CSV "Email Addresses.csv"
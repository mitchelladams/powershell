net stop w3svc
Start-Sleep -Seconds 5
net stop IISAdmin
Start-Sleep -Seconds 5
net start IISAdmin
Start-Sleep -Seconds 5
net start w3svc



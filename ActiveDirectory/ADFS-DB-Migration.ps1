Stop-Service adfssrv

$newDBServer = <SQLServer\SQLInstance>

$newArtifactCN = "data source=$newDBServer; initial catalog=AdfsArtifactStore;Integrated Security=True"

$newConfigCN = "data source=$newDBServer; initial catalog=AdfsConfiguration;Integrated Security=True"

$temp= Get-WmiObject -namespace root/ADFS -class SecurityTokenService

$temp.ConfigurationdatabaseConnectionstring=$newConfigCN

$temp.put()

Start-Service adfssrv

Set-adfsproperties –artifactdbconnection $newArtifactCN

Restart-Service adfssrv
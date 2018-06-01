/* 
   Windows: Domain Firewall Not Enabled
   
   Lists any Windows machine where Windows Firewall is not turned on for the Domain Profile.
   Requires a custom registry scan configured as follows:
   
   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile
   RegValue: EnableFirewall

*/
   
   Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  Case When tblRegistry.Value = 0 Then 'OFF'
    When tblRegistry.Value = 1 Then 'ON' Else 'UNKNOWN'
  End As DomainFirewallStatus,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblRegistry On tblAssets.AssetID = tblRegistry.AssetID
Where Case When tblRegistry.Value = 0 Then 'OFF'
    When tblRegistry.Value = 1 Then 'ON' Else 'UNKNOWN'
  End <> 'ON' And tblAssetCustom.State = 1 And tblRegistry.Regkey =
  N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile' And tblRegistry.Valuename = N'EnableFirewall'

/* 
   Windows: Domain Firewall Not Enabled
   
   Lists any Windows machine where Windows Firewall is not turned on for the Domain Profile.
   Requires custom registry scans configured as follows:
   
   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile
   RegValue: EnableFirewall

   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile
   RegValue: EnableFirewall
   
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join (Select *
  From tblRegistry
  Where
    tblRegistry.Regkey =
    N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile' And tblRegistry.Valuename = N'EnableFirewall') As tblLocalFWPolicy On tblAssets.AssetID = tblLocalFWPolicy.AssetID
  Left Join (Select *
  From tblRegistry
  Where
    tblRegistry.Regkey =
    N'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile' And tblRegistry.Valuename = N'EnableFirewall') As tblGPOFWPolicy On tblGPOFWPolicy.AssetID = tblAssets.AssetID
Where IsNull(tblLocalFWPolicy.Value, 0) = 0 And IsNull(tblGPOFWPolicy.Value, 0) = 0 And tblAssetCustom.State = 1
Order By DomainRole,
  tblAssets.AssetName
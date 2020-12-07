/*

  Windows: Restart Pending for Updates
  
  Lists Windows assets that are currently waiting to be restarted after updates.
  
  Requires a custom registry scan to be defined in Lansweeper as follows:
  
  Rootkey: HKEY_LOCAL_MACHINE
  RegPath: SYSTEM\CurrentControlSet\Control\Session Manager
  RegValue: SystemUpdateOnBoot

*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As Role,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblUpdateOnBoot.Lastchanged,
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
        N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager'
        And tblRegistry.Valuename = N'SystemUpdateOnBoot') As tblUpdateOnBoot On
    tblAssets.AssetID = tblUpdateOnBoot.AssetID
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblUpdateOnBoot.Value = 1 And tblAssetCustom.State = 1
Order By Role,
  tblAssets.AssetName
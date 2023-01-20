/*
   Asset: Unallocated Workstations
   
   Lists active domain workstations with no Contact, managedBy user, or Location filled in.

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblOperatingsystem.Caption As OSName,
  tblAssets.Version As Build,
  Cast(tblOperatingsystem.InstallDate As Date) As Installed,
  Cast(tblAssetCustom.Warrantydate As Date) As Warranty,
  tblAssetCustom.Location,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblOperatingsystem On
    tblAssets.AssetID = tblOperatingsystem.AssetID
Where tblComputersystem.Domainrole = 1 And tblAssetCustom.State = 1 And
  IsNull(tblAssetCustom.Contact, '') = '' And
  tblADComputers.ManagerADObjectId Is Null
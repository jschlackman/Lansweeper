/*
   Asset: Unallocated Workstations
   
   Lists active domain workstations with no Contact or Location filled in.

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblOperatingsystem.Caption As OSName,
  tblOperatingsystem.Version As OSBuild,
  tblAssetCustom.Warrantydate As [Warranty Expiration],
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblOperatingsystem
    On tblAssets.AssetID = tblOperatingsystem.AssetID
Where tblComputersystem.Domainrole = 1 And IsNull(tblAssetCustom.Location, '') =
  '' And tblAssetCustom.State = 1 And IsNull(tblAssetCustom.Contact, '') = ''
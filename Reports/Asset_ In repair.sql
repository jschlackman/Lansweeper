/*
   Asset: In repair
   
   Lists all assets in Repair status.

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblOperatingsystem.Caption As OSName,
  tblAssets.Version As Build,
  tblAssetCustom.Warrantydate As [Warranty Expiration],
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Left Join tblOperatingsystem On tblAssets.AssetID = tblOperatingsystem.AssetID
Where tblAssetCustom.State = 8
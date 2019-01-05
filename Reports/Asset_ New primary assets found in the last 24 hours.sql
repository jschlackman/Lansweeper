/*
	Asset: New primary assets found in the last 24 hours
*/

Select Top 1000000 tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.AssetID,
  tblAssets.AssetName,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssetCustom.Model,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Location,
  tblAssets.IPAddress,
  tblAssets.Firstseen
From tblAssetCustom
  Inner Join tblAssets On tblAssetCustom.AssetID = tblAssets.AssetID
  Inner Join tsysAssetTypes On tblAssets.Assettype = tsysAssetTypes.AssetType
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblAssets.Firstseen > GetDate() - 1 And tblAssetCustom.State = 1
  And tblAssets.Assettype <> 208
Order By tblAssets.AssetName
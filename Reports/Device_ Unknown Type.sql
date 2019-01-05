/* 
	Device: Unknown Type
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.IPAddress,
  tblAssets.Firstseen,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
Where tblAssetCustom.State = 1 And tblAssets.Assettype = 0
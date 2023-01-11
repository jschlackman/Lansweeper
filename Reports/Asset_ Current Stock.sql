/*
	Asset: Current Stock
	
	Summary of all assets in stock (better field selection and ordering than the default report)
	
*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssetCustom.Serialnumber,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  Cast(tblAssets.Firstseen As Date) As [Added On],
  '$' + tblAssetCustom.Custom1 As [Purchase Cost],
  tblAssetCustom.Custom2 As Vendor
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
Where tblAssetCustom.State = 9
Order By [Added On],
  tblAssets.AssetName
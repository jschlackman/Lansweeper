/*
	Mac: All Active Mac Assets
	
	Shows all active Apple Mac assets.

*/


Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename As Type,
  IsNull(NullIf(tblAssets.Description, ''), 'Workstation - ' +
  tblAssetCustom.Contact) As Description,
  tblAssets.IPAddress,
  tblAssetCustom.Model,
  tblAssetCustom.Location,
  tblMacOSInfo.SystemVersion,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  Cast(tblAssetCustom.PurchaseDate As Date) As PurchaseDate,
  Cast(tblAssetCustom.WarrantyDate As Date) As WarrantyDate,
  tblAssetCustom.Serialnumber,
  tblAssets.FirstSeen,
  tblAssets.Lastseen,
  tblAssets.LastChanged
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tblAssets.Assettype = tsysAssetTypes.AssetType
  Inner Join tblMacOSInfo On tblAssets.AssetID = tblMacOSInfo.AssetID
Where tblAssetCustom.State = 1
Order By tblAssets.AssetName
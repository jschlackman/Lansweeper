/*
	Assets: All Active Servers & Network Devices
	
	Shows all active servers and network connected assets (excluding workstations).

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename As AssetType,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  Coalesce(tsysOS.OSname, tblLinuxSystem.OSRelease, tblMacOSInfo.SystemVersion)
  As OS,
  tblAssetCustom.Model,
  tblAssetCustom.Manufacturer,
  tblAssets.IPAddress,
  tblAssets.Mac As MACAddress,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  Cast(tblAssetCustom.PurchaseDate As Date) As PurchaseDate,
  Cast(tblAssetCustom.WarrantyDate As Date) As WarrantyDate,
  IsNull(tblAzureVirtualMachine.Region, IsNull(tblADComputers.Location,
  tblAssetCustom.Location)) As Location,
  tblAssetCustom.BarCode,
  tblAssetCustom.Contact,
  tblAssetCustom.Serialnumber,
  tblAssetCustom.OrderNumber,
  tblAssets.LastSeen,
  tblAssets.LastChanged
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
      tblAssets.LocationID
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tblLinuxSystem On tblAssets.AssetID = tblLinuxSystem.AssetID
  Left Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Left Join tblMacOSInfo On tblAssets.AssetID = tblMacOSInfo.AssetID
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Left Join tblAzureVirtualMachine On
      tblAssets.AssetID = tblAzureVirtualMachine.AssetId
Where IsNull(tblAssets.IPAddress, '') <> '' And (tblAssets.Assettype Not In (
    -1, 13, 39, 66, 70, 208) Or tblComputersystem.Domainrole > 1) And
  tblAssetCustom.State = 1
Order By AssetType,
  tblAssets.AssetName
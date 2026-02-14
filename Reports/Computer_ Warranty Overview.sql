/*
	Computer: Warranty Overview

	Warranty information for each active computer along with their basic specifications.
*/

Select Top (1000000) tsysOS.Image As icon,
  tblAssetCustom.AssetID,
  tblAssets.AssetName,
  tblAssetCustom.PurchaseDate As [Purchase Date],
  tblAssetCustom.Warrantydate As [Warranty Expiration],
  tblAssets.Domain,
  tblAssets.Username,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  Cast(tblAssets.Memory / 1024 As DECIMAL(10,0)) As [Memory (GB)],
  Cast(assetDiskspace.TotalSize / 1073741824 As DECIMAL(10,0)) As
  [Total Disk (GB)],
  tblAssetCustom.SystemSKU,
  tblAssetCustom.Serialnumber,
  tblAssetCustom.Location,
  tsysIPLocations.IPLocation,
  tblAssets.Firstseen As [Created at],
  tblAssets.Lastseen As [Last successful scan]
From tblAssetCustom
  Inner Join tblAssets On tblAssetCustom.AssetID = tblAssets.AssetID
  Left Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Left Outer Join tsysIPLocations On tsysIPLocations.LocationID =
      tblAssets.LocationID
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join (Select tblassets.AssetID,
      Sum(tblDiskdrives.Size) As TotalSize,
      Sum(tblDiskdrives.Freespace) As TotalFree
    From tblassets
      Inner Join tblDiskdrives On tblassets.AssetID = tblDiskdrives.AssetID
    Group By tblassets.AssetID) assetDiskspace On assetDiskspace.AssetID =
      tblAssets.AssetID
Where ((tblAssetCustom.PurchaseDate Is Not Null And tblAssetCustom.State = 1) Or
    (tblAssetCustom.Warrantydate Is Not Null And tblAssetCustom.State = 1)) And
  tblAssets.Assettype In ( -1, 3)
Order By tblAssets.AssetName
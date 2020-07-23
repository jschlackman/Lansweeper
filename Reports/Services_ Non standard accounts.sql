/*
   Services: Non standard accounts
   
   Enhanced version of built-in report with a more useful selection of fields and that
   excludes some very common standard SQL service account names, and the huge number
   of entries with blank account names.

*/


Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  Coalesce(tsysOS.Image, tsysAssetTypes.AssetTypeIcon10) As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tsysOS.OSname As OS,
  tblServicesUni.Caption As ServiceDisplayName,
  tblServicesUni.Startname,
  tblServicesUni.Name As ServiceName,
  tblServices.Lastchanged,
  tblAssets.Lastseen,
  tblAssets.Lasttried,
  tblServicesUni.Pathname
From tblServices
  Inner Join tblAssets On tblServices.AssetID = tblAssets.AssetID
  Inner Join tblServicesUni On tblServices.ServiceuniqueID =
    tblServicesUni.ServiceuniqueID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
    tblAssets.LocationID
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblServicesUni.Startname Not In ('', 'NT AUTHORITY\LocalService',
  'NT AUTHORITY\NetworkService', 'NT AUTHORITY\Network Service', 'LocalSystem',
  'NT AUTHORITY\LOCAL SERVICE', 'NT Service\MSSQLSERVER',
  'NT Service\SQLSERVERAGENT', 'NT Service\SQLTELEMETRY') And
  tblState.Statename = 'Active'
Order By tblAssets.Domain,
  tblAssets.AssetName,
  ServiceDisplayName
/*
  OS: Windows 10 Build
  
  List of all Windows 10 assets in order of build and update revision.

*/

Select Top (1000000) tsysOS.Image As icon,
  tblAssets.AssetID,
  tblAssets.AssetName,
  tsysOS.OSname As OS,
  tblAssets.OScode + '.' + tblAssets.BuildNumber As Build,
  tblAssets.Version As Release,
  tblAssets.Username,
  tblAssets.IPAddress,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tsysIPLocations.IPLocation,
  tblAssets.Firstseen,
  tblAssets.Lastseen
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Left Outer Join tsysIPLocations On tblAssets.LocationID =
    tsysIPLocations.LocationID
  Inner Join tblOperatingsystem On
    tblAssets.AssetID = tblOperatingsystem.AssetID
  Inner Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tsysOS.OSname = 'Win 10' And tblAssetCustom.State = 1
Order By tblAssets.OScode,
  Cast(tblAssets.BuildNumber As int)
/*
   Windows: New objects in Computers container

   Lists computers added to Lansweeper in the last 24h that are in the Computers container in AD.
*/
Select Top (1000000) tsysOS.Image As icon,
  tblAssets.AssetID,
  tblAssets.AssetName,
  tblAssets.Domain,
  tblAssets.IPAddress,
  tblAssets.Description,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tsysIPLocations.IPLocation,
  tblAssets.Firstseen As [Created at],
  tblAssets.Lastseen As [Last successful scan]
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Outer Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Left Outer Join tsysIPLocations On tsysIPLocations.LocationID =
      tblAssets.LocationID
  Inner Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblAssets.Firstseen > GetDate() - 1 And tblAssetCustom.State = 1 And
  tblAssets.Assettype = -1 And tblADComputers.OU Like 'CN=Computers,DC=%'
Order By [Created at] Desc,
  tblAssets.AssetName
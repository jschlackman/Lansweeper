/*
	Software: Unauthorized software
	
	Improved report with irrelevant columns removed, cleaner WHERE clause,
	and	software details moved forward in the list
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tsysIPLocations.IPLocation,
  tblSoftwareUni.softwareName As Software,
  tblSoftware.softwareVersion As Version,
  tblSoftwareUni.SoftwarePublisher As Publisher,
  tblAssets.Lastseen,
  tblAssets.Lasttried,
  tblSoftware.Lastchanged
From tblSoftware
  Inner Join tblAssets On tblSoftware.AssetID = tblAssets.AssetID
  Inner Join tblSoftwareUni On tblSoftware.softID = tblSoftwareUni.SoftID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Inner Join tsysIPLocations On
    tblAssets.LocationID = tsysIPLocations.LocationID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblSoftwareUni.Approved = 2 And tblState.Statename = 'Active'
Order By tblAssets.Domain,
  tblAssets.AssetName
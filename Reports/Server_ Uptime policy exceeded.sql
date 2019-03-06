/*
	Server: Uptime policy exceeded
	
	Details Windows servers that have been up longer than a pre-defined time
	(40 days in this example)
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  tsysOS.OSname As OS,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  Convert(nvarchar(10),Ceiling(Floor(Convert(integer,tblAssets.Uptime) / 3600 /
  24))) + ' days ' +
  Convert(nvarchar(10),Ceiling(Floor(Convert(integer,tblAssets.Uptime) / 3600 %
  24))) + ' hours ' +
  Convert(nvarchar(10),Ceiling(Floor(Convert(integer,tblAssets.Uptime) % 3600 /
  60))) + ' minutes' As UptimeSinceLastReboot,
  tblAssets.Lastseen - Convert(Decimal,tblAssets.Uptime / 60 / 60 /
  24) As [Boot Time],
  tsysIPLocations.IPLocation,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
    tblAssets.LocationID
  Inner Join tsysOS On tsysOS.OScode = tblAssets.OScode
Where tblAssets.Uptime > 3456000 And tblDomainroles.Domainrole > 1 And
  tblAssetCustom.State = 1
Order By tblAssets.Uptime Desc
/*
	Windows: Installed Web Browser Versions
	
	Improved and updated version of the built-in report 'Windows: Installed web browsers'
	
*/
Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  Chrome.softwareVersion As Chrome,
  Edge.softwareVersion As Edge,
  FireFox.softwareVersion As Firefox,
  InternetExplorer.softwareVersion As InternetExplorer,
  Opera.softwareVersion As Opera,
  Safari.softwareVersion As Safari,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Left Outer Join tsysOS On tsysOS.OScode = tblAssets.OScode
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
      tblAssets.LocationID
  Left Outer Join (Select tblSoftware.AssetID,
      tblSoftware.softID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like 'Windows Internet Explorer%') As
  InternetExplorer On InternetExplorer.AssetID = tblAssets.AssetID
  Left Outer Join (Select tblSoftware.AssetID,
      tblSoftware.softID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like '%Mozilla Firefox%') As FireFox On
      FireFox.AssetID = tblAssets.AssetID
  Left Outer Join (Select tblSoftware.AssetID,
      tblSoftware.softID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like '%Google Chrome%') As Chrome On
      Chrome.AssetID = tblAssets.AssetID
  Left Outer Join (Select tblSoftware.AssetID,
      tblSoftware.softID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like '%Safari%') As Safari On
      Safari.AssetID = tblAssets.AssetID
  Left Outer Join (Select tblSoftware.AssetID,
      tblSoftware.softID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like 'Opera %' And
      tblSoftwareUni.SoftwarePublisher = 'Opera Software') As Opera On
      Opera.AssetID = tblAssets.AssetID
  Left Outer Join (Select tblSoftware.AssetID,
      tblSoftware.softID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like 'Microsoft Edge') As Edge On
      Edge.AssetID = tblAssets.AssetID
Where tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
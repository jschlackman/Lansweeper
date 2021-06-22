/*
	Software: New in last 90 days
	
	Newly discovered software (software not previously seen by Lansweeper) in the last 90 days
	Adapated from https://www.lansweeper.com/forum/yaf_postst16019_Show-newly-discovered-software.aspx#post53935
	
*/

Select Distinct Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  Coalesce(tsysOS.Image, tsysAssetTypes.AssetTypeIcon10) As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tsysIPLocations.IPLocation,
  tblSoftwareUni.softwareName As Software,
  tblSoftware.softwareVersion As Version,
  tblSoftwareUni.Added,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
    tblAssets.LocationID
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tsysOS On tsysOS.OScode = tblAssets.OScode
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Inner Join tblSoftware On tblAssets.AssetID = tblSoftware.AssetID
  Right Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
  Left Join tblSoftwareHist On tblSoftwareHist.softid = tblSoftwareUni.SoftID
Where tblSoftwareUni.Added > GetDate() - 90 And
  SubString(tblSoftwareUni.softwareName, 1, 10) Not In (Select
        SubString(tblSoftwareUni.softwareName, 1, 10) From tblSoftwareUni
      Where tblSoftwareUni.Added < GetDate() - 7) And
  tblSoftwareUni.SoftwarePublisher Is Not Null And tblState.Statename = 'Active'
Order By DomainRole Desc,
  tblAssets.AssetName
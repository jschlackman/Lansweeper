/* 
	Software: Adobe Acrobat Installed
	
	Report of workstations with some version of Acrobat (not Reader) installed.
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  AcrobatInstalls.softwareVersion,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.Username,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Inner Join (Select tblSoftware.AssetID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like '%Acrobat%' And
      tblSoftwareUni.softwareName Not Like '%Reader%' And tblSoftware.MsStore =
      0) AcrobatInstalls On AcrobatInstalls.AssetID = tblAssets.AssetID
Where tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName

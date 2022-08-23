/* 
	Software: Acrobat DC Installed
	
	Report of workstations with some version of Acrobat DC installed.
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
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
Where tblAssets.AssetID In (Select Top 1000000 tblSoftware.AssetID
    From tblSoftware Inner Join tblSoftwareUni On tblSoftwareUni.SoftID =
          tblSoftware.softID
    Where tblSoftwareUni.softwareName Like '%Acrobat DC%') And
  tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
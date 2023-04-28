/*
	Software: Kaseya Installed
	
	Lists all Windows computers with the Kaseya Agent installed. Kaseya uses a unique display name for every
	machine in the Add/Remove Programs list which means every install is treated as a unique software package
	by Lansweeper and not aggregated in standard reports.

*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tblDomainroles.Domainrolename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  KaseyaAgents.softwareVersion,
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
  Inner Join (Select Top 1000000 tblSoftware.AssetID,
      tblSoftware.softwareVersion
    From tblSoftware
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
    Where tblSoftwareUni.softwareName Like 'Kaseya Agent%') KaseyaAgents On
      KaseyaAgents.AssetID = tblADComputers.AssetID
Where tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
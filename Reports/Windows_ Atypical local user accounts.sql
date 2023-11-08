/*
	Windows: Atypical local user accounts
	
	Lists all atypical/unusual user accounts on active Windows systems.
	
*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblUsers.Name,
  tblUsers.Fullname,
  tblUsers.Disabled,
  tblUsers.PasswordChangeable,
  tblUsers.PasswordRequired,
  tblUsers.Lastchanged,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Inner Join tblUsers On tblAssets.AssetID = tblUsers.AssetID
Where tblUsers.Name Not In ('WDAGUtilityAccount', 'DefaultAccount', 'Guest') And
  tblUsers.BuildInAdmin = 0 And tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
/*
	Windows: Template with User Assignment
	
	Enhanced template for Windows asset reports that includes domain role and
	user assignment (based on a custom user relation of type 200)
	
*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  tblAssetCustom.Model,
  tblCurrentAssignments.DisplayName As [Assigned User],
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Left Outer Join (Select tblAssetUserRelations.AssetID,
      STRING_AGG(tblADusers.Displayname, '; ') As DisplayName,
      STRING_AGG(tblADusers.email, '; ') As email
    From tblAssetUserRelations
      Inner Join tblADusers On
          tblADusers.Username = tblAssetUserRelations.Username And
          tblADusers.Userdomain = tblAssetUserRelations.Userdomain
    Where tblAssetUserRelations.StartDate < GetDate() And
      (tblAssetUserRelations.EndDate > GetDate() Or
        tblAssetUserRelations.EndDate Is Null) And tblAssetUserRelations.Type =
      200
    Group By tblAssetUserRelations.AssetID) tblCurrentAssignments On
      tblCurrentAssignments.AssetID = tblAssets.AssetID
Where tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
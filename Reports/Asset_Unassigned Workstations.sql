/*
   Asset: Unassigned Workstations
   
   Lists active domain workstations with no user relation of type 200 (custom type used for assignment)

*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblState.Statename As State,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblOperatingsystem.Caption As OSName,
  tblAssets.Version As Build,
  Cast(tblOperatingsystem.InstallDate As Date) As Installed,
  tblAssetCustom.Serialnumber As Serial,
  Cast(tblAssetCustom.Warrantydate As Date) As Warranty,
  tblAssetCustom.Location,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Join tblOperatingsystem On tblAssets.AssetID = tblOperatingsystem.AssetID
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Left Join (Select tblAssetUserRelations.AssetID
    From tblAssetUserRelations
    Where tblAssetUserRelations.StartDate < GetDate() And
      (tblAssetUserRelations.EndDate > GetDate() Or
        tblAssetUserRelations.EndDate Is Null) And tblAssetUserRelations.Type =
      200) tblCurrentAssignments On tblCurrentAssignments.AssetID =
      tblAssets.AssetID
Where IsNull(tblAssetCustom.Serialnumber, '') <> '' And
  IsNull(tblComputersystem.Domainrole, 0) <= 1 And tblCurrentAssignments.AssetID
  Is Null And tblAssets.Assettype = -1 And tblAssetCustom.Manufacturer <>
  'VMware, Inc.' And tblAssetCustom.State In (1, 7, 9)
Order By Warranty,
  tblAssets.AssetName
/* 
   Asset: Workstations assigned to users with multiple computers
   
   Lists Windows workstations that are assigned to users who have multiple
   computers assigned to them (according to the AD managedBy field).

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblADusers.Displayname As 'Assigned to',
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join (Select Count(tblAssets.AssetName) As assetCount,
        tblADComputers.ManagerADObjectId
      From tblAssets
        Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
        Inner Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
      Where tblADComputers.ManagerADObjectId Is Not Null And
        tblAssetCustom.Model <> 'Virtual Machine'
      Group By tblADComputers.ManagerADObjectId,
        tblAssetCustom.State
      Having Count(tblAssets.AssetName) > 1 And tblAssetCustom.State =
        1) As multiAssets On multiAssets.ManagerADObjectId =
    tblADComputers.ManagerADObjectId And multiAssets.ManagerADObjectId =
    tblADComputers.ManagerADObjectId
  Inner Join tblADusers On
    tblADusers.ADObjectID = tblADComputers.ManagerADObjectId
Where tblAssetCustom.State = 1 And tblAssets.Assettype In ( -1, 13)
Order By 'Assigned to',
  tblAssets.AssetName

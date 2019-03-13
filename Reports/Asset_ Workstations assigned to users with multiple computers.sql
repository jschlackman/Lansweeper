/* 
   Asset: Workstations assigned to users with multiple computers
   
   Lists Windows and Mac workstations that are assigned to users who have multiple
   computers assigned to them (according to the Contact field).

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssetCustom.Contact,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join (Select Count(tblAssets.AssetName) As assetCount,
        tblAssetCustom.Contact
      From tblAssets
        Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
      Group By tblAssetCustom.Contact,
        tblAssetCustom.State
      Having Count(tblAssets.AssetName) > 1 And tblAssetCustom.Contact <> '' And
        tblAssetCustom.State = 1) As multiAssets On multiAssets.Contact =
    tblAssetCustom.Contact And multiAssets.Contact = tblAssetCustom.Contact
Where tblAssetCustom.State = 1 And tblAssets.Assettype In ( -1, 13)
Order By tblAssetCustom.Contact,
  tblAssets.AssetName

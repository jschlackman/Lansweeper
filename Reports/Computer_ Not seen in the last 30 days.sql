/*
   Computer: Not seen in the last 30 days
   
   Enhanced version of last seen report that includes domain role and AD
   description for Windows computers, and also shows Mac computers.

*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblAssets.Lastseen As [Last Seen],
  tblAssets.Lasttried As [Last Tried]
From tblDomainroles
  Inner Join tblComputersystem On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Right Outer Join (tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Outer Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID)
    On tblComputersystem.AssetID = tblAssets.AssetID
Where tblAssets.Lastseen < GetDate() - 30 And tblAssetCustom.State = 1
  And (tblAssets.Assettype = -1 Or tblAssets.Assettype = 13)
Order By [Last Seen] Desc,
  tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
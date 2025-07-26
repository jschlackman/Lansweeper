/*
   Software: Domain Controllers missing Entra Password Protection Agent
*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.Domain,
  tblAssetCustom.Model,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
Where tblAssets.AssetID Not In (Select tblSoftware.AssetID
    From tblSoftware Inner Join tblSoftwareUni On tblSoftwareUni.SoftID =
          tblSoftware.softID
    Where tblSoftwareUni.SoftwarePublisher = 'Microsoft Corporation' And
      tblSoftwareUni.softwareName = 'Azure AD Password Protection DC Agent') And
  tblComputersystem.Domainrole = 4 And tblAssets.Assettype = -1 And
  tblAssetCustom.State = 1
Order By tblAssets.AssetName
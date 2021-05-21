/*
	Asset: All Assigned Workstations
	
	Lists all workstations that have an assigned user in Active Directory.

*/
Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssetCustom.Serialnumber,
  tblOperatingsystem.Caption As OSName,
  Cast(tblAssetCustom.Warrantydate As Date) As WarrantyDate,
  tblAssets.Firstseen,
  tblAssets.Lastseen,
  SoftwareHist.FirstScan
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Outer Join tsysAssetTypes On tsysAssetTypes.AssetType =
    tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblOperatingsystem On
    tblAssets.AssetID = tblOperatingsystem.AssetID
  Inner Join (Select Min(tblSoftwareHist.Lastchanged) As FirstScan,
        tblSoftwareHist.AssetID
      From tblSoftwareHist
      Group By tblSoftwareHist.AssetID) SoftwareHist On SoftwareHist.AssetID =
    tblAssets.AssetID
Where tblADComputers.ManagerADObjectId Is Not Null And
  tblDomainroles.Domainrole = 1 And tblAssetCustom.State = 1
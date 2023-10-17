/*
	Windows: All Active Windows Assets
	
	Shows all active Windows workstations and servers.

*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblDomainroles.Domainrolename As DomainRole,
  tblAssets.IPAddress,
  tblAssetCustom.Serialnumber,
  IsNull(tblAzureVirtualMachine.Region, IsNull(tblADComputers.Location,
  tblAssetCustom.Location)) As Location,
  tblOperatingsystem.Caption As OSName,
  Cast(tblAssetCustom.PurchaseDate As Date) As PurchaseDate,
  Cast(tblAssetCustom.Warrantydate As Date) As WarrantyDate,
  tblADComputers.OU,
  tblAssets.FirstSeen,
  tblAssets.LastSeen,
  tblAssets.LastChanged
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
  Left Join tblAzureVirtualMachine On
      tblAssets.AssetID = tblAzureVirtualMachine.AssetId
Where tsysAssetTypes.AssetTypename = N'Windows' And tblAssetCustom.State = 1
Order By DomainRole
/*
  Windows: Laptops with no webcam

  Lists laptops (including tablets and convertibles) that appear to have
  no webcam installed. Useful for identifying faults with built-in webcams.
  
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
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
  Inner Join tblSystemEnclosure On
    tblAssets.AssetID = tblSystemEnclosure.AssetID
Where tblAssets.AssetID Not In (Select Distinct tblUSBDevices.AssetID
      From tblUSBDevices
      Where tblUSBDevices.Name Like '%cam%') And tblSystemEnclosure.ChassisTypes
  In (9, 10, 30, 31, 32) And tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
/*
	Battery: Detail
	
	Detail from the Win32_PortableBattery class. More accurate and useful than
	the built-in "Battery: Information" report.

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblPortableBattery.Manufacturer,
  tblPortableBattery.Name,
  tblPortableBattery.ManufactureDate,
  Format(Round(tblPortableBattery.DesignCapacity / 1000, 0), '# Wh') As
  DesignCapacity,
  Format(Round(tblPortableBattery.DesignVoltage / 1000, 1), '#.# V') As
  DesignVoltage
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblPortableBattery On
    tblAssets.AssetID = tblPortableBattery.AssetID
Where tblPortableBattery.DesignCapacity > 0 And tblAssetCustom.State = 1
Order By tblAssets.AssetName 
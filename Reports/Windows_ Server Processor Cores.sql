/*
	Windows: Server Processor Cores
	
	Physical processor cores that need minimum Windows Server licensing.
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblProcessor.DeviceID,
  tblProcessor.Name,
  tblProcessor.NumberOfCores,
  tblAssets.OScode,
  tblOperatingsystem.Caption,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblProcessor On tblAssets.AssetID = tblProcessor.AssetID
  Inner Join tblOperatingsystem On
    tblAssets.AssetID = tblOperatingsystem.AssetID
Where tblAssets.OScode Like '%S' And tblAssetCustom.Model <> 'Virtual Machine'
  And tblAssetCustom.State = 1
Order By tblAssets.AssetName, tblProcessor.DeviceID
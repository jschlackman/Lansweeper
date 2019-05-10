/*
  Services: Event Log not running
  
  List of workstations where the Event Log service is not running.
  
  A stopped Event Log service can cause system instability and should not happen unless
  there is a serious problem on the workstation.
  
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblServicesUni.Name As Service,
  tblServices.Lastchanged,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblServices On tblAssets.AssetID = tblServices.AssetID
  Inner Join tblServicesUni On tblServices.ServiceuniqueID =
    tblServicesUni.ServiceuniqueID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Inner Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
Where tblServicesUni.Name = N'EventLog' And tblServices.Started = 0 And
  tblAssetCustom.State = 1
Order By tblAssets.AssetName
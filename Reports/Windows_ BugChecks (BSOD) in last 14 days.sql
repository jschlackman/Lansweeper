/*
	Windows: BugChecks (BSOD) in last 14 days
	
	List of all BSOD events in the last 14 days.
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblNtlog.TimeGenerated,
  tblNtlogMessage.Message
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblNtlog On tblAssets.AssetID = tblNtlog.AssetID
  Inner Join tblNtlogSource On tblNtlogSource.SourcenameID =
    tblNtlog.SourcenameID
  Inner Join tblNtlogFile On tblNtlogFile.LogfileID = tblNtlog.LogfileID
  Inner Join tblNtlogMessage On tblNtlogMessage.MessageID = tblNtlog.MessageID
  Inner Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblNtlog.TimeGenerated > GetDate() - 14 And tblNtlogSource.Sourcename =
  'Microsoft-Windows-WER-SystemErrorReporting' And tblNtlog.Eventcode = 1001 And
  tblAssetCustom.State = 1
Order By tblNtlog.TimeGenerated Desc
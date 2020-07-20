/* 
   Windows: Disk errors in last 7 days
   
   Lists workstations that have logged a disk error to the Event log in the last 7 days.
   Ignores event code 11 as this is seen frequently for USB disks that are disconnected unexpectedly.
   
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblNtlog.Eventcode,
  Max(tblNtlog.TimeGenerated) As LastError,
  Count(tblNtlog.TimeGenerated) As ErrorCount,
  tblNtlogSource.Sourcename,
  tblNtlogMessage.Message
From tblAssets
  Inner Join tblNtlog On tblNtlog.AssetID = tblAssets.AssetID
  Inner Join tblNtlogMessage On tblNtlogMessage.MessageID = tblNtlog.MessageID
  Inner Join tblNtlogSource On tblNtlogSource.SourcenameID =
    tblNtlog.SourcenameID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
Where tblNtlogSource.Sourcename = 'disk' And tblNtlogMessage.Message Like
  '%Harddisk0%' And tblNtlog.Eventtype = 1 And tblAssetCustom.State = 1
Group By tblAssets.AssetID,
  tblAssets.AssetName,
  IsNull(tblADComputers.Description, tblAssets.Description),
  tblNtlog.Eventcode,
  tblNtlogSource.Sourcename,
  tblNtlogMessage.Message,
  tblNtlog.Eventtype,
  tblAssetCustom.State
Having tblNtlog.Eventcode <> 11 And Max(tblNtlog.TimeGenerated) > GetDate() - 7
Order By LastError Desc
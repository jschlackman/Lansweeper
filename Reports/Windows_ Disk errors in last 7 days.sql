/* 
   Windows: Disk errors in last 7 days
   
   Lists workstations that have logged a disk error to the Event log in the last 7 days.
   Ignores event code 11 as this is seen frequently for USB disks that are disconnected unexpectedly.
   
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblNtlog.Eventcode,
  Case tblNtlog.Eventtype When 1 Then 'Error' When 2 Then 'Warning'
    When 3 Then 'Information' When 4 Then 'Security Audit Success'
    When 5 Then 'Security Audit Failure' End As EventType,
  Max(tblNtlog.TimeGenerated) As LastError,
  tblNtlogSource.Sourcename,
  tblNtlogMessage.Message
From tblAssets
  Inner Join tblNtlog On tblNtlog.AssetID = tblAssets.AssetID
  Inner Join tblNtlogMessage On tblNtlogMessage.MessageID = tblNtlog.MessageID
  Inner Join tblNtlogSource On tblNtlogSource.SourcenameID =
    tblNtlog.SourcenameID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID,
  tblState
Where Case tblNtlog.Eventtype When 1 Then 'Error' When 2 Then 'Warning'
    When 3 Then 'Information' When 4 Then 'Security Audit Success'
    When 5 Then 'Security Audit Failure'
  End = 'Error' And tblNtlog.TimeGenerated > GetDate() - 7 And
  tblNtlogSource.Sourcename = 'disk' And tblState.Statename = 'Active'
Group By tblAssets.AssetID,
  tblAssets.AssetName,
  IsNull(tblADComputers.Description, tblAssets.Description),
  tblNtlog.Eventcode,
  tblNtlogSource.Sourcename,
  tblNtlogMessage.Message,
  tblNtlog.Eventtype,
  tblState.Statename
Having tblNtlog.Eventcode <> 11
Order By LastError Desc
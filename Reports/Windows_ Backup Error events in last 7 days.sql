/*
	Windows: Backup Error events in last 7 days
	
	Shows all errors from Windows Server Backup in the last 7 days.

*/

Select tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblNtlog.Eventcode,
  Case tblNtlog.Eventtype
    When 1 Then 'Error'
    When 2 Then 'Warning'
    When 3 Then 'Information'
    When 4 Then 'Security Audit Success'
    When 5 Then 'Security Audit Failure'
  End As EventType,
  tblNtlog.TimeGenerated,
  tblNtlogFile.Logfile,
  tblNtlogMessage.Message,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Inner Join tblNtlog On tblNtlog.AssetID = tblAssets.AssetID
  Inner Join tblNtlogMessage On tblNtlogMessage.MessageID = tblNtlog.MessageID
  Inner Join tblNtlogSource On tblNtlogSource.SourcenameID =
      tblNtlog.SourcenameID
  Inner Join tblNtlogFile On tblNtlogFile.LogfileID = tblNtlog.LogfileID
Where Case tblNtlog.Eventtype
    When 1 Then 'Error'
    When 2 Then 'Warning'
    When 3 Then 'Information'
    When 4 Then 'Security Audit Success'
    When 5 Then 'Security Audit Failure'
  End = 'Error' And tblNtlog.TimeGenerated > GetDate() - 7 And
  tblNtlogSource.Sourcename = 'microsoft-windows-backup' And
  tblAssetCustom.State = 1
Order By tblNtlog.TimeGenerated Desc,
  tblAssets.AssetName
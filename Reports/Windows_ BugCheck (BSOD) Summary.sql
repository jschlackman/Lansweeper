/*
	Windows: BugCheck (BSOD) Summary
	
	Summary of how many times each workstation has had a BSOD.
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  Count(tblNtlog.MessageID) As BSODCount,
  Max(tblNtlog.TimeGenerated) As LastBugCheck
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblNtlog On tblAssets.AssetID = tblNtlog.AssetID
  Inner Join tblNtlogSource On tblNtlogSource.SourcenameID =
    tblNtlog.SourcenameID
  Inner Join tblNtlogFile On tblNtlogFile.LogfileID = tblNtlog.LogfileID
  Inner Join tblNtlogMessage On tblNtlogMessage.MessageID = tblNtlog.MessageID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
Where tblNtlogSource.Sourcename = 'Microsoft-Windows-WER-SystemErrorReporting'
  And tblNtlog.Eventcode = 1001 And tblAssetCustom.State = 1
Group By tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10,
  tblDomainroles.Domainrolename,
  IsNull(tblADComputers.Description, tblAssets.Description)
Order By BSODCount Desc,
  LastBugCheck Desc
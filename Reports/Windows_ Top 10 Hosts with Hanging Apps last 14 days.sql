/*
	Windows: Top 10 Hosts with Hanging Apps last 14 days
	
	Hosts with the highest number of hung app events as reported in the Event log
	
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblHangAssets.HangCount,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join (Select Top (10) Count(tblNtlog.TimeGenerated) As HangCount,
        tblNtlog.AssetID
      From tblNtlog
        Inner Join tblNtlogFile On tblNtlog.LogfileID = tblNtlogFile.LogfileID
        Inner Join tblNtlogMessage On
          tblNtlog.MessageID = tblNtlogMessage.MessageID
        Inner Join tblNtlogSource On tblNtlog.SourcenameID =
          tblNtlogSource.SourcenameID
      Where tblNtlogSource.Sourcename = N'Application Hang' And
        tblNtlog.TimeGenerated > DateAdd(day, -14, GetDate())
      Group By tblNtlog.AssetID
      Order By HangCount Desc) tblHangAssets On tblHangAssets.AssetID =
    tblAssets.AssetID
Where tblAssets.Lastseen >= tblAssets.Lasttried And tblAssetCustom.State = 1
Order By tblHangAssets.HangCount Desc,
  tblAssets.AssetName
/*
	Windows: Excessive Windows Search database size
	
	Machines where the Windows Search database has grown to more than 50GB in size, which
	typically indicates a malfunction.
	
	Requires a file scanning target to be configured with the following path name:
	%ProgramData%\Microsoft\Search\Data\Applications\Windows\Windows.edb
*/


Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  Coalesce(tsysOS.Image, tsysAssetTypes.AssetTypeIcon10) As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  Cast(tblFileVersions.Filesize / (1024 * 1024 * 1024) As decimal(9,1)) As
  SizeGB,
  tblAssets.IPAddress,
  tblAssets.Lastseen As [Last successful scan],
  tblAssets.Lasttried As [Last scan attempt],
  TsysLastscan.Lasttime As LastFileScan,
  tblFileVersions.FilePathfull As PathSearched
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Outer Join tblFileVersions On tblFileVersions.AssetID = tblAssets.AssetID
  Left Outer Join tsysOS On tsysOS.OScode = tblAssets.OScode
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Inner Join TsysLastscan On tblAssets.AssetID = TsysLastscan.AssetID
  Inner Join TsysWaittime On TsysWaittime.CFGCode = TsysLastscan.CFGcode
Where Cast(tblFileVersions.Filesize / (1024 * 1024 * 1024) As decimal(9,1)) > 50
  And tblFileVersions.FilePathfull Like '%Windows.edb' And tblState.Statename =
  'Active' And TsysWaittime.CFGname = 'files'
Order By tblAssets.AssetName,
  PathSearched
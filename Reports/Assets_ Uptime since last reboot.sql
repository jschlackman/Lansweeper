/*
	Assets: Uptime since last reboot
	
	Improved version of report that replaces the obsolete service pack field with the OS version/release identifier
	and uses live uptime calculations for Windows assets instead of returning the uptime at last scan

*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename As AssetType,
  Convert(nvarchar(10),Ceiling(Floor(Convert(integer,IsNull(tblBootTime.UptimeSeconds, tblAssets.Uptime)) / 3600 / 24))) + ' days ' + Convert(nvarchar(10),Ceiling(Floor(Convert(integer,IsNull(tblBootTime.UptimeSeconds, tblAssets.Uptime)) / 3600 % 24))) + ' hours ' + Convert(nvarchar(10),Ceiling(Floor(Convert(integer,IsNull(tblBootTime.UptimeSeconds, tblAssets.Uptime)) % 3600 / 60))) + ' minutes' As UptimeSinceLastReboot,
  IsNull(tblBootTime.BootTime, tblAssets.Lastseen -
  Convert(float,tblAssets.Uptime / 60 / 60 / 24)) As [Boot Time],
  tblAssets.Username,
  tblAssets.Userdomain,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.IPAddress,
  tsysIPLocations.IPLocation,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  Coalesce(tsysOS.OSname, tblLinuxSystem.OSRelease, tblMacOSInfo.SystemVersion)
  As OS,
  tblAssets.Version As Release,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Left Join tsysOS On tsysOS.OScode = tblAssets.OScode
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
      tblAssets.LocationID
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tblLinuxSystem On tblAssets.AssetID = tblLinuxSystem.AssetID
  Left Join tblMacOSInfo On tblAssets.AssetID = tblMacOSInfo.AssetID
  Left Join (Select Top 1000000 tblUptime.AssetID,
      Max(tblUptime.EventTime) As BootTime,
      Min(DateDiff(second, tblUptime.EventTime, GetDate())) As UptimeSeconds
    From tblUptime
    Group By tblUptime.AssetID) tblBootTime On tblBootTime.AssetId =
      tblAssets.AssetID
Where tblAssets.Uptime Is Not Null And tblState.Statename = 'Active'
Order By IsNull(tblBootTime.UptimeSeconds, tblAssets.Uptime) Desc,
  tblAssets.IPNumeric,
  tblAssets.Domain,
  tblAssets.AssetName
/*
	Windows: Computer time zone setting
	Improved version of built-in report that correctly handles fractional time zones.
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tblAssets.Domain,
  'UTC' + (Case
    When tblComputersystem.CurrentTimeZone < 0 Then '-'
    Else '+'
  End) + Format(DateAdd(Minute, Abs(tblComputersystem.CurrentTimeZone), 0),
  'HH:mm') As Timezone,
  tblAssets.Username,
  tblAssets.Userdomain,
  Coalesce(tsysOS.Image, tsysAssetTypes.AssetTypeIcon10) As icon,
  tblAssets.IPAddress,
  tsysIPLocations.IPLocation,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tsysOS.OSname As OS,
  tblAssets.Lastseen As [Last successful scan],
  tblAssets.Lasttried As [Last scan attempt]
From tblAssets
  Left Outer Join tsysOS On tsysOS.OScode = tblAssets.OScode
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
      tblAssets.LocationID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblState On tblState.State = tblAssetCustom.State
Where tblState.Statename = 'Active'
Order By tblAssets.Domain,
  tblAssets.AssetName
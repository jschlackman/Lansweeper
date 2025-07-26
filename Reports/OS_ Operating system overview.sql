/*
   OS: Operating system overview

   Improvement on the built-in OS overview report   
*/
Select Top (1000000) tsysOS.Image As icon,
  tblAssets.AssetID,
  tblAssets.AssetName,
  tsysOS.OSname As OS,
  tblOperatingsystem.Caption,
  tblAssets.Domain,
  Cast(tblAssets.Memory / 1024 As DECIMAL(10,0)) As [Memory (GB)],
  assetCPUs.CPUs,
  tblAssets.IPAddress,
  tblAssets.Description,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tblAssetCustom.Location,
  tsysIPLocations.IPLocation,
  tblAssets.Firstseen As [Created at],
  tblAssets.Lastseen As [Last successful scan]
From tblAssets
  Inner Join tblOperatingsystem On
      tblAssets.AssetID = tblOperatingsystem.AssetID
  Inner Join tsysOS On tsysOS.OScode = tblAssets.OScode
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Outer Join tsysIPLocations On tblAssets.LocationID =
      tsysIPLocations.LocationID
  Left Join (Select tblProcessor.AssetID,
      Sum(tblProcessor.NumberOfLogicalProcessors) As CPUs
    From tblProcessor
    Group By tblProcessor.AssetID) assetCPUs On assetCPUs.AssetID =
      tblAssets.AssetID
Where tblAssetCustom.State = 1
Order By OS,
  tblAssets.AssetName,
  tblOperatingsystem.Caption
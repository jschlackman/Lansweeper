/* 
   OS: Out of Service Windows 10 Build
   
   Lists workstations with a Windows 10 build that is out of service. Replaces
   the useless "OS: Not latest Service Pack Windows 10" report, since Microsoft
   have not released Service Packs for any OS since Windows 7 SP1.
   
   Needs regular updates of the last supported build number. Official reference:
   https://www.microsoft.com/en-us/itpro/windows-10/release-information
   
*/

Select Top (1000000) tsysOS.Image As icon,
  tblAssets.AssetID,
  tblAssets.AssetName,
  tsysOS.OSname As OS,
  tblOperatingsystem.Version,
  tblAssets.Domain,
  tblAssets.Username,
  tblAssets.Userdomain,
  tblAssets.IPAddress,
  tblAssets.Description,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tblAssetCustom.Location,
  tsysIPLocations.IPLocation,
  tblAssets.Firstseen,
  tblAssets.Lastseen
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Left Outer Join tsysIPLocations On tblAssets.LocationID =
    tsysIPLocations.LocationID
  Inner Join tblOperatingsystem
    On tblAssets.AssetID = tblOperatingsystem.AssetID
Where tsysOS.OSname = 'Win 10' And tblOperatingsystem.Version < N'10.0.15063'
  And tblAssetCustom.State = 1
Order By tblAssets.AssetName

/* 
   Disk: Physical Drive Details
   
   Lists model, serial, and firmware identifiers of the physical disk hardware
   present in assets. This returns hard disk information despite it drawing
   on the tblFloppy table.

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.IPAddress,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblFloppy.Name,
  tblFloppy.Model,
  tblFloppy.SerialNumber,
  tblFloppy.FirmwareRevision,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblFloppy On tblAssets.AssetID = tblFloppy.AssetID
Where tblAssetCustom.State = 1
Order By tblAssets.AssetName
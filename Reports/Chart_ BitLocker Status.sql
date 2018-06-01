/*
   Chart: BitLocker Status
   
   Used to generate dashboard pie chart showing percentage of eligible C: drives that are encrypted with BitLocker.

*/

Select Top (100) Percent Max(BitLockerStat.BitLocker) As Status,
  Count(BitLockerStat.BitLocker) As Total
From (Select Case When tblEncryptableVolume.ProtectionStatus = 0 Then 'OFF'
      When tblEncryptableVolume.ProtectionStatus = 1 Then 'ON' Else 'UNKNOWN'
    End As BitLocker
  From tblEncryptableVolume
    Inner Join tblAssets On tblEncryptableVolume.AssetId = tblAssets.AssetID
    Inner Join tsysAssetTypes On tblAssets.Assettype = tsysAssetTypes.AssetType
    Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
    Inner Join tsysOS On tsysOS.OScode = tblAssets.OScode
    Left Outer Join tsysIPLocations On tblAssets.LocationID =
      tsysIPLocations.LocationID
  Where tblEncryptableVolume.DriveLetter = N'C:') As BitLockerStat
Group By BitLockerStat.BitLocker
Order By Status Desc

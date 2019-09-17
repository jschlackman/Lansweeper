/*
   Chart: BitLocker Status (Active Workstations)
   
   Used to generate dashboard pie chart showing percentage of eligible C: drives that are encrypted with BitLocker.

*/

Select Top (100) Percent Max(BitLockerStat.BitLocker) As Status,
  Count(BitLockerStat.BitLocker) As Total
From (Select Case
          When tblEncryptableVolume.ProtectionStatus = 0 Then 'OFF'
          When tblEncryptableVolume.ProtectionStatus = 1 Then 'ON'
          Else 'UNKNOWN'
        End As BitLocker
      From tblEncryptableVolume
        Inner Join tblComputersystem On tblEncryptableVolume.AssetId =
          tblComputersystem.AssetID
        Inner Join tblAssetCustom On tblEncryptableVolume.AssetId =
          tblAssetCustom.AssetID
      Where tblEncryptableVolume.DriveLetter = N'C:' And tblAssetCustom.State =
        1 And tblComputersystem.Domainrole = 1 And tblAssetCustom.Contact <>
        '') As BitLockerStat
Group By BitLockerStat.BitLocker
Order By Status Desc

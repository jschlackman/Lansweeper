/*
   Chart: BitLocker Status (Assigned Workstations)
   
   Used to generate dashboard pie chart showing percentage of C: drives that are encrypted with BitLocker on
   workstations with a current user relation of type 200 (custom type used for assignment).

*/
Select Top (100) Percent Max(BitLockerStat.BitLocker) As Status,
  Count(BitLockerStat.BitLocker) As Total
From (Select Case
        When tblEncryptableVolume.ProtectionStatus = 0 Then 'OFF'
        When tblEncryptableVolume.ProtectionStatus = 1 Then 'ON'
        Else 'UNKNOWN'
      End As BitLocker
    From tblComputersystem
      Left Join tblEncryptableVolume On tblEncryptableVolume.AssetId =
          tblComputersystem.AssetID And tblEncryptableVolume.DriveLetter = 'C:'
      Inner Join tblAssetCustom On tblComputersystem.AssetId =
          tblAssetCustom.AssetID
      Left Join tblADComputers On tblADComputers.AssetID =
          tblComputersystem.AssetID
      Inner Join tblAssetUserRelations On tblAssetUserRelations.AssetID =
          tblComputersystem.AssetID
    Where tblAssetCustom.State = 1 And tblComputersystem.Domainrole = 1 And
      tblComputersystem.Model <> 'Virtual Machine' And
      tblAssetUserRelations.Type = 200 And tblAssetUserRelations.StartDate <=
      GetDate() And IsNull(tblAssetUserRelations.EndDate, 0) = 0) As
  BitLockerStat
Group By BitLockerStat.BitLocker
Order By Total Desc
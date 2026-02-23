/* 
   Windows: Active Directory Writeback
   
   Lists Windows computer details to be written back to Active Directory using the Lansweeper-UpdateComputers.ps1 script.

*/
Select
  tblADComputers.ObjectGUID,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tblAssetCustom.SystemSKU,
  tblAssetCustom.Contact,
  tblAssetCustom.Serialnumber,
  tblAssetCustom.Location,
  AssignedUsers.UserDisplayName
From tblComputersystem
  Inner Join tblADComputers On tblComputersystem.AssetID =
      tblADComputers.AssetID
  Inner Join tblAssetCustom On tblADComputers.AssetID = tblAssetCustom.AssetID
  Left Join (Select tblAssetUserRelations.AssetID,
      (tblADusers.Firstname + ' ' + tblADusers.Lastname) As UserDisplayName
    From tblAssetUserRelations
      Inner Join tblADusers On
          tblADusers.Username = tblAssetUserRelations.Username And
          tblADusers.Userdomain = tblAssetUserRelations.Userdomain
    Where tblAssetUserRelations.EndDate Is Null And tblAssetUserRelations.Type =
      200) AssignedUsers On AssignedUsers.AssetID = tblComputersystem.AssetID
Where Not (tblAssetCustom.Model Is Null) And tblAssetCustom.State = 1 And
  tblComputersystem.Domainrole = 1
/* 
	Software: Office 365 license not used
	
	Report of users who have an Office 365 license assigned to them
	but none of their workstations have the software installed.
	
	Can be adapted to any software detected by Lansweeper so long as
	the following requirements are satisfied in your environment:
	
	1. Users are members of an AD group defining exactly who has licenses for that software.
	2. Workstation assignment is recorded in AD using the 'managedBy' attribute on the computer account.
*/

Select Top 1000000 tblADusers.Displayname,
  tblADusers.email,
  tblADusers.Firstname,
  tblADusers.Lastname,
  tblADusers.Username,
  tblADusers.Userdomain
From tblADGroups
  Inner Join tblADMembership On tblADMembership.ParentAdObjectID =
    tblADGroups.ADObjectID
  Inner Join tblADusers On
    tblADusers.ADObjectID = tblADMembership.ChildAdObjectID
Where tblADGroups.Name = 'Contoso-Software-Office365' And
  tblADusers.ADObjectID Not In (Select tblADComputers.ManagerADObjectId
      From tblAssets Inner Join tblSoftware On tblAssets.AssetID =
          tblSoftware.AssetID Inner Join tblSoftwareUni On
          tblSoftwareUni.SoftID = tblSoftware.softID Inner Join tblAssetCustom
          On tblAssets.AssetID = tblAssetCustom.AssetID Inner Join
        tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
      Where tblSoftwareUni.softwareName = 'Microsoft Office 365 ProPlus - en-us' And
        tblAssetCustom.State = 1)
Order By tblADusers.Displayname
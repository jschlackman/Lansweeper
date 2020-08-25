/*
	Computer: Unauthorized local administrators
	
	Improved unauthorized administrator report that also treats local admins as authorized
	if they are	marked as the computer object manager in AD (I use this in my environment
	to designate the workstation owner who typically has admin rights).
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblUsersInGroup.Domainname As unauthorizedDomain,
  tblUsersInGroup.Username As unauthorizedUser,
  tblUsersInGroup.Lastchanged,
  tblAssets.IPAddress,
  tsysIPLocations.IPLocation,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblUsersInGroup On tblUsersInGroup.AssetID = tblAssets.AssetID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tsysIPLocations On tsysIPLocations.LocationID =
    tblAssets.LocationID
  Inner Join tblState On tblState.State = tblAssetCustom.State
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join tblADusers On
    tblADusers.ADObjectID = tblADComputers.ManagerADObjectId
Where tblUsersInGroup.Username <> IsNull(tblADusers.Username, '') And
  Not Exists(Select tblAssets.AssetName As Domain,
        tblUsers.Name As Username
      From tblAssets Inner Join tblUsers On tblAssets.AssetID = tblUsers.AssetID
      Where tblUsers.BuildInAdmin = 1 And tblUsersInGroup.Domainname =
        tblAssets.AssetName And tblUsersInGroup.Username = tblUsers.Name) And
  Not Exists(Select tsysadmins.Domain,
        tsysadmins.AdminName As username From tsysadmins
      Where tblUsersInGroup.Domainname Like tsysadmins.Domain And
        tblUsersInGroup.Username Like tsysadmins.AdminName) And
  tblUsersInGroup.Admingroup = 1 And tblState.Statename = 'Active'
Order By tblDomainroles.Domainrolename,
  tblAssets.AssetName
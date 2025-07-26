/*
   Microsoft 365: Office license not used

   Shows users who have a license for Microsoft 365 desktop apps, but do not have it installed
   on any workstation assigned to them (via a user relation of type 200)

*/
Select Distinct Top 1000000 'user.png' As Icon,
  tblO365User.DisplayName,
  tblO365User.UserPrincipalName,
  tblO365User.AccountEnabled As Enabled,
  tblO365User.Mail,
  tblO365Organization.TenantId
From tblO365User
  Inner Join tblO365Organization On tblO365User.OrganizationId =
      tblO365Organization.OrganizationId
  Left Outer Join tblADusers On tblADusers.UPN = tblO365User.UserPrincipalName
  Left Outer Join (Select tblAssetUserRelations.Username,
      tblAssetUserRelations.Userdomain
    From tblAssets
      Inner Join tblSoftware On tblAssets.AssetID = tblSoftware.AssetID
      Inner Join tblSoftwareUni On tblSoftwareUni.SoftID = tblSoftware.softID
      Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
      Inner Join tblAssetUserRelations On tblAssets.AssetID =
          tblAssetUserRelations.AssetID
    Where tblAssetUserRelations.Type = 200 And tblSoftwareUni.softwareName Like
      'Microsoft 365 Apps for enterprise%' And tblAssetCustom.State =
      1) OfficeInstalls On tblADusers.username = OfficeInstalls.username
  Inner Join tblO365AssignedPlan On tblO365AssignedPlan.UserId =
      tblO365User.UserId
  Inner Join tblO365ServicePlan On tblO365ServicePlan.ServicePlanId =
      tblO365AssignedPlan.ServicePlanId
Where tblO365ServicePlan.ServicePlanName = 'OFFICESUBSCRIPTION' And
  OfficeInstalls.Username Is Null
Order By tblO365User.DisplayName
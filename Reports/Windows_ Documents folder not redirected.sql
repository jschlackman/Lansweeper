/*
  Windows: Documents folder not redirected

  Lists assigned workstations where a standard user account has logged in and not
  had their Documents folder redirected. Useful for detecting instances where
  automatic redirection by OneDrive for Business is not functioning correctly.
  
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssets.Username,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblDocsFolder.Lastchanged,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join (Select *
      From tblRegistry
      Where
        tblRegistry.Regkey =
        N'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' And tblRegistry.Valuename = N'Personal') As tblDocsFolder On tblAssets.AssetID = tblDocsFolder.AssetID
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblAssets.Username Not Like '%admin%' And tblDocsFolder.Value =
  '%USERPROFILE%\Documents' And tblComputersystem.Domainrole < 2 And
  tblAssetCustom.State = 1 And tblADComputers.ManagerADObjectId Is Not Null
Order By tblAssets.AssetName
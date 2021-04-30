/*
	Windows: Azure AD Join Status
	
	Details of the Azure AD join status for Windows machines.
	
	Requires custom registry scans configured as follows:
	
	Rootkey: HKEY_LOCAL_MACHINE
	RegPath: SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics
	RegValue: hr

	Rootkey: HKEY_LOCAL_MACHINE
	RegPath: SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics
	RegValue: phase

	Rootkey: HKEY_LOCAL_MACHINE
	RegPath: SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics
	RegValue: serverMessage

	Rootkey: HKEY_LOCAL_MACHINE
	RegPath: SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics
	RegValue: registrationType
	
*/
Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblCDJhr.Value As [AAD Join Result],
  tblCDJphase.Value As [AAD Join Phase],
  tblCDJregistrationType.Value As [AAD Join Type],
  tblCDJserverMessage.Value As [AAD Join Server Message],
  tblCDJhr.Lastchanged As [AAD Join Last Change],
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join (Select *
      From tblRegistry
      Where
        tblRegistry.Regkey =
        N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics' And tblRegistry.Valuename = N'hr') As tblCDJhr On tblCDJhr.AssetID = tblAssets.AssetID
  Left Join (Select *
      From tblRegistry
      Where
        tblRegistry.Regkey =
        N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics' And tblRegistry.Valuename = N'phase') As tblCDJphase On tblCDJphase.AssetID = tblAssets.AssetID
  Left Join (Select *
      From tblRegistry
      Where
        tblRegistry.Regkey =
        N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics' And tblRegistry.Valuename = N'serverMessage') As tblCDJserverMessage On tblCDJserverMessage.AssetID = tblAssets.AssetID
  Left Join (Select *
      From tblRegistry
      Where
        tblRegistry.Regkey =
        N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics' And tblRegistry.Valuename = N'registrationType') As tblCDJregistrationType On tblCDJregistrationType.AssetID = tblAssets.AssetID
Where tblAssetCustom.State = 1
Order By tblDomainroles.Domainrole Desc,
  tblAssets.AssetName
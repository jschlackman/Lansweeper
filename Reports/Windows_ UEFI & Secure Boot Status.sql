/*
   Windows: UEFI & Secure Boot Status
   
   Lists whether the boot mode for any Windows machine is BIOS (Legacy) or UEFI, whether
   Secure Boot is enabled, and the status of the 2023 Secure Boot Certificate update.
   
   Note that this does NOT report whether the hardware is UEFI-capable, only if Windows is actually
   running in UEFI mode. Hardware may be UEFI capable but still booting in BIOS (legacy) mode.
   
   Requires custom registry scans configured as follows:
   
   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Control\SecureBoot\State
   RegValue: UEFISecureBootEnabled

   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing
   RegValue: UEFICA2023Status

   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing
   RegValue: UEFICA2023Error

   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing
   RegValue: ConfidenceLevel
*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  Case
    When tblRegSBEnabled.Value Is Null Then 'BIOS'
    Else 'UEFI'
  End As BootMode,
  Case
    When tblRegSBEnabled.Value = 1 Then 'ON'
    Else 'OFF'
  End As SecureBoot,
  tblRegSBUEFICA2023Status.Value As UEFICA2023Status,
  tblRegSBConfidenceLevel.Value As ConfidenceLevel,
  tblRegSBUEFICA2023Error.Value As UEFICA2023Error,
  tblOperatingsystem.Caption As OSVersion,
  tblAssets.Version As Release,
  tblDomainroles.Domainrolename As DomainRole,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Left Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Outer Join (Select tblRegistry.RegistryID,
      tblRegistry.AssetID,
      tblRegistry.Value,
      tblRegistry.Lastchanged
    From tblRegistry
    Where
      tblRegistry.Regkey =
      N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State'
      And tblRegistry.Valuename = N'UEFISecureBootEnabled') As tblRegSBEnabled
    On tblAssets.AssetID = tblRegSBEnabled.AssetID
  Left Outer Join (Select tblRegistry.RegistryID,
      tblRegistry.AssetID,
      tblRegistry.Value,
      tblRegistry.Lastchanged
    From tblRegistry
    Where
      tblRegistry.Regkey =
      N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing'
	  And tblRegistry.Valuename = N'UEFICA2023Status') As tblRegSBUEFICA2023Status
	On tblAssets.AssetID = tblRegSBUEFICA2023Status.AssetID
  Left Outer Join (Select tblRegistry.RegistryID,
      tblRegistry.AssetID,
      tblRegistry.Value,
      tblRegistry.Lastchanged
    From tblRegistry
    Where
      tblRegistry.Regkey =
      N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing'
	  And tblRegistry.Valuename = N'UEFICA2023Error') As tblRegSBUEFICA2023Error
	On tblAssets.AssetID = tblRegSBUEFICA2023Error.AssetID
  Left Outer Join (Select tblRegistry.RegistryID,
      tblRegistry.AssetID,
      tblRegistry.Value,
      tblRegistry.Lastchanged
    From tblRegistry
    Where
      tblRegistry.Regkey =
      N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing'
	  And tblRegistry.Valuename = N'ConfidenceLevel') As tblRegSBConfidenceLevel
	On tblAssets.AssetID = tblRegSBConfidenceLevel.AssetID
  Left Outer Join tsysAssetTypes On tsysAssetTypes.AssetType =
      tblAssets.Assettype
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Left Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Join tblTPM On tblAssets.AssetID = tblTPM.AssetId
  Left Join tblOperatingsystem On tblAssets.AssetID = tblOperatingsystem.AssetID
Where tsysAssetTypes.AssetTypename = N'Windows' And tblAssetCustom.State = 1
Order By tblComputersystem.DomainRole,
  tblAssets.AssetName
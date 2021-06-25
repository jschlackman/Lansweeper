/*
	Windows: BitLocker Readiness
	
	Shows the UEFI, SecureBoot, TPM, and BitLocker status of all active Windows machines.
	
	Requires custom registry scan configured as follows for UEFI status:
   
	Rootkey: HKEY_LOCAL_MACHINE
	RegPath: SYSTEM\CurrentControlSet\Control\SecureBoot\State
	RegValue: UEFISecureBootEnabled
	
*/
Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  Case
    When tblRegistrySB.Value Is Null Then 'BIOS'
    Else 'UEFI'
  End As BootMode,
  Case
    When tblRegistrySB.Value = 1 Then 'ON'
    Else 'OFF'
  End As SecureBoot,
  tblTPM.SpecVersion As TPMVersion,
  IsNull(tblTPM.IsEnabled_InitialValue, 0) As TPMEnabled,
  IsNull(tblTPM.IsActivated_InitialValue, 0) As TPMActive,
  IsNull(tblTPM.IsOwned_InitialValue, 0) As TPMOwned,
  Case
    When tblEncryptableVolume.ProtectionStatus = 0 Then 'OFF'
    When tblEncryptableVolume.ProtectionStatus = 1 Then 'ON'
    Else 'UNKNOWN'
  End As BitLockerStatus,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
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
      tblRegistry.Regkey,
      tblRegistry.Valuename,
      tblRegistry.Value,
      tblRegistry.Lastchanged
    From tblRegistry
    Where
      tblRegistry.Regkey =
      N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State'
      And tblRegistry.Valuename = N'UEFISecureBootEnabled') As tblRegistrySB On
      tblAssets.AssetID = tblRegistrySB.AssetID
  Left Outer Join tsysAssetTypes On tsysAssetTypes.AssetType =
      tblAssets.Assettype
  Left Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Left Join tblDomainroles On tblDomainroles.Domainrole =
      tblComputersystem.Domainrole
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
  Left Join tblTPM On tblAssets.AssetID = tblTPM.AssetId
  Left Join tblEncryptableVolume On
      tblAssets.AssetID = tblEncryptableVolume.AssetId And
      tblEncryptableVolume.DriveLetter = 'C:'
  Left Join tblOperatingsystem On tblAssets.AssetID = tblOperatingsystem.AssetID
Where tsysAssetTypes.AssetTypename = N'Windows' And tblAssetCustom.State = 1
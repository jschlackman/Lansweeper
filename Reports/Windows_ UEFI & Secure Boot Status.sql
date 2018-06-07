/*
   Windows: UEFI & Secure Boot Status
   
   Lists whether the boot mode for any Windows machine is BIOS (Legacy) or UEFI, and whether
   Secure Boot is enabled.
   
   Note that this does NOT report whether the hardware is UEFI-capable, only if Windows is actually
   running in UEFI mode. Hardware may be UEFI capable but still booting in BIOS (legacy) mode.
   
   Requires a custom registry scan configured as follows:
   
   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SYSTEM\CurrentControlSet\Control\SecureBoot\State
   RegValue: UEFISecureBootEnabled

*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypename,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  Case When tblRegistrySB.Value Is Null Then 'BIOS' Else 'UEFI' End As BootMode,
  Case When tblRegistrySB.Value = 1 Then 'ON' Else 'OFF' End As SecureBoot,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblDomainroles.Domainrolename As DomainRole,
  tblAssets.IPAddress,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Left Outer Join (Select tblRegistry.RegistryID,
    tblRegistry.AssetID,
    tblRegistry.Regkey,
    tblRegistry.Valuename,
    tblRegistry.Value,
    tblRegistry.Lastchanged
  From tblRegistry
  Where
    tblRegistry.Regkey =
    N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State' And
    tblRegistry.Valuename = N'UEFISecureBootEnabled') As tblRegistrySB
    On tblAssets.AssetID = tblRegistrySB.AssetID
  Left Outer Join tsysAssetTypes On tsysAssetTypes.AssetType =
    tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tsysAssetTypes.AssetTypename = N'Windows' And tblAssetCustom.State = 1
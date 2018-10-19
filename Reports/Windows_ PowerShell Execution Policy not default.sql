/*
   Windows: PowerShell Execution Policy not default
   
   Lists active machines that have a PowerShell script execution policy set to something
   other than the Windows default (Restricted for workstations and RemoteSigned for servers).
   
   Requires a custom registry scan configured as follows:
   
   Rootkey: HKEY_LOCAL_MACHINE
   RegPath: SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
   RegValue: ExecutionPolicy

*/

Select Top (1000000) tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblDomainroles.Domainrolename As DomainRole,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblAssets.IPAddress,
  tblPowerShellPolicy.Value As ExecutionPolicy,
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
        N'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' And tblRegistry.Valuename = N'ExecutionPolicy')
	  As tblPowerShellPolicy On tblAssets.AssetID = tblPowerShellPolicy.AssetID
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblAssets.Lastseen >= tblAssets.Lasttried And
  ((tblPowerShellPolicy.Value <> 'Restricted' And tblDomainroles.Domainrolename
      Like '%workstation') Or (tblPowerShellPolicy.Value <> 'RemoteSigned' And
      tblDomainroles.Domainrolename Like '%server')) And tblAssetCustom.State = 1
Order By DomainRole,
  tblAssets.AssetName
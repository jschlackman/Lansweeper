/*
   Services: Netlogon not set to Automatic
   
   Lists workstations where the Netlogon service is not set to automatic startup.
   
   Used to detect workstations affected by an issue where Dell SupportAssist sets
   the startup type to Manual.
   
   https://www.dell.com/community/SupportAssist/Dell-SupportAssistant-sets-Netlogon-service-to-manual/td-p/6083752

*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  IsNull(tblADComputers.Description, tblAssets.Description) As Description,
  tblServicesUni.Caption As Service,
  tsysOS.Image As icon,
  tblServiceStartMode.StartMode,
  tblServices.Lastchanged,
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblServices
  Inner Join tblAssets On tblServices.AssetID = tblAssets.AssetID
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblServicesUni On tblServices.ServiceuniqueID =
    tblServicesUni.ServiceuniqueID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysOS On tblAssets.OScode = tsysOS.OScode
  Inner Join tblServiceStartMode On tblServiceStartMode.StartID =
    tblServices.StartID
  Left Join tblADComputers On tblAssets.AssetID = tblADComputers.AssetID
Where tblServicesUni.Caption = 'Netlogon' And tblServices.StartID <> 3
  And tblComputersystem.Domainrole < 2 And tblAssetCustom.State = 1
Order By tblAssets.AssetName
/*
	Chart: Windows 10 Workstation Build
*/

Select Top (100) Percent BuildRelease.Version,
  Count(tblAssets.OScode) As Count
From tblAssets
  Inner Join (Select tblAssets.OScode,
      Max(tblAssets.Version) As Version
    From tblAssets
    Where tblAssets.OScode <> '' And tblAssets.Version <> ''
    Group By tblAssets.OScode) As BuildRelease On BuildRelease.OScode =
      tblAssets.OScode
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
Where tblAssets.OScode Like N'10.0.1%' And tblComputersystem.Domainrole < 2 And
  tblAssetCustom.State = 1
Group By BuildRelease.Version

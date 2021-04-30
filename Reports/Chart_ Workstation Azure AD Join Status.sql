/*
	Chart: Workstation Azure AD Join Status
	
	Used to generate dashboard pie chart showing percentage of workstations that are Azure AD joined.
	
	Requires custom registry scans configured as follows:
   
	Rootkey: HKEY_LOCAL_MACHINE
	RegPath: SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics
	RegValue: hr
	
*/

Select Top (100) Percent Max(AADJoinStat.AADJoin) As Status,
  Count(AADJoinStat.AADJoin) As Total
From (Select Case
          When tblCDJhr.Value Is Null Then 'Unknown'
          When tblCDJhr.Value = 0 Then 'Joined'
          Else 'Not Joined'
        End As AADJoin
      From tblAssets
        Left Join (Select tblRegistry.AssetID,
              Cast(tblRegistry.Value As bigint) As Value
            From tblRegistry
            Where
              tblRegistry.Regkey =
              N'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\Diagnostics' And tblRegistry.Valuename = N'hr') As tblCDJhr On tblCDJhr.AssetID = tblAssets.AssetID
        Inner Join tblComputersystem On
          tblAssets.AssetID = tblComputersystem.AssetID
        Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
      Where tblComputersystem.Domainrole = 1 And tblAssetCustom.State =
        1) As AADJoinStat
Group By AADJoinStat.AADJoin
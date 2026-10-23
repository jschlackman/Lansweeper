Select Top 1000000 tblassets.AssetID,
  tblassets.AssetName,
  tsysassettypes.AssetTypeIcon10 As icon,
  IsNull(tblADComputers.Description, tblassets.Description) As Description,
  tblSqlServers.skuName As 'SQL Server Type',
  tblSqlDatabases.name As 'Database Name',
  tblSqlDatabases.dataFilesSizeKb,
  tblassets.Lastseen,
  tblSqlDatabases.Lastchanged
From tblassets
  Inner Join tblassetcustom On tblassets.AssetID = tblassetcustom.AssetID
  Inner Join tsysassettypes On tsysassettypes.AssetType = tblassets.Assettype
  Inner Join tblSqlServers On tblassets.AssetID = tblSqlServers.AssetID
  Inner Join tblSqlDatabases On tblSqlServers.sqlServerId =
      tblSqlDatabases.sqlServerId
  Left Join tblADComputers On tblassets.AssetID = tblADComputers.AssetID
Where tblassetcustom.State = 1
Order By tblassets.AssetName,
  'SQL Server Type',
  'Database Name'
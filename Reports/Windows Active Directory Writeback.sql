/* 
   Windows: Active Directory Writeback
   
   Lists Windows computer details to be written back to Active Directory using the LansweeperADWriteback.ps1 script.

*/
SELECT
    dbo.tblADObjects.sAMAccountName,
    dbo.tblADComputers.OU,
    dbo.tblAssetCustom.Manufacturer,
    dbo.tblAssetCustom.Model,
    dbo.tblAssetCustom.SystemSKU,
    dbo.tblAssetCustom.Contact,
    dbo.tblAssetCustom.Serialnumber,
    dbo.tblAssetCustom.Location
FROM
    dbo.tblComputersystem INNER JOIN
    dbo.tblADComputers ON dbo.tblComputersystem.AssetID = dbo.tblADComputers.AssetID INNER JOIN
    dbo.tblADObjects ON dbo.tblADComputers.ADObjectID = dbo.tblADObjects.ADObjectID INNER JOIN
    dbo.tblAssetCustom ON dbo.tblADComputers.AssetID = dbo.tblAssetCustom.AssetID
WHERE
    (NOT (dbo.tblAssetCustom.Model IS NULL)) AND
    (dbo.tblAssetCustom.State = 1) AND
    (dbo.tblComputersystem.Domainrole = 1)
ORDER BY
    dbo.tblADObjects.sAMAccountName
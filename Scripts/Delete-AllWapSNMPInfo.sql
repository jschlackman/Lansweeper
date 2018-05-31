/* 

   Name: Delete-AllWapSNMPInfo.sql
   Author: James Schlackman
   Last modified: Aug 3 2017
   
   Deletes SNMP information for any device with the Wireless Access Point asset type.

   Used when Meraki WAPs changed what MAC addresses they reported and Lansweeper
   reported errors ever since because the number of MACs was inconsistent with previous scans.
   
*/
DELETE FROM tblSNMPInfo
WHERE (SnmpInfoID IN
	(SELECT dbo.tblSNMPInfo.SnmpInfoID
	FROM dbo.tblAssets INNER JOIN
		dbo.tblSNMPInfo ON dbo.tblAssets.AssetID = dbo.tblSNMPInfo.AssetID
	WHERE (dbo.tblAssets.Assettype = 17)))


DELETE FROM tblAssetMacAddress
WHERE (MacID IN
	(SELECT dbo.tblAssetMacAddress.MacID
	FROM dbo.tblAssets INNER JOIN
		dbo.tblAssetMacAddress ON dbo.tblAssets.AssetID = dbo.tblAssetMacAddress.AssetID
	WHERE (dbo.tblAssets.Assettype = 17)))

/* 

   Name: Delete-InactiveSwitchSNMPInfo.sql
   Author: James Schlackman
   Last modified: Feb 16 2017
   
   Deletes MAC address information gathered via SNMP that relates to connections to inactive switch assets.

   Used to clear old LLDP/CDP connection details from assests that were connected to switches that have been decomissioned.
   
*/

DELETE FROM tblSNMPAssetMac
WHERE (SNMPMacID IN
	(SELECT tblSNMPAssetMac_1.SNMPMacID
		FROM tblSNMPInfo INNER JOIN
			tblSNMPAssetMac AS tblSNMPAssetMac_1 ON tblSNMPInfo.IfIndex = tblSNMPAssetMac_1.IfIndex AND tblSNMPInfo.AssetID = tblSNMPAssetMac_1.AssetID RIGHT OUTER JOIN
			tblAssetCustom INNER JOIN
			tblAssets AS tblAssets_1 ON tblAssetCustom.AssetID = tblAssets_1.AssetID ON tblSNMPInfo.AssetID = tblAssets_1.AssetID
            WHERE (tblAssetCustom.State <> 1) AND (tblAssets_1.Assettype = 6)))
/*
	Asset: Disposed
	
	Lists assets with custom state of Disposed (State = 10 in this example). Used when Finance requests a list of
	disposed assets.
	
	This custom state needs to be added manually and the Where clause may need altering to match if it is not state 10
	
	The Contact field is used to indicate who the assets was disposed to (e.g. name of recycling company)
	
	This report also relies on the following custom fields being defined. You will need to add them as required
	and adjust the Select statement accordingly if your definitions do not match exactly
	
	Custom1 = Purchase Cost (Currency)
	Custom2 = Vendor (Textbox)
	Custom3 = GL Code (Textbox)
	Custom4 = Disposal Date (Date)
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tblAssetCustom.Contact,
  Cast(tblAssetCustom.Custom4 As Date) As [Disposal Date],
  tblAssetCustom.PurchaseDate,
  tblAssetCustom.Custom1 As [Purchase Cost],
  tblAssetCustom.Custom2 As Vendor,
  tblAssetCustom.OrderNumber,
  tblAssetCustom.Custom3 As [GL Code],
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
  Inner Join tblDomainroles On tblDomainroles.Domainrole =
    tblComputersystem.Domainrole
Where tblAssetCustom.State = 10
Order By [Disposal Date],
  tblAssets.AssetName
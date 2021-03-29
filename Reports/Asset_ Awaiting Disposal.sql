/*
	Asset: Awaiting Disposal
	
	Lists assets that are Non-active or Broken.
	
	Excludes:
	
	- Assets with 'Virtual' in their model name (e.g. virtual machines)
	- VMWare Guests
	- Azure VMs
	- Remote Access Controllers (these are integrated into other assets and do not need tracking separately)
	
	This report also relies on the following optional custom fields being defined. You will need to add them as
	required and adjust the Select statement accordingly if your definitions do not match exactly
	
	Custom1 = Purchase Cost (Currency)
	Custom2 = Vendor (Textbox)
	Custom3 = GL Code (Textbox)
	
*/

Select Top 1000000 tblAssets.AssetID,
  tblAssets.AssetName,
  Cast(tblAssetCustom.PurchaseDate As DATE) As PurchaseDate,
  tsysAssetTypes.AssetTypeIcon10 As icon,
  tblState.Statename As State,
  tsysAssetTypes.AssetTypename,
  tblAssetCustom.Manufacturer,
  tblAssetCustom.Model,
  tblAssetCustom.Serialnumber,
  tblAssetCustom.Contact,
  tblAssetCustom.Custom1 As [Purchase Cost],
  tblAssetCustom.Custom2 As Vendor,
  tblAssetCustom.OrderNumber,
  tblAssetCustom.Custom3 As [GL Code],
  tblAssets.Lastseen,
  tblAssets.Lasttried
From tblAssets
  Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
  Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
  Inner Join tblState On tblState.State = tblAssetCustom.State
Where tblAssetCustom.Model Not Like '%Virtual%' And (tblAssetCustom.State = 2 Or
    tblAssetCustom.State = 5) And tsysAssetTypes.AssetType Not In (38, 70, 74)
Order By tblAssetCustom.PurchaseDate,
  tblAssets.AssetName
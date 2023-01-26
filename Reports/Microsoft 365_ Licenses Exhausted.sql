/*
  Microsoft 365: Licenses Exhausted
  
  Report that lists when select Microsoft 365 licenses have 0 seats remaining
  (In this example, Microsoft 365 E5, Project Professional, and Visio Pro Online)
  
  Requires Office 365 scanning to be set up in Lansweeper:
  https://community.lansweeper.com/t5/scanning-your-network/how-to-scan-office-365-with-a-microsoft-cloud-credential/ta-p/64545

*/

Select Top 1000000 tblO365Sku.DisplayName,
  tblO365License.PrepaidUnitsEnabled - tblO365License.ConsumedUnits As
  Available,
  tblO365License.ConsumedUnits As Assigned,
  tblO365License.PrepaidUnitsEnabled As Total
From tblO365License
  Inner Join tblO365Sku On tblO365Sku.Name = tblO365License.SkuPartNumber
Where tblO365License.PrepaidUnitsEnabled - tblO365License.ConsumedUnits < 1 And
  tblO365License.SkuPartNumber In ('SPE_E5', 'VISIOCLIENT',
  'PROJECTPROFESSIONAL')
Order By Total Desc
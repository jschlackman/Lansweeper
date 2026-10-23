Select Top 1000000 tblADusers.Displayname As Name,
  Format(DateAdd(s, -1, tblADusers.ExpirationDate At Time Zone 'UTC') At Time
  Zone CURRENT_TIMEZONE_ID(), 'ddd M/d') As [Last Day],
  tblADusers.Email,
  IsNull(tblADusers.Title, tblADusers.Description) As Description,
  tblADusers.Department,
  Format(tblADusers.whenCreated, 'd') As [Account Created],
  tblADmanagers.Displayname As Manager,
  tblADmanagers.email As [Manager Email]
From tblADusers
  Left Join tblADusers tblADmanagers On tblADusers.ManagerADObjectId =
      tblADmanagers.ADObjectID
Where tblADusers.ExpirationDate > GetDate() And
  tblADusers.ExpirationDate < DateAdd(d, 7, GetDate()) And
  tblADusers.IsEnabled = 1
Order By tblADusers.ExpirationDate
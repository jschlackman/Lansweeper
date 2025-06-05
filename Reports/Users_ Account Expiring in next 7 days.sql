Select Top 1000000 tblADusers.Displayname As Name,
  Format(DateAdd(s, -1, tblADusers.ExpirationDate At Time Zone 'UTC') At Time
  Zone CURRENT_TIMEZONE_ID(), 'ddd M/d') As [Last Day],
  tblADusers.Email,
  IsNull(tblADusers.Title, tblADusers.Description) As Description,
  tblADusers.Department,
  Format(tblADusers.whenCreated, 'd') As [Account Created]
From tblADusers
  Inner Join (Select tblADMembership.ChildAdObjectID,
      STRING_AGG(tblADGroups.Name, '; ') As ADGroups
    From tblADMembership
      Inner Join tblADGroups On tblADGroups.ADObjectID =
          tblADMembership.ParentAdObjectID
    Group By tblADMembership.ChildAdObjectID) GroupList On
      GroupList.ChildAdObjectID = tblADusers.ADObjectID
Where tblADusers.ExpirationDate > GetDate()  And
  tblADusers.ExpirationDate < DateAdd(d, 7, GetDate()) And
  tblADusers.IsEnabled = 1
Order By tblADusers.ExpirationDate
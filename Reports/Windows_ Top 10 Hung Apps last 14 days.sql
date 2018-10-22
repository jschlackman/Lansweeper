/*
	Windows: Top 10 Hung Apps last 14 days
	
	Summary of which applications have hung most frequently as recorded in the Event log.

*/

Select Top (10) tblHang.HungApp,
  Count(tblHang.TimeGenerated) As HangCount
From (Select SubString(tblNtlogMessage.Message, 13, CharIndex(' version ',
        tblNtlogMessage.Message) - 13) As HungApp,
        tblNtlog.TimeGenerated
      From tblNtlog
        Inner Join tblNtlogFile On tblNtlog.LogfileID = tblNtlogFile.LogfileID
        Inner Join tblNtlogMessage On
          tblNtlog.MessageID = tblNtlogMessage.MessageID
        Inner Join tblNtlogSource On tblNtlog.SourcenameID =
          tblNtlogSource.SourcenameID
      Where tblNtlog.TimeGenerated > DateAdd(day, -14, GetDate()) And
        tblNtlogSource.Sourcename = N'Application Hang') As tblHang
Group By tblHang.HungApp
Order By HangCount Desc
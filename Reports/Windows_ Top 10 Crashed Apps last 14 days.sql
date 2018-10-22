/*
	Windows: Top 10 Crashed Apps last 14 days
	
	Summary of which applications have crashed most frequently as recorded in the Event log.

*/

Select Top (10) tblCrash.CrashedApp,
  Count(tblCrash.TimeGenerated) As CrashCount
From (Select SubString(tblNtlogMessage.Message, 28, CharIndex(',',
        tblNtlogMessage.Message) - 28) As CrashedApp,
        tblNtlog.TimeGenerated
      From tblNtlog
        Inner Join tblNtlogFile On tblNtlog.LogfileID = tblNtlogFile.LogfileID
        Inner Join tblNtlogMessage On
          tblNtlog.MessageID = tblNtlogMessage.MessageID
        Inner Join tblNtlogSource On tblNtlog.SourcenameID =
          tblNtlogSource.SourcenameID
      Where tblNtlog.TimeGenerated > DateAdd(day, -14, GetDate()) And
        tblNtlogSource.Sourcename = N'Application Error') As tblCrash
Group By tblCrash.CrashedApp
Order By CrashCount Desc
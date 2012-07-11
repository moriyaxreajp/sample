'-----------------------------------------------------------
' NTP の設定をするよ
' Vista以降では明示的に管理者として実行させる
'-----------------------------------------------------------

Dim NTPserver
NTPserver = "ntp.jst.mfeed.ad.jp"

'----
'OS判別
'----

Dim objWMI, osInfo
Set objWMI = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set osInfo = objWMI.ExecQuery("SELECT * FROM Win32_OperatingSystem")

Dim flag
flag = False

For each os In osInfo
	If Left(os.Version, 3) >= 6.0 Then
		flag = True
	End If
Next

'----
'実行
'----

Dim objShell
Set objShell=CreateObject("Shell.Application") 

Dim fileName,fileNameXP
Dim dispreg

fileName   = "w32tm /config /update /manualpeerlist:" & NTPserver & " /syncfromflags:manual & sc config w32time start= delayed-auto & net start w32time & w32tm /resync"
fileNameXP = "w32tm /config /update /manualpeerlist:" & NTPserver & " /syncfromflags:manual & sc config w32time start= auto         & net start w32time & w32tm /resync"

dispreg = "& reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers /v 0 /t REG_SZ /d " & NTPserver & " /f & reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers /t REG_SZ /d 0 /f"

If flag Then ' Vista or later 管理者権限実行
	objShell.ShellExecute "cmd.exe", "/q /c """ & fileName   & dispreg & """","","runas",0
Else ' XP 通常実行
	objShell.ShellExecute "cmd.exe", "/q /c """ & fileNameXP & dispreg & """","","",0
End If


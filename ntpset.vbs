'-----------------------------------------------------------
' NTP �̐ݒ�������
' Vista�ȍ~�ł͖����I�ɊǗ��҂Ƃ��Ď��s������
'-----------------------------------------------------------

Dim NTPserver
NTPserver = "ntp.jst.mfeed.ad.jp"

'----
'OS����
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
'���s
'----

Dim objShell
Set objShell=CreateObject("Shell.Application") 

Dim fileName,fileNameXP
Dim dispreg

fileName   = "w32tm /config /update /manualpeerlist:" & NTPserver & " /syncfromflags:manual & sc config w32time start= delayed-auto & net start w32time & w32tm /resync"
fileNameXP = "w32tm /config /update /manualpeerlist:" & NTPserver & " /syncfromflags:manual & sc config w32time start= auto         & net start w32time & w32tm /resync"

dispreg = "& reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers /v 0 /t REG_SZ /d " & NTPserver & " /f & reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers /t REG_SZ /d 0 /f"

If flag Then ' Vista or later �Ǘ��Ҍ������s
	objShell.ShellExecute "cmd.exe", "/q /c """ & fileName   & dispreg & """","","runas",0
Else ' XP �ʏ���s
	objShell.ShellExecute "cmd.exe", "/q /c """ & fileNameXP & dispreg & """","","",0
End If


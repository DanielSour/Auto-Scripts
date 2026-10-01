Set WShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' Get script directory and paths
scriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)
scriptPath = WScript.ScriptFullName

' Register for startup (runs once and stays registered)
On Error Resume Next
WShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\AppMonitorChain", "wscript.exe """ & scriptPath & """", "REG_SZ"
On Error GoTo 0

' Helper function to launch a command with a built-in retry safeguard
Sub SafeLaunch(command, windowStyle)
    Dim success, attempt
    success = False
    attempt = 1
    
    Do While Not success And attempt <= 2
        On Error Resume Next
        WShell.Run command, windowStyle, False
        
        If Err.Number = 0 Then
            success = True
        Else
            WScript.Sleep 3000
            attempt = attempt + 1
        End If
        On Error GoTo 0
    Loop
End Sub

' ==========================================
' STARTUP DELAY: Wait 3 seconds (3,000 ms)
' ==========================================
WScript.Sleep 3000

' 1. Launch Script 2 (tb_s_m.bat) - Hidden
batchCommand = chr(34) & scriptDir & "\tb_s_m.bat" & chr(34)
SafeLaunch batchCommand, 0

WScript.Sleep 2000

' 2. Launch tb_AutoShutdown.ps1 - Hidden
psCommand = "powershell.exe -ExecutionPolicy Bypass -File """ & scriptDir & "\tb_AutoShutdown.ps1"""
SafeLaunch psCommand, 0

WScript.Sleep 1000

' 3. Launch tb_FolderGuard.ps1 - Hidden
guardCommand = "powershell.exe -ExecutionPolicy Bypass -File """ & scriptDir & "\tb_FolderGuard.ps1"""
SafeLaunch guardCommand, 0

WScript.Sleep 1000

' 4. Launch the Watchdog timer script (tb_Watchdog.bat) - Hidden
watchdogCommand = chr(34) & scriptDir & "\tb_Watchdog.bat" & chr(34)
SafeLaunch watchdogCommand, 0

Set FSO = Nothing
Set WShell = Nothing
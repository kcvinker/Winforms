@echo off
set wrkdir="E:/OneDrive Folder/OneDrive/Programming/Odin/Winforms"
set conemu=E:\cmder\vendor\conemu-maximus5\ConEmu64.exe
start /D %wrkdir% %conemu% -run odin check app.odin -file
exit
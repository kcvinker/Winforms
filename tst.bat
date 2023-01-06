@echo off
set wdir="E:/OneDrive Folder/OneDrive/Programming/Odin/Winforms"
set conemu=E:\cmder\vendor\conemu-maximus5\ConEmu64.exe
start /D %wdir% /b %conemu% -run odin run app.odin -file
exit
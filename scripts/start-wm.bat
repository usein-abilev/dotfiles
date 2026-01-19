@echo off
komorebic start --whkd
timeout /t 2 /nobreak >nul
start /B yasb

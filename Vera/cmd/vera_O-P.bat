Rem 	Name: vera_O-P_$C.cmd
Rem  Daten:   Steuer; Arzt; Banken;  usw. 
Rem Laufwerk O
Rem   UND
Rem  Daten:  Passwörter 
Rem Laufwerk P
@echo off
set Passwort=!Airbus-is-ne-Nuss!
set /p LW=Bitte Laufwerksbuchstaben eingeben (Standard=C): 
REM Prüfen, ob Eingabe leer ist
if "%LW%"=="" set "LW=C"
Rem dir %LW%:
"C:\Program Files\VeraCrypt\VeraCrypt.exe" /v %LW%:\Start_PW\_PW.hc /l P /a /p %Passwort% /q /e /m rm
@echo on
pause

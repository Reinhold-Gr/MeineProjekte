Rem 	Name: vera_P2-Q.cmd
Rem  Daten:   Steuer; Arzt; Banken;  usw. 
Rem Laufwerk O
Rem   UND
Rem  Daten:  Passwörter 
Rem Laufwerk Q
@echo off
set Passwort=!Airbus-is-ne-Nuss!
set /p LW=Bitte Laufwerksbuchstaben eingeben (Standard=E): 
REM Prüfen, ob Eingabe leer ist
if "%LW%"=="" set "LW=E"
Rem dir %LW%:
"C:\Program Files\VeraCrypt\VeraCrypt.exe" /v %LW%:\Start_PW\_PW.hc /l Q /a /p %Passwort% /q /e /m rm
@echo on
pause
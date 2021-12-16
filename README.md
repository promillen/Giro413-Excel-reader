# Giro413-Excel-reader
Processing application for reading team scores from an Excel sheet (must be in .xls-format and not .xlsx), and playing the winning teams song.

- *For source code:* download data, Giro143_excel_reader and waveform.pde and open in Processing 4.x
- *For exported app (ready to use):* download application.windows folder *for using exported version install java open JDK https://adoptopenjdk.net, or export application with Java using Processing

## Setup
1. First set the number of teams between 2-99.
   - Make sure that the number of mp3 files in the data folder matches the number of set teams.
   - Naming convention: teamx.mp3 
2. Set the number of entries between 1-99
   - The number of entries in the Excel sheet must match the number of set entries, and the corrensponding cell must contain a number
3. Set whether or not there should be an alarm with a fixed time interval 
4. If alarm is enabled, select time interval for the alarm 
5. If happy with setup, hit enter to start application.

## Use
The program will read the score from the Excel sheet Pointscore.xls every second. If a new team is in lead, it will play the teams corresponding song.
It's important to remember to save the Excel sheet every time its updated, or else nothing will happen.

If alarm is enabled, a second window will show up after setup with a timer. When the timer hits 0, an alarm will play for approximately 30 seconds, after which the program will continue and the timer will restart.

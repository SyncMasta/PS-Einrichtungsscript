# PS-Einrichtungsscript
PowerShell Script zur Automatisierten Einrichtung Windows-Clients.

Einrichtungsscript mit folgenden Schritten

* Ändern: Kennwort d. lokalen Administrator läuft nicht ab
* WindowsUpdate Installation über PS-WindowsUpdate
* aktivieren von
  * RDP
  * SMB
  * .NET 3.5
* Windows Key Import und Aktivierung
* Aktivieren von Power-Einstellung Höchstleistung
* Anpassung Netzwerk-Einstellung
* Einbindung in Windows AD inkl. Namensänderung

Ideal in Zusammenhang mit Installtion von Windows im unattended-Mode.

## Hinweise / Aufbau 
Das Script gliedert sich in 2 Schritten (Dateien) auf. 
Die 1. Datei (1 Enable Powershell.txt) beinhaltet einen PowerShell Befehl, welcher einmalig am Client vor der Ausführung des eigentlichen Scriptes ausgeführt werden muss. Der PowerShell aktiviert das Ausführen von .... . 
Die 2. Datei beinhaltet das eigentliche Script.
Beide Dateien haben keine prozedualen oder sonstige Verbindungen. Dadurch können beide Dateinamen an die jeweiligen Gegebenheiten angepasst werden.

Das Script sollte auf einem Windows-Installationsmedium in oberster Datei-Ebene ausgeführt werden. Sollte es an anderer Stelle gespeichert werden, muss das Script im Bereich von .Net-Installation angepasst werden.

### Anpassungen an eigene Gegebenheiten
Um die Möglichkeiten der Netzwerkanpassung oder AD-Join nutzen zu können, muss das Script an diversen Stellen in den jeweiligen Bereichen angepasst werden.
Als nächster Schritt ruft man die 2. Datei (2_AfterInstallScript.ps1) auf und folgend den Anweisungen.

### Ausführung
1. Entpacken des .zip-Archivs
2. Erstellen eines Ordners "wsuslogs". Dieses Ordner wird für die Protokoll-Dateien der WindowsUpdates benötigt.
3. Ausführen des PowerShell Befehls, welches in Datei (1 Enable Powershell.txt) steht.
4. Ausführen des PowerShell Scripts (2_AfterInstallScript.ps1).



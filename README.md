# PS-Einrichtungsscript
PowerShell Script zur Automatisierten Einrichtung Windows-Clients.

Einrichtungsscript mit folgenden Schritten

Ändern: Kennwort d. lokalen Administrator läuft nicht ab
- WindowsUpdate Installation über PS-WindowsUpdate
- aktivieren von
-- RDP
-- SMB
-- .NET 3.5
-- SMB
- Windows Key Import und Aktivierung
- Aktivieren von Power-Einstellung Höchstleistung
- Anpassung Netzwerk-Einstellung
- Einbindung in Windows AD inkl. Namensänderung

Ideal in Zusammenhang mit Installtion von Windows im unattended-Mode.

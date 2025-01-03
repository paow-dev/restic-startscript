# Restic-Startscript

## Übersicht

Dieses Bash-Skript hilft dabei, **Restic** effektiv zu nutzen, um Backups von Dateien und Verzeichnissen zu erstellen. Es bietet Funktionen zur Initialisierung eines Repositories, Durchführung von Backups, Überprüfung der Integrität des Repositories sowie Planung automatisierter Backups über Cron-Jobs.

## Anforderungen

- Bash
- Restic (Download unter [restic/restic](https://github.com/restic/restic))

## Einrichtung

1. Klone das Repository:

   ```bash
   git clone <REPOSITORY_URL>
   cd <REPOSITORY_DIRECTORY>
   ```

2. Stelle sicher, dass du Restic installiert hast und der Pfad korrekt gesetzt ist.

3. Führe das Skript mit dem Argument `init` aus, um ein neues Repository zu initialisieren:

   ```bash
   ./backup_script.sh init
   ```
   
4. Folge den Anweisungen im Terminal, um den Repository-Pfad und das Verschlüsselungspasswort festzulegen.

## Verwendung

Die Verwendung erfolgt durch die Angabe eines Befehls als Argument beim Ausführen des Skripts. Die verfügbaren Befehle sind:

- **init**: Initialisiere das Repository.
- **backup**: Starte den Backup-Prozess.
- **check**: Überprüfe das Repository auf Fehler.
- **cronjob**: Richten Sie einen wiederkehrenden Cron-Job ein.
- **mount**: Mounten Sie das Repository lokal.
- **showstats**: Zeige Statistiken über das Backup an.
- **showsnapshots**: Listet alle Snapshots im Repository auf.
- **help**: Diese Hilfe anzeigen.

### Beispiel für ein Backup

Um ein Backup zu starten, verwende den folgenden Befehl:

```bash
./backup_script.sh backup
```

Das Skript verwendet die Konfigurationsdateien `restic-exclude.txt` und `restic-files.txt`, um zu bestimmen, welche Dateien ausgeschlossen bzw. gesichert werden sollen.

### Cron-Job einrichten

Um regelmäßige Backups automatisch zu planen, kannst du einen Cron-Job einrichten:

```bash
./backup_script.sh cronjob
```

Dieser Befehl fügt einen Cron-Job hinzu, der jeden Tag um 02:00 Uhr ein Backup ausführt.

## Hinweis

Stelle sicher, dass du die richtigen Berechtigungen hast, um auf das Repository zuzugreifen und Änderungen vorzunehmen. 

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Weitere Informationen findest du in der `LICENSE`-Datei.

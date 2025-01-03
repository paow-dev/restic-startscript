#!/bin/bash

cd $(dirname $0)

# Pfad zur Konfigurationsdatei
CONFIG_FILE="restic.conf"
EXCLUDE_FILE="restic-exclude.txt"
FILES_FROM_FILE="restic-files.txt"

function find_restic() {
    load_config

    # Prüfen, ob 'restic' im PATH gefunden wird oder unter RESTIC_PATH
    if command -v restic &> /dev/null && [[ -x "$(command -v restic)" ]]; then
        RESTIC_PATH="$(command -v restic)"
        echo "Restic gefunden unter: $RESTIC_PATH"
        echo "Restic-Pfad wurde in $CONFIG_FILE gespeichert."
    elif [[ -n "$RESTIC_PATH" && -x "$RESTIC_PATH" ]]; then
        echo "Restic gefunden unter konfiguriertem Pfad: $RESTIC_PATH"
    else
        # Benutzer zur Eingabe des Pfads auffordern
        echo "Restic wurde nicht gefunden. Bitte geben Sie den vollständigen Pfad zur Restic-Binärdatei ein:"
        while true; do
            read -r RESTIC_PATH
            
            # Überprüfen, ob der eingegebene Pfad ausführbar ist
            if [[ -x "$RESTIC_PATH" ]]; then
                echo "Restic wurde unter dem angegebenen Pfad gefunden: $RESTIC_PATH"
                
                # Schreiben des Restic-Pfads in die Konfigurationsdatei
                if [ -w "$CONFIG_FILE" ]; then
                    echo "RESTIC_PATH=\"$RESTIC_PATH\"" >> "$CONFIG_FILE"
                    echo "Restic-Pfad wurde in $CONFIG_FILE gespeichert."
                else
                    echo "Fehler: Konfigurationsdatei $CONFIG_FILE ist nicht beschreibbar."
                    exit 1
                fi
                break
            else
                echo "Ungültiger Pfad oder keine Berechtigung zum Ausführen von Restic. Bitte versuchen Sie es erneut:"
                exit 1
            fi
        done
    fi
}


function load_config() {
    # Überprüfen, ob die Hauptkonfigurationsdatei existiert
    if [ ! -f "$CONFIG_FILE" ]; then
        # Fehlermeldung ausgeben, wenn die Datei nicht gefunden wird
        echo "Konfigurationsdatei $CONFIG_FILE nicht gefunden. Bitte führen Sie init aus."
        # Skript mit Fehlercode 1 beenden
        exit 1
    fi

    # Einbinden der Konfigurationsdatei in das aktuelle Skript
    source ./$CONFIG_FILE
    
    # Bestätigungsausgabe, dass die Konfigurationsdatei erfolgreich geladen wurde
    echo "Konfigurationsdatei $CONFIG_FILE erfolgreich geladen."
}



# Hilfsfunktion, um verfügbare Befehle zu zeigen
function show_help() {
    echo ""
    echo "Dieses Skript soll dir dabei helfen, Restic effektiver zu nutzen."
    echo "Restic kannst du hier herunterladen:"
    echo "https://github.com/restic/restic"
    echo ""
    echo "Verwendung: $(basename $0) <Befehl>"
    echo ""
    echo "Befehle:"
    echo "  init            Initialisiere das Repository"
    echo "                  Dieser Befehl erstellt ein neues Restic-Repository."
    echo "                  Sie werden aufgefordert, den Pfad zum Repository sowie ein"
    echo "                  Verschlüsselungspasswort einzugeben."
    
    echo ""
    echo "  backup          Backup starten"
    echo "                  Startet den Backup-Prozess für Ihre Dateien im angegebenen"
    echo "                  Repository. Stellt sicher, dass alle neuen und geänderten"
    echo "                  Dateien gesichert werden."

    echo ""
    echo "  check           Repository auf Fehler prüfen"
    echo "                  Überprüft die Integrität des Repositories und stellt sicher,"
    echo "                  dass die gesicherten Daten korrekt sind. Dies hilft bei der"
    echo "                  frühzeitigen Erkennung von Problemen."
    
    echo ""
    echo "  cronjob         Richten Sie einen wiederkehrenden Cron-Job ein"
    echo "                  Ermöglicht es Ihnen, regelmäßige Backups automatisch zu planen,"
    echo "                  indem Sie einen Cron-Job erstellen. Sie können Intervalle und"
    echo "                  andere Optionen angeben."
    
    echo ""
    echo "  mount           Mounten Sie das Repository lokal"
    echo "                  Mountet Ihr Backup-Repository als Verzeichnis in das"
    echo "                  Dateisystem. Dadurch können Sie auf die gesicherten Dateien"
    echo "                  zugreifen, als wären sie normal vorhanden."

    echo ""
    echo "  stats           Zeigt Statistiken über das Backup an"
    echo "                  Gibt Ihnen einen Überblick über die letzten Backups, einschließlich"
    echo "                  Informationen zur Größe, Anzahl der gesicherten Dateien und"
    echo "                  weiteren wichtigen Statistiken."

    echo ""
    echo "  snapshots       Listet alle Snapshots im Repository auf"
    echo "                  Zeigt eine Liste aller Snapshots, die im Repository gespeichert"
    echo "                  sind, zusammen mit ihren Erstellungsdaten und IDs."
    
    echo ""
    echo "  help            Diese Hilfe anzeigen"
    echo "                  Zeigt diese Hilfeseite an und gibt eine Übersicht über alle"
    echo "                  verfügbaren Befehle."
    
    echo ""
    echo "Hinweis: Stellen Sie sicher, dass Sie die richtigen Berechtigungen haben, um"
    echo "auf das Repository zuzugreifen und Änderungen vorzunehmen."
}

# Funktion zum Initialisieren eines neuen Repositories
function init_repo() {
    echo ""
    echo "Bitte wählen Sie, wo die Dateien gespeichert werden sollen:"
    echo "1) Local"
    echo "2) SFTP"
    echo "3) REST Server"
    echo "4) S3 compatible storage providers"
    read -p "Ihre Auswahl (1-4): " storage_option

    case $storage_option in
        1)
            echo "Bitte geben Sie den lokalen Repository-Pfad ein:"
            echo "(/srv/restic-repo)"
            read -p "" repo_path
            ;;
        2)
            echo "Bitte geben Sie den SFTP-Pfad ein:"
            echo "(sftp://user@host//srv/folder/)"
            read -p "" repo_path
            ;;
        3)
            echo "Bitte geben Sie den REST Server URL ein:"
            echo "(rest:user:pass@host:8000/my_backup_repo/)"
            read -p "" repo_path

            echo "Bitte geben Sie Ihren RESTIC_REST_USERNAME ein:"
            read -p "" restic_rest_username

            echo "Bitte geben Sie Ihren RESTIC_REST_PASSWORD ein:"
            read -p "" restic_rest_password
            ;;
        4)
            echo "Bitte geben Sie die S3-kompatible URL ein:"
            echo "(s3:https://server:port/bucket_name)"
            read -p "" repo_path
            echo ""
            echo "Bitte geben Sie die AWS_ACCESS_KEY_ID ein."
            read -p "" aws_access_key_id
            echo ""
            echo "Bitte geben Sie die AWS_SECRET_ACCESS_KEY ein."
            read -p "" aws_secret_access_key
            ;;
        *)
            echo "Ungültige Option!"
            return 1
            ;;
    esac

    echo "Bitte geben Sie das Verschlüsselungspasswort für das Repository ein:"
    read -sp "" password
    echo

    if [[ -z "$password" ]]; then
        echo "Fehler: Das Passwort darf nicht leer sein."
        return 1
    fi

    read -p "Möchten Sie das Passwort in der Konfigurationsdatei speichern? (y/n): " save_password
    echo

    echo "export RESTIC_REPOSITORY=\"$repo_path\"" > "$CONFIG_FILE"
    echo "export AWS_ACCESS_KEY_ID=\"$aws_access_key_id\"" >> "$CONFIG_FILE"
    echo "export AWS_SECRET_ACCESS_KEY=\"$aws_secret_access_key\"" >> "$CONFIG_FILE"
    echo "export RESTIC_REST_USERNAME=\"$restic_rest_username\"" >> "$CONFIG_FILE"
    echo "export RESTIC_REST_PASSWORD=\"$restic_rest_password\"" >> "$CONFIG_FILE"
    echo "RESTIC_PATH=\"$RESTIC_PATH\"" >> "$CONFIG_FILE"

    if [[ "$save_password" =~ ^[yYjJ]$ ]]; then
        echo "export RESTIC_PASSWORD=\"$password\"" >> "$CONFIG_FILE"
        
        echo "Repo Passwort in Konfigurationsdatei geschrieben."
    else
        echo "Das Passwort wird nicht gespeichert."
    fi

    /usr/bin/touch "$EXCLUDE_FILE"
    /usr/bin/touch "$FILES_FROM_FILE"
    echo "Die Dateien '$EXCLUDE_FILE' und '$FILES_FROM_FILE' wurden erstellt."
    echo "Listen sie alle Ordner auf, die vom Backup berücksichtigt werden soll, in die Datei $FILES_FROM_FILE"
    echo "Ausnahmen davon tragen Sie bitte in die $EXCLUDE_FILE."

    find_restic
    $RESTIC_PATH init --repo "$repo_path" --password-file <(echo "$password") -o s3.unsafe-anonymous-auth=true
    echo "Repository initialisiert."
}

# Funktion für Backup
function backup_repo() {
    load_config
    sources=("$@")
    echo "Backup gestartet für Quellen: ${sources[*]}"

    # Führt das Backup mit den angegebenen Dateien/Verzeichnissen durch
    $RESTIC_PATH backup --files-from "$FILES_FROM_FILE" --exclude-file "$EXCLUDE_FILE"
    echo "Backup abgeschlossen."
}

# Funktion zum Prüfen des Repositories
function check_repo() {
    load_config
    $RESTIC_PATH check
    echo "Repository-Prüfung abgeschlossen."
}

# Cron-Job für automatisiertes Backup
function setup_cronjob() {
    load_config

    # Abfrage des Cronjobs vom Benutzer
    echo "Bitte geben Sie den Cron-Job ein:"
    echo "(0 2 * * * für täglich 2 Uhr)"
    read -p "" cronjob

    echo "Erstellung eines Cron-Jobs für automatisiertes Backup."

    # Überprüfen, ob der Cronjob bereits existiert
    if crontab -l 2>/dev/null | grep -Fxq "$cronjob"; then
        read -p "Der Cronjob existiert bereits. Möchten Sie ihn ersetzen? (j/n): " choice
        case "$choice" in
            j|J ) 
                # Cronjob ersetzen
                (crontab -l 2>/dev/null | grep -vFx "$cronjob"; echo "$cronjob") | crontab -
                echo "Cron-Job ersetzt."
                ;;
            n|N )
                echo "Kein neuer Cron-Job erstellt."
                ;;
            * )
                echo "Ungültige Eingabe. Kein neuer Cron-Job erstellt."
                ;;
        esac
    else
        # Cronjob hinzufügen
        (crontab -l 2>/dev/null; echo "$cronjob") | crontab -
        echo "Cron-Job hinzugefügt."
    fi
}


# Funktion zum Mounten des Repositories
function mount_repo() {
    load_config

    mount_point="$1"

    # Prüfen, ob das Verzeichnis erreichbar ist
    if [ ! -d "$mount_point" ]; then
        echo "Verzeichnis $mount_point existiert nicht. Erstelle es..."
        mkdir -p "$mount_point"

        # Überprüfen, ob die Erstellung erfolgreich war
        if [ $? -ne 0 ]; then
            echo "Fehler: Das Verzeichnis $mount_point konnte nicht erstellt werden."
            exit 1
        fi
        echo "Verzeichnis $mount_point wurde erfolgreich erstellt."
    else
        echo "Verzeichnis $mount_point ist bereits vorhanden."
    fi

    # Repository mounten
    if $RESTIC_PATH mount "$mount_point"; then
        echo "Repository erfolgreich gemountet unter: $mount_point"
    else
        echo "Fehler beim Mounten des Repositories unter: $mount_point"
        exit 1
    fi
}


# Funktion zur Anzeige von Statistiken
function stats() {
    load_config 

    $RESTIC_PATH stats -r $RESTIC_REPOSITORY
    echo "Backup-Statistiken angezeigt."
}

# Funktion zur Auflistung von Snapshots
function snapshots() {
    load_config
    $RESTIC_PATH snapshots -r $RESTIC_REPOSITORY
    echo "Alle Repository-Snapshots aufgelistet."
}

# Überprüfen des ersten Arguments und entsprechende Funktion aufrufen
if [[ -z "$1" ]]; then
    show_help
    exit 0
fi

case "$1" in
    init)
        init_repo
        ;;
    backup)
        shift
        backup_repo "$@"
        ;;
    check)
        check_repo
        ;;
    cronjob)
        shift
        setup_cronjob "$@"
        ;;
    mount)
        shift
        mount_repo "$@"
        ;;
    stats)
        stats
        ;;
    snapshots)
        snapshots
        ;;
    help)
        show_help
        ;;
    *)
        show_help
        ;;
esac

#!/bin/bash
# Lädt <app>/dist/*.jad + *.jar per Bluetooth (gammu) auf die Speicherkarte des 6303i
# und liest sie zur Kontrolle zurück. Aufruf: ./hochladen.sh signal|homeassistant|standort
# Die App muss am Handy beendet sein, Bluetooth an.
# gammus Schlussmeldung „Datei existiert nicht“ ist falsch, entscheidend ist die Kontrolle.
set -e
cd "$(dirname "$0")"
APP=${1:?Aufruf: ./hochladen.sh signal|homeassistant|standort}
RC=privat/gammu-bluetooth.rc
HANDY=$(sed -n 's/^device *= *//p' $RC)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Ein kurzes Verbinden weckt das Handy auf, sonst antwortet gammu oft nicht.
timeout 20 bluetoothctl connect "$HANDY" >/dev/null 2>&1 || true
timeout 15 bluetoothctl disconnect "$HANDY" >/dev/null 2>&1 || true

for f in "$APP"/dist/*.jad "$APP"/dist/*.jar; do
    echo "lade $(basename "$f") …"
    (cd "$(dirname "$f")" && timeout 150 gammu -c "$OLDPWD/$RC" addfile a:/ "$(basename "$f")" >/dev/null 2>&1) || true
    (cd "$TMP" && timeout 150 gammu -c "$OLDPWD/$RC" getfiles "a:/$(basename "$f")" >/dev/null 2>&1) || true
    if cmp -s "$f" "$TMP/$(basename "$f")"; then
        echo "  ok, auf der Karte identisch"
    else
        echo "  FEHLER: nicht (vollständig) auf der Karte" >&2
        exit 1
    fi
done

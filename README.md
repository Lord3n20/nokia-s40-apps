# nokia-s40-apps

Drei kleine Java-ME-Apps (CLDC 1.1 / MIDP 2.0) für ein Nokia 6303i classic (Series 40), die über
eine eigene Brücke in Home Assistant mit der heutigen Welt reden. Die Brücken liegen im Repo
[Lord3n20/server-homeassistant](https://github.com/Lord3n20/server-homeassistant).

| App | Ordner | Brücke | Was |
|---|---|---|---|
| 1 Signal | `signal/` | `nokia-signal-app` | Signal lesen und schreiben, Bilder ansehen und senden, Fotos mit der Kamera. Verschlüsselt (ChaCha20 + HMAC), weil das Handy kein modernes TLS kann. |
| 2 Home Assistant | `homeassistant/` | `nokia-bridge-app` | Ein Dashboard aus Home Assistant als Text und kleine Graphen. |
| 3 Standort | `standort/` | – | Test, was das Handy einer Java-App über Funkzelle und Standort verrät. Beim 6303i: nichts Brauchbares. |

## Bauen

Gebraucht werden Java, `jar`, `openssl`, `curl` und die MIDP/CLDC-Bibliotheken von
[MicroEmulator](https://github.com/barteo/microemu) (unter Arch: AUR-Paket `microemulator`; anderer
Ort per `MICROEMU_LIB=/pfad/zu/lib`). Der Compiler (ecj 4.5.1) wird beim ersten Bauen von Maven
Central geladen und per SHA-256 geprüft.

    signal/build.sh          # → signal/dist/Signal.jad + Signal.jar
    homeassistant/build.sh
    standort/build.sh

`ecj -target cldc1.1` erzeugt Klassen mit StackMap, ein `preverify` ist nicht nötig.

## Eigene Daten: `privat/`

Alles Persönliche liegt in `privat/` und ist per `.gitignore` ausgeschlossen:

| Datei | Wofür |
|---|---|
| `signal-adresse.txt`, `signal-schluessel.txt` | Adresse und Schlüssel der Signal-Brücke, werden als `SG-Url` / `SG-Key` eingebaut |
| `homeassistant-adresse.txt`, `homeassistant-schluessel.txt` | dasselbe für die HA-Brücke (`HA-Url` / `HA-Key`) |
| `zertifikat/zertifikat.pem`, `zertifikat/schluessel.pem` | eigenes Zertifikat zum Signieren (optional) |
| `gammu-bluetooth.rc` | gammu-Einstellungen fürs Hochladen, Vorlage in `werkzeuge/gammu-bluetooth.rc.beispiel` |

Ohne diese Dateien bauen die Apps trotzdem; Adresse und Schlüssel tippt man dann am Handy in den
Einstellungen ein, und die Apps sind unsigniert.

## Aufs Handy

    ./hochladen.sh signal     # per Bluetooth über gammu, liest zur Kontrolle zurück

App am Handy vorher beenden. gammus Schlussmeldung „Datei existiert nicht“ ist beim 6303i falsch.
Ohne Bluetooth: Handy per USB als Massenspeicher anschließen und `<app>/COPY.sh`.
Signierte Apps brauchen `.jad` und `.jar` zusammen auf der Karte; nach jedem Bauen beide neu kopieren.

## Signieren und was das 6303i erlaubt

Unsignierte Apps fragen bei jedem Netzzugriff nach. Mit einem eigenen Zertifikat lässt sich das
abstellen: Das Zertifikat (DER) kommt in den Ordner `d:/predefhiddenfolder/certificates/user` des
Handys, und der zugehörige Eintrag in `ext_info.sys` muss die Verwendung „Code-Signierung“
enthalten (OID 1.3.6.1.5.5.7.3.3). Danach vertraut das Handy Apps, die mit diesem Zertifikat
signiert sind.

Grenzen, die auch mit Signatur bleiben:

- Java-Apps laufen nicht im Hintergrund; `Nokia-MIDlet-No-Exit` wird ignoriert.
- Autostart (PushRegistry-Wecker) und Netzzugriff dürfen nicht beide auf „immer erlaubt“ stehen
  (MIDP-2-Sicherheitsregel), eine Abfrage bleibt also beim Wecken immer sichtbar.
- Kein Zugriff auf Anrufliste, Funkzelle oder Standort.

Für Benachrichtigungen ruft die Signal-Brücke deshalb bei neuen Nachrichten kurz über SIP an
(z. B. über ein IP-Telefon der FritzBox) und legt wieder auf.

## Lizenz

Gemeinfrei ([Unlicense](LICENSE)): Mach damit, was du willst.

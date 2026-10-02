#!/bin/bash
# Baut dist/Signal.jar + .jad (signiert, falls ../privat/zertifikat/ da ist).
# Braucht zusätzlich JSR-75 (Dateien), JSR-135 (Kamera) und die Nokia-UI-API (Licht, Vibration).
#
# Signieren: Das 6303i vertraut dem eigenen Zertifikat, weil es im Zertifikatsordner
# d:/predefhiddenfolder/certificates/user liegt und dessen ext_info.sys ihm Code-Signierung
# erlaubt (siehe README). Nur Rechte, die hier stehen, bekommt die App.
cd "$(dirname "$0")"
source ../werkzeuge/bauen.sh
bauen Signal SG ":$L/microemu-jsr-75.jar:$L/microemu-jsr-135.jar:$L/microemu-nokiaui.jar" \
"MIDlet-Permissions: javax.microedition.io.Connector.http, javax.microedition.io.Connector.file.read, javax.microedition.media.control.VideoControl.getSnapshot
MIDlet-Permissions-Opt: javax.microedition.io.PushRegistry" ja

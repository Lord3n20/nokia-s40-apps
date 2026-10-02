#!/bin/bash
# Baut dist/Standort.jar + .jad (signiert, falls ../privat/zertifikat/ da ist).
# JSR-179 nur gegen leere Ersatzklassen kompiliert; das Handy bringt die echten mit.
cd "$(dirname "$0")"
source ../werkzeuge/bauen.sh
bauen Standort ST ":$(jsr179_stubs)" "MIDlet-Permissions-Opt: javax.microedition.location.Location" ja

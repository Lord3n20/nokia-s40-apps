#!/bin/bash
# Baut dist/HomeAssistant.jar + .jad (unsigniert).
cd "$(dirname "$0")"
source ../werkzeuge/bauen.sh
bauen HomeAssistant HA "" "" nein

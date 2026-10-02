# Gemeinsamer Teil der build.sh-Skripte, wird mit „source“ eingebunden.
#
# bauen NAME KÜRZEL "Zusatz-Jars" "Manifest-Zusatzzeilen" signieren(ja|nein)
#   kompiliert src/*.java (CLDC 1.1 / MIDP 2.0) und schreibt dist/NAME.jar + dist/NAME.jad.
#   Adresse und Schlüssel aus ../privat/<app>-adresse.txt und -schluessel.txt werden als
#   KÜRZEL-Url / KÜRZEL-Key eingebaut, dann muss am Handy nichts eingetippt werden.
#   Signiert wird mit ../privat/zertifikat/ (zertifikat.pem + schluessel.pem), falls vorhanden.
#
# ecj -target cldc1.1 erzeugt Klassenversion 45.3 samt StackMap, ein preverify ist nicht nötig.
# Die MIDP/CLDC-APIs kommen aus MicroEmulator (Arch: AUR-Paket microemulator).

set -e
W="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P="$W/../privat"
L=${MICROEMU_LIB:-/usr/share/java/microemulator/lib}
ECJ_URL=https://repo1.maven.org/maven2/org/eclipse/jdt/core/compiler/ecj/4.5.1/ecj-4.5.1.jar
ECJ_SHA256=19f313fb13191477e7c7e0f1142f096fef19b721979efc7f18cea81d259e7294

ecj() {
    if [ ! -s "$W/ecj.jar" ]; then
        echo "lade ecj 4.5.1 …" >&2
        curl -fsSL -o "$W/ecj.jar.tmp" "$ECJ_URL"
        echo "$ECJ_SHA256  $W/ecj.jar.tmp" | sha256sum -c --quiet -
        mv "$W/ecj.jar.tmp" "$W/ecj.jar"
    fi
    java -jar "$W/ecj.jar" "$@"
}

# Nur zum Kompilieren: leere Klassen der Standort-API (JSR-179), die MicroEmulator nicht hat.
jsr179_stubs() {
    if [ ! -s "$W/build/jsr179-stubs.jar" ]; then
        rm -rf "$W/build/jsr179" && mkdir -p "$W/build/jsr179"
        ecj -source 1.3 -target cldc1.1 -bootclasspath "$L/cldcapi11.jar" \
            -d "$W/build/jsr179" "$W"/jsr179-stubs/javax/microedition/location/*.java >&2
        jar cf "$W/build/jsr179-stubs.jar" -C "$W/build/jsr179" .
    fi
    echo "$W/build/jsr179-stubs.jar"
}

bauen() {
    local name=$1 short=$2 extra=$3 lines=$4 sign=$5
    local app
    app=$(basename "$PWD")
    rm -rf build dist && mkdir build dist
    ecj -source 1.3 -target cldc1.1 \
        -bootclasspath "$L/cldcapi11.jar:$L/midpapi20.jar$extra" \
        -d build src/*.java

    { cat src/manifest.txt
      [ -n "$lines" ] && echo "$lines"
      [ -s "$P/$app-adresse.txt" ] && echo "$short-Url: $(tr -d '[:space:]' < "$P/$app-adresse.txt")"
      [ -s "$P/$app-schluessel.txt" ] && echo "$short-Key: $(tr -d '[:space:]' < "$P/$app-schluessel.txt")"
      true
    } > dist/manifest.mf
    jar cfm "dist/$name.jar" dist/manifest.mf -C build . -C res icon.png
    { cat dist/manifest.mf
      echo "MIDlet-Jar-URL: $name.jar"
      echo "MIDlet-Jar-Size: $(stat -c %s "dist/$name.jar")"
    } > "dist/$name.jad"
    rm dist/manifest.mf

    local z="$P/zertifikat"
    if [ "$sign" = ja ] && [ -s "$z/zertifikat.pem" ] && [ -s "$z/schluessel.pem" ]; then
        echo "MIDlet-Certificate-1-1: $(openssl x509 -in "$z/zertifikat.pem" -outform DER | base64 -w0)" >> "dist/$name.jad"
        echo "MIDlet-Jar-RSA-SHA1: $(openssl dgst -sha1 -sign "$z/schluessel.pem" "dist/$name.jar" | base64 -w0)" >> "dist/$name.jad"
        echo "fertig (signiert): dist/$name.jar ($(stat -c %s "dist/$name.jar") Bytes)"
    else
        echo "fertig: dist/$name.jar ($(stat -c %s "dist/$name.jar") Bytes)"
    fi
}

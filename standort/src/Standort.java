import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.CommandListener;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Displayable;
import javax.microedition.lcdui.Form;
import javax.microedition.lcdui.StringItem;
import javax.microedition.midlet.MIDlet;

/**
 * Test: what does the 6303i tell a Java app about where it is? Shows the
 * Nokia network properties (cell, area, network) and asks the JSR-179
 * location API for a position, if the phone has one.
 */
public class Standort extends MIDlet implements CommandListener {

    /** Nokia system properties for the network; the names differ between S40 versions. */
    private static final String[] PROPS = {
        "Cell-ID", "com.nokia.mid.cellid", "CellID",
        "com.nokia.mid.lac", "LocAreaCode", "com.nokia.mid.networkid",
        "com.nokia.mid.countrycode", "com.nokia.mid.networksignal",
        "com.nokia.mid.networkavailability", "com.nokia.network.access",
        "microedition.location.version",
    };

    private final Command cmdCheck = new Command("Prüfen", Command.SCREEN, 1);
    private final Command cmdExit = new Command("Beenden", Command.EXIT, 2);
    private Display display;
    private Form form;
    private StringItem gps;

    public void startApp() {
        if (display != null) {
            return;
        }
        display = Display.getDisplay(this);
        form = new Form("Standort-Test");
        form.addCommand(cmdCheck);
        form.addCommand(cmdExit);
        form.setCommandListener(this);
        display.setCurrent(form);
        check();
    }

    public void pauseApp() {
    }

    public void destroyApp(boolean unconditional) {
    }

    public void commandAction(Command c, Displayable d) {
        if (c == cmdExit) {
            notifyDestroyed();
        } else if (c == cmdCheck) {
            check();
        }
    }

    private void check() {
        form.deleteAll();
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < PROPS.length; i++) {
            String v;
            try {
                v = System.getProperty(PROPS[i]);
            } catch (Throwable t) {
                v = "Fehler " + t;
            }
            sb.append(PROPS[i]).append(": ").append(v == null ? "-" : v).append('\n');
        }
        form.append(new StringItem("Netz", sb.toString()));
        gps = new StringItem("Position", "frage …");
        form.append(gps);
        if (System.getProperty("microedition.location.version") == null) {
            gps.setText("keine Standort-Schnittstelle");
            return;
        }
        new Thread(new Runnable() {
            public void run() {
                gps.setText(locate());
            }
        }).start();
    }

    /** Separate method, so phones without JSR-179 never load these classes. */
    private static String locate() {
        try {
            javax.microedition.location.Criteria cr = new javax.microedition.location.Criteria();
            cr.setHorizontalAccuracy(javax.microedition.location.Criteria.NO_REQUIREMENT);
            cr.setCostAllowed(true);
            cr.setPreferredPowerConsumption(javax.microedition.location.Criteria.NO_REQUIREMENT);
            javax.microedition.location.LocationProvider lp =
                    javax.microedition.location.LocationProvider.getInstance(cr);
            if (lp == null) {
                return "kein Anbieter (getInstance null)";
            }
            String state = lp.getState() == javax.microedition.location.LocationProvider.AVAILABLE
                    ? "verfügbar" : "Zustand " + lp.getState();
            javax.microedition.location.Location l = lp.getLocation(90);
            if (l == null || !l.isValid()) {
                return state + ", keine gültige Position";
            }
            javax.microedition.location.QualifiedCoordinates q = l.getQualifiedCoordinates();
            int m = l.getLocationMethod();
            String how = (m & javax.microedition.location.Location.MTE_SATELLITE) != 0 ? "Satellit"
                    : (m & javax.microedition.location.Location.MTE_CELLID) != 0 ? "Funkzelle"
                    : "Methode " + m;
            return state + "\n" + q.getLatitude() + ", " + q.getLongitude()
                    + "\n± " + (int) q.getHorizontalAccuracy() + " m (" + how + ")";
        } catch (SecurityException e) {
            return "nicht erlaubt (Recht Standort)";
        } catch (Throwable t) {
            return "Fehler: " + t;
        }
    }
}

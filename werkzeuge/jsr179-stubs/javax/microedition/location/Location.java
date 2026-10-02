package javax.microedition.location;
public class Location {
    public static final int MTE_SATELLITE = 1, MTE_CELLID = 8, MTA_ASSISTED = 262144;
    public boolean isValid() { return false; } public QualifiedCoordinates getQualifiedCoordinates() { return null; }
    public int getLocationMethod() { return 0; } public long getTimestamp() { return 0; }
}

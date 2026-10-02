package javax.microedition.location;
public abstract class LocationProvider {
    public static final int AVAILABLE = 1, TEMPORARILY_UNAVAILABLE = 2, OUT_OF_SERVICE = 3;
    public static LocationProvider getInstance(Criteria c) throws LocationException { return null; }
    public abstract Location getLocation(int timeout) throws LocationException, InterruptedException;
    public abstract int getState();
}

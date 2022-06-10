package ch.ethz.systems.netbench.xpt.ports.Pushback;

public class PushbackConstants {

    public static final int NO_BITS = 4;
    public static final int MAX_CLUSTER = 20;
    public static final int CLUSTER_LEVEL = 4;

    //make it 0 to classify on the basis of dst addresses, 1 to classify on the basis of flowid
    public static final int AGGREGATE_CLASSIFICATION_MODE_FLOWID = 1;

    //0 for the old version, 1 for the dynamic version
    public static final int LOWER_BOUND_MODE = 1;

    //maximum number of rate-limiting sessions that a congested router can start.
    public static final int MAX_SESSIONS = 3;

    //min time to release an aggregate after starting to rate-limit it.
    public static final int EARLIEST_TIME_TO_FREE = 10;

    //min time to release an aggregate after it goes below limit imposed on it.
    public static final int MIN_TIME_TO_FREE = 20;
    public static final int PRIMARY_WAITING_ZONE = 10;
    public static final int RATE_LIMIT_TIME_DEFAULT = 30;    //in seconds
    public static final int DEFAULT_BUCKET_DEPTH = 5000;          //in bytes

    public static final int PUSHBACK_REFRESH_EVENT = 2;
    public static final int INITIAL_UPDATE_EVENT = 4;

    public static final int PUSHBACK_CYCLE_TIME = 5;
    public static final double INITIAL_UPDATE_TIME = 0.5;

    public static final int SUSTAINED_CONGESTION_PERIOD = 2;      //in seconds
    public static final double SUSTAINED_CONGESTION_DROPRATE = 0.10;  //fraction
    public static final double TARGET_DROPRATE = 0.05;
}

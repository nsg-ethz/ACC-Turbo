package ch.ethz.systems.netbench.xpt.ports.RED;

public class REDParameters {

    /******************************************
     * Early drop parameters, supplied by user
     ******************************************/

    public int averagePacketSize;	/* avg pkt size, to compute the number of packets that could fit in the link during idle time */
    public boolean wait;		    /* true for waiting between dropped packets */
    public boolean gentle;		/* true to increases dropping prob. slowly when ave queue exceeds maxthresh. */
    public double th_min;		/* minimum threshold of average queue size */
    public double th_max;		/* maximum threshold of average queue size */
    public double q_weight;		    /* queue weight given to cur q size sample */

    /*
     * Computed as a function of user supplied parameters.
     */
    public double invAvgPacketTime;		/* Inverse of the average time to send a packet */

    public REDParameters() {
    }

}

package ch.ethz.systems.netbench.xpt.ports.RED;

public class REDVariables {

    public double v_ave;	    /* average queue size */
    public double v_prob1;	    /* prob. of packet drop before "count". */

    public double v_prob;	    /* prob. of packet drop */
    public double v_a;		    /* v_prob = v_a * v_ave + v_b */
    public double v_b;

    public double v_c;		    /* used for "gentle" mode */
    public double v_d;		    /* used for "gentle" mode */

    public int count;		    /* # of packets since last drop */
    public int old;		        /* 0 when average queue first exceeds thresh */
    public double cur_max_p;	//current max_p

    public REDVariables(){}

}

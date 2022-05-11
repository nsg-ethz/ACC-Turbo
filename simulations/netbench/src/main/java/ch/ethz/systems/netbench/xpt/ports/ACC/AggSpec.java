package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.ext.basic.IpHeader;

public class AggSpec {
    public int dstON;         //whether destination based pushback is ON.
    public int dstPrefix;     //destination prefix
    public int dstBits; //number of bits in the prefix;

    //other dimensions of rate-limiting go here;
    public int ptype;           //packet type, which is to be rate-limited.
    public double ptypeShare;


    public AggSpec(int dstON, int dstPrefix, int dstBits) {
        this.dstON = dstON;
        this.dstPrefix = dstPrefix;
        this.dstBits = dstBits;

        this.ptype=-1;
        this.ptypeShare=0;
    }

    boolean isMember(Packet pkt) {

        if (this.dstON == 1) {
            int prefix;
            if (ACCConstants.AGGREGATE_CLASSIFICATION_MODE_FLOWID == 1) { // Classify on the basis of the flowid
                prefix = getPrefix((int) pkt.getFlowId());
            } else {
                System.out.println("IP Address clustering not supported yet");
                System.exit(-1);
                IpHeader iph = (IpHeader) pkt;
                prefix = 0; // TODO: Replace 0 for getPrefix(iph.dst());// We don't have flowID support in netbench
            }
            if (prefix == dstPrefix) {
                return true;
            }
        }
        return false;
    }

    int getPrefix(int addr) {
        int andAgent = ((1 << dstBits) - 1) << (ACCConstants.NO_BITS - dstBits);
        return (addr &  andAgent);
    }

    boolean equals(AggSpec another) {
        if (dstON == another.dstON && dstPrefix == another.dstPrefix && dstBits == another.dstBits) {
            return true;
        } else {
            return false;
        }
    }

    int contains(AggSpec another) {

        if (another.dstBits < dstBits) return 0;
        if (dstON != another.dstON) return 0;

        int prefix1 = PrefixTree.getPrefixBits(dstPrefix, dstBits);
        int prefix2 = PrefixTree.getPrefixBits(another.dstPrefix, dstBits);

        if (prefix1 == prefix2){
            return 1;
        } else {
            return 0;
        }
    }
}

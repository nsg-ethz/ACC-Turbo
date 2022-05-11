package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.network.Packet;

public class IdentStruct {

    public PrefixTree dstTree;
    protected double lowerBound;

    public IdentStruct() {
        dstTree = new PrefixTree();
        lowerBound = 0;
    }

    // Count a new drop to the aggregate, when repported by the RED module
    void registerDrop(Packet p) {
        if (ACCConstants.AGGREGATE_CLASSIFICATION_MODE_FLOWID == 1) {
            dstTree.registerDrop((int)p.getFlowId(), (int)p.getSizeBit());
        } else {
            System.out.println("IP Address clustering not supported yet");
            System.exit(-1);
            dstTree.registerDrop(0, (int)p.getSizeBit()); // TODO: Replace 0 for p.ipdest()
        }
    }

    // Resets the drop counters
    void reset() {
        dstTree.reset();
    }

    AggReturn identifyAggregate(double estimatedArrivalRate, double linkCapacity) {
        return dstTree.identifyAggregate(estimatedArrivalRate, linkCapacity);
    }

    void setLowerBound(double bound, int averageIt) {
        double alpha = 0.5;
        if (lowerBound == 0)
            lowerBound = bound;
        else if (averageIt == 0) {
            if (bound < lowerBound)
                lowerBound = bound;
            else
                lowerBound = alpha * lowerBound + (1 - alpha) * bound;
        }
        else {
            lowerBound = alpha * lowerBound + (1 - alpha) * bound;
        }
    }

}

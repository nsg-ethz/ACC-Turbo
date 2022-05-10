package ch.ethz.systems.netbench.core.network;

import ch.ethz.systems.netbench.core.Simulator;

/**
 * The packet is the unit of transfer through the network.
 * It must be part of a flow and have a fixed size.
 */
public abstract class Packet implements PacketHeader {

    private int flowletId;
    private final long flowId;
    private final long sizeBit;
    private final long departureTime;
    private final boolean isTCP;
    private long enqueueTime;

    /**
     * Construct a fixed-size packet belonging to a particular flow.
     * The {@link #getDepartureTime() departure time} is set to the current simulator time.
     *
     * @param flowId    Flow identifier
     * @param sizeBit   Total size of the packet in bits (must be total, as it is used by the {@link Link link}).
     */
    public Packet(long flowId, long sizeBit, boolean isTCP) {
        this.flowletId = 0;
        this.flowId = flowId;
        this.sizeBit = sizeBit;
        this.departureTime = Simulator.getCurrentTime();
        this.isTCP = isTCP;
    }

    /**
     * Retrieve immutable flow identifier.
     *
     * @return  Flow identifier
     */
    @Override
    public long getFlowId() {
        return flowId;
    }

    /**
     * Retrieve the size of the packet in bits.
     *
     * @return  Total size of the packet in bits
     */
    @Override
    public long getSizeBit() {
        return sizeBit;
    }

    /**
     * Retrieve the departure time (equal to the construction time)
     * of the packet.
     *
     * @return  Departure time in ns since simulation epoch
     */
    @Override
    public long getDepartureTime() {
        return departureTime;
    }

    /**
     * Set the flowlet identifier of this packet.
     *
     * @param flowletId     Flowlet identifier to be set
     */
    @Override
    public void setFlowletId(int flowletId) {
        this.flowletId = flowletId;
    }

    /**
     * Retrieve the flowlet identifier of this packet.
     *
     * @return  Flowlet identifier
     */
    @Override
    public int getFlowletId() {
        return flowletId;
    }

    @Override
    public String toString() {
        return "Packet<" +
                    "flow #" + flowId + " (flowlet " + flowletId + ")" +
                    ", size: " + sizeBit +
                    ", departure: " + departureTime +
                ">";
    }

    public boolean isTCP() {
        return isTCP;
    }

    public long getEnqueueTime() { return enqueueTime; }

    public void setEnqueueTime(long enqueueTime) {this.enqueueTime = enqueueTime;}
}

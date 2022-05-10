package ch.ethz.systems.netbench.xpt.udp;

import ch.ethz.systems.netbench.ext.basic.IpPacket;

public class UdpPacket extends IpPacket implements UdpHeader, Comparable  {


    private static final long UDP_HEADER_SIZE_BIT = 64L;

    // Actual fields
    private final int sourcePort; // 16 bits
    private final int destinationPort; // 16 bits
    private final int length; // 16 bits
    private final long checksum; // 16 bits
    private final long dataSizeByte; // In bytes

    public UdpPacket(long flowId, long dataSizeByte,
            int sourceId, int destinationId, int TTL, // IP header fields
            int sourcePort, int destinationPort, int length, long checksum) {
        super(flowId, UDP_HEADER_SIZE_BIT + dataSizeByte * 8L, sourceId, destinationId, TTL, false);
        this.sourcePort = sourcePort;
        this.destinationPort = destinationPort;
        this.length = length;
        this.checksum = checksum;
        this.dataSizeByte = dataSizeByte;
    }

    @Override
    public long getDataSizeByte() {
        return dataSizeByte;
    }

    @Override
    public int getSourcePort() {
        return sourcePort;
    }

    @Override
    public int getDestinationPort() {
        return destinationPort;
    }

    @Override
    public int getLength() {
        return length;
    }

    @Override
    public long getChecksum() {
        return checksum;
    }

    @Override
    public String toString() {
        return "UdpPacket[" + getSourceId() + " -> " + getDestinationId() + ", DATA=" + this.getDataSizeByte() + "]";
    }


    @Override
    public int compareTo(Object o) {
        // "this" is the packet being inserted
        // "other" is the packet we're comparing to (in the queue)
        UdpPacket other = (UdpPacket) o;

        // Priority = rank
        int i = Long.compare((int)this.getFlowId(), (int)other.getFlowId());
        // If the ranks are not equal, return comparator int
        if (i != 0) return i;

        i = Long.compare((int)this.getEnqueueTime(), (int)other.getEnqueueTime());
        //System.out.println("Comparison: " + i + " other " + (int)other.getEnqueueTime() + " this " + (int)this.getEnqueueTime());
        return i;
    }
}

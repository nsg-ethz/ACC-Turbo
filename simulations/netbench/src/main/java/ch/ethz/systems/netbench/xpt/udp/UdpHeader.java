package ch.ethz.systems.netbench.xpt.udp;

import ch.ethz.systems.netbench.ext.basic.IpHeader;

public interface UdpHeader extends IpHeader {

    /**
     * Retrieve size of data transported by the packet in bytes.
     *
     * @return  Data in bytes
     */
    long getDataSizeByte();

    /**
     * Get the source port.
     *
     * @return  Source port
     */
    int getSourcePort();

    /**
     * Get the destination port.
     *
     * @return  Destination port
     */
    int getDestinationPort();

    /**
     * Get the checksum field of the packet.
     * The sequence number is the number of the first byte of the data carried.
     *
     * @return  Sequence number
     */
    long getChecksum();

    /**
     * Get the length field of the packet.
     * The sequence number is the number of the first byte of the data carried.
     *
     * @return  Sequence number
     */
    int getLength();

}
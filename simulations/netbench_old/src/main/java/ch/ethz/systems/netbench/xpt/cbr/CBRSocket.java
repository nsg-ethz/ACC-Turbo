package ch.ethz.systems.netbench.xpt.cbr;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.core.network.TransportLayer;
import ch.ethz.systems.netbench.xpt.udp.UdpPacket;
import ch.ethz.systems.netbench.xpt.udp.UdpSocket;

import java.util.Random;

public class CBRSocket extends UdpSocket {

    // Specific of CBR Traffic generator
    protected boolean running;
    protected long packetSizeBits;
    protected float rateBitPerNs;
    protected double timeStart;
    protected double timeEnd;
    protected boolean randomEnabled;

    /*
     * Constant bit rate traffic source.   Parameterized by interval, (optional)
     * random noise in the interval, and packet size.
     */

    public CBRSocket(TransportLayer transportLayer, long flowId, int sourceId, int destinationId,
                     long packetSize, float rate, double timeStart, double timeEnd, boolean randomEnabled) {

        super(transportLayer, flowId, sourceId, destinationId, -1);

        this.running = false;
        this.packetSizeBits = packetSize;
        this.rateBitPerNs = rate;
        this.timeStart = timeStart;
        this.timeEnd = timeEnd;
        this.randomEnabled = randomEnabled;
    }

    /**
     * Makes the socket a sender and initiates the communication.
     */
    @Override
    public void start() {
        this.timeout();
        System.out.println(Simulator.getCurrentTime()/1000000000 + "s: CBRSocket started");
    }

    /**
     * Used by the receiver to process packets. We don't do much
     */
    @Override
    public void handle(Packet genericPacket) {
        // We don't do any processing for packets received
        SimulationLogger.increaseStatisticCounter("UDP_PACKETS_RECEIVED"); // This just does + 1 (since length not added)
    }

    void timeout() {

        long now = Simulator.getCurrentTime();
        if (now >= timeStart && now < timeEnd) {
            this.running = true;
            // We send a packet
            UdpPacket packet = super.sendOutDataPacket(this.packetSizeBits/8);
            // We revisit the task after interval time
            double waitFor = ((double)packet.getSizeBit()/rateBitPerNs); // nanoseconds
            if (this.randomEnabled){
                Random independentRng = new Random();
                double outcome = independentRng.nextDouble() - 0.5; //Distribuited uniformly from -0.5 to 0.5
                waitFor = waitFor + (((double)packet.getSizeBit()/rateBitPerNs)* outcome); // nanoseconds. We use getSizeBit to consider the whole packet size, not just the data
            }
            CBRSendEvent sendEvent = new CBRSendEvent((long)waitFor, this);
            Simulator.registerEvent(sendEvent);
        } else {
            this.running = false;
        }
    }

}







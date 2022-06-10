package ch.ethz.systems.netbench.xpt.sppifo.ports.PIFO;

import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;

import java.util.Arrays;
import java.util.Queue;
import java.util.concurrent.PriorityBlockingQueue;

public class PIFOQueue extends PriorityBlockingQueue implements Queue {

    private final int maxItems;

    public PIFOQueue(long maxItems){
        this.maxItems = (int)maxItems;
    }

    // We put a limit to the PIFO queue so that if an inserted packet exceeds the capacity,
    // the packet with highest rank is dropped. 
    public Packet offerPacket(Object o) {

        // We cast the packet
        FullExtTcpPacket packet = (FullExtTcpPacket) o;

        // As the original PBQ is has no limited size, the packet is always inserted
        boolean success = super.offer(packet); // This method will always return true

        // If the size exceeds the PIFO size, we drop the packet with lowest priority (highest rank)
        if (this.size()>maxItems-1){
            Object[] contentPIFO = this.toArray();
            Arrays.sort(contentPIFO);
            packet = (FullExtTcpPacket) contentPIFO[this.size()-1]; // Potser esta aqui l'error
            this.remove(packet);
            
            return packet;
        }
        return null;
    }

    @Override
    public Object poll() {
            Packet packet = (Packet) super.poll(); // As the super queue is unbounded, this method will always return true
            return packet;
    }

    @Override
    public int size() {
        return super.size();
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty();
    }

    public void printQueue() {
        Object[] contentPIFO = this.toArray();
        System.out.print("Still in queue: ");
        for (int i = 0; i<contentPIFO.length; i++){
            FullExtTcpPacket packet = (FullExtTcpPacket) contentPIFO[i];
            System.out.print(packet.getPriority() + ",");
        }
        System.out.print("\n");
    }

}

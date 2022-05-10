package ch.ethz.systems.netbench.xpt.ports.PriorityQueues;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.NetworkDevice;
import ch.ethz.systems.netbench.core.network.Packet;
import ch.ethz.systems.netbench.xpt.tcpbase.FullExtTcpPacket;
import ch.ethz.systems.netbench.xpt.tcpbase.PriorityHeader;

import java.util.*;
import java.util.concurrent.ArrayBlockingQueue;

public class PriorityQueues implements Queue {

    private final ArrayList<ArrayBlockingQueue> queueList;
    private int ownId;

    public PriorityQueues(long numQueues, long perQueueCapacity, NetworkDevice ownNetworkDevice){
        this.queueList = new ArrayList((int)numQueues);

        ArrayBlockingQueue fifo;
        for (int i=0; i<(int)numQueues; i++){
            fifo = new ArrayBlockingQueue<Packet>((int)perQueueCapacity);
            queueList.add(fifo);
        }
        this.ownId = ownNetworkDevice.getIdentifier();
    }

    // Packet dropped and null returned if selected queue exceeds its size
    public boolean offerToPriorityQueue(Object o, int queueId) {
        return queueList.get(queueId).offer(o);
    }

    @Override
    public boolean offer(Object o) {
        FullExtTcpPacket packet = (FullExtTcpPacket) o;
        return this.offerToPriorityQueue(packet, (int)packet.getPriority());
    }

    @Override
    public Object poll() {
        Packet p;
        for (int q=0; q<queueList.size(); q++){
            p = (Packet) queueList.get(q).poll();
            if (p != null){
                return p;
            }
        }
        return null;
    }

    @Override
    public int size() {
        int size = 0;
        for (int q=0; q<queueList.size(); q++){
            size += queueList.get(q).size();
        }
        return size;
    }

    @Override
    public boolean isEmpty() {
        boolean empty = true;
        for (int q=0; q<queueList.size(); q++){
            if(!queueList.get(q).isEmpty()){
                empty = false;
            }
        }
        return empty;
    }

    @Override
    public boolean contains(Object o) {
        return false;
    }

    @Override
    public Iterator iterator() {
        return null;
    }

    @Override
    public Object[] toArray() {
        return new Object[0];
    }

    @Override
    public Object[] toArray(Object[] objects) {
        return new Object[0];
    }

    @Override
    public boolean add(Object o) {
        return false;
    }

    @Override
    public boolean remove(Object o) {
        return false;
    }

    @Override
    public boolean addAll(Collection collection) {
        return false;
    }

    @Override
    public void clear() { }

    @Override
    public boolean retainAll(Collection collection) {
        return false;
    }

    @Override
    public boolean removeAll(Collection collection) {
        return false;
    }

    @Override
    public boolean containsAll(Collection collection) {
        return false;
    }

    @Override
    public Object remove() {
        return null;
    }

    @Override
    public Object element() {
        return null;
    }

    @Override
    public Object peek() {
        return null;
    }
}

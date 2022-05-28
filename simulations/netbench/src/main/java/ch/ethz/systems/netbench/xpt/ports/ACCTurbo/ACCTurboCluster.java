package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

import jdk.internal.net.http.common.Pair;

public class ACCTurboCluster {

    private ACCTurboSignature signature;
    private int clusterId;
    private int priority;
    private int numPackets;

    public ACCTurboCluster(ACCTurboSignature signature, int clusterId, int numClusters) {
        this.signature = signature;
        this.clusterId = clusterId;
        this.priority = numClusters - 1;
        this.numPackets = 1;
    }

    // Updates the packet counter when a new cluster is merged to the existing one.
    public void update_num_packets(ACCTurboCluster new_cluster) {
        this.numPackets = this.numPackets + new_cluster.getNumPackets();
    }

    public int getNumPackets(){
        return this.numPackets;
    }

    public void resetNumPackets(){
        this.numPackets = 0;
    }

    public int getClusterId() {
        return this.clusterId;
    }

    public void setClusterId(int clusterId) {
        this.clusterId = clusterId;
    }

    public int getPriority() {
        return this.priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public ACCTurboSignature getSignature() {
        return this.signature;
    }

    public void setSignature(ACCTurboSignature signature) {
        this.signature = signature;
    }
}

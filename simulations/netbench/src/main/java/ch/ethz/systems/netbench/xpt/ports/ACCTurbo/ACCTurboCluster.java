package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

public class ACCTurboCluster {

    private ACCTurboSignature signature;
    private int priority;
    private int numPackets;

    public ACCTurboCluster(ACCTurboSignature signature, int numClusters) {
        this.signature = signature;
        this.priority = numClusters - 1;
        this.numPackets = 1;
    }

    // Updates the packet counter when a new cluster is merged to the existing one.
    public void updateNumPackets(ACCTurboCluster new_cluster) {
        this.numPackets = this.numPackets + new_cluster.getNumPackets();
    }

    public int getNumPackets(){
        return this.numPackets;
    }

    public void resetNumPackets(){
        this.numPackets = 0;
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

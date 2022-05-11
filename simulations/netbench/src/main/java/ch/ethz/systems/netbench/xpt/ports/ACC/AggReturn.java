package ch.ethz.systems.netbench.xpt.ports.ACC;

public class AggReturn {

    public Cluster[] clusterList;
    public double limit;
    public int finalIndex;
    public int totalCount;

    public AggReturn(Cluster[] clusterList, double bottom, int finalIndex, int totalCount) {
        this.clusterList = clusterList;
        this.limit = bottom;
        this.finalIndex = finalIndex;
        this.totalCount=totalCount;
    }

}

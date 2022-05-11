package ch.ethz.systems.netbench.xpt.ports.ACC;

public class PrefixTree {

    public Integer countArray[];

    public PrefixTree() {
        countArray = new Integer[(1<<(ACCConstants.NO_BITS+1))-1];

        for (int i = 0; i <= getLastIndex(); i++) {
            countArray[i] = 0;
        }
    }

    static int getLastIndex() {
        return (1 << (ACCConstants.NO_BITS + 1)) - 2;
    }

    void reset() {
        for (int i = 0; i <= getLastIndex(); i++) {
            countArray[i] = 0;
        }
    }

    void registerDrop(int address, int size) {
        if (address > getMaxAddress()) {
            System.out.println("ERROR: Address out of Range\n");
            System.exit(-1);
        }
        for (int i = 0; i <= ACCConstants.NO_BITS; i++) {
            int index = getIndexFromAddress(address, i);
            countArray[index] += size;
        }
    }

    AggReturn identifyAggregate(double estimatedArrivalRate, double linkCapacity) {
        int sum = 0;
        int count = 0;
        int i;
        for (i = getFirstIndexOfBit(ACCConstants.NO_BITS); i <= getLastIndexOfBit(ACCConstants.NO_BITS); i++) {
            if (countArray[i] != 0) {
                sum += countArray[i];
                count++;
            }
        }

        if (count == 0) return null;

        Cluster[] clusterList =  new Cluster[ACCConstants.MAX_CLUSTER];
        for (i = 0; i < ACCConstants.MAX_CLUSTER; i++) {
            clusterList[i] = new Cluster(0, -1);
        }

        double mean = sum / count;
        for (i = getFirstIndexOfBit(ACCConstants.NO_BITS); i <= getLastIndexOfBit(ACCConstants.NO_BITS); i++) {
            if (countArray[i] >= mean / 2) { //using mean/2 helps in trivial simulations.
                insertCluster(clusterList, i, countArray[i], ACCConstants.CLUSTER_LEVEL);
            }
        }

        for (i = 0; i < ACCConstants.MAX_CLUSTER; i++) {
            if (clusterList[i].prefix == -1) {
                break;
            }
            goDownCluster(clusterList, i);
        }
        int lastIndex = i - 1;

        sortCluster(clusterList, lastIndex);

        double targetRate = linkCapacity / (1 - ACCConstants.TARGET_DROPRATE);
        double excessRate = estimatedArrivalRate - targetRate;

        double rateTillNow = 0;
        double requiredBottom = 0; //TODO: Check if correct. Added so that it does not say "requiredBottom" may not be initialized.
        int id;
        for (id = 0; id <= lastIndex; id++) {
            rateTillNow += clusterList[id].count * (estimatedArrivalRate / countArray[0]);
            requiredBottom = (rateTillNow - excessRate) / (id + 1);
            //printf("id: %d excessRate: %5.2f rateTillNow: %5.2f requiredBottom: %5.2f\n",
            //id, excessRate, rateTillNow, requiredBottom);
            if (clusterList[id + 1].prefix == -1) {
                // I think that this means that no viable set of aggregates was found.
                // Shouldn't it return failure in this case?  - Sally
                break;
            }
            if (clusterList[id + 1].count * (estimatedArrivalRate / countArray[0]) < requiredBottom) break;
        }

        return new AggReturn(clusterList, requiredBottom, id, countArray[0]);
    }

    void insertCluster(Cluster[] clusterList, int index, int count, int noBits) {

        int address = getPrefixFromIndex(index);
        int prefix = (address >> (ACCConstants.NO_BITS - noBits)) << (ACCConstants.NO_BITS - noBits);
        int breakCode = 0;
        for (int i = 0; i < ACCConstants.MAX_CLUSTER; i++) {
            if (clusterList[i].prefix == prefix && clusterList[i].bits == noBits) {
                clusterList[i].count += count;
                breakCode = 1;
                break;
            }
            if (clusterList[i].prefix == -1) {
                clusterList[i].prefix = prefix;
                clusterList[i].bits = noBits;
                clusterList[i].count = count;
                breakCode = 2;
                break;
            }
        }

        if (breakCode == 0) {
            System.out.println("Error: Too Small MAX_CLUSTER. Increase and Recompile\n");
            System.exit(-1);
        }
    }

    void goDownCluster(Cluster[] clusterList, int index) {

        int noBits = clusterList[index].bits;
        int prefix = clusterList[index].prefix;

        int treeIndex = getIndexFromPrefix(prefix, noBits);
        int maxIndex = treeIndex;
        while (true) {
            int leftIndex = 2 * maxIndex + 1;
            if (leftIndex > getLastIndex()) break;
            int leftCount = countArray[leftIndex];
            int rightCount = countArray[leftIndex + 1];
            if (leftCount > 9 * rightCount) {
                maxIndex = leftIndex;
            } else if (rightCount > 9 * leftCount) {
                maxIndex = leftIndex + 1;
            } else {
                break;
            }
        }

        clusterList[index].prefix = getPrefixFromIndex(maxIndex);
        clusterList[index].bits = getNoBitsFromIndex(maxIndex);
        clusterList[index].count = countArray[maxIndex];
    }

    void sortCluster(Cluster[] clusterList, int lastIndex) {
        int i, j;

        for (i = 0; i <= lastIndex; i++) {
            for (j = i + 1; j <= lastIndex; j++) {
                if (clusterList[i].count < clusterList[j].count) {
                    swapCluster(clusterList, i, j);
                }
            }
        }
    }

    void swapCluster(Cluster[] clusterList, int id1, int id2) {

        int tempP = clusterList[id1].prefix;
        int tempB = clusterList[id1].bits;
        int tempC = clusterList[id1].count;

        clusterList[id1].prefix = clusterList[id2].prefix;
        clusterList[id1].bits = clusterList[id2].bits;
        clusterList[id1].count = clusterList[id2].count;

        clusterList[id2].prefix = tempP;
        clusterList[id2].bits = tempB;
        clusterList[id2].count = tempC;
    }

    int getMaxAddress() {
        return (1 << ACCConstants.NO_BITS) - 1;
    }

    int getIndexFromPrefix(int prefix, int noBits) {
        int base = (1 << noBits) - 1;
        return base + (prefix >> (ACCConstants.NO_BITS - noBits));
    }

    int getIndexFromAddress(int address, int noBits) {

        int base = (1 << noBits) - 1;
//   int andAgent = address >> (NO_BITS - noBits);
//   int additive = base & andAgent;
        int additive = address >> (ACCConstants.NO_BITS - noBits);

        return base + additive;
    }

    int getPrefixFromIndex(int index) {

        int noBits = getNoBitsFromIndex(index);
        int base = (1 << noBits) - 1;
        int prefix = (index - base) << (ACCConstants.NO_BITS - noBits);

        return prefix;
    }


    public static int getPrefixBits(int prefix, int noBits) {
        return (prefix >> (ACCConstants.NO_BITS - noBits)) << (ACCConstants.NO_BITS - noBits);
    }

    int getNoBitsFromIndex(int index) {

        //using 1.2 is an ugly hack to get precise floating point calculation.
        int noBits = (int) Math.floor(Math.log(index + 1.2) / Math.log(2));
        return noBits;
    }

    int getFirstIndexOfBit(int noBits) {
        return (1 << noBits) - 1;
    }

    int getLastIndexOfBit(int noBits) {
        return (1 << (noBits + 1)) - 2;
    }
}
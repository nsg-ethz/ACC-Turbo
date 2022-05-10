package ch.ethz.systems.netbench.xpt.cbr;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Event;

public class CBRFlowStartEvent extends Event {

    private final CBRTransportLayer transportLayer;

    protected int dstId;
    protected int packetSize;
    protected Float rate;
    protected int flowId;
    protected long timeStart;
    protected long timeEnd;

    public CBRFlowStartEvent(CBRTransportLayer transportLayer, int dstId, int packetSize, Float rate, int flowId, long timeStart, long timeEnd) {
        super(timeStart); // useless
        this.transportLayer = transportLayer;
        this.dstId = dstId;
        this.packetSize = packetSize;
        this.rate = rate;
        this.flowId = flowId;
        this.timeStart = timeStart;
        this.timeEnd = timeEnd;

        if(this.transportLayer.getNetworkDevice().getIdentifier() == 0) {
            System.out.println("CBRFlowStartEvent prepared: [dstId: " + dstId +
                    ", packetSize: " + packetSize +
                    ", rate: " + rate +
                    ", flowId: " + flowId +
                    ", timeStart: " + timeStart/1000000000 +
                    "s, timeEnd: " + timeEnd/1000000000 + "s]");
        }
    }

    @Override
    public void trigger() {
        this.transportLayer.startCBRFlow(flowId, dstId,
        packetSize, rate, timeStart, timeEnd);
        if(this.transportLayer.getNetworkDevice().getIdentifier() == 0) {
            System.out.println(Simulator.getCurrentTime()/1000000000 + "s: CBRFlowStartEvent executed [dstId: " + dstId +
                    ", packetSize: " + packetSize +
                    ", rate: " + rate +
                    ", flowId: " + flowId +
                    ", timeStart: " + timeStart/1000000000 +
                    "s, timeEnd: " + timeEnd/1000000000 + "s]");
        }
    }

}



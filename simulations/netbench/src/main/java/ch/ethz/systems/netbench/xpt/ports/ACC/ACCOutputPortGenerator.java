package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.log.SimulationLogger;
import ch.ethz.systems.netbench.core.network.Link;
import ch.ethz.systems.netbench.core.network.NetworkDevice;
import ch.ethz.systems.netbench.core.network.OutputPort;
import ch.ethz.systems.netbench.core.run.infrastructure.OutputPortGenerator;

public class ACCOutputPortGenerator extends OutputPortGenerator {

    private final long sizePackets;
    private final boolean enableRateLimiting;
    private final double sustainedCongestionPeriod;
    private double q_weight;
    private int th_min;
    private int th_max;
    private boolean enable_gentle;
    private int averagePacketSize;
    private boolean wait;

    public ACCOutputPortGenerator(long sizePackets, boolean enableRateLimiting, double sustainedCongestionPeriod,double q_weight, int th_min, int th_max, boolean enable_gentle, int averagePacketSize, boolean wait) {
        this.sizePackets = sizePackets;
        this.enableRateLimiting = enableRateLimiting;
        this.sustainedCongestionPeriod = sustainedCongestionPeriod;
        this.q_weight = q_weight;
        this.th_min = th_min;
        this.th_max = th_max;
        this.enable_gentle = enable_gentle;
        this.averagePacketSize = averagePacketSize;
        this.wait = wait;
        SimulationLogger.logInfo("Port", "PushbackOutputPort(sizePackets=" + sizePackets + ", enableRateLimiting=" + enableRateLimiting + ")");
    }

    @Override
    public OutputPort generate(NetworkDevice ownNetworkDevice, NetworkDevice towardsNetworkDevice, Link link) {
        return new ACCOutputPort(ownNetworkDevice, towardsNetworkDevice, link, sizePackets, enableRateLimiting, sustainedCongestionPeriod, q_weight, th_min, th_max, enable_gentle, averagePacketSize, wait);
    }

}
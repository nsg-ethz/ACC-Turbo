package ch.ethz.systems.netbench.xpt.ports.ACCTurbo;

public class ACCTurboSignature {
    private Long min;
    private Long max;

    public ACCTurboSignature(Long min, Long max){
        this.min = min;
        this.max = max;
    }

    public Long getMin() {
        return this.min;
    }

    public Long getMax() {
        return this.max;
    }
}

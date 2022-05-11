package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.network.Packet;

import java.util.ArrayList;
import java.util.Random;

public class RateLimitSessionList {

    public int numSessions;
    public ArrayList<RateLimitSession> list;

    public RateLimitSessionList() {
        this.numSessions = 0;
        this.list = new ArrayList<>();
    }

    public int filter(Packet pkt) {
        double dropP = -1;
        for(RateLimitSession listItem : list){
            if (listItem != null){
                double p = listItem.log(pkt); // p is only 0 (not dropped) or 1 (dropped)
                if (p >= dropP){
                    dropP = p;
                }
            }
        }
        if (dropP == -1) {
            //System.out.println("Rate-Limit-Session List: Found a non-member packet at " + Simulator.getCurrentTime() + "\n");
        }

        Random uniformRNG = new Random();
        double u = uniformRNG.nextDouble();
        if (u <= dropP) {
            //System.out.println("Packet dropped by the rate limiter");
            return 1;
        }
        //System.out.println("Packet survived the rate limiter. Random number: " + u + "<= Drop prob:" + dropP);
        return 0;
    }

    public int insert(RateLimitSession session) {
        for(RateLimitSession listItem : list){
            if (listItem != null){
                if (listItem.aggSpec.equals(session.aggSpec)) {
                    return 0;
                }
            }
        }
        list.add(session);
        numSessions++;
        return 1;
    }

    public RateLimitSession containsAggSpec(AggSpec spec) {
        for(RateLimitSession listItem : list){
            if (listItem != null){
                if (listItem.aggSpec.contains(spec) == 1) {
                    return listItem;
                }
            }
        }
        return null;
    }

    public void endSession(RateLimitSession rls) {

        if (numSessions==0) {
            System.out.print("Rate-Limit-Session List: Error. No session in progress\n");
            System.exit(-1);
        }

        for(RateLimitSession listItem : list){
            if (listItem != null){
                if (listItem == rls) {
                    list.remove(listItem);
                    numSessions--;
                    return;
                }
            }
        }
        System.out.println("Rate-Limit-Session List: The correct RLS not found\n");
        System.exit(-1);
    }

    //descending order
    public int rankRate(double rate) {
        int rank=0;
        for(RateLimitSession listItem : list){
            if (listItem != null){
                if (listItem.getArrivalRateForStatus() > rate) {
                    rank++;
                }
            }
        }
        return rank;
    }

    //ascending order
    public int rankSession(RateLimitSession session) {
        int rank=0;
        for(RateLimitSession listItem : list){
            if (listItem != null){
                if (listItem.getArrivalRateForStatus() < session.getArrivalRateForStatus()) {
                    rank++;
                }
                //to enforce deterministic ordering between sessions with same rate
                else if (listItem.getArrivalRateForStatus() == session.getArrivalRateForStatus() && listItem.startTime < session.startTime) {
                    rank++;
                }
            }
        }
        return rank;
    }



}

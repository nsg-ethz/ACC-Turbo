package ch.ethz.systems.netbench.xpt.ports.ACC;

import ch.ethz.systems.netbench.core.Simulator;
import ch.ethz.systems.netbench.core.network.Packet;

import java.util.ArrayList;

public class ACCAgent {

    public int lastIndex;
    public int intResult;
    public int debugLevel;
    protected double requiredLimit;
    protected boolean firstTime;

    ACCQueue pushbackQueue;             //pointer to the queue object
    IdentStruct idTree;

    public ACCAgent(ACCQueue pushbackQueue) {
        this.pushbackQueue = pushbackQueue;
        this.idTree = new IdentStruct();
        this.firstTime = true;

        this.lastIndex = 0;
        this.intResult = -1;
        this.debugLevel = 3;
    }

    // Used by RED to report drops to the agent
    public void registerDrop(Packet p) {
        this.idTree.registerDrop(p);
    }

    // Resets the drop counters after each timeout() iteration of the pushback queue
    public void resetDropLog() {
        this.idTree.reset();
    }

    // Called when the drop rate exceeds a pre-configured value to identify the aggregates responsible for congestion and controll them
    public void identifyAggregate(double estimatedArrivalRate, double linkCapacity) {

        //System.out.println("Call to identify aggregate: (estimatedArrivalRate: " + estimatedArrivalRate + " (bit/s), linkCapacity: " + linkCapacity + " (bit/s))");

        // Configure a refresh event (if it is the first time called) to revisit the aggregates periodically
        if (this.firstTime) {
            ACCAgentEvent pushbackAgentEvent = new ACCAgentEvent((long) ACCConstants.PUSHBACK_CYCLE_TIME*1000000000, ACCConstants.PUSHBACK_REFRESH_EVENT, this);
            Simulator.registerEvent(pushbackAgentEvent);
            this.firstTime = false;
        }

        // Current number of rate-limiting sessions
        int numSessions = pushbackQueue.rlsList.numSessions;

        // Identify aggregate
        AggReturn aggReturn = this.idTree.identifyAggregate(estimatedArrivalRate, linkCapacity);
        if (aggReturn == null) return;

        // If we have identified one or multiple aggregates
        for (int i=0; i<=aggReturn.finalIndex; i++) {
            Cluster currCluster = aggReturn.clusterList[i];
            AggSpec aggSpec = new AggSpec(1, currCluster.prefix, currCluster.bits);

            // We make sure that the aggregate is not already in the rate-limiting list
            RateLimitSession rateLimitSession = this.pushbackQueue.rlsList.containsAggSpec(aggSpec);
            if (rateLimitSession != null) {
                // System.out.println("Identified an aggregate which was already in the rate-limiting list: " + aggSpec.dstPrefix);

                // This could keep the lowerbound unnecessarily down. But don't be sympathetic with aggregates, which have been identified again.
                if (aggReturn.limit < rateLimitSession.lowerBound) {
                    rateLimitSession.lowerBound = aggReturn.limit;
                    System.out.println("Further reduced the limit of the aggregate to the new limit: " + aggReturn.limit);
                }

                // Update the last-refreshed time for the analyzed rate-limit session
                rateLimitSession.refreshed();
                continue;
            }

            System.out.println("Identified an aggregate which is not in the rate-limiting list: " + aggSpec.dstPrefix);
            // If the aggregate is not already in the rate-limiting list, we create a new session
            // We estimate the arrival rate of the aggregate (based on the reported RED drops and total estimated arrival rate)
            double estimate = (currCluster.count) * (estimatedArrivalRate / aggReturn.totalCount);
            System.out.println("Estimated rate for the new aggregate (" + aggSpec.dstPrefix + "): " + estimate + "; Counter aggregate=" + currCluster.count + "; Counter total=" + aggReturn.totalCount);

            // If we have exceeded the max number of sessions that we can rate limit, we check if it is a top aggregate
            if (numSessions >= ACCConstants.MAX_SESSIONS) {
                int rank = this.pushbackQueue.rlsList.rankRate(estimate);
                if (rank >= ACCConstants.MAX_SESSIONS) {
                    System.out.println("Identified aggregate is not in the top " + ACCConstants.MAX_SESSIONS + " responsibles: " + aggSpec);
                    continue;
                }
            }

            // If we have space in the list, we start a new rate-limiting session
            double initialLimit = estimate; //*(1 - ambientDropRate);
            RateLimitSession rls = new RateLimitSession(aggSpec, estimate, true, initialLimit, aggReturn.limit);
            this.pushbackQueue.rlsList.insert(rls);
            numSessions++;

            ACCAgentEvent pushbackAgentEvent = new ACCAgentEvent((long) ACCConstants.INITIAL_UPDATE_TIME, ACCConstants.INITIAL_UPDATE_EVENT, rls, this);
            Simulator.registerEvent(pushbackAgentEvent);
        }

        this.idTree.setLowerBound(aggReturn.limit, 0);
    }

    public void initialUpdate(RateLimitSession rls) {

        if (rls.initialPhase == false) {
            System.out.println("Error: Update when not in initial phase");
            System.exit(-1);
        }

        double qdrop = this.pushbackQueue.getDropRate();
        double dropRate = rls.getDropRate();
        double estimatedArrivalRate = rls.getArrivalRateForStatus();
        double newLimit = estimatedArrivalRate * (1 - 2 * (dropRate + qdrop));
        System.out.println("Initial-Update: qdrop="+qdrop+", dr="+dropRate+", newL="+newLimit+", oldTarget="+rls.rateLimitStrategy.targetRate+", lowerBound="+rls.lowerBound+", arr="+estimatedArrivalRate);

        // If estimatedArrivalRate is significantly less than lower bound, cancel right now
        if (estimatedArrivalRate < 0.75 * rls.lowerBound) {
            pushbackCancel(rls);
            System.out.println("Cancelled a rate-limiting session for aggregate: " + rls.aggSpec.dstPrefix + ". Reason is significantly less than lower bound: estimatedArrivalRate < 0.75 * rls.lowerBound");
            return;
        }

        if (false) {
        //if (newLimit > rls.lowerBound) {
            rls.setLimit(newLimit);
            System.out.println("Set new limit for rate-limiting session for aggregate: " + rls.aggSpec.dstPrefix + ". Limit: " + newLimit + "Based on estimated arrival rate aggregate: " + estimatedArrivalRate);

            ACCAgentEvent pushbackAgentEvent = new ACCAgentEvent((long) ACCConstants.INITIAL_UPDATE_TIME, ACCConstants.INITIAL_UPDATE_EVENT, rls, this);
            Simulator.registerEvent(pushbackAgentEvent);
        } else {
            rls.setLimit(rls.lowerBound);
            System.out.println("Set new limit for rate-limiting session for aggregate: " + rls.aggSpec.dstPrefix + ". Limit: " + rls.lowerBound + "Based on estimated arrival rate aggregate: " + estimatedArrivalRate);
            rls.initialPhase = false;
        }
    }

    public void pushbackRefresh() {

        System.out.println(Simulator.getCurrentTime()/1000000000 + "s: Pushback refresh");

        int numSessions = this.pushbackQueue.rlsList.numSessions;
        System.out.println("Current active RL sessions = " + numSessions);

        if (numSessions == 0) {
            //set up refresh timers for a later time and return.
            ACCAgentEvent pushbackAgentEvent = new ACCAgentEvent((long) ACCConstants.PUSHBACK_CYCLE_TIME*1000000000, ACCConstants.PUSHBACK_REFRESH_EVENT, this);
            Simulator.registerEvent(pushbackAgentEvent);
            return;
        }

        // Check if some sessions need to be discarded because of rate-limiting too many sessions
        double now = Simulator.getCurrentTime()/1000000000;

        ArrayList<RateLimitSession> sessionsToDelete = new ArrayList<>();
        for(RateLimitSession listItem1 : this.pushbackQueue.rlsList.list){
            if (numSessions > ACCConstants.MAX_SESSIONS && listItem1 != null){
                int rank = this.pushbackQueue.rlsList.rankRate(listItem1.getArrivalRateForStatus());
                if (rank >= ACCConstants.MAX_SESSIONS && (now - listItem1.startTime) >= ACCConstants.EARLIEST_TIME_TO_FREE) {
                    System.out.println("Releasing because of too many being rate-limited");
                    if (ACCConstants.LOWER_BOUND_MODE == 1 && this.idTree.lowerBound<listItem1.getArrivalRateForStatus()){
                        this.idTree.lowerBound = listItem1.getArrivalRateForStatus();
                    }
                    sessionsToDelete.add(listItem1);
                }
            }
        }

        // We delete the selected sessions
        for (int i = 0; i < sessionsToDelete.size(); i++) {
            pushbackCancel(sessionsToDelete.get(i));
            numSessions--;
        }

        double linkCapacity = this.pushbackQueue.getBandwidthBitPerNs()*1000000000; // In bits per second
        double estimatedArrivalRate = this.pushbackQueue.getRate(); // In bits per second
        double targetRate = linkCapacity / (1 - ACCConstants.TARGET_DROPRATE);

        double totalRateLimitedArrivalRate = 0;
        double totalLimit = 0;
        double lowerBound = -1;
        for(RateLimitSession listItem : this.pushbackQueue.rlsList.list) {
            if (listItem != null) {
                if (listItem.merged == false) {
                    double sessionestimatedArrivalRate = listItem.getArrivalRateForStatus();
                    double sessionLimit = listItem.rateLimitStrategy.targetRate;
                    totalRateLimitedArrivalRate += sessionestimatedArrivalRate;
                    totalLimit += (sessionestimatedArrivalRate > sessionLimit) ? sessionLimit : sessionestimatedArrivalRate;
                    if (listItem.lowerBound < lowerBound || lowerBound == -1) {
                        lowerBound = listItem.lowerBound;
                    }
                }
            }
        }

        if (ACCConstants.LOWER_BOUND_MODE == 1) {
            lowerBound = this.idTree.lowerBound;
        }

        double excessRate = (estimatedArrivalRate - totalLimit + totalRateLimitedArrivalRate) - targetRate;
        System.out.println("Arrival rate= "+ estimatedArrivalRate + ", totalLimit=" + totalLimit + ", totalRateLimit=" + totalRateLimitedArrivalRate + ", excess=" + excessRate);
        if (excessRate < 0) {
            System.out.println("Negative Excess Rate. Things may be fine now.");
            //this would make all sessions go away after a while.
            requiredLimit = 2 * totalRateLimitedArrivalRate;
        } else {
            //Should we allow such an abrupt increase when the number of sessions changes?
            // How about: Let L be the requiredLimit.
            // We need Sum (session arrival rate - L ) = excessRate
            requiredLimit = (totalRateLimitedArrivalRate - excessRate) / numSessions;
            if (requiredLimit < lowerBound) {
                requiredLimit = lowerBound;
            }
            System.out.println("New requiredLimit: " + requiredLimit + "lowerBound: " + lowerBound);
        }
        System.out.println("Refresh. target="+ targetRate+ ", limit="+requiredLimit+", floor="+ lowerBound);


        //consider all sessions in ascending order of their arrival rate
        for(int i = 0; i < numSessions; i++){
            RateLimitSession listItem = this.pushbackQueue.rlsList.list.get(i);
            if (listItem != null) {
                if (this.pushbackQueue.rlsList.rankSession(listItem) == i)
                    break;
            }
            if (listItem == null) {
                System.out.println("Error: Rank " + i + " not found\n");
                System.exit(0);
            }

            double oldLimit = listItem.rateLimitStrategy.targetRate;
            double sendRate = listItem.getArrivalRateForStatus();

            //Session sending less than the limit.
            if (sendRate < requiredLimit) {
                //if it has been sending less for "some" time.
                if (now - listItem.refreshedTime >= ACCConstants.MIN_TIME_TO_FREE) {
                    pushbackCancel(listItem);       //cancel rate-limiting
                    requiredLimit += (requiredLimit - sendRate) / (numSessions - i - 1);
                    i--;
                    numSessions--;
                } else {
                    //refresh upstream with double of max(sending rate, old limit)
                    //just using sending rate, limits the amount an aggregate can grow till next refresh
                    //using just old limit is tricky when different aggregates have different limits.
                    //at the same time, we would prefer not to loosen the hold too much in one step.
                    double maxR = sendRate > oldLimit ? sendRate : oldLimit;
                    if (now - listItem.refreshedTime <= ACCConstants.PRIMARY_WAITING_ZONE) {
                        System.out.println("Waiting Zone 1: sendRate="+ sendRate + ", oldLimit=" + oldLimit + "\n");
                    } else {
                        System.out.println("Waiting Zone 2: sendRate="+ sendRate + ", oldLimit=" + oldLimit + "\n");
                        maxR *= 1.5;
                    }
                    if (maxR < requiredLimit) {
                        listItem.setLimit(maxR);
                        if ((numSessions - i - 1) > 0) {
                            requiredLimit += (requiredLimit - maxR) / (numSessions - i - 1);
                        }
                    } else {
                        listItem.setLimit(requiredLimit);
                    }
                }
            } else {
                //change the rate limit most half way.
                double newLimit;
                if (oldLimit > 1.25 * requiredLimit || oldLimit == 0)
                    newLimit = requiredLimit;
                else
                    newLimit = 0.5 * requiredLimit + 0.5 * oldLimit;

                if (newLimit < lowerBound)
                    newLimit = lowerBound;

                listItem.refreshed();
                listItem.setLimit(newLimit);
            }
        }

        //setup refresh timer again
        numSessions = this.pushbackQueue.rlsList.numSessions;
        if (numSessions > 0) {
            ACCAgentEvent event = new ACCAgentEvent((long) ACCConstants.PUSHBACK_CYCLE_TIME*1000000000, ACCConstants.PUSHBACK_REFRESH_EVENT, this);
            Simulator.registerEvent(event);
        }
    }


    void pushbackCancel(RateLimitSession rls) {
        //System.out.println("Stopping rate-limiting for aggregate: " + rls.aggSpec.dstPrefix);

        //local cancellation here.
        this.pushbackQueue.rlsList.endSession(rls);
    }



}
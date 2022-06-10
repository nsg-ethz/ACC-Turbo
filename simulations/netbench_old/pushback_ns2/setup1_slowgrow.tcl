
#
# one complete test with CBR flows only, no pushback and no ACC.
# Slowly-growing bad CBR aggregate.
#

Class Test/slowgrow

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ slowgrow
    $self next noTraceFiles
}

run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup1
    $ns_ run
}

#
# one complete test with CBR flows only, with ACC.
# Slowly-growing bad CBR aggregate.
#

Class Test/slowgrow-acc

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ slowgrow-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/slowgrow-acc instproc run {} [Test/slowgrow info instbody run]
    $self next noTraceFiles
}

Topology/net2 instproc init ns {
    $self instvar node_ bandwidth_ bandwidth1_
    set bandwidth_ 0.5Mb
    set bandwidth1_ 500000
    #the destinations; declared first
    for {set i 0} {$i < 2} {incr i} {
        set node_(d$i) [$ns node]
    }

    #the routers
    for {set i 0} {$i < 4} {incr i} {
        set node_(r$i) [$ns node]
        #$node_(r$i) add-pushback-agent
    }
    $node_(r0) add-pushback-agent

    #the sources
    for {set i 0} {$i < 4} {incr i} {
        set node_(s$i) [$ns node]
    }

    $self next

    $ns duplex-link $node_(s0) $node_(r0) 10Mb 2ms DropTail
    $ns duplex-link $node_(s1) $node_(r0) 10Mb 3ms DropTail
    $ns pushback-simplex-link $node_(r0) $node_(r1) $bandwidth_ 10ms
    $ns simplex-link $node_(r1) $node_(r0) $bandwidth_ 10ms DropTail
    $ns duplex-link $node_(d0) $node_(r1) 10Mb 2ms DropTail
    $ns duplex-link $node_(d1) $node_(r1) 10Mb 2ms DropTail

    $ns queue-limit $node_(r0) $node_(r1) 100
    $ns queue-limit $node_(r1) $node_(r0) 100
}

setup1 {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
    $self instvar maxAggregates_

    set stoptime 50.0
    set dumptime 1.0
    set stoptime1 [expr $stoptime + 1.0]
    set packetsize_ 200
    Application/Traffic/CBR set random_ 0.001
    Application/Traffic/CBR set packetSize_ $packetsize_

    set slink [$ns_ link $node_(r0) $node_(r1)]; # link to collect stats on
    set fmon [$ns_ makeflowmon Fid]
    $ns_ attach-fmon $slink $fmon

    $self new-cbr $node_(s0) $node_(d0) $packetsize_ 0.12Mb 1 0.1
    $self new-cbr $node_(s1) $node_(d1) $packetsize_ 0.08Mb 2 0.2
    $self new-cbr $node_(s1) $node_(d1) $packetsize_ 0.07Mb 3 0.3
    $self new-cbr $node_(s1) $node_(d1) $packetsize_ 0.06Mb 4 0.4
    $self new-cbr $node_(s1) $node_(d1) $packetsize_ 0.04Mb 5 0.5

    # bad traffic
    set cbr_ [$self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.09Mb 5 0.0]

    set maxAggregates_ 5

    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.1Mb 5 13.0 39.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.1Mb 5 14.0 38.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 15.0 37.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 16.0 36.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 17.0 35.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 18.0 34.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 19.0 33.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 20.0 32.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 21.0 31.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 22.0 30.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 23.0 29.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 24.0 28.0
    $self new-cbr $node_(s0) $node_(d1) $packetsize_ 0.05Mb 5 25.0 27.0

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}
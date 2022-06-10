
#
# Slowly-growing bad CBR aggregate, competing TCP and CBR traffic, no ACC.
#

Class Test/demo

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ demo
    $self next noTraceFiles
}

run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup6
    $ns_ run
}

#
# Slowly-growing bad CBR aggregate, competing TCP and CBR traffic, local ACC.
#

Class Test/demo-acc

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ demo-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/demo-acc instproc run {} [Test/demo info instbody run]
    $self next noTraceFiles
}


setup6 {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
    $self instvar maxAggregates_

    set stoptime 50.0
    #set dumptime 5.0
    set dumptime 1.0
    #set stoptime 5.0
    set stoptime1 [expr $stoptime + 1.0]
    set packetsize_ 500
    Application/Traffic/CBR set random_ 0
    Application/Traffic/CBR set packetSize_ $packetsize_

    set slink [$ns_ link $node_(r0) $node_(r1)]; # link to collect stats on
    set fmon [$ns_ makeflowmon Fid]
    $ns_ attach-fmon $slink $fmon
    Application/Traffic/CBR set random_ 0.001

    $self new-cbr $node_(s0) $node_(d0) 500 0.12Mb 1 0.1
    $self new-tcp $node_(s0) $node_(d0) 500 10 2 1.2
    $self new-tcp $node_(s1) $node_(d1) 500 10 3 2.3
    $self new-tcp $node_(s1) $node_(d1) 500 10 3 3.4
    $self new-tcp $node_(s0) $node_(d1) 500 10 4 5.6
    $self new-tcp $node_(s0) $node_(d1) 500 10 4 6.7
    $self new-tcp $node_(s1) $node_(d0) 500 20 4 7.7

    # bad traffic
    set cbr_ [$self new-cbr $node_(s0) $node_(d1) 500 0.1Mb 5 0.0]
    $cbr_ set random_ 0.001

    set maxAggregates_ 6

    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 13.0 39.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 14.0 38.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 15.0 37.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 16.0 36.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 17.0 35.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 18.0 34.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 19.0 33.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 20.0 32.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 21.0 31.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 22.0 30.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 23.0 29.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 24.0 28.0
    $self new-cbr $node_(s0) $node_(d1) 500 0.05Mb 5 25.0 27.0

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}
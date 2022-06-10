#
# CBR flows only, no pushback and no local ACC
#

Class Test/A_noACC

init {} {
    $self instvar net_ test_
    set net_ net3
    set test_ A_noACC
    $self next noTraceFiles
}

run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup2
    $ns_ run
}

#
# CBR flows only, local ACC
#

Class Test/A_ACC

init {} {
    $self instvar net_ test_
    set net_ net3
    set test_ A_ACC

    Queue/RED/Pushback set rate_limiting_ 1
    Agent/Pushback set enable_pushback_ 0

    Test/A_ACC instproc run {} [Test/A_noACC info instbody run]

    $self next noTraceFiles
}

setup2 {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
    $self instvar maxAggregates_

    set stoptime 100.0
    set dumptime 1.0
    set stoptime1 [expr $stoptime + 1.0]
    set packetsize_ 200
    Application/Traffic/CBR set random_ 0
    Application/Traffic/CBR set packetSize_ $packetsize_

    set slink [$ns_ link $node_(r0) $node_(r1)]; # link to collect stats on
    set fmon [$ns_ makeflowmon Fid]
    $ns_ attach-fmon $slink $fmon

    set udp1 [$ns_ create-connection UDP $node_(s2) Null $node_(d0) 1]
    set cbr1 [$udp1 attach-app Traffic/CBR]
    $cbr1 set rate_ 0.2Mb
    $cbr1 set random_ 0.001

    set udp2 [$ns_ create-connection UDP $node_(s3) Null $node_(d0) 2]
    set cbr2_ [$udp2 attach-app Traffic/CBR]
    $cbr2_ set rate_ 0.2Mb
    $cbr2_ set random_ 0.001

    # bad traffic
    set udp [$ns_ create-connection UDP $node_(s0) Null $node_(d1) 3]
    set cbr_ [$udp attach-app Traffic/CBR]
    $cbr_ set rate_ 3.0Mb
    $cbr_ set random_ 0.001
    $ns_ at 0.0 "$cbr_ start"

    # poor traffic
    set udp6 [$ns_ create-connection UDP $node_(s1) Null $node_(d1) 3]
    set cbr6_ [$udp attach-app Traffic/CBR]
    $cbr6_ set rate_ 0.2Mb
    $cbr6_ set random_ 0.001
    $ns_ at 0.0 "$cbr6_ start"

    set maxAggregates_ 3

    $ns_ at 0.2 "$cbr1 start"
    $ns_ at 0.1 "$cbr2_ start"

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}
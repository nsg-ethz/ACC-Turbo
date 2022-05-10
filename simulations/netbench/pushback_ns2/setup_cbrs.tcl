
#
# one complete test with CBR flows only, no pushback and no ACC.
#

Class Test/cbrs

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs
    $self next noTraceFiles
}

run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup
    $ns_ run
}

#
# one complete test with CBR flows only, with ACC.
#

Class Test/cbrs-acc

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/cbrs-acc instproc run {} [Test/cbrs info instbody run]
    $self next noTraceFiles
}

#
# one complete test with CBR flows only, with no ACC
# CBR flows flows starting and stopping
#

Class Test/cbrs1

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs1
    $self next noTraceFiles
}

run {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_
    $self setTopo
    $self setup
    $ns_ at 10.0 "$cbr_ set rate_ 0.1Mb"
    $ns_ at 15.0 "$cbr2_ set rate_ 0.5Mb"
    $ns_ run
}

#
# one complete test with CBR flows only, with ACC
# CBR flows flows starting and stopping
#

Class Test/cbrs-acc1

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs-acc1
    Queue/RED/Pushback set rate_limiting_ 1
    Test/cbrs-acc1 instproc run {} [Test/cbrs1 info instbody run]
    $self next noTraceFiles
}

setup {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
    $self instvar maxAggregates_

    set stoptime 100.0
    #set stoptime 5.0
    #set dumptime 5.0
    set dumptime 1.0
    set stoptime1 [expr $stoptime + 1.0]
    set packetsize_ 200
    Application/Traffic/CBR set random_ 0
    Application/Traffic/CBR set packetSize_ $packetsize_

    set slink [$ns_ link $node_(r0) $node_(r1)]; # link to collect stats on
    set fmon [$ns_ makeflowmon Fid]
    $ns_ attach-fmon $slink $fmon

    set udp1 [$ns_ create-connection UDP $node_(s0) Null $node_(d0) 1]
    set cbr1 [$udp1 attach-app Traffic/CBR]
    $cbr1 set rate_ 0.12Mb
    $cbr1 set random_ 0.005

    set udp2 [$ns_ create-connection UDP $node_(s1) Null $node_(d1) 2]
    set cbr2_ [$udp2 attach-app Traffic/CBR]
    $cbr2_ set rate_ 0.08Mb
    $cbr2_ set random_ 0.005

    # bad traffic
    set udp [$ns_ create-connection UDP $node_(s0) Null $node_(d1) 3]
    set cbr_ [$udp attach-app Traffic/CBR]
    $cbr_ set rate_ 0.5Mb
    $cbr_ set random_ 0.001
    $ns_ at 0.0 "$cbr_ start"

    set udp4 [$ns_ create-connection UDP $node_(s1) Null $node_(d0) 4]
    set cbr4 [$udp4 attach-app Traffic/CBR]
    $cbr4 set rate_ 0.07Mb
    $cbr4 set random_ 0.005

    set udp5 [$ns_ create-connection UDP $node_(s0) Null $node_(d0) 5]
    set cbr5 [$udp5 attach-app Traffic/CBR]
    $cbr5 set rate_ 0.06Mb
    $cbr5 set random_ 0.005

    set udp6 [$ns_ create-connection UDP $node_(s0) Null $node_(d0) 6]
    set cbr6 [$udp6 attach-app Traffic/CBR]
    $cbr6 set rate_ 0.05Mb
    $cbr6 set random_ 0.005


    set maxAggregates_ 6

    $ns_ at 0.2 "$cbr1 start"
    $ns_ at 0.1 "$cbr2_ start"
    $ns_ at 0.3 "$cbr4 start"
    $ns_ at 0.4 "$cbr5 start"

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}
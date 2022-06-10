
#
# Slowly-growing TCP aggregate competing against large TCP aggregates.
# No ACC.
#

Class Test/tcp2

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp2
    $self next noTraceFiles
}

run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup4b
    $ns_ run
}

#
# Slowly-growing TCP aggregate competing against large TCP aggregates.
# No pushback, but with local ACC.
#

Class Test/tcp2-acc

init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp2-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/tcp2-acc instproc run {} [Test/tcp2 info instbody run]
    $self next noTraceFiles
}

setup4b {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
    $self instvar maxAggregates_

    set stoptime 60.0
    #set dumptime 5.0
    set dumptime 1.0
    #set stoptime 5.0
    set stoptime1 [expr $stoptime + 1.0]
    set packetsize_ 200
    Application/Traffic/CBR set random_ 0
    Application/Traffic/CBR set packetSize_ $packetsize_
    Agent/TCP set packetSize_ $packetsize_

    set slink [$ns_ link $node_(r0) $node_(r1)]; # link to collect stats on
    set fmon [$ns_ makeflowmon Fid]
    $ns_ attach-fmon $slink $fmon

    $self manytcps 0
    $self manytcps 1
    $self manytcps 2
    $self manytcps 3
    $self manytcps 4
    $self manytcps 5

    set maxAggregates_ 6
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps
    $self badtcps

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}

Class Topology

Topology instproc node? num {
    $self instvar node_
    return $node_($num)
}

Class Topology/net2 -superclass Topology
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

Class Topology/net3 -superclass Topology
Topology/net3 instproc init ns {
    $self next
    $self instvar node_ bandwidth_ bandwidth1_
    set bandwidth_ 1.0Mb
    set bandwidth1_ 1000000
    #the destinations; declared first
    for {set i 0} {$i < 2} {incr i} {
        set node_(d$i) [$ns node]
    }

    #the routers
    for {set i 0} {$i < 4} {incr i} {
        set node_(r$i) [$ns node]
	$node_(r$i) add-pushback-agent
    }

    #the sources
    for {set i 0} {$i < 4} {incr i} {
        set node_(s$i) [$ns node]
	set pushback($i) [$node_(s$i) add-pushback-agent]
    }


    $ns pushback-duplex-link $node_(s0) $node_(r2) 10Mb 2ms
    #$ns duplex-link $node_(s0) $node_(r2) 10Mb 2ms DropTail
    $ns pushback-duplex-link $node_(s1) $node_(r2) 10Mb 3ms
    #$ns duplex-link $node_(s1) $node_(r3) 10Mb 3ms DropTail
    $ns pushback-duplex-link $node_(s2) $node_(r3) 10Mb 3ms
    $ns pushback-duplex-link $node_(s3) $node_(r3) 10Mb 3ms
    $ns pushback-duplex-link $node_(r0) $node_(r1) $bandwidth_ 10ms
    $ns pushback-duplex-link $node_(r2) $node_(r0) 10Mb 10ms
    $ns pushback-duplex-link $node_(r3) $node_(r0) 10Mb 10ms
    #
    $ns pushback-simplex-link $node_(r1) $node_(d0) 10Mb 2ms
    $ns simplex-link $node_(d0) $node_(r1) 10Mb 2ms DropTail
    #$ns duplex-link $node_(d0) $node_(r1) 10Mb 2ms DropTail
    #
    $ns pushback-simplex-link $node_(r1) $node_(d1) 10Mb 2ms
    $ns simplex-link $node_(d1) $node_(r1) 10Mb 2ms DropTail
    #$ns duplex-link $node_(d1) $node_(r1) 10Mb 2ms DropTail

    $ns queue-limit $node_(r0) $node_(r1) 100
    $ns queue-limit $node_(r1) $node_(r0) 100
}
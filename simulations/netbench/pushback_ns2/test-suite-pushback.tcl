#
# Copyright (c) 2000  International Computer Science Institute
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by ACIRI, the AT&T
#      Center for Internet Research at ICSI (the International Computer
#      Science Institute).
# 4. Neither the name of ACIRI nor of ICSI may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY ICSI AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL ICSI OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

set dir [pwd]
catch "cd tcl/test"
source misc_simple.tcl
Agent/TCP set tcpTick_ 0.1
# The default for tcpTick_ is being changed to reflect a changing reality.
Agent/TCP set rfc2988_ false
# The default for rfc2988_ is being changed to true.
# FOR UPDATING GLOBAL DEFAULTS:
Agent/TCP set precisionReduce_ false ;   # default changed on 2006/1/24.
Agent/TCP set rtxcur_init_ 6.0 ;      # Default changed on 2006/01/21
Agent/TCP set updated_rttvar_ false ;  # Variable added on 2006/1/21
Agent/TCP set minrto_ 1
# default changed on 10/14/2004.
Queue/RED set bytes_ false
# default changed on 10/11/2004.
Queue/RED set queue_in_bytes_ false
# default changed on 10/11/2004.
Queue/RED set q_weight_ 0.002
Queue/RED set thresh_ 5
Queue/RED set maxthresh_ 15
# The RED parameter defaults are being changed for automatic configuration.
Agent/TCP set useHeaders_ false
# The default is being changed to useHeaders_ true.
Agent/TCP set windowInit_ 1
# The default is being changed to 2.
Agent/TCP set singledup_ 0
# The default is being changed to 1
catch "cd $dir"
Queue/RED set gentle_ true
Agent/Pushback set verbose_ false
#Agent/Pushback set verbose_ true

Queue/RED/Pushback set rate_limiting_ 0
Agent/Pushback set enable_pushback_ 0

set flowfile fairflow.tr; # file where flow data is written
set flowgraphfile fairflow.xgr; # file given to graph tool

TestSuite instproc finish file {
	global quiet PERL
	$self instvar ns_ tchan_ testName_ tmpschan_ maxAggregates_
	# was: -s 2 -d 3
        #exec $PERL ../../bin/getrc -s 12 -d 13 all.tr | \
        #  $PERL ../../bin/raw2xg -a -s 0.01 -m 90 -t $file > temp2.rands
	#if {$quiet == "false"} {
        #	exec xgraph -bb -tk -nl -m -x time -y packets temp2.rands &
	#}
        ## now use default graphing tool to make a data file
        ## if so desired

	if { [info exists tchan_] && $quiet == "false" } {
		#$self plotQueue $testName_
	}
	if { [info exists tmpschan_]} {
		$self finishflows $testName_ $maxAggregates_
		close $tmpschan_
	}
	$ns_ halt
}

# display graph of results
#
# temp.s:
# time: 4.000 LinkUtilThisTime  1.002 totalLinkUtil: 1.000 totalOQPkts: 1250
# fid: 1 Util: 0.124 OQdroprate: 0.320 OQpkts: 155 OQdrops: 73
#
TestSuite instproc finishflows {testname maxAggregate} {
        global quiet
        $self instvar tmpschan_ tmpqchan_ topo_ node_ ns_
	$self instvar packetsize_
        $topo_ instvar cbqlink_ bandwidth1_

        set graphfile temp.rands
        set maxbytes [expr $bandwidth1_ / 8.0]
	set maxpkts [expr 1.0 * $maxbytes / $packetsize_]

        set awkCode  {
		{
		if ($1 == 0) {time=1; oldpkts=0;}
		if ($1 == "time:" && $3 == "LinkUtilThisTime") {
			time = $2
		}
		if ($1 == "fid:" && $2==flow) {
		  newpkts = $8;
		  pkts = newpkts - oldpkts;
		  print time, pkts/maxpkts;
		  oldpkts = newpkts
		}}
        }
        set awkCodeAll {
		{
		if ($1==0) {oldpkts=0}
		if ($1 == "time:" && $7 == "totalOQPkts:") {
			time = $2;
		  	newpkts = $8;
		  	pkts = newpkts - oldpkts;
		  	print time, pkts/maxpkts;
		  	oldpkts = newpkts
		}}
        }
        set awkCodeDrop {
		{
		if ($1==0) {oldpkts = 0; olddrops = 0; time=0;}
		if ($5~"totalOQDrops:"){
		  time = $2;
		  pkts = $4;
		  drops = $6;
		  newpkts = pkts - oldpkts;
		  newdrops = drops - olddrops;
		  print time, newdrops/newpkts;
		  oldpkts = pkts; olddrops = drops;
		}}
	}


        if { [info exists tmpschan_] } {
                close $tmpschan_
        }

        set f [open $graphfile w]
        puts $f "TitleText: $testname"
        puts $f "Device: Postscript"

        exec rm -f temp.p
        exec touch temp.p
	for {set i 1} {$i < $maxAggregate + 1 } {incr i} {
                exec echo "\n\"flow $i" >> temp.p
                exec awk $awkCode flow=$i maxpkts=$maxpkts temp.s > flows$i
                exec cat flows$i >> temp.p
                exec echo " " >> temp.p
        }

        exec awk $awkCodeAll maxpkts=$maxpkts temp.s > all
        exec echo "\n\"all " >> temp.p
        exec cat all >> temp.p

        exec cat temp.p >@ $f
        close $f
        exec awk $awkCodeDrop temp.s > temp.droprate
        if {$quiet == "false"} {
                exec xgraph -bb -tk -ly 0,1 -x time -y bandwidth $graphfile &
        }
#       exec csh gnuplotE.com $testname
#       exec csh gnuplotF.com $testname

        exit 0
}

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

TestSuite instproc new-tcp {source dest size window fid startTime} {
    $self instvar ns_

    set tcp [$ns_ create-connection TCP/Sack1 $source TCPSink/Sack1 $dest $fid]
    $tcp set window_ $window
    $tcp set tcpTick_ 0.01

    if {$size > 0}  {
        $tcp set packetSize_ $size
    }
    set ftp [$tcp attach-source FTP]
    #if {$maxPkts > 0} {$ftp set maxpkts_ $maxPkts}
    $ns_ at $startTime "$ftp start"
}

TestSuite instproc new-cbr {src dst pktSize rate fid startTime {stopTime -1}} {
    $self instvar ns_
    set udp [$ns_ create-connection UDP $src Null $dst $fid]
    set cbr [$udp attach-app Traffic/CBR]
    $cbr set packetSize_ $pktSize
    $cbr set rate_ $rate
    $cbr set random_ 1

    $ns_ at $startTime "$cbr start"
    if {$stopTime != -1} {
        $ns_ at $stopTime "$cbr set rate_ 1000"
    }
    return $cbr
}

#
# Arrange for time to be printed every
# $interval seconds of simulation time
#
TestSuite instproc statsDump { interval fmon packetsize oldpkts } {
        global quiet
        $self instvar dump_inst_ ns_ tmpschan_ f
	$self instvar maxAggregates_
	set dumpfile temp.s
        if ![info exists dump_inst_] {
		$self instvar tmpschan_ f
                set dump_inst_ 1
		set f [open $dumpfile w]
		set tmpschan_ $f
                $ns_ at 0.0 "$self statsDump $interval $fmon $packetsize $oldpkts"
                return
        }
        set time [$ns_ now]
        puts $f "$time"
        set newtime [expr [$ns_ now] + $interval]
	## $quiet == "false"
        if { $time > 0} {
            set totalPkts [$fmon set pdepartures_]
            set totalArrivals [$fmon set parrivals_]
	    set totalDrops [$fmon set pdrops_]
            set packets [expr $totalPkts - $oldpkts]
            set oldpkts $totalPkts
    	    set linkBps [ expr 500000/8 ]
    	    set recentUtil [expr (1.0*$packets*$packetsize)/($interval*$linkBps)]
    	    set totalLinkUtil [expr (1.0*$totalPkts*$packetsize)/($time*$linkBps)]
            set now [$ns_ now]
	    puts $f "time: [format %.3f $now] totalOQArrivals: $totalArrivals totalOQDrops: $totalDrops"
    	    puts $f "time: [format %.3f $now] LinkUtilThisTime  [format %.3f $recentUtil] totalLinkUtil: [format %.3f $totalLinkUtil] totalOQPkts: $totalPkts"
    	    set fcl [$fmon classifier];
	    ## this
	    for {set i 1} {$i < $maxAggregates_ + 1} {incr i} {
    	        set flow [$fcl lookup auto 0 0 $i]
		if {$flow != "" } {
		  set flowpkts($flow) [$flow set pdepartures_]
    	          set flowutil [expr (1.0*$flowpkts($flow)*$packetsize)/($time*$linkBps)]
		  set flowdrops($flow) [$flow set pdrops_]
		  if {$flowpkts($flow) + $flowdrops($flow) > 0} {
    	            set flowdroprate [expr (1.0*$flowdrops($flow)/($flowpkts($flow) + $flowdrops($flow)))]
                  } else { set flowdroprate 0 }
		  puts $f "fid: $i Util: [format %.3f $flowutil] OQdroprate: [format %.3f $flowdroprate] OQpkts: [format %d $flowpkts($flow)] OQdrops: [format %d $flowdrops($flow)]"
		}
	    }
        }
        $ns_ at $newtime "$self statsDump $interval $fmon $packetsize $oldpkts"
}

TestSuite instproc setup {} {
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

#
# one complete test with CBR flows only, no pushback and no ACC.
#
Class Test/cbrs -superclass TestSuite
Test/cbrs instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs
    $self next noTraceFiles
}
Test/cbrs instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup
    $ns_ run
}

#
# one complete test with CBR flows only, with ACC.
#
Class Test/cbrs-acc -superclass TestSuite
Test/cbrs-acc instproc init {} {
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
Class Test/cbrs1 -superclass TestSuite
Test/cbrs1 instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs1
    $self next noTraceFiles
}
Test/cbrs1 instproc run {} {
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
Class Test/cbrs-acc1 -superclass TestSuite
Test/cbrs-acc1 instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ cbrs-acc1
    Queue/RED/Pushback set rate_limiting_ 1
    Test/cbrs-acc1 instproc run {} [Test/cbrs1 info instbody run]
    $self next noTraceFiles
}

TestSuite instproc setup1 {} {
    $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
    $self instvar maxAggregates_

    set stoptime 50.0
    #set dumptime 5.0
    set dumptime 1.0
    #set stoptime 5.0
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

#
# one complete test with CBR flows only, no pushback and no ACC.
# Slowly-growing bad CBR aggregate.
#
Class Test/slowgrow -superclass TestSuite
Test/slowgrow instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ slowgrow
    $self next noTraceFiles
}
Test/slowgrow instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup1
    $ns_ run
}

#
# one complete test with CBR flows only, with ACC.
# Slowly-growing bad CBR aggregate.
#
Class Test/slowgrow-acc -superclass TestSuite
Test/slowgrow-acc instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ slowgrow-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/slowgrow-acc instproc run {} [Test/slowgrow info instbody run]
    $self next noTraceFiles
}

######################################################33

TestSuite instproc setup6 {} {
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

#
# Slowly-growing bad CBR aggregate, competing TCP and CBR traffic, no ACC.
#
Class Test/demo -superclass TestSuite
Test/demo instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ demo
    $self next noTraceFiles
}
Test/demo instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup6
    $ns_ run
}

#
# Slowly-growing bad CBR aggregate, competing TCP and CBR traffic, local ACC.
#
Class Test/demo-acc -superclass TestSuite
Test/demo-acc instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ demo-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/demo-acc instproc run {} [Test/demo info instbody run]
    $self next noTraceFiles
}

######################################################33

TestSuite instproc manytcps {starttime} {
    $self instvar ns_ node_
    set tcp1 [$ns_ create-connection TCP/Sack1 $node_(s0) TCPSink/Sack1 $node_(d0) 1 ]
    $tcp1 set window_ 10
    set ftp1 [$tcp1 attach-app FTP]
    $ns_ at $starttime.0 "$ftp1 start"

    set tcp2 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 2 ]
    $tcp2 set window_ 12
    set ftp2 [$tcp2 attach-app FTP]
    $ns_ at $starttime.1 "$ftp2 start"

    set tcp3 [$ns_ create-connection TCP/Sack1 $node_(s0) TCPSink/Sack1 $node_(d1) 3 ]
    $tcp3 set window_ 15
    set ftp3 [$tcp3 attach-app FTP]
    $ns_ at $starttime.2 "$ftp3 start"

    set tcp4 [$ns_ create-connection TCP/Sack1 $node_(s0) TCPSink/Sack1 $node_(d0) 4 ]
    $tcp4 set window_ 8
    set ftp4 [$tcp4 attach-app FTP]
    $ns_ at $starttime.3 "$ftp4 start"

    set tcp5 [$ns_ create-connection TCP/Sack1 $node_(s0) TCPSink/Sack1 $node_(d1) 5 ]
    $tcp5 set window_ 4
    set ftp5 [$tcp5 attach-app FTP]
    $ns_ at $starttime.4 "$ftp5 start"
}

TestSuite instproc badtcps {} {
    $self instvar ns_ node_
    Agent/TCP set window_ 100
    # bad traffic

    set tcp [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp set window_ 1000
    set ftp [$tcp attach-app FTP]
    $ns_ at 11.0 "$ftp start"
    $ns_ at 50.0 "$ftp stop"

    set tcp1 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp1 set window_ 1000
    set ftp1 [$tcp attach-app FTP]
    $ns_ at 12.0 "$ftp1 start"
    $ns_ at 49.0 "$ftp1 stop"

    set tcp2 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp2 set window_ 1000
    set ftp2 [$tcp attach-app FTP]
    $ns_ at 13.0 "$ftp2 start"
    $ns_ at 48.0 "$ftp2 stop"

    set tcp3 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp3 set window_ 1000
    set ftp3 [$tcp attach-app FTP]
    $ns_ at 14.0 "$ftp3 start"
    $ns_ at 47.0 "$ftp3 stop"

    set tcp4 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp4 set window_ 1000
    set ftp4 [$tcp attach-app FTP]
    $ns_ at 15.0 "$ftp4 start"
    $ns_ at 46.0 "$ftp4 stop"

    set tcp [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    set ftp [$tcp attach-app FTP]
    $ns_ at 16.0 "$ftp start"
    $ns_ at 45.0 "$ftp stop"

    set tcp1 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    set ftp1 [$tcp attach-app FTP]
    $ns_ at 17.0 "$ftp1 start"
    $ns_ at 44.0 "$ftp1 stop"

    set tcp2 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    set ftp2 [$tcp attach-app FTP]
    $ns_ at 18.0 "$ftp2 start"
    $ns_ at 43.0 "$ftp2 stop"

    set tcp3 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    set ftp3 [$tcp attach-app FTP]
    $ns_ at 19.0 "$ftp3 start"
    $ns_ at 42.0 "$ftp3 stop"

    set tcp4 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    set ftp4 [$tcp attach-app FTP]
    $ns_ at 20.0 "$ftp4 start"
    $ns_ at 41.0 "$ftp4 stop"

    set tcp [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp set window_ 1000
    set ftp [$tcp attach-app FTP]
    $ns_ at 21.0 "$ftp start"
    $ns_ at 40.0 "$ftp stop"

    set tcp1 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp1 set window_ 1000
    set ftp1 [$tcp attach-app FTP]
    $ns_ at 22.0 "$ftp1 start"
    $ns_ at 39.0 "$ftp1 stop"

    set tcp2 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp2 set window_ 1000
    set ftp2 [$tcp attach-app FTP]
    $ns_ at 23.0 "$ftp2 start"
    $ns_ at 38.0 "$ftp2 stop"

    set tcp3 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp3 set window_ 1000
    set ftp3 [$tcp attach-app FTP]
    $ns_ at 24.0 "$ftp3 start"
    $ns_ at 37.0 "$ftp3 stop"

    set tcp4 [$ns_ create-connection TCP/Sack1 $node_(s1) TCPSink/Sack1 $node_(d0) 5 ]
    $tcp4 set window_ 1000
    set ftp4 [$tcp attach-app FTP]
    $ns_ at 25.0 "$ftp4 start"
    $ns_ at 36.0 "$ftp4 stop"

}

TestSuite instproc badcbr {} {
    $self instvar ns_ node_

    set udp [$ns_ create-connection UDP $node_(s0) Null $node_(d1) 5]
    set cbr_ [$udp attach-app Traffic/CBR]
    $cbr_ set rate_ 0.1Mb
    $cbr_ set random_ 0.001

    $ns_ at 0.0 "$cbr_ start"
    $ns_ at 11.0 "$cbr_ set rate_ 0.15Mb"
    $ns_ at 12.0 "$cbr_ set rate_ 0.2Mb"
    $ns_ at 13.0 "$cbr_ set rate_ 0.25Mb"
    $ns_ at 14.0 "$cbr_ set rate_ 0.3Mb"
    $ns_ at 15.0 "$cbr_ set rate_ 0.35Mb"
    $ns_ at 16.0 "$cbr_ set rate_ 0.4Mb"
    $ns_ at 17.0 "$cbr_ set rate_ 0.45Mb"
    $ns_ at 18.0 "$cbr_ set rate_ 0.5Mb"
    $ns_ at 19.0 "$cbr_ set rate_ 0.55Mb"
    $ns_ at 20.0 "$cbr_ set rate_ 0.6Mb"
    $ns_ at 21.0 "$cbr_ set rate_ 0.65Mb"
    $ns_ at 22.0 "$cbr_ set rate_ 0.7Mb"
    $ns_ at 23.0 "$cbr_ set rate_ 0.75Mb"
    $ns_ at 24.0 "$cbr_ set rate_ 0.8Mb"
    $ns_ at 25.0 "$cbr_ set rate_ 0.855Mb"
    $ns_ at 37.0 "$cbr_ set rate_ 0.8Mb"
    $ns_ at 37.0 "$cbr_ set rate_ 0.75Mb"
    $ns_ at 38.0 "$cbr_ set rate_ 0.7Mb"
    $ns_ at 39.0 "$cbr_ set rate_ 0.65Mb"
    $ns_ at 40.0 "$cbr_ set rate_ 0.6Mb"
    $ns_ at 41.0 "$cbr_ set rate_ 0.55Mb"
    $ns_ at 42.0 "$cbr_ set rate_ 0.5Mb"
    $ns_ at 43.0 "$cbr_ set rate_ 0.45Mb"
    $ns_ at 44.0 "$cbr_ set rate_ 0.4Mb"
    $ns_ at 45.0 "$cbr_ set rate_ 0.35Mb"
    $ns_ at 46.0 "$cbr_ set rate_ 0.3Mb"
    $ns_ at 47.0 "$cbr_ set rate_ 0.25Mb"
    $ns_ at 48.0 "$cbr_ set rate_ 0.2Mb"
    $ns_ at 49.0 "$cbr_ set rate_ 0.15Mb"
    $ns_ at 50.0 "$cbr_ set rate_ 0.1Mb"
}

TestSuite instproc setup4 {} {
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
    set maxAggregates_ 6
    $self badcbr

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}

#
# Slowly-growing CBR aggregate competing against small TCP aggregates.
# No ACC.
#
Class Test/tcp -superclass TestSuite
Test/tcp instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp
    $self next noTraceFiles
}
Test/tcp instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup4
    $ns_ run
}

#
# Slowly-growing CBR aggregate competing against small TCP aggregates.
# No pushback, but with local ACC.
#
Class Test/tcp-acc -superclass TestSuite
Test/tcp-acc instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/tcp-acc instproc run {} [Test/tcp info instbody run]
    $self next noTraceFiles
}

TestSuite instproc setup4a {} {
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
    $self badcbr

    $self statsDump $dumptime $fmon $packetsize_ 0
    # trace only the bottleneck link
    #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
    $ns_ at $stoptime1 "$self cleanupAll $testName_"
}

#
# Slowly-growing CBR aggregate competing against large TCP aggregates.
# No ACC.
#
Class Test/tcp1 -superclass TestSuite
Test/tcp1 instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp1
    $self next noTraceFiles
}
Test/tcp1 instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup4a
    $ns_ run
}

#
# Slowly-growing CBR aggregate competing against large TCP aggregates.
# No pushback, but with local ACC.
#
Class Test/tcp1-acc -superclass TestSuite
Test/tcp1-acc instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp1-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/tcp1-acc instproc run {} [Test/tcp1 info instbody run]
    $self next noTraceFiles
}

TestSuite instproc setup4b {} {
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

#
# Slowly-growing TCP aggregate competing against large TCP aggregates.
# No ACC.
#
Class Test/tcp2 -superclass TestSuite
Test/tcp2 instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp2
    $self next noTraceFiles
}
Test/tcp2 instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup4b
    $ns_ run
}

#
# Slowly-growing TCP aggregate competing against large TCP aggregates.
# No pushback, but with local ACC.
#
Class Test/tcp2-acc -superclass TestSuite
Test/tcp2-acc instproc init {} {
    $self instvar net_ test_
    set net_ net2
    set test_ tcp2-acc
    Queue/RED/Pushback set rate_limiting_ 1
    Test/tcp2-acc instproc run {} [Test/tcp2 info instbody run]
    $self next noTraceFiles
}

######################################################33

## TestSuite instproc setup5 {} {
##     $self instvar ns_ node_ testName_ net_ topo_ cbr_ cbr2_ packetsize_
##     $self instvar maxAggregates_
##
##     set stoptime 100.0
##     #set stoptime 5.0
##     #set dumptime 5.0
##     set dumptime 1.0
##     set stoptime1 [expr $stoptime + 1.0]
##     set packetsize_ 200
##     Application/Traffic/CBR set random_ 0
##     Application/Traffic/CBR set packetSize_ $packetsize_
##
##     set slink [$ns_ link $node_(r0) $node_(r1)]; # link to collect stats on
##     set fmon [$ns_ makeflowmon Fid]
##     $ns_ attach-fmon $slink $fmon
##
##     set udp1 [$ns_ create-connection UDP $node_(s0) Null $node_(d0) 1]
##     set cbr1 [$udp1 attach-app Traffic/CBR]
##     $cbr1 set rate_ 0.12Mb
##     $cbr1 set random_ 0.005
##
##     set udp2 [$ns_ create-connection UDP $node_(s1) Null $node_(d1) 2]
##     set cbr2 [$udp2 attach-app Traffic/CBR]
##     $cbr2 set rate_ 0.08Mb
##     $cbr2 set random_ 0.005
##
##     # bad traffic
##     set udp [$ns_ create-connection UDP $node_(s0) Null $node_(d1) 3]
##     set cbr_ [$udp attach-app Traffic/CBR]
##     $cbr_ set rate_ 0.5Mb
##     $cbr_ set random_ 0.001
##     $ns_ at 0.0 "$cbr_ start"
##
##     set udp4 [$ns_ create-connection UDP $node_(s1) Null $node_(d0) 4]
##     set cbr4 [$udp4 attach-app Traffic/CBR]
##     $cbr4 set rate_ 0.07Mb
##     $cbr4 set random_ 0.005
##
##     set udp5 [$ns_ create-connection UDP $node_(s0) Null $node_(d0) 5]
##     set cbr5 [$udp5 attach-app Traffic/CBR]
##     $cbr5 set rate_ 0.06Mb
##     $cbr5 set random_ 0.005
##
##     set udp6 [$ns_ create-connection UDP $node_(s0) Null $node_(d0) 6]
##     set cbr6 [$udp6 attach-app Traffic/CBR]
##     $cbr6 set rate_ 0.05Mb
##     $cbr6 set random_ 0.005
##
##
##     set maxAggregates_ 6
##
##     $ns_ at 0.2 "$cbr1 start"
##     $ns_ at 0.1 "$cbr2 start"
##     $ns_ at 0.3 "$cbr4 start"
##     $ns_ at 0.4 "$cbr5 start"
##
##     $self statsDump $dumptime $fmon $packetsize_ 0
##     # trace only the bottleneck link
##     #$self traceQueues $node_(r1) [$self openTrace $stoptime $testName_]
##     $ns_ at $stoptime1 "$self cleanupAll $testName_"
## }
##
## #
## #
## Class Test/onoff -superclass TestSuite
## Test/onoff instproc init {} {
##     $self instvar net_ test_
##     set net_ net2
##     set test_ onoff
##     $self next noTraceFiles
## }
## Test/onoff instproc run {} {
##     $self instvar ns_ node_ testName_ net_ topo_
##     $self setTopo
##     $self setup5
##     $ns_ run
## }
##
## #
## #
## Class Test/onoff-acc -superclass TestSuite
## Test/onoff-acc instproc init {} {
##     $self instvar net_ test_
##     set net_ net2
##     set test_ onoff-acc
##     Queue/RED/Pushback set rate_limiting_ 1
##     Test/onoff-acc instproc run {} [Test/onoff info instbody run]
##     $self next noTraceFiles
## }
##

######################################################33

TestSuite instproc setup2 {} {
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


#
# CBR flows only, no pushback and no local ACC
#
Class Test/A_noACC -superclass TestSuite
Test/A_noACC instproc init {} {
    $self instvar net_ test_
    set net_ net3
    set test_ A_noACC
    $self next noTraceFiles
}
Test/A_noACC instproc run {} {
    $self instvar ns_ node_ testName_ net_ topo_
    $self setTopo
    $self setup2
    $ns_ run
}

#
# CBR flows only, local ACC
#
Class Test/A_ACC -superclass TestSuite
Test/A_ACC instproc init {} {
    $self instvar net_ test_
    set net_ net3
    set test_ A_ACC
    Queue/RED/Pushback set rate_limiting_ 1
    Agent/Pushback set enable_pushback_ 0
    Test/A_ACC instproc run {} [Test/A_noACC info instbody run]
    $self next noTraceFiles
}

#
# CBR flows only, local and Pushback.
#
Class Test/A_Push -superclass TestSuite
Test/A_Push instproc init {} {
    $self instvar net_ test_
    set net_ net3
    set test_ A_Push
    Queue/RED/Pushback set rate_limiting_ 1
    Agent/Pushback set enable_pushback_ 1
    Test/A_Push instproc run {} [Test/A_noACC info instbody run]
    $self next noTraceFiles
}

TestSuite runTest

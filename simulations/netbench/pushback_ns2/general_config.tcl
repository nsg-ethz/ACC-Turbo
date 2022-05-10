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
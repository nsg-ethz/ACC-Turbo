--- Captures packets, can dump to a pcap file or decode on standard out.
--- This is essentially an extremely fast version of tcpdump, single-threaded stats are:
---  * > 20 Mpps filtering (depending on filter, tested with port range and IP matching)
---  * > 11 Mpps pcap writing (60 byte packets)
--- 
--- This scales very well to multiple core, we achieved the following with 4 2.2 GHz cores:
---  * 20 Mpps pcap capturing (limited by small packet performance of i40e NIC)
---  * 40 Gbit/s pcap capturing of 128 byte packets to file system cache (mmap)
---  * 1900 MB/s (~15 Gbit/s) sustained write speed to a raid of two NVMe SSDs
---
--- Note that the stats shown at the end will probably not add up when plugging this into live traffic:
--- Some packets are simply lost during NIC reset and startup (the NIC counter is a hardware counter).

-- #########
-- IMPORTANT: We log the throughput of malicious and benign traffic separated but place them both into the same output pcap file
-- #########

local lm     = require "libmoon"
local device = require "device"
local memory = require "memory"
local stats  = require "stats"
local eth    = require "proto.ethernet"
local log    = require "log"
local pcap   = require "pcap"
local pf     = require "pf"

function configure(parser)
	parser:argument("dev", "Device to use."):args(1):convert(tonumber)
	parser:option("-f --file", "Write result to a pcap file.")
	parser:option("-s --snap-len", "Truncate packets to this size."):convert(tonumber):target("snapLen")
	parser:option("-t --threads", "Number of threads."):convert(tonumber):default(1)
	-- parser:argument("filter", "A BPF filter expression."):args("*"):combine()
    local args = parser:parse()

    -- we hardcode the filter
	args.filter = "(dst host 20.0.0.50) or (dst host 20.0.0.100) or (dst host 20.0.0.150) or (dst host 20.0.0.200) or (src host 10.0.0.50)"
	if args.filter then
		local ok, err = pcall(pf.compile_filter, args.filter)
		if not ok then
			parser:error(err)
		end
	end
	return args
end

function master(args)
	local dev = device.config{port = args.dev, rxQueues = args.threads, rssQueues = args.threads, dropEnable = false, rxDescs =  4096}
    device.waitForLinks()
	for i = 1, args.threads do
		lm.startTask("dumper", dev:getRxQueue(i - 1), args, i)
	end
	lm.waitForTasks()
end

function dumper(queue, args, threadId)
	-- default: show everything
	local filter = args.filter and pf.compile_filter(args.filter) or function() return true end
	local snapLen = args.snapLen
    local writer
    
    -- we create the packet counters (directly logged to output files in csv format)
    local captureCtr, filterCtr
	captureCtr = stats:newPktRxCounter("Capture benign", "CSV", "run_fig_06b/results/accturbo_throughput_benign.dat")
    filterCtr = stats:newPktRxCounter("Capture malicious", "CSV", "run_fig_06b/results/accturbo_throughput_malicious.dat")

	if args.file then
		if args.threads > 1 then
			if args.file:match("%.pcap$") then
				args.file = args.file:gsub("%.pcap$", "")
			end
			args.file = args.file .. "-thread-" .. threadId .. ".pcap"
		else
			if not args.file:match("%.pcap$") then
				args.file = args.file .. ".pcap"
			end
		end
		writer = pcap:newWriter(args.file)
	end
	
	local bufs = memory.bufArray()
	while lm.running() do
		local rx = queue:tryRecv(bufs, 100)
		local batchTime = lm.getTime()
		for i = 1, rx do
            local buf = bufs[i]
            
            -- We first print every received packet into an output pcap (both malicious=filtered and benign=non-filtered)
            if writer then
                writer:writeBuf(batchTime, buf, snapLen)
            -- else
                -- buf:dump()
            end

            -- We now compute the individual throughputs
			if filter(buf:getBytes(), buf:getSize()) then

				-- This is the filtered traffic (i.e., malicious)
				filterCtr:countPacket(buf)
	
			else

				-- This is the non-filtered traffic (i.e., benign)
				captureCtr:countPacket(buf)
				
			end
			buf:free()
		end
        captureCtr:update()
        filterCtr:update()
    end

    -- We close the counters
    captureCtr:finalize()
	filterCtr:finalize()
    log:info("Flushing buffers, this can take a while...")

    -- We close the pcap writer
	if writer then
		writer:close()
	end
end


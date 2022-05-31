local lm     = require "libmoon"
local device = require "device"
local memory = require "memory"
local stats  = require "stats"
local eth    = require "proto.ethernet"
local log    = require "log"
local pcap   = require "pcap"
local pf     = require "pf"

function configure(parser)
    local args = parser:parse()

    -- we hardcode the filter
	args.filter = "(src host 1.1.1.1)"
	if args.filter then
		local ok, err = pcall(pf.compile_filter, args.filter)
		if not ok then
			parser:error(err)
		end
	end
	return args
end

function master(args)
	local dev = device.config{port = 2, rxQueues = 1, rssQueues = 1, dropEnable = false, rxDescs =  4096}
    device.waitForLinks()

	lm.startTask("dumper", dev:getRxQueue(0), args)
	lm.waitForTasks()
end

function dumper(queue, args)

	local filter = args.filter and pf.compile_filter(args.filter) or function() return true end
    
    -- we create the packet counters (directly logged to output files in csv format)
    local captureCtr, filterCtr
	captureCtr = stats:newPktRxCounter("Capture program 2", "CSV", "run_fig_07c/results/throughput_program2.dat")
    filterCtr = stats:newPktRxCounter("Capture program 1", "CSV", "run_fig_07c/results/throughput_program1.dat")
	
	local bufs = memory.bufArray()
	while lm.running() do
		local rx = queue:tryRecv(bufs, 100)
		local batchTime = lm.getTime()
		for i = 1, rx do
            local buf = bufs[i]
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
end


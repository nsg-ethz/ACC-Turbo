local mg     = require "moongen"
local memory = require "memory"
local device = require "device"
local ts     = require "timestamping"
local filter = require "filter"
local hist   = require "histogram"
local stats  = require "stats"
local timer  = require "timer"
local arp    = require "proto.arp"
local log    = require "log"
local pipe   = require "pipe"
local ffi    = require "ffi"

-- set addresses here
local DST_MAC		= "00:25:90:33:aa:db" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local DST_MAC_2		= "00:25:90:35:dc:cb" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP_BASE_1	= "10.0.0.2"
local DST_IP_BASE_1	= "10.0.0.1"
local DST_IP		= "10.0.1.2"
local SRC_PORT		= 1234
local DST_PORT		= 6000

local NUM_PKTS		= 10^7 -- each sender task should send ten million packets
local BATCH_SIZE    = 5    -- number of packets sent in one buffer/batch
local N_RECORD		= 1000
local NO_RW			= 1

function configure(parser)
	parser:description("Generates UDP traffic for three interfaces. Edit the source to modify constants like IPs.")
	parser:argument("txDev1", "First device to transmit from."):convert(tonumber)
	parser:argument("txDev2", "Second device to transmit from."):convert(tonumber)
	parser:option("-r --rate", "Transmit rate in Mbit/s."):default(10000):convert(tonumber)
	parser:option("-f --flows", "Number of flows (randomized source IP)."):default(4):convert(tonumber)
	parser:option("-s --size", "Packet size."):default(60):convert(tonumber)
end

function master(args)
	-- three queues per device
	txDev1 = device.config{port = args.txDev1, speed = args.rate, txQueues = 4, rxQueues = 4}
	txDev2 = device.config{port = args.txDev2, speed = args.rate, txQueues = 4, rxQueues = 4}
	
	device.waitForLinks()
	
	txDev1:setRate(args.rate)
	txDev2:setRate(args.rate)
    -- txDev1:getTxQueue(0):setRate(args.rate)

	local pipeSender_1 = pipe:newFastPipe()
	local pipeReceiver_1 = pipe:newFastPipe()
	local cat1_1 = math.random(0, 2^32-1)
	local cat2_1 = math.random(0, 2^32-1)
	local startNumSender_1 = math.random(0, 2^32-1)
	local startNumReceiver_1 = math.random(0, 2^32-1)

	mg.startTask("sender", txDev1:getTxQueue(0), args.size, args.flows, pipeSender_1, cat1_1, cat2_1, startNumSender_1, 1, 1, "send_1")
	mg.startTask("receiver", txDev1:getRxQueue(0), args.size, args.flows, pipeSender_1, 1, startNumReceiver_1, "rcv_1")

	mg.startTask("receiver", txDev2:getRxQueue(0), args.size, args.flows, pipeReceiver_1, 0, startNumSender_1, "rcv_2")
	mg.startTask("sender", txDev2:getTxQueue(0), args.size, args.flows, pipeReceiver_1, cat1_1, cat2_1, startNumReceiver_1, 0, 1, "send_2")
	
	mg.waitForTasks()
end

local function fillUdpPacketSend(buf, len)
	buf:getUdpPacket():fill{
		ethSrc = queue,
		ethDst = DST_MAC,
		ip4Src = SRC_IP,
		ip4Dst = DST_IP,
		udpSrc = SRC_PORT,
		udpDst = DST_PORT,
		pktLength = len
	}
end

local function fillUdpPacketRcv(buf, len)
	buf:getUdpPacket():fill{
		ethSrc = queue,
		ethDst = DST_MAC_2,
		ip4Src = SRC_IP,
		ip4Dst = DST_IP,
		udpSrc = DST_PORT,
		udpDst = SRC_PORT,
		pktLength = len
	}
end

ffi.cdef[[
	struct share { uint32_t time; }
]]

-- use bufs[i].udata64

function sender(queue, size, flows, pipe, cat1, cat2, startNum, is_origin, flow_num, f_name)
	local mempool = nil
	if is_origin == 1 then
		mempool = memory.createMemPool(function(buf)
			fillUdpPacketSend(buf, size)
		end)
	else
		mempool = memory.createMemPool(function(buf)
			fillUdpPacketRcv(buf, size)
		end)
	end
	local bufs = mempool:bufArray(BATCH_SIZE) -- limits number of packets sent in one batch (not sure if that is really working)
	local counter = 0
	local pkt_count = startNum
	local txCtr = stats:newDevTxCounter(queue, "plain")
	local baseIP = nil
	local baseIP_dst = nil
	local current = 1
	local save = {}
	local times = {}
	
	if NO_RW ~= 1 then
		baseIP = parseIPAddress(SRC_IP_BASE_1)
		baseIP_dst = parseIPAddress(DST_IP_BASE_1)

		if is_origin ~= 1 then
			baseIP = parseIPAddress(DST_IP)
			baseIP_dst = baseIP_dst
		end
	else
		baseIP = parseIPAddress(SRC_IP_BASE_1)
		baseIP_dst = parseIPAddress(DST_IP)

		if is_origin ~= 1 then
			baseIP = parseIPAddress(DST_IP)
			baseIP_dst = parseIPAddress(SRC_IP_BASE_1)
		end
	end

	local data = memory.alloc("struct share*", ffi.sizeof("struct share"))
	data.time = 0
	pipe:send(data)

	-- make sure that receiver are running before sending the first packets
	mg.sleepMillis(2000)

	-- make sure that we first start to send from client to server
	if is_origin ~= 1 then
		mg.sleepMillis(100)
	end

	local j = 0
	local keep = N_RECORD

	while j < NUM_PKTS and mg.running() do
		--print(luasocket.gettime())
		bufs:alloc(size)
		for i, buf in ipairs(bufs) do
			local pkt = buf:getUdpPacket()
			pkt.ip4.src:set(baseIP)
			pkt.ip4.dst:set(baseIP_dst)

			pkt.payload.uint32[0] = 0xf07f00d8
			pkt.payload.uint32[1] = cat1
			pkt.payload.uint32[2] = cat2
			pkt.payload.uint32[3] = bit.bswap(pkt_count)
			pkt.payload.uint32[4] = data.time
			if j == keep then
				keep = keep + N_RECORD
				pkt.payload.uint32[5] = 1
				save[current] = pkt.payload.uint32[3]
				times[current] = mg.getTime()
				current = current + 1
				-- buf:dump()
			else
				pkt.payload.uint32[5] = 0
			end
			
			pkt_count = pkt_count + 1

			counter = incAndWrap(counter, flows)

			j = j + 1

			-- print(bit.bswap(pkt_count))
			
			-- if pkt.payload.uint32[3] % N_RECORD == 0 then
			-- 	save[current] = pkt.payload.uint32[3]
			-- 	times[current] = mg.getTime()
			-- end
			
			-- keep = keep + 1
			-- if keep == N_RECORD then
			-- 	save[current] = pkt.payload.uint32[3]
			-- 	times[current] = mg.getTime()
			-- 	current = current + 1
			-- 	keep = 0
			-- end
		end
		-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
		bufs:offloadUdpChecksums()
		queue:send(bufs)
		txCtr:update()

	end

	local f = io.open(f_name, "w")
	for i, v in ipairs(save) do
		f:write(v, " ", times[i], "\n")
	end
	f:close()

	print('Sent pkts:', pkt_count-startNum)

	txCtr:finalize()

	-- perhaps helps to receive the last packets?
	mg.sleepMillis(2000)
end

function receiver(queue, size, flows, pipe, is_origin, startNum, f_name)
	local bufs = memory.bufArray()

	local counter = 0
	local pkt_count = 0
	local save = {}
	local times = {}
	local rxCtr = stats:newDevRxCounter(queue, "plain")
	local keep = 0
	local current = 1
	local data = ffi.cast("struct share*", pipe:recv())

	local not_correct = 0

	while mg.running() do
		local rx = queue:recv(bufs)
		for i = 1, rx do
			local pkt = bufs[i]:getUdpPacket()
			
			if is_origin == 1 then
				if pkt.ip4.dst:get() ~= 167772162 then
					not_correct = not_correct + 1
				end
			else
				if pkt.ip4.dst:get() ~= 167772418 then
					not_correct = not_correct + 1
				end
			end

			if pkt.payload.uint32[5] == 1 then
				-- bufs[i]:dump()
				save[current] = pkt.payload.uint32[3]
				times[current] = mg.getTime()
				current = current + 1
			end

			data.time = pkt.payload.uint32[3]
			counter = incAndWrap(counter, flows)
			pkt_count = pkt_count + 1

			--print(pkt.payload.uint32[5])

			-- if pkt.payload.uint32[3] % N_RECORD == 0 then
			-- 	save[current] = pkt.payload.uint32[3]
			-- 	times[current] = mg.getTime()
			-- end

			-- keep = keep + 1
			-- if keep == N_RECORD then
			-- 	save[current] = pkt.payload.uint32[3]
			-- 	times[current] = mg.getTime()
			-- 	current = current + 1
			-- 	keep = 0
			-- end
		end
		rxCtr:update()
		bufs:freeAll()
	end

	print('Received pkts:', pkt_count)	

	rxCtr:finalize()

	print('Not correct:', not_correct)

	memory.free(data)

	local f = io.open(f_name, "w")
	for i, v in ipairs(save) do
		f:write(v, " ", times[i], "\n")
	end
	f:close()

end

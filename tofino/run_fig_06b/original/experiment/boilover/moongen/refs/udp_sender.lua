local mg	= require "moongen"
local memory	= require "memory"
local device	= require "device"
local stats	= require "stats"
local log 	= require "log"

-- set addresses here
local DST_MAC           = "98:03:9b:4d:d7:9c" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP		    = "10.0.0.1" -- actual address will be SRC_IP_BASE + random(0, flows) for first interface
local DST_IP            = "10.0.0.2"
local SRC_PORT_BASE     = 1234
local DST_PORT          = 1234

function configure(parser)
	parser:description("Generates UDP traffic to test bandwidth, supports both IPv4 and IPv6")
	parser:argument("txDev1", "First device to transmit from."):convert(tonumber)
	parser:option("-r --rate", "Transmit rate in Mbit/s."):default(20000):convert(tonumber)
	parser:option("-f --flows", "Number of flows (randomized source IP)."):default(1):convert(tonumber)
	parser:option("-s --size", "Packet size."):default(1200):convert(tonumber)
end

function sleep(sec)
    os.execute("sleep " .. tonumber(sec))
end

function master(args)
	-- we just have one "device" which is the 100G interface, and we allocate it 4 queues
	txDev1 = device.config{port = args.txDev1, speed = args.rate, txQueues = 4}
	device.waitForLinks()
	mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 1)
	sleep(5)
	mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 2)
	sleep(5)
	mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 3)
	sleep(5)
	mg.startTask("loadSlave", txDev1:getTxQueue(3), args.size, args.flows, 4)
end

function loadSlave(queue, size, flows, thread_id)
		local mem = memory.createMemPool(function(buf)
			buf:getUdpPacket():fill{ 
				ethSrc = queue,
				ethDst = DST_MAC,
				ip4Src = SRC_IP,
				ip4Dst = DST_IP,
				ip4TOS = 0,
				ipv4Length = 0,
				ip4TTL = 0,
				-- ipProtocol
				ip4ID  = 0,
				udpSrc = SRC_PORT_BASE,
				udpDst = DST_PORT,
				pktLength = size
				-- udpLength
				-- udpChecksum 
			}
		end)

		-- a bufArray is just a list of buffers from a mempool that is processed as a single batch
		local bufs = mem:bufArray()
        if num == 1 then
			TTL = 0
		elseif num == 2 then
			TTL = 50
		elseif num == 3 then
			TTL = 100
		elseif num == 4 then
			TTL = 150

		end 

		while mg.running() do -- check if Ctrl+c was pressed
		-- this actually allocates some buffers from the mempool the array is associated with
				-- this has to be repeated for each send because sending is asynchronous, we cannot reuse the old buffers here
				bufs:alloc(size)
				for i, buf in ipairs(bufs) do
					-- packet framework allows simple access to fields in complex protocol stacks
					local pkt = buf:getUdpPacket()
					-- We set the ttl according to the threat id
					pkt.ip4:setTTL(TTL)
					pkt.udp:setSrcPort(SRC_PORT_BASE + math.random(0, flows - 1))
				end
				-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
				-- UDP checksum offloading is comparatively slow: NICs typically do not support calculating the pseudo-header checksum so this is done in SW
				bufs:offloadUdpChecksums()
				-- send out all packets and frees old bufs that have been sent
				queue:send(bufs)
		end
end
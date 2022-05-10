--- On one queue: Replay a pcap file add payload to the packets according to their IP length
--- On the other queues: Generate a DDoS attack on top

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
local pcap    = require "pcap"
local limiter = require "software-ratecontrol"

-- set addresses here
local DST_MAC           = "3c:fd:fe:b4:98:91" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP            = "10.0.0.0" -- actual address will be SRC_IP_BASE + random(0, flows) for first interface
local DST_IP            = "20.0.0.0"
local SRC_PORT          = 111
local DST_PORT          = 222

function configure(parser)
        -- general configs
        parser:description("Generates traffic by reading a pcap file, while running crafted attacks on top.")
        parser:argument("dev", "Device to use."):default(3):convert(tonumber)

        -- configs for the pcap generation
        parser:argument("file", "File to replay."):args(1)
        parser:option("-pr --pcap-rate-multiplier", "Speed up or slow down replay, 1 = use intervals from file, default = replay as fast as possible"):default(0):convert(tonumber):target("rateMultiplier")
        parser:flag("-l --loop", "Repeat pcap file.")

        -- configs for the attack generation
        parser:option("-ar --attack_rate", "Attack transmission rate in Mbit/s."):default(10000):convert(tonumber)
        parser:option("-f --flows", "Number of flows (randomized source IP)."):default(1):convert(tonumber)
        parser:option("-s --size", "Packet size."):default(1200):convert(tonumber)

        local args = parser:parse()
        return args
end

function master(args)
        -- we set 4 queues to the interface
        local dev = device.config{port = args.dev, txQueues = 4}
	device.waitForLinks()

        -- replay pcap using the first queue
        local rateLimiter
        if args.rateMultiplier > 0 then
                rateLimiter = limiter:new(dev:getTxQueue(0), "custom")
        end
        mg.startTask("replay_pcap", dev:getTxQueue(0), args.file, args.loop, rateLimiter, args.rateMultiplier)
        stats.startStatsTask{txDevices = {dev}}

        -- starts multiple threads increasing performance
        mg.sleepMillis(10000)
        mg.startTask("launch_attack", dev:getTxQueue(1), args.size, args.flows, 1)
        mg.startTask("launch_attack", dev:getTxQueue(2), args.size, args.flows, 1)
        mg.startTask("launch_attack", dev:getTxQueue(3), args.size, args.flows, 1)
        mg.sleepMillis(20000)
        mg.startTask("launch_attack", dev:getTxQueue(1), args.size, args.flows, 2)
        mg.startTask("launch_attack", dev:getTxQueue(2), args.size, args.flows, 2)
        mg.startTask("launch_attack", dev:getTxQueue(3), args.size, args.flows, 2)
        mg.sleepMillis(20000)
        mg.startTask("launch_attack", dev:getTxQueue(1), args.size, args.flows, 3)
        mg.startTask("launch_attack", dev:getTxQueue(2), args.size, args.flows, 3)
        mg.startTask("launch_attack", dev:getTxQueue(3), args.size, args.flows, 3)
        mg.sleepMillis(20000)
        mg.startTask("launch_attack", dev:getTxQueue(1), args.size, args.flows, 4)
        mg.startTask("launch_attack", dev:getTxQueue(2), args.size, args.flows, 4)
        mg.startTask("launch_attack", dev:getTxQueue(3), args.size, args.flows, 4)
        mg.sleepMillis(20000)
        
        -- monitor progress
        mg.waitForTasks()
end

function launch_attack(queue, size, flows, num)
        mg.sleepMillis(100) -- wait a few milliseconds to ensure that the rx thread is running
        
        local mempool = memory.createMemPool(function(buf)
                buf:getUdpPacket():fill{ 
                        ethSrc = queue, -- get the src mac from the device
                        ethDst = DST_MAC,
                        ip4Src = SRC_IP,
                        ip4Dst = DST_IP, -- ipDst will be modified later as it varies
                        ip4TOS = 0,
                        ipv4Length = 0,
                        ip4TTL = 250,
                        -- ipProtocol
                        ip4ID  = 0,
                        udpSrc = SRC_PORT,
                        udpDst = DST_PORT,
                        pktLength = size -- this sets all length headers fields in all used protocols
                        -- udpLength
                        -- udpChecksum 
                        -- payload will be initialized to 0x00 as new memory pools are initially empty
                }
        end)

        local bufs = mempool:bufArray() -- a buf array is essentially a very thing wrapper around a rte_mbuf*[], i.e. an array of pointers to packet buffers
        RUN_TIME = 10 -- seconds
	local runtime = timer:new(RUN_TIME)
        while mg.running() and runtime:running() do -- check if Ctrl+c was pressed
        	-- this actually allocates some buffers from the mempool the array is associated with
		-- this has to be repeated for each send because sending is asynchronous, we cannot reuse the old buffers here
                bufs:alloc(size)
                for i, buf in ipairs(bufs) do
        		-- packet framework allows simple access to fields in complex protocol stacks
                        local pkt = buf:getUdpPacket()
                        -- We set the IP according to the id
                        local DST_IP_MOD = nil
                        if num == 1 then
                                DST_IP_MOD = parseIPAddress("20.0.0.50")
                        elseif num == 2 then
                                DST_IP_MOD = parseIPAddress("20.0.0.100")
                        elseif num == 3 then
                                DST_IP_MOD = parseIPAddress("20.0.0.150")
                        elseif num == 4 then
                                DST_IP_MOD = parseIPAddress("20.0.0.200")
                        end
                        pkt.ip4.dst:set(DST_IP_MOD)
                        -- pkt.ip4:setTTL(TTL)
                        -- pkt.udp:setSrcPort(SRC_PORT_BASE + math.random(0, flows - 1)
                        -- select a randomized source IP address
                        -- we can also use a wrapping counter instead of random
                        -- pkt.ip4.src:set(baseIP + math.random(NUM_FLOWS) - 1)
                end
                -- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
                -- UDP checksum offloading is comparatively slow: NICs typically do not support calculating the pseudo-header checksum so this is done in SW
                bufs:offloadUdpChecksums()
                -- send out all packets and frees old bufs that have been sent
                queue:send(bufs)
        end
end

function replay_pcap(queue, file, loop, rateLimiter, multiplier)
        local mempool = memory:createMemPool(4096)
        local bufs = mempool:bufArray()
        local pcapFile = pcap:newReader(file)
        local prev = 0
        local linkSpeed = queue.dev:getLinkStatus().speed
        while mg.running() do
                local n = pcapFile:read(bufs)
                if n > 0 then
                        if rateLimiter ~= nil then
                                if prev == 0 then
                                        prev = bufs.array[0].udata64
                                end
                                for i, buf in ipairs(bufs) do

                                        local pkt = buf:getIPPacket()
                                        -- local payLength = 100
                                        local payLength = 10
                                        -- local payLength = pkt.getLength()

                                        local j=0
                                        while j < payLength do
                                            -- NOTE: (i - offset) is to remove the 16 byte initial offset.
                                            pkt.payload.uint8[j] = 255
                                            -- pkt.payload.uint8[i] = string.byte(constants.defaultPayload, i - offset + 1) or 0
                                            
                                            j = j + 1
                                        end

                                        -- ts is in microseconds
                                        local ts = buf.udata64
                                        if prev > ts then
                                                ts = prev
                                        end
                                        local delay = ts - prev
                                        delay = tonumber(delay * 10^3) / multiplier -- nanoseconds
                                        delay = delay / (8000 / linkSpeed) -- delay in bytes
                                        buf:setDelay(delay)
                                        prev = ts
                                end
                        end
                else
                        if loop then
                                pcapFile:reset()
                        else
                                break
                        end
                end
                if rateLimiter then
                        rateLimiter:sendN(bufs, n)
                else
                        queue:sendN(bufs, n)
                end
        end
end
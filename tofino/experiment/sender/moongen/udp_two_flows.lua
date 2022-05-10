--- On one queue: Replay a pcap file
--- On the other queues: Generate a DDoS attack on top

local mg      = require "moongen"
local device  = require "device"
local memory  = require "memory"
local stats   = require "stats"
local log     = require "log"
local pcap    = require "pcap"
local limiter = require "software-ratecontrol"
local timer  = require "timer"

function configure(parser)
        -- general configs
        parser:argument("dev", "Device to use."):default(3):convert(tonumber)

        -- configs for the pcap generation
        parser:argument("file", "File to replay."):args(1)
        parser:option("-pr --pcap-rate-multiplier", "Speed up or slow down replay, 1 = use intervals from file, default = replay as fast as possible"):default(0):convert(tonumber):target("rateMultiplier")
        parser:flag("-l --loop", "Repeat pcap file.")

        local args = parser:parse()
        return args
end

function master(args)
        -- we set 5 queues to the interface
        local dev = device.config{port = args.dev, txQueues = 12}
	    device.waitForLinks()

        -- ATTACK GENERATION
        local flows = 1
        local packetSize = 1200

        -- 5G (dstip = "1.1.1.1")
        mg.startTask("launch_flashcrowd", dev:getTxQueue(1), packetSize, flows, 1)

        -- 1G each (dstip = "5.5.5.5")
        mg.startTask("launch_prioritized", dev:getTxQueue(2), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(3), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(4), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(5), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(6), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(7), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(8), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(9), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(10), packetSize, flows, 1)
        mg.startTask("launch_prioritized", dev:getTxQueue(11), packetSize, flows, 1)

        -- monitor progress
        stats.startStatsTask{txDevices = {dev}}
        mg.sleepMillis(100000)
        mg.stop()
        mg.waitForTasks()
end

function launch_flashcrowd(queue, size, flows, id)
        
        -- attack packet configuration
        local DST_MAC           = "3c:fd:fe:b4:98:91" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
        local SRC_IP            = "10.0.0.50"
        local DST_IP            = "5.5.5.5"
        local SRC_PORT          = 111
        local DST_PORT          = 222

        local mempool = memory.createMemPool(function(buf)
                buf:getUdpPacket():fill{ 
                        ethSrc = queue, -- get the src mac from the device
                        ethDst = DST_MAC,
                        ip4Src = SRC_IP,
                        ip4Dst = DST_IP,
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
        --RUN_TIME = 80 -- seconds
	--local runtime = timer:new(RUN_TIME)
        --while mg.running() and runtime:running() do -- check if Ctrl+c was pressed
        while mg.running() do
        	-- this actually allocates some buffers from the mempool the array is associated with
		-- this has to be repeated for each send because sending is asynchronous, we cannot reuse the old buffers here
                bufs:alloc(size)
                
                -- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
                -- UDP checksum offloading is comparatively slow: NICs typically do not support calculating the pseudo-header checksum so this is done in SW
                bufs:offloadUdpChecksums()
                -- send out all packets and frees old bufs that have been sent
                queue:send(bufs)
                -- Rate limiting
                mg.sleepMicros(118) -- tunned such that each attack sends at 5Gbps with framing
        end
end


function launch_prioritized(queue, size, flows, id)
        
    -- attack packet configuration
    local DST_MAC           = "3c:fd:fe:b4:98:91" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
    local SRC_IP            = "10.0.0.50"
    local DST_IP            = "1.1.1.1"
    local SRC_PORT          = 111
    local DST_PORT          = 222

    local mempool = memory.createMemPool(function(buf)
            buf:getUdpPacket():fill{ 
                    ethSrc = queue, -- get the src mac from the device
                    ethDst = DST_MAC,
                    ip4Src = SRC_IP,
                    ip4Dst = DST_IP,
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
    --RUN_TIME = 80 -- seconds
--local runtime = timer:new(RUN_TIME)
    --while mg.running() and runtime:running() do -- check if Ctrl+c was pressed
    while mg.running() do
        -- this actually allocates some buffers from the mempool the array is associated with
    -- this has to be repeated for each send because sending is asynchronous, we cannot reuse the old buffers here
            bufs:alloc(size)
            
            -- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
            -- UDP checksum offloading is comparatively slow: NICs typically do not support calculating the pseudo-header checksum so this is done in SW
            bufs:offloadUdpChecksums()
            -- send out all packets and frees old bufs that have been sent
            queue:send(bufs)
            -- Rate limiting
            mg.sleepMicros(610) -- tunned such that each attack sends at 10Gbps with framing
    end
end
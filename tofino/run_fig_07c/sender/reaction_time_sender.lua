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

function configure(parser)
        -- general configs
        parser:argument("dev", "Device to use."):default(3):convert(tonumber)
        local args = parser:parse()
        return args
end

function master(args)

        -- we set 1 queue to the interface
        local dev = device.config{port = args.dev, txQueues = 1}
	device.waitForLinks()

        -- udp flow generation
        local packetSize = 1200
        mg.startTask("udp_flow", dev:getTxQueue(0), packetSize)
        stats.startStatsTask{txDevices = {dev}}

        -- duration experiment
        mg.sleepMillis(150000)
        mg.stop()

        -- monitor progress
        mg.waitForTasks()
end

function udp_flow(queue, size)
        
        -- attack packet configuration
        local DST_MAC           = "3c:fd:fe:b4:98:91" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
        local SRC_IP            = "10.0.0.50"
        local DST_IP            = "20.0.0.50"
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
        while mg.running() do -- check if Ctrl+c was pressed
        	-- this actually allocates some buffers from the mempool the array is associated with
		-- this has to be repeated for each send because sending is asynchronous, we cannot reuse the old buffers here
                bufs:alloc(size)
                
                -- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
                -- UDP checksum offloading is comparatively slow: NICs typically do not support calculating the pseudo-header checksum so this is done in SW
                bufs:offloadUdpChecksums()
                -- send out all packets and frees old bufs that have been sent
                queue:send(bufs)
        end
end
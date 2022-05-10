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

-- set addresses here
local DST_MAC           = "3c:fd:fe:b4:98:91" -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP_BASE_1     = "192.168.5.3" -- actual address will be SRC_IP_BASE + random(0, flows) for first interface
local SRC_IP_BASE_2     = "192.168.5.2" -- actual address will be SRC_IP_BASE + random(0, flows) for second interface
local SRC_IP_BASE_3     = "192.168.5.1" -- actual address will be SRC_IP_BASE + random(0, flows) for third interface
local DST_IP            = "192.168.5.4"
local SRC_PORT          = 1234
local DST_PORT          = 319

function configure(parser)
        parser:description("Generates UDP traffic for three interfaces. Edit the source to modify constants like IPs.")
        parser:argument("txDev1", "First device to transmit from."):convert(tonumber)
        parser:argument("txDev2", "Second device to transmit from."):convert(tonumber)
        parser:argument("txDev3", "Third device to transmit from."):convert(tonumber)
        parser:option("-r --rate", "Transmit rate in Mbit/s."):default(10000):convert(tonumber)
        parser:option("-f --flows", "Number of flows (randomized source IP)."):default(4):convert(tonumber)
        parser:option("-s --size", "Packet size."):default(60):convert(tonumber)
end

function sleep(sec)
    os.execute("sleep " .. tonumber(sec))
end

function master(args)
        -- three queues per device
        txDev1 = device.config{port = args.txDev1, speed = args.rate, txQueues = 3}
        txDev2 = device.config{port = args.txDev2, speed = args.rate, txQueues = 3}
        txDev3 = device.config{port = args.txDev3, speed = args.rate, txQueues = 3}

        device.waitForLinks()

        txDev1:setRate(args.rate)
        txDev2:setRate(args.rate)
        txDev3:setRate(args.rate)

        -- starts multiple threads increasing performance
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 1)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 1)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 1)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 2)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 2)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 2)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 3)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 3)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 3)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 4)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 4)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 4)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 5)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 5)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 5)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 6)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 6)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 6)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 7)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 7)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 7)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 8)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 8)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 8)
        sleep(20)
        mg.startTask("loadSlave", txDev1:getTxQueue(0), args.size, args.flows, 9)
        mg.startTask("loadSlave", txDev1:getTxQueue(1), args.size, args.flows, 9)
        mg.startTask("loadSlave", txDev1:getTxQueue(2), args.size, args.flows, 9)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 10)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 10)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 10)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 11)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 11)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 11)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 12)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 12)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 12)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 13)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 13)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 13)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 14)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 14)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 14)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 15)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 15)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 15)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 16)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 16)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 16)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 17)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 17)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 17)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 18)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 18)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 18)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 19)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 19)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 19)
        sleep(20)
        mg.startTask("loadSlave", txDev2:getTxQueue(0), args.size, args.flows, 20)
        mg.startTask("loadSlave", txDev2:getTxQueue(1), args.size, args.flows, 20)
        mg.startTask("loadSlave", txDev2:getTxQueue(2), args.size, args.flows, 20)
        mg.waitForTasks()
end

function loadSlave(queue, size, flows, num)
        local mempool = memory.createMemPool(function(buf)
                fillUdpPacket(buf, size)
        end)
        local bufs = mempool:bufArray()
        local counter = 0
        local txCtr = stats:newDevTxCounter(queue, "plain")
        local baseIP = nil
        if num == 1 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 2 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 3 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 4 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 5 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 6 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 7 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 8 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 9 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 10 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 11 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 12 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 13 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 14 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 15 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 16 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 17 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 18 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 19 then
                baseIP = parseIPAddress("192.168.5.3")
        elseif num == 20 then
                baseIP = parseIPAddress("192.168.5.3")


        end

        while mg.running() do
                bufs:alloc(size)
                for i, buf in ipairs(bufs) do
                        local pkt = buf:getUdpPacket()
                        pkt.ip4.src:set(baseIP + counter)
                        counter = incAndWrap(counter, flows)
                end
                -- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
                bufs:offloadUdpChecksums()
                queue:send(bufs)
                txCtr:update()
        end
        txCtr:finalize()
end
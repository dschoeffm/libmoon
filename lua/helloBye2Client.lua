local ffi = require "ffi"
local memory = require "memory"
local log = require "log"
local utils = require "utils"

ffi.cdef[[
void *HelloBye2_Client_init();

void HelloBye2_Client_config(uint32_t srcIP, uint16_t dstPort);

void *HelloBye2_Client_connect(void *obj, struct rte_mbuf **inPkts, unsigned int inCount,
	unsigned int *sendCount, unsigned int *freeCount, uint32_t dstIP, uint16_t srcPort,
	uint64_t ident);

void HelloBye2_Client_getPkts(
	void *obj, struct rte_mbuf **sendPkts, struct rte_mbuf **freePkts);

void *HelloBye2_Client_process(void *obj, struct rte_mbuf **inPkts, unsigned int inCount,
	unsigned int *sendCount, unsigned int *freeCount);

void HelloBye2_Client_free(void *obj);
]]

local mod = {}

function mod.init()
	return ffi.C.HelloBye2_Client_init()
end

function mod.config(srcIP, dstPort)
	ffi.C.HelloBye2_Client_config(parseIP4Address(srcIP), dstPort)
end

function mod.process(obj, inPkts, inCount)
	ret = {}

	if 0 < inCount then
--		log:info("helloByeClient.process() called (>0 packets)")

		local sendBufsCount = ffi.new("unsigned int[1]")
		local freeBufsCount = ffi.new("unsigned int[1]")

		local ba = ffi.C.HelloBye2_Client_process(obj, inPkts, inCount, sendBufsCount,
		freeBufsCount)

		local sendBufs = memory.bufArray(sendBufsCount[0])
		local freeBufs = memory.bufArray(freeBufsCount[0])

		ffi.C.HelloBye2_Client_getPkts(ba, sendBufs.array, freeBufs.array)

		sendBufs.size = sendBufsCount[0]
		ret.send = sendBufs
		ret.sendCount = sendBufsCount[0]

		freeBufs:freeAll()
	else
		ret.sendCount = 0
	end

	return ret
end

function mod.connect(mempool, obj, dstIP, srcPort, ident, bSize)
	local bufArray = mempool:bufArray(bSize)
	bufArray:alloc(100)

	local sendBufsAll = memory.bufArray(bSize)

	for i = 1,bSize do
		local sendBufsCount = ffi.new("unsigned int[1]")
		local freeBufsCount = ffi.new("unsigned int[1]")

		local bAC = ffi.C.HelloBye2_Client_connect(obj, bufArray.array + (i-1), 1, sendBufsCount,
		freeBufsCount, dstIP, srcPort, ident +( i-1))

		local freeBufs = memory.bufArray(freeBufsCount[0])

		ffi.C.HelloBye2_Client_getPkts(bAC, sendBufsAll.array + (i-1), freeBufs.array)

	end

	sendBufsAll.size = bSize

	ret = {}

	ret.send = sendBufsAll
	ret.sendCount = bSize

	return ret
end

function mod.free(obj)
	ffi.C.HelloBye2_Client_free(obj)
end

return mod

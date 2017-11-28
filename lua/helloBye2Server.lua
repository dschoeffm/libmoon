local ffi = require "ffi"
local memory = require "memory"
local log = require "log"

ffi.cdef[[
void *HelloBye2_Server_init();

void *HelloBye2_Server_process(void *obj, struct rte_mbuf **inPkts, unsigned int inCount,
	unsigned int *sendCount, unsigned int *freeCount);

void HelloBye2_Server_getPkts(
	void *obj, struct rte_mbuf **sendPkts, struct rte_mbuf **freePkts);

void HelloBye2_Server_free(void *obj);
]]

local mod = {}

function mod.init()
	return ffi.C.HelloBye2_Server_init()
end

function mod.process(obj, inPkts, inCount)
	ret = {}

	if 0 < inCount then
		log:info("helloBye.process() called (>0 packets)")

		local sendBufsCount = ffi.new("unsigned int[1]")
		local freeBufsCount = ffi.new("unsigned int[1]")

		local ba = ffi.C.HelloBye2_Server_process(obj, inPkts, inCount, sendBufsCount,
		freeBufsCount)

		local sendBufs = memory.bufArray(sendBufsCount[0])
		local freeBufs = memory.bufArray(freeBufsCount[0])

		ffi.C.HelloBye2_Server_getPkts(ba, sendBufs.array, freeBufs.array)

		sendBufs.size = sendBufsCount[0]
		ret.send = sendBufs
		ret.sendCount = sendBufsCount[0]

		freeBufs:freeAll()
	else
		ret.sendCount = 0
	end

	return ret
end

function mod.free(obj)
	ffi.C.HelloBye2_Server_free(obj)
end

return mod

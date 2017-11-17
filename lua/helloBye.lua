local ffi = require "ffi"
local memory = require "memory"
local log = require "log"

ffi.cdef[[
void *HelloByeServer_init();

void HelloByeServer_process(void *obj, struct rte_mbuf **inPkts, unsigned int inCount,
struct rte_mbuf **sendPkts, unsigned int *sendCount, struct rte_mbuf **freePkts,
unsigned int *freeCount);

void HelloByeServer_free(void *obj);
]]

local mod = {}

function mod.init()
	return ffi.C.HelloByeServer_init()
end

function mod.process(obj, inPkts, inCount)
	ret = {}

	if 0 < inCount then
		log:info("helloBye.process() called (>0 packets)")

		local sendBufs = memory.bufArray(inCount)
		local freeBufs = memory.bufArray(inCount)
		local sendBufsCount = ffi.new("unsigned int[1]")
		local freeBufsCount = ffi.new("unsigned int[1]")

		ffi.C.HelloByeServer_process(obj, inPkts, inCount, sendBufs.array, sendBufsCount,
		freeBufs.array, freeBufsCount)

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
	ffi.C.HelloByeServer_free(obj)
end

return mod

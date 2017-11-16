local ffi = require "ffi"
local memory = require "memory"

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

	local sendBufs = memory.bufArray(inCount)
	local freeBufs = memory.bufArray(inCount)
	local sendBufsCount = ffi.new("unsigned int[1]")
	local freeBufsCount = ffi.new("unsigned int[1]")

	ffi.C.HelloByeServer_process(obj, inPkts, inCount, sendBufs, sendBufsCount,
	freeBufs, freeBufsCount)

	ret.send = sendBufs
	ret.sendCount = sendBufsCount[0]

	freeBufs:freeAll()

	return ret
end

function mod.free(obj)
	ffi.C.HelloByeServer_free(obj)
end

return mod

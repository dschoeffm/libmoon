import ffi

local mod = {}

ffi.cdef[[
void run_algo1(struct rte_mbuf **bufs, int num_bufs);
]]

local function algo1(buf_array, num_bufs)
	ffi.C.run_algo1(buf_array, num_bufs)
end

mod["algo1"] = algo1

return mod

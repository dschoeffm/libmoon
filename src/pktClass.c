#include <rte_mbuf.h>
#include <stdint.h>

void run_algo1(struct rte_mbuf **bufs, int num_bufs) {
	for (int i = 0; i < num_bufs; i++) {
		uint8_t *packet_data = rte_pktmbuf_mtod(bufs[i], uint8_t *);

		// Run some pkt classification algorithm on packet_data
		// packet_data is a pointer to the actual data inside the packet,
		// starting with the ethernet header
	}
}

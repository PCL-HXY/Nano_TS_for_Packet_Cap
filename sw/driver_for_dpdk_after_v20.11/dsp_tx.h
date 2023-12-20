
#ifndef _DSP_TX_H_
#define _DSP_TX_H_

#include <unistd.h>
#include <fcntl.h>

#include "ddr_dma.h"

#include <rte_ethdev.h>
#include <rte_malloc.h>

#define RTE_ETH_DSP_SNAPLEN ETHER_MAX_JUMBO_FRAME_LEN
#define N_TX_QUEUES 2

static const uint64_t PREAMBLE = 0x55555555555555fb;
static const uint64_t IDLE = 0x07070707070707fd;

struct dsp_tx_queue
{
	unsigned char *dma_ring; 		//point to memory used to dma H2C
	uint64_t usr_wr_ptr;			//write pointer in host memory
	uint64_t usr_rd_ptr;			//read pointer in host memory
	int64_t send_fd;				//dma send file
	uint32_t eth_port;				//not used now(?)
	//	volatile uint64_t tx_pkts;   /* packets write */
	//	volatile uint64_t tx_bytes;  /* bytes write */
};

/**
 * DPDK callback to setup a TX queue for use.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 * @param idx
 *   RX queue index.
 * @param desc
 *   Number of descriptors to configure in queue.
 * @param socket
 *   NUMA socket on which memory must be allocated.
 * @param[in] conf
 *   Thresholds parameters.
 * @param mp
 *   Memory pool for buffer allocations.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */

int dsp_eth_tx_queue_setup(struct rte_eth_dev *dev,
						   uint16_t tx_queue_id,
						   uint16_t nb_tx_desc,
						   unsigned int socket_id,
						   const struct rte_eth_txconf *tx_conf);

/**
 * DPDK callback to release a RX queue.
 *
 * @param q
 *   Generic RX queue pointer.
 */
void dsp_eth_tx_queue_release(void *q);

/**
 * increase 8 bits, check if the pointer points the
 * edge of host memory.
 * 
 * @param p_in_ts
 *   pointer
 * 
 * @return
 *   pointer
 */
static inline uint64_t
whether_close2edge_8_tx(uint64_t p_in_ts)
{
	if (unlikely(p_in_ts + 8 > DMA_RING_SIZE - 1))
	{
		p_in_ts = 0;
	}
	else
	{
		p_in_ts += 8;
	}
	return p_in_ts;
}

/**
 * Update the value of the pointer to make it an integral multiple of 8 bytes.
 * 
 * @param wrp
 * 	 writer pointr of host memory
 * @param len
 *   data length without CRC
 * 
 * @return
 *   the updated value of wrp
 */
static inline uint64_t
locate_usr_wrp(unsigned char *dma_ring, uint64_t wrp, uint32_t len)
{
	uint64_t temp;
	uint64_t wrp_out;
	if (likely(wrp + len + 4 < DMA_RING_SIZE))
	{
		temp = wrp + len + 4;	//point to the first byte after CRC.
	}
	else
	{
		temp = wrp + len + 4 - DMA_RING_SIZE;
	}

	if (temp % 8)	//make the wrp an integral multiple of 8 bytes.
	{
		wrp_out = ((temp >> 3) + 1) << 3;
		rte_memcpy(dma_ring + temp, &IDLE, wrp_out - temp);
		if (unlikely(wrp_out == DMA_RING_SIZE))
		{
			wrp_out = 0;
		}
	}
	else
	{
		wrp_out = temp;
	}
	return wrp_out;
}

/**
 * get a jumbo frame
 */
static void
dsp_get_jumbo(unsigned char *data, struct rte_mbuf *mbuf)
{
	uint16_t data_len = 0;

	while (mbuf)
	{
		rte_memcpy(data + data_len, rte_pktmbuf_mtod(mbuf, void *), mbuf->data_len);
		data_len += mbuf->data_len;
		mbuf = mbuf->next;
	}
}

/**
 * DPDK callback for TX.
 *
 * @param dpdk_txq
 *   Generic pointer to TX queue structure.
 * @param bufs
 *   Packets to transmit.
 * @param nb_pkts
 *   Number of packets in array.
 *
 * @return
 *   Number of packets successfully transmitted (<= nb_pkts).
 */
static inline uint16_t
eth_dsp_tx(void *queue,
		   struct rte_mbuf **bufs,
		   uint16_t nb_pkts)
{

	int i;
	struct rte_mbuf *mbuf = NULL;
	struct dsp_tx_queue *tx_q = queue;
	uint32_t pkt_len, pkt_len_temp, pkt_len_revise;
	uint16_t data_len;
	uint16_t num_tx = 0;
	//uint64_t num_bytes = 0;
	uint8_t mbuf_segs;
	unsigned char jumbo_frame_temp[RTE_ETH_DSP_SNAPLEN];

	unsigned char *dma_ring = tx_q->dma_ring;
	uint64_t usr_wrp = tx_q->usr_wr_ptr;
	uint64_t *usr_rdp = &(tx_q->usr_rd_ptr);


	if (unlikely(tx_q == NULL || tx_q->dma_ring == NULL || nb_pkts == 0))
	{
		return 0;
	}

	for (i = 0; i < nb_pkts; i++)
	{
		mbuf = bufs[i];
		pkt_len = mbuf->pkt_len;
		data_len = mbuf->data_len;
		mbuf_segs = mbuf->nb_segs;
		
		/*if (((usr_wrp > *usr_rdp) && (DMA_RING_SIZE - usr_wrp + *usr_rdp > pkt_len+8))
			|| ((usr_wrp < *usr_rdp) && (*usr_rdp - usr_wrp > pkt_len+8))
			|| (usr_wrp == *usr_rdp)){*/
		rte_memcpy(dma_ring + usr_wrp, &PREAMBLE, 8);
		pkt_len_revise = rte_be_to_cpu_16(pkt_len);
		rte_memcpy(dma_ring + usr_wrp + 6, &pkt_len_revise, 2);
		usr_wrp = whether_close2edge_8_tx(usr_wrp);
		if (likely(mbuf_segs == 1)) //not jumbo frame
		{
			if (likely(usr_wrp + data_len <= DMA_RING_SIZE - 1))
			{
				rte_memcpy(dma_ring + usr_wrp, rte_pktmbuf_mtod(mbuf, void *), data_len);
				usr_wrp = locate_usr_wrp(dma_ring, usr_wrp, data_len);
			}
			else
			{
				pkt_len_temp = DMA_RING_SIZE - usr_wrp;
				rte_memcpy(dma_ring + usr_wrp, rte_pktmbuf_mtod(mbuf, void *), pkt_len_temp);
				rte_memcpy(dma_ring, rte_pktmbuf_mtod_offset(mbuf, uint8_t *, pkt_len_temp),
						   data_len - pkt_len_temp);
				usr_wrp = locate_usr_wrp(dma_ring, usr_wrp, data_len);
			}
		}
		else //write jumbo frame
		{
			dsp_get_jumbo(jumbo_frame_temp, mbuf);
			if (likely(usr_wrp + pkt_len <= DMA_RING_SIZE - 1))
			{
				rte_memcpy(dma_ring + usr_wrp, jumbo_frame_temp, pkt_len);
				usr_wrp = locate_usr_wrp(dma_ring, usr_wrp, pkt_len);
			}
			else
			{
				pkt_len_temp = DMA_RING_SIZE - usr_wrp;
				rte_memcpy(dma_ring + usr_wrp, jumbo_frame_temp, pkt_len_temp);
				rte_memcpy(dma_ring, jumbo_frame_temp + pkt_len_temp, pkt_len - pkt_len_temp);
				usr_wrp = locate_usr_wrp(dma_ring, usr_wrp, pkt_len);
			}
		}

		tx_q->usr_wr_ptr = usr_wrp;
		
		num_tx++;
		rte_pktmbuf_free(mbuf);
	}

	return num_tx;
}

#endif /* _DSP_TX_H_ */

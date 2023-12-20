
#ifndef _DSP_RX_H_
#define _DSP_RX_H_

#include "ddr_dma.h"
#include <time.h>
#include <unistd.h>
#include <assert.h>

#define N_RX_QUEUES 2
#define CRC 4
#define RTE_STATIC_BSWAP64(v) \
        ((((uint64_t)(v) & UINT64_C(0x00000000000000ff)) << 56) | \
         (((uint64_t)(v) & UINT64_C(0x000000000000ff00)) << 40) | \
         (((uint64_t)(v) & UINT64_C(0x0000000000ff0000)) << 24) | \
         (((uint64_t)(v) & UINT64_C(0x00000000ff000000)) <<  8) | \
         (((uint64_t)(v) & UINT64_C(0x000000ff00000000)) >>  8) | \
         (((uint64_t)(v) & UINT64_C(0x0000ff0000000000)) >> 24) | \
         (((uint64_t)(v) & UINT64_C(0x00ff000000000000)) >> 40) | \
         (((uint64_t)(v) & UINT64_C(0xff00000000000000)) >> 56))

struct dsp_rx_queue
{
	unsigned char *dma_ring; //pointer to memory for dma in host
	unsigned char *jumbo_frame;
	uint64_t usr_wr_ptr;	 //pointer to ring where user read
	uint64_t usr_rd_ptr;	 //pointer to ring where user write
	int64_t recv_fd;
	struct rte_mempool *mb_pool;
	uint8_t in_port;
	uint8_t port_flag;
	uint32_t eth_port;
	uint64_t rx_pkt;
	uint64_t basetime;
};

/**
 * DPDK callback to setup a RX queue for use.
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
 * @param mb_pool
 *   Memory pool for buffer allocations.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
int dsp_eth_rx_queue_setup(struct rte_eth_dev *dev,
						   uint16_t rx_queue_id,
						   uint16_t nb_rx_desc __rte_unused,
						   unsigned int socket_id,
						   const struct rte_eth_rxconf *rx_conf __rte_unused,
						   struct rte_mempool *mb_pool);
/**
 * DPDK callback to release a RX queue.
 * 
 * @param dpdk_rxq
 *   Generic RX queue pointer
 */
void dsp_eth_rx_queue_release(void *q);

static inline void
timespec_sub(struct timespec *t1, const struct timespec *t2)
{
	assert(t1->tv_nsec >= 0);
	assert(t1->tv_nsec < 1000000000);
	assert(t2->tv_nsec >= 0);
	assert(t2->tv_nsec < 1000000000);
	t1->tv_sec -= t2->tv_sec;
	t1->tv_nsec -= t2->tv_nsec;
	if (t1->tv_nsec >= 1000000000)
	{
		t1->tv_sec++;
		t1->tv_nsec -= 1000000000;
	}
	else if (t1->tv_nsec < 0)
	{
		t1->tv_sec--;
		t1->tv_nsec += 1000000000;
	}
}

static inline uint64_t
whether_close2edge_8(uint64_t p_in_ts)
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

static inline uint64_t
locate_usr_rdp(uint64_t p_in_ts,
			   uint32_t pkt_len)
{
	uint32_t temp = 0;
	uint32_t p_out_ts = 0;

	if (unlikely((p_in_ts + pkt_len) > DMA_RING_SIZE - 1))
		temp = p_in_ts + pkt_len - DMA_RING_SIZE;
	else
		temp = p_in_ts + pkt_len;

	if (temp % 8)
	{
		p_out_ts = ((temp >> 3) + 1) << 3;
		if (p_out_ts == DMA_RING_SIZE)
			p_out_ts = 0;
	}
	else
	{
		p_out_ts = temp;
	}
	return p_out_ts;
}

/**
 * process jumbo frame
 * 
 * @param mb_pool
 *   the mempool to get mbuf
 * @param mbuf
 *   the mbuf to put data
 * @param data
 *   the data of jumbo frame
 * @param len
 *   the len of data
 */
static inline int
dsp_rx_jumbo(struct rte_mempool *mb_pool, struct rte_mbuf *mbuf,
			 const uint8_t *data, uint16_t data_len)
{
	struct rte_mbuf *m;
	uint16_t total_len = data_len;
	uint16_t mbuf_len = rte_pktmbuf_tailroom(mbuf);

	mbuf->pkt_len = total_len;
	mbuf->data_len = mbuf_len;
	rte_memcpy(rte_pktmbuf_mtod(mbuf, void *), data, mbuf_len);
//	print_hex((unsigned char *)mbuf->buf_addr + mbuf->data_off, mbuf_len);
//	printf("mbuf: %p\n", mbuf);
	data_len -= mbuf_len;
	data += mbuf_len;

	m = mbuf;
	while (data_len > 0)
	{
		/* Allocate next mbuf and point to that. */
		m->next = rte_pktmbuf_alloc(mb_pool);
//		while(m->next == mbuf)
//			m->next = rte_pktmbuf_alloc(mb_pool);
		if (unlikely(!m->next))
		{
			printf("not enough mbuf from jumbo rx!\n");
			return -1;
		}

		m = m->next;
		/* Copy next segment. */
		mbuf_len = RTE_MIN(rte_pktmbuf_tailroom(m), data_len);
		rte_memcpy(rte_pktmbuf_mtod(m, void *), data, mbuf_len);
//		print_hex((unsigned char *)m->buf_addr + m->data_off, mbuf_len);
//		printf("m: %p\n", m);
		m->pkt_len = total_len;
		m->data_len = mbuf_len;

		mbuf->nb_segs++;
		data_len -= mbuf_len;
		data += mbuf_len;
	}
	return mbuf->nb_segs;
}

static inline uint16_t
eth_dsp_rx(void *queue,
		   struct rte_mbuf **bufs,
		   uint16_t nb_pkts)
{
	unsigned int i, round = 0;
	struct dsp_rx_queue *dsp_q = (struct dsp_rx_queue *)queue;
	struct rte_mbuf *mbuf;
	struct rte_mbuf *mbufs[nb_pkts];
	uint32_t ret = 0, dma_en = 0, pkt_len = 0, pkt_len_cnt = 0;
	uint64_t usr_wrp = 0, usr_rdp = 0, usr_rdp_temp = 0, pkt_len_temp = 0, head_ptr = 0, usr_rdp_1 = 0;
	uint16_t buf_size;
	uint16_t num_rx = 0;
	uint16_t pkt_avail = 0;
	uint64_t rx_bytes = 0;
	unsigned char *usr_rbuffer = NULL;
	unsigned char *jumbo_frame_temp = NULL;
	
	if(dsp_q->eth_port)
	{
		usr_rbuffer = dsp_q->dma_ring;
		usr_wrp = dsp_q->usr_wr_ptr;
		usr_rdp = dsp_q->usr_rd_ptr;
	}
	else
	{
        return 0;
	}

	buf_size = rte_pktmbuf_data_room_size(dsp_q->mb_pool) -
			   RTE_PKTMBUF_HEADROOM;
	if (unlikely(dsp_q->dma_ring == NULL || nb_pkts == 0))
		return 0;


	i = rte_pktmbuf_alloc_bulk(dsp_q->mb_pool, mbufs, nb_pkts);
	if (unlikely(i != 0))
	{
		//printf("not enough mb in mb_pool!!!!!!\n");
            //printf("asking_for_cnt: %u, avail_cnt: %u, in_use_cnt: %u\n", nb_pkts, rte_mempool_avail_count(dsp_q->mb_pool), rte_mempool_in_use_count(dsp_q->mb_pool));
		return 0;
	}


	for (i = 0; i < nb_pkts; i++)
	{
		mbuf = mbufs[i];
		if (unlikely(usr_rdp == usr_wrp))
			goto post_processing;//not enough pkts
rematch:
		while (((*((uint64_t *)(usr_rbuffer + usr_rdp))) & 0x0000ffffffffffff) ^ UINT64_C(0x00005555555555fb))
		{
			usr_rdp = whether_close2edge_8(usr_rdp);
			if (usr_rdp == usr_wrp)
			{
				goto post_processing;//not enough pkts
			}
		}
		pkt_len = ((*(usr_rbuffer + usr_rdp + 6)) << 8) + (*(usr_rbuffer + usr_rdp + 7)); //Actual packet length, not Ethernet-defined payload, excluding crc.
		if (unlikely(pkt_len > 10000))
		{
			usr_rdp = whether_close2edge_8(usr_rdp);
			if (unlikely(usr_rdp == usr_wrp))
			{
				goto post_processing;//not enough pkts
			}
			else
			{
				goto rematch;
			}	
		}
		if (unlikely((pkt_len + 20) > (usr_wrp > usr_rdp ? (usr_wrp - usr_rdp) : (DMA_RING_SIZE - usr_rdp + usr_wrp)))) //--pkt_len+20+8;pkt_len greater than distance between wrp and rdp
		{				
			goto post_processing;//not enough pkts
		}
		else
		{
			usr_rdp_temp = locate_usr_rdp(usr_rdp, pkt_len + 20); //fb(8) + ts(8) + crc(4) = 20
		}

		usr_rdp = whether_close2edge_8(usr_rdp);
		mbuf->timestamp = RTE_STATIC_BSWAP64(*((uint64_t *)(usr_rbuffer + usr_rdp)));
		usr_rdp = whether_close2edge_8(usr_rdp);

		if (pkt_len <= buf_size)
		{
			if (likely(usr_rdp + pkt_len <= DMA_RING_SIZE - 1))
			{
				rte_memcpy(rte_pktmbuf_mtod(mbuf, void *), usr_rbuffer + usr_rdp, pkt_len);
				usr_rdp = usr_rdp_temp;//locate_usr_rdp(usr_rdp, pkt_len + CRC);
			}
			else
			{
				pkt_len_temp = DMA_RING_SIZE - usr_rdp;
				rte_memcpy(rte_pktmbuf_mtod(mbuf, void *), usr_rbuffer + usr_rdp, pkt_len_temp);
				rte_memcpy(rte_pktmbuf_mtod(mbuf, uint8_t *) + pkt_len_temp,
						   usr_rbuffer, pkt_len - pkt_len_temp);
				usr_rdp = usr_rdp_temp;//locate_usr_rdp(0, pkt_len - pkt_len_temp + CRC);
			}
			mbuf->data_len = pkt_len;
		}
		else
		{
			//goto post_processing;
			if (unlikely(usr_rdp + pkt_len > DMA_RING_SIZE - 1))
			{
				jumbo_frame_temp = dsp_q->jumbo_frame;
				if(!jumbo_frame_temp)
				{
					printf("jumbo_frame_temp NULL!\n");
					goto post_processing;
				}
				pkt_len_temp = DMA_RING_SIZE - usr_rdp;
				rte_memcpy(jumbo_frame_temp, usr_rbuffer + usr_rdp, pkt_len_temp);
				rte_memcpy(jumbo_frame_temp + pkt_len_temp, usr_rbuffer, pkt_len - pkt_len_temp);
				if (unlikely(dsp_rx_jumbo(dsp_q->mb_pool,
							  mbuf,
							  jumbo_frame_temp,
							  pkt_len) == -1))
				{
					memset(dsp_q->jumbo_frame, 0, sizeof(dsp_q->jumbo_frame));
					jumbo_frame_temp = NULL;
					goto post_processing;	
				}
				usr_rdp = usr_rdp_temp;//locate_usr_rdp(0, pkt_len - pkt_len_temp + CRC);
				memset(dsp_q->jumbo_frame, 0, sizeof(dsp_q->jumbo_frame));
				jumbo_frame_temp = NULL;
			}
			else
			{
				if (unlikely(dsp_rx_jumbo(dsp_q->mb_pool,
							  mbuf,
							  usr_rbuffer + usr_rdp,
							  pkt_len) == -1))
				{
					memset(dsp_q->jumbo_frame, 0, sizeof(dsp_q->jumbo_frame));
					jumbo_frame_temp = NULL;
					goto post_processing;
				}
				usr_rdp = usr_rdp_temp;//locate_usr_rdp(usr_rdp, pkt_len + CRC);
				memset(dsp_q->jumbo_frame, 0, sizeof(dsp_q->jumbo_frame));
						jumbo_frame_temp = NULL;
			}
		}
		mbuf->pkt_len = pkt_len;
		bufs[i] = mbuf;
		num_rx++;
		rx_bytes += pkt_len;
	}

post_processing:

	dsp_q->usr_rd_ptr = usr_rdp;
	
	for (i = num_rx; i < nb_pkts; i++)
		rte_pktmbuf_free(mbufs[i]);
	dsp_q->rx_pkt += num_rx;

    return num_rx;
}

#endif /* _DSP_RX_H_ */

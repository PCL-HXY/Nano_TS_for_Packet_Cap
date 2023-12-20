
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

#include "dsp.h"

uint64_t dsp_timestamp_rx_dynflag;
int dsp_timestamp_dynfield_offset = -1;

int dsp_eth_rx_queue_setup(struct rte_eth_dev *dev,
						   uint16_t rx_queue_id,
						   uint16_t nb_rx_desc __rte_unused,
						   unsigned int socket_id,
						   const struct rte_eth_rxconf *rx_conf __rte_unused,
						   struct rte_mempool *mb_pool)
{
	struct pmd_internals *internals = dev->data->dev_private;
	struct dsp_rx_queue *rx_q = NULL;
	unsigned char *dma_ring = NULL;
	unsigned char *jumbo_frame = NULL;

	rx_q = rte_zmalloc_socket("dsp_rx_queue", sizeof(struct dsp_rx_queue),
							  RTE_CACHE_LINE_SIZE, socket_id);
	if (unlikely(rx_q == NULL))
	{
		RTE_LOG(ERR, PMD, "rte_zmalloc_socket() failed for rx queue id %" PRIu16 "!\n", rx_queue_id);
		return -1;
	}

	dma_ring = rte_malloc(NULL, DMA_RING_SIZE, 4096);
	if (unlikely(dma_ring == NULL))
	{
		RTE_LOG(ERR, MALLOC, "cannot allocate memory dma_buf\n");
		return -1;
	}
	
	jumbo_frame = rte_malloc(NULL, 10240, 64);
    if (unlikely(jumbo_frame == NULL))
    {
        RTE_LOG(ERR, MALLOC, "cannot allocate memory jumbo_frame\n");
        return -1;
    }

	rx_q->dma_ring = dma_ring;
	rx_q->jumbo_frame = jumbo_frame;
	rx_q->mb_pool = mb_pool;
	rx_q->usr_wr_ptr = 0;
	rx_q->usr_rd_ptr = 0;
	rx_q->recv_fd = -1;
	rx_q->in_port = dev->data->port_id;
	rx_q->rx_pkt = 0;
	rx_q->port_flag = 0;
	rx_q->eth_port = 0;
	rx_q->basetime = 0;
	dev->data->rx_queues[rx_queue_id] = rx_q;
	internals->rx_queue[rx_queue_id] = rx_q;
	printf("rx_q->dma_ring: %p\n", rx_q->dma_ring);
	return 0;
}

void dsp_eth_rx_queue_release(void *queue)
{
	struct dsp_rx_queue *rx_q = queue;

	if (rx_q != NULL)
	{
		rte_free(rx_q->dma_ring);
		rte_free(rx_q->mb_pool);
		rte_free(rx_q->jumbo_frame);
		rx_q->dma_ring = NULL;
		rx_q->mb_pool = NULL;
		rx_q->jumbo_frame = NULL;
		rx_q->usr_wr_ptr = 0;
		rx_q->usr_rd_ptr = 0;
		rx_q->in_port = 0;
		rx_q->port_flag = 0;
		rx_q->rx_pkt = 0;
		rx_q->eth_port = 0;
		rx_q->basetime = 0;
		if (rx_q->recv_fd >= 0)
		{
			close(rx_q->recv_fd);
		}
		rte_free(rx_q);
		rx_q = NULL;
	}
}

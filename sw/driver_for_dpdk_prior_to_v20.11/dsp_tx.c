
#include "dsp.h"

int dsp_eth_tx_queue_setup(struct rte_eth_dev *dev,
						   uint16_t tx_queue_id,
						   uint16_t nb_tx_desc __rte_unused,
						   unsigned int socket_id,
						   const struct rte_eth_txconf *tx_conf __rte_unused)
{
	struct pmd_internals *internals = dev->data->dev_private; //struct dsp_tx_queue *tx_q = &internals->tx_queue[tx_queue_id];
	struct dsp_tx_queue *tx_q = NULL;						  //alloc memory for dma H2C
	unsigned char *dma_ring = NULL;

	tx_q = rte_zmalloc_socket("dsp tx queue", sizeof(struct dsp_tx_queue), RTE_CACHE_LINE_SIZE, socket_id);
	if (unlikely(tx_q == NULL))
	{
		RTE_LOG(ERR, PMD, "rte_zmalloc_scoket() failed for tx queue id"
						  "%" PRIu16 "!\n",
				tx_queue_id);
		return -1;
	}

	dma_ring = rte_malloc(NULL, DMA_RING_SIZE, 4096);
	if (unlikely(dma_ring == NULL))
	{
		RTE_LOG(ERR, PMD, "Cannot allocate dma_ring for tx queue id %" PRIu16 "!\n", tx_queue_id);
		return -1;
	}


	tx_q->dma_ring = dma_ring;
	tx_q->send_fd = -1;
	tx_q->usr_wr_ptr = 0;
	tx_q->usr_rd_ptr = 0;
	tx_q->eth_port = 0;

	dev->data->tx_queues[tx_queue_id] = tx_q;
	internals->tx_queue[tx_queue_id] = tx_q;

	return 0;
}

void dsp_eth_tx_queue_release(void *q)
{
	struct dsp_tx_queue *tx_q = (struct dsp_tx_queue *)q;

	if (tx_q != NULL)
	{
		if (tx_q->dma_ring != NULL)
		{
			rte_free(tx_q->dma_ring);
			tx_q->dma_ring = NULL;
		}
		tx_q->usr_wr_ptr = 0;
		tx_q->usr_rd_ptr = 0;
		if (tx_q->send_fd >= 0)
		{
			close(tx_q->send_fd);
		}
		rte_free(tx_q);
		tx_q = NULL;
	}
}

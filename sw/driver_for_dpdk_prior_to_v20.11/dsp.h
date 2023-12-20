
#ifndef _DSP_H_
#define _DSP_H_

#include "dsp_tx.h"
#include "dsp_rx.h"

/* PCI Vendor ID */
#define PCI_VENDOR_ID_XILINX 0x10ee

/* PCI Device IDs */
#define PCI_DEVICE_ID_DSP_121 0x8038
#define PCI_DEVICE_ID_DSP_241 0x903f

/* Max index of dsp rx/tx queues */
#define RTE_ETH_DSP_MAX_QUEUES 1

/* Max index of rx/tx dmas */
#define RTE_MAX_NC_RXMAC 256
#define RTE_MAX_NC_TXMAC 256

#define RTE_DSP_DRIVER_NAME net_dsp

/* Device arguments */
#define TIMESTAMP_ARG "timestamp"

static const char *const VALID_KEYS[] = {TIMESTAMP_ARG, NULL};

struct pmd_internals
{
	struct dsp_rx_queue *rx_queue[RTE_ETH_DSP_MAX_QUEUES];
	struct dsp_tx_queue *tx_queue[RTE_ETH_DSP_MAX_QUEUES];
	uint32_t eth_link_state[2];
};

/* Idle core id */
#define SLAVE_CORE "mask"

static const char *const VALID_KEYS[] = {SLAVE_CORE, NULL};

#endif /* _DSP_H_ */

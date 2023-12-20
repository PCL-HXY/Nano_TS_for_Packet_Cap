#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include <sys/queue.h>
#include <inttypes.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <assert.h>
#include <signal.h>

#include <rte_memory.h>
#include <rte_launch.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_lcore.h>
#include <rte_debug.h>
#include <rte_ethdev.h>
#include <rte_cycles.h>
#include <rte_lcore.h>
#include <rte_mbuf.h>

#define RX_RING_SIZE 1024
#define TX_RING_SIZE 1024

#define NUM_MBUFS 8191
#define MBUF_CACHE_SIZE 256
#define BURST_SIZE 64
#define CONFIG_RTE_MEMPOOL_CACHE_MAX_SIZE 512

int force_quit;

static const struct rte_eth_conf port_conf_default = {
	.rxmode = {
		.max_rx_pkt_len = ETHER_MAX_LEN,
	},
};

static void
signal_handler(int signum)
{
	if (signum == SIGINT || signum == SIGTERM)
		force_quit = 1;
}

static inline void
print_hex(unsigned char *source, int len)
{
	int i = 0;
	for (i = 0; i < len; i++)
	{
		printf("%02X", source[i]);
		if ((i + 1) % 8 == 0)
			printf(" ");
		if ((i + 1) % 64 == 0)
			printf("%d\n", i / 64 + 1);
		if ((i + 1) == len)
			printf("\n");
	}
}

static void
write_data(struct rte_mbuf **mbufs, int nb_mbufs)
{
	int o_file;
	int ret, i;
	struct rte_mbuf *mbuf;
	//unsigned char line[] = "\n";

	o_file = open("mbuf_data.bin", O_WRONLY | O_TRUNC | O_CREAT, S_IRUSR | S_IWUSR);
	for (i = 0; i < nb_mbufs; i++)
	{
		mbuf = mbufs[i];
		ret = write(o_file, (unsigned char *)mbuf->buf_addr + mbuf->data_off, mbuf->data_len);
		if (mbuf->next != NULL)
		{
			mbuf = mbuf->next;
			ret = write(o_file, (unsigned char *)mbuf->buf_addr + mbuf->data_off, mbuf->data_len);
		}
		if (unlikely(ret < 0))
			RTE_LOG(ERR, USER1, "Cannot write file data.txt\n");
	}
	ret = close(o_file);
	if (unlikely(ret != 0))
		RTE_LOG(ERR, USER1, "Cannot close file data.txt\n");
	//printf("%d\n",mbufs[0]->buf_len);
}

static void timespec_sub(struct timespec *t1, const struct timespec *t2)
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

static int
lcore_main(/*void *queue*/void *arg __rte_unused)
{
	uint16_t port, q_id;
	int i = 0, n = 0;
	int first_mbuf_flag = 0, error_flag = 0;
	struct timespec ts_start, ts_end;
	int nb_rx = 0, nb_tx = 0;
	uint64_t total_nb_rx = 0;
	uint64_t total_nb_tx = 0;
	int32_t check_data_1, check_data_2;
	uint64_t prev_tsc = 0, diff_tsc = 0, cur_tsc = 0, timer_tsc = 0;
	struct rte_mbuf *bufs[BURST_SIZE];
	struct rte_mbuf *mbuf1, *mbuf2;
	//uint16_t *q = (uint16_t *)(queue);
	uint16_t id = rte_lcore_id();
	
	if (id == 0)
	{
		q_id = 0;
	}
	else if (id == 2)
	{
		q_id = 1;
	}
	else
	{
		printf("wrong core\n");
		return -1;
	}
	RTE_ETH_FOREACH_DEV(port)
	if (rte_eth_dev_socket_id(port) > 0 && rte_eth_dev_socket_id(port) != (int)rte_socket_id())
		printf("WARNING, port %u is on remote NUMA node to polling thread.\n\tPerformance will "
			   "not be optimal.\n",
			   port);

	printf("eth%d fwd is running on lcore %d\n", q_id, id);
	clock_gettime(CLOCK_MONOTONIC, &ts_start);
	for (;(force_quit != 1);n++)
	{
		nb_rx = rte_eth_rx_burst(0, q_id, bufs, BURST_SIZE);
		if (likely(nb_rx == 0))
		{
			//usleep(1);	
			continue;
		}
		else
		total_nb_rx = total_nb_rx + nb_rx;

	/*	for (i = 0; i < nb_rx; i++)
                {
                	rte_pktmbuf_free(bufs[i]);
                }*/

		nb_tx = rte_eth_tx_burst(0, q_id, bufs, nb_rx);
		total_nb_tx = total_nb_tx + nb_tx;
		if (unlikely(nb_tx < nb_rx))
		{
			for (i = nb_tx; i < nb_rx; i++)
			{
				rte_pktmbuf_free(bufs[i]);
			}
		}
	}

	clock_gettime(CLOCK_MONOTONIC, &ts_end);
	timespec_sub(&ts_end, &ts_start);
	printf("\n\neth%d Statistics:", q_id);
	printf("\n=*=*=*=*=number of capture is %ld,   number of transmission is %ld\n",total_nb_rx,total_nb_tx);
	printf("\n=*=*=*=*=It takes %ld.%09ld seconds (total) for write\n", ts_end.tv_sec, ts_end.tv_nsec);
	printf("=*=*=*=*=current proccess speed : %0.3fpps\n\n\n", total_nb_rx / (ts_end.tv_sec + 0.000000001 * ts_end.tv_nsec));
	return 0;
}
static inline int
port_init(uint16_t port, struct rte_mempool *mbuf_pool)
{
	struct rte_eth_conf port_conf = port_conf_default;
	const uint16_t rx_rings = 2, tx_rings = 2;
	uint16_t nb_rxd = RX_RING_SIZE;
	uint16_t nb_txd = TX_RING_SIZE;
	int retval;
	uint16_t q = 0;
	struct rte_eth_dev_info dev_info;
	struct ether_addr addr;

	if (!rte_eth_dev_is_valid_port(port))
		return -1;

	/*????*/
	rte_eth_dev_info_get(port, &dev_info);

	retval = rte_eth_dev_configure(port, rx_rings, tx_rings, &port_conf);
	if (retval != 0)
		return retval;

	//retval = rte_eth_dev_adjust_nb_rx_tx_desc(port, &nb_rxd, &nb_txd);
	//if (retval != 0)
	//	return retval;

	for (q = 0; q < rx_rings; q++)
	{
		retval = rte_eth_rx_queue_setup(port, q, nb_rxd, rte_eth_dev_socket_id(port), NULL, mbuf_pool);
		if (retval < 0)
			//rte_exit(EXIT_FAILURE, "Cannot init port %d\n", retval);
			return retval;
	}
	RTE_LOG(INFO, USER2, "Rx queue has been setup.\n");

	for (q = 0; q < tx_rings; q++)
	{
	 retval = rte_eth_tx_queue_setup(port, q, nb_txd, rte_eth_dev_socket_id(port), NULL);
	//	retval = rte_eth_tx_queue_setup(port, q, nb_txd, 6, NULL);
		if (retval < 0)
			return retval;
	}
	RTE_LOG(INFO, USER2, "Tx queue has been setup.\n");

	retval = rte_eth_dev_start(port);
	if (retval < 0)
		return retval;
	RTE_LOG(INFO, USER2, "Device has been started.\n");

	rte_eth_macaddr_get(port, &addr);
	//RTE_LOG(INFO, USER1, "Print mac address.\n");

	printf("Port %u MAC: %02" PRIx8 " %02" PRIx8 " %02" PRIx8
		   " %02" PRIx8 " %02" PRIx8 " %02" PRIx8 "\n",
		   port,
		   addr.addr_bytes[0], addr.addr_bytes[1], addr.addr_bytes[2],
		   addr.addr_bytes[3], addr.addr_bytes[4], addr.addr_bytes[5]);

	rte_eth_promiscuous_enable(port);

	return 0;
}

int main(int argc, char **argv)
{
	int ret;
	unsigned nb_ports;
	uint16_t port;
	struct rte_mempool *mbuf_pool;
	uint16_t queue;
	int i = 0;

	ret = rte_eal_init(argc, argv);
	if (ret < 0)
		rte_exit(EXIT_FAILURE, "Cannot init EAL\n");

	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);

	argc -= ret;
	argv += ret;

	nb_ports = rte_eth_dev_count();
	if (nb_ports == 0)
		rte_exit(EXIT_FAILURE, "No Ethernet ports\n");

	mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", NUM_MBUFS * nb_ports, CONFIG_RTE_MEMPOOL_CACHE_MAX_SIZE/*MBUF_CACHE_SIZE*/, 0, RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());
	if (mbuf_pool == NULL)
		rte_exit(EXIT_FAILURE, "Cannot create mbuf pool\n");

	RTE_ETH_FOREACH_DEV(port)
	if (port_init(port, mbuf_pool) != 0)
		rte_exit(EXIT_FAILURE, "Cannot init port %" PRIu16 "\n", port);

/*	if (rte_lcore_count() > 1)
		printf("\nWARNING: Too many lcores enabled. Only 1 used.\n");

	/* call it on master lcore*/
	//lcore_main();
	printf("================starting receive mbuf================\n\t\t  Ctrl + c to quit.\n");
	/* call it on master lcore and lcore 1 */	
	rte_eal_mp_remote_launch(lcore_main, NULL, CALL_MASTER);
//	rte_eal_mp_wait_lcore();//for SKIP_MASTER
	/* stop device */
	RTE_ETH_FOREACH_DEV(port)
	{
		printf("Stopping device...");
		fflush(stdout);
		rte_eth_dev_stop(port);
		printf("Done.\n");
	}
	return 0;
}

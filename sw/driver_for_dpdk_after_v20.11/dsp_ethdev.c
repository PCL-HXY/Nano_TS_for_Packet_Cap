
#define _GNU_SOURCE

#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
#include <rte_kvargs.h>
#include <rte_mbuf_dyn.h>

#include <rte_ethdev_pci.h>
#include <rte_cycles.h>
#include <rte_timer.h>

#include "dsp.h"

#include "include/nsa_static_ctrl.h"
#include "include/nsa_types.h"
cpu_set_t cpuset, cpuget;
/**
 * Default MAC addr
 */
static const struct ether_addr eth_addr = {
	.addr_bytes = {0x00, 0x11, 0x17, 0x00, 0x00, 0x00}};
static const uint64_t Complement = 0x0707070707070707;
// int Spirent_interrupt = 0;
static int mask;
/**
 * DPDK callback to uninitialize an ethernet device
 *
 * @param dev
 *   Pointer to ethernet device structure
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static int
dsp_eth_dev_uninit(struct rte_eth_dev *eth_dev __rte_unused)
{
	semp_nsa_uninit();
	return 0;
}

/**
 * set FPGA regs to enable DMA
 */
static int
dsp_dma_start(struct rte_eth_dev *dev)
{
	int ret;
	/*ret = semp_fpga_reg_write(0, 0x140000, 0x5a); //eth_tx
        if (ret)
        {
                RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x140000);
                goto nsa_uninit;
        }
        usleep(10);*/

	ret = semp_fpga_reg_write(0, 0x1100000, 0x80000005); // enable ddr module
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1100000);
		goto nsa_uninit;
	}
	/*	ret = semp_fpga_reg_write(0, 0x1100100, 0x80000100);
    if (ret)
    {
        printf("Write register failed\n");
		goto nsa_unint;
    }*/
	ret = semp_fpga_reg_write(0, 0x700008, 0x00000002); //eth_loop_mod 
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700008);
		goto nsa_uninit;
	}

	ret = semp_fpga_reg_write(0, 0x700000, 0x00000001); //eth_rx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700000);
		goto nsa_uninit;
	}

	ret = semp_fpga_reg_write(0, 0x700004, 0x00000001); //eth_tx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700004);
		goto nsa_uninit;
	}
	/***eth1***/
	ret = semp_fpga_reg_write(0, 0x710008, 0x00000002); //eth1_loop_mod
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700008);
		goto nsa_uninit;
	}

	ret = semp_fpga_reg_write(0, 0x710000, 0x00000001); //eth1_rx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700000);
		goto nsa_uninit;
	}

	ret = semp_fpga_reg_write(0, 0x710004, 0x00000001); //eth1_tx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700004);
		goto nsa_uninit;
	}

	/***pkt_gen***/
	ret = semp_fpga_reg_write(0, 0x1200018, 0x00000000); //gen_num_low
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1200018);
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_write(0, 0x120001c, 0x00000000); //gen_num_high
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x120001c);
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_write(0, 0x1200020, 0x00000040); //val_len
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1200020);
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_write(0, 0x1200024, 0x00000001); //gen_en
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1200024);
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_write(0, 0x1200014, 0x00000001); //gen_en
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1200014);
		goto nsa_uninit;
	}
	return 0;

nsa_uninit:
	dsp_eth_dev_uninit(dev);
	return ret;
}

static int
dsp_tx_dma_loop(struct rte_eth_dev *dev)
{
	CPU_ZERO(&cpuset);
	CPU_SET(mask, &cpuset);
	if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0)
		perror("pthread_setaffinity_np\n");
	printf("into tx loop\n");
	uint16_t nb_tx = dev->data->nb_tx_queues;

	struct dsp_tx_queue *tx_q_0 = dev->data->tx_queues[0];
	struct dsp_tx_queue *tx_q_1 = dev->data->tx_queues[1];

	unsigned char *dma_ring = tx_q_0->dma_ring;
	uint64_t usr_rdp = tx_q_0->usr_rd_ptr;
	uint64_t usr_wrp = tx_q_0->usr_wr_ptr;
	unsigned char *dma_ring_1 = tx_q_1->dma_ring;
	uint64_t usr_rdp_1 = tx_q_1->usr_rd_ptr;
	uint64_t usr_wrp_1 = tx_q_1->usr_wr_ptr;
	uint8_t set_reg_flag = 0;
	uint8_t set_reg_flag_1 = 0;
	int64_t *send_fd = &(tx_q_0->send_fd);
	int64_t myret_value = 0;
	int ret = 0;
	uint64_t ddr_wrp = 0, ddr_wrp_1 = 0;
	uint32_t dma_en;
	uint32_t diff = 0, ddr_rdp = 0, wrp_offset = 0;
	uint32_t diff_1 = 0, ddr_rdp_1 = 0, wrp_offset_1 = 0;
	uint32_t link_state_0 = 0, link_state_1 = 0;
	char sendbuff[BUF_LEN] = {0};
	uint32_t tmp = 0;
	uint64_t prev_tsc = 0, diff_tsc = 0, cur_tsc = 0, timer_tsc = 0;
	uint64_t prev_tsc_1 = 0, diff_tsc_1 = 0, cur_tsc_1 = 0, timer_tsc_1 = 0;
	uint64_t timer_tsc_tmp = 0;
	uint32_t padding_diff_count = 0;
	printf("init para done\n");
	snprintf(sendbuff, BUF_LEN, DEV_SEND, 0);
	*send_fd = open(sendbuff, O_RDWR);
	if (*send_fd < 0)
	{
		RTE_LOG(ERR, PMD, "[ ERR ] open %s error! (%s)", DEV_SEND, strerror(errno));
		goto nsa_uninit;
	}
	/*myret_value = lseek(*send_fd, OFFSET_4G, SEEK_SET);
	if (myret_value < 0)
	{
		RTE_LOG(ERR, PMD, "[ ERR ] lseek %s error! (%s)", DEV_SEND, strerror(errno));
		goto nsa_uninit;
	}*/
	ret = semp_fpga_reg_read(0, 0x70000c, &link_state_0); //eth0 link state
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x70000c);
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_read(0, 0x71000c, &link_state_1); //eth1 link state
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x71000c);
		goto nsa_uninit;
	}
	if ((link_state_0 & 1) && (link_state_1 & 1))
	{
		tx_q_0->eth_port = 1;
		tx_q_1->eth_port = 1;
		RTE_LOG(INFO, USER2, "eth0&eth1 link...\n");
	}
	else if (link_state_0 & 1)
	{
		tx_q_0->eth_port = 1;
		tx_q_1->eth_port = 0;
		RTE_LOG(INFO, USER2, "eth0 links...\n");
	}
	else if (link_state_1 & 1)
	{
		tx_q_0->eth_port = 0;
		tx_q_1->eth_port = 1;
		RTE_LOG(INFO, USER2, "eth1 links...\n");
	}
	else
	{
		tx_q_0->eth_port = 0;
		tx_q_1->eth_port = 0;
		RTE_LOG(ERR, PMD, "eth link down.\n");
		return 0;
	}
	uint32_t rd_pkt_nb_en = 0;
	unsigned char *frame_FF = NULL; 
	uint32_t min_offset = 64; //16 * 1024;
	frame_FF = rte_malloc(NULL, min_offset, 64);
	memset(frame_FF, 0xFF, min_offset);
	// unsigned char *frame_temp = NULL;
	// frame_temp = rte_malloc(NULL, 128, 64);

	wrp_offset = 0x100000; //1M
	wrp_offset_1 = 0x100000;
	prev_tsc = rte_rdtsc();
	prev_tsc_1 = rte_rdtsc();

	ret = semp_fpga_reg_write(0, 0x1100018, 0x00000000);
	if(ret){
			RTE_LOG(ERR, PMD,"Write register %#x failed\n",0x1100018);
			goto nsa_uninit;
	}
	ret = semp_fpga_reg_write(0, 0x1100118, 0x00000000);
	if(ret){
			RTE_LOG(ERR, PMD,"Write register %#x failed\n",0x1100018);
			goto nsa_uninit;
	}

	while (1)
	{
next:
		//usleep(1);
		ret = semp_fpga_reg_read(0, 0x1200014, &dma_en);
		if (ret)
		{
			RTE_LOG(ERR, PMD, "Read register %#x failed\n", 0x1200014);
			goto nsa_uninit;
		}
		if (dma_en == 0)
		{
			printf("\n=======point of tx is: \n      ddr_wrp is:%ld, usr_rdp is:%ld, usr_wrp is:%ld\n",
				   ddr_wrp, usr_rdp, usr_wrp);
			break;
		}

		if (tx_q_0->eth_port)
		{
			cur_tsc = rte_rdtsc();
			diff_tsc = cur_tsc - prev_tsc;
			timer_tsc += diff_tsc;
			timer_tsc_tmp += diff_tsc;
			prev_tsc = cur_tsc;

			wrp_offset = N_TX_BURST_1M;

			usr_wrp = tx_q_0->usr_wr_ptr;
			diff = (usr_wrp >= usr_rdp) ? (usr_wrp - usr_rdp) : (DMA_RING_SIZE - usr_rdp + usr_wrp);
			if (unlikely(diff == 0))
			{
				timer_tsc = 0;
				prev_tsc = rte_rdtsc();
				goto eth_1;//continue;
			}
			if(set_reg_flag)
			{
				ret = semp_fpga_reg_write(0, 0x1100018, 0x00000000);
				if(ret){
						RTE_LOG(ERR, PMD,"Write register %#x failed\n",0x1100018);
						goto nsa_uninit;
				}
				set_reg_flag = 0;
			}

			if (usr_rdp + wrp_offset > DMA_RING_SIZE)
			{
				wrp_offset = DMA_RING_SIZE - usr_rdp;
			//	printf("wrp_offset after tuned: %d.\n", wrp_offset);
			}

			if (diff >= wrp_offset)
			{
				lseek(*send_fd, OFFSET_4G + ddr_wrp, SEEK_SET);
				ret = write(*send_fd, dma_ring + usr_rdp, wrp_offset);
				if (ret < 0)
				{
					RTE_LOG(ERR, PMD, "[ ERR1 ] or! Error info: %s, error: %d\n", strerror(errno), ret);
					goto nsa_uninit;
				}
				else if (wrp_offset != (unsigned)ret)
				{
					RTE_LOG(ERR, PMD, "[ ERR1 ] Write error! (read %d, need %d)\n", ret, wrp_offset);
					goto nsa_uninit;
				}
				usr_rdp = (usr_rdp + wrp_offset) % DMA_RING_SIZE;
				ddr_wrp = (ddr_wrp + wrp_offset) % TX_OFFSET_4G;
				ret = semp_fpga_reg_write(0, 0x1100014, ddr_wrp);
				if (ret)
				{
					RTE_LOG(ERR, PMD, "1.Write register %#x failed\n", 0x1100014);
					goto nsa_uninit;
				}

				tx_q_0->usr_rd_ptr = usr_rdp;
				timer_tsc = 0;
			}

			if (timer_tsc > (rte_get_timer_hz() * 2))
			{
				printf("┌enter data complement.\n");
				usr_wrp = tx_q_0->usr_wr_ptr;
				printf("│Before: tx_ddr_wrp is:%ld, tx_usr_wrp is:%ld, tx_usr_rdp is:%ld\n", ddr_wrp, usr_wrp, usr_rdp);
				diff = (usr_wrp >= usr_rdp) ? (usr_wrp - usr_rdp) : (DMA_RING_SIZE - usr_rdp + usr_wrp);
				if (diff == 0 || diff >= wrp_offset)
				{
					timer_tsc = 0;
					//prev_tsc = rte_rd_tsc();
					printf("diff length error:diff : %d\n", diff);
					printf("diff_l_e: tx_ddr_wrp is:%ld, tx_usr_wrp is:%ld, tx_usr_rdp is:%ld\n", ddr_wrp, usr_wrp, usr_rdp);
					goto eth_1;//BUG
				}

				if (usr_wrp > usr_rdp)
				{
					padding_diff_count = diff % min_offset;
					lseek(*send_fd, OFFSET_4G + ddr_wrp, SEEK_SET);
					if (padding_diff_count != 0)
					{
						ret = write(*send_fd, dma_ring + usr_rdp, diff);
						ret = write(*send_fd, frame_FF, min_offset - padding_diff_count);
						ddr_wrp = (ddr_wrp + diff + min_offset - padding_diff_count) % TX_OFFSET_4G;
						usr_rdp = (usr_rdp + diff + min_offset - padding_diff_count) % DMA_RING_SIZE;
					}
					else
					{
						ret = write(*send_fd, dma_ring + usr_rdp, diff);
						ddr_wrp = (ddr_wrp + diff) % TX_OFFSET_4G;
						usr_rdp = (usr_rdp + diff) % DMA_RING_SIZE;
					}
					ret = semp_fpga_reg_write(0, 0x1100014, ddr_wrp);
					if (ret)
					{
						RTE_LOG(ERR, PMD, "1.Write register %#x failed\n", 0x1100014);
						goto nsa_uninit;
					}
					if (usr_wrp != tx_q_0->usr_wr_ptr)
						printf("Wrong, receive new pkts.\n"); //Sometimes it complements twice, suspect new packets are recived after complement.
					tx_q_0->usr_rd_ptr = usr_rdp;
					tx_q_0->usr_wr_ptr = usr_rdp;
					usr_wrp = tx_q_0->usr_wr_ptr;
					printf("└After: tx_ddr_wrp is:%ld, tx_usr_wrp is:%ld, tx_usr_rdp is:%ld\n", ddr_wrp, usr_wrp, usr_rdp);
				}
				else
				{
					printf("Bug, haven't been processed yet.\n");
					printf("Bug: tx_ddr_wrp is:%ld, tx_usr_wrp is:%ld, tx_usr_rdp is:%ld\n", ddr_wrp, usr_wrp, usr_rdp);
				}
				timer_tsc = 0;
				ret = semp_fpga_reg_write(0, 0x1100018, 0x00000001);
				if(ret){
						RTE_LOG(ERR, PMD,"Write register %#x failed\n",0x1100018);
						goto nsa_uninit;
				}
				set_reg_flag = 1;
			}
		}
eth_1:
		if (tx_q_1->eth_port)
		{
			cur_tsc_1 = rte_rdtsc();
			diff_tsc_1 = cur_tsc_1 - prev_tsc_1;
			timer_tsc_1 += diff_tsc_1;
			prev_tsc_1 = cur_tsc_1;

			wrp_offset_1 = N_TX_BURST_1M;

			usr_wrp_1 = tx_q_1->usr_wr_ptr;
			diff_1 = (usr_wrp_1 >= usr_rdp_1) ? (usr_wrp_1 - usr_rdp_1) : (DMA_RING_SIZE - usr_rdp_1 + usr_wrp_1);
			if (unlikely(diff_1 == 0))
			{
				timer_tsc_1 = 0;
				prev_tsc_1 = rte_rdtsc();
				goto next;//continue;
			}
			if(set_reg_flag_1){
				ret = semp_fpga_reg_write(0, 0x1100118, 0x00000000);
				if(ret){
						RTE_LOG(ERR, PMD,"Write register %#x failed\n",0x1100118);
						goto nsa_uninit;
				}
				set_reg_flag_1 = 0;
			}

			if (usr_rdp_1 + wrp_offset_1 > DMA_RING_SIZE)
			{
				wrp_offset_1 = DMA_RING_SIZE - usr_rdp_1;
			}

			if (diff_1 >= wrp_offset_1)
			{
				lseek(*send_fd, OFFSET_12G + ddr_wrp_1, SEEK_SET);
				ret = write(*send_fd, dma_ring_1 + usr_rdp_1, wrp_offset_1);
				if (ret < 0)
				{
					RTE_LOG(ERR, PMD, "[ ERR1 ] or! Error info: %s, error: %d\n", strerror(errno), ret);
					goto nsa_uninit;
				}
				else if (wrp_offset_1 != (unsigned)ret)
				{
					RTE_LOG(ERR, PMD, "[ ERR1 ] Write error! (read %d, need %d)\n", ret, wrp_offset_1);
					goto nsa_uninit;
				}
				usr_rdp_1 = (usr_rdp_1 + wrp_offset_1) % DMA_RING_SIZE;
				ddr_wrp_1 = (ddr_wrp_1 + wrp_offset_1) % TX_OFFSET_4G;
				ret = semp_fpga_reg_write(0, 0x1100114, ddr_wrp_1);
				if (ret)
				{
					RTE_LOG(ERR, PMD, "1.Write register %#x failed\n", 0x1100114);
					goto nsa_uninit;
				}
				tx_q_1->usr_rd_ptr = usr_rdp_1;
				timer_tsc_1 = 0;
			}
			if(timer_tsc_1 > (rte_get_timer_hz()*2))
				printf("time is:%ld\n",timer_tsc_1 / rte_get_timer_hz());
			if (timer_tsc_1 > (rte_get_timer_hz()))
			{
				printf("┌enter data complement.\n");
				usr_wrp_1 = tx_q_1->usr_wr_ptr;
				printf("│Before: tx_ddr_wrp_1 is:%ld, tx_usr_wrp_1 is:%ld, tx_usr_rdp_1 is:%ld\n", ddr_wrp_1, usr_wrp_1, usr_rdp_1);
				diff_1 = (usr_wrp_1 >= usr_rdp_1) ? (usr_wrp_1 - usr_rdp_1) : (DMA_RING_SIZE - usr_rdp_1 + usr_wrp_1);
				if (diff_1 == 0 || diff_1 >= wrp_offset_1)
				{
					timer_tsc_1 = 0;
					printf("diff length error:diff : %d\n", diff_1);
					printf("diff_l_e: tx_ddr_wrp_1 is:%ld, tx_usr_wrp_1 is:%ld, tx_usr_rdp_1 is:%ld\n", ddr_wrp_1, usr_wrp_1, usr_rdp_1);
					goto next;//BUG
				}

				if (usr_wrp_1 > usr_rdp_1)
				{
					padding_diff_count = diff_1 % min_offset;
					lseek(*send_fd, OFFSET_12G + ddr_wrp_1, SEEK_SET);
					if (padding_diff_count != 0)
					{
						ret = write(*send_fd, dma_ring_1 + usr_rdp_1, diff_1);
						ret = write(*send_fd, frame_FF, min_offset - padding_diff_count);
						ddr_wrp_1 = (ddr_wrp_1 + diff_1 + min_offset - padding_diff_count) % TX_OFFSET_4G;
						usr_rdp_1 = (usr_rdp_1 + diff_1 + min_offset - padding_diff_count) % DMA_RING_SIZE;
					}
					else
					{
						ret = write(*send_fd, dma_ring_1 + usr_rdp_1, diff_1);
						ddr_wrp_1 = (ddr_wrp_1 + diff_1) % TX_OFFSET_4G;
						usr_rdp_1 = (usr_rdp_1 + diff_1) % DMA_RING_SIZE;
					}
					ret = semp_fpga_reg_write(0, 0x1100114, ddr_wrp_1);
					if (ret)
					{
						RTE_LOG(ERR, PMD, "1.Write register %#x failed\n", 0x1100114);
						goto nsa_uninit;
					}
					if (usr_wrp_1 != tx_q_1->usr_wr_ptr)
						printf("Wrong, receive new pkts.\n"); //Sometimes it complements twice, suspect new packets are recived after complement.
					tx_q_1->usr_rd_ptr = usr_rdp_1;
					tx_q_1->usr_wr_ptr = usr_rdp_1;
					usr_wrp_1 = tx_q_1->usr_wr_ptr;
					printf("└After: tx_ddr_wrp_1 is:%ld, tx_usr_wrp_1 is:%ld, tx_usr_rdp_1 is:%ld\n", ddr_wrp_1, usr_wrp_1, usr_rdp_1);
				}
				else
				{
					printf("Bug, haven't been processed yet.\n");
					printf("Bug: tx_ddr_wrp is:%ld, tx_usr_wrp is:%ld, tx_usr_rdp is:%ld\n", ddr_wrp_1, usr_wrp_1, usr_rdp_1);
				}
				timer_tsc_1 = 0;
			//	printf("enter DMA!!!!!!!\n");
				ret = semp_fpga_reg_write(0, 0x1100118, 0x00000001);
				if(ret){
						RTE_LOG(ERR, PMD,"Write register %#x failed\n",0x1100118);
						goto nsa_uninit;
				}
			//	ret = semp_fpga_reg_read(0, 0x1100118, &tmp);
			//	printf("0x1100118 is %d\n",tmp);
				set_reg_flag_1 = 1;
			}
		}
	}
	rte_free(frame_FF);
	frame_FF = NULL;
	printf("dma tx stop.\n");
	return 0;

nsa_uninit:
	if (*send_fd >= 0)
	{
		close(*send_fd);
	}
	semp_nsa_uninit();
	return -1;
}

static int
dsp_rx_dma_loop(struct rte_eth_dev *dev)
{
	CPU_ZERO(&cpuset);
	CPU_SET(mask, &cpuset);
	if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0)
		perror("pthread_setaffinity_np\n");

	uint16_t nb_rx = dev->data->nb_rx_queues;

	struct dsp_rx_queue *rx_q_0 = dev->data->rx_queues[0];
	struct dsp_rx_queue *rx_q_1 = dev->data->rx_queues[1];
	unsigned char *dma_ring = rx_q_0->dma_ring;
	unsigned char *dma_ring_1 = rx_q_1->dma_ring;
	uint64_t *usr_rdp = &(rx_q_0->usr_rd_ptr);
	uint64_t *usr_wrp = &(rx_q_0->usr_wr_ptr);
	uint64_t *usr_rdp_1 = &(rx_q_1->usr_rd_ptr);
	uint64_t *usr_wrp_1 = &(rx_q_1->usr_wr_ptr);
	int64_t *recv_fd = &(rx_q_0->recv_fd);

	uint32_t ddr_wrp = 0, ddr_wrp_1 = 0;
	uint64_t ddr_rdp = 0, ddr_rdp_1 = 0;
	uint64_t ddr_rdp_in_bytes = 0;
	uint32_t ddr_off_g = 0, ddr_off_b = 0;
	uint32_t rdp_offset = 1, rdp_offset_1 = 1;
	uint32_t dma_en = 0;
	uint32_t thrput = 0, thrput_1 = 0;
	int ret = 0;
	char mybuff[BUF_LEN] = {0};
	int64_t myret_value = 0;

	uint64_t prev_tsc = 0, diff_tsc = 0, cur_tsc = 0, timer_tsc = 0;
	uint32_t rd_pkt_nb_en = 0;
	uint32_t link_state_0 = 0, link_state_1 = 0;
	uint32_t i = 0;
	int diff = 0;

	snprintf(mybuff, BUF_LEN, DEV_RECV, 0);
	*recv_fd = open(mybuff, O_RDWR);
	if (*recv_fd < 0)
	{
		RTE_LOG(ERR, PMD, "[ ERR ] open %s error! (%s)", DEV_RECV, strerror(errno));
		goto nsa_uninit;
	}

	myret_value = lseek(*recv_fd, 0, SEEK_SET);
	if (myret_value < 0)
	{
		RTE_LOG(ERR, PMD, "[ ERR ] lseek %s error! (%s)", DEV_RECV, strerror(errno));
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_read(0, 0x70000c, &link_state_0); //eth0 link state
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x70000c);
		goto nsa_uninit;
	}
	ret = semp_fpga_reg_read(0, 0x71000c, &link_state_1); //eth1 link state
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x71000c);
		goto nsa_uninit;
	}
	if ((link_state_0 & 1) && (link_state_1 & 1))
	{
		rx_q_0->eth_port = 1;
		rx_q_1->eth_port = 1;
		RTE_LOG(INFO, USER2, "eth0&eth1 link...\n");
	}
	else if (link_state_0 & 1)
	{
		rx_q_0->eth_port = 1;
		rx_q_1->eth_port = 0;
		RTE_LOG(INFO, USER2, "eth0 links...\n");
	}
	else if (link_state_1 & 1)
	{
		rx_q_0->eth_port = 0;
		rx_q_1->eth_port = 1;
		RTE_LOG(INFO, USER2, "eth1 links...\n");
	}
	else
	{
		rx_q_0->eth_port = 0;
		rx_q_1->eth_port = 0;
		RTE_LOG(ERR, PMD, "eth link down.\n");
		return 0;
	}
	// ret = semp_fpga_reg_read(0, 0x1200000, &thrput);
	// while(thrput == 0){
	// 	ret = semp_fpga_reg_read(0, 0x1200000, &thrput);
	// 	usleep(1);
	// }
	//printf("link state is port0 = %d, port1 = %d\n",rx_q->eth_port[0],rx_q->eth_port[1]);
	while (1)
	{
		usleep(1);
		ret = semp_fpga_reg_read(0, 0x1200014, &dma_en); //dma enable reg
		if (ret)
		{
			RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x1200014);
			goto nsa_uninit;
		}
		if (dma_en == 0)
			break;
		ret = semp_fpga_reg_read(0, 0x1200018, &rd_pkt_nb_en); //read number of rx pkts enable
		if (ret)
		{
			RTE_LOG(ERR, PMD, "Read register %#x failed\n", 0x1200018);
			goto nsa_uninit;
		}
		if (rd_pkt_nb_en)
		{
			printf("rx port 0 read point is:%ld, write point is:%ld\n",*usr_rdp,*usr_wrp);
			printf("rx port 1 read point is:%ld, write point is:%ld\n",*usr_rdp_1,*usr_wrp_1);
			printf("rx ddr 0 read point is:%ld, write point is：%ld\n",ddr_rdp,ddr_wrp);
			printf("totally rx %ld pkts\n", rx_q_0->rx_pkt + rx_q_1->rx_pkt);
			ret = semp_fpga_reg_write(0, 0x1200018, 0x00000000);
		}

		cur_tsc = rte_rdtsc();
		diff_tsc = cur_tsc - prev_tsc;
		timer_tsc += diff_tsc;
		prev_tsc = cur_tsc;

		if (timer_tsc > (rte_get_timer_hz() / 2)) //500ms
		{

			if (rx_q_0->eth_port)
			{
				ret = semp_fpga_reg_read(0, 0x1200000, &thrput); //throughput(byte/s)
				if (ret)
				{
					RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x1200000);
					goto nsa_uninit;
				}
				if (thrput >= THRPUT_1G)
				{
					rdp_offset = N_BURST_1M; //1m;rdp_offset = 0x40;
				}
				else if (thrput >= THRPUT_100M)
				{
					rdp_offset = N_BURST_256k; //256k;rdp_offset = 0x10;
				}
				else if (thrput >= THRPUT_1M)
				{
					rdp_offset = N_BURST_16k; //16k;rdp_offset = 0x1;
				}
				else
				{
					rdp_offset = 0x1; //64B;rdp_offset = 0x100;//16k;rdp_offset = 0x1;
				}
			}
			if (rx_q_1->eth_port)
			{
				ret = semp_fpga_reg_read(0, 0x1300000, &thrput_1); //throughput(byte/s)
				if (ret)
				{
					RTE_LOG(ERR, PMD, "Read register %#x failed.\n", 0x1300000);
					goto nsa_uninit;
				}
				if (thrput_1 >= THRPUT_1G)
				{
					rdp_offset_1 = N_BURST_1M; //1m;rdp_offset = 0x40;
				}
				else if (thrput_1 >= THRPUT_100M)
				{
					rdp_offset_1 = N_BURST_256k; //256k;rdp_offset = 0x10;
				}
				else if (thrput_1 >= THRPUT_1M)
				{
					rdp_offset_1 = N_BURST_16k; //16k;rdp_offset = 0x1;
				}
				else
				{
					rdp_offset_1 = 0x1; //64B;rdp_offset = 0x100;//16k;rdp_offset = 0x1;
				}
			}
			timer_tsc = 0;
		//	printf("eth0 adjust to %d, eth1 adjust to %d\n", rdp_offset, rdp_offset_1);
		//	printf("ddr_rdp: %d, ddr_wrp: %d, ddr_rdp_1: %d, ddr_wrp_1: %d, usr_wrp is:%ld, usr_rdp is:%ld, usr_wrp_1 is:%ld, usr_rdp_1 is:%ld\n", 
		//		ddr_rdp, ddr_wrp, ddr_rdp_1, ddr_wrp_1, *usr_wrp, *usr_rdp, *usr_wrp_1, *usr_rdp_1);
		}
		if (rx_q_0->eth_port)
		{
			ret = semp_fpga_reg_read(0, 0x110000c, &ddr_wrp); //ddr write pointer
			if (ret)
			{
				RTE_LOG(ERR, PMD, "Read register %#x failed\n", 0x110000c);
				goto nsa_uninit;
			}
			// if (ddr_rdp == 0)
			// {
			// 	myret_value = lseek(*recv_fd, 0, SEEK_SET);
			// 	if (myret_value < 0)
			// 	{
			// 		RTE_LOG(ERR, PMD, "[ ERR ] lseek %s error! (%s)", DEV_RECV, strerror(errno));
			// 		goto nsa_uninit;
			// 	}
			// }
			diff = (ddr_wrp >= ddr_rdp) ? (ddr_wrp - ddr_rdp) : (N_BURST_4G - ddr_rdp + ddr_wrp);
			if (rdp_offset == 1)
			{
				if (diff >= N_BURST_1M)
				{
					rdp_offset = N_BURST_1M;
				}
				else if (diff >= N_BURST_16k)
				{
					rdp_offset = N_BURST_16k;
				}
				else
				{
					rdp_offset = 1;
				}
			}
			if (ddr_rdp + rdp_offset > N_BURST_4G) // || (*usr_wrp + rdp_offset * 64 > DMA_RING_SIZE))
			{
				rdp_offset = N_BURST_4G - ddr_rdp;
			}
			if (*usr_wrp + rdp_offset * 64 > DMA_RING_SIZE)
			{
				rdp_offset = (DMA_RING_SIZE - *usr_wrp) / 64;
			}

			if (likely((ddr_wrp - ddr_rdp >= rdp_offset) && (ddr_wrp > ddr_rdp)))
			{
				//if (!ddr_rdp)
				//	printf("ddr_rdp: %d, ddr_wrp: %d\n", ddr_rdp, ddr_wrp);
				if (((*usr_wrp > *usr_rdp) && ((DMA_RING_SIZE - *usr_wrp + *usr_rdp) > rdp_offset * 64)) ||
					((*usr_wrp < *usr_rdp) && ((*usr_rdp - *usr_wrp) > rdp_offset * 64)) || (*usr_wrp == *usr_rdp))
				{

					lseek(*recv_fd, ddr_rdp * 64, SEEK_SET);
					myret_value = read(*recv_fd, dma_ring + *usr_wrp, rdp_offset * 64);
					if (myret_value < 0)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! Error info: %s, error: %ld\n", strerror(errno), myret_value);
						goto nsa_uninit;
					}
					else if (rdp_offset * 64 != myret_value)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! (read %ld, need %ld)\n", myret_value, rdp_offset * 64);
						goto nsa_uninit;
					}

					ddr_rdp = (ddr_rdp + rdp_offset) % N_BURST_4G;
					(*usr_wrp) = (*usr_wrp + rdp_offset * 64) % DMA_RING_SIZE;
				}
			}
			else if ((N_BURST_4G - ddr_rdp + ddr_wrp >= rdp_offset) && (ddr_rdp > ddr_wrp))
			{
				//if (!ddr_rdp)
                                //       printf("ddr_rdp: %d, ddr_wrp: %d\n", ddr_rdp, ddr_wrp);
				if (((*usr_wrp > *usr_rdp) && ((DMA_RING_SIZE - *usr_wrp + *usr_rdp) > rdp_offset * 64)) ||
					((*usr_wrp < *usr_rdp) && ((*usr_rdp - *usr_wrp) > rdp_offset * 64)) || (*usr_wrp == *usr_rdp))
				{

					lseek(*recv_fd, ddr_rdp * 64, SEEK_SET);
					myret_value = read(*recv_fd, dma_ring + *usr_wrp, rdp_offset * 64);
					if (myret_value < 0)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! Error info: %s, error: %ld\n", strerror(errno), myret_value);
						goto nsa_uninit;
					}
					else if (rdp_offset * 64 != myret_value)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! (read %ld, need %ld)\n", myret_value, rdp_offset * 64);
						goto nsa_uninit;
					}

					ddr_rdp = (ddr_rdp + rdp_offset) % N_BURST_4G;
					(*usr_wrp) = (*usr_wrp + rdp_offset * 64) % DMA_RING_SIZE;
				}
			}
			else
			{
				;
				// if (ddr_rdp == ddr_wrp){
				// 	printf("enter ddr point edge!!!\n");
				// ret = semp_fpga_reg_read(0, 0x1200000, &thrput);
				// if(thrput==0){
				// 	printf("rx_ddr_wrp is:%ld, rx_ddr_rdp is:%ld, rx_usr_wrp is:%ld, rx_usr_rdp is:%ld\n",ddr_wrp,ddr_rdp,*usr_wrp,*usr_rdp);
				// 	sleep(1);
				// }
				// 		sleep(2);
				// 		Spirent_interrupt = 1;
				// 		ret = semp_fpga_reg_read(0, 0x1200000, &thrput);
				// 	}
				// }
			}
		}
		if (rx_q_1->eth_port)
		{
			ret = semp_fpga_reg_read(0, 0x110010c, &ddr_wrp_1); //ddr write pointer
			if (ret)
			{
				RTE_LOG(ERR, PMD, "Read register %#x failed\n", 0x110010c);
				goto nsa_uninit;
			}
			// if (ddr_rdp_1 == 0)
			// {
			// 	myret_value = lseek(*recv_fd, 8 * OFFSET_1G, SEEK_SET);
			// 	if (myret_value < 0)
			// 	{
			// 		RTE_LOG(ERR, PMD, "[ ERR ] lseek %s error! (%s)", DEV_RECV, strerror(errno));
			// 		goto nsa_uninit;
			// 	}
			// }
			diff = (ddr_wrp_1 >= ddr_rdp_1) ? (ddr_wrp_1 - ddr_rdp_1) : (N_BURST_4G - ddr_rdp_1 + ddr_wrp_1);
			if (rdp_offset_1 == 1)
			{
				if (diff >= N_BURST_1M)
				{
					rdp_offset_1 = N_BURST_1M;
				}
				else if (diff >= N_BURST_16k)
				{
					rdp_offset_1 = N_BURST_16k;
				}
				else
				{
					rdp_offset_1 = 1;
				}
			}

			if (ddr_rdp_1 + rdp_offset_1 > N_BURST_4G) // || (*usr_wrp + rdp_offset * 64 > DMA_RING_SIZE))
			{
				rdp_offset_1 = N_BURST_4G - ddr_rdp_1;
			}
			if (*usr_wrp_1 + rdp_offset_1 * 64 > DMA_RING_SIZE)
			{
				rdp_offset_1 = (DMA_RING_SIZE - *usr_wrp_1) / 64;
			}

			if (likely((ddr_wrp_1 - ddr_rdp_1 >= rdp_offset_1) && (ddr_wrp_1 > ddr_rdp_1)))
			{
				//if (!ddr_rdp_1)
                                //        printf("ddr_rdp_1: %d, ddr_wrp_1: %d\n", ddr_rdp_1, ddr_wrp_1);
				if (((*usr_wrp_1 > *usr_rdp_1) && ((DMA_RING_SIZE - *usr_wrp_1 + *usr_rdp_1) > rdp_offset_1 * 64)) ||
					((*usr_wrp_1 < *usr_rdp_1) && ((*usr_rdp_1 - *usr_wrp_1) > rdp_offset_1 * 64)) || (*usr_wrp_1 == *usr_rdp_1))
				{

					lseek(*recv_fd, ddr_rdp_1 * 64 + 8 * OFFSET_1G, SEEK_SET);
					myret_value = read(*recv_fd, dma_ring_1 + *usr_wrp_1, rdp_offset_1 * 64);
					if (myret_value < 0)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! Error info: %s, error: %ld\n", strerror(errno), myret_value);
						goto nsa_uninit;
					}
					else if (rdp_offset_1 * 64 != myret_value)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! (read %ld, need %ld)\n", myret_value, rdp_offset_1 * 64);
						goto nsa_uninit;
					}

					ddr_rdp_1 = (ddr_rdp_1 + rdp_offset_1) % N_BURST_4G;
					(*usr_wrp_1) = (*usr_wrp_1 + rdp_offset_1 * 64) % DMA_RING_SIZE;
				}
			}
			else if ((N_BURST_4G - ddr_rdp_1 + ddr_wrp_1 >= rdp_offset_1) && (ddr_rdp_1 > ddr_wrp_1))
			{
				//if (!ddr_rdp_1)
                                //        printf("ddr_rdp_1: %d, ddr_wrp_1: %d\n", ddr_rdp_1, ddr_wrp_1);
				if (((*usr_wrp_1 > *usr_rdp_1) && ((DMA_RING_SIZE - *usr_wrp_1 + *usr_rdp_1) > rdp_offset_1 * 64)) ||
					((*usr_wrp_1 < *usr_rdp_1) && ((*usr_rdp_1 - *usr_wrp_1) > rdp_offset_1 * 64)) || (*usr_wrp_1 == *usr_rdp_1))
				{

					lseek(*recv_fd, ddr_rdp_1 * 64 + 8 * OFFSET_1G, SEEK_SET);
					myret_value = read(*recv_fd, dma_ring_1 + *usr_wrp_1, rdp_offset_1 * 64);
					if (myret_value < 0)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! Error info: %s, error: %ld\n", strerror(errno), myret_value);
						goto nsa_uninit;
					}
					else if (rdp_offset_1 * 64 != myret_value)
					{
						RTE_LOG(ERR, PMD, "[ ERR ] Read error! (read %ld, need %ld)\n", myret_value, rdp_offset_1 * 64);
						goto nsa_uninit;
					}

					ddr_rdp_1 = (ddr_rdp_1 + rdp_offset_1) % N_BURST_4G;
					(*usr_wrp_1) = (*usr_wrp_1 + rdp_offset_1 * 64) % DMA_RING_SIZE;
				}
			}
			else
			{
				;
			}
		}
	}
	printf("dma rx stop\n");

	return 0;
nsa_uninit:
	if (*recv_fd >= 0)
	{
		close(*recv_fd);
	}
	semp_nsa_uninit();
	return -1;
}

/**
 * DPDK callback to start the device.
 *
 * Start device by starting all configured queues.
 *
 * @param dev
 *
 *   Pointer to Ethernet device structure.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static int
dsp_eth_dev_start(struct rte_eth_dev *dev)
{
	int ret;
	uint16_t i;
	uint16_t nb_rx = dev->data->nb_rx_queues;
	uint16_t nb_tx = dev->data->nb_tx_queues;
	char sendbuff[BUF_LEN] = {0};
	int mysend_fd = -1;
	int send_ret = 0;
	unsigned char *buf = NULL;
	pthread_t thread1, thread2;
	
	buf = rte_malloc(NULL, 16 * 1024 * 1024, 4096);
	memset(buf, 0, 16 * 1024 * 1024);
	snprintf(sendbuff, BUF_LEN, DEV_SEND, 0);
	send_ret = open(sendbuff, O_RDWR);
	if (send_ret < 0)
	{
		printf("[ ERR ] open %s error! (%s)", DEV_SEND, strerror(errno));
		fflush(stdout);
		return send_ret;
	}
	mysend_fd = send_ret;
	uint64_t send_ret_value;
	send_ret_value = lseek(mysend_fd, 0, SEEK_SET);
	RTE_LOG(INFO, USER2, "DDR is initializing..\n");
	for (i = 0; i < 1024; i++)
	{
		ret = write(mysend_fd, buf, 16 * 1024 * 1024);
		if (16 * 1024 * 1024 != ret)
		{
			printf("write error, need %d, but %d\n", 16 * 1024 * 1024, ret);
		}
		if (!((i + 1) % 128))
			RTE_LOG(INFO, USER2, "%dGB..\n", (i + 1) / 64);
	}
	send_ret_value = lseek(mysend_fd, 0, SEEK_CUR);
	RTE_LOG(INFO, USER2, "DDR initialization finish, initializing %ld byte.\n", send_ret_value);
	if (mysend_fd >= 0)
		close(mysend_fd);
	rte_free(buf);
	ret = dsp_dma_start(dev);
	if (ret)
	{
		return -1; //
	}
	usleep(3); //rte_delay_ms(3 * 1000);

	ret = pthread_create(&thread1, NULL, (void *)&dsp_rx_dma_loop, (void *)dev);
	if (ret != 0)
	{
		RTE_LOG(ERR, PMD, "Failed to create thread.\n");
		return -1;
	}
	ret = pthread_create(&thread2, NULL, (void *)&dsp_tx_dma_loop, (void *)dev);
	if (ret != 0)
	{
		RTE_LOG(ERR, PMD, "Failed to create tx_dma thread.\n");
		return -1;
	}
	//	pthread_join(thread1,NULL);
	/*for (i = 0; i < nb_rx; i++)
	{
		rx_q = dev->data->rx_queues[i];
		rte_eal_remote_launch(dsp_rx_dma_loop, rx_q, 1);
	}
	//rte_eal_mp_wait_lcore();
	for (i = 0; i < nb_tx; i++)
	{
		tx_q = dev->data->tx_queues[i];
		rte_eal_remote_launch(dsp_tx_dma_setup, tx_q, 2);
	}*/
	return 0;
}

/**
 * DPDK callback to stop the device.
 *
 * Stop device by stopping all configured queues.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 */
static void
dsp_eth_dev_stop(struct rte_eth_dev *dev)
{
	int ret, i = 0; //send_fd = -1, recv_fd = -1,
	uint16_t nb_rx = dev->data->nb_rx_queues;
	uint16_t nb_tx = dev->data->nb_tx_queues;

	ret = semp_fpga_reg_write(0, 0x1100000, 0x00000000); //ddr disable
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1100000);
		goto nsa_uninit;
	}
	usleep(1);
	ret = semp_fpga_reg_write(0, 0x700008, 0x00000002); //eth_loop_mode
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700008);
		goto nsa_uninit;
	}
	usleep(1);
	ret = semp_fpga_reg_write(0, 0x700000, 0x00000000); //eth_rx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700000);
		goto nsa_uninit;
	}
	usleep(1);
	ret = semp_fpga_reg_write(0, 0x700004, 0x00000000); //eth_tx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700004);
		goto nsa_uninit;
	}
	usleep(1);
	ret = semp_fpga_reg_write(0, 0x710008, 0x00000002); //eth1_loop_mode
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700008);
		goto nsa_uninit;
	}
	usleep(1);
	ret = semp_fpga_reg_write(0, 0x710000, 0x00000000); //eth1_rx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700000);
		goto nsa_uninit;
	}
	usleep(1);
	ret = semp_fpga_reg_write(0, 0x710004, 0x00000000); //eth1_tx
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x700004);
		goto nsa_uninit;
	}
	usleep(1);

	ret = semp_fpga_reg_write(0, 0x1200014, 0x00000000); //gen_en
	if (ret)
	{
		RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x1200014);
		goto nsa_uninit;
	}
	sleep(1);
	 ret = semp_fpga_reg_write(0, 0x140000, 0x5a); //eth_tx
	 if (ret)
	 {
	 	RTE_LOG(ERR, PMD, "Write register %#x failed\n", 0x140000);
	 	goto nsa_uninit;
	 }
	 usleep(10);

nsa_uninit:
	for (i = 0; i < nb_rx; i++)
	{
		struct dsp_rx_queue *rx_q = /*(struct dsp_rx_queue *)*/ (dev->data->rx_queues[i]);
		if (rx_q != NULL)
		{
			if (rx_q->dma_ring)
			{
				//printf("rx_q_%d->dma_ring: %p\n", i, rx_q->dma_ring);
				rte_free(rx_q->dma_ring);	
			}
			if (!i)
			{
				//printf("rx_q_%d->mb_pool: %p\n", i, rx_q->mb_pool);
				rte_free(rx_q->mb_pool);
			}
			rx_q->dma_ring = NULL;
			rx_q->mb_pool = NULL;
			rx_q->usr_wr_ptr = 0;
			rx_q->usr_rd_ptr = 0;
			rx_q->in_port = 0;
			if (rx_q->recv_fd >= 0)
			{
				close(rx_q->recv_fd);
			}
			rte_free(rx_q);
			rx_q = NULL;
		}
		//printf("release rx queue_%d successfully\n", i);
	}
	for (i = 0; i < nb_tx; i++)
	{
		struct dsp_tx_queue *tx_q = (struct dsp_tx_queue *)(dev->data->tx_queues[i]);
		if (tx_q != NULL)
		{
			rte_free(tx_q->dma_ring);
			tx_q->dma_ring = NULL;
			tx_q->usr_wr_ptr = 0;
			tx_q->usr_rd_ptr = 0;
			if (tx_q->send_fd >= 0)
			{
				close(tx_q->send_fd);
			}
			rte_free(tx_q);
			tx_q = NULL;
		}
		printf("release tx queue_%d successfully\n", i);
	}
	//semp_nsa_uninit();
}

/**
 * DPDK callback for Ethernet device configuration.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static int
dsp_eth_dev_configure(struct rte_eth_dev *dev)
{
	int ret;

	ret = rte_mbuf_dyn_rx_timestamp_register
			(&dsp_timestamp_dynfield_offset,
			&dsp_timestamp_rx_dynflag);
	if (ret != 0) {
		RTE_LOG(ERR, PMD, "Cannot register Rx timestamp"
				" field/flag %d\n", ret);
		semp_nsa_uninit();
		return -1;
	}

	RTE_LOG(INFO, PMD, "device %s has been configured.\n", dev->device->name);
	return 0;
}

/**
 * DPDK callback to get information about the device.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 * @param[out] info
 *   Info structure output buffer.
 */
static void
dsp_eth_dev_info(struct rte_eth_dev *dev,
				 struct rte_eth_dev_info *dev_info)
{
	dev_info->max_mac_addrs = 1;
	dev_info->max_rx_pktlen = (uint32_t)-1;
	dev_info->max_rx_queues = dev->data->nb_rx_queues;
	dev_info->max_tx_queues = dev->data->nb_tx_queues;
	dev_info->speed_capa = ETH_LINK_SPEED_10G;
}

/**
 * DPDK callback to close the device.
 *
 * Destroy all queues and objects, free memory.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 */
static void
dsp_eth_dev_close(struct rte_eth_dev *dev __rte_unused)
{
	;
}

/**
 * DPDK callback to retrieve physical link information.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 * @param[out] link
 *   Storage for current link status.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static int
dsp_eth_link_update(struct rte_eth_dev *dev __rte_unused,
					int wait_to_complete __rte_unused)
{
	return 0;
}

/**
 * DPDK callback to set primary MAC address.
 *
 * @param dev
 *   Pointer to Ethernet device structure.
 * @param mac_addr
 *   MAC address to register.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static void
dsp_eth_mac_addr_set(struct rte_eth_dev *dev,
					 struct ether_addr *mac_addr)
{
	uint64_t mac = 0;
	struct rte_eth_dev_data *data = dev->data;

	if (semp_mac_addr_get(0, &mac))
	{
		printf("get mac addr failed\n");
		//return -1;
	}
	//	printf("mac:%ld", mac);

	mac_addr->addr_bytes[0] = (uint8_t)((mac & 0xff0000000000) >> 40);
	mac_addr->addr_bytes[1] = (uint8_t)((mac & 0x00ff00000000) >> 32);
	mac_addr->addr_bytes[2] = (uint8_t)((mac & 0x0000ff000000) >> 24);
	mac_addr->addr_bytes[3] = (uint8_t)((mac & 0x000000ff0000) >> 16);
	mac_addr->addr_bytes[4] = (uint8_t)((mac & 0x00000000ff00) >> 8);
	mac_addr->addr_bytes[5] = (uint8_t)(mac & 0x0000000000ff);
	//	printf("%d %d %d %d %d %d",mac_addr->addr_bytes[0], mac_addr->addr_bytes[1], mac_addr->addr_bytes[2],
	//				mac_addr->addr_bytes[3], mac_addr->addr_bytes[4], mac_addr->addr_bytes[5]);
	ether_addr_copy(mac_addr, data->mac_addrs);
	//return 0;
}
/**
 *  * set host basetime
 *   */
static int
dsp_timesync_adjust_time(struct rte_eth_dev *dev,
						 int64_t basetime)
{
	uint32_t high = 0, low = 0, ret = 0, i = 0;
	struct dsp_rx_queue *rx_q = NULL;

	for(i = 0; i < dev->data->nb_rx_queues; i++)
	{
		if (dev->data->rx_queues[i])
		{
			rx_q = dev->data->rx_queues[i];
		}
		else
		{
			RTE_LOG(INFO, PMD, "set basetime after setting up rx queue.\n");
			return 0;
		}
		rx_q->basetime = (uint64_t)basetime;
	}

	low = (uint32_t)basetime;
	high = (uint32_t)((((uint64_t)(basetime)&UINT64_C(0x000000ff00000000)) >> 32) |
					  (((uint64_t)(basetime)&UINT64_C(0x0000ff0000000000)) >> 32) |
					  (((uint64_t)(basetime)&UINT64_C(0x00ff000000000000)) >> 32) |
					  (((uint64_t)(basetime)&UINT64_C(0xff00000000000000)) >> 32));
	ret = semp_fpga_reg_write(0, 0x1200050, low);
	if (ret)
	{
		printf("Write register failed\n");
		dsp_eth_dev_uninit(dev);
		return ret;
	}
	ret = semp_fpga_reg_write(0, 0x1200054, high);
	if (ret)
	{
		printf("Write register failed\n");
		dsp_eth_dev_uninit(dev);
		return ret;
	}
	ret = semp_fpga_reg_write(0, 0x1100000, 0xa0000000);
	if (ret)
	{
		printf("Write register failed\n");
		dsp_eth_dev_uninit(dev);
		return ret;
	}
	//usleep(1);
	ret = semp_fpga_reg_write(0, 0x1100000, 0x80000000);
	if (ret)
	{
		printf("Write register failed\n");
		dsp_eth_dev_uninit(dev);
		return ret;
	}
	return 0;
}
static const struct eth_dev_ops ops = {
	.dev_start = dsp_eth_dev_start,
	.dev_stop = dsp_eth_dev_stop,
	// .dev_set_link_up = dsp_eth_dev_set_link_up,
	// .dev_set_link_down = dsp_eth_dev_set_link_down,
	.dev_close = dsp_eth_dev_close,
	.dev_configure = dsp_eth_dev_configure,
	.dev_infos_get = dsp_eth_dev_info,
	.rx_queue_setup = dsp_eth_rx_queue_setup,
	.tx_queue_setup = dsp_eth_tx_queue_setup,
	.rx_queue_release = dsp_eth_rx_queue_release,
	.tx_queue_release = dsp_eth_tx_queue_release,
	.link_update = dsp_eth_link_update,
	// .stats_get = dsp_eth_stats_get,
	// .stats_reset = dsp_eth_stats_reset,
	.timesync_adjust_time = dsp_timesync_adjust_time,
	.mac_addr_set = dsp_eth_mac_addr_set,
};

/**
 * DPDK callback to initialize an ethernet device
 *
 * @param dev
 *   Pointer to ethernet device structure
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static int
dsp_eth_dev_init(struct rte_eth_dev *dev)
{
	nsa_info_t nsa_info;
	struct ether_addr eth_addr_init;
	struct rte_eth_dev_data *data = dev->data;
	struct rte_kvargs *kvlist;
	int i = 0;

	sleep(1);
	if (semp_nsa_init())
	{
		RTE_LOG(ERR, PMD, "semp nsa init faield!\n");
		goto nsa_uninit;
	}
	if (semp_get_nsa_info(&nsa_info))
	{
		RTE_LOG(ERR, PMD, "get the nsa informaton faield!\n");
		goto nsa_uninit; //dsp_eth_dev_uninit();
	}

	/* Get Idle core ID */
    if (dev->device->devargs != NULL &&
            dev->device->devargs->args != NULL &&
            strlen(dev->device->devargs->args) > 0) 
	{
        kvlist = rte_kvargs_parse(dev->device->devargs->args,
                        VALID_KEYS);
        if (kvlist == NULL) 
		{
            RTE_LOG(ERR, PMD, "Failed to parse device arguments %s",
                dev->device->devargs->args);
            rte_kvargs_free(kvlist);
            return -EINVAL;
        } 
		else
		{
			if ((i = rte_kvargs_count(kvlist, SLAVE_CORE)))
			{
				assert (i == 1);
				rte_kvargs_process(kvlist, SLAVE_CORE, &ascii_to_u32, &mask);
			}
			rte_kvargs_free(kvlist);
		}
	}

	dev->data->nb_rx_queues = N_RX_QUEUES;
	dev->data->nb_tx_queues = N_TX_QUEUES;
	/* Set rx, tx burst functions */
	dev->rx_pkt_burst = eth_dsp_rx;
	dev->tx_pkt_burst = eth_dsp_tx;
	/* Set function callbacks for Ethernet API */
	dev->dev_ops = &ops;

	data->mac_addrs = rte_zmalloc(data->name, sizeof(struct ether_addr), RTE_CACHE_LINE_SIZE);
	if (data->mac_addrs == NULL)
	{
		RTE_LOG(ERR, PMD, "Could not alloc space for MAC address!\n");
		return -EINVAL;
	}

	eth_random_addr(eth_addr_init.addr_bytes);
	eth_addr_init.addr_bytes[0] = eth_addr.addr_bytes[0];
	eth_addr_init.addr_bytes[1] = eth_addr.addr_bytes[1];
	eth_addr_init.addr_bytes[2] = eth_addr.addr_bytes[2];
	dsp_eth_mac_addr_set(dev, &eth_addr_init);

	return 0;

nsa_uninit:
	semp_nsa_uninit();
	return -1;
}

/**
 * DPDK callback to register a PCI device.
 *
 * This function spawns Ethernet devices out of a given PCI device.
 *
 * @param[in] pci_drv
 *   PCI driver structure (dsp_driver).
 * @param[in] pci_dev
 *   PCI device information.
 *
 * @return
 *   0 on success, a negative errno value otherwise.
 */
static int
dsp_eth_pci_probe(struct rte_pci_driver *pci_drv __rte_unused,
				  struct rte_pci_device *pci_dev)
{
	return rte_eth_dev_pci_generic_probe(pci_dev,
										 sizeof(struct pmd_internals), dsp_eth_dev_init);
}

/**
 * DPDK callback to remove a PCI device.
 *
 * This function removes all Ethernet devices belong to a given PCI device.
 *
 * @param[in] pci_dev
 *   Pointer to the PCI device.
 *
 * @return
 *   0 on success, the function cannot fail.
 */
static int
dsp_eth_pci_remove(struct rte_pci_device *pci_dev)
{
	return rte_eth_dev_pci_generic_remove(pci_dev, dsp_eth_dev_uninit);
}

static const struct rte_pci_id dsp_pci_id_table[] = {
	{RTE_PCI_DEVICE(PCI_VENDOR_ID_XILINX, PCI_DEVICE_ID_DSP_121)},
	{RTE_PCI_DEVICE(PCI_VENDOR_ID_XILINX, PCI_DEVICE_ID_DSP_241)},
	{
		.vendor_id = 0,
	}};

static struct rte_pci_driver dsp_eth_driver = {
	.id_table = dsp_pci_id_table,
	.probe = dsp_eth_pci_probe,
	.remove = dsp_eth_pci_remove,
};

RTE_PMD_REGISTER_PCI(RTE_DSP_DRIVER_NAME, dsp_eth_driver);
RTE_PMD_REGISTER_PCI_TABLE(RTE_DSP_DRIVER_NAME, dsp_pci_id_table);
RTE_PMD_REGISTER_KMOD_DEP(RTE_DSP_DRIVER_NAME, "* nsa_dma");

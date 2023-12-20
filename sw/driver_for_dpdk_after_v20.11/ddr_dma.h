
#define DMA_TRANSFER_SIZE (1 * 1024 * 1024UL) //can be modified from 1MB~16MB
//#define DMA_TRANSFER_SIZE (256 * 1024UL)
#define DMA_RING_SIZE (512 * 1024 * 1024UL)

#define N_BURST_8G 0x8000000 //number of 16KB-burst, 0x80000 means 8GB
#define N_BURST_4G 0x4000000 //number of 16KB-burst, 0x40000 means 4GB
#define N_BURST_64M 0x100000
#define N_BURST_4M 0x10000
#define N_BURST_1M 0x4000
#define N_BURST_512k 0x2000
#define N_BURST_256k 0x1000
#define N_BURST_128k 0x0800
#define N_BURST_64k 0x0400
#define N_BURST_32k 0x0200
#define N_BURST_16k 0x0100

#define N_TX_BURST_1M 0x100000 
#define TX_OFFSET_4G  0x100000000

#define OFFSET_1G (1024 * 1024 * 1024UL)
#define OFFSET_4G (4 * 1024 * 1024 * 1024UL)
#define OFFSET_8G (8 * 1024 * 1024 * 1024UL)
#define OFFSET_12G (12 * 1024 * 1024 * 1024UL)


#define DEV_SEND "/dev/xdma%d_h2c_0"
#define DEV_RECV "/dev/xdma%d_c2h_0"
#define BUF_LEN 256
#define THRPUT_1G 0x722561a
#define THRPUT_100M 0xb71b77
#define THRPUT_10M 0x989680
#define THRPUT_1M 0x1d4c1

#define PKT_LEN_OFFSET 16 //set

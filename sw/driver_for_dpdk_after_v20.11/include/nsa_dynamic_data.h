
#ifndef __NSA_DYNAMIC_DATA_H__
#define __NSA_DYNAMIC_DATA_H__

#include "nsa_types.h"

typedef struct
{
    nsa_ddr_id_e ddr_id;
    uint32_t ddr_read_time;
    uint32_t ddr_write_time;
}nsa_ddr_rw_time_t;

typedef enum
{
    DDR_TEST_CLOSE = 0,
    DDR_TEST_OPEN,
    DDR_TEST_MAX
}ndd_ddr_test_sw_e;

typedef enum
{
    DDR_REG_READ = 0,
    DDR_REG_WRITE,
    DDR_REG_MAX
}ndd_ddr_rw_e;

typedef enum
{
    DDR_TMODE_FREE = 0,
    DDR_TMODE_START,
    DDR_TMODE_STOP,
    DDR_TMODE_POLL,
    DDR_TMODE_MAX
}ndd_ddr_test_mode_e;

typedef struct
{
    nsa_ddr_id_e ddr_id;
    ndd_ddr_test_sw_e ddr_sw;
    ndd_ddr_test_mode_e ddr_mode;
    uint8_t ddr_tpoll_cnt;
    ndd_ddr_rw_e ddr_reg_rw;
}nsa_ddr_test_en_t;

typedef enum
{
    ETH_SET_MODE = 0,
    ETH_GET_MODE,
    ETH_MAX_MODE
}ndd_eth_op_e;

typedef struct
{
	nsa_port_id_e eth_id;
	ndd_eth_op_e eth_op;
	nsa_port_dir_e eth_dir;
}nsa_eth_param_t;

SERV semp_ddr_test_result_get(int board_id, nsa_ddr_id_e ddr_id, uint32_t *ddr_result);
SERV semp_ddr_curr_test_cnt_get(int board_id, nsa_ddr_id_e ddr_id, uint32_t *test_cnt);
SERV semp_ddr_rw_time_get(int board_id, nsa_ddr_rw_time_t *drr_time_info);
SERV semp_ddr_test_op(int board_id, nsa_ddr_test_en_t *ddr_info);
SERV semp_eth_rate_get(int board_id, nsa_eth_param_t *eth_param, uint32_t *bps, uint32_t *pps);
SERV semp_eth_en_op(int board_id, nsa_eth_param_t *eth_param, uint32_t *eth_en);
SERV semp_eth_tx_num_op(int board_id, nsa_eth_param_t *eth_param, uint64_t *tx_num);
SERV semp_eth_pkg_gap_op(int board_id, nsa_eth_param_t *eth_param, uint32_t *gap);
SERV semp_eth_tx_len_op(int board_id, nsa_eth_param_t *eth_param, uint32_t *tx_len);
SERV semp_end_tx_overflag_get(int board_id, nsa_port_id_e eth_id, uint32_t *over_flag);
SERV semp_xdma_block_ram_size_get(int board_id, uint32_t *size);
SERV semp_xdma_block_ram_base_addr_get(int board_id, uint64_t *addr);

#endif /*NSA_DYNAMIC_DATA_H*/


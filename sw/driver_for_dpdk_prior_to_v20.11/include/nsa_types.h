
#ifndef __SEMP_TYPES_H__
#define __SEMP_TYPES_H__

#define SEMP_TRUE  1
#define SEMP_FALSE 0

#ifndef __KERNEL__
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#endif

#define NSA_EEPROM_SN_LEN           10
#define NSA_EEPROM_PN_LEN           19
#define BOARD_NUM_MAX               16
#define BOARD_STR_LENGTH            32
/* Optical Module relevant Macro and Structure definition */
#define NSA_OPT_WAVELEN_NUM         4
#define NSA_OPT_MOD_INFO_SIZE       17
#define NDD_DYNAMIC_MMAP_OFFSET     0x01000000

#define CPLD_UPGARDE_OFFSET (1UL <<4)


typedef enum
{
    RELOAD_CHECK_ERR_SAFE_MODE = 0,
    RELOAD_CHECK_ERR_WORK_MODE,    
    RELOAD_IGNORE_ERR_SAFE_MODE,
    RELOAD_IGNORE_ERR_WORK_MODE,
    RELOAD_IGNORE_ERR_CPLD_SAFE_MODE,
    RELOAD_IGNORE_ERR_CPLD_WORK_MODE,
    RELOAD_IGNORE_ERR_ALTERA_CPLD_SAFE_MODE,
    RELOAD_IGNORE_ERR_ALTERA_CPLD_WORK_MODE,
    RELOAD_MAX_MODE
}reload_area_mode_e;

typedef enum
{
    UPGRADE_SAFE_BIN_MODE = 0,
    UPGRADE_WORK_BIN_MODE,
    UPGRADE_CPLD_SAFE_BIN_MODE,
    UPGRADE_CPLD_WORK_BIN_MODE,
    UPGRADE_MAX_MODE
}upgrade_fgpa_mode_e;

typedef enum
{
    PORT_TXFLT_SUCCESS = 0,
    PORT_TXFLT_FAIL,
    PORT_MAX_TXFLT
}nsa_port_txflt_st_e;

typedef enum
{
    PORT_PRESENT = 0,
    PORT_NOT_PRESENT,
    PORT_MAX_PRESENT
}nsa_port_present_e;

typedef enum
{
    PORT_LOS_NOEXIST = 0,
    PORT_LOS_EXIST,
    PORT_MAX_LOS
}nsa_port_los_st_e;

typedef enum
{
    PORT_LINK_DOWN = 0,
    PORT_LINK_UP,
    PORT_LINK_MAX
}nsa_port_link_st_e;

typedef enum
{
    NSA_ETH0 = 0,
    NSA_ETH1,
    NSA_ETH2,
    NSA_ETH3,
    NSA_ETH4,
    NSA_ETH5,
    NSA_ETH6,
    NSA_ETH7,
    NSA_MAX_ETH
}nsa_port_id_e;

typedef enum
{
    PORT_RX,
    PORT_TX,
    PORT_MAX_DIR
}nsa_port_dir_e;

typedef enum
{
    PORT_CLOSE = 0,
    PORT_OPEN,
    PORT_MAX_EN
}nsa_port_enable_e;

typedef enum
{
    PORT_TX_NOT_DISABLE = 0, 
    PORT_TX_DISABLE,
    PORT_MAX_DISABLE
}nsa_port_tx_disable_e;

typedef enum
{
    PORT_REVC_PKT  = 0,
    PORT_LOOP_BACK,
    PORT_BOTH_ALL,
    PORT_MAX_TYPE
}nsa_port_type_e;

typedef enum
{
    DDR_IDX0 = 0,
    DDR_IDX1,
    DDR_IDX2,
    DDR_IDX3,
    DDR_ID_MAX
}nsa_ddr_id_e;

typedef enum
{
    PORT_TYPE_NULL = 0,
    PORT_TYPE_1G,
    PORT_TYPE_10G,
    PORT_TYPE_25G,
    PORT_TYPE_100G,
    PORT_TYPE_MAX
}nsa_port_speed_type_e;

typedef enum
{
    DDR_SDRAM = 0,
    DDR_DDR1,
    DDR_DDR2,
    DDR_DDR3,
    DDR_DDR4,
    DDR_TYPE_MAX
}nsa_ddr_type_e;

typedef enum
{   
    MT40A1G8 = 1,
    MT40A1G16,
    PARTICLE_MAX
}nsa_ddr_particle_e;

typedef enum
{
    FLASH_HWIDTH_NULL = 0,
    FLASH_HWIDTH_X1,
    FLASH_HWIDTH_X2,
    FLASH_HWIDTH_X4   = 4,
    FLASH_HWIDTH_X8   = 8,
    FLASH_HWIDTH_X16  =16,
    FLASH_HWIDTH_MAX
}nsa_flash_hwidth_e;

typedef enum
{
    CPLD_HWIDTH_NULL = 0,
    CPLD_HWIDTH_X1,
    CPLD_HWIDTH_MAX
}nsa_cpld_hwidth_e;

typedef enum
{
    FLASH_TYPE_NULL = 0,
    FLASH_TYPE_SPI,
    FLASH_TYPE_BPI,
    CPLD_FLASH_TYPE_SPI = 1 + CPLD_UPGARDE_OFFSET,
    CPLD_FLASH_TYPE_PMBUS = 2 +CPLD_UPGARDE_OFFSET ,
    FLASH_TYPE_MAX
}nsa_flash_typed_e;

typedef enum
{
    CPLD_TYPE_NULL = 0,
    CPLD_TYPE_SPI,
    CPLD_TYPE_PMBUS,
    CPLD_TYPE_MAX
}nsa_cpld_typed_e;


typedef enum
{   
    NSA_BOARD_NULL  = 0,
    NSA_120A        = 0x2, 
    NSA_120B        = 0x3,
    NSA_121A        = 0x21,
    NSA_121A_2      = 0x22,
    NSA_121B        = 0x29,
    NSA_121B_2      = 0x2a,
    NSA_121B_3      = 0x2b,
    NSA_221A        = 0x31,
    NSA_242A32      = 0x41,
    NSA_242A32_2    = 0x42,
    NSA_242B32      = 0x49,
    NSA_242B32_2    = 0x4a,
    NSA_343         = 0x51,    
    NSA_343_2_32G   = 0x52,
    NSA_343_2_16G   = 0x5a,
    NSA_241B32      = 0x61,
    NSA_140         = 0x71,
    NSA_140_2       = 0x72,
    NSA_BOARD_MAX
}nsa_board_type_e;

typedef enum
{   
    NSA_121x_PID = 0x001,
    NSA_242_PID,
    NSA_343_PID,
    NSA_62x_PID,
    NSA_GZIP_PID,  
    NSA_140_PID,
    NSA_MAX_PID
}nsa_product_type_e;

typedef enum
{
    FPGA_NULL   =  0,
    FPGA_XCKU060,
    FPGA_XCKU115,
    FPGA_XCVU9P,
    FPGA_XCVU7P,
    FPGA_MAX
}nsa_fpga_chip_e;

typedef enum
{
    NSA_MODE_NULL,
    NSA_MODE_CAPI,
    NSA_MODE_DMA,
    NSA_MODE_SDACCEL,
    NSA_MODE_MAX
}nsa_mode_type_e;

/*define for pr status flag */
typedef enum
{
    PR_DYNAMIC_NONE = 0,
    PR_DYNAMIC_HAVE,
    PR_DYNAMIC_MAX
}nsa_pr_status_e;
    
/*Encryption enum info*/
typedef enum
{
    ENCRYPT_AUTH_FAIL = 0,
    ENCRYPT_AUTH_OK
}nsa_encrypt_auth_st_e;

typedef enum
{
    ENCRYPT_UNLOCK_KEY = 0,
    ENCRYPT_LOCK_KEY_FOREVER
}nsa_encrypt_lock_e;

typedef enum
{
    ENCRYPT0 = 0,
    ENCRYPT1,
    ENCRYPT_MAX
}nsa_encrypt_obj_e;

typedef enum
{
    SE_SUCCESS,
    SE_FAIL,
    SE_NULL,
    SE_MEMORY,
    SE_TIMEOUT,
    SE_EXCEED,
    SE_PARAM,
    SE_EXIST,
    SE_OPEN,
    SE_READ,
    SE_WRITE,
    SE_FORMAT,
    SE_IOCTL,
    SE_INIT,
    SE_NOTFOUND,
    SE_NOTSUPPORT,
    SE_NOTREADY,
    SE_NOSYNC,
    SE_NORESOURCE,
    SE_MSG_QUE_SYNC,
    SE_OVERFLOW,
    SE_LEN_ERR,
    SE_DMA_ERR,
    SE_OVERTIME_ERR,    
    SE_NOTEXIST,
    SE_NOTIP,
    SE_MOD_NOTEXIST,
    SE_MAX
} SERV;

#endif /* !__SEMP_TYPES_H__ */

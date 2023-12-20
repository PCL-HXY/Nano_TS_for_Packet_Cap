
#ifndef __NSA_STATIC_CTRL_H__
#define __NSA_STATIC_CTRL_H__

#include <inttypes.h>
#include "nsa_types.h"

typedef struct
{
    nsa_port_id_e port_id;
    nsa_port_dir_e port_dir;
    nsa_port_enable_e port_en;
}ndd_port_en_t;

typedef struct
{
    int module_type;                                /* Optical Module Type: bdd_optical_mod_type*/
    int wavelength;                                 /* Laser Wavelength */
    int linklength;                                 /* link length support for single mode*/
    uint8_t mode;                                   /* Single/Multi Mode*/
    double rx_power_max;                            /* Optical Module Rx Power max */
    double rx_power_min;                            /* Optical Module Rx Power min */
    double rx_power;                                /* Real-time Rx Power */
    double rx_power_detail[NSA_OPT_WAVELEN_NUM];    /* Real-time Rx Power for each lane*/
    double rx_los;                                  /* Rx LOS Assert */
    double tx_power_max;                            /* Optical Module Tx Power max */
    double tx_power_min;                            /* Optical Module Tx Power min */
    double tx_power;                                /* Real-time Tx Power */
    double tx_power_detail[NSA_OPT_WAVELEN_NUM];    /* Real-time Tx Power for each lane*/
    float temp;                                     /* Temperature */
    char type[NSA_OPT_MOD_INFO_SIZE];               /* Optical Module connector type: SC, LC....*/
    char vendor[NSA_OPT_MOD_INFO_SIZE];             /* Vendor name */
    char pn[NSA_OPT_MOD_INFO_SIZE];                 /* Vendor PN */
    char sn[NSA_OPT_MOD_INFO_SIZE];                 /* Vendor SN */
    uint8_t rx_lane_num;                            /* Rx lane number */
    uint8_t tx_lane_num;                            /* Tx lane number */
} nsa_optical_mod_info_t;

typedef struct
{
    uint8_t major;  /*fpga vertion type is 16-bit ,overflow risk*/
    uint8_t minor;  /*fpga vertion type is 16-bit ,overflow risk*/
    uint16_t build;
}nsa_version_t;

typedef struct
{
    uint32_t frequency;             /*working frequency of DDR, unit:MHz*/
    uint8_t num;                    /*number of particles DDR*/
    uint8_t group_num;              /*number of groups of DDR*/
    nsa_ddr_type_e type;            /*type of the DDR*/
    nsa_ddr_particle_e particle;    /*types of particles DDR*/
    uint8_t data_total_bits_wide;   /*total DDR data bits wide, unit:bit*/
    uint8_t data_per_bits_wide;     /*each particle data bits wide of DDR, unit:bit*/
    uint8_t data_total_capacity;    /*total capacity of data DDR data, unit:G byte*/
    uint8_t data_per_capacity;      /*capacity of each particle of DDR data, unit:G byte*/
    uint8_t ecc_total_bits_wide;    /*total DDR ecc bits wide, unit:bit*/
    uint8_t ecc_per_bits_wide;      /*each particle ecc bits wide of DDR, unit:bit*/
    uint8_t ecc_total_capacity;     /*total capacity of data DDR ecc, unit:G byte*/
    uint8_t ecc_per_capacity;       /*capacity of each particle of DDR ecc, unit:G byte*/
}nsa_ddr_att_t;

typedef struct
{
    nsa_flash_hwidth_e hard_width;       /**/
    nsa_flash_typed_e type;
    uint32_t capacity;
    uint32_t data_width;
    uint32_t erase_blk_size;
    uint32_t program_size;
    uint32_t partion_num;
}nsa_flash_att_t;

typedef struct
{
    uint8_t port_logic_num;
    uint8_t port_num;
    nsa_port_speed_type_e port_speed_type;
}nsa_port_att_t;

typedef struct
{
    uint8_t major;
    uint8_t minor;
    uint16_t release;
    uint32_t build;
    char ver_date[32];        
}base_ver_t;

typedef struct 
{
	base_ver_t lib_ver;
	base_ver_t drv_ver;
    uint32_t reserve;
}nsa_soft_ver_t;

typedef struct
{
    uint8_t board_id;
    SERV rval;
    uint8_t is_persent;
    nsa_board_type_e nsa_type;
    nsa_fpga_chip_e  fpga_chip;
    nsa_mode_type_e  mode_type;
    base_ver_t fpga_ver;
    uint16_t hw_ver;   
    uint32_t reserver;
    uint16_t fpga_ver_type;
    int pci_domain;            
    unsigned char pci_bus;      /*pci bus*/ 
    unsigned int pci_devfn;
    uint8_t board_sn[BOARD_STR_LENGTH];
    uint8_t product_sn[BOARD_STR_LENGTH];
    char fpga_ver_type_str[BOARD_STR_LENGTH];
    char board_series_str[BOARD_STR_LENGTH];
    char mode_type_str[BOARD_STR_LENGTH];
    char board_type_str[BOARD_STR_LENGTH];
}nsa_board_info_t;

typedef struct 
{
    uint8_t board_num;  /*1~8*/
    nsa_board_info_t board_info[BOARD_NUM_MAX];
    nsa_soft_ver_t soft_ver;
    uint32_t reserve;
}nsa_info_t;

typedef struct
{
	uint8_t core_vol_mask;
	float in_voltage;
	float in_current;
	float in_power;
	float out_voltage;
	float out_current;
	float out_power;
	float chip_temperature;
    float refer_voltage;
} nsa_core_voltage_param_t;

typedef struct
{
	uint8_t core_vol_mask;
	float in_voltage;
	float in_current[2];
	float in_power[2];
	float out_voltage[2];
	float out_current[2];
	float out_power[2];
	float chip_temperature[2];
    float refer_voltage[2];
}nsa_cpld_control_voltage_param_t;


typedef struct
{
	uint8_t name[32];
	uint8_t power_mask;
	float bus_voltage;
	float shunt_voltage;
	float current;
	float power;
}nsa_voltage_monitor_t;

typedef struct
{
	float vccint; 
	float vccaux; 
	float vccbram;
}nsa_fpga_voltage_t;

typedef struct
{
	nsa_fpga_voltage_t fpga_vol;
	nsa_core_voltage_param_t core_vol;
    nsa_cpld_control_voltage_param_t cpld_control_coer_vol;
	uint8_t voltage_monitor_num;
	nsa_voltage_monitor_t voltage_monitor[8];
}nsa_board_electrical_t;

typedef struct
{
	uint8_t name[32];
	float temper;
	float tlow;
	float thigh;
}nsa_temper_monitor_t;

typedef struct
{
    float fpga_tmper;
    uint8_t temper_monitor_num;
    nsa_temper_monitor_t temper_monitor[8];
}nsa_board_temperature_t;

typedef struct
{
    uint32_t encrypt_keys[8];
    nsa_encrypt_lock_e lock_val;
}nsa_encrypt_burn_t;

typedef struct
{
    uint32_t encrypt_keys[8];
    nsa_encrypt_auth_st_e auth_st;
}nsa_encrypt_auth_t;

typedef struct
{
    int             bus_id;         /* bus id */
    int             device_addr;    /* device address on the bus */
    uint32_t        reg_addr;       /* device register */
    int             reg_width;      /* register width */
    uint32_t        data;           /* read/write data */
    int             data_len;       /* read/write data length */
}nsa_bus_parm_t;


struct xil_xvc_ioc
{
	unsigned int opcode;
	unsigned int length;
	unsigned char *tms_buf;
	unsigned char *tdi_buf;
	unsigned char *tdo_buf;
};

#define FPGA_VOLTAGE_NUMBER 3
typedef struct
{   
    char *vol_str;
    float vol_low_alarm;
    float vol_high_alarm;
}ndd_fpgavol_alarm_t;

typedef struct
{    
    nsa_board_type_e btype;
    ndd_fpgavol_alarm_t fpga_alarm[FPGA_VOLTAGE_NUMBER];
}ndd_board_for_fpgavol_alarm_t;
typedef struct
{
    float adc1;
    float adc2;    
    float adc3;
    float adc4;
    float adc5;
    float adc6;
    float adc7;
    uint32_t alarm;
}ndd_get_cpld_adc_info_t;



SERV semp_nsa_init(void);
SERV semp_nsa_uninit(void);
SERV semp_fgpa_soft_reset(int board_id);
SERV semp_fpga_upgrade(int board_id, upgrade_fgpa_mode_e umode, char *path);
SERV semp_fpga_pr_upgrade(int board_id, char *file);
SERV semp_cpld_upgrade(int board_id, upgrade_fgpa_mode_e umode, char *path);
SERV semp_fpga_internal_reload(int board_id, reload_area_mode_e area_mode);
SERV semp_fpga_external_reload(int board_id, reload_area_mode_e area_mode);
SERV semp_cpld_reload(int board_id, reload_area_mode_e mode);
SERV semp_fpga_external_forced_reload(int board_id);
SERV semp_get_nsa_info(nsa_info_t *nsa_info);
SERV semp_board_electrical_info_get(int board_id, nsa_board_electrical_t *be_info);
SERV semp_board_temperatrue_info_get(int board_id, nsa_board_temperature_t *temper_info);    
SERV semp_fpga_reg_write(int board_id,uint32_t reg, uint32_t data);
SERV semp_fpga_reg_read(int board_id,uint32_t reg, uint32_t *data);
SERV semp_i2c_write(int board_id, nsa_bus_parm_t i2c_parm);
SERV semp_i2c_read(int board_id, nsa_bus_parm_t *i2c_parm);
SERV semp_pmbus_write(int board_id,nsa_bus_parm_t pmbus_parm);
SERV semp_pmbus_read(int board_id,nsa_bus_parm_t *pmbus_parm);
SERV semp_user_custom_reg_write(int board_id, uint32_t addr, uint64_t *data, uint32_t len);
SERV semp_user_custom_reg_read(int board_id, uint32_t addr, uint64_t *data, uint32_t len);
SERV semp_encrypt_burn_set(int board_id, nsa_encrypt_obj_e eobj, nsa_encrypt_burn_t *burn);
SERV semp_encrypt_auth_set(int board_id, nsa_encrypt_obj_e eobj, nsa_encrypt_auth_t *auth);
SERV semp_encrypt_auth_state_get(int board_id, nsa_encrypt_obj_e eobj, nsa_encrypt_auth_st_e *st);
SERV semp_auto_fan_run_set(int board_id);
SERV semp_temp_ctrl_fan_set(int board_id, uint32_t temp_cnt);
SERV semp_fpga_fan_speed_get(int board_id ,uint32_t *speed, uint32_t *speed1);
SERV semp_fpga_pcie_heart_get(int board_id);
SERV semp_run_HPC_status_get(int board_id, uint32_t *power_en);
SERV semp_run_HPC_status_set(int board_id, uint32_t power_en);
SERV semp_flash_attribute_get(int board_id, nsa_flash_att_t *flash_att);
SERV semp_ddr_attribute_get(int board_id, nsa_ddr_att_t *ddr_att);
SERV semp_ddr_base_addr_get(int board_id, nsa_ddr_id_e ddr_id, uint64_t *ddr_base_addr);
SERV semp_ddr_three_step_selftest(int board_id, int test_cnt);
SERV semp_port_attribute_get(int board_id, nsa_port_att_t *port_att);
SERV semp_port_enable_set(int board_id, ndd_port_en_t *port_info);
SERV semp_port_enable_get(int board_id, ndd_port_en_t *port_info);
SERV semp_port_loopback_set(int board_id, nsa_port_id_e port, nsa_port_type_e type);
SERV semp_port_loopback_get(int board_id, nsa_port_id_e port, nsa_port_type_e *type);
SERV semp_port_tx_disable_set(int board_id, nsa_port_id_e port, nsa_port_tx_disable_e tx_sw);
SERV semp_port_tx_disable_get(int board_id, nsa_port_id_e port, nsa_port_tx_disable_e *tx_sw);
SERV semp_port_link_get(int board_id, nsa_port_id_e port, nsa_port_link_st_e *pl);
SERV semp_port_los_get(int board_id, nsa_port_id_e port, nsa_port_los_st_e *port_los);
SERV semp_port_present_get(int board_id, nsa_port_id_e port, nsa_port_present_e *port_present);
SERV semp_port_txflt_st_get(int board_id, nsa_port_id_e port, nsa_port_txflt_st_e *port_txflt);
SERV semp_port_optical_module_info_get(int board_id, nsa_port_id_e port, nsa_optical_mod_info_t *info);
SERV semp_mac_addr_get(int board_id, uint64_t *mac);
SERV semp_eeprom_info_get(int board_id, uint8_t *buf, int fisrt_addr, int *len);
SERV semp_eeprom_board_info_burn(nsa_board_info_t *board_info, uint8_t *sn, nsa_version_t eep_ver);
SERV semp_eeprom_aging_info_clear(int board_id, uint8_t *buf, int fisrt_addr, int len);
SERV semp_all_board_devices_selftest(int board_id, int test_cnt, char *test_messages);
void *semp_dynamic_area_mmap(int board_id, int mmap_size, SERV *ret);
SERV semp_dynamic_area_munmap(int board_id);
SERV semp_pci_xvc_write(int board_id,struct xil_xvc_ioc *xvc_ioc);
SERV semp_fpga_hw_status_check(int board_id, uint8_t item_id);
SERV semp_user_cust_reg_get(int board_id, uint32_t addr, uint64_t *data, uint32_t len);
SERV semp_user_cust_reg_set(int board_id, uint32_t addr, uint64_t *data, uint32_t len);
SERV  semp_cpld_adc_info_get(int board_id,ndd_get_cpld_adc_info_t *adc_arry);

#endif /*__NSA_STATIC_CTRL_H__*/


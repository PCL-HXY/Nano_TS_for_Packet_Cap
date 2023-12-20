
include $(RTE_SDK)/mk/rte.vars.mk

#
# library name
#
LIB = librte_pmd_net_dsp.a

INCLUDES :=-I$(SRCDIR)


CFLAGS += -O3
CFLAGS += $(WERROR_FLAGS)
CFLAGS += -I/include
LDLIBS += -lrte_eal -lrte_mbuf -lrte_mempool -lrte_kvargs
LDLIBS += -lrte_ethdev -lrte_net
LDLIBS += -lrte_bus_pci
LDLIBS += -lpthread
#LDLIBS += -L/opt/dsp/lib241 -lndd


EXPORT_MAP := rte_pmd_net_dsp_version.map

LIBABIVER := 1

#
# all source are stored in SRCS-y
#
SRCS-$(CONFIG_RTE_LIBRTE_NET_DSP_PMD) += dsp_ethdev.c
SRCS-$(CONFIG_RTE_LIBRTE_NET_DSP_PMD) += dsp_rx.c
SRCS-$(CONFIG_RTE_LIBRTE_NET_DSP_PMD) += dsp_tx.c

#
# Export include files
#
SYMLINK-y-include +=

include $(RTE_SDK)/mk/rte.lib.mk

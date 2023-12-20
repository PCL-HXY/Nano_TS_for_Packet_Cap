$$
\begin{aligned}
& This is the source code of DPDK driver for paper "Hardware Nanosecond-Precision Timestamping for Line-Rate Packet Capture".

& ## ABSTRACT
& Cybersecurity events occurred frequently. When it comes to investigating security threats, it is es-sential to offer a 100 
& percent accurate and packet-level network history, which depends on packet capture with high precision packet timestamping. 
& Many packet capture applications are devel-oped based on DPDK—a set of libraries and drivers for fast packet processing. 
& However, DPDK cannot give an accurate timestamp for every packet, and it is unable to truly reflect the order in which 
& packets arrive at the network interface card. In addition, DPDK-based applications cannot achieve zero packet loss when the
& packet is small such as 64 B for beyond 10 Gigabit Ethernet. Therefore, we proposed a new method based on FPGA to solve this 
& problem. We also develop a DPDK driver for FPGA devices to make our design compatible with all DPDK-based applications. Our 
& method performs timestamping at line-rate for 10 Gigabit Ethernet traffic at 4 ns precision and 1 ns precision for 25 Gigabit, 
& which greatly improves the accuracy of security incident retro-spective analysis. Furthermore, the design can capture full-size 
& packets for any protocol with zero packet loss and can be applied to 40/100 Gigabit systems as well.
\end{aligned}
$$

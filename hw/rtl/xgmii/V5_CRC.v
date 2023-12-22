
//----------------------------------------------------------------------
//
// Copyright (C) 2007, Xilinx, Inc. All Rights Reserved.
//
// This file is owned and controlled by Xilinx and must be used solely
// for design, simulation, implementation and creation of design files
// limited to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and immediately
// terminates your license.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications is
// expressly prohibited.
//
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor      : Xilinx
// \   \   \/     Version     : 1.2
//  \   \         Application : CRC Wizard
//  /   /         Filename    : V5_CRC.v
// /___/   /\     Module      : V5_CRC
// \   \  /  \
//  \___\/\___\
//
//----------------------------------------------------------------------



`timescale 1 ns/ 10 ps

module V5_CRC (
	Reset,
	CRCOUT,
	CRCCLK,
	CRCDATAVALID,
	CRCDATAWIDTH,
	CRCIN,
	CRCRESET
);

	parameter CRC_INIT = 32'hFFFFFFFF;
	parameter POLYNOMIAL = 32'h04C11DB7;
    input           Reset;    
	output [31 : 0] CRCOUT;
	input 			CRCCLK;
	input 			CRCDATAVALID;
	input [2 : 0] 	CRCDATAWIDTH;
	input [64-1 : 0] CRCIN;
	input 			CRCRESET;
	
			
		V6_CRC64 #(
			.CRC_INIT(CRC_INIT)
		) CRC (
		
      	// CRC Ports
        .Reset(Reset),
		.CRCOUT(CRCOUT),	
		.CRCCLK(CRCCLK),
		.CRCDATAVALID(CRCDATAVALID),
		.CRCDATAWIDTH(CRCDATAWIDTH),
		.CRCIN(CRCIN),
		.CRCRESET(CRCRESET)
	);

	endmodule
	                                                                                                                           
	


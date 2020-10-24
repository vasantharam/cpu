`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:25:02 10/19/2020 
// Design Name: 
// Module Name:    eth_defs 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


`define RD_STATE_IDLE 0
`define RD_STATE_WAIT_FOR_RXDATA 1
`define RD_STATE_WRITE_FRAME_TO_RAM 2
`define RD_STATE_WAIT_SEND_DONE 3
`define RD_STATE_WAIT_LAST_WRITE 4

`define WR_ST_IDLE 0

`define TX_DRIVER_IDLE 0
`define TX_DRIVER_WAIT_FOR_FIFO_READY 1
`define TX_DRIVER_SEND_FRAME 2

`define ETH_FRAME_PREAMBLE_START 0
`define ETH_FRAME_PREAMBLE_END 15
`define ETH_FRAME_TYPE_MSB 41
`define ETH_FRAME_TYPE_LSB 43


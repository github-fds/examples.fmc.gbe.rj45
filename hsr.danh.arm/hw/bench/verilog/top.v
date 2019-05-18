//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// top.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
//------------------------------------------------------------------------------
//
//          +--0--+               +--1--+               +--2--+
//          |     |               |     |               |     |
//  //=====>|BR AT|=====A2B[0]===>|BR AT|======A2B[1]==>|BR AT|======\\
//  ||  //==|BT AR|<====B2A[1]====|BT AR|<=====B2A[2]===|BT AR|<==\\  ||
//  ||  ||  |     |               |     |               |     |   ||  ||
//  ||  ||  +-----+               +-----+               +-----+   ||  ||
//  ||  \\==============B2A[0]====================================//  ||
//  \\==================A2B[2]========================================//
//------------------------------------------------------------------------------
`timescale 1ns/1ps

`ifndef FPGA_FAMILY
`define FPGA_FAMILY         "VIRTEX6"
`endif
`ifndef TXCLK_INV
`define TXCLK_INV           1'b0
`endif
`ifndef DANH_OR_REDBOX
`define DANH_OR_REDBOX      "DANH"
`endif

`ifndef NUM_OF_HSR_NODE
`define NUM_OF_HSR_NODE 2
`endif

module top;
   //---------------------------------------------------------------------------
   localparam NUM_OF_HSR_NODE=`NUM_OF_HSR_NODE;
   //---------------------------------------------------------------------------
   // Let there are N nodes.
   // For given node n,
   //     it drives to node (n+1)%N through A2B.
   //     it receives from node (n+n-1)%N through B2A.
   wire              gmii_A2B_gxc[0:NUM_OF_HSR_NODE-1];
   wire  [7:0]  #1   gmii_A2B_gxd[0:NUM_OF_HSR_NODE-1];
   wire         #1   gmii_A2B_gen[0:NUM_OF_HSR_NODE-1];
   wire         #1   gmii_A2B_ger[0:NUM_OF_HSR_NODE-1];
   wire              gmii_B2A_gxc[0:NUM_OF_HSR_NODE-1];
   wire  [7:0]  #1   gmii_B2A_gxd[0:NUM_OF_HSR_NODE-1];
   wire         #1   gmii_B2A_gen[0:NUM_OF_HSR_NODE-1];
   wire         #1   gmii_B2A_ger[0:NUM_OF_HSR_NODE-1];
   //---------------------------------------------------------------------------
   wire  [NUM_OF_HSR_NODE-1:0] done;
   //---------------------------------------------------------------------------
   generate
   genvar idx;
   for (idx=0; idx<NUM_OF_HSR_NODE; idx=idx+1) begin : BLK_IDX
        hsr_node #(.NUM_OF_HSR_NODE(NUM_OF_HSR_NODE)
                  ,.HSR_ID(idx)
                  ,.MAC_ADDR(48'hF0_12_34_56_78_00) // low 8-bit for board_sw
                  ,.TX_ENABLE((idx==0)? 1 : 0)
                  ,.FPGA_FAMILY(`FPGA_FAMILY)
                  ,.TXCLK_INV(`TXCLK_INV)
                  ,.DANH_OR_REDBOX(`DANH_OR_REDBOX)
                  )
        u_hsr_node (
            .gmiiA_gtxc ( gmii_A2B_gxc[idx]) // AT0==>BR1
          , .gmiiA_txd  ( gmii_A2B_gxd[idx])
          , .gmiiA_txen ( gmii_A2B_gen[idx])
          , .gmiiA_txer ( gmii_A2B_ger[idx])

          , .gmiiA_rxc  ( gmii_B2A_gxc[(idx+1)%NUM_OF_HSR_NODE]) // BT1==>AR0
          , .gmiiA_rxd  ( gmii_B2A_gxd[(idx+1)%NUM_OF_HSR_NODE])
          , .gmiiA_rxdv ( gmii_B2A_gen[(idx+1)%NUM_OF_HSR_NODE])
          , .gmiiA_rxer ( gmii_B2A_ger[(idx+1)%NUM_OF_HSR_NODE])
          , .gmiiA_col  ( 1'b0         )
          , .gmiiA_crs  ( 1'b0         )

          , .gmiiB_gtxc ( gmii_B2A_gxc[idx]) // BT0==>AR2
          , .gmiiB_txd  ( gmii_B2A_gxd[idx])
          , .gmiiB_txen ( gmii_B2A_gen[idx])
          , .gmiiB_txer ( gmii_B2A_ger[idx])

          , .gmiiB_rxc  ( gmii_A2B_gxc[(idx+NUM_OF_HSR_NODE-1)%NUM_OF_HSR_NODE]) // AT2==>BR0
          , .gmiiB_rxd  ( gmii_A2B_gxd[(idx+NUM_OF_HSR_NODE-1)%NUM_OF_HSR_NODE])
          , .gmiiB_rxdv ( gmii_A2B_gen[(idx+NUM_OF_HSR_NODE-1)%NUM_OF_HSR_NODE])
          , .gmiiB_rxer ( gmii_A2B_ger[(idx+NUM_OF_HSR_NODE-1)%NUM_OF_HSR_NODE])
          , .gmiiB_col  ( 1'b0         )
          , .gmiiB_crs  ( 1'b0         )
        );
        assign done[idx] = u_hsr_node.done;
   end
   endgenerate
   //---------------------------------------------------------------------------
   initial begin
        //----------------------------------------------------------------------
        wait (&done==1'b1);
        //----------------------------------------------------------------------
        repeat (100) @ (posedge gmii_A2B_gxc[0]);
        $finish(2);
   end
   //---------------------------------------------------------------------------
   `ifdef VCD
   initial begin
         $display("VCD dump enable.");
         $dumpfile("wave.vcd");
         $dumpvars(0);
       //$dumpoff;
       //#(3800*1000);
       //$dumpon;
       //#(2*1000*1000);
       //$dumpoff;
   end
   `endif
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.25: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------

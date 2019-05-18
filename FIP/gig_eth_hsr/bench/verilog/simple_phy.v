//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// simple_phy.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
//------------------------------------------------------------------------------
//                 simple_phy
//        +-------------+
//        |             |
//        |             |
//        |   -+-+-+    |
//  RX===>|===>| | |===>|===>TX
//        |   -+-+-+    |
//        |             |
//        |             |
//        +-------------+
//------------------------------------------------------------------------------
`timescale 1ns/1ns
`include "fifo_async.v"

module simple_phy
(
       input        reset_n
     , input        gmii_rxc
     , input  [7:0] gmii_rxd
     , input        gmii_rxdv
     , input        gmii_rxer
     , output       gmii_gtxc
     , output [7:0] gmii_txd
     , output       gmii_txen
     , output       gmii_txer
);
   //---------------------------------------------------------------------------
   reg  [7:0] reg_gmii_rxd[0:4];
   reg  [4:0] reg_gmii_rxdv;
   reg  [4:0] reg_gmii_rxer;
   wire       rxer4=reg_gmii_rxer[4];
   wire [7:0] rxd4=reg_gmii_rxd[4];
   //---------------------------------------------------------------------------
   integer idx;
   always @ (posedge gmii_rxc) begin
       reg_gmii_rxd [0] <= gmii_rxd ;
       reg_gmii_rxdv[0] <= gmii_rxdv;
       reg_gmii_rxer[0] <= gmii_rxer;
       for (idx=1; idx<5; idx=idx+1) begin
            reg_gmii_rxd [idx] <= reg_gmii_rxd [idx-1];
            reg_gmii_rxdv[idx] <= reg_gmii_rxdv[idx-1];
            reg_gmii_rxer[idx] <= reg_gmii_rxer[idx-1];
       end
   end // always
   //---------------------------------------------------------------------------
   reg [15:0] cnt=16'h0;
   reg [ 8:0] error_insert=8'h0; // {txer,txd}
   //---------------------------------------------------------------------------
   localparam ST_READY='h0
            , ST_PRE  ='h1
            , ST_DATA ='h2
            , ST_CRC  ='h3;
   reg [1:0] state=ST_READY;
   //---------------------------------------------------------------------------
   reg  [8*10-1:0] state_ascii="READY";
   always @ (state) begin
   case (state)
       ST_READY: state_ascii="READY  ";
       ST_PRE  : state_ascii="PRE    ";
       ST_DATA : state_ascii="DATA   ";
       ST_CRC  : state_ascii="CRC    ";
       default : state_ascii="UNKNOWN";
   endcase
   end
   //---------------------------------------------------------------------------
   always @ (posedge gmii_rxc or negedge reset_n) begin
   if (reset_n==1'b0) begin
       cnt          <= 16'h0;
       error_insert <=  9'h000;
       state        <= ST_READY;
   end else begin
       case (state)
       ST_READY: begin
          if (reg_gmii_rxdv[3]==1'b1) begin
              cnt   <= 16'h1;
              state <= ST_PRE;
          end
          end // ST_READY
       ST_PRE: begin
          cnt   <= cnt + 1;
          if (reg_gmii_rxd[4]==8'hD5) begin
              cnt   <= 16'h1;
              state <= ST_DATA;
          end
          end // ST_READY
       ST_DATA: begin
          cnt   <= cnt + 1;
//if (cnt==8)  error_insert <= 9'h011; // modify src-mac
//else         error_insert <= 9'h000;
//if (cnt==40) error_insert <= 9'h100; // modify rxer
//else         error_insert <= 9'h000;
          if ((gmii_rxdv==1'b0)&&(reg_gmii_rxdv[4]==1'b1)) begin
              cnt   <= 16'h1;
              state <= ST_CRC;
          end
          end // ST_PASS
       ST_CRC: begin
          cnt   <= cnt + 1;
error_insert <= 9'h000;
//if (reg_gmii_rxdv[1]==1'b0) error_insert <= 9'h100;
          if (reg_gmii_rxdv[3]==1'b0) begin
              cnt   <= 16'h0;
              state <= ST_READY;
          end
          end // ST_CRC
       default: begin
                state <= ST_READY;
                cnt   <= 16'h0;
                end
       endcase
   end // if
   end // always
   //---------------------------------------------------------------------------
   fifo_async #(.FDW(9),.FAW(12))
   u_fifo (
      .rst     (~reset_n   )
     ,.clr     ( 1'b0      )
     ,.wr_clk  ( gmii_rxc  )
     ,.wr_rdy  (  )
     ,.wr_vld  ( reg_gmii_rxdv[4] )
     ,.wr_din  ({reg_gmii_rxer[4],reg_gmii_rxd[4]}^error_insert)
     ,.rd_clk  ( gmii_gtxc )
     ,.rd_rdy  ( 1'b1       )
     ,.rd_vld  ( gmii_txen )
     ,.rd_dout ({gmii_txer,gmii_txd})
     ,.full    (  )
     ,.empty   (  )
     ,.fullN   (  )
     ,.emptyN  (  )
     ,.wr_cnt  (  )
     ,.rd_cnt  (  )
   );
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.25: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------

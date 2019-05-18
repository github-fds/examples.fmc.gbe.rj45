//--------------------------------------------------------
// Copyright (c) 2011-2014-2018 by Future Design Systems , Inc.
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// gmii_phy.v
//--------------------------------------------------------
// VERSION = 2018.09.30.
//--------------------------------------------------------
`timescale 1ns/1ns
`include "gmii_fifo_async.v"
`include "gmii_mdio_slave.v"

//--------------------------------------------------------
module gmii_phy #(parameter LOOPBACK=1'b0,
                            MDIO_PHY_ADR=5'h0,
                            MODEL="NONE")
(
       input   wire         gmii_tx_clk // it is gtx_clk
     , input   wire [ 7:0]  gmii_txd
     , input   wire         gmii_txen
     , input   wire         gmii_txer
     , output  wire         gmii_crs
     , output  wire         gmii_col
     , output  wire         gmii_rx_clk
     , output  wire [ 7:0]  gmii_rxd
     , output  wire         gmii_rxdv
     , output  wire         gmii_rxer
     , input   wire         gmii_mdc
     , inout   wire         gmii_mdio
   `ifdef GMII_PHY_RESET
     , input   wire         gmii_phy_reset_n
   `endif
   `ifdef GMII_PHY_INT
     , output  wire         gmii_phy_int_n
   `endif
   `ifdef GMII_PHY_MODE
     , output  wire [ 3:0]  gmii_phy_mode
   `endif
);
     //---------------------------------------------------
   `ifndef GMII_PHY_RESET
     reg         gmii_phy_reset_n;
     initial begin gmii_phy_reset_n = 0;
             #50;
             gmii_phy_reset_n = 1'b1;
     end 
     wire reset_n=gmii_phy_reset_n;
   `else
     reg reg_reset_n=1'b0; initial begin #44; reg_reset_n=1'b1; end
     wire reset_n=gmii_phy_reset_n&reg_reset_n;
   `endif
   `ifndef GMII_PHY_INT
     wire         gmii_phy_int_n;
   `endif
   `ifndef GMII_PHY_MODE
     wire [ 3:0]  gmii_phy_mode;
   `endif
     //---------------------------------------------------
`ifdef XXYY128
     assign #3 gmii_rx_clk = ~gmii_tx_clk; // 8nsec period
`else
   reg        osc_clk  = 1'b0;
   always #(4.0) osc_clk <= ~osc_clk; // Oscillator clock 50MHz
   assign gmii_rx_clk = osc_clk;
`endif
     //---------------------------------------------------
     assign gmii_phy_int_n = 1'b1;
     assign gmii_phy_mode  = 4'h0;
     //---------------------------------------------------
     localparam FDW=10,  // pkt_end,gmii_txer, gmii_txd
                FAW=10;
     wire [FDW-1:0] fifo_pop_dat ;
     wire           fifo_pop_vld ;
     wire           fifo_pop_rdy ;
     wire [FAW:0]   fifo_item    ;
     //---------------------------------------------------
     reg            tmp_gmii_txen=1'b0;
     reg            tmp_gmii_txer=1'b0;
     reg  [ 7:0]    tmp_gmii_txd = 'h0;
     reg            dly_gmii_txen=1'b0;
     reg            dly_gmii_txer=1'b0;
     reg  [ 7:0]    dly_gmii_txd = 'h0;
     wire           dly_gmii_rdy;
     wire           pkt_end; // 1 at the end of packet
     //---------------------------------------------------
     always @ (posedge gmii_tx_clk) begin
           tmp_gmii_txen <= gmii_txen;
           tmp_gmii_txer <= gmii_txer;
           tmp_gmii_txd  <= gmii_txd ;
           dly_gmii_txen <= tmp_gmii_txen;
           dly_gmii_txer <= tmp_gmii_txer;
           dly_gmii_txd  <= tmp_gmii_txd ;
           // synthesis translate_off
           if ((dly_gmii_txen==1'b1)&&(dly_gmii_rdy==1'b0))
              $display("%04d %m ERROR ASYNC FIFO has been full", $time);
           // synthesis translate_on
     end
     assign pkt_end = ~tmp_gmii_txen & dly_gmii_txen;
     //---------------------------------------------------
     gmii_fifo_async #(.FDW (FDW)  // fifo data width
                      ,.FAW (FAW)  // num of entries in 2 to the power FAW
                      ,.FULN(  4)) // lookahead-full
     Ufifo_async (
           .rst     (~reset_n)
         , .clr     (1'b0)
         , .wr_clk  (gmii_tx_clk  )
         , .wr_rdy  (dly_gmii_rdy )
         , .wr_vld  (dly_gmii_txen)
         , .wr_din  ({pkt_end,dly_gmii_txer,dly_gmii_txd})
         , .rd_clk  (gmii_rx_clk )
         , .rd_rdy  (fifo_pop_rdy)
         , .rd_vld  (fifo_pop_vld)
         , .rd_dout (fifo_pop_dat)
         , .full    ()
         , .empty   ()
         , .fullN   ()
         , .emptyN  ()
         , .rd_cnt  (fifo_item)
         , .wr_cnt  ()
     );
     //---------------------------------------------------
     gmii_phy_tx
     Ugmii_phy_tx (
           .gmii_tx_clk      (gmii_tx_clk)
         , .gmii_txd         (gmii_txd   )
         , .gmii_txen        (gmii_txen  )
         , .gmii_txer        (gmii_txer  )
         , .gmii_crs         (gmii_crs   )
         , .gmii_col         (gmii_col   )
     `ifdef GMII_PHY_RESET
         , .gmii_phy_reset_n (reset_n)
     `endif
     );
     //---------------------------------------------------
     gmii_phy_rx #(.LOOPBACK(LOOPBACK),.FAW(FAW),.FDW(FDW))
     Ugmii_phy_rx (
            .gmii_rx_clk        (gmii_rx_clk)
          , .gmii_rxd           (gmii_rxd   )
          , .gmii_rxdv          (gmii_rxdv  )
          , .gmii_rxer          (gmii_rxer  )
          `ifdef GMII_PHY_RESET
          , .gmii_phy_reset_n   (reset_n)
          `endif
          , .fifo_pop_dat       (fifo_pop_dat)
          , .fifo_pop_vld       (fifo_pop_vld)
          , .fifo_pop_rdy       (fifo_pop_rdy)
          , .fifo_item          (fifo_item   )
     );
     //---------------------------------------------------
     gmii_mdio_slave #(.PHYADR(MDIO_PHY_ADR))
     Umdio_slave (
           .MDC  (gmii_mdc )
         , .MDIO (gmii_mdio)
     );
     //---------------------------------------------------
endmodule
//--------------------------------------------------------
module gmii_phy_tx
(
       input   wire         gmii_tx_clk // it is gtx_clk
     , input   wire [ 7:0]  gmii_txd
     , input   wire         gmii_txen
     , input   wire         gmii_txer
     , output  wire         gmii_crs
     , output  wire         gmii_col
   `ifdef GMII_PHY_RESET
     , input   wire         gmii_phy_reset_n
   `endif
);
     //---------------------------------------------------
   `ifndef GMII_PHY_RESET
     reg         gmii_phy_reset_n;
     initial begin gmii_phy_reset_n = 0;
             #50;
             gmii_phy_reset_n = 1'b1;
     end 
   `endif
     //---------------------------------------------------
     assign gmii_crs       = 1'b1;
     assign gmii_col       = 1'b0;
     //---------------------------------------------------
     //                   __    __    __    __    __    __
     // gmii_tx_clk    __|  |__|  |__|  |__|  |__|  |__|  |__
     //                   ____________ _____ _____________
     // gmii_txd       XXX___55_______X_D5__X_DSTADR______
     //                         ____________ _____________
     // state_tx       XXXXXXXXX__PRE_______X_DST_________
     //---------------------------------------------------
     reg [15:0] leng_type;
     reg [ 3:0] state_tx;
     localparam ST_IDLE = 'h0,
                ST_PRE  = 'h1,
                ST_DST  = 'h2,
                ST_SRC  = 'h3,
                ST_LEN  = 'h4,
                ST_PAY  = 'h5,
                ST_CRC  = 'h6,
                ST_EXT  = 'h7,
                ST_ERROR= 'h8;
     reg [15:0] cnt_tx = 'h0;
     always @ (posedge gmii_tx_clk or negedge gmii_phy_reset_n) begin
     if (gmii_phy_reset_n==1'b0) begin
         cnt_tx    <= 'h1;
         leng_type <= 'h0;
         state_tx  <= ST_IDLE;
     end else begin
         case (state_tx)
         ST_IDLE: begin
            leng_type <= 'h0;
            if (gmii_txen) state_tx <= ST_PRE;
            cnt_tx <= 'h1;
            end // ST_IDLE
         ST_PRE: begin
            if (~gmii_txen) state_tx <= ST_ERROR;
            if ( gmii_txen&(cnt_tx==7)) begin
                 if (gmii_txd!=8'hD5) state_tx <= ST_ERROR;
            end
            if (cnt_tx=='h7) begin
                cnt_tx   <= 'h1;
                if (gmii_txd==8'hD5) state_tx <= ST_DST;
                else                 state_tx <= ST_ERROR;
            end else begin
                cnt_tx   <= cnt_tx + 1;
            end
            end // ST_PRE
         ST_DST: begin
            if (~gmii_txen) state_tx <= ST_ERROR;
            if (cnt_tx=='h6) begin
                cnt_tx   <= 'h1;
                state_tx <= ST_SRC;
            end else begin
                cnt_tx   <= cnt_tx + 1;
            end
            end // ST_DST
         ST_SRC: begin
            if (~gmii_txen) state_tx <= ST_ERROR;
            if (cnt_tx=='h6) begin
                cnt_tx   <= 'h1;
                state_tx <= ST_LEN;
            end else begin
                cnt_tx   <= cnt_tx + 1;
            end
            end // ST_SRC
         ST_LEN: begin
            if (cnt_tx=='h2) begin
                cnt_tx   <= 'h1;
                state_tx <= ST_PAY;
            end else begin
                cnt_tx   <= cnt_tx + 1;
            end
            if (cnt_tx=='h1) leng_type[15:8] <= gmii_txd;
            if (cnt_tx=='h2) begin
               leng_type[ 7:0] <= ({leng_type[15:8],gmii_txd}<46) ? 46 : gmii_txd;
            end
            end // ST_LEN
         ST_PAY: begin
            if (leng_type<=1500) begin
                if (cnt_tx==leng_type) begin
                    cnt_tx   <= 'h1;
                    state_tx <= ST_CRC;
                end else begin
                    cnt_tx   <= cnt_tx + 1;
                end
            end else if (leng_type<=16'h88F7) begin // PTPv2
                if (~gmii_txen) state_tx <= ST_IDLE;
            end else if (leng_type<=16'h0800) begin // IPv4
                if (~gmii_txen) state_tx <= ST_IDLE;
            end else if (leng_type<=16'h08DD) begin // IPv6
                if (~gmii_txen) state_tx <= ST_IDLE;
            end else begin
                if (~gmii_txen) state_tx <= ST_IDLE;
            end
            end // ST_PAY
         ST_CRC: begin
            if (cnt_tx==4) begin
                cnt_tx   <= 'h1;
                state_tx <= ST_EXT;
            end else begin
                cnt_tx   <= cnt_tx + 1;
            end
            end // ST_CRC
         ST_EXT: begin
            if (~gmii_txen) state_tx <= ST_IDLE;
            end // ST_EXT
         ST_ERROR: begin
            $display($time,,"%m ERROR un-expected gmii_txen");
            end // ST_ERROR
         endcase
     end // if
     end // always
     //---------------------------------------------------
     reg  [31:0] crc;
     reg         crc_error;
     wire [31:0] crc_out = ~{crc[24],crc[25],crc[26],crc[27]
                            ,crc[28],crc[29],crc[30],crc[31]
                            ,crc[16],crc[17],crc[18],crc[19]
                            ,crc[20],crc[21],crc[22],crc[23]
                            ,crc[ 8],crc[ 9],crc[10],crc[11]
                            ,crc[12],crc[13],crc[14],crc[15]
                            ,crc[ 0],crc[ 1],crc[ 2],crc[ 3]
                            ,crc[ 4],crc[ 5],crc[ 6],crc[ 7]};
     always @ (posedge gmii_tx_clk or negedge gmii_phy_reset_n) begin
     if (gmii_phy_reset_n==1'b0) begin
         crc       <= ~'h0;
         crc_error <= 1'b0;
     end else begin
         // the first serial bit is gmii_txd[0]
         if      (state_tx==ST_PRE ) begin crc <= ~'h0; crc_error <= 1'b0; end
         else if (state_tx==ST_DST ) crc <= crc32_d8( gmii_txd, crc);
         else if (state_tx==ST_SRC ) crc <= crc32_d8( gmii_txd, crc);
         else if (state_tx==ST_LEN ) crc <= crc32_d8( gmii_txd, crc);
         else if (state_tx==ST_PAY ) crc <= crc32_d8( gmii_txd, crc);
         else if (state_tx==ST_CRC ) crc <= crc32_d8(~gmii_txd, crc);
         else if (state_tx==ST_EXT ) crc_error <= |crc;
     end // if
     end // always
     `include "crc32_d8.v"
     //---------------------------------------------------
endmodule
//--------------------------------------------------------
module gmii_phy_rx #(parameter LOOPBACK=1'b0, FAW=10, FDW=10)
(
       input   wire         gmii_rx_clk
     , output  reg  [ 7:0]  gmii_rxd
     , output  reg          gmii_rxdv
     , output  reg          gmii_rxer
   `ifdef GMII_PHY_RESET
     , input   wire         gmii_phy_reset_n
   `endif
     //---------------------------------------------------
     , input   wire [FDW-1:0] fifo_pop_dat
     , input   wire           fifo_pop_vld
     , output  reg            fifo_pop_rdy
     , input   wire [FAW:0]   fifo_item
);
     //---------------------------------------------------
   `ifndef GMII_PHY_RESET
     reg         gmii_phy_reset_n;
     initial begin gmii_phy_reset_n = 0;
             #50;
             gmii_phy_reset_n = 1'b1;
     end 
   `endif
     //---------------------------------------------------
     reg [7:0] gmii_rxdf  =  'h0;
     reg       gmii_rxerf = 1'b0;
     reg       gmii_rxdvf = 1'b0;
     reg [7:0] mac_dst[0:5];
     reg [7:0] mac_src[0:5];
     //---------------------------------------------------
     reg  [31:0] crc;
     reg         crc_error;
     wire [31:0] crc_out = ~{crc[24],crc[25],crc[26],crc[27]
                            ,crc[28],crc[29],crc[30],crc[31]
                            ,crc[16],crc[17],crc[18],crc[19]
                            ,crc[20],crc[21],crc[22],crc[23]
                            ,crc[ 8],crc[ 9],crc[10],crc[11]
                            ,crc[12],crc[13],crc[14],crc[15]
                            ,crc[ 0],crc[ 1],crc[ 2],crc[ 3]
                            ,crc[ 4],crc[ 5],crc[ 6],crc[ 7]};
     //---------------------------------------------------
     reg [15:0] leng_ptp  = 'h0; // packet length of PTPv2 including header and payload
     reg [15:0] leng_ip   = 'h0; // packet length of IP including header and payload
     reg [15:0] leng_type = 'h0;
     localparam SR_IDLE    = 'h0,
                SR_ADR_DST = 'h1,
                SR_ADR_SRC = 'h2,
                SR_PRE     = 'h3,
                SR_DST     = 'h4,
                SR_SRC     = 'h5,
                SR_LEN     = 'h6,
                SR_PAY     = 'h7,
                SR_CRC     = 'h8,
                SR_EXT     = 'h9,
                SR_ERROR   = 'hA;
     reg [ 3:0] state_rx=SR_IDLE;
     reg [15:0] cnt_rx = 'h0;
reg xxyy=1'b0;
     //---------------------------------------------------
   // synthesis translate_off
   reg  [8*10-1:0] state_ascii = "READY";
   always @ (state_rx) begin
   case (state_rx)
       SR_IDLE   : state_ascii="IDLE   ";
       SR_ADR_DST: state_ascii="ADR_DST";
       SR_ADR_SRC: state_ascii="ADR_SRC";
       SR_PRE    : state_ascii="PRE    ";
       SR_DST    : state_ascii="DST    ";
       SR_SRC    : state_ascii="SRC    ";
       SR_LEN    : state_ascii="LEN    ";
       SR_PAY    : state_ascii="PAY    ";
       SR_CRC    : state_ascii="CRC    ";
       SR_EXT    : state_ascii="EXT    ";
       SR_ERROR  : state_ascii="ERROR  ";
       default   : state_ascii="UNKNOWN";
   endcase
   end
   // synthesis translate_on
     //---------------------------------------------------
     always @ (posedge gmii_rx_clk or negedge gmii_phy_reset_n) begin
     if (gmii_phy_reset_n==1'b0) begin
         cnt_rx        <=  'h1;
         fifo_pop_rdy  <= 1'b0;
         gmii_rxdf     <=  'h0;
         gmii_rxerf    <=  'h0;
         gmii_rxdvf    <= 1'b0;
         leng_type     <=  'h0;
         leng_ip       <=  'h0;
         leng_ptp      <=  'h0;
         for (cnt_rx=0; cnt_rx<6; cnt_rx=cnt_rx+1) begin
              mac_dst[cnt_rx] <= ~'h0;
              mac_src[cnt_rx] <= ~'h0;
         end
         state_rx  <= SR_IDLE;
     end else begin
         case (state_rx)
         SR_IDLE: begin
            leng_type    <=  'h0;
            leng_ip      <=  'h0;
            leng_ptp     <=  'h0;
            fifo_pop_rdy <= 1'b1;
            if (fifo_pop_vld&(fifo_pop_dat[7:0]==8'hD5)) begin
                state_rx     <= SR_ADR_DST;
                cnt_rx       <=  'h0;
            end
            end // SR_IDLE
         SR_ADR_DST: begin
            if (cnt_rx=='h5) begin
                cnt_rx   <= 'h0;
                state_rx <= SR_ADR_SRC;
            end else begin
                cnt_rx   <= cnt_rx + 1;
            end
            mac_dst[cnt_rx]  <= fifo_pop_dat[7:0];
            end // SR_ADR_DST
         SR_ADR_SRC: begin
            if (cnt_rx=='h5) begin
                fifo_pop_rdy <= 1'b0;
                gmii_rxdf    <= 8'h55;
                gmii_rxerf   <= 1'b0;
                gmii_rxdvf   <= 1'b1;
                cnt_rx       <=  'h1;
                state_rx     <= SR_PRE;
            end else begin
                cnt_rx    <= cnt_rx + 1;
            end
            mac_src[cnt_rx]  <= fifo_pop_dat[7:0];
            end // SR_ADR_SRC
         SR_PRE: begin
            if (cnt_rx=='h8) begin
                gmii_rxdf  <= (LOOPBACK) ? mac_src[0] : mac_dst[0];
                gmii_rxerf <= 1'b0;
                gmii_rxdvf <= 1'b1;
                cnt_rx     <= 'h1;
                state_rx   <= SR_DST;
            end else if (cnt_rx=='h7) begin
                gmii_rxdf  <= 8'hD5;
                gmii_rxerf <= 1'b0;
                gmii_rxdvf <= 1'b1;
                cnt_rx     <= cnt_rx + 1;
            end else begin
                gmii_rxdf  <= 8'h55;
                gmii_rxerf <= 1'b0;
                gmii_rxdvf <= 1'b1;
                cnt_rx     <= cnt_rx + 1;
            end
            end // SR_PRE
         SR_DST: begin
            if (cnt_rx=='h6) begin
                gmii_rxdf  <= (LOOPBACK) ? mac_dst[0] : mac_src[0];
                gmii_rxerf <= 1'b0;
                gmii_rxdvf <= 1'b1;
                cnt_rx     <= 'h1;
                state_rx   <= SR_SRC;
            end else begin
                gmii_rxdf  <= (LOOPBACK) ? mac_src[cnt_rx] : mac_dst[cnt_rx];
                gmii_rxerf <= 1'b0;
                gmii_rxdvf <= 1'b1;
                cnt_rx     <= cnt_rx + 1;
            end
            end // SR_DST
         SR_SRC: begin
            if (cnt_rx=='h5) fifo_pop_rdy <= 1'b1;
            if (cnt_rx=='h6) begin
                gmii_rxdf       <= fifo_pop_dat[7:0];
                gmii_rxerf      <= fifo_pop_dat[8];
                gmii_rxdvf      <= 1'b1;
                cnt_rx          <= 'h1;
                leng_type[15:8] <= fifo_pop_dat[7:0];
                state_rx        <= SR_LEN;
            end else begin
                gmii_rxdf  <= (LOOPBACK) ? mac_dst[cnt_rx] : mac_src[cnt_rx];
                gmii_rxerf <= 1'b0;
                gmii_rxdvf <= 1'b1;
                cnt_rx     <= cnt_rx + 1;
            end
            end // SR_SRC
         SR_LEN: begin
            if (cnt_rx=='h2) begin
                cnt_rx   <= 'h1;
                state_rx <= SR_PAY;
            end else begin
                leng_type[7:0] <= ({leng_type[15:8],fifo_pop_dat[7:0]}<46) ? 46 : fifo_pop_dat[7:0];
                cnt_rx         <= cnt_rx + 1;
            end
            gmii_rxdf  <= fifo_pop_dat[7:0];
            gmii_rxerf <= fifo_pop_dat[8];
            gmii_rxdvf <= 1'b1;
            end // SR_LEN
         SR_PAY: begin
            if (leng_type<=1500) begin
                if (cnt_rx==leng_type) begin
                    cnt_rx   <= 'h1;
                    state_rx <= SR_CRC;
                end else begin
                    cnt_rx    <= cnt_rx + 1;
                end
                gmii_rxdf  <= fifo_pop_dat[7:0];
                gmii_rxerf <= fifo_pop_dat[8];
                gmii_rxdvf <= 1'b1;
            end else if (leng_type==16'h0800) begin // IP packet
                gmii_rxdf  <= fifo_pop_dat[7:0];
                gmii_rxerf <= fifo_pop_dat[8];
                gmii_rxdvf <= 1'b1;
		if (cnt_rx==2) leng_ip[15:8] <= fifo_pop_dat[7:0];
		if (cnt_rx==3) leng_ip[ 7:0] <= fifo_pop_dat[7:0];
		if (cnt_rx==leng_ip) begin
                    cnt_rx   <= 'h1;
                    state_rx <= SR_CRC;
                end else begin
		    cnt_rx <= cnt_rx + 1;
                end
            end else if (leng_type==16'h88F7) begin // PTPv2 packet
                gmii_rxdf  <= fifo_pop_dat[7:0];
                gmii_rxerf <= fifo_pop_dat[8];
                gmii_rxdvf <= 1'b1;
		if (cnt_rx==2) leng_ptp[15:8] <= fifo_pop_dat[7:0];
		if (cnt_rx==3) leng_ptp[ 7:0] <= fifo_pop_dat[7:0];
		if (cnt_rx==4) leng_ptp[ 7:0] <= (leng_ptp<46) ? 46 : leng_ptp;
		if (cnt_rx==leng_ptp) begin
                    cnt_rx   <= 'h1;
                    state_rx <= SR_CRC;
                end else begin
		    cnt_rx <= cnt_rx + 1;
                end
            end else if (leng_type==16'h8100) begin // VLAN packet
// VLAN should be checked
                gmii_rxdf  <= fifo_pop_dat[7:0];
                gmii_rxerf <= fifo_pop_dat[8];
                gmii_rxdvf <= 1'b1;
		if (cnt_rx==2) begin
                    cnt_rx   <= 'h1;
                    leng_type[15:8] <= fifo_pop_dat[7:0];
                    state_rx <= SR_LEN;
                end else begin
		    cnt_rx <= cnt_rx + 1;
                end
            end else if (leng_type==16'h892F) begin // VLAN packet
                gmii_rxdf  <= fifo_pop_dat[7:0];
                gmii_rxerf <= fifo_pop_dat[8];
                gmii_rxdvf <= 1'b1;
		if (cnt_rx==4) begin
                    cnt_rx   <= 'h1;
                    leng_type[15:8] <= fifo_pop_dat[7:0];
                    state_rx <= SR_LEN;
                end else begin
		    cnt_rx <= cnt_rx + 1;
                end
            end else begin
xxyy<=1'b1;
$display($time,,"%m un-supported Ethernet type, CRC check does not work: leng_type (0x%02X)", leng_type);
                gmii_rxdf  <= fifo_pop_dat[7:0];
                gmii_rxerf <= fifo_pop_dat[8];
                gmii_rxdvf <= 1'b1;
if (fifo_pop_dat[FDW-1]) begin
fifo_pop_rdy <= 1'b0;
gmii_rxdf <= fifo_pop_dat[7:0];
cnt_rx    <=  'h1;
state_rx  <= SR_EXT;
end
            end
            end // SR_PAY
         SR_CRC: begin
            if (cnt_rx=='h3) fifo_pop_rdy <= 1'b0;
            if (cnt_rx=='h4) begin
                gmii_rxdvf<= 1'b0;
                cnt_rx    <=  'h1;
                state_rx  <= SR_EXT;
            end else begin
                cnt_rx   <= cnt_rx + 1;
            end
            gmii_rxdf  <= fifo_pop_dat[7:0];
            gmii_rxerf <= fifo_pop_dat[8];
            end // SR_CRC
         SR_EXT: begin
            gmii_rxdvf <= 1'b0;
            gmii_rxerf <= 1'b0;
            if (cnt_rx=='h2) begin
                state_rx <= SR_IDLE;
            end else begin
                cnt_rx   <= cnt_rx + 1;
            end
            end // SR_EXT
         SR_ERROR: begin
            $display($time,,"%m ERROR un-expected rxdv");
            end // SR_ERROR
         endcase
     end // if
     end // always
     //---------------------------------------------------
     always @ (negedge gmii_rx_clk or negedge gmii_phy_reset_n) begin
     if (gmii_phy_reset_n==1'b0) begin
         gmii_rxd  <=  'h0;
         gmii_rxdv <= 1'b0;
         gmii_rxer <= 1'b0;
     end else begin
         gmii_rxd   <= (LOOPBACK==1'b0)   ? gmii_rxdf
                     : (state_rx==SR_CRC) ? crc_out[31:24] : gmii_rxdf;
         gmii_rxer  <= gmii_rxerf;
         gmii_rxdv  <= gmii_rxdvf;
     end // if
     end //always
     //---------------------------------------------------
     always @ (posedge gmii_rx_clk or negedge gmii_phy_reset_n) begin
     if (gmii_phy_reset_n==1'b0) begin
         crc       <= ~'h0;
         crc_error <= 1'b0;
     end else begin
         // the first serial bit is gmii_rxd   [0]
         if      (state_rx==SR_PRE ) begin crc <= ~'h0; crc_error <= 1'b0; end
         else if (state_rx==SR_DST ) crc <= crc32_d8( gmii_rxd, crc);
         else if (state_rx==SR_SRC ) crc <= crc32_d8( gmii_rxd, crc);
         else if (state_rx==SR_LEN ) crc <= crc32_d8( gmii_rxd, crc);
         else if (state_rx==SR_PAY ) crc <= crc32_d8( gmii_rxd, crc);
         else if (state_rx==SR_CRC ) crc <= crc32_d8(~gmii_rxd, crc);
         else if (state_rx==SR_EXT ) crc_error <= |crc;
     end // if
     end // always
     `include "crc32_d8.v"
     //---------------------------------------------------
endmodule
//--------------------------------------------------------
// Revision History
//
// 2018.09.30: 0x892F(HSR) added and checked.
//             0x8100(VLAN) added but not checked.
// 2018.07.04: 'gmii_rxerf' added, which reflect gmii_txer.
// 2014.07.04: '0x88F7' type added, which is PTPv2 over raw Ethernet packet.
// 2014.05.07: 'leng_type' of gmii_phy_tx changed in order to handle IP packet.
//             'dly_gmii_tx*/tmp_gmii_tx*' added to detect end of packet
//             through fifo.
//             'pkt_end' added for fifo.
// 2014.04.14: 'gmii_rx_clk' modified.
// 2011.07.19: 'gmii_phy_reset_n', 'gmii_phy_int_n', 'gmii_phy_mode[]'.
// 2011.07.17: 'mdio_slave()' added.
// 2011.06.26: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------

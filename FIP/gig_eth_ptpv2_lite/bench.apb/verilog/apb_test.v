//--------------------------------------------------------
// Copyright (c) 2019 by Ando Ki.
// All right reserved.
//
// http://www.future-ds.com
// adki@future-ds.com
//--------------------------------------------------------
`timescale 1ns/1ns

module apb_test
     #(parameter PTPV2_UDP=1'b0) // use UDP when 1
(
      input  wire         PRESETn
    , input  wire         PCLK
    , output reg          PSEL=1'b0
    , output reg          PENABLE=1'b0
    , output reg   [31:0] PADDR=32'h0
    , output reg          PWRITE=1'b0
    , output reg   [31:0] PWDATA=32'h0
    , input  wire  [31:0] PRDATA
   //---------------------------------------------------------
    , input  wire         IRQ_PTP
    , input  wire         IRQ_RTC
   //---------------------------------------------------------
    , input  wire         gmii_tx_clk
    , output reg  [ 7:0]  gmii_txd=8'h0
    , output reg          gmii_txen=1'b0
    , output reg          gmii_txer=1'b0
    , input  wire         gmii_rx_clk
    , output reg  [ 7:0]  gmii_rxd=8'h0
    , output reg          gmii_rxdv=1'b0
    , output reg          gmii_rxer=1'b0
   //---------------------------------------------------------
    , input  wire         ptp_pps
    , input  wire         ptp_ppus
    , input  wire         ptp_pp100us
    , input  wire         ptp_ppms
);
   //---------------------------------------------------------
   reg [31:0] data_burst[0:1023];
   //---------------------------------------------------------
   reg [47:0] mac;
   //---------------------------------------------------------
   initial begin
       wait  (PRESETn==1'b0);
       wait  (PRESETn==1'b1);
       //-----------------------------------------------------
if (1) begin
       repeat (20) @ (posedge PCLK);
       csr_test;
end
       //-----------------------------------------------------
if (1) begin
       repeat (20) @ (posedge PCLK);
       reset_test;
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       clr_test;
end
       //-----------------------------------------------------
if (0) begin
       //u_ptpv2_lite.u_rtc.ToD_CNT_NS = 32'hFFFF_FFFF;
       rtc_inc_set(8'h8, 32'h1000_0000);
       //rtc_tod_set(48'h1111_1111_1111, 32'h3B9A_CA00-(8*15));
       //rtc_tod_set(48'h1111_1111_1111, 32'h3B9A_CA00-(8*16));
       //rtc_tod_set(48'h1111_1111_1111, 32'h3B9A_CA00-(8*17));
       rtc_tod_set(48'h1111_1111_1111, 32'h3B9A_CA00-(8*18));
       ptp_enable( 1// rtc_enable
                 , 0// tsu_tx_enable
                 , 0// tsu_rx_enable
                 );
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       ptp_mac_set(48'h00_12_34_56_78_9A);
       ptp_mac_get(mac);
       if (mac!=48'h00_12_34_56_78_9A) $display($time,,"%m ERROR Mac read-after-write");
       else                            $display($time,,"%m OK Mac read-after-write");
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       rtc_tod_raw(48'h1111, 32'h5550); // read-after-write
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       rtc_tod_adj(1'b0, 32'hAAAA_3333); // inc
       repeat (20) @ (posedge PCLK);
       rtc_tod_adj(1'b1, 32'hAAAA_3333); // dec
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       rtc_inc_raw(8'h11,32'h1234_5678);
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       rtc_inc_adj(1'b0, 8'h21, 32'h3322_1234); // inc
       repeat (20) @ (posedge PCLK);
       rtc_inc_adj(1'b1, 8'h21, 32'h1234_3322); // dec
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       ptp_timer_test(20'h2);
end
       //-----------------------------------------------------
if (0) begin
       ptp_add_test;
end
       //-----------------------------------------------------
if (0) begin
       repeat (20) @ (posedge PCLK);
       ptpv2_test;
end
       //-----------------------------------------------------
       repeat (100) @ (posedge PCLK);
       $finish(2);
   end
  initial begin
      //-----------------------------------------------------
      repeat (1000) @ (posedge PCLK);
      $finish(2);
  end
   //---------------------------------------------------------
   `include "apb_tasks.v"
   `include "ptpv2_slave_tasks.v" // PTP Slave register related
   `include "ptpv2_tasks.v"       // PTPv2 packet
   //---------------------------------------------------------
endmodule

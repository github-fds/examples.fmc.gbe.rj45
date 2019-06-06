//------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------
// top.v
//------------------------------------------------------
// VERSION: 2019.05.20.
//-----------------------------------------------------------------------------
`include "apb_test.v"
`timescale 1ns/1ps

`define CLK_RTC_FREQ_MHZ     125 // 124, 125, 126
`define CLK_RTC_PERIOD_NSEC  (1000000000.0/(`CLK_RTC_FREQ_MHZ*1000000.0))

`define CLK_GMII_FREQ_MHZ    125
`define CLK_GMII_PERIOD_NSEC (1000000000.0/(`CLK_GMII_FREQ_MHZ*1000000.0))

`define CLK_BUS_FREQ_MHZ     50
`define CLK_BUS_PERIOD_NSEC  (1000000000.0/(`CLK_BUS_FREQ_MHZ*1000000.0))

module top;
    //------------------------------------------
    localparam CLK_RTC_FREQ_MHZ    =`CLK_RTC_FREQ_MHZ
             , CLK_RTC_PERIOD_NSEC =`CLK_RTC_PERIOD_NSEC;
    localparam CLK_GMII_FREQ_MHZ   =`CLK_GMII_FREQ_MHZ
             , CLK_GMII_PERIOD_NSEC=`CLK_GMII_PERIOD_NSEC;
    localparam CLK_BUS_FREQ_MHZ    =`CLK_BUS_FREQ_MHZ
             , CLK_BUS_PERIOD_NSEC =`CLK_BUS_PERIOD_NSEC;
    //------------------------------------------
    reg           PRESETn=1'b0; initial begin #170; PRESETn = 1'b1; end
    reg           PCLK   =1'b0; always #(CLK_BUS_PERIOD_NSEC/2.0) PCLK <= ~PCLK;
    wire          PSEL        ;
    wire          PENABLE     ;
    wire  [31:0]  PADDR       ;
    wire          PWRITE      ;
    wire  [31:0]  PWDATA      ;
    wire  [31:0]  PRDATA      ;
    wire          IRQ_PTP  ;
    wire          IRQ_RTC  ;
    //------------------------------------------
    reg           gmii_tx_clk=1'b0; always #(CLK_GMII_PERIOD_NSEC/2.0) gmii_tx_clk <= ~gmii_tx_clk;
    wire  [ 7:0]  gmii_txd ;
    wire          gmii_txen;
    wire          gmii_txer;
    reg           gmii_rx_clk=1'b0; always #(CLK_GMII_PERIOD_NSEC/2.0) gmii_rx_clk <= #3 ~gmii_rx_clk;
    wire  [ 7:0]  gmii_rxd ;
    wire          gmii_rxdv;
    wire          gmii_rxer;
    //------------------------------------------
    // rtc_clk will be used ptpv2_slave, which has RTC its own.
    reg           rtc_clk=1'b1;
    always #(CLK_RTC_PERIOD_NSEC/2.0) rtc_clk <= #1 ~rtc_clk;
    wire          ptpv2_master;
    wire          ptp_pps     ;
    wire          ptp_ppus    ;
    wire          ptp_pp100us ;
    wire          ptp_ppms    ;
    //------------------------------------------
    localparam PTPV2_UDP=1'b1;
    //------------------------------------------
    gig_eth_ptpv2_lite_apb  #(.PTP_GMII_TX_SYNCHRONOUS(1))
    u_ptpv2_lite  (
       .PRESETn     ( PRESETn     )
     , .PCLK        ( PCLK        )
     , .PSEL        ( PSEL        )
     , .PENABLE     ( PENABLE     )
     , .PADDR       ( PADDR       )
     , .PWRITE      ( PWRITE      )
     , .PWDATA      ( PWDATA      )
     , .PRDATA      ( PRDATA      )
     , .IRQ_PTP     (IRQ_PTP    )
     , .IRQ_RTC     (IRQ_RTC    )
     , .gmii_rx_clk (gmii_rx_clk)
     , .gmii_rxd    (gmii_rxd   )
     , .gmii_rxdv   (gmii_rxdv  )
     , .gmii_rxer   (gmii_rxer  )
     , .gmii_tx_clk (gmii_tx_clk)
     , .gmii_txd    (gmii_txd   )
     , .gmii_txen   (gmii_txen  )
     , .gmii_txer   (gmii_txer  )
     , .rtc_clk     (rtc_clk    )
     , .ptpv2_master(           )
     , .ptp_pps     (ptp_pps    )
     , .ptp_ppus    (ptp_ppus   )
     , .ptp_pp100us (ptp_pp100us)
     , .ptp_ppms    (ptp_ppms   )
    );
    //------------------------------------------
    apb_test #(.PTPV2_UDP(1'b1))
    u_test (
       .PRESETn     ( PRESETn     )
     , .PCLK        ( PCLK        )
     , .PSEL        ( PSEL        )
     , .PENABLE     ( PENABLE     )
     , .PADDR       ( PADDR       )
     , .PWRITE      ( PWRITE      )
     , .PWDATA      ( PWDATA      )
     , .PRDATA      ( PRDATA      )
     , .IRQ_PTP ( IRQ_PTP )
     , .IRQ_RTC ( IRQ_RTC )
     , .gmii_tx_clk (gmii_tx_clk)
     , .gmii_txd    (gmii_txd   )
     , .gmii_txen   (gmii_txen  )
     , .gmii_txer   (gmii_txer  )
     , .gmii_rx_clk (gmii_rx_clk)
     , .gmii_rxd    (gmii_rxd   )
     , .gmii_rxdv   (gmii_rxdv  )
     , .gmii_rxer   (gmii_rxer  )
     , .ptp_pps     (ptp_pps    )
     , .ptp_ppus    (ptp_ppus   )
     , .ptp_pp100us (ptp_pp100us)
     , .ptp_ppms    (ptp_ppms   )
    );
    //------------------------------------------
    `ifdef VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0);
    end
    `endif
    //------------------------------------------
    // synthesis translate_off
    real stamp_x, stamp_y;
    initial begin
         wait (PRESETn==1'b0);
         wait (PRESETn==1'b1);
         repeat (5) @ (posedge rtc_clk);
         @ (posedge rtc_clk); stamp_x = $realtime;
         @ (posedge rtc_clk); stamp_y = $realtime;
         $display("%m rtc_clk %.2f-nsec %.2f-Hz", stamp_y - stamp_x, 1000000000.0/(stamp_y-stamp_x));
         repeat (5) @ (posedge gmii_tx_clk);
         @ (posedge gmii_tx_clk); stamp_x = $realtime;
         @ (posedge gmii_tx_clk); stamp_y = $realtime;
         $display("%m gmii_tx_clk %.2f-nsec %.2f-Hz", stamp_y - stamp_x, 1000000000.0/(stamp_y-stamp_x));
         repeat (5) @ (posedge gmii_rx_clk);
         @ (posedge gmii_rx_clk); stamp_x = $realtime;
         @ (posedge gmii_rx_clk); stamp_y = $realtime;
         $display("%m gmii_rx_clk %.2f-nsec %.2f-Hz", stamp_y - stamp_x, 1000000000.0/(stamp_y-stamp_x));
         repeat (5) @ (posedge PCLK);
         @ (posedge PCLK); stamp_x = $realtime;
         @ (posedge PCLK); stamp_y = $realtime;
         $display("%m PCLK %.2f-nsec %.2f-Hz", stamp_y - stamp_x, 1000000000.0/(stamp_y-stamp_x));
//repeat (10000) @ (posedge gmii_clk); $finish(2);
    end
    // synthesis translate_on
    //---------------------------------------------------
endmodule
//------------------------------------------------------
// Revision history:
//
// 2019.05.20: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------

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
`ifndef FPGA_FAMILY
`define FPGA_FAMILY         "VIRTEX6"
`endif
`ifndef TXCLK_INV
`define TXCLK_INV           1'b0
`endif

`include "defines_system.v"

`timescale 1ns/1ps

module top;
   //---------------------------------------------------------------------------
   reg  RESET_N=1'b0; initial begin #55; RESET_N=1'b1; end
   //---------------------------------------------------------------------------
`ifdef BOARD_ML605
   localparam real CLK200_FREQ=200_000_000.0;
   localparam real CLK200_PERIOD_HALF=1_000_000_000.0/(CLK200_FREQ*2.0);
   reg  CLK200M=1'b0;
   always #CLK200_PERIOD_HALF CLK200M <= ~CLK200M;
   wire CLK200_P=CLK200M;
   wire CLK200_N=~CLK200M;
`elsif BOARD_ZED
   localparam real CLK100_FREQ=100_000_000.0;
   localparam real CLK100_PERIOD_HALF=1_000_000_000.0/(CLK100_FREQ*2.0);
   reg  CLK100=1'b0;
   always #CLK100_PERIOD_HALF CLK100 <= ~CLK100;
`elsif BOARD_VC
   localparam real CLK125_FREQ=125_000_000.0;
   localparam real CLK125_PERIOD_HALF=1_000_000_000.0/(CLK125_FREQ*2.0);
   reg  CLK125=1'b0;
   always #CLK125_PERIOD_HALF CLK125 <= ~CLK125;
`endif
   //---------------------------------------------------------------------------
   localparam  [47:0]   MAC_ADDR=`CONF_MAC_ADDR;
   localparam  [ 7:0]   BOARD_ID=8'h1;
   reg  [47:0]   mac_addr={MAC_ADDR[47:8],BOARD_ID[7:0]};
   wire          gmii_mdio; pullup u_m(gmii_mdio);
   wire          gmii_mdc ;
   wire          ptp_pps  ;
   wire          ptp_ppus ;
   wire          irq_gmac ;
   wire          irq_ptp  ;
   wire          irq_rtc  ;
   wire          irq_gpio ;
   wire [ 3:0]   irq_timer;
   wire          irq_swd  ;
   wire          irq_swu  ;
   //---------------------------------------------------------------------------
   wire         #(1) gmii_phy_reset_n; pullup u_gbe_rst(gmii_phy_reset_n);
   wire         #(1) gmii_gtxc   ;
   wire [ 7:0]  #(1) gmii_txd    ;
   wire         #(1) gmii_txen   ;
   wire         #(1) gmii_txer   ;
   wire         #(1) gmii_crs    ;
   wire         #(1) gmii_col    ;
   wire         #(1) gmii_rxc    ;
   wire [ 7:0]  #(1) gmii_rxd    ;
   wire         #(1) gmii_rxdv   ;
   wire         #(1) gmii_rxer   ;
   //---------------------------------------------------------------------------
   localparam AXI_WIDTH_AD=32    // address width
            , AXI_WIDTH_DA=32    // data width
            , AXI_WIDTH_DS=(AXI_WIDTH_DA/8);
   wire                      s_axi_aresetn; // output from fpga
   wire                      s_axi_aclk   ; // output from fpga
   wire  [AXI_WIDTH_AD-1:0]  s_axi_awaddr ;
   wire  [ 7:0]              s_axi_awlen  ;
   wire                      s_axi_awlock ;
   wire  [ 2:0]              s_axi_awsize ;
   wire  [ 1:0]              s_axi_awburst;
   wire  [ 3:0]              s_axi_awcache;
   wire  [ 2:0]              s_axi_awprot ;
   wire                      s_axi_awvalid;
   wire                      s_axi_awready;
   wire  [AXI_WIDTH_DA-1:0]  s_axi_wdata  ;
   wire  [AXI_WIDTH_DS-1:0]  s_axi_wstrb  ;
   wire                      s_axi_wlast  ;
   wire                      s_axi_wvalid ;
   wire                      s_axi_wready ;
   wire  [ 1:0]              s_axi_bresp  ;
   wire                      s_axi_bvalid ;
   wire                      s_axi_bready ;
   wire  [AXI_WIDTH_AD-1:0]  s_axi_araddr ;
   wire  [ 7:0]              s_axi_arlen  ;
   wire                      s_axi_arlock ;
   wire  [ 2:0]              s_axi_arsize ;
   wire  [ 1:0]              s_axi_arburst;
   wire  [ 3:0]              s_axi_arcache;
   wire  [ 2:0]              s_axi_arprot ;
   wire                      s_axi_arvalid;
   wire                      s_axi_arready;
   wire  [AXI_WIDTH_DA-1:0]  s_axi_rdata  ;
   wire  [ 1:0]              s_axi_rresp  ;
   wire                      s_axi_rlast  ;
   wire                      s_axi_rvalid ;
   wire                      s_axi_rready ;
   //---------------------------------------------------------------------------
   mac_ptp_axi #(.FPGA_FAMILY(`FPGA_FAMILY)
                ,.TXCLK_INV(`TXCLK_INV))
   u_fpga (
         .BOARD_CLK_IN     ( CLK100     )
       , .BOARD_RST_SW     ( 1'b0       )
       , .BOARD_SLIDE_SW   ( BOARD_ID[7:0])
       , .BOARD_LED        (            )
       , .BOARD_BTND       ( 1'b0       ) // active-high user interrupt from push-button switch down
       , .BOARD_BTNU       ( 1'b0       ) // active-high user interrupt from push-button switch down

       , .s_axi_aresetn  ( s_axi_aresetn )
       , .s_axi_aclk     ( s_axi_aclk    )
       , .s_axi_awaddr   ( s_axi_awaddr  )
       , .s_axi_awlen    ( s_axi_awlen   )
       , .s_axi_awlock   ( s_axi_awlock  )
       , .s_axi_awsize   ( s_axi_awsize  )
       , .s_axi_awburst  ( s_axi_awburst )
       , .s_axi_awcache  ( s_axi_awcache )
       , .s_axi_awprot   ( s_axi_awprot  )
       , .s_axi_awvalid  ( s_axi_awvalid )
       , .s_axi_awready  ( s_axi_awready )
       , .s_axi_wdata    ( s_axi_wdata   )
       , .s_axi_wstrb    ( s_axi_wstrb   )
       , .s_axi_wlast    ( s_axi_wlast   )
       , .s_axi_wvalid   ( s_axi_wvalid  )
       , .s_axi_wready   ( s_axi_wready  )
       , .s_axi_bresp    ( s_axi_bresp   )
       , .s_axi_bvalid   ( s_axi_bvalid  )
       , .s_axi_bready   ( s_axi_bready  )
       , .s_axi_araddr   ( s_axi_araddr  )
       , .s_axi_arlen    ( s_axi_arlen   )
       , .s_axi_arlock   ( s_axi_arlock  )
       , .s_axi_arsize   ( s_axi_arsize  )
       , .s_axi_arburst  ( s_axi_arburst )
       , .s_axi_arcache  ( s_axi_arcache )
       , .s_axi_arprot   ( s_axi_arprot  )
       , .s_axi_arvalid  ( s_axi_arvalid )
       , .s_axi_arready  ( s_axi_arready )
       , .s_axi_rdata    ( s_axi_rdata   )
       , .s_axi_rresp    ( s_axi_rresp   )
       , .s_axi_rlast    ( s_axi_rlast   )
       , .s_axi_rvalid   ( s_axi_rvalid  )
       , .s_axi_rready   ( s_axi_rready  )

       , .GBE_MDC          ( gmii_mdc   )
       , .GBE_MDIO         ( gmii_mdio  )

       , .GBEU_PHY_RESET_N ( gmii_phy_reset_n)
       , .GBEU_GTXC        ( gmii_gtxc  )
       , .GBEU_TXD         ( gmii_txd   )
       , .GBEU_TXEN        ( gmii_txen  )
       , .GBEU_TXER        ( gmii_txer  )
       , .GBEU_RXC         ( gmii_rxc   )
       , .GBEU_RXD         ( gmii_rxd   )
       , .GBEU_RXDV        ( gmii_rxdv  )
       , .GBEU_RXER        ( gmii_rxer  )

       , .PTP_PPS          ( ptp_pps    )
       , .PTP_PPUS         ( ptp_ppus   )
       , .IRQ_GMAC         ( irq_gmac   )
       , .IRQ_PTP          ( irq_ptp    )
       , .IRQ_RTC          ( irq_rtc    )
       , .IRQ_GPIO         ( irq_gpio   )
       , .IRQ_TIMER        ( irq_timer  )
       , .IRQ_SWD          ( irq_swd    )
       , .IRQ_SWU          ( irq_swu    )
   );
   //---------------------------------------------------------------------------
   gmii_phy #(.LOOPBACK    (1'b1)
             ,.MDIO_PHY_ADR(5'h4)
             ,.MODEL       ("NONE"))
   u_gmii_phy (
       .gmii_tx_clk      (  gmii_gtxc         )
     , .gmii_txd         (  gmii_txd          )
     , .gmii_txen        (  gmii_txen         )
     , .gmii_txer        (  gmii_txer         )
     , .gmii_crs         (  gmii_crs          )
     , .gmii_col         (  gmii_col          )
     , .gmii_rx_clk      (  gmii_rxc          )
     , .gmii_rxd         (  gmii_rxd          )
     , .gmii_rxdv        (  gmii_rxdv         )
     , .gmii_rxer        (  gmii_rxer         )
     , .gmii_mdc         (  gmii_mdc          )
     , .gmii_mdio        (  gmii_mdio         )
     , .gmii_phy_reset_n (  gmii_phy_reset_n  )
   );
   //---------------------------------------------------------------------------
   wire done;
   //---------------------------------------------------------------------------
       tester    #(.AXI_MST_ID   (0            )// Master ID
                  ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
                  ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
                  ,.ADDR_START_MEM_TX(32'h4100_0000)
                  ,.ADDR_START_MEM_RX(32'h4200_0000)
                  ,.ADDR_START_GMAC  (32'h4300_0000)
                  )
       u_test (
             .ARESETn            ( s_axi_aresetn        )
           , .ACLK               ( s_axi_aclk           )
           , .AWADDR             ( s_axi_awaddr         )
           , .AWLEN              ( s_axi_awlen          )
           , .AWLOCK             ( s_axi_awlock         )
           , .AWSIZE             ( s_axi_awsize         )
           , .AWBURST            ( s_axi_awburst        )
           `ifdef AMBA_AXI_CACHE
           , .AWCACHE            ( s_axi_awcache        )
           `endif
           `ifdef AMBA_AXI_PROT
           , .AWPROT             ( s_axi_awprot         )
           `endif
           , .AWVALID            ( s_axi_awvalid        )
           , .AWREADY            ( s_axi_awready        )
           , .WDATA              ( s_axi_wdata          )
           , .WSTRB              ( s_axi_wstrb          )
           , .WLAST              ( s_axi_wlast          )
           , .WVALID             ( s_axi_wvalid         )
           , .WREADY             ( s_axi_wready         )
           , .BRESP              ( s_axi_bresp          )
           , .BVALID             ( s_axi_bvalid         )
           , .BREADY             ( s_axi_bready         )
           , .ARADDR             ( s_axi_araddr         )
           , .ARLEN              ( s_axi_arlen          )
           , .ARLOCK             ( s_axi_arlock         )
           , .ARSIZE             ( s_axi_arsize         )
           , .ARBURST            ( s_axi_arburst        )
           `ifdef AMBA_AXI_CACHE
           , .ARCACHE            ( s_axi_arcache        )
           `endif
           `ifdef AMBA_AXI_PROT
           , .ARPROT             ( s_axi_arprot         )
           `endif
           , .ARVALID            ( s_axi_arvalid        )
           , .ARREADY            ( s_axi_arready        )
           , .RDATA              ( s_axi_rdata          )
           , .RRESP              ( s_axi_rresp          )
           , .RLAST              ( s_axi_rlast          )
           , .RVALID             ( s_axi_rvalid         )
           , .RREADY             ( s_axi_rready         )
           , .ptp_ppus           ( ptp_ppus             )
           , .mac_addr           ( mac_addr             )
           , .done               ( done                 )
       );
   //---------------------------------------------------------------------------
   initial begin
        wait(RESET_N==1'b0);
        wait(RESET_N==1'b1);
        repeat (10) @ (posedge s_axi_aclk)
        //----------------------------------------------------------------------
        wait (done==1'b1);
        //----------------------------------------------------------------------
        repeat (100) @ (posedge s_axi_aclk)
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

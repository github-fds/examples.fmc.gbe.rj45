//------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------
// dut_apb_peri.v
//------------------------------------------------------
// VERSION: 2018.09.20.
//------------------------------------------------------
  wire [31:0] gpio_in;
  assign gpio_in[31]   =1'b1; //hsr_ready;
  assign gpio_in[30]   =ptp_ready;
  assign gpio_in[29:19]=11'h0;
  assign gpio_in[18]   =irq_rtc;
  assign gpio_in[17]   =irq_ptp;
  assign gpio_in[16]   =irq_gmac;
  assign gpio_in[15:8] =8'h0;
  assign gpio_in[7:0]  =board_id;
  //--------------------------------------------------
  wire [31:0] gpio_out;
  assign irq_gpio = gpio_out[0];
  //--------------------------------------------------
  mdio_apb
  u_mdio_apb (
       .PRESETn   (PRESETn     )
     , .PCLK      (PCLK        )
     , .PADDR     (PADDR       )
     , .PENABLE   (PENABLE     )
     , .PWRITE    (PWRITE      )
     , .PWDATA    (PWDATA      )
     , .PSEL      (PSEL     [0])
     , .PRDATA    (PRDATA   [0])
     , .IRQ       (            )
     , .MDC       (gbe_mdc     )
     , .MDIO_I    (gbe_mdio_I  )
     , .MDIO_O    (gbe_mdio_O  )
     , .MDIO_T    (gbe_mdio_T  )
  );
  `ifdef AMBA_APB3
  assign PREADY [0]=1'b1;
  assign PSLVERR[0]=1'b0;
  `endif
  //--------------------------------------------------
  // port 1 for HSR
  //--------------------------------------------------
  // port 2 for gpio
  gpio_apb #(.GPIO_WIDTH(32))
  u_gpio (
       .PRESETn ( PRESETn    )
     , .PCLK    ( PCLK       )
     , .PENABLE ( PENABLE    )
     , .PADDR   ( PADDR      )
     , .PWRITE  ( PWRITE     )
     , .PWDATA  ( PWDATA     )
     , .PSEL    ( PSEL    [2])
     , .PRDATA  ( PRDATA  [2])
     , .GPIO_I  ( gpio_in    )
     , .GPIO_O  ( gpio_out   )
     , .GPIO_T  (  )
     , .IRQ     (  )
     , .IRQn    (  )
  );
  `ifdef AMBA_APB3
  assign PREADY [2]=1'b1;
  assign PSLVERR[2]=1'b0;
  `endif
  //--------------------------------------------------
  wire ptp_ppus_bufg;
  BUFG u_bufg(.I(ptp_ppus),.O(ptp_ppus_bufg));
  //--------------------------------------------------
  // port 3 for timer
  timer_apb #(.NUM_TIMER(4),.FREQUENCY(1_000_000)) // 1usec
  u_timer  (
       .PRESETn   ( PRESETn    )
     , .PCLK      ( PCLK       )
     , .PENABLE   ( PENABLE    )
     , .PADDR     ( PADDR      )
     , .PWRITE    ( PWRITE     )
     , .PWDATA    ( PWDATA     )
     , .PSEL      ( PSEL    [3])
     , .PRDATA    ( PRDATA  [3])
     , .interrupt ( irq_timer   )
     , .interruptb(  )
     , .clk_timer ( ptp_ppus_bufg )
  );
  `ifdef AMBA_APB3
  assign PREADY [3]=1'b1;
  assign PSLVERR[3]=1'b0;
  `endif
  //--------------------------------------------------
  // port 4 for PTP (see dut_axi_peri.v)
  //--------------------------------------------------

//------------------------------------------------------
// Revision history:
//
// 2018.09.20: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------

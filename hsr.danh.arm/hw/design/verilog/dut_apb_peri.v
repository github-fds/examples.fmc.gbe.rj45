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
  wire [31:0] gpio;
  assign gpio[31]=hsr_ready;
  assign gpio[30:8]=23'h0;
  assign gpio[7:0]=board_id;
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
     , .GPIO_I  ( gpio       )
     , .GPIO_O  (  )
     , .GPIO_T  (  )
     , .IRQ     (  )
     , .IRQn    (  )
  );
  `ifdef AMBA_APB3
  assign PREADY [2]=1'b1;
  assign PSLVERR[2]=1'b0;
  `endif
  //--------------------------------------------------

//------------------------------------------------------
// Revision history:
//
// 2018.09.20: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------

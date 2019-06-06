//------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------
// dut_apb_bus.v
//------------------------------------------------------
// VERSION: 2018.09.20.
//------------------------------------------------------

   //-------------------------------------------------
   localparam APB_WIDTH_PAD=32
            , APB_WIDTH_PDA=32
            , APB_WIDTH_PDS=APB_WIDTH_PDA/8;
   localparam PCLK_RATIO=2'b00;
   localparam APB_NUM_PSLAVE=5;
   //-------------------------------------------------
   localparam APB_ADDR_BASE0=P_ADDR_START_MDIO , APB_LENGTH0=P_ADDR_LENGTH_MDIO
            , APB_ADDR_BASE1=P_ADDR_START_HSR  , APB_LENGTH1=P_ADDR_LENGTH_HSR 
            , APB_ADDR_BASE2=P_ADDR_START_GPIO , APB_LENGTH2=P_ADDR_LENGTH_GPIO
            , APB_ADDR_BASE3=P_ADDR_START_TIMER, APB_LENGTH3=P_ADDR_LENGTH_TIMER
            , APB_ADDR_BASE4=P_ADDR_START_PTP  , APB_LENGTH4=P_ADDR_LENGTH_PTP
            ;
   //-------------------------------------------------
   wire                      PRESETn  =ARESETn;
   wire                      PCLK     =ACLK;
   wire [APB_WIDTH_PAD-1:0]  PADDR    ;
   wire                      PENABLE  ;
   wire                      PWRITE   ;
   wire [APB_WIDTH_PDA-1:0]  PWDATA   ;
   wire [APB_NUM_PSLAVE-1:0] PSEL     ;
   wire [APB_WIDTH_PDA-1:0]  PRDATA   [0:APB_NUM_PSLAVE-1];
   `ifdef AMBA_APB3
   wire [APB_NUM_PSLAVE-1:0] PREADY   ;
   wire [APB_NUM_PSLAVE-1:0] PSLVERR  ;
   `endif
   `ifdef AMBA_APB4
   wire [APB_WIDTH_PDS-1:0]  PSTRB    ;
   wire [ 2:0]               PPROT    ;
   `endif
   //---------------------------------------------------------
   axi_to_apb_s5 #(.AXI_WIDTH_CID(AXI_WIDTH_CID )
                  ,.AXI_WIDTH_ID (AXI_WIDTH_ID  )
                  ,.AXI_WIDTH_AD (AXI_WIDTH_AD  )
                  ,.AXI_WIDTH_DA (AXI_WIDTH_DA  )
                  ,.NUM_PSLAVE   (APB_NUM_PSLAVE)
                  ,.WIDTH_PAD    (APB_WIDTH_PAD )
                  ,.WIDTH_PDA    (APB_WIDTH_PDA )
                  ,.ADDR_PBASE0  (APB_ADDR_BASE0),.ADDR_PLENGTH0 (APB_LENGTH0)
                  ,.ADDR_PBASE1  (APB_ADDR_BASE1),.ADDR_PLENGTH1 (APB_LENGTH1)
                  ,.ADDR_PBASE2  (APB_ADDR_BASE2),.ADDR_PLENGTH2 (APB_LENGTH2)
                  ,.ADDR_PBASE3  (APB_ADDR_BASE3),.ADDR_PLENGTH3 (APB_LENGTH3)
                  ,.ADDR_PBASE4  (APB_ADDR_BASE4),.ADDR_PLENGTH4 (APB_LENGTH4)
                  ,.CLOCK_RATIO  (PCLK_RATIO    )
                  )
   u_axi_to_apb (
       .ARESETn            ( ARESETn        )
     , .ACLK               ( ACLK           )
     , .AWID               ( S_AWID      [4])
     , .AWADDR             ( S_AWADDR    [4])
     , .AWLEN              ( S_AWLEN     [4])
     , .AWLOCK             ( S_AWLOCK    [4])
     , .AWSIZE             ( S_AWSIZE    [4])
     , .AWBURST            ( S_AWBURST   [4])
     `ifdef AMBA_AXI_CACHE
     , .AWCACHE            ( S_AWCACHE   [4])
     `endif
     `ifdef AMBA_AXI_PROT  
     , .AWPROT             ( S_AWPROT    [4])
     `endif
     , .AWVALID            ( S_AWVALID   [4])
     , .AWREADY            ( S_AWREADY   [4])
     `ifdef AMBA_AXI4      
     , .AWQOS              ( S_AWQOS     [4])
     , .AWREGION           ( S_AWREGION  [4])
     `endif
     , .WID                ( S_WID       [4])
     , .WDATA              ( S_WDATA     [4])
     , .WSTRB              ( S_WSTRB     [4])
     , .WLAST              ( S_WLAST     [4])
     , .WVALID             ( S_WVALID    [4])
     , .WREADY             ( S_WREADY    [4])
     , .BID                ( S_BID       [4]) //[AXI_WIDTH_SID-1:0]
     , .BRESP              ( S_BRESP     [4])
     , .BVALID             ( S_BVALID    [4])
     , .BREADY             ( S_BREADY    [4])
     , .ARID               ( S_ARID      [4])
     , .ARADDR             ( S_ARADDR    [4])
     , .ARLEN              ( S_ARLEN     [4])
     , .ARLOCK             ( S_ARLOCK    [4])
     , .ARSIZE             ( S_ARSIZE    [4])
     , .ARBURST            ( S_ARBURST   [4])
     `ifdef AMBA_AXI_CACHE
     , .ARCACHE            ( S_ARCACHE   [4])
     `endif
     `ifdef AMBA_AXI_PROT
     , .ARPROT             ( S_ARPROT    [4])
     `endif
     , .ARVALID            ( S_ARVALID   [4])
     , .ARREADY            ( S_ARREADY   [4])
     `ifdef AMBA_AXI4     
     , .ARQOS              ( S_ARQOS     [4])
     , .ARREGION           ( S_ARREGION  [4])
     `endif
     , .RID                ( S_RID       [4]) //[AXI_WIDTH_SID-1:0]
     , .RDATA              ( S_RDATA     [4])
     , .RRESP              ( S_RRESP     [4])
     , .RLAST              ( S_RLAST     [4])
     , .RVALID             ( S_RVALID    [4])
     , .RREADY             ( S_RREADY    [4])
     , .PRESETn       (PRESETn     )
     , .PCLK          (PCLK        )
     , .S_PADDR       (PADDR       )
     , .S_PENABLE     (PENABLE     )
     , .S_PWRITE      (PWRITE      )
     , .S_PWDATA      (PWDATA      )
     , .S0_PSEL       (PSEL    [0] )
     , .S1_PSEL       (PSEL    [1] )
     , .S2_PSEL       (PSEL    [2] )
     , .S3_PSEL       (PSEL    [3] )
     , .S4_PSEL       (PSEL    [4] )
     , .S0_PRDATA     (PRDATA  [0] )
     , .S1_PRDATA     (PRDATA  [1] )
     , .S2_PRDATA     (PRDATA  [2] )
     , .S3_PRDATA     (PRDATA  [3] )
     , .S4_PRDATA     (PRDATA  [4] )
     `ifdef AMBA_APB3
     , .S0_PREADY     (PREADY  [0] )
     , .S1_PREADY     (PREADY  [1] )
     , .S2_PREADY     (PREADY  [2] )
     , .S3_PREADY     (PREADY  [3] )
     , .S4_PREADY     (PREADY  [4] )
     , .S0_PSLVERR    (PSLVERR [0] )
     , .S1_PSLVERR    (PSLVERR [1] )
     , .S2_PSLVERR    (PSLVERR [2] )
     , .S3_PSLVERR    (PSLVERR [3] )
     , .S4_PSLVERR    (PSLVERR [4] )
     `endif
     `ifdef AMBA_APB4
     , .S_PSTRB       (PSTRB       )
     , .S_PPROT       (PPROT       )
     `endif
   );
   //--------------------------------------------------
   // HSR not used
    assign PRDATA [1] = 32'h0;
    `ifdef AMBA_APB3
    assign PREADY [1]=1'b1;
    assign PSLVERR[1]=1'b0;
    `endif
//------------------------------------------------------
// Revision history:
//
// 2018.09.20: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------

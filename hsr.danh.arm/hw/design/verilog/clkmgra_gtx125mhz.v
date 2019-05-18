`ifndef CLKMGRA_GTX125MHZ_V
`define CLKMGRA_GTX125MHZ_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved.
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module clkmgra_gtx125mhz
     #(parameter FPGA_FAMILY="VIRTEX6")
(
      input   wire    CLK125_IN
    , output  wire    CLKOUT0
    , output  wire    CLKOUT90
    , output  wire    CLKOUT180
    , output  wire    CLKOUT270
    , input   wire    RST
    , output  wire    LOCKED
);
    parameter INPUT_CLOCK_FREQ = 125_000_000;
//------------------------------------------------------------------------------
generate
if (FPGA_FAMILY=="VIRTEX6") begin: VIRTEX6_CLK125
    wire CLK0  ;
    wire CLK90 ;
    wire CLK180;
    wire CLK270;
    wire CLKFB = CLKOUT0;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));

    DCM #(.CLKIN_PERIOD  (1_000_000_000.0/INPUT_CLOCK_FREQ))
    u_dcm (
          .CLKFB     ( CLKFB     )
        , .CLKIN     ( CLK125_IN )
        , .DSSEN     ( 1'b0      )
        , .RST       ( RST       )
        , .PSEN      ( 1'b0      )
        , .PSINCDEC  ( 1'b0      )
        , .PSCLK     ( 1'b0      )
        , .CLK0      ( CLK0      ) // F=Fin
        , .CLK90     ( CLK90     )
        , .CLK180    ( CLK180    )
        , .CLK270    ( CLK270    )
        , .CLK2X     (  ) // F=Fin*2
        , .CLK2X180  (  )
        , .CLKDV     (  ) // F=Fin/CLKDV_DIVIDE
        , .CLKFX     (  ) // F=Fin*CLKFX_MULTIPLY/CLKFX_DIVIDE
        , .CLKFX180  (  )
        , .STATUS    (  )
        , .LOCKED    ( LOCKED   )
        , .PSDONE    (  )
    );
end
//------------------------------------------------------------------------------
else if ((FPGA_FAMILY=="VIRTEX7")||(FPGA_FAMILY=="ARTIX7 ")) begin: VIRTEX_CLK125
//synthesis translate_off
initial begin
$display("%m ERROR FPGA_FAMILY not defined");
$stop(2);
end
//synthesis translate_on
end
//------------------------------------------------------------------------------
else if (FPGA_FAMILY=="ZYNQ7000") begin: ZYNQ_CLK125
    wire CLK0  ;
    wire CLK90 ;
    wire CLK180;
    wire CLK270;
    wire CLKFBOUT;
    wire CLKFBIN = CLKFBOUT;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));

    localparam real CLK_IN_PERIOD_NS = 1000.0/(INPUT_CLOCK_FREQ/1_000_000.0);
    localparam      MUL  =  1_000/(INPUT_CLOCK_FREQ/1_000_000);// 18.0  // 5~64
    localparam      DIV  = ((INPUT_CLOCK_FREQ/1_000_000)*MUL)/(125_000_000/1_000_000); // 1.0~128.0
    localparam real CLK_MUL  = MUL
                  , CLK0_DIV = DIV;
    localparam      CLK1_DIV = ((INPUT_CLOCK_FREQ/1_000_000)*CLK_MUL)/(125_000_000/1_000_000) //1~128
                  , CLK2_DIV = ((INPUT_CLOCK_FREQ/1_000_000)*CLK_MUL)/(125_000_000/1_000_000)
                  , CLK3_DIV = ((INPUT_CLOCK_FREQ/1_000_000)*CLK_MUL)/(125_000_000/1_000_000)
                  , CLK4_DIV = ((INPUT_CLOCK_FREQ/1_000_000)*CLK_MUL)/(125_000_000/1_000_000);

    MMCME2_BASE #(.BANDWIDTH("OPTIMIZED"),
                  .CLKFBOUT_MULT_F(CLK_MUL),
                  .CLKFBOUT_PHASE (0.0),
                  .CLKIN1_PERIOD  (CLK_IN_PERIOD_NS),
                  // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
                  .CLKOUT1_DIVIDE  (CLK1_DIV),
                  .CLKOUT2_DIVIDE  (CLK2_DIV),
                  .CLKOUT3_DIVIDE  (CLK3_DIV),
                  .CLKOUT4_DIVIDE  (CLK4_DIV),
                  .CLKOUT5_DIVIDE  (1),
                  .CLKOUT6_DIVIDE  (1),
                  .CLKOUT0_DIVIDE_F(CLK0_DIV), // Divide amount for CLKOUT0 (1.000-128.000).
                  // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
                  .CLKOUT0_DUTY_CYCLE(0.5),
                  .CLKOUT1_DUTY_CYCLE(0.5),
                  .CLKOUT2_DUTY_CYCLE(0.5),
                  .CLKOUT3_DUTY_CYCLE(0.5),
                  .CLKOUT4_DUTY_CYCLE(0.5),
                  .CLKOUT5_DUTY_CYCLE(0.5),
                  .CLKOUT6_DUTY_CYCLE(0.5),
                  // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
                  .CLKOUT0_PHASE(0.0),
                  .CLKOUT1_PHASE(90.0),
                  .CLKOUT2_PHASE(180.0),
                  .CLKOUT3_PHASE(270.0),
                  .CLKOUT4_PHASE(0.0),
                  .CLKOUT5_PHASE(0.0),
                  .CLKOUT6_PHASE(0.0),
                  .CLKOUT4_CASCADE("FALSE"),
                  .DIVCLK_DIVIDE  (1),
                  .REF_JITTER1    (0.0),
                  .STARTUP_WAIT   ("FALSE")
                  )
    u_mmcme2 (
                  .CLKOUT0 (CLK0),
                  .CLKOUT0B(        ),
                  .CLKOUT1 (CLK90),
                  .CLKOUT1B(        ),
                  .CLKOUT2 (CLK180),
                  .CLKOUT2B(        ),
                  .CLKOUT3 (CLK270),
                  .CLKOUT3B(        ),
                  .CLKOUT4 (        ),
                  .CLKOUT5 (        ),
                  .CLKOUT6 (        ),
                  // Feedback Clocks: 1-bit (each) output: Clock feedback ports
                  .CLKFBOUT (CLKFBOUT),
                  .CLKFBOUTB(         ),
                  // Status Port: 1-bit (each) output: MMCM status ports
                  .LOCKED   (LOCKED),
                  // Clock Input: 1-bit (each) input: Clock input
                  .CLKIN1   (CLK125_IN  ),
                  // Control Ports: 1-bit (each) input: MMCM control ports
                  .PWRDWN   (1'b0),
                  .RST      (1'b0),
                  // Feedback Clocks: 1-bit (each) input: Clock feedback ports
                  .CLKFBIN  (CLKFBIN) // 1-bit input: Feedback clock
    );
end
//------------------------------------------------------------------------------
else if (FPGA_FAMILY=="VirtexUS" ) begin: XCVU_CLK125
//synthesis translate_off
initial begin
$display("%m ERROR FPGA_FAMILY not defined");
$stop(2);
end
//synthesis translate_on
end
//------------------------------------------------------------------------------
else if ((FPGA_FAMILY=="SPARTAN")||(FPGA_FAMILY=="SPARTAN6")) begin: SPARTAN_CLK125
    wire CLK0  ;
    wire CLK90 ;
    wire CLK180;
    wire CLK270;
    wire CLKFB = CLKOUT0;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));

    DCM #(.CLKIN_PERIOD  (1_000_000_000.0/INPUT_CLOCK_FREQ))
    u_dcm (
          .CLKFB     ( CLKFB     )
        , .CLKIN     ( CLK125_IN )
        , .DSSEN     ( 1'b0      )
        , .RST       ( RST       )
        , .PSEN      ( 1'b0      )
        , .PSINCDEC  ( 1'b0      )
        , .PSCLK     ( 1'b0      )
        , .CLK0      ( CLK0      ) // F=Fin
        , .CLK90     ( CLK90     )
        , .CLK180    ( CLK180    )
        , .CLK270    ( CLK270    )
        , .CLK2X     (  ) // F=Fin*2
        , .CLK2X180  (  )
        , .CLKDV     (  ) // F=Fin/CLKDV_DIVIDE
        , .CLKFX     (  ) // F=Fin*CLKFX_MULTIPLY/CLKFX_DIVIDE
        , .CLKFX180  (  )
        , .STATUS    (  )
        , .LOCKED    ( LOCKED   )
        , .PSDONE    (  )
    );
end
//------------------------------------------------------------------------------
else begin : BLK_DEFAULT
    wire CLK0  ;
    wire CLK90 ;
    wire CLK180;
    wire CLK270;
    wire CLKFB = CLKOUT0;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));

    DCM #(.CLKIN_PERIOD  (1_000_000_000.0/INPUT_CLOCK_FREQ))
    u_dcm (
          .CLKFB     ( CLKFB     )
        , .CLKIN     ( CLK125_IN )
        , .DSSEN     ( 1'b0      )
        , .RST       ( RST       )
        , .PSEN      ( 1'b0      )
        , .PSINCDEC  ( 1'b0      )
        , .PSCLK     ( 1'b0      )
        , .CLK0      ( CLK0      ) // F=Fin
        , .CLK90     ( CLK90     )
        , .CLK180    ( CLK180    )
        , .CLK270    ( CLK270    )
        , .CLK2X     (  ) // F=Fin*2
        , .CLK2X180  (  )
        , .CLKDV     (  ) // F=Fin/CLKDV_DIVIDE
        , .CLKFX     (  ) // F=Fin*CLKFX_MULTIPLY/CLKFX_DIVIDE
        , .CLKFX180  (  )
        , .STATUS    (  )
        , .LOCKED    ( LOCKED   )
        , .PSDONE    (  )
    );
end
endgenerate

endmodule

//------------------------------------------------------------------------------
//Revision History:
//
// 2018.07.13: DCM_SP for Spartan-6 added by Ando Ki,
//             to support 200Mhz input for SP605 board.
// 2018.06.06: Parameter check added by Ando Ki.
// 2018.03.12: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif

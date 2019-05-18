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
    , output  wire    CLKOUT2X // 256 for chipscope
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
    wire CLK2X;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));
    BUFG BUFG_CLKOUT2X ( .I( CLK2X  ), .O( CLKOUT2X  ));

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
        , .CLK2X     ( CLK2X     ) // F=Fin*2
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
//synthesis translate_off
initial begin
$display("%m ERROR FPGA_FAMILY not defined");
$stop(2);
end
//synthesis translate_on
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
    wire CLK2X;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));
    BUFG BUFG_CLKOUT2X ( .I( CLK2X  ), .O( CLKOUT2X  ));

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
        , .CLK2X     ( CLK2X     ) // F=Fin*2
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
    wire CLK2X;

    BUFG BUFG_CLKOUT0  ( .I( CLK0   ), .O( CLKOUT0   ));
    BUFG BUFG_CLKOUT90 ( .I( CLK90  ), .O( CLKOUT90  ));
    BUFG BUFG_CLKOUT180( .I( CLK180 ), .O( CLKOUT180 ));
    BUFG BUFG_CLKOUT270( .I( CLK270 ), .O( CLKOUT270 ));
    BUFG BUFG_CLKOUT2X ( .I( CLK2X  ), .O( CLKOUT2X  ));

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
        , .CLK2X     ( CLK2X     ) // F=Fin*2
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

//----------------------------------------------------------
// Copyright (c) 2011 by Future Design Systems , Inc.
// All right reserved.
//----------------------------------------------------------
// mdio_slave.v
//----------------------------------------------------------
// VERSION: 2011.07.09.
//----------------------------------------------------------
// MDIO slave model
//----------------------------------------------------------
// Limitations:
//----------------------------------------------------------
`timescale  1ns/1ns

module gmii_mdio_slave #(parameter PHYADR=5'h1)
(
       input   wire         MDC
     , inout   wire         MDIO
);
    //------------------------------------------------------
    wire MDIO_O, MDIO_T;
    assign MDIO = (MDIO_T) ? 1'bZ : MDIO_O;
    //------------------------------------------------------
    mdio_slave_core #(.PHYADR(PHYADR))
    Umdio_slave_core (
       .MDC    (MDC   )
     , .MDIO_I (MDIO  )
     , .MDIO_O (MDIO_O)
     , .MDIO_T (MDIO_T) // active-low output enable
    );
    //------------------------------------------------------
endmodule
//----------------------------------------------------------
module mdio_slave_core #(parameter PHYADR=5'h1)
(
       input   wire         MDC
     , input   wire         MDIO_I
     , output  reg          MDIO_O
     , output  reg          MDIO_T   // active-low output enable
);
    //------------------------------------------------------
    localparam OPCODE_WR = 2'b01,
               OPCODE_RD = 2'b10,
               START_CODE= 2'b01;
    //------------------------------------------------------
    reg        mdio    = 1'b1;
    reg        mdio_oe = 1'b0;
    reg [ 5:0] cnt     =  'h0;
    reg [ 1:0] opcode  =  'h0;
    reg [ 4:0] phyadr  =  PHYADR;
    reg [ 4:0] regadr  =  'h0;
    reg [15:0] data    =  'h0;
    reg [15:0] mem[0:31];
    //------------------------------------------------------
    integer idx;
    initial begin
        for (idx=0; idx<32; idx=idx+1) begin
            mem[idx] = idx;
        end
    end
    //------------------------------------------------------
    always @ (negedge MDC) begin
         MDIO_O <=  mdio;
         MDIO_T <= ~mdio_oe;
    end
    //------------------------------------------------------
    localparam ST_IDLE     = 'h0,
               ST_START    = 'h1,
               ST_OPCODE   = 'h2,
               ST_PHYADR   = 'h3,
               ST_REGADR   = 'h4,
               ST_TA       = 'h5,
               ST_WR       = 'h6,
               ST_RD       = 'h7,
               ST_PREAMBLE = 'h8;
    reg [3:0] state = ST_PREAMBLE;
    always @ (posedge MDC) begin
        case (state)
        ST_IDLE: begin
           if (MDIO_I==START_CODE[1]) begin
               cnt    <= 'h0;
               opcode <= 'h0;
               state  <= ST_START;
           end
           mdio    <= 1'b1;
           mdio_oe <= 1'b0;
           end // ST_IDLE
        ST_START: begin
           if (MDIO_I==START_CODE[0]) begin
               cnt   <= 'h1;
               state <= ST_OPCODE;
           end else begin
               state <= ST_IDLE;
           end
           end // ST_START
        ST_OPCODE: begin
           opcode <= {opcode[0],MDIO_I};
           if (cnt<2) cnt <= cnt + 1;
           else begin
               cnt   <= 'h1;
               state <= ST_PHYADR;
           end
           end // ST_OPCODE
        ST_PHYADR: begin
           phyadr <= {phyadr[3:0],MDIO_I};
           if (cnt<5) cnt <= cnt + 1;
           else begin
               cnt   <= 'h1;
               if ({phyadr[3:0],MDIO_I}==PHYADR) begin
                   state <= ST_REGADR;
               end else begin
                   state <= ST_PREAMBLE;
`ifdef DEBUG
$display($time,,"%m PHY addr mis-match P=0x%02x, but 0x%02x", {phyadr,MDIO_I}, PHYADR);
`endif
               end
           end
           end // ST_PHYADR
        ST_REGADR: begin
           regadr <= {regadr[3:0],MDIO_I};
           if (cnt<5) cnt <= cnt + 1;
           else begin
               cnt   <= 'h1;
               if (opcode==OPCODE_RD) begin
                  mdio    <= 1'b1;
                  mdio_oe <= 1'b1;
               end
               state <= ST_TA;
           end
           end // ST_REGADR
        ST_TA: begin
           if (cnt<='h1) begin
              cnt     <= cnt + 1;
              if (opcode==OPCODE_RD) begin
                  mdio    <= 1'b0;
                  mdio_oe <= 1'b1;
                  data    <= mem[regadr];
`ifdef DEBUG
$display($time,,"%m read P=0x%02x R=0x%02x D=0x%04x", phyadr, regadr, mem[regadr]);
`endif
              end
           end else if (cnt=='h2) begin
               cnt     <=  'h1;
               if (opcode==OPCODE_RD) begin
                   mdio    <= data[15];
                   data    <= {data[14:0],1'b0};
                   state   <= ST_RD;
               end else begin
                   state <= ST_WR;
               end
           end 
           end // ST_TA
        ST_RD: begin
           if (cnt<16) begin
               mdio  <= data[15];
               data  <= {data[14:0],1'b0};
               cnt   <= cnt + 1;
           end else begin
               cnt     <= 'h1;
               mdio_oe <= 1'b0;
               state   <= ST_PREAMBLE;
           end
           end // ST_RD
        ST_WR: begin
           if (cnt<1) begin
               cnt <= cnt + 1;
           end else if (cnt<=16) begin
               cnt  <= cnt + 1;
               data <= {data[14:0],MDIO_I};
           end else begin
               cnt <= 'h1;
               mem[regadr] <= data;
               state       <= ST_PREAMBLE;
`ifdef DEBUG
$display($time,,"%m write P=0x%02x R=0x%02x D=0x%04x", phyadr, regadr, data);
`endif
           end
           end // ST_WR
        ST_PREAMBLE: begin
           mdio    <= 1'b1;
           mdio_oe <= 1'b0;
           if (cnt<32) begin
               if (MDIO_I==1'b0) cnt <= 'h1;
               else              cnt <= cnt + 1;
           end else begin
               state <= ST_IDLE;
           end
           end // ST_PREAMBLE
        endcase
    end
    //------------------------------------------------------
endmodule
//----------------------------------------------------------
// Revision history:
//
// 2011.07.09.: Started Ando Ki (adki@future-ds.com)
//----------------------------------------------------------

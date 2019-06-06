//------------------------------------------------------------------------------
//  Copyright (c) by Future Design Systems
//  All right reserved.
//  http://www.future-ds.com
//------------------------------------------------------------------------------
//  timer_apb.v
//------------------------------------------------------------------------------
//  VERSION: 2008.12.30.
//------------------------------------------------------------------------------
// [Note]
// mode: 00 tick timer is disabled (default)
// mode: 01 timer is restarted when PERIOD matches COUNTER
// mode: 10 timer stops when PERIOD matches COUNTER
// mode: 11 timer does not stop when PERIOD matches COUNTER
//
// interrupt enable: 0 disabled (default)
// interrupt enable: 1 enabled
//
// interrupt pending: 0 none (default)
// interrupt pending: 1 tick timer interrupt pending (write 0 to clear it)
//
// time period:
//------------------------------------------------------------------------------
//
// ADDR[7:4] selection timer[x]
//
// ADDR[3:0] 4'h0: CONTROL
//           4'h4: PERIOD
//           4'h8: COUNTER
//           4'hC: FREQUENCY
//
//------------------------------------------------------------------------------
`include "timer_tick.v"

module timer_apb
     #(parameter NUM_TIMER=2
               , FREQUENCY=1_000_000 // frequency of clk_timer
               )
(
       input   wire                 PRESETn
     , input   wire                 PCLK
     , input   wire                 PSEL
     , input   wire                 PENABLE
     , input   wire [31:0]          PADDR
     , input   wire                 PWRITE
     , output  reg  [31:0]          PRDATA
     , input   wire [31:0]          PWDATA
     , output  wire [NUM_TIMER-1:0] interrupt // active-high interrupt
     , output  wire [NUM_TIMER-1:0] interruptb // active-low interrupt
     , input   wire                 clk_timer
);
    //------------------------------------
    assign  interruptb= ~interrupt; // active-low interrupt
    //------------------------------------
    wire [NUM_TIMER-1:0] T_RE;
    wire [NUM_TIMER-1:0] T_WE;
    wire [31:0]          T_ADDR;
    wire [31:0]          T_DW;
    wire [31:0]          T_DR[0:NUM_TIMER-1];
    //------------------------------------
    wire [31:0] T_DR0 = T_DR[0];
    wire [31:0] T_DR1 = T_DR[1];
    //------------------------------------
    generate
    genvar idx;
    for (idx=0; idx<NUM_TIMER; idx=idx+1) begin : BLK_IDX
         assign T_RE[idx] = (T_ADDR[7:4]==idx[3:0]) ? ~PWRITE&PSEL&PENABLE&PRESETn
                                                    :  1'b0;
         assign T_WE[idx] = (T_ADDR[7:4]==idx[3:0]) ?  PWRITE&PSEL&PENABLE&PRESETn
                                                    :  1'b0;
    end
    endgenerate
    //------------------------------------
    integer idy;
    always @ ( * ) begin
    PRDATA <= 32'h0;
    for (idy=0; idy<NUM_TIMER; idy=idy+1) begin
         if (T_ADDR[7:4]==idy[3:0]) begin
             PRDATA <= T_DR[idy];
         end
    end // for
    end // always
    //------------------------------------
    assign T_ADDR =  PADDR;
    assign T_DW   =  PWDATA;
    //------------------------------------
    generate
    genvar idz;
    for (idz=0; idz<NUM_TIMER; idz=idz+1) begin : BLK_IDZ
         timer_tick #(.FREQUENCY(FREQUENCY))
         u_timer (
                 .clk_i  ( PCLK           )
               , .rstb_i ( PRESETn        )
               , .re_i   ( T_RE[idz]      )
               , .we_i   ( T_WE[idz]      )
               , .addr_i ( T_ADDR[3:2]    )
               , .data_i ( T_DW           )
               , .data_o ( T_DR[idz]      )
               , .intr_o ( interrupt[idz] )
               , .clk_timer_i ( clk_timer )
         );
    end
    endgenerate
endmodule

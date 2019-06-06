//------------------------------------------------------------------------------
//  Copyright (c) by Future Design Systems
//  All right reserved.
//  http://www.future-ds.com
//------------------------------------------------------------------------------
//  timer_tick.v
//------------------------------------------------------------------------------
//  VERSION: 2008.12.30.
//------------------------------------------------------------------------------
// A timer interrupt will happen everytime
// CONTROL[IE](2) bit is set and PERIOD(31:0)
// matches the COUNTER.
// When an interrupt is pending the CONTROL[IP](3) bit will be set
// and the interrupt will be asserted to 1 
// until CONTROL[IP](3) is cleared by writting a 0 to the CONTROL[IP] bit.
//
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

module timer_tick
     #(parameter FREQUENCY=1_000_000)
(
       input   wire        clk_i
     , input   wire        rstb_i
     , input   wire        re_i
     , input   wire        we_i
     , input   wire [1:0]  addr_i
     , input   wire [31:0] data_i
     , output  reg  [31:0] data_o
     , output  wire        intr_o
     , input   wire        clk_timer_i // clk_i will be faster than this
);
  //--------------------------------------------
  reg  [31:0] COUNTER=32'h1;
  reg  [1:0]  mode=2'b0;
  reg         ie=1'b0;   // interrupt enable
  reg         ip=1'b0;   // interrupt pending
  reg  [31:0] PERIOD=32'h0;   // timer period
  wire [31:0] CONTROL = {28'h0, ip, ie, mode};
  //----------------------------------------------------------------------------
  // synchronized with clk_timer_i
  reg  [31:0] COUNTER_sync=32'h1;
  reg  [31:0] PERIOD_sync=32'h0;   // timer period
  reg  [ 1:0] mode_sync=2'b0;
  reg         ie_sync=1'b0;   // interrupt enable
  reg         ip_sync=1'b0;   // interrupt pending
  //--------------------------------------------
  // It generates pulse when the value changes.
  reg  flag_counter=1'b0;
  reg  flag_period=1'b0;
  reg  flag_control=1'b0;
  //--------------------------------------------
  // clk_timer_i
  reg [2:0] flag_counter_sync=3'h0;
  reg [2:0] flag_period_sync=3'h0;
  reg [2:0] flag_control_sync=3'h0;
  //--------------------------------------------
  assign intr_o = ip;
  //--------------------------------------------
  // CSR address
  localparam CSRA_CONTROL   = 2'b00,
             CSRA_PERIOD    = 2'b01,
             CSRA_COUNTER   = 2'b10,
             CSRA_FREQUENCY = 2'b11; // clk_timer_i
  //--------------------------------------------
  // CSR read
  always @ (*) begin
  if (re_i==1'b1) begin
      case (addr_i)
      CSRA_CONTROL  :   data_o = CONTROL;
      CSRA_PERIOD   :   data_o = PERIOD ;
      CSRA_COUNTER  :   data_o = COUNTER_sync;
      CSRA_FREQUENCY:   data_o = FREQUENCY;
      default: data_o = 32'h0;
      endcase
  end else begin
      data_o = 32'h0;
  end
  end
  //--------------------------------------------
  // CSR write
  always @ (posedge clk_i or negedge rstb_i) begin
  if (rstb_i==1'b0) begin
     mode         <=  2'b0;
     ie           <=  1'b0;
     PERIOD       <= 32'h0;
     COUNTER      <= 32'h1;
     flag_counter <=  1'b0;
     flag_period  <=  1'b0;
     flag_control <=  1'b0;
  end else begin
     if (we_i==1'b1) begin
         case (addr_i)
         CSRA_CONTROL: {flag_control,ie,mode} <= {1'b1,data_i[2:0]};
         CSRA_PERIOD : {flag_period,PERIOD}   <= {1'b1,data_i};
         CSRA_COUNTER: {flag_counter,COUNTER} <= {1'b1,data_i};
         endcase
     end else begin
         flag_counter <= (flag_counter_sync[2]==1'b1) ? 1'b0 : flag_counter;
         flag_period  <= (flag_period_sync [2]==1'b1) ? 1'b0 : flag_period ;
         flag_control <= (flag_control_sync[2]==1'b1) ? 1'b0 : flag_control;
     end
  end // if
  end // always
  //--------------------------------------------
  reg ip_clr=1'b0;
  //--------------------------------------------
  always @ (posedge clk_i or negedge rstb_i) begin
  if (rstb_i==1'b0) begin
     ip     <= 1'b0;
     ip_clr <= 1'b0;
  end else begin
     if ((we_i==1'b1)&&(addr_i==2'b00)) begin
         ip     <=  data_i[3];
         ip_clr <= (data_i[3]==1'b0) ? 1'b1 : 1'b0;
     end else begin
         ip     <= ip_sync;
         ip_clr <= 1'b0;
     end
  end // if
  end // always
  //----------------------------------------------------------------------------
  always @ (posedge clk_timer_i or negedge rstb_i) begin
  if (rstb_i==1'b0) begin
      flag_counter_sync <= 3'h0;
      flag_period_sync  <= 3'h0;
      flag_control_sync <= 3'h0;
  end else begin
      flag_control_sync[2] <= flag_control_sync[1];
      flag_control_sync[1] <= flag_control_sync[0];
      flag_control_sync[0] <= flag_control;
      flag_period_sync [2] <= flag_period_sync [1];
      flag_period_sync [1] <= flag_period_sync [0];
      flag_period_sync [0] <= flag_period ;
      flag_counter_sync[2] <= flag_counter_sync[1];
      flag_counter_sync[1] <= flag_counter_sync[0];
      flag_counter_sync[0] <= flag_counter;
  end // if
  end // always
  //----------------------------------------------------------------------------
  localparam TT_DISABLE=2'b00
           , TT_RESTART=2'b01
           , TT_ONE    =2'b10
           , TT_CONT   =2'b11;
  //----------------------------------------------------------------------------
  always @ (posedge clk_timer_i or negedge rstb_i) begin
  if (rstb_i==1'b0) begin
     COUNTER_sync <= 32'h1;
  end else begin
     if ((flag_counter_sync[2]==1'b0)&&(flag_counter_sync[1]==1'b1)) begin
         COUNTER_sync <= COUNTER;
     end else if ((flag_period_sync[2]==1'b0)&&(flag_period_sync[1]==1'b1)) begin
         PERIOD_sync <= PERIOD;
     end else if ((flag_control_sync[2]==1'b0)&&(flag_control_sync[1]==1'b1)) begin
         mode_sync <= mode;
         ie_sync   <= ie;
     end else begin
         case (mode_sync)
         TT_DISABLE:
            COUNTER_sync <= 32'h1;
         TT_RESTART:
            COUNTER_sync <= (COUNTER_sync==PERIOD_sync) ? 32'h1 : COUNTER_sync + 32'h1;
         TT_ONE:
            COUNTER_sync <= (COUNTER_sync==PERIOD_sync) ? COUNTER_sync : COUNTER_sync + 32'h1;
         TT_CONT:
            COUNTER_sync <= COUNTER_sync + 32'h1;
         default:
            COUNTER_sync <= COUNTER_sync;
         endcase
     end
  end // if
  end // always
  //----------------------------------------------------------------------------
  wire ip_rst= (rstb_i==1'b0)||(ip_clr==1'b1);
  //----------------------------------------------------------------------------
  always @ (posedge clk_timer_i or posedge ip_rst) begin
  if (ip_rst==1'b1) begin
      ip_sync <= 1'b0;
  end else if ((flag_control_sync[2]==1'b0)&&(flag_control_sync[1]==1'b1)) begin
      ip_sync <= (ip==1'b0) ? 1'b0 : ip_sync;
  end else begin
      ip_sync <= ie_sync & (ip_sync|(PERIOD_sync==COUNTER_sync));
  end // if
  end // always
  //----------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------

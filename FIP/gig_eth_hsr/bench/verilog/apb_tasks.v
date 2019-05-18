`ifndef APB_TASKS_V
`define APB_TASKS_V
//------------------------------------------------------------------------------
// Copyright (c) 2013-2015-2017 by Ando Ki.
// All right reserved.
//
// andoki@gmail.com
//------------------------------------------------------------------------------
// apb_tasks.h
//------------------------------------------------------------------------------
// VERSION = 2017.04.13.
//------------------------------------------------------------------------------
// [MACROS]
// - 'AMBA_APB3' should be defined for AMBA_APB3 to use 'PREADY' and 'PSLVERR'.
// - 'AMBA_APB4' should be defined for AMBA_APB4 APB to use 'PSTRB' and 'PPROT'.
// - 'RIGOR' makes rigorous checking and displaying error message.
// - 'ENDIAN_BIG' make use big-endian data ordering for multi-byte data.
//------------------------------------------------------------------------------
// [NOTE]
// - Data passed through argument is in justified fashion.
//   So, the data should be re-positioned according to address and size.
//------------------------------------------------------------------------------
// 'apb_write' generates AMBA APB wirte transaction.
//
// [input]
//  addr: 32-bit address to be driven on PADDR[31:0].
//  data: 32-bit width data to be driven on PWDATA[31:0].
//        Partial bytes are in justified fashion when AMBA_APB4 is defined.
//        E.g., 1-byte is on data[7:0] regardless of address.
//  size: Num of valid bytes in 'data' starting from addr%4.
//        It can be 1, 2, and 4.
//  prot: Protection type
// [output]
// [note]
//  - 'size' is used when 'AMBA_APB4' is defined.
//  - 'prot' is used when 'AMBA_APB4' is defined.
//  - Actual valid bytes are determened by a combination of addr and size.
//------------------------------------------------------------------------------
task apb_write;
input  [31:0] addr; // byte-wise address
input  [31:0] data; // justified fashion
input  [ 2:0] size; // if not sure, use 4
output        status; // return 0 for OK
begin
      `ifdef RIGOR
      `ifndef AMBA_APB4
      if (size!=4) $display("%04d %m size should be 4.", $time);
      `endif
      `endif
       apb_write_core( addr
                     , data
                     , size
                     , 3'b010// if not sure, use 2 (data,nonsecure,normal)
                     , status);
end
endtask

//------------------------------------------------------------------------------
task apb_write_core;
input  [31:0] addr; // byte-wise address
input  [31:0] data; // justified fashion
input  [ 2:0] size; // if not sure, use 4
input  [ 2:0] prot; // if not sure, use 2 (data,nonsecure,normal)
output        status; // return 0 for OK
begin
      `ifdef RIGOR
      `ifdef AMBA_APB4
      if ((size!==1)&&(size!==2)&&(size!=4))
           $display("%04d %m size should be 1, 2, or 4.", $time);
      `else
      if (size!=4) $display("%04d %m size should be 4.", $time);
      `endif
      `endif
      @ (posedge PCLK);
      PSEL    <= 1'b1;
      PADDR   <= addr;
      PWRITE  <= 1'b1;
      `ifdef ENDIAN_BIG
      PWDATA  <= data<<(24-(8*addr[1:0])); // for big-endian
      `else
      PWDATA  <= data<<(8*addr[1:0]); // for little-endian
      `endif
      `ifdef AMBA_APB4
      PPROT   <= prot;
      PSTRB   <= get_pstrb(addr,size);
      `endif
      @ (posedge PCLK);
      PENABLE <= 1'b1;
      @ (posedge PCLK);
      `ifdef AMBA_APB3
      while (PREADY!==1'b1) @ (posedge PCLK);
      status = PSLVERR;
      `else
      status = 1'b0;
      `endif
      PSEL    = 1'b0;
      PENABLE = 1'b0;
      `ifdef AMBA_APB3
      `ifdef RIGOR
      if (PSLVERR!==1'b0) $display("%04d %m PSLVERR", $time);
      `endif
      `endif
end
endtask

//------------------------------------------------------------------------------
// 'apb_read' generates AMBA APB read transaction.
//
// [input]
//  addr: 32-bit address to be driven on PADDR[31:0].
//  prot: Protection type
// [output]
//  data: 32-bit data has been read.
//        Always 4-byte access.
// [note]
//  - 'prot' is used when 'AMBA_APB4' is defined.
//------------------------------------------------------------------------------
task apb_read;
input  [31:0] addr; // byte-wise address, but lower two bit is not used
output [31:0] data; // always 4-byte
output        status; // return 0 for OK
begin
       apb_read_core( addr
                    , data
                    , 3'b010 // if not sure, use 2 (data,nonsecure,normal)
                    , status);
end
endtask

//------------------------------------------------------------------------------
task apb_read_core;
input  [31:0] addr; // byte-wise address
output [31:0] data; // always 4-byte
input  [ 2:0] prot; // if not sure, use 2 (data,nonsecure,normal)
output        status; // return 0 for OK
begin
      @ (posedge PCLK);
      PSEL    <= 1'b1;
      PADDR   <= addr;
      PWRITE  <= 1'b0;
      `ifdef AMBA_APB4
      PPROT   <= prot;
      `endif
      @ (posedge PCLK);
      PENABLE <= 1'b1;
      @ (posedge PCLK);
      `ifdef AMBA_APB3
      while (PREADY!==1'b1) @ (posedge PCLK);
      status  = PSLVERR;
      `else
      status  = 1'b0;
      `endif
      data    = PRDATA; // it should be blocking and always 4-byte
      PSEL    = 1'b0;
      PENABLE = 1'b0;
      `ifdef AMBA_APB3
      `ifdef RIGOR
      if (PSLVERR!==1'b0) $display("%m PSLVERR", $time);
      `endif
      `endif
end
endtask

//------------------------------------------------------------------------------
// 'get_pstrb' returns 'PSTRB[3:0]' and it is determined
// by combining 'size' and 'address'.
`ifdef AMBA_APB4
function [3:0] get_pstrb;
input [31:0] addr; // lower 2-bit is effective
input [ 2:0] size;
begin
   get_pstrb = 4'b0000;
   `ifdef ENDIAN_BIG
   case (addr[1:0])
   2'b00: case (size)
          3'd1: get_pstrb = 4'b1000;
          3'd2: get_pstrb = 4'b1100;
          3'd4: get_pstrb = 4'b1111;
          endcase
   2'b01: case (size)
          3'd1: get_pstrb = 4'b0100;
          endcase
   2'b10: case (size)
          3'd1: get_pstrb = 4'b0010;
          3'd2: get_pstrb = 4'b0011;
          endcase
   2'b11: case (size)
          3'd1: get_pstrb = 4'b0001;
          endcase
   endcase
   `else
   case (addr[1:0])
   2'b00: case (size)
          3'd1: get_pstrb = 4'b0001;
          3'd2: get_pstrb = 4'b0011;
          3'd4: get_pstrb = 4'b1111;
          endcase
   2'b01: case (size)
          3'd1: get_pstrb = 4'b0010;
          endcase
   2'b10: case (size)
          3'd1: get_pstrb = 4'b0100;
          3'd2: get_pstrb = 4'b1100;
          endcase
   2'b11: case (size)
          3'd1: get_pstrb = 4'b1000;
          endcase
   endcase
   `endif
   `ifdef RIGOR
   if (get_pstrb==4'b0000) $display("%04d %m mis-aligned access", $time);
   `endif
end
endfunction
`endif
//------------------------------------------------------------------------------
// Revision history
//
// 2017.04.13: Partail access case updated by Ando Ki.
//             LOW_POWER macro removed.
// 2015.10.16: Rewitten by Ando Ki (andoki@gmail.com)
// 2013.01.31: Started by Ando Ki (andoki@gmail.com)
//------------------------------------------------------------------------------
`endif

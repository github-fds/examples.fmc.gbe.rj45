//`ifndef AXI_TASKS_V
//`define AXI_TASKS_V
//------------------------------------------------------------------------------
//  Copyright (c) 2013-2015-2017 by Ando Ki.
//  All right reserved.
//
//  andoki@gmail.com
//------------------------------------------------------------------------------
// axi_tasks.v
//------------------------------------------------------------------------------
// VERSION: 2017.09.17.
//------------------------------------------------------------------------------
// [NOTE]
// - Data passed through argument is in justified fashion.
//   So, the data should be re-positioned according to address and size.
//------------------------------------------------------------------------------
reg [15:0] axi_read_id =16'h0; // transaction id for read
reg [15:0] axi_write_id=16'h0; // transaction id for write
reg [ 1:0] status_burst_read[0:1023]; // its index is not address, but beat
reg [AXI_WIDTH_DA-1:0] data_burst_read [0:2047]; // its index is not address, but beat
reg [AXI_WIDTH_DA-1:0] data_burst_write[0:2047]; // its index is not address, but beat

//------------------------------------------------------------------------------
task axi_read_one;
     input  [31:0] addr;
     output [31:0] data;
     reg [ 1:0] status; // 0: all ok
begin
     axi_read(addr, 4, 1, status);
     data = data_burst_read[0];
end
endtask

//------------------------------------------------------------------------------
task axi_write_one;
     input  [31:0] addr;
     input  [31:0] data;
     reg [ 1:0] status; // 0: all ok
begin
     data_burst_write[0] = data;
     axi_write(addr, 4, 1, status);
end
endtask

//------------------------------------------------------------------------------
task axi_read;
     input  [AXI_WIDTH_AD-1:0] addr;
     input  [15:0]             size; // 1 ~ 128 byte in a beat
     input  [15:0]             leng; // 1 ~ 16/256  beats in a burst
     output [ 1:0]             status; // 0: all ok
begin
     `ifndef AMBA_AXI4
     if (leng>16) begin
          $display("%04d %m ERROR AXI3 burst length exceed %d", $time, leng);
     end
     `endif
     `ifdef RIGOR
     if (addr%size) begin
          $display("%04d %m ERROR mis-aligned access", $time);
     end
     `endif
     axi_read_id = (axi_read_id + 1);
     axi_read_core( axi_read_id[AXI_WIDTH_ID-1:0], addr, size, leng, 2'b01, 3'b010, 2'b00, status);
end
endtask

//------------------------------------------------------------------------------
task axi_read_core;
     input  [AXI_WIDTH_ID-1:0] id  ; // transaction identification
     input  [AXI_WIDTH_AD-1:0] addr;
     input  [15:0]             size; // 1 ~ 128 byte in a beat
     input  [15:0]             leng; // 1 ~ 16/256  beats in a burst
     input  [ 1:0]             btype; // burst type (code)
     input  [ 2:0]             prot; // protection (code)
     input  [ 1:0]             lock; // lock (code)
     output [ 1:0]             status; // 0: all ok
begin
     `ifndef AMBA_AXI4
     if (leng>16) begin
          $display("%04d %m ERROR AXI3 burst length exceed %d", $time, leng);
     end
     `endif
     fork
     axi_read_address_channel(id,addr,size,leng,btype,prot,lock);
     axi_read_data_channel(id,addr,size,leng,btype,status);
     join
end
endtask

//------------------------------------------------------------------------------
task axi_read_address_channel;
     input [AXI_WIDTH_ID-1:0] id  ;
     input [AXI_WIDTH_AD-1:0] addr;
     input [15:0]             size; // 1 ~ 128 byte in a beat
     input [15:0]             leng; // 1 ~ 16/256  beats in a burst
     input [ 1:0]             btype; // burst type (code)
     input [ 2:0]             prot; // protection (code)
     input [ 1:0]             lock; // lock (code)
begin
     @ (posedge ACLK);
     ARID    = id;
     ARADDR  = addr;
     ARLEN   = leng-1;
     ARLOCK  = lock;
     ARSIZE  = get_size_code(size);
     ARBURST = btype[1:0];
     `ifdef AMBA_AXI_PROT
     ARPROT  = prot[2:0]; // data, secure, normal
     `endif
     ARVALID = 1'b1;
     @ (posedge ACLK);
     while (ARREADY==1'b0) @ (posedge ACLK);
     ARVALID = 1'b0;
     `ifdef RIGOR
     ARID    = 'hX;
     ARADDR  = 'hX;
     ARLEN   = 'hX;
     ARLOCK  = 'hX;
     ARSIZE  = 'hX;
     ARBURST = 'hX;
     `ifdef AMBA_AXI_PROT
     ARPROT  = 'hX;
     `endif
     `endif
end
endtask

//------------------------------------------------------------------------------
// It stores data in 'data_burst_read[x]' in justified fashion,
// where 'x' indicates beat from 0 to (len-1).
task axi_read_data_channel;
     input  [AXI_WIDTH_ID-1:0] id  ;
     input  [AXI_WIDTH_AD-1:0] addr;
     input  [15:0]             size; // 1 ~ 128 byte in a beat
     input  [15:0]             leng; // 1 ~ 16/256  beats in a burst
     input  [ 1:0]             btype; // burst type (code)
     output [ 1:0]             status; // 0: all ok
     reg    [AXI_WIDTH_AD-1:0] naddr;
     reg    [AXI_WIDTH_DA-1:0] mask ;
     integer idx;
begin
     naddr  = addr;
     status = 0;
     mask   = (1<<(size*8))-1; // justified-mask
     @ (posedge ACLK);
     RREADY = 1'b1;
     for (idx=0; idx<leng; idx=idx+1) begin
          @ (posedge ACLK);
          while (RVALID==1'b0) @ (posedge ACLK);
          data_burst_read[idx] = (RDATA>>(8*(naddr%AXI_WIDTH_DS)))&mask; // make justified
          status_burst_read[idx] = RRESP;
          status = status | RRESP;
          if (id!=RID) begin
             $display("%04d %m Error id/RID mis-match for read-data-channel", $time, id, RID);
          end
          if (idx==leng-1) begin
             if (RLAST==1'b0) begin
                 $display("%04d %m Error RLAST expected for read-data-channel", $time);
             end
          end else begin
              naddr = get_next_addr( naddr // current address
                                   , size  // num of bytes in a beat
                                   , leng  // num of beat
                                   , btype);// type of burst
          end
     end // for
     RREADY = 1'b0;
end
endtask

//------------------------------------------------------------------------------
task axi_write;
     input  [AXI_WIDTH_AD-1:0] addr;
     input  [15:0]             size; // 1 ~ 128 byte in a beat
     input  [15:0]             leng; // 1 ~ 16/256  beats in a burst
     output [ 1:0]             status; // 0:OK, 1:EXOK, 2:SLVERR, 3:DECERR
begin
     `ifndef AMBA_AXI4
     if (leng>16) begin
          $display("%04d %m ERROR AXI3 burst length exceed %d", $time, leng);
     end
     `endif
     `ifdef RIGOR
     if (addr%size) begin
          $display("%04d %m ERROR mis-aligned access", $time);
     end
     `endif
     axi_write_id = (axi_write_id + 1);
     axi_write_core(axi_write_id[AXI_WIDTH_ID-1:0], addr, size, leng, 2'b01, 3'b010, 2'b00, status);
end
endtask

//------------------------------------------------------------------------------
task axi_write_core;
     input  [AXI_WIDTH_ID-1:0] id  ;
     input  [AXI_WIDTH_AD-1:0] addr;
     input  [15:0]             size; // 1 ~ 128 byte in a beat
     input  [15:0]             leng; // 1 ~ 16/256  beats in a burst
     input  [ 1:0]             btype; // burst type (code)
     input  [ 2:0]             prot; // protection (code)
     input  [ 1:0]             lock; // lock (code)
     output [ 1:0]             status; // 0:OK, 1:EXOK, 2:SLVERR, 3:DECERR
begin
     `ifndef AMBA_AXI4
     if (leng>16) begin
          $display("%04d %m ERROR AXI3 burst length exceed %d", $time, leng);
     end
     `endif
     fork
     axi_write_address_channel(id,addr,size,leng,btype,prot,lock);
     axi_write_data_channel(id,addr,size,leng,btype);
     axi_write_resp_channel(id,status);
     join
end
endtask

//------------------------------------------------------------------------------
task axi_write_address_channel;
     input [AXI_WIDTH_ID-1:0] id  ;
     input [AXI_WIDTH_AD-1:0] addr;
     input [15:0]             size; // 1 ~ 128 byte in a beat
     input [15:0]             leng; // 1 ~ 16/256  beats in a burst
     input [ 1:0]             btype; // burst type (code)
     input [ 2:0]             prot; // protection (code)
     input [ 1:0]             lock; // lock (code)
begin
     @ (posedge ACLK);
     AWID    = id;
     AWADDR  = addr;
     AWLEN   = leng-1;
     AWLOCK  = lock;
     AWSIZE  = get_size_code(size);
     AWBURST = btype[1:0];
     `ifdef AMBA_AXI_PROT
     AWPROT  = prot[2:0]; // data, secure, normal
     `endif
     AWVALID = 1'b1;
     @ (posedge ACLK);
     while (AWREADY==1'b0) @ (posedge ACLK);
     AWVALID = 1'b0;
     `ifdef RIGOR
     AWID    = 'hX;
     AWADDR  = 'hX;
     AWLEN   = 'hX;
     AWLOCK  = 'hX;
     AWSIZE  = 'hX;
     AWBURST = 'hX;
     `ifdef AMBA_AXI_PROT
     AWPROT  = 'hX;
     `endif
     `endif
end
endtask

//------------------------------------------------------------------------------
// It uses data in 'data_burst_write[x]' in justified fashion,
// where 'x' indicates beat from 0 to (len-1).
task axi_write_data_channel;
     input [AXI_WIDTH_ID-1:0] id  ;
     input [AXI_WIDTH_AD-1:0] addr;
     input [15:0]             size; // 1 ~ 128 byte in a beat
     input [15:0]             leng; // 1 ~ 16/256  beats in a burst
     input [ 1:0]             btype; // burst type (code)
     reg   [AXI_WIDTH_AD-1:0] naddr;
     integer idx;
begin
     naddr  = addr;
     @ (posedge ACLK);
     WID    = id;
     WVALID = 1'b1;
     for (idx=0; idx<leng; idx=idx+1) begin
          WDATA = data_burst_write[idx]<<(8*(naddr%AXI_WIDTH_DS));
          WSTRB = get_strb(naddr, size);
          WLAST = (idx==(leng-1));
          naddr = get_next_addr( naddr // current address
                               , size  // num of bytes in a beat
                               , leng  // num of beat
                               , btype);// type of burst
          @ (posedge ACLK);
          while (WREADY==1'b0) @ (posedge ACLK);
     end // for
     WLAST  = 1'b0;
     WVALID = 1'b0;
end
endtask

reg error_axi_w=1'b0;
//------------------------------------------------------------------------------
task axi_write_resp_channel;
     input  [AXI_WIDTH_ID-1:0] id;
     output [ 1:0]             status; // 0:OK, 1:EXOK, 2:SLVERR, 3:DECERR
begin
     @ (posedge ACLK);
     BREADY = 1'b1;
     @ (posedge ACLK);
     while (BVALID==1'b0) @ (posedge ACLK);
     status = BRESP;
     if (id!=BID) begin
        $display("%04d %m Error id mis-match for write-resp-channel 0x%x/0x%x", $time, id, BID);
     end else begin
         case (BRESP)
         2'b00: begin
                `ifdef DEBUG
                $display("%04d %m OK response for write-resp-channel: OKAY", $time);
                `endif
                end
         2'b01: $display("%04d %m OK response for write-resp-channel: EXOKAY", $time);
         2'b10: $display("%04d %m Error response for write-resp-channel: SLVERR", $time);
         2'b11: begin $display("%04d %m Error response for write-resp-channel: DECERR", $time);
error_axi_w=1'b1;
end
         endcase
     end
     BREADY = 1'b0;
end
endtask

//------------------------------------------------------------------------------
// input: num of bytes
// output: AxSIZE[2:0] code
function [ 2:0] get_size_code;
   input [15:0] size;
begin
   case (size)
     1: get_size_code = 0;
     2: get_size_code = 1;
     4: get_size_code = 2;
     8: get_size_code = 3;
    16: get_size_code = 4;
    32: get_size_code = 5;
    64: get_size_code = 6;
   128: get_size_code = 7;
   default: get_size_code = 0;
   endcase
end
endfunction

//------------------------------------------------------------------------------
function [AXI_WIDTH_DS-1:0] get_strb;
    input [AXI_WIDTH_AD-1:0] addr;
    input [15:0] size; // num of bytes in a beat
    integer offset;
    reg   [127:0] bit_size;
begin
    offset   = addr%AXI_WIDTH_DS;
    case (size)
      1: bit_size = {  1{1'b1}};
      2: bit_size = {  2{1'b1}};
      4: bit_size = {  4{1'b1}};
      8: bit_size = {  8{1'b1}};
     16: bit_size = { 16{1'b1}};
     32: bit_size = { 32{1'b1}};
     64: bit_size = { 64{1'b1}};
    128: bit_size = {128{1'b1}};
    default: bit_size = 0;
    endcase
    get_strb = bit_size<<offset;
end
endfunction

//------------------------------------------------------------------------------
function [AXI_WIDTH_AD-1:0] get_next_addr;
    input [AXI_WIDTH_AD-1:0] addr; // current address
    input [15:0] size; // num of bytes in a beat
    input [ 7:0] leng; // num of beats
    input [ 1:0] btype; // type of burst
    integer offset, bnum, bwid;
begin
    case (btype[1:0])
    2'b00: get_next_addr = addr; // fixed
    2'b01: begin // increment
           offset = addr%AXI_WIDTH_DS;
           if ((offset+size)<=AXI_WIDTH_DS) begin
               get_next_addr = addr + size;
           end else begin // (offset+size)>nb
               get_next_addr = addr + AXI_WIDTH_DS - size;
           end
           end
    2'b10: begin // wrap
           bnum = size*leng;
           bwid = logb2(bnum);
           offset = (addr+size)%bnum;
           addr   = addr&~(bnum-1);
           get_next_addr = addr+offset;
           if ((addr%size)!=0) begin
              $display("%04d %m wrap-burst not aligned", $time);
              get_next_addr = addr;
           end
           if ((leng!=2)&&(leng!=4)&&(leng!=8)&&(leng!=16)) begin
               $display("%04d %m ERROR wrapping should be 2, 4, 8, or 16 leng, but %d", $time, leng);
           end
           end
    default: $display("%04d %m Error un-defined burst-type: %2b", $time, btype);
    endcase
end
endfunction

//------------------------------------------------------------------------------
function integer logb2;
input [31:0] value;
begin
   value = value - 1;
   for (logb2 = 0; value > 0; logb2 = logb2 + 1)
      value = value >> 1;
   end
endfunction

//------------------------------------------------------------------------------
// Revision History
//
// 2019.03.22: 'axi_read/write_one()' added by Ando Ki.
// 2017.09.1y: 'id' width has been specified by Ando Ki.
// 2017.09.13: 'mask' added for wide data width by Ando Ki.
// 2015.10.29: Rewritten by Ando Ki (andoki@gmail.com)
// 2013.02.03: Started by Ando Ki (andoki@gmail.com)
//------------------------------------------------------------------------------
//`endif

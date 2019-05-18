//`ifndef MEM_TEST_TASKS_V
//`define MEM_TEST_TASKS_V
//--------------------------------------------------------
// Copyright (c) 2013-2015-2017 by Ando Ki.
// All right reserved.
//
// andoki@gmail.com
//--------------------------------------------------------
// mem_test_tasks.v
//--------------------------------------------------------
// VERSION = 2017.04.16.
//--------------------------------------------------------
   //-----------------------------------------------------
   // Memory test using a single accesse through AMBA AXI
   task memory_test;
        input [AXI_WIDTH_AD-1:0] start;  // start address
        input [AXI_WIDTH_AD-1:0] finish; // end address
        input [15:0] size;   // data size: 1, 2, 4
	//------------------
        reg [ 1:0] status; // 0: OK
        integer i, j, k, error, seed;
        reg [AXI_WIDTH_DA-1:0] mask, dataW, dataR, expect;
   begin
        error = 0;
        seed = 7;
        mask = get_mask(size);
        for (i=start; i<(finish-size+1); i=i+size) begin
            dataW = {AXI_WIDTH_DA{1'bX}};
            for (k=0; k<size; k=k+1) begin
                 dataW[k*8+:8] = $random(seed)&8'hFF;
            end // for k
            data_burst_write[0] = dataW;
            axi_write(i, size, 1, status); // data is justified
            axi_read (i, size, 1, status); // data is justified
            dataR = data_burst_read[0]&mask;
            if ((dataW&mask)!==dataR) begin
               $display("[%04d] %m A:%x D:%x, but %x expected", $time, i, dataR, dataW&mask);
               error = error+1;
            end
        end
        if (error==0)
               $display("[%04d] %m   RAW %x-%x %d-byte test OK", $time, start, finish, size);
        //-------------------------------------------------------------
        error = 0;
        seed = 1;
        mask = get_mask(size);
        for (i=start; i<(finish-size+1); i=i+size) begin
            dataW = {AXI_WIDTH_DA{1'bX}};
            for (k=0; k<size; k=k+1) begin
                 dataW[k*8+:8] = $random(seed)&8'hFF;
            end // for k
            data_burst_write[0] = dataW;
            axi_write(i, size, 1, status); // data is justified
        end
        seed = 1;
        for (i=start; i<(finish-size+1); i=i+size) begin
            axi_read(i, size, 1, status); // dataR is justified
            dataR = data_burst_read[0]&mask;
            expect = {AXI_WIDTH_DA{1'bX}};
            for (k=0; k<size; k=k+1) begin
                 expect[k*8+:8] = $random(seed)&8'hFF;
            end // for k
            if (dataR!==(expect&mask)) begin
               $display("[%04d] %m A:%x D:%x, but %x expected", $time, i, dataR, expect&mask);
               error = error+1;
            end
        end
        if (error==0)
               $display("[%04d] %m RAAWA %x-%x %d-byte test OK", $time, start, finish, size);
   end
   endtask

   //-----------------------------------------------------
   // Memory test using a burst accesse through AMBA AXI
   // only for 4-byte granulity
   task memory_test_burst;
        input [AXI_WIDTH_AD-1:0] start; // start address
        input [AXI_WIDTH_AD-1:0] finish;// end address
        input [15:0] size;  // byte number per beat (1, 2, 4)
        input [15:0] leng;  // burst length
        reg   [ 1:0] status; // 0: OK
        reg   [AXI_WIDTH_DA-1:0] mask;
        integer i, j, k, error, seed;
        reg [31:0] expect;
   begin
        // at this moment size 4 is only supported
        error = 0;
        mask = (1<<(size*8))-1;
        if (finish>(start+leng*4)) begin
           seed  = 111;
           for (i=start; i<(finish-(leng*4)+1); i=i+leng*4) begin
               for (j=0; j<leng; j=j+1) begin
                   data_burst_write[j] = {AXI_WIDTH_DA{1'bX}};
                   for (k=0; k<size; k=k+1) begin
                        data_burst_write[j][k*8+:8] = $random(seed)&8'hFF;
                   end // for k
               end // for j
               @ (posedge ACLK);
               axi_write(i, 4, leng, status);
               axi_read(i, 4, leng, status);
               for (j=0; j<leng; j=j+1) begin
                   if ((data_burst_read[j]&mask)!==(data_burst_write[j]&mask)) begin
                      error = error+1;
                      $display("%m A=%h D=%h, but %h expected",
                              i+j*leng, (data_burst_read[j]&mask), (data_burst_write[j]&mask));
                   end
               end // for j
               @ (posedge ACLK);
           end // for i
           if (error==0)
               $display("%m %d-length burst RAW OK: from %h to %h",
                         leng, start, finish);
           else $display("%m %d-length burst RAW Error %d from %h to %h",
                         leng, error, start, finish);
        end else begin
            $display("%m %d-length burst read-after-write from %h to %h ???",
                         leng, start, finish);
        end
        //------------------------------------------------
        error = 0;
        if (finish>(start+leng*4)) begin
           seed  = 111;
           for (i=start; i<(finish-(leng*4)+1); i=i+leng*4) begin
               for (j=0; j<leng; j=j+1) begin
                   data_burst_write[j] = {AXI_WIDTH_DA{1'bX}};
                   for (k=0; k<(AXI_WIDTH_DA/8); k=k+1) begin
                        data_burst_write[j][k*8+:8] = $random(seed)&8'hFF;
                   end // for k
               end // for j
               @ (posedge ACLK);
               axi_write(i, 4, leng, status);
           end // for i
           seed  = 111;
           for (i=start; i<(finish-(leng*4)+1); i=i+leng*4) begin
               @ (posedge ACLK);
               axi_read(i, 4, leng, status);
               for (j=0; j<leng; j=j+1) begin
                   expect = {AXI_WIDTH_DA{1'bX}};
                   for (k=0; k<(AXI_WIDTH_DA/8); k=k+1) begin
                        expect[k*8+:8] = $random(seed)&8'hFF;
                   end // for k
                   if ((data_burst_read[j]&mask)!==(expect&mask)) begin
                      error = error+1;
                      $display("%m A=%h D=%h, but %h expected",
                              i+j*leng, (data_burst_read[j]&mask), (expect&mask));
                   end
               end // for j
               @ (posedge ACLK);
           end
           if (error==0)
               $display("%m %d-length burst RAAWA OK: from %h to %h",
                         leng, start, finish);
           else $display("%m %d-length burst RAAWA Error %d from %h to %h",
                         leng, error, start, finish);
        end else begin
            $display("%m %d-length burst read-all-after-write-all from %h to %h ???",
                         leng, start, finish);
        end
   end
   endtask

   //-----------------------------------------------------
   // Memory test using a wrapping accesse through AMBA AXI
   // only for 4-byte granulity
   task memory_test_wrap;
        input [AXI_WIDTH_AD-1:0] start; // start address
        input [AXI_WIDTH_AD-1:0] finish;// end address
        input [15:0] size;  // num of bytes per beat (1, 2, 4)
        input [15:0] leng;  // burst length
        input [ 7:0] offset;
        reg   [ 1:0] status; // 0: OK
        reg   [AXI_WIDTH_DA-1:0] mask;
        integer i, j, k, error, seed;
        reg [15:0] id_wr, id_rd;
        reg [31:0] expect;
   begin
        error = 0;
        id_wr = 0;
        id_rd = 6;
        mask  = (1<<(size*8))-1;
        if (finish>(start+leng*4)) begin
           seed  = 333;
           for (i=(start+offset); i<(finish-(leng*4)+1); i=i+leng*4) begin
               for (j=0; j<leng; j=j+1) begin
                   data_burst_write[j] = {AXI_WIDTH_DS{1'bX}};
                   for (k=0; k<(AXI_WIDTH_DA/8); k=k+1) begin
                        data_burst_write[j][k*8+:8] = $random(seed)&8'hFF;
                   end // for k
               end // for j
               @ (posedge ACLK);
               id_wr = id_wr + 1;
               axi_write_core(id_wr, i, 4, leng, 2'b10, 3'b010, 2'b00, status);
               id_rd = id_rd + 1;
               axi_read_core(id_rd, i, 4, leng, 2'b10, 3'b010, 2'b00, status);
               for (j=0; j<leng; j=j+1) begin
                   if ((data_burst_read[j]&mask)!==(data_burst_write[j]&mask)) begin
                      error = error+1;
                      $display("%m A=%h D=%h, but %h expected",
                              i+j*leng, data_burst_read[j]&mask, data_burst_write[j]&mask);
                   end
               end // for j
               @ (posedge ACLK);
           end
           if (error==0)
               $display("%m %d-length wrapping burst RAW OK: from %h to %h",
                         leng, start, finish);
           else $display("%m %d-length wrapping burst RAW Error %d from %h to %h",
                         leng, error, start, finish);
        end else begin
            $display("%m %d-length wrapping burst read-after-write from %h to %h ???",
                         leng, start, finish);
        end
        //------------------------------------------------
        error = 0;
        id_wr = 0;
        id_rd = 3;
        if (finish>(start+leng*4)) begin
           seed  = 333;
           for (i=(start+offset); i<(finish-(leng*4)+1); i=i+leng*4) begin
               for (j=0; j<leng; j=j+1) begin
                   data_burst_write[j] = {AXI_WIDTH_DS{1'bX}};
                   for (k=0; k<(AXI_WIDTH_DA/8); k=k+1) begin
                        data_burst_write[j][k*8+:8] = $random(seed)&8'hFF;
                   end // for k
               end // for j
               @ (posedge ACLK);
               id_wr = id_wr + 1;
               axi_write_core(id_wr, i, 4, leng, 2'b10, 3'b010, 2'b00, status);
           end // for i
           seed  = 333;
           for (i=(start+offset); i<(finish-(leng*4)+1); i=i+leng*4) begin
               @ (posedge ACLK);
               id_rd = id_rd + 1;
               axi_read_core(id_rd, i, 4, leng, 2'b10, 3'b010, 2'b00, status);
               for (j=0; j<leng; j=j+1) begin
                   expect = {AXI_WIDTH_DS{1'bX}};
                   for (k=0; k<(AXI_WIDTH_DA/8); k=k+1) begin
                        expect[k*8+:8] = $random(seed)&8'hFF;
                   end // for k
                   if ((data_burst_read[j]&mask)!==(expect&mask)) begin
                      error = error+1;
                      $display("%m A=%h D=%h, but %h expected",
                              i+j*leng, data_burst_read[j]&mask, expect&mask);
                   end
               end
               @ (posedge ACLK);
           end
           if (error==0)
               $display("%m %d-length wrapping burst RAAWA OK: from %h to %h",
                         leng, start, finish);
           else $display("%m %d-length wrapping burst RAAWA Error %d from %h to %h",
                         leng, error, start, finish);
        end else begin
            $display("%m %d-length wrapping burst read-all-after-write-all from %h to %h ???",
                         leng, start, finish);
        end
   end
   endtask
   //-----------------------------------------------------
   function [AXI_WIDTH_DA-1:0] get_mask;
   input [15:0] size;
   begin
        get_mask = (1<<(size*8))-1;
   end
   endfunction
//--------------------------------------------------------
// Revision history
//
// 2017.04.16: 'memory_test_burst' and 'memory_test_wrap' updated
// 2015.10.21: Parameter names changed
// 2013.01.31: Started by Ando Ki (andoki@gmail.com)
//--------------------------------------------------------
//`endif

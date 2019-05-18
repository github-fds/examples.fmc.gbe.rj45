//----------------------------------------------------------
// Copyright (c) 2011 by Future Design Systems , Inc.
// All right reserved.
//----------------------------------------------------------
// gmii_fifo_async.v
//----------------------------------------------------------
// VERSION: 2011.07.08.
//----------------------------------------------------------
// Asynchronous FIFO
//----------------------------------------------------------
// MACROS and PARAMETERS
//----------------------------------------------------------------
// Features
//    * ready-valid handshake protocol
//    * lookahead full and empty -- see fullN and emptyN
//    * First-Word Fall-Through, but rd_vld indicates its validity
//----------------------------------------------------------------
//    * data moves when both ready(rdy) and valid(vld) is high.
//    * ready(rdy) means the receiver is ready to accept data.
//    * valid(vld) means the data is valid on 'data'.
//----------------------------------------------------------------
//
//                ___   _____   _____   _____   ____
//   wr_clk         |___|   |___|   |___|   |___|
//               _______________________________
//   wr_rdy     
//                     _________________
//   wr_vld      ______|       ||      |___________  
//                      _______  ______
//   wr_din      XXXXXXX__D0___XX__D1__XXXX
//                ___   _____   _____   _____   ____
//   rd_clk         |___|   |___|   |___|   |___|
//                                     _________________
//   rd_rdy      ______________________|               |___
//                                     _________________
//   rd_vld      ______________________|       ||      |___
//                                      ________ _______
//   rd_dout     XXXXXXXXXXXXXXXXXXXXXXX__D0____X__D1___XXXX
//
//                ______________                       _____
//   empty                     |_______________________|
//
//   full        __________________________________________
//
//----------------------------------------------------------------
//
// 'full' is synchronized with wr_clk and 'empty' is synchronized with rd_clk.
//  This means 'empty' may not reflect fast-write operations when rd_clk is
//  slower than wr_clk.
//  This also means 'full' may not reflect fast-read operations when wr_clk
//  is slower than rd_clk. 
//
// 'rd_cnt', 'wr_cnt', 'fullN', 'emptyN' still have metastability problem,
//  since rd_clk and wr_clk are asynchronous.
// 'fullN' and 'emptyN' can reflect current status much faster than
// 'full' and 'empty'. 
//
// 'clr' is synchronous to both 'wr_clk' and 'rd_clk'.
// Thus, 'clr' should be remain high at least one clock
// period of slower clock.
// $EndDescription$
//----------------------------------------------------------------
`timescale 1ns/1ns

module gmii_fifo_async #(parameter FDW  =17,  // fifo data width
                                        FAW  = 3,  // num of entries in 2 to the power FAW
                                        FULN = 2)  // lookahead-full
(
       input   wire           rst     // asynchronous reset
     , input   wire           clr     // synchronous clear 
     , input   wire           wr_clk
     , output  wire           wr_rdy
     , input   wire           wr_vld
     , input   wire [FDW-1:0] wr_din
     , input   wire           rd_clk
     , input   wire           rd_rdy
     , output  wire           rd_vld
     , output  wire [FDW-1:0] rd_dout
     , output  wire           full
     , output  wire           empty
     , output  wire           fullN   // lookahead full; fullN indicates there are only N rooms left
     , output  wire           emptyN  // lookahead empty; empty indicats there are only N elements in the FIFO
     , output  wire [FAW:0]   wr_cnt  // num of rooms in the FIFO to be written
     , output  reg  [FAW:0]   rd_cnt  // num of elements in the FIFO to be read
);
   //---------------------------------------------------
   localparam FDT  = 1<<FAW; // FIFO Depth
   //---------------------------------------------------
   wire [FAW:0] NextToWrite, NextToRead; // mind the width
   wire         wr_enable; // written when it is high with wr_clk
   wire         rd_enable; // read when it is high with rd_clk
   //---------------------------------------------------
   assign rd_vld = !empty;
   assign wr_rdy = !full;
   assign wr_enable = wr_rdy&wr_vld;
   assign rd_enable = rd_rdy&rd_vld;
   //---------------------------------------------------
   gmii_fifo_async_core #(.FDW(FDW), .FAW(FAW)) Ufifo (
         .Data_out   (rd_dout      ),
         .Empty_out  (empty        ),
         .ReadEn_in  (rd_enable    ),
         .RClk       (rd_clk       ),
         .Data_in    (wr_din       ),
         .Full_out   (full         ),
         .WriteEn_in (wr_enable    ),
         .WClk       (wr_clk       ),
         .Reset_in   (rst          ),
         .Clear_in   (clr          ),
         .NextToWrite(NextToWrite  ),
         .NextToRead (NextToRead   )
   );
   //---------------------------------------------------
   always @ (*) begin
       if (NextToWrite[FAW]~^NextToRead[FAW]) begin
           rd_cnt = NextToWrite[FAW-1:0]-NextToRead[FAW-1:0];
       end else begin
           rd_cnt = FDT - (NextToRead[FAW-1:0]-NextToWrite[FAW-1:0]);
       end
   end
   assign wr_cnt = FDT-rd_cnt; // num of rooms in the FIFO
   assign fullN  = (wr_cnt<=FULN); // nearly full
   assign emptyN = (rd_cnt<=FULN); // nearly empty
   //---------------------------------------------------
endmodule

//----------------------------------------------------------------
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
// http://www.asic-world.com/examples/verilog/asyn_fifo.html
//----------------------------------------------------------------
module gmii_fifo_async_core #(parameter FDW = 8, // data width
                                       FAW = 4) // address width
(
       Reset_in
     , Clear_in
     , RClk
     , Data_out
     , ReadEn_in
     , WClk
     , Data_in
     , WriteEn_in
     , NextToWrite
     , NextToRead
     , Empty_out
     , Full_out
);
    //-------------------------------------------------------------------
    input             Reset_in   ; wire            Reset_in   ;
    input             Clear_in   ; wire            Clear_in   ;
    input             RClk       ; wire            RClk       ;
    output [FDW-1:0]  Data_out   ; wire [FDW-1:0]  Data_out   ;
    input             ReadEn_in  ; wire            ReadEn_in  ;
    input             WClk       ; wire            WClk       ;
    input  [FDW-1:0]  Data_in    ; wire [FDW-1:0]  Data_in    ;
    input             WriteEn_in ; wire            WriteEn_in ;
    output [FAW:0]    NextToWrite; wire [FAW:0]    NextToWrite;
    output [FAW:0]    NextToRead ; wire [FAW:0]    NextToRead ;
    output            Empty_out  ; reg             Empty_out  = 1'b1;
    output            Full_out   ; reg             Full_out   = 1'b0;
    //-------------------------------------------------------------------
    localparam DEPTH    = (1 << FAW); // fifo depth
    //-------------------------------------------------------------------
    /////Internal connections & variables//////
    wire  [FAW-1:0] pNextWordToWrite, pNextWordToWrite_nxt;
    wire  [FAW-1:0] pNextWordToRead,  pNextWordToRead_nxt;
    wire            EqualAddresses;
    wire            NextWriteAddressEn, NextReadAddressEn;
    wire            Set_Status, Rst_Status;
    reg             Status;
    wire            PresetFull, PresetEmpty;
    wire  [FAW-1:0] next_read = (ReadEn_in) ? pNextWordToRead_nxt : pNextWordToRead;
    //-------------------------------------------------------------------
    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    //Addreses (Gray counters) logic:
    gmii_fifo_async_core_gray_counter #(.CW(FAW)) GrayCounter_pWr (
        .GrayCount_out(pNextWordToWrite),
        .GrayCount_nxt(pNextWordToWrite_nxt),
        .Enable_in    (NextWriteAddressEn),
        .Reset_in     (Reset_in),
        .Clear_in     (Clear_in),
        .Clk          (WClk),
        .BinaryCount  (NextToWrite)
    );
    gmii_fifo_async_core_gray_counter #(.CW(FAW)) GrayCounter_pRd (
        .GrayCount_out(pNextWordToRead),
        .GrayCount_nxt(pNextWordToRead_nxt),
        .Enable_in    (NextReadAddressEn),
        .Reset_in     (Reset_in),
        .Clear_in     (Clear_in),
        .Clk          (RClk),
        .BinaryCount  (NextToRead)
    );

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    //'Quadrant selectors' logic:
    assign Set_Status = (pNextWordToWrite[FAW-2] ~^ pNextWordToRead[FAW-1]) &
                        (pNextWordToWrite[FAW-1] ^  pNextWordToRead[FAW-2]);
                            
    assign Rst_Status = (pNextWordToWrite[FAW-2] ^  pNextWordToRead[FAW-1]) &
                        (pNextWordToWrite[FAW-1] ~^ pNextWordToRead[FAW-2]);
                         
    //'Status' latch logic:
    // Refer to DC: set_false_path -from {Set_Status,Clear_in,Reset_in} -to Status
    always @ (Set_Status, Rst_Status, Clear_in, Reset_in) begin //D Latch w/ Asynchronous Clear & Preset.
        if      (Rst_Status | Clear_in | Reset_in) Status = 0; //Going 'Empty'.
        else if (Set_Status)                       Status = 1; //Going 'Full'.
        else                                       Status = Status;
    end
            
    //'Full_out' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    `ifndef XILINX
    always @ (posedge WClk, posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull) Full_out <= 1;
        else            Full_out <= 0;
    `else
    wire Full_out_wire;
    FDCP #(.INIT(1'b0)) Ufull_out (.Q(Full_out_wire),.C(WClk),.CLR(Reset_in),.D(1'b0),.PRE(PresetFull));
    always @ ( * ) Full_out = Full_out_wire;
    `endif
            
    //'Empty_out' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
    always @ (posedge RClk, posedge PresetEmpty) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty) Empty_out <= 1;
        else             Empty_out <= 0;
    //-------------------------------------------------------------------
    //'Data_out' logic:
    // First-word fall-through: ADKI, Ando Ki
    reg [FDW-1:0] Mem [DEPTH-1:0];
    assign Data_out = (!Empty_out) ? Mem[pNextWordToRead] : {FDW{1'b0}};
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;
endmodule
//==========================================
// Function : Code Gray counter.
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
//=======================================
module gmii_fifo_async_core_gray_counter #(parameter CW = 4)
(      input  wire          Reset_in 
     , input  wire          Clear_in      //Count reset.
     , input  wire          Clk 
     , input  wire          Enable_in     //Count enable.
     , output reg  [CW-1:0] GrayCount_out //'Gray' code count output.
     , output reg  [CW:0]   BinaryCount
     , output reg  [CW-1:0] GrayCount_nxt //'Gray' code count output.
);
    //-------------------------------------------------------------------
     reg  [CW:0]   BinaryCount_nxt = 2;
    //-------------------------------------------------------------------
    // synthesis translate_off
    initial begin
            BinaryCount     = 1;
            BinaryCount_nxt = 2;
            GrayCount_out   = 0;
            GrayCount_nxt   = 1;
    end
    // synthesis translate_on
    //-------------------------------------------------------------------
    always @ (posedge Clk, posedge Reset_in) begin
        if (Reset_in) begin
            BinaryCount     <= 1;  //Gray count begins @ '1' with
            BinaryCount_nxt <= 2;  //Gray count begins @ '1' with
            GrayCount_out   <= 0;  //first 'Enable_in'.
            GrayCount_nxt   <= 1;  //first 'Enable_in'.
        end
        else if (Clear_in) begin
            BinaryCount     <= 1;  //Gray count begins @ '1' with
            BinaryCount_nxt <= 2;  //Gray count begins @ '1' with
            GrayCount_out   <= 0;  //first 'Enable_in'.
            GrayCount_nxt   <= 1;  //first 'Enable_in'.
        end
        else if (Enable_in) begin
            BinaryCount     <= BinaryCount + 1;
            BinaryCount_nxt <= BinaryCount_nxt + 1;
            GrayCount_out   <= {BinaryCount[CW-1],
                                BinaryCount[CW-2:0] ^ BinaryCount[CW-1:1]};
            GrayCount_nxt   <= {BinaryCount_nxt[CW-1],
                                BinaryCount_nxt[CW-2:0] ^ BinaryCount_nxt[CW-1:1]};
        end
    end
    
endmodule

//----------------------------------------------------------------
// Revision History
//
// 2011.07.11: Started based on DIP_0002_fifo_async by Ando Ki.
//----------------------------------------------------------------

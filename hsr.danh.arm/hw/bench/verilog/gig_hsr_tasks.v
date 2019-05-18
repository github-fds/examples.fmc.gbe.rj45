//`ifndef GIG_HSR_TASKS_V
//`define GIG_HSR_TASKS_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Ando Ki.
// All right reserved.
//
// andoki@gmail.com
//------------------------------------------------------------------------------
// gig_hsr_tasks.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
   localparam CSA_HSR_BASE        = `ADDR_START_HSR;
   localparam CSRA_HSR_VERSION    =(CSA_HSR_BASE+ 8'h00)
            , CSRA_HSR_MAC_ADDR0  =(CSA_HSR_BASE+ 8'h10)// MAC[47:16]
            , CSRA_HSR_MAC_ADDR1  =(CSA_HSR_BASE+ 8'h14)// MAC[15:0]
            , CSRA_HSR_HSR_NET_ID =(CSA_HSR_BASE+ 8'h18)
            , CSRA_HSR_CONTROL    =(CSA_HSR_BASE+ 8'h1C)
            , CSRA_HSR_PHY        =(CSA_HSR_BASE+ 8'h20)// to check and drive PHY RESET
            , CSRA_HSR_PROXY      =(CSA_HSR_BASE+ 8'h24)// read-only
            , CSRA_HSR_QR         =(CSA_HSR_BASE+ 8'h28);// read-only

   //---------------------------------------------------------------------------
   task gig_hsr_phy_reset;
        input      phy_reset; // 1 caluse reset
        input      block; // wait until when 1
        output     phy_reset_n; // return current phy_reset_n
        reg [ 1:0] status; // 0: OK
   begin
        if (phy_reset) begin
            axi_read(CSRA_HSR_PHY, 4, 1, status);
            data_burst_read[0][2:0] = 3'h7;
            data_burst_write[0] = data_burst_read[0];
            axi_write(CSRA_HSR_PHY, 4, 1, status);
        end
        while (block&(data_burst_read[0][2:0]!=3'h0)) begin
               axi_read(CSRA_HSR_PHY, 4, 1, status);
        end
        axi_read(CSRA_HSR_PHY, 4, 1, status);
        phy_reset_n = &data_burst_read[0][2:0];
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_hsr_set_mac_addr;
        input  [47:0] mac_addr;
        reg [ 1:0] status; // 0: OK
   begin
        data_burst_write[0][ 7: 0] = mac_addr[47:40];
        data_burst_write[0][15: 8] = mac_addr[39:32];
        data_burst_write[0][23:16] = mac_addr[31:24];
        data_burst_write[0][31:24] = mac_addr[23:16];
        data_burst_write[1][ 7: 0] = mac_addr[15: 8];
        data_burst_write[1][15: 8] = mac_addr[ 7: 0];
        data_burst_write[1][23:16] = 8'h0;
        data_burst_write[1][31:24] = 8'h0;
        axi_write(CSRA_HSR_MAC_ADDR0, 4, 2, status); // data is justified
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_hsr_get_mac_addr;
        output [47:0] mac_addr;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_HSR_MAC_ADDR0, 4, 2, status); // data is justified
        mac_addr[47:40] = data_burst_write[0][ 7: 0];
        mac_addr[39:32] = data_burst_write[0][15: 8];
        mac_addr[31:24] = data_burst_write[0][23:16];
        mac_addr[23:16] = data_burst_write[0][31:24];
        mac_addr[15: 8] = data_burst_write[1][ 7: 0];
        mac_addr[ 7: 0] = data_burst_write[1][15: 8];
   end
   endtask
   //---------------------------------------------------------------------------
   task hsr_read_and_check;
        input   [31:0]     addr;
        input   [8*20-1:0] str;
        input   [31:0]     expect;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read (addr, 4, 1, status); // data is justified
        $write("%s A:0x%08X D:0x%08X E:0x%08X ", str, addr, data_burst_read[0], expect);
        if (data_burst_read[0]!==expect) begin
            $display(" Mis-match");
        end else begin
            $display(" Match");
        end
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_hsr_csr_test;
   begin
        hsr_read_and_check(CSRA_HSR_VERSION   ,"VERSION   ",32'h2018_1001);
        hsr_read_and_check(CSRA_HSR_MAC_ADDR0 ,"MAC_ADDR0 ",32'h5634_12F0);
        hsr_read_and_check(CSRA_HSR_MAC_ADDR1 ,"MAC_ADDR1 ",32'h0000_0078);
        hsr_read_and_check(CSRA_HSR_HSR_NET_ID,"HSR_NET_ID",32'h0000_0000);
        hsr_read_and_check(CSRA_HSR_CONTROL   ,"CONTROL   ",32'h8000_0006);
        hsr_read_and_check(CSRA_HSR_PHY       ,"PHY       ",32'h0000_007F);
        hsr_read_and_check(CSRA_HSR_PROXY     ,"PROXY     ",32'h0000_0010);
        hsr_read_and_check(CSRA_HSR_QR        ,"QR        ",32'h0000_0010);
   end
   endtask
//------------------------------------------------------------------------------
// Revision history
//
// 2018.06.25: Started by Ando Ki (andoki@gmail.com)
//------------------------------------------------------------------------------
//`endif

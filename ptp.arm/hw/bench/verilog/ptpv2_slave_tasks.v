`ifndef PTPV2_LITE_TASKS_V
`define PTPV2_LITE_TASKS_V
//--------------------------------------------------------
// Copyright (c) 2019 by Ando Ki.
// All right reserved.
//
// http://www.future-ds.com
// adki@future-ds.com
//--------------------------------------------------------
//`include "ptpv2_lite_defines.v"
//--------------------------------------------------------
localparam PTP_CSRA_BASE            = 32'h4C04_0000;
localparam PTP_CSRA_NAME0           = PTP_CSRA_BASE + 8'h00
         , PTP_CSRA_NAME1           = PTP_CSRA_BASE + 8'h04
         , PTP_CSRA_NAME2           = PTP_CSRA_BASE + 8'h08
         , PTP_CSRA_NAME3           = PTP_CSRA_BASE + 8'h0C
         , PTP_CSRA_COMP0           = PTP_CSRA_BASE + 8'h10
         , PTP_CSRA_COMP1           = PTP_CSRA_BASE + 8'h14
         , PTP_CSRA_COMP2           = PTP_CSRA_BASE + 8'h18
         , PTP_CSRA_COMP3           = PTP_CSRA_BASE + 8'h1C
         , PTP_CSRA_VERSION         = PTP_CSRA_BASE + 8'h20
         , PTP_CSRA_CONTROL         = PTP_CSRA_BASE + 8'h30
         , PTP_CSRA_STATUS          = PTP_CSRA_BASE + 8'h34
         , PTP_CSRA_LD_NS           = PTP_CSRA_BASE + 8'h40 // load RTC TOD
         , PTP_CSRA_LD_SEC_LSB      = PTP_CSRA_BASE + 8'h44 // load RTC TOD
         , PTP_CSRA_LD_SEC_MSB      = PTP_CSRA_BASE + 8'h48 // load RTC TOD
         , PTP_CSRA_ADJ_NS          = PTP_CSRA_BASE + 8'h4C // adjust RTC TOD
         , PTP_CSRA_ADJ_SEC         = PTP_CSRA_BASE + 8'h50 // adjust RTC TOD
         , PTP_CSRA_INC_LD_FRAC     = PTP_CSRA_BASE + 8'h54 // load RTC TOD INC
         , PTP_CSRA_INC_LD_NS       = PTP_CSRA_BASE + 8'h58 // load RTC TOD INC
         , PTP_CSRA_INC_ADJ_FRAC    = PTP_CSRA_BASE + 8'h5C // adjust RTC TOD INC
         , PTP_CSRA_INC_ADJ_NS      = PTP_CSRA_BASE + 8'h60 // adjust RTC TOD INC
         , PTP_CSRA_TOD_NS          = PTP_CSRA_BASE + 8'h64 // RTC TOD (read-only)
         , PTP_CSRA_TOD_SEC_LSB     = PTP_CSRA_BASE + 8'h68 // RTC TOD (read-only)
         , PTP_CSRA_TOD_SEC_MSB     = PTP_CSRA_BASE + 8'h6C // RTC TOD (read-only)
         , PTP_CSRA_TIMER           = PTP_CSRA_BASE + 8'h70 // periodic timer setting
         , PTP_CSRA_TSU_TX_ID       = PTP_CSRA_BASE + 8'h74 // TSU-TX fifo
         , PTP_CSRA_TSU_TX_NS       = PTP_CSRA_BASE + 8'h78 // TSU-TX fifo
         , PTP_CSRA_TSU_TX_SEC_LSB  = PTP_CSRA_BASE + 8'h7C // TSU-TX fifo
         , PTP_CSRA_TSU_TX_SEC_MSB  = PTP_CSRA_BASE + 8'h80 // TSU-TX fifo
         , PTP_CSRA_TSU_RX_ID       = PTP_CSRA_BASE + 8'h84 // TSU-RX fifo
         , PTP_CSRA_TSU_RX_NS       = PTP_CSRA_BASE + 8'h88 // TSU-RX fifo
         , PTP_CSRA_TSU_RX_SEC_LSB  = PTP_CSRA_BASE + 8'h8C // TSU-RX fifo
         , PTP_CSRA_TSU_RX_SEC_MSB  = PTP_CSRA_BASE + 8'h90 // TSU-RX fifo
         , PTP_CSRA_MAC_ADDR_LSB    = PTP_CSRA_BASE + 8'h94
         , PTP_CSRA_MAC_ADDR_MSB    = PTP_CSRA_BASE + 8'h98
         , PTP_CSRA_CLOCK_ID_LSB    = PTP_CSRA_BASE + 8'h9C
         , PTP_CSRA_CLOCK_ID_MSB    = PTP_CSRA_BASE + 8'hA0
         , PTP_CSRA_PORT_ID         = PTP_CSRA_BASE + 8'hA4
         , PTP_CSRA_OPA_NSEC        = PTP_CSRA_BASE + 8'hB0
         , PTP_CSRA_OPA_SEC_LSB     = PTP_CSRA_BASE + 8'hB4
         , PTP_CSRA_OPA_SEC_MSB     = PTP_CSRA_BASE + 8'hB8
         , PTP_CSRA_OPB_NSEC        = PTP_CSRA_BASE + 8'hC0
         , PTP_CSRA_OPB_SEC_LSB     = PTP_CSRA_BASE + 8'hC4
         , PTP_CSRA_OPB_SEC_MSB     = PTP_CSRA_BASE + 8'hC8
         , PTP_CSRA_RESULT_NSEC     = PTP_CSRA_BASE + 8'hD0
         , PTP_CSRA_RESULT_SEC_LSB  = PTP_CSRA_BASE + 8'hD4
         , PTP_CSRA_RESULT_SEC_MSB  = PTP_CSRA_BASE + 8'hD8;
//--------------------------------------------------------
localparam NUM_PTP_CSR=37;
reg  [119:0] ptp_string [0:NUM_PTP_CSR-1];
reg  [ 31:0] ptp_addr   [0:NUM_PTP_CSR-1];
reg  [ 31:0] ptp_default[0:NUM_PTP_CSR-1];
initial begin
     ptp_string[ 0] = "NAME0         "; ptp_addr[ 0] = PTP_CSRA_NAME0         ; ptp_default[ 0] = "PTPv";
     ptp_string[ 1] = "NAME1         "; ptp_addr[ 1] = PTP_CSRA_NAME1         ; ptp_default[ 1] = "2 LI";
     ptp_string[ 2] = "NAME2         "; ptp_addr[ 2] = PTP_CSRA_NAME2         ; ptp_default[ 2] = "TE  ";
     ptp_string[ 3] = "NAME3         "; ptp_addr[ 3] = PTP_CSRA_NAME3         ; ptp_default[ 3] = "    ";
     ptp_string[ 4] = "COMP0         "; ptp_addr[ 4] = PTP_CSRA_COMP0         ; ptp_default[ 4] = "FDS ";
     ptp_string[ 5] = "COMP1         "; ptp_addr[ 5] = PTP_CSRA_COMP1         ; ptp_default[ 5] = "    ";
     ptp_string[ 6] = "COMP2         "; ptp_addr[ 6] = PTP_CSRA_COMP2         ; ptp_default[ 6] = "    ";
     ptp_string[ 7] = "COMP3         "; ptp_addr[ 7] = PTP_CSRA_COMP3         ; ptp_default[ 7] = "    ";
     ptp_string[ 8] = "VERSION       "; ptp_addr[ 8] = PTP_CSRA_VERSION       ; ptp_default[ 8] = 32'h2019_0520;
     ptp_string[ 9] = "CONTROL       "; ptp_addr[ 9] = PTP_CSRA_CONTROL       ; ptp_default[ 9] = 32'h0000_0000;
     ptp_string[10] = "STATUS        "; ptp_addr[10] = PTP_CSRA_STATUS        ; ptp_default[10] = 32'h0000_0000;
     ptp_string[11] = "LD_NS         "; ptp_addr[11] = PTP_CSRA_LD_NS         ; ptp_default[11] = 32'h0000_0000;
     ptp_string[12] = "LD_SEC_LSB    "; ptp_addr[12] = PTP_CSRA_LD_SEC_LSB    ; ptp_default[12] = 32'h0000_0000;
     ptp_string[13] = "LD_SEC_MSB    "; ptp_addr[13] = PTP_CSRA_LD_SEC_MSB    ; ptp_default[13] = 32'h0000_0000;
     ptp_string[14] = "ADJ_NS        "; ptp_addr[14] = PTP_CSRA_ADJ_NS        ; ptp_default[14] = 32'h0000_0000;
     ptp_string[15] = "ADJ_SEC       "; ptp_addr[15] = PTP_CSRA_ADJ_SEC       ; ptp_default[15] = 32'h0000_0000;
     ptp_string[16] = "INC_LD_FRAC   "; ptp_addr[16] = PTP_CSRA_INC_LD_FRAC   ; ptp_default[16] = 32'h0000_0000;
     ptp_string[17] = "INC_LD_NS     "; ptp_addr[17] = PTP_CSRA_INC_LD_NS     ; ptp_default[17] = 32'h0000_0008;
     ptp_string[18] = "INC_ADJ_FRAC  "; ptp_addr[18] = PTP_CSRA_INC_ADJ_FRAC  ; ptp_default[18] = 32'h0000_0000;
     ptp_string[19] = "INC_ADJ_NS    "; ptp_addr[19] = PTP_CSRA_INC_ADJ_NS    ; ptp_default[19] = 32'h0000_0000;
     ptp_string[20] = "TOD_NS        "; ptp_addr[20] = PTP_CSRA_TOD_NS        ; ptp_default[20] = 32'h0000_0000;
     ptp_string[21] = "TOD_SEC_LSB   "; ptp_addr[21] = PTP_CSRA_TOD_SEC_LSB   ; ptp_default[21] = 32'h0000_0000;
     ptp_string[22] = "TOD_SEC_MSB   "; ptp_addr[22] = PTP_CSRA_TOD_SEC_MSB   ; ptp_default[22] = 32'h0000_0000;
     ptp_string[23] = "TIMER         "; ptp_addr[23] = PTP_CSRA_TIMER         ; ptp_default[23] = 32'h0000_0000;
     ptp_string[24] = "TSU_TX_ID     "; ptp_addr[24] = PTP_CSRA_TSU_TX_ID     ; ptp_default[24] = 32'h0000_0000;
     ptp_string[25] = "TSU_TX_NS     "; ptp_addr[25] = PTP_CSRA_TSU_TX_NS     ; ptp_default[25] = 32'h0000_0000;
     ptp_string[26] = "TSU_TX_SEC_LSB"; ptp_addr[26] = PTP_CSRA_TSU_TX_SEC_LSB; ptp_default[26] = 32'h0000_0000;
     ptp_string[27] = "TSU_TX_SEC_MSB"; ptp_addr[27] = PTP_CSRA_TSU_TX_SEC_MSB; ptp_default[27] = 32'h0000_0000;
     ptp_string[28] = "TSU_RX_ID     "; ptp_addr[28] = PTP_CSRA_TSU_RX_ID     ; ptp_default[28] = 32'h0000_0000;
     ptp_string[29] = "TSU_RX_NS     "; ptp_addr[29] = PTP_CSRA_TSU_RX_NS     ; ptp_default[29] = 32'h0000_0000;
     ptp_string[30] = "TSU_RX_SEC_LSB"; ptp_addr[30] = PTP_CSRA_TSU_RX_SEC_LSB; ptp_default[30] = 32'h0000_0000;
     ptp_string[31] = "TSU_RX_SEC_MSB"; ptp_addr[31] = PTP_CSRA_TSU_RX_SEC_MSB; ptp_default[31] = 32'h0000_0000;
     ptp_string[32] = "MAC_ADDR_LSB  "; ptp_addr[32] = PTP_CSRA_MAC_ADDR_LSB  ; ptp_default[32] = 32'h2233_4455;
     ptp_string[33] = "MAC_ADDR_MSB  "; ptp_addr[33] = PTP_CSRA_MAC_ADDR_MSB  ; ptp_default[33] = 32'h0000_0211;
     ptp_string[34] = "CLOCK_ID_LSB  "; ptp_addr[34] = PTP_CSRA_CLOCK_ID_LSB  ; ptp_default[34] = 32'h2233_4455;
     ptp_string[35] = "CLOCK_ID_MSB  "; ptp_addr[35] = PTP_CSRA_CLOCK_ID_MSB  ; ptp_default[35] = 32'hACDE_4800;
     ptp_string[36] = "PORT_ID       "; ptp_addr[36] = PTP_CSRA_PORT_ID       ; ptp_default[36] = 32'h0000_0001;
end
//-----------------------------------------------------
task ptp_compare;
input [31:0]  value ;
input [31:0]  expect;
input [119:0] name  ;
begin
    if (value==expect) $display($time,,"%m %s OK    0x%08H", name, value);
    else               $display($time,,"%m %s ERROR 0x%08H, but 0x%08H expected", name, value, expect);
end
endtask
//--------------------------------------------------------
task ptp_csr_test;
reg [31:0] value;
integer    idx;
begin
    for (idx=0; idx<NUM_PTP_CSR; idx=idx+1) begin
         axi_read_one(ptp_addr[idx], value);
         ptp_compare(value, ptp_default[idx], ptp_string[idx]);
    end
end
endtask
//--------------------------------------------------------
task ptp_reset_test;
begin
       ptp_reset( 1// rtc_reset
                , 0// tsu_tx_reset
                , 0// tsu_rx_reset
                );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.rtc_reset_n==1'b1) $display($time,,"%m ERROR RTC reset should be 0");
       else                         $display($time,,"%m OK    RTC reset is 0");
       ptp_reset( 0// rtc_reset
                , 0// tsu_tx_reset
                , 0// tsu_rx_reset
                );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.rtc_reset_n==1'b0) $display($time,,"%m ERROR RTC reset should be 1");
       else                         $display($time,,"%m OK    RTC reset is 1");
       ptp_reset( 0// rtc_reset
                , 1// tsu_tx_reset
                , 0// tsu_rx_reset
                );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_tx_reset_n==1'b1) $display($time,,"%m ERROR TSU TX reset should be 0");
       else                            $display($time,,"%m OK    TSU TX reset is 0");
       ptp_reset( 0// rtc_reset
                , 0// tsu_tx_reset
                , 0// tsu_rx_reset
                );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_tx_reset_n==1'b0) $display($time,,"%m ERROR TSU TX reset should be 1");
       else                            $display($time,,"%m OK    TSU TX reset is 1");
       ptp_reset( 0// rtc_reset
                , 0// tsu_tx_reset
                , 1// tsu_rx_reset
                );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_rx_reset_n==1'b1) $display($time,,"%m ERROR TSU RX reset should be 0");
       else                            $display($time,,"%m OK    TSU RX reset is 0");
       ptp_reset( 0// rtc_reset
                , 0// tsu_tx_reset
                , 0// tsu_rx_reset
                );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_rx_reset_n==1'b0) $display($time,,"%m ERROR TSU RX reset should be 1");
       else                            $display($time,,"%m OK    TSU RX reset is 1");
end
endtask
//--------------------------------------------------------
`define PUSH_FIFO\
       fork\
            begin\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_tx_clk);\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_tx.fifo_vld = 1'b1;\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_tx.fifo_dat = ~101'h0;\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_tx_clk);\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_tx.fifo_vld = 1'b1;\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_tx.fifo_dat = 101'h0;\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_tx_clk);\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_tx.fifo_vld = 1'b0;\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_tx_clk);\
            end\
            begin\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_rx_clk);\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_rx.fifo_vld = 1'b1;\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_rx.fifo_dat = ~101'h0;\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_rx_clk);\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_rx.fifo_vld = 1'b1;\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_rx.fifo_dat = 101'h0;\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_rx_clk);\
            u_fpga.u_dut.u_ptpv2_lite.u_tsu_rx.fifo_vld = 1'b0;\
            @ (posedge u_fpga.u_dut.u_ptpv2_lite.gmii_rx_clk);\
            end\
       join
//--------------------------------------------------------
task ptp_clr_test;
begin
       //---------
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m ERROR TSU-TX should be empty");
       else                                      $display($time,,"%m OK    TSU-TX is empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m ERROR TSU-RX should be empty");
       else                                      $display($time,,"%m OK    TSU-RX is empty");
       `PUSH_FIFO
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m OK    TSU-TX is not empty");
       else                                      $display($time,,"%m ERROR TSU-TX should not be empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m OK    TSU-RX is not empty");
       else                                      $display($time,,"%m ERROR TSU-RX should not be empty");
       //---------
       ptp_clr( 0// tsu_tx_clr
              , 0// tsu_rx_clr
              );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m OK    TSU-TX is not empty");
       else                                      $display($time,,"%m ERROR TSU-TX should not be empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m OK    TSU-RX is not empty");
       else                                      $display($time,,"%m ERROR TSU-RX should not be empty");
       //---------
       ptp_clr( 1// tsu_tx_clr
              , 0// tsu_rx_reset
              );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m ERROR TSU-TX should be empty");
       else                                      $display($time,,"%m OK    TSU-TX is empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m OK    TSU-RX is not empty");
       else                                      $display($time,,"%m ERROR TSU-RX should not be empty");
       //---------
       `PUSH_FIFO
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m OK    TSU-TX is not empty");
       else                                      $display($time,,"%m ERROR TSU-TX should not be empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m OK    TSU-RX is not empty");
       else                                      $display($time,,"%m ERROR TSU-RX should not be empty");
       //---------
       ptp_clr( 0// tsu_tx_clr
              , 1// tsu_rx_clr
              );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m OK    TSU-TX is not empty");
       else                                      $display($time,,"%m ERROR TSU-TX should not be empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m ERROR TSU-RX should be empty");
       else                                      $display($time,,"%m OK    TSU-RX is empty");
       //---------
       `PUSH_FIFO
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m OK    TSU-TX is not empty");
       else                                      $display($time,,"%m ERROR TSU-TX should not be empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m OK    TSU-RX is not empty");
       else                                      $display($time,,"%m ERROR TSU-RX should not be empty");
       //---------
       ptp_clr( 1// tsu_tx_clr
              , 1// tsu_rx_clr
              );
@ (negedge ACLK);
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_tx_empty==1'b0) $display($time,,"%m ERROR TSU-TX should empty");
       else                                      $display($time,,"%m OK    TSU-TX is empty");
       if (u_fpga.u_dut.u_ptpv2_lite.pipe_tsu_rx_empty==1'b0) $display($time,,"%m ERROR TSU-RX should be empty");
       else                                      $display($time,,"%m OK    TSU-RX is empty");
end
endtask
//--------------------------------------------------------
task ptp_enable_test;
begin
       ptp_enable( 1// rtc_enable
                 , 0// tsu_tx_enable
                 , 0// tsu_rx_enable
                 );
       if (u_fpga.u_dut.u_ptpv2_lite.rtc_enable==1'b0) $display($time,,"%m ERROR RTC enable should be 1");
       else                         $display($time,,"%m OK    RTC enable is 1");
       ptp_enable( 0// rtc_enable
                , 0// tsu_tx_enable
                , 0// tsu_rx_enable
                );
       if (u_fpga.u_dut.u_ptpv2_lite.rtc_enable==1'b1) $display($time,,"%m ERROR RTC enable should be 0");
       else                         $display($time,,"%m OK    RTC enable is 0");
       ptp_enable( 0// rtc_enable
                , 1// tsu_tx_enable
                , 0// tsu_rx_enable
                );
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_tx_enable==1'b0) $display($time,,"%m ERROR TSU TX enable should be 1");
       else                            $display($time,,"%m OK    TSU TX enable is 1");
       ptp_enable( 0// rtc_enable
                , 0// tsu_tx_enable
                , 0// tsu_rx_enable
                );
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_tx_enable==1'b1) $display($time,,"%m ERROR TSU TX enable should be 0");
       else                            $display($time,,"%m OK    TSU TX enable is 0");
       ptp_enable( 0// rtc_enable
                , 0// tsu_tx_enable
                , 1// tsu_rx_enable
                );
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_rx_enable==1'b0) $display($time,,"%m ERROR TSU RX enable should be 1");
       else                            $display($time,,"%m OK    TSU RX enable is 1");
       ptp_enable( 0// rtc_enable
                , 0// tsu_tx_enable
                , 0// tsu_rx_enable
                );
       if (u_fpga.u_dut.u_ptpv2_lite.tsu_rx_enable==1'b1) $display($time,,"%m ERROR TSU RX enable should be 0");
       else                            $display($time,,"%m OK    TSU RX enable is 0");
end
endtask
//--------------------------------------------------------
task ptp_reset;
input rtc_reset;
input tsu_tx_reset;
input tsu_rx_reset;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_CONTROL, value);
   value[17] = rtc_reset;
   value[ 9] = tsu_rx_reset;
   value[ 1] = tsu_tx_reset;
   axi_write_one(PTP_CSRA_CONTROL, value);
end
endtask
//--------------------------------------------------------
task ptp_clr;
input tsu_tx_clr;
input tsu_rx_clr;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_TSU_TX_ID, value);
   value[23] = tsu_tx_clr;
   axi_write_one(PTP_CSRA_TSU_TX_ID, value);
   axi_read_one(PTP_CSRA_TSU_RX_ID, value);
   value[23] = tsu_rx_clr;
   axi_write_one(PTP_CSRA_TSU_RX_ID, value);
end
endtask
//--------------------------------------------------------
task ptp_enable;
input rtc_enable;
input tsu_tx_enable;
input tsu_rx_enable;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_CONTROL, value);
   value[16] = rtc_enable;
   value[ 8] = tsu_rx_enable;
   value[ 0] = tsu_tx_enable;
   axi_write_one(PTP_CSRA_CONTROL, value);
end
endtask
//--------------------------------------------------------
task ptp_enable_ie;
input rtc_ie;
input tsu_tx_ie;
input tsu_rx_ie;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_CONTROL, value);
   value[18] = rtc_ie;
   value[10] = tsu_rx_ie;
   value[ 2] = tsu_tx_ie;
   axi_write_one(PTP_CSRA_CONTROL, value);
end
endtask
//--------------------------------------------------------
task ptp_mac_get;
output [47:0] mac;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_MAC_ADDR_LSB, value);
   mac[31:0] = value;
   axi_read_one(PTP_CSRA_MAC_ADDR_MSB , value);
   mac[47:32] = value[15:0];
end
endtask
//--------------------------------------------------------
task ptp_mac_set;
input [47:0] mac;
reg [31:0] value;
begin
   value = mac[31:0];
   axi_write_one(PTP_CSRA_MAC_ADDR_LSB, value);
   value = {16'h0,mac[47:32]};
   axi_write_one(PTP_CSRA_MAC_ADDR_MSB , value);
end
endtask
//--------------------------------------------------------
// TOD Read-After-Write
task rtc_tod_raw;
input [47:0] sec;
input [31:0] nsec;
reg   [31:0] value;
reg   [47:0] rd_sec;
reg   [31:0] rd_nsec;
begin
   //------------------------------------------------------
   // RTC write
   axi_write_one(PTP_CSRA_LD_NS     , nsec);
   axi_write_one(PTP_CSRA_LD_SEC_LSB, sec[31:0]);
   value = (1'b1<<31) | sec[47:32];
   axi_write_one(PTP_CSRA_LD_SEC_MSB, value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_LD_SEC_MSB, value);
   //------------------------------------------------------
   // RTC read
   value = (1'b1<<31); // RTC_RD
   axi_write_one(PTP_CSRA_TOD_SEC_MSB, value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_TOD_SEC_MSB, value);
   //------------------------------------------------------
   rd_sec[47:32] = value[15:0];
   axi_read_one(PTP_CSRA_TOD_SEC_LSB, value);
   rd_sec[31:0] = value;
   axi_read_one(PTP_CSRA_TOD_NS     , value);
   rd_nsec = nsec;
   // check
   if (sec==rd_sec)  $display($time,,"%m OK    0x%06H-sec", rd_sec);
   else              $display($time,,"%m ERROR 0x%06H-sec, but 0x%06H-sec expected", rd_sec, sec);
   if (nsec==rd_nsec) $display($time,,"%m OK    0x%06H-nsec", rd_nsec);
   else               $display($time,,"%m ERROR 0x%06H-nsec, but 0x%06H-nsec expected", rd_nsec, nsec);
end
endtask
//--------------------------------------------------------
// TOD set
task ptp_rtc_tod_set;
input [47:0] sec;
input [31:0] nsec;
reg   [31:0] value;
reg   [47:0] rd_sec;
reg   [31:0] rd_nsec;
begin
   //------------------------------------------------------
   // RTC write
   axi_write_one(PTP_CSRA_LD_NS     , nsec);
   axi_write_one(PTP_CSRA_LD_SEC_LSB, sec[31:0]);
   value = (1'b1<<31) | sec[47:32];
   axi_write_one(PTP_CSRA_LD_SEC_MSB, value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_LD_SEC_MSB, value);
end
endtask
//--------------------------------------------------------
// TOD ADJUST
// RTC should be enabled
// It is updated when ptp_usec occurs.
task ptp_rtc_tod_adj;
input        dec; // 0:inc, 1:dec
input [31:0] nsec;
reg   [31:0] value;
reg   [31:0] cntl;
reg          flag;
begin
   flag = 0;
   //------------------------------------------------------
   axi_read_one(PTP_CSRA_CONTROL, cntl);
   if (cntl[15]==1'b0) begin
       value = cntl | (1<<16);
       axi_write_one(PTP_CSRA_CONTROL, value);
       flag = 1;
   end
   //------------------------------------------------------
   // RTC write
   axi_write_one(PTP_CSRA_ADJ_NS , nsec);
   value = (1'b1<<31) | (dec<<30);
   axi_write_one(PTP_CSRA_ADJ_SEC, value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_ADJ_SEC, value);
   //------------------------------------------------------
   wait (ptp_ppus==1'b1);
   //------------------------------------------------------
   // RTC read
   value = (1'b1<<31); // RTC_RD
   axi_write_one(PTP_CSRA_TOD_SEC_MSB, value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_TOD_SEC_MSB, value);
   //------------------------------------------------------
   if (flag) axi_write_one(PTP_CSRA_CONTROL, cntl);
end
endtask
//--------------------------------------------------------
// INC Read-After-Write
task ptp_rtc_inc_raw;
input [ 7:0] nsec;
input [31:0] frac;
reg   [31:0] value;
reg   [ 7:0] rd_nsec;
reg   [31:0] rd_frac;
begin
   //------------------------------------------------------
   // INC write
   value = frac;
   axi_write_one(PTP_CSRA_INC_LD_FRAC, value);
   value = (1'b1<<31) | nsec;
   axi_write_one(PTP_CSRA_INC_LD_NS  , value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_INC_LD_NS, value);
   //------------------------------------------------------
   // INC read
   axi_read_one(PTP_CSRA_INC_LD_FRAC, value);
   rd_frac = value;
   axi_read_one(PTP_CSRA_INC_LD_NS  , value);
   rd_nsec = value[7:0];
   // check
   if (rd_nsec==nsec) $display($time,,"%m OK    0x%02H-nsec", rd_nsec);
   else               $display($time,,"%m ERROR 0x%02H-nsec, but 0x%02H-nsec expected", rd_nsec, nsec);
   if (rd_frac==frac) $display($time,,"%m OK    0x%08H-sec", rd_frac);
   else               $display($time,,"%m ERROR 0x%08H-sec, but 0x%08H-sec expected", rd_frac, frac);
end
endtask
//--------------------------------------------------------
// INC set
task ptp_rtc_inc_set;
input [ 7:0] nsec;
input [31:0] frac;
reg   [31:0] value;
reg   [ 7:0] rd_nsec;
reg   [31:0] rd_frac;
begin
   //------------------------------------------------------
   // INC write
   value = frac;
   axi_write_one(PTP_CSRA_INC_LD_FRAC, value);
   value = (1'b1<<31) | nsec;
   axi_write_one(PTP_CSRA_INC_LD_NS  , value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_INC_LD_NS, value);
   //------------------------------------------------------
end
endtask
//--------------------------------------------------------
// INC ADJUST
// RTC should be enabled
// It is updated when ptp_usec occurs.
task ptp_rtc_inc_adj;
input        dec; // 0:inc, 1:dec
input [ 7:0] nsec;
input [31:0] frac;
reg   [31:0] value;
reg   [ 7:0] rd_nsec;
reg   [31:0] rd_frac;
reg   [ 7:0] inc_nsec;
reg   [31:0] inc_frac;
reg   [31:0] cntl;
reg          flag;
begin
   flag = 0;
   //------------------------------------------------------
   axi_read_one(PTP_CSRA_CONTROL, cntl);
   if (cntl[15]==1'b0) begin
       value = cntl | (1<<16);
       axi_write_one(PTP_CSRA_CONTROL, value);
       flag = 1;
   end
   //------------------------------------------------------
   axi_read_one(PTP_CSRA_INC_LD_FRAC, value);
   inc_frac = value;
   axi_read_one(PTP_CSRA_INC_LD_NS  , value);
   inc_nsec = value&'hFF;
   //------------------------------------------------------
   // INC write
   value = frac;
   axi_write_one(PTP_CSRA_INC_ADJ_FRAC   , value);
   value = (1'b1<<31) | (dec<<30) | nsec;
   axi_write_one(PTP_CSRA_INC_ADJ_NS     , value);
   // wait until complete
   while (value[31]) axi_read_one(PTP_CSRA_INC_ADJ_NS, value);
   //------------------------------------------------------
   wait (ptp_ppus==1'b1);
   //------------------------------------------------------
   // INC read
   axi_read_one(PTP_CSRA_INC_LD_FRAC, value);
   rd_frac = value;
   axi_read_one(PTP_CSRA_INC_LD_NS, value);
   rd_nsec = value[7:0];
   // check
   if (rd_nsec==inc_nsec) $display($time,,"%m OK    0x%02H-nsec", rd_nsec);
   else                   $display($time,,"%m ERROR 0x%02H-nsec, but 0x%02H-nsec expected", rd_nsec, inc_nsec);
   if (rd_frac==inc_frac) $display($time,,"%m OK    0x%08H-sec", rd_frac);
   else                   $display($time,,"%m ERROR 0x%08H-sec, but 0x%08H-sec expected", rd_frac, inc_frac);
   //------------------------------------------------------
   if (flag) axi_write_one(PTP_CSRA_CONTROL, cntl);
end
endtask
//--------------------------------------------------------
task ptp_timer_test;
input [19:0] usec;
reg [31:0] value;
begin
    ptp_enable_ie ( 1 // rtc_ie;
                  , 0 // tsu_tx_ie;
                  , 0 // tsu_rx_ie;
                  );
    ptp_enable( 1// rtc_enable
              , 0// tsu_tx_enable
              , 0// tsu_rx_enable
              );
    value = {1'b1,7'h0,usec};
    axi_write_one(PTP_CSRA_TIMER, value);
    axi_read_one(PTP_CSRA_STATUS, value);
    while (value[16]==1'b0) axi_read_one(PTP_CSRA_STATUS, value);
    if (u_fpga.u_dut.u_ptpv2_lite.u_csr.IRQ_RTC==1'b0) $display($time,,"%m ERROR IRQ_RTC should be 1");
    else                                    $display($time,,"%m OK    IRQ_RTC is 1");
    //-------------------------------
    // clear IP
    value[16] = 1'b0;
    axi_write_one(PTP_CSRA_STATUS, value);
    if (u_fpga.u_dut.u_ptpv2_lite.u_csr.IRQ_RTC==1'b1) $display($time,,"%m ERROR IRQ_RTC should be 0");
    else                                    $display($time,,"%m OK    IRQ_RTC is 0");
    //-------------------------------
    ptp_enable_ie ( 0 // rtc_ie;
                  , 0 // tsu_tx_ie;
                  , 0 // tsu_rx_ie;
                  );
    ptp_enable( 0// rtc_enable
              , 0// tsu_tx_enable
              , 0// tsu_rx_enable
              );
end
endtask
//--------------------------------------------------------
task ptp_fifo_clear;
input tsu_tx_clr;
input tsu_rx_clr;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_TSU_TX_ID, value);
   value[23] = tsu_tx_clr;
   axi_write_one(PTP_CSRA_TSU_TX_ID, value);
   axi_read_one(PTP_CSRA_TSU_RX_ID, value);
   value[23] = tsu_rx_clr;
   axi_write_one(PTP_CSRA_TSU_RX_ID, value);
end
endtask
//--------------------------------------------------------
task ptp_fifo_tx_pop;
output        mode;
output [ 3:0] type;
output [15:0] seq_id;
output [31:0] nsec;
output [47:0] sec;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_TSU_TX_NS, value);
   nsec   = value;
   axi_read_one(PTP_CSRA_TSU_TX_SEC_LSB, value);
   sec[31:0]   = value;
   axi_read_one(PTP_CSRA_TSU_TX_SEC_MSB, value);
   sec[47:32]   = value[15:0];
   axi_read_one(PTP_CSRA_TSU_TX_ID, value);
   mode   = value[20];
   type   = value[19:16];
   seq_id = value[15:0];
   value[31] = 1'b1; // rd
   value[23] = 1'b0; // clr
   axi_write_one(PTP_CSRA_TSU_TX_ID, value);
   axi_read_one(PTP_CSRA_TSU_TX_ID, value);
   if (value[31]==1'b1) $display($time,,"%m ERROR TX FIFO RD not returned to 0");
end
endtask
//--------------------------------------------------------
task ptp_fifo_rx_pop;
output        mode;
output [ 3:0] type;
output [15:0] seq_id;
output [31:0] nsec;
output [47:0] sec;
reg [31:0] value;
begin
   axi_read_one(PTP_CSRA_TSU_RX_NS, value);
   nsec   = value;
   axi_read_one(PTP_CSRA_TSU_RX_SEC_LSB, value);
   sec[31:0]   = value;
   axi_read_one(PTP_CSRA_TSU_RX_SEC_MSB, value);
   sec[47:32]   = value[15:0];
   axi_read_one(PTP_CSRA_TSU_RX_ID, value);
   mode   = value[20];
   type   = value[19:16];
   seq_id = value[15:0];
   value[31] = 1'b1; // rd
   value[23] = 1'b0; // clr
   axi_write_one(PTP_CSRA_TSU_RX_ID, value);
   axi_read_one(PTP_CSRA_TSU_RX_ID, value);
   if (value[31]==1'b1) $display($time,,"%m ERROR RX FIFO RD not returned to 0");
end
endtask
//-----------------------------------------------------
task ptp_add_test;
reg        opa_neg;
reg [31:0] opa_ns ;
reg [47:0] opa_sec;
reg        opb_neg;
reg [31:0] opb_ns ;
reg [47:0] opb_sec;
reg        result_over;
reg        result_neg ;
reg [31:0] result_ns  ;
reg [47:0] result_sec ;
integer idx, idy;
begin
     opa_neg =  1'b0;
     opa_sec = 48'h1;
     opa_ns  = 32'h1;
     opb_neg =  1'b1;
     opb_sec = 48'h1;
     opb_ns  = 32'h2;
     put_add_one(opa_neg, opa_ns, opa_sec
                ,opb_neg, opb_ns, opb_sec
                ,result_over, result_neg, result_ns, result_sec);
     $display($time,,"%m %c:%012X.%08X + %c:%012X.%08X = %1d:%c:%012X.%08X" 
                ,(opa_neg) ? "-" : "+", opa_sec, opa_ns
                ,(opb_neg) ? "-" : "+", opb_sec, opb_ns
                ,result_over, (result_neg) ? "-" : "+", result_sec, result_ns);
     for (idx=0; idx<5; idx=idx+1) begin
     for (idy=0; idy<5; idy=idy+1) begin
          opa_neg =  1'b0;
          opa_sec = 48'h0+idy;
          opa_ns  = 32'h0+idx;
          opb_neg =  1'b0;
          opb_sec = 48'h0+idy;
          opb_ns  = 32'h0+idx;
          put_add_one(opa_neg, opa_ns, opa_sec
                     ,opb_neg, opb_ns, opb_sec
                     ,result_over, result_neg, result_ns, result_sec);
          $display($time,,"%m %c:%012X.%08X + %c:%012X.%08X = %1d:%c:%012X.%08X" 
                     ,(opa_neg) ? "-" : "+", opa_sec, opa_ns
                     ,(opb_neg) ? "-" : "+", opb_sec, opb_ns
                     ,result_over, (result_neg) ? "-" : "+", result_sec, result_ns);
     end // idy
     end // idx
     for (idx=0; idx<5; idx=idx+1) begin
     for (idy=0; idy<5; idy=idy+1) begin
          opa_neg =  1'b0;
          opa_sec = 48'h0+idy;
          opa_ns  = 32'h0+idx;
          opb_neg =  1'b1;
          opb_sec = 48'h0+idy;
          opb_ns  = 32'h0+idx;
          put_add_one(opa_neg, opa_ns, opa_sec
                     ,opb_neg, opb_ns, opb_sec
                     ,result_over, result_neg, result_ns, result_sec);
          $display($time,,"%m %c:%012X.%08X + %c:%012X.%08X = %1d:%c:%012X.%08X" 
                     ,(opa_neg) ? "-" : "+", opa_sec, opa_ns
                     ,(opb_neg) ? "-" : "+", opb_sec, opb_ns
                     ,result_over, (result_neg) ? "-" : "+", result_sec, result_ns);
     end // idy
     end // idx
     for (idx=0; idx<5; idx=idx+1) begin
     for (idy=0; idy<5; idy=idy+1) begin
          opa_neg =  1'b1;
          opa_sec = 48'h0+idy;
          opa_ns  = 32'h0+idx;
          opb_neg =  1'b0;
          opb_sec = 48'h0+idy;
          opb_ns  = 32'h0+idx;
          put_add_one(opa_neg, opa_ns, opa_sec
                     ,opb_neg, opb_ns, opb_sec
                     ,result_over, result_neg, result_ns, result_sec);
          $display($time,,"%m %c:%012X.%08X + %c:%012X.%08X = %1d:%c:%012X.%08X" 
                     ,(opa_neg) ? "-" : "+", opa_sec, opa_ns
                     ,(opb_neg) ? "-" : "+", opb_sec, opb_ns
                     ,result_over, (result_neg) ? "-" : "+", result_sec, result_ns);
     end // idy
     end // idx
     for (idx=0; idx<5; idx=idx+1) begin
     for (idy=0; idy<5; idy=idy+1) begin
          opa_neg =  1'b1;
          opa_sec = 48'h0+idy;
          opa_ns  = 32'h0+idx;
          opb_neg =  1'b1;
          opb_sec = 48'h0+idy;
          opb_ns  = 32'h0+idx;
          put_add_one(opa_neg, opa_ns, opa_sec
                     ,opb_neg, opb_ns, opb_sec
                     ,result_over, result_neg, result_ns, result_sec);
          $display($time,,"%m %c:%012X.%08X + %c:%012X.%08X = %1d:%c:%012X.%08X" 
                     ,(opa_neg) ? "-" : "+", opa_sec, opa_ns
                     ,(opb_neg) ? "-" : "+", opb_sec, opb_ns
                     ,result_over, (result_neg) ? "-" : "+", result_sec, result_ns);
     end // idy
     end // idx
end
endtask
//-----------------------------------------------------
task put_add_one;
input          opa_neg;
input   [31:0] opa_ns ;
input   [47:0] opa_sec;
input          opb_neg;
input   [31:0] opb_ns ;
input   [47:0] opb_sec;
output         result_over;
output         result_neg ;
output [31:0]  result_ns  ;
output [47:0]  result_sec ;
reg [31:0] value;
begin
     axi_write_one(PTP_CSRA_OPA_NSEC   , opa_ns);
     axi_write_one(PTP_CSRA_OPA_SEC_LSB, opa_sec[31:0]);
     axi_write_one(PTP_CSRA_OPA_SEC_MSB, {15'h0,opa_neg,opa_sec[47:32]});
     axi_write_one(PTP_CSRA_OPB_NSEC   , opb_ns);
     axi_write_one(PTP_CSRA_OPB_SEC_LSB, opb_sec[31:0]);
     axi_write_one(PTP_CSRA_OPB_SEC_MSB, {15'h0,opb_neg,opb_sec[47:32]});
     axi_read_one (PTP_CSRA_RESULT_NSEC   , result_ns);
     axi_read_one (PTP_CSRA_RESULT_SEC_LSB, result_sec[31:0]);
     axi_read_one (PTP_CSRA_RESULT_SEC_MSB, value);
     result_sec[47:32] = value[15:0];
     result_neg        = value[16];
     result_over       = value[17];
end
endtask
//-----------------------------------------------------
// Revision history
//
// 2019.05.20: Started by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
`endif

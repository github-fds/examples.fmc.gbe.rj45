//`ifndef GIG_MAC_TASKS_V
//`define GIG_MAC_TASKS_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Ando Ki.
// All right reserved.
//
// andoki@gmail.com
//------------------------------------------------------------------------------
// gig_mac_tasks.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
   localparam CSA_BASE      = `ADDR_START_GMAC;
   localparam CSRA_CONTROL  =(CSA_BASE+'h00),
              CSRA_STATUS   =(CSA_BASE+'h04),

              CSRA_MAC_ADDR0=(CSA_BASE+'h10), //[7:0] goes to conf_mac_addr[47:40]
              CSRA_MAC_ADDR1=(CSA_BASE+'h14),

              CSRA_CONF_TX0 =(CSA_BASE+'h20),
              CSRA_CONF_TX1 =(CSA_BASE+'h24),
              CSRA_CONF_RX0 =(CSA_BASE+'h30),
              CSRA_CONF_RX1 =(CSA_BASE+'h34),

              CSRA_DES_TX0 =(CSA_BASE+'h40), // room,bnum
              CSRA_DES_TX1 =(CSA_BASE+'h44), // dummy to align with 64-bit
              CSRA_DES_TX2 =(CSA_BASE+'h48), // src
              CSRA_DES_TX3 =(CSA_BASE+'h4C), // src

              CSRA_DES_RX0 =(CSA_BASE+'h50), // items,bnum
              CSRA_DES_RX1 =(CSA_BASE+'h54), // dummy to align with 64-bit
              CSRA_DES_RX2 =(CSA_BASE+'h58), // dst
              CSRA_DES_RX3 =(CSA_BASE+'h5C), // dst

              CSRA_DMA_TX0  =(CSA_BASE+'h60), // control (chunk)
              CSRA_DMA_TX1  =(CSA_BASE+'h64), // status (full or empty)
              CSRA_DMA_TX2  =(CSA_BASE+'h68), // start (lower 32-bit)
              CSRA_DMA_TX3  =(CSA_BASE+'h6C), // start (upper 32-bit)
              CSRA_DMA_TX4  =(CSA_BASE+'h70), // end
              CSRA_DMA_TX5  =(CSA_BASE+'h74), // end
              CSRA_DMA_TX6  =(CSA_BASE+'h78), // head
              CSRA_DMA_TX7  =(CSA_BASE+'h7C), // head
              CSRA_DMA_TX8  =(CSA_BASE+'h80), // tail (RO)
              CSRA_DMA_TX9  =(CSA_BASE+'h84), // tail (RO)

              CSRA_DMA_RX0  =(CSA_BASE+'h90), // control (chunk)
              CSRA_DMA_RX1  =(CSA_BASE+'h94), // status (full or empty)
              CSRA_DMA_RX2  =(CSA_BASE+'h98), // start
              CSRA_DMA_RX3  =(CSA_BASE+'h9C), // start
              CSRA_DMA_RX4  =(CSA_BASE+'hA0), // end
              CSRA_DMA_RX5  =(CSA_BASE+'hA4), // end
              CSRA_DMA_RX6  =(CSA_BASE+'hA8), // head (RO)
              CSRA_DMA_RX7  =(CSA_BASE+'hAC), // head (RO)
              CSRA_DMA_RX8  =(CSA_BASE+'hB0), // tail
              CSRA_DMA_RX9  =(CSA_BASE+'hB4); // tail

   //---------------------------------------------------------------------------
   // It fills frame memory.
   task gig_mac_send_packet;
        input  [47:0] mac_dst;
        input  [47:0] mac_src;
        input  [15:0] type_leng;
        reg [ 1:0] status; // 0: OK
        reg [31:0] head;
        reg [31:0] tail;
        reg [31:0] Astart;
        reg [31:0] Aend  ;
        reg [31:0] src ;
        integer    room;
        integer    Aneed, Wneed, Wroom;
        integer idx, idy, idz;
        reg [7:0] value;
        reg [31:0] data_tmp;
   begin
        if (type_leng==0) disable gig_mac_send_packet;
        //----------------------------------------------------------------------
        // get head pointer
        axi_read (CSRA_DMA_TX6, 4, 1, status); // data is justified
        head[31: 0] = data_burst_read[0];
        src         = head;
        //----------------------------------------------------------------------
        // check full
        data_burst_read[0] = 32'h2; // full
        while (data_burst_read[0][1]==1'b1) begin
               axi_read (CSRA_DMA_TX1, 4, 1, status);
        end
        //----------------------------------------------------------------------
        // check room in descriptor
        data_burst_read[0] = 32'h0;
        while (data_burst_read[0][31:16]==16'h0) begin
               axi_read (CSRA_DES_TX0, 4, 1, status);
        end
        //----------------------------------------------------------------------
        if (head%4) $display("%t %m Warning mis-aligned packet", $time);
        //----------------------------------------------------------------------
        // build packet
        value = 8'h01;
        data_burst_write[0][ 7: 0] = mac_dst[47:40];
        data_burst_write[0][15: 8] = mac_dst[39:32];
        data_burst_write[0][23:16] = mac_dst[31:24];
        data_burst_write[0][31:24] = mac_dst[23:16];
        data_burst_write[1][ 7: 0] = mac_dst[15: 8];
        data_burst_write[1][15: 8] = mac_dst[ 7: 0];
        data_burst_write[1][23:16] = mac_src[47:40];
        data_burst_write[1][31:24] = mac_src[39:32];
        data_burst_write[2][ 7: 0] = mac_src[31:24];
        data_burst_write[2][15: 8] = mac_src[23:16];
        data_burst_write[2][23:16] = mac_src[15: 8];
        data_burst_write[2][31:24] = mac_src[ 7: 0];
        data_burst_write[3][ 7: 0] = type_leng[15: 8];
        data_burst_write[3][15: 8] = type_leng[ 7: 0];
        if (type_leng==1) begin
            data_burst_write[3][23:16] = value; value = value + 1;
            data_burst_write[3][31:24] = 8'h0;
        end else begin // type_leng>=2
            data_burst_write[3][23:16] = value; value = value + 1;
            data_burst_write[3][31:24] = value; value = value + 1;
        end
        idy = 4;
        if (type_leng>2) begin
            idy = 4;
            for (idx=2; (idx+4)<=type_leng; idx=idx+4) begin
                data_burst_write[idy][ 7: 0] = value; value = value + 1;
                data_burst_write[idy][15: 8] = value; value = value + 1;
                data_burst_write[idy][23:16] = value; value = value + 1;
                data_burst_write[idy][31:24] = value; value = value + 1;
                idy = idy+1;
            end
            //------------------------------------------------------------------
            if ((type_leng-idx)==3) begin
                data_burst_write[idy][ 7: 0] = value; value = value + 1;
                data_burst_write[idy][15: 8] = value; value = value + 1;
                data_burst_write[idy][23:16] = value; value = value + 1;
                data_burst_write[idy][31:24] = 8'h0;
                idy = idy + 1;
            end if ((type_leng-idx)==2) begin
                data_burst_write[idy][ 7: 0] = value; value = value + 1;
                data_burst_write[idy][15: 8] = value; value = value + 1;
                data_burst_write[idy][23:16] = 8'h0;
                data_burst_write[idy][31:24] = 8'h0;
                idy = idy + 1;
            end if ((type_leng-idx)==1) begin
                data_burst_write[idy][ 7: 0] = value; value = value + 1;
                data_burst_write[idy][15: 8] = 8'h0;
                data_burst_write[idy][23:16] = 8'h0;
                data_burst_write[idy][31:24] = 8'h0;
                idy = idy + 1;
            end
            //------------------------------------------------------------------
        end
        Wneed = idy; // the num of data_burst_write[] to move for a packet
        //----------------------------------------------------------------------
        // need room = 6+6+2+type_leng
        Aneed = 14+type_leng;
        if (((Aneed+3)/4)!=Wneed) $display("%04d %m not matched packet", $time);
        //----------------------------------------------------------------------
        while (Aneed>0) begin
            room = 0;
            while (room==0) begin
                   gig_mac_get_rooms( room  // num of bytes
                                    , head 
                                    , tail 
                                    ,Astart 
                                    ,Aend);
            end
            //----------------------------------------------------------------------
            if (room>=Aneed) begin
                // sufficient room to fill packet in frame buffer
                while ((Wneed-256)>0) begin
                    axi_write(head[31:0], 4, 256, status); // data is justified
                    head[31:0] = head[31:0] + (256<<2); //head[31:0] = head[31:0] + Aneed + 3;
                    head[31:0] ={head[31:2],2'b00};
                    if (head==Aend) head = Astart;
                    //----------------------------------------------------------
                    // make packet shifted
                    for (idx=256; idx<Wneed; idx=idx+1) begin
                         data_burst_write[idx-256] = data_burst_write[idx];
                    end
                    Wneed = Wneed - 256;
                end
                if (Wneed>0) begin
                    axi_write(head[31:0], 4, Wneed, status); // data is justified
                    head[31:0] = head[31:0] + (Wneed<<2); //head[31:0] = head[31:0] + Aneed + 3;
                    head[31:0] ={head[31:2],2'b00};
                    if (head==Aend) head = Astart;
                end
                //----------------------------------------------------------------------
                // update head
                data_burst_write[0] = head[31: 0];
                axi_write(CSRA_DMA_TX6, 4, 1, status); // data is justified
                //----------------------------------------------------------------------
                Aneed = 0;
            end else begin
                Wroom = room>>2;
                if (room%4) $display("%04d %m ERROR not word aligned", $time);
                while ((Wroom-256)>0) begin
                    axi_write(head[31:0], 4, 256, status); // data is justified
                    head[31:0] = head[31:0] + (256<<2); //head[31:0] = head[31:0] + Aneed + 3;
                    head[31:0] ={head[31:2],2'b00};
                    if (head==Aend) head = Astart;
                    //----------------------------------------------------------
                    // make packet shifted
                    for (idx=256; idx<Wneed; idx=idx+1) begin
                         data_burst_write[idx-256] = data_burst_write[idx];
                    end
                    Wroom = Wroom - 256;
                end
                if (Wroom>0) begin
                    axi_write(head[31:0], 4, Wroom, status); // data is justified
                    head[31:0] = head[31:0] + (Wroom<<2); //head[31:0] = head[31:0] + Aneed + 3;
                    head[31:0] ={head[31:2],2'b00};
                    if (head==Aend) head = Astart;
                    //----------------------------------------------------------
                    // make packet shifted
                    for (idx=Wroom; idx<Wneed; idx=idx+1) begin
                         data_burst_write[idx-Wroom] = data_burst_write[idx];
                    end
                    Wroom = 0;
                end
                //----------------------------------------------------------------------
                // update head
                data_tmp = data_burst_write[0]; // save to keep value
                data_burst_write[0] = head[31: 0];
                axi_write(CSRA_DMA_TX6, 4, 1, status); // data is justified
                data_burst_write[0] = data_tmp;
                //----------------------------------------------------------------------
                Aneed = Aneed - room;
                Wneed = (Aneed+3)/4;
            end
        end
        //----------------------------------------------------------------------
        // update tx descriptor
        data_burst_write[0]        = src[31: 0];
        axi_write(CSRA_DES_TX2, 4, 1, status);
        data_burst_write[0][31   ] = 1'b1;
        data_burst_write[0][30:16] = 15'h0;
        data_burst_write[0][15: 0] = (type_leng+14);
        axi_write(CSRA_DES_TX0, 4, 1, status); // data is justified
        //----------------------------------------------------------------------
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_get_rooms;
        output [15:0] Aroom; // num of bytes
        output [31:0] Ahead;
        output [31:0] Atail;
        output [31:0] Astart;
        output [31:0] Aend;
        reg [ 1:0] status; // 0: OK
        reg        full, empty;
   begin
        //----------------------------------------------------------------------
        axi_read (CSRA_DMA_TX0, 4, 9, status); // note it is 9-beat burst
        full   = data_burst_read[1][1];
        empty  = data_burst_read[1][0];
        Astart = data_burst_read[2];
        Aend   = data_burst_read[4];
        Ahead  = data_burst_read[6];
        Atail  = data_burst_read[8];
        //----------------------------------------------------------------------
        // calculate room
        if (empty) begin
            //      Astart                Aend
            //      |--------------------|
            //      |--------------------|
            //       /\
            //       ||
            //      Tail==Head
            //
            //      Astart                Aend
            //      |--------------------|
            //      |--------------------|
            //              /\
            //              ||
            //             Tail==Head
            Aroom = Aend - Ahead; // be careful
        end else if (full) begin
            //      Astart                Aend
            //      |--------------------|
            //      |XXXXXXXXXXXXXXXXXXXX|
            //       /\
            //       ||
            //      Tail==Head
            Aroom = 32'h0;
        end else if (Atail>Ahead) begin
            //      Astart                Aend
            //      |--------------------|
            //      |XXX------------XXXXX|
            //          /\          /\
            //          ||          ||
            //         Head        Tail
            Aroom = Atail - Ahead;
        end else begin
            //      Astart                Aend
            //      |--------------------|
            //      |---XXXXXXXXXXXX-----|
            //          /\          /\
            //          ||          ||
            //         Tail        Head
            Aroom = Aend - Ahead;
        end
   end
   endtask
   //---------------------------------------------------------------------------
   reg [7:0] packet_buff[0:(6+6+2+1500+4)];
   //---------------------------------------------------------------------------
   task axi_read_slow;
        input [31:0] addr;
        input [15:0] size;
        input [15:0] leng;
        input integer ind;
        reg   [ 1:0] status;
        reg   [31:0] addrX;
        integer num;
   begin
        addrX = addr;
        num = leng;
        while ((num-4)>0) begin
                axi_read(addrX, size, 4, status); // data is justified
                gig_mac_pkt_build(ind, 4); ind = ind + (4<<2);
                num = num - 4;
                addrX = addrX + 4*size;
        end
        if (num>0) begin
                axi_read(addrX, size, num, status); // data is justified
                gig_mac_pkt_build(ind, num); ind = ind + (num<<2);
        end
   end
   endtask
   //---------------------------------------------------------------------------
   // It consumes data in the frame memory.
   task gig_mac_receive_packet;
        input slow;
        reg [ 1:0] status; // 0: OK
        reg [31:0] head;
        reg [31:0] tail;
        reg [31:0] Astart;
        reg [31:0] Aend  ;
        reg [31:0] dst ;
        integer Aneed, Wneed, item;
        integer idx, idy, idz, idw;
        reg [7:0] value;
   begin
        //----------------------------------------------------------------------
        // wait for an RX descriptor entry
        data_burst_read[0] = 0;
        while (data_burst_read[0][31:16]==16'h0) axi_read(CSRA_DES_RX0, 4, 1, status);
        Aneed = data_burst_read[0][15:0]; // the num of bytes in the packet
        //----------------------------------------------------------------------
        // get dst (where to start to read)
        axi_read(CSRA_DES_RX2, 4, 1, status);
        dst = data_burst_read[0];
        //----------------------------------------------------------------------
        // pop one descriptor
        data_burst_write[0][31] = 1'b1;
        axi_write(CSRA_DES_RX0, 4, 1, status);
        //----------------------------------------------------------------------
        idw = 0;
        while (Aneed>0) begin
            item = 0;
            while (item==0) begin
                   gig_mac_get_items( item  // num of bytes
                                    , head 
                                    , tail 
                                    ,Astart 
                                    ,Aend);
            end
            //----------------------------------------------------------------------
            if (item>=Aneed) begin
                Wneed = (Aneed+3)>>2;
                // sufficient item to get packet from frame buffer
                while ((Wneed-256)>0) begin
                    if (slow) begin
                        axi_read_slow(tail[31:0], 4, 256, idw); // data is justified
                    end else begin
                        axi_read(tail[31:0], 4, 256, status); // data is justified
                        gig_mac_pkt_build(idw, 256);
                    end
                    idw = idw + (256<<2);
                    tail[31:0] = tail[31:0] + (256<<2);
                    tail[31:0] ={tail[31:2],2'b00};
                    if (tail==Aend) tail = Astart;
                    Aneed = Aneed - (256<<2);
                    Wneed = Wneed - 256;
                end
                if (Aneed>0) begin
                    Wneed = (Aneed+3)>>2;
                    if (slow) begin
                        axi_read_slow(tail[31:0], 4, Wneed, idw); // data is justified
                    end else begin
                        axi_read(tail[31:0], 4, Wneed, status); // data is justified
                        gig_mac_pkt_build(idw, Wneed);
                    end
                    idw = idw + (Wneed<<2);
                    tail[31:0] = tail[31:0] + (Wneed<<2);
                    tail[31:0] ={tail[31:2],2'b00};
                    if (tail==Aend) tail = Astart;
                end
                //----------------------------------------------------------------------
                // update tail
                data_burst_write[0] = tail[31: 0];
                axi_write(CSRA_DMA_RX8, 4, 1, status); // data is justified
                //----------------------------------------------------------------------
                Aneed = 0;
            end else begin
                Aneed = Aneed - item;
                Wneed = (item+3)>>2;
                while ((Wneed-256)>0) begin
                    if (slow) begin
                        axi_read_slow(tail[31:0], 4, 256, idw); // data is justified
                    end else begin
                        axi_read(tail[31:0], 4, 256, status); // data is justified
                        gig_mac_pkt_build(idw, 256);
                    end
                    idw = idw + (256<<2);
                    tail[31:0] = tail[31:0] + (256<<2);
                    tail[31:0] ={tail[31:2],2'b00};
                    if (tail==Aend) tail = Astart;
                    item = item - (256<<2);
                    Wneed = Wneed - 256;
                end
                if (item>0) begin
                    Wneed = (item+3)>>2;
                    item  = 0;
                    if (slow) begin
                        axi_read_slow(tail[31:0], 4, Wneed, idw); // data is justified
                    end else begin
                        axi_read(tail[31:0], 4, Wneed, status); // data is justified
                        gig_mac_pkt_build(idw, Wneed);
                    end
                    idw = idw + (Wneed<<2);
                    tail[31:0] = tail[31:0] + (Wneed<<2);
                    tail[31:0] ={tail[31:2],2'b00};
                    if (tail==Aend) tail = Astart;
                end
                //----------------------------------------------------------------------
                // update tail
                data_burst_write[0] = tail[31: 0];
                axi_write(CSRA_DMA_RX8, 4, 1, status); // data is justified
                //----------------------------------------------------------------------
            end
        end
        gig_mac_pkt_check(idw);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_pkt_build;
        input integer ind; // starting index of packet_buff[]
        input integer wnum; // num of bytes
        integer bnum;
        integer a, x;
   begin
        bnum = wnum<<2;
        a = ind;
        for (x=0; x<wnum; x=x+1) begin
             packet_buff[a  ] = data_burst_read[x][ 7: 0];
             packet_buff[a+1] = data_burst_read[x][15: 8];
             packet_buff[a+2] = data_burst_read[x][23:16];
             packet_buff[a+3] = data_burst_read[x][31:24];
             a = a + 4;
        end
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_pkt_check;
        input integer bnum;
        integer ix, iz;
        integer type_leng, error;
        reg [7:0] expect;
   begin
        type_leng = (packet_buff[12]<<8)|packet_buff[13];
        if ((type_leng<46)&&(bnum!=60)) $display("%04d %m ERROR type-leng error \"(type_leng<46)&&(bnum!=60)\": type_leng=%d, bnum=%d", $time, type_leng, bnum);
        if (bnum<(type_leng+14)) $display("%04d %m ERROR type-leng error \"(bnum<(type_leng+14))\": bnum=%d type_leng=%d", $time, bnum, type_leng);
        error = 0;
        expect = 8'h01;
        for (ix=0; ix<type_leng; ix=ix+1) begin
             iz = ix + 14;
             if (packet_buff[iz]!==expect) begin
$display("%04d %m %d[%02X], but %02X expected", $time, iz, packet_buff[iz], expect);
                 error=error+1;
             end
             expect = expect + 1;
        end
        if (error==0) $display("%04d %m packet payload %d OK", $time, type_leng);
        else          $display("%04d %m packet payload %d %d error", $time, type_leng, error);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_get_items;
        output [15:0] Aitem; // num of bytes
        output [31:0] Ahead;
        output [31:0] Atail;
        output [31:0] Astart;
        output [31:0] Aend;
        reg [ 1:0] status; // 0: OK
        reg        full, empty;
   begin
        //----------------------------------------------------------------------
        axi_read (CSRA_DMA_RX0, 4, 9, status); // note it is 9-beat burst
        full   = data_burst_read[1][1];
        empty  = data_burst_read[1][0];
        Astart = data_burst_read[2];
        Aend   = data_burst_read[4];
        Ahead  = data_burst_read[6];
        Atail  = data_burst_read[8];
        //----------------------------------------------------------------------
        // calculate items
        if (empty) begin
            //      Astart                Aend
            //      |--------------------|
            //      |--------------------|
            //       /\
            //       ||
            //      Tail==Head
            Aitem = 32'h0;
        end else if (full) begin
            //      Astart                Aend
            //      |--------------------|
            //      |XXXXXXXXXXXXXXXXXXXX|
            //       /\
            //       ||
            //      Tail==Head
            //
            //      Astart                Aend
            //      |--------------------|
            //      |XXXXXXXXXXXXXXXXXXXX|
            //                /\
            //                ||
            //               Tail==Head
            Aitem = Aend - Atail; // be careful
        end else if (Atail>Ahead) begin
            //      Astart                Aend
            //      |--------------------|
            //      |XXX------------XXXXX|
            //          /\          /\
            //          ||          ||
            //         Head        Tail
            Aitem = Aend - Atail;
        end else begin
            //      Astart                Aend
            //      |--------------------|
            //      |---XXXXXXXXXXXX-----|
            //          /\          /\
            //          ||          ||
            //         Tail        Head
            Aitem = Ahead - Atail;
        end
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_enable_tx;
        input  [15:0] chunk; // number of bytes to move as a burst
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONF_TX0, 4, 1, status); // data is justified
        //----------------------------------------------------------------------
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][1] = 1; // conf_tx_en;
        axi_write(CSRA_CONF_TX0, 4, 1, status); // data is justified
        //----------------------------------------------------------------------
        data_burst_write[0] = chunk; // chunk for tx
        axi_write(CSRA_DMA_TX0, 4, 1, status); // data is justified
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_enable_rx;
        input  [15:0] chunk;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONF_RX0, 4, 1, status); // data is justified
        //----------------------------------------------------------------------
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][1] = 1; // conf_tx_en;
        axi_write(CSRA_CONF_RX0, 4, 1, status); // data is justified
        //----------------------------------------------------------------------
        data_burst_write[0] = chunk; // chunk for tx
        axi_write(CSRA_DMA_RX0, 4, 1, status); // data is justified
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_reset_tx;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONF_TX0, 4, 1, status);
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][0] = 1'b1; // conf_tx_reset: auto return to 0
        axi_write(CSRA_CONF_TX0, 4, 1, status);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_reset_rx;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONF_RX0, 4, 1, status);
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][0] = 1'b1; // conf_rx_reset: auto return to 0
        axi_write(CSRA_CONF_RX0, 4, 1, status);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_set_conf_tx;
        input jumbo_en;
        input no_gen_crc;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONF_TX0, 4, 1, status);
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][2] = jumbo_en;
        data_burst_write[0][3] = no_gen_crc;
        axi_write(CSRA_CONF_TX0, 4, 1, status);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_set_conf_rx;
        input jumbo_en;
        input no_chk_crc;
        input promiscuous;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONF_RX0, 4, 1, status);
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][2] = jumbo_en;
        data_burst_write[0][3] = no_chk_crc;
        data_burst_write[0][4] = promiscuous;
        axi_write(CSRA_CONF_RX0, 4, 1, status);
   end
   endtask
   //---------------------------------------------------------------------------
   // It requires tx_reset
   task gig_mac_init_frame_buffer_tx;
        input  [31:0] tx_start;
        input  [31:0] tx_end  ;
        reg [ 1:0] status; // 0: OK
   begin
        //----------------------------------------------------------------------
        data_burst_write[0] = tx_start[31: 0];
        axi_write(CSRA_DMA_TX2, 4, 1, status); // tx_addr_start
        axi_write(CSRA_DMA_TX6, 4, 1, status); // tx_addr_head
        data_burst_write[0] = tx_end[31: 0];
        axi_write(CSRA_DMA_TX4, 4, 1, status); // tx_addr_end
        //----------------------------------------------------------------------
        gig_mac_reset_tx;
        //----------------------------------------------------------------------
   end
   endtask
   //---------------------------------------------------------------------------
   // It requires rx_reset
   task gig_mac_init_frame_buffer_rx;
        input  [31:0] rx_start;
        input  [31:0] rx_end  ;
        reg [ 1:0] status; // 0: OK
   begin
        //----------------------------------------------------------------------
        data_burst_write[0] = rx_start[31: 0];
        axi_write(CSRA_DMA_RX2, 4, 1, status); // rx_addr_start
        axi_write(CSRA_DMA_RX8, 4, 1, status); // rx_addr_tail
        data_burst_write[0] = rx_end[31: 0];
        axi_write(CSRA_DMA_RX4, 4, 1, status); // rx_addr_end
        //----------------------------------------------------------------------
        gig_mac_reset_rx;
        //----------------------------------------------------------------------
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_set_mac_addr;
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
        axi_write(CSRA_MAC_ADDR0, 4, 2, status); // data is justified
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_get_mac_addr;
        output [47:0] mac_addr;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_MAC_ADDR0, 4, 2, status); // data is justified
        mac_addr[47:40] = data_burst_write[0][ 7: 0];
        mac_addr[39:32] = data_burst_write[0][15: 8];
        mac_addr[31:24] = data_burst_write[0][23:16];
        mac_addr[23:16] = data_burst_write[0][31:24];
        mac_addr[15: 8] = data_burst_write[1][ 7: 0];
        mac_addr[ 7: 0] = data_burst_write[1][15: 8];
   end
   endtask
   //----------------------------------------------------------------------
   // check room in descriptor
   task gig_mac_get_descriptor_tx;
        output [15:0] rooms;
        output [15:0] items;
        reg [ 1:0] status; // 0: OK
   begin
          axi_read (CSRA_DES_TX0, 4, 1, status);
          {rooms,items} = data_burst_read[0];
   end
   endtask
   //----------------------------------------------------------------------
   // check items in descriptor
   task gig_mac_get_descriptor_rx;
        output [15:0] items;
        output [15:0] bnum;
        reg [ 1:0] status; // 0: OK
   begin
          axi_read (CSRA_DES_RX0, 4, 1, status);
          {items,bnum} = data_burst_read[0];
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_set_ie;
        input ie;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_CONTROL, 4, 1, status);
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][31] = ie;
        axi_write(CSRA_CONTROL, 4, 1, status);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_check_ip;
        output ip;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_STATUS, 4, 1, status);
        ip =  data_burst_read[0][31];
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_mac_clear_ip;
        reg [ 1:0] status; // 0: OK
   begin
        axi_read(CSRA_STATUS, 4, 1, status);
        data_burst_write[0] = data_burst_read[0];
        data_burst_write[0][31] = 1'b1;
        axi_write(CSRA_STATUS, 4, 1, status);
   end
   endtask
   //---------------------------------------------------------------------------
   task gig_phy_reset;
        input      phy_reset; // 1 caluse reset
        input      block; // wait until when 1
        output     phy_reset_n; // return current phy_reset_n
        reg [ 1:0] status; // 0: OK
   begin
        if (phy_reset) begin
            axi_read(CSRA_CONTROL, 4, 1, status);
            data_burst_read[0][30] = 1'b1;
            data_burst_write[0] = data_burst_read[0];
            axi_write(CSRA_CONTROL, 4, 1, status);
        end
        while (block&data_burst_read[0][30]) begin
               axi_read(CSRA_CONTROL, 4, 1, status);
        end
        axi_read(CSRA_STATUS, 4, 1, status);
        phy_reset_n = data_burst_read[0][30];
   end
   endtask
   //---------------------------------------------------------------------------
   task read_and_check;
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
   task gig_mac_csr_test;
   begin
        read_and_check(CSRA_CONTROL  , "CONTROL  ", 32'h0000_0002);
        read_and_check(CSRA_STATUS   , "STATUS   ", 32'h4000_0000);
                                                 
        read_and_check(CSRA_MAC_ADDR0, "MAC_ADDR0", 32'h0000_0000);
        read_and_check(CSRA_MAC_ADDR1, "MAC_ADDR1", 32'h0000_0000);
                                                 
        read_and_check(CSRA_CONF_TX0 , "CONF_TX0 ", 32'h0000_0000);
        read_and_check(CSRA_CONF_TX1 , "CONF_TX1 ", 32'h0000_0000);
        read_and_check(CSRA_CONF_RX0 , "CONF_RX0 ", 32'h0000_0000);
        read_and_check(CSRA_CONF_RX1 , "CONF_RX1 ", 32'h0000_0000);
                                                 
        read_and_check(CSRA_DES_TX0 , "FIFO_TX0 ", 32'h0010_0000); // TX_DESCIPTOR_FAW=4
        read_and_check(CSRA_DES_TX1 , "FIFO_TX1 ", 32'h0000_0000);
        read_and_check(CSRA_DES_TX2 , "FIFO_TX2 ", 32'h0000_0000);
        read_and_check(CSRA_DES_TX3 , "FIFO_TX3 ", 32'h0000_0000);
                                                 
        read_and_check(CSRA_DES_RX0 , "FIFO_RX0 ", 32'h0000_0000); // TX_DESCIPTOR_FAW=4
        read_and_check(CSRA_DES_RX1 , "FIFO_RX1 ", 32'h0000_0000);
        read_and_check(CSRA_DES_RX2 , "FIFO_RX2 ", 32'h0000_0000);
        read_and_check(CSRA_DES_RX3 , "FIFO_RX3 ", 32'h0000_0000);
                                                 
        `ifndef AMBA_AXI4
        read_and_check(CSRA_DMA_TX0  , "DMA_TX0  ", 32'h0000_0040);
        `else
        read_and_check(CSRA_DMA_TX0  , "DMA_TX0  ", 32'h0000_0400);
        `endif
        read_and_check(CSRA_DMA_TX1  , "DMA_TX1  ", 32'h0000_0001);
        read_and_check(CSRA_DMA_TX2  , "DMA_TX2  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX3  , "DMA_TX3  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX4  , "DMA_TX4  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX5  , "DMA_TX5  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX6  , "DMA_TX6  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX7  , "DMA_TX7  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX8  , "DMA_TX8  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_TX9  , "DMA_TX9  ", 32'h0000_0000);
                                                 
        `ifndef AMBA_AXI4
        read_and_check(CSRA_DMA_RX0  , "DMA_RX0  ", 32'h0000_0040);
        `else
        read_and_check(CSRA_DMA_RX0  , "DMA_RX0  ", 32'h0000_0400);
        `endif
        read_and_check(CSRA_DMA_RX1  , "DMA_RX1  ", 32'h0000_0001);
        read_and_check(CSRA_DMA_RX2  , "DMA_RX2  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX3  , "DMA_RX3  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX4  , "DMA_RX4  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX5  , "DMA_RX5  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX6  , "DMA_RX6  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX7  , "DMA_RX7  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX8  , "DMA_RX8  ", 32'h0000_0000);
        read_and_check(CSRA_DMA_RX9  , "DMA_RX9  ", 32'h0000_0000);
   end
   endtask
//------------------------------------------------------------------------------
// Revision history
//
// 2018.06.25: Started by Ando Ki (andoki@gmail.com)
//------------------------------------------------------------------------------
//`endif

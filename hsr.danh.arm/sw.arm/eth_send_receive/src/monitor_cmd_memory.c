//--------------------------------------------------------
// Copyright (c) 2018 by Futue Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2018.10.02.
//--------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "strtoi.h"
#include "monitor_command.h"
#include "mem_api.h"

//--------------------------------------------------------
int mem_read_word(unsigned int saddr, unsigned int eaddr)
{
    unsigned int pt, val;
    int num;
    num = 0;
    pt = saddr;
    printf("%08x:", saddr);
    while (pt<=(eaddr-3)) {
//printf("mem_read_word: S:0x%x E:0x%x P:0x%x\n", saddr, eaddr, pt);
        if (num>=4) {
            printf("\n");
            printf("%08x: ", pt);
            num = 0;
        } else {
          printf(" ");
        }
        val = *(unsigned int*)pt; //MEM_READ(pt, val);
        printf("%08x", val);
        pt+=4;
        num++;
    }
    printf("\n");
    return num;
}
int mem_read_short(unsigned int saddr, unsigned int eaddr)
{
    unsigned int pt;
    unsigned short val;
    int num;
    num = 0;
    pt = saddr;
    printf("%08x:", saddr);
    while ((unsigned int)pt<=(eaddr-1)) {
        if (num>=8) {
            printf("\n");
            printf("%08x: ", pt);
            num = 0;
        } else {
          printf(" ");
        }
        val = *(unsigned short*)pt; // MEM_READ_P(pt, val, 2);
        printf("%04x", (unsigned short)val);
        pt+=2;
        num++;
    }
    printf("\n");
    return num;
}
int mem_read_byte(unsigned int saddr, unsigned int eaddr)
{
    unsigned int pt;
    unsigned char val;
    int num;
    num = 0;
    pt = saddr;
    printf("%08x:", saddr);
    while ((unsigned int)pt<=eaddr) {
        if (num>=16) {
            printf("\r\n");
            printf("%08x: ", pt);
            num = 0;
        } else {
          printf(" ");
        }
        val = *(unsigned char*)pt; //MEM_READ_P(pt, val, 1);
        printf("%02x", (unsigned char)val);
        pt++;
        num++;
    }
    printf("\r\n");
    return num;
}

//--------------------------------------------------------
// Memory read from <start_addr> to <end_addr> with
// the specific granuality.
//
// mr [-w|s|b] <start_addr[:len]>
int func_mem_read   (int argc, char *argv[])
{
    char *token;
    unsigned int saddr, eaddr;
    int size, pos, num;
//printf("mem_read: argc=%d\n", argc);
    if (argc<2) return -1;
    pos = 1;
    size = 1;
    if (argv[pos][0]=='-') {
       switch (argv[pos][1]) {
         case 'w': size = 4; break;
         case 's': size = 2; break;
         case 'b': size = 1; break;
         default:  {
#ifdef RIGOR
              if (verbose>0) {
                  printf("Error: memory option error\r\n");
              }
#endif
              return -1;
         }
       }
       pos++;
    }
//printf("mem_read: argc=%d pos=%d\n", argc, pos);
    //if (argc<=pos) return -1;
    token = strtok(argv[pos], ":");
    if (token==NULL) return -1;
    saddr = (unsigned int)strtoi(token);
    token = strtok(NULL, ":");
    if (token!=NULL) {
        eaddr = saddr+(unsigned int)strtoi(token);
    } else {
        eaddr = saddr + size-1;
    }
//printf("mem_read: argc=%d pos=%d eaddr=0x%x\n", argc, pos, eaddr);
    switch (size) {
       case 4: num = mem_read_word (saddr, eaddr); break;
       case 2: num = mem_read_short(saddr, eaddr); break;
       case 1: num = mem_read_byte (saddr, eaddr); break;
    }
    return num;
}
//--------------------------------------------------------
int mem_write_word (unsigned int cont, unsigned int saddr, unsigned int eaddr)
{
    unsigned int pt;
    int num;
    num = 0;
    pt = saddr;
    while ((unsigned int)pt<=(eaddr-3)) {
//printf("mem_write_word: C:0x%x S:0x%x E:0x%x P:0x%x\n", cont, saddr, eaddr, pt);
        *(unsigned int*)pt= cont; //MEM_WRITE(pt, cont); // *pt = cont;
        pt+=4;
        num++;
    }
    return num;
}
int mem_write_short (unsigned short cont, unsigned int saddr, unsigned int eaddr)
{
    unsigned int pt;
    int num;
    num = 0;
    pt = saddr;
    while ((unsigned int)pt<=(eaddr-1)) {
        *(unsigned short*)pt= cont; //MEM_WRITE_P(pt, cont, 2); // *pt = cont;
        pt+=2;
        num++;
    }
    return num;
}
int mem_write_byte (unsigned char cont, unsigned int saddr, unsigned int eaddr)
{
    unsigned int pt;
    int num;
    num = 0;
    pt = saddr;
    while ((unsigned int)pt<=eaddr) {
        *(unsigned char*)pt = cont; //MEM_WRITE_P(pt, cont, 1); //*pt = cont;
        pt++;
        num++;
    }
    return num;
}

//--------------------------------------------------------
// Memory wirte from <start_addr> to <end_addr> with
// the specific granuality and <cont>.
//
// mw [-w|s|b] <cont> <start_addr[:leng]>
int func_mem_write  (int argc, char *argv[])
{
    char *token;
    unsigned int cont, saddr, eaddr;
    int size, pos, num;
    if (argc<3) return -1;
    pos = 1;
    size = 1;
    if (argv[pos][0]=='-') {
       switch (argv[pos][1]) {
         case 'w': size = 4; break;
         case 's': size = 2; break;
         case 'b': size = 1; break;
         default:  {
#ifdef RIGOR
              if (verbose>0) {
                  printf("Error: memory option error\r\n");
              }
#endif
              return -1;
         }
       }
       pos++;
    }
    //if (argc<=pos) return -1;
    cont = (unsigned int)strtoi(argv[pos]);
    pos++;
    //if (argc<=pos) return -1;
    token = strtok(argv[pos], ":");
    if (token==NULL) return -1;
    saddr = (unsigned int)strtoi(token);
    token = strtok(NULL, ":");
    if (token!=NULL) {
        eaddr = saddr+(unsigned int)strtoi(token);
    } else {
        eaddr = saddr + size-1;
    }
    switch (size) {
       case 4: num = mem_write_word (cont, saddr, eaddr); break;
       case 2: num = mem_write_short(cont&0xFFFF, saddr, eaddr); break;
       case 1: num = mem_write_byte (cont&0xFF, saddr, eaddr); break;
    }
    return num;
}

//--------------------------------------------------------
int mem_move_word (unsigned int saddr, unsigned int daddr, unsigned int num)
{
   unsigned int spt, dpt, val;
   unsigned int i;
   spt = saddr;
   dpt = daddr;
   for (i=0; i<num; i++) {
       val = *(unsigned int*)spt; //MEM_READ(spt, val);
       *(unsigned int*)dpt = val; //MEM_WRITE(dpt, val); // *dpt = *spt;
       dpt+=4;
       spt+=4;
   }
   return i;
}

int mem_move_short (unsigned int saddr, unsigned int daddr, unsigned int num)
{
   unsigned int spt, dpt;
   unsigned short val;
   unsigned int i;
   spt = saddr;
   dpt = daddr;
   for (i=0; i<num; i++) {
       val = *(unsigned short*)spt; //MEM_READ_P(spt, val, 2);
       *(unsigned short*)dpt = val; //MEM_WRITE_P(dpt, val, 2); // *dpt = *spt;
       dpt+=2;
       spt+=2;
   }
   return i;
}
int mem_move_byte (unsigned int saddr, unsigned int daddr, unsigned int num)
{
   unsigned int spt, dpt;
   unsigned char val;
   unsigned int i;
   spt = saddr;
   dpt = daddr;
   for (i=0; i<num; i++) {
       val = *(unsigned char*)spt; //MEM_READ_P(spt, val, 1);
       *(unsigned char*)dpt = val; //MEM_WRITE_P(dpt, val, 1); // *dpt = *spt;
       dpt++;
       spt++;
   }
   return i;
}

//--------------------------------------------------------
// Memory move from <src_addr> to <dst_addr> with
// the specific granuality.
//
// mm [-w|s|b] <src_addr> <dst_addr> <num>
int func_mem_move   (int argc, char *argv[])
{
    unsigned int saddr, daddr;
    int size, pos, num;
    if (argc<4) return -1;
    pos = 1;
    size = 1;
    if (argv[pos][0]=='-') {
       switch (argv[pos][1]) {
         case 'w': size = 4; break;
         case 's': size = 2; break;
         case 'b': size = 1; break;
         default:  {
#ifdef RIGOR
              if (verbose>0) {
                  printf("Error: memory option error\r\n");
              }
#endif
              return -1;
         }
       }
       pos++;
    }
    if (argc<=pos) return -1;
    saddr = (unsigned int)strtoi(argv[pos]);
    pos++;
    if (argc<=pos) return -1;
    daddr = (unsigned int)strtoi(argv[pos]);
    pos++;
    if (argc<=pos) return -1;
    num = (int)strtoi(argv[pos]);
    switch (size) {
       case 4: num = mem_move_word (saddr, daddr, num); break;
       case 2: num = mem_move_short(saddr, daddr, num); break;
       case 1: num = mem_move_byte (saddr, daddr, num); break;
    }
    return num;
}

//--------------------------------------------------------
int mem_compare_word ( unsigned int saddr
                     , unsigned int daddr
                     , int num
                     , int disp
                     )
{
  unsigned int spt, dpt, sval, dval;
  int i, miss;
  miss = 0;
  spt = saddr;
  dpt = daddr;
  for (i=0; i<num; i++) {
      sval = *(unsigned int*)spt; //MEM_READ(spt, sval);
      dval = *(unsigned int*)dpt; //MEM_READ(dpt, dval);
      if (sval!=dval) {
          miss++;
          if (disp) printf("Error: memory comapre mis-match: A:0x%08x=D:0x%08x A:0x%08x=D:0x%08x\n", spt, sval, dpt, dval);
      }
      spt+=4;
      dpt+=4;
  }
  return miss;
}
int mem_compare_short( unsigned int saddr
                     , unsigned int daddr
                     , int num
                     , int disp
                     )
{
  unsigned int spt, dpt;
  unsigned short sval, dval;
  int i, miss;
  miss = 0;
  spt = saddr;
  dpt = daddr;
  for (i=0; i<num; i++) {
      sval = *(unsigned short*)spt; //MEM_READ_P(spt, sval, 2);
      dval = *(unsigned short*)dpt; //MEM_READ_P(dpt, dval, 2);
      if ((sval&0xFFFF)!=(dval&0xFFFF)) {
          miss++;
          if (disp) printf("Error: memory comapre mis-match: A:0x%08x=D:0x%04x A:0x%08x=D:0x%04x\n", spt, sval, dpt, dval);
      }
      spt+=2;
      dpt+=2;
  }
  return miss;
}
int mem_compare_byte( unsigned int saddr
                     , unsigned int daddr
                     , int num
                     , int disp
                     )
{
  unsigned int spt, dpt;
  unsigned char sval, dval;
  int i, miss;
  miss = 0;
  spt = saddr;
  dpt = daddr;
  for (i=0; i<num; i++) {
      sval = *(unsigned char*)spt; //MEM_READ_P(spt, sval, 1);
      dval = *(unsigned char*)dpt; //MEM_READ_P(dpt, dval, 1);
      if ((sval&0xFF)!=(dval&0xFF)) {
          miss++;
          if (disp) printf("Error: memory comapre mis-match: A:0x%08x=D:0x%02x A:0x%08x=D:0x%02x\n", spt, sval, dpt, dval);
      }
      spt++;
      dpt++;
  }
  return miss;
}

//--------------------------------------------------------
// Memory compare from <addr1> and <addr2> with
// the specific granuality and <num>.
//
// mc [-w|s|b] [-d] <addr1> <addr2> <num>
int func_mem_compare(int argc, char *argv[])
{
    unsigned int saddr, daddr;
    int size, disp, pos, num, err;
    if (argc<4) return -1;
    pos  = 1;
    size = 1;
    disp = 0;
    while (argv[pos][0]=='-') {
       switch (argv[pos][1]) {
         case 'w': size = 4; break;
         case 's': size = 2; break;
         case 'b': size = 1; break;
         case 'd': disp = 1; break;
       }
       pos++;
    }
    if (argc<=pos) return -1;
    saddr = (unsigned int)strtoi(argv[pos]);
    pos++;
    if (argc<=pos) return -1;
    daddr = (unsigned int)strtoi(argv[pos]);
    pos++;
    if (argc<=pos) return -1;
    num = (int)strtoi(argv[pos]);
    switch (size) {
       case 4: err = mem_compare_word (saddr, daddr, num, disp); break;
       case 2: err = mem_compare_short(saddr, daddr, num, disp); break;
       case 1: err = mem_compare_byte (saddr, daddr, num, disp); break;
    }
    if (err) {
       printf("Error: memory compare %d mismatch out of %d\n", err, num);
    } else {
       printf("Info: memory compare %d", num);
       switch (size) {
          case 4: printf("-word OK\r\n");  break;
          case 2: printf("-short OK\r\n"); break;
          case 1: printf("-byte OK\r\n");  break;
       }
    }
    return num;
}

//--------------------------------------------------------
// mt <start_addr> <end_addr> [level]
// level: 0 simple test, 1 complex test
int func_mem_test   (int argc, char *argv[])
{
    unsigned int saddr, eaddr, depth, level; // size
    int pos;
    extern void mem_test(unsigned int sa, unsigned int ea, int level);
    if (argc<3) return -1;
    pos   = 1;
    //size  = 1;
    level = 1;
    if (argc<=pos) return -1;
    saddr = (unsigned int)strtoi(argv[pos]);
    pos++;
    if (argc<=pos) return -1;
    eaddr = (unsigned int)strtoi(argv[pos]);
    depth = eaddr - saddr;
    pos++;
//printf("argc=%d pos=%d\n", argc, pos);
    if (argc>pos) level = (unsigned int)strtoi(argv[pos]);
//printf("mem_test %x %x %d\n", saddr, depth, level);
    mem_test(saddr, depth, level);
    return 0;
}

//--------------------------------------------------------
int mem_register(void)
{
  command_register("mr", "", func_mem_read,
                   "mr : memory read",
                   "mr [-w|s|b] <start_addr[:leng]>             : memory read - w for word");
  command_register("mw", "", func_mem_write,
                   "mw : memory write",
                   "mw [-w|s|b] <cont> <start_addr[:leng]>      : memory write");
  command_register("mm", "", func_mem_move,
                   "mm : memory move",
                   "mm [-w|s|b] <src_addr> <dst_addr> <num>     : memory move");
  command_register("mc", "", func_mem_compare,
                   "mc : memory compare",
                   "mc [-w|s|b] [-d] <addr1> <addr2> <num>      : memory compare");
  command_register("mt", "", func_mem_test,
                   "mt : memory test",
                   "mt <start_addr> <end_addr> [level]          : memory test");
  return 0;
}

//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------

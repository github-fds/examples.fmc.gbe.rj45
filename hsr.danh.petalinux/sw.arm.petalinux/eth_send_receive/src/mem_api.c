//********************************************************
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//********************************************************
// mem_api.c
//********************************************************
// VERSION = 2018.10.02.
//********************************************************
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void
mem_test(unsigned int saddr, unsigned int depth, int level) {
    unsigned int diff;
    unsigned int b;
    extern int MemTestRAW(unsigned int saddr, unsigned int depth, unsigned int size);
    extern int MemTestBurstRAW(unsigned int saddr, unsigned int depth, unsigned int leng);

    printf("Info: memory test from 0x%x to 0x%x\n", saddr, saddr+depth);
    fflush(stdout);
    if (level>0) {
       diff = MemTestRAW(saddr, depth, 4); // word test
       diff = MemTestRAW(saddr, depth, 2); // short test
       diff = MemTestRAW(saddr, depth, 1); // byte test
    }
    if (level>1) {
       b = 1;
       diff = MemTestBurstRAW(saddr, depth, b); // burst test
       b = 2;
       diff = MemTestBurstRAW(saddr, depth, b); // burst test
    }
    if (level>2) {
       for (b=4; b<=16; b+=4) {
           diff = MemTestBurstRAW(saddr, depth, b); // burst test
       }
    }
    diff = diff;
}

static unsigned int my_rand(void);
static void my_srand(unsigned int seed);
static void rotating_cursor(int t);
int
MemTestRAW(unsigned int saddr, unsigned int depth, unsigned int size) {
   unsigned int i, mask, err;
   unsigned int send;

   printf("Info: %d-byte  Test from 0x%x 0x%x ", size, saddr, saddr+depth);
   fflush(stdout);
   switch (size) {
     case 1:  mask = 0x000000ff; break;
     case 2:  mask = 0x0000ffff; break;
     case 4:
     default: mask = 0xffffffff; break;
   }
   my_srand(7);
   send = saddr+depth;
   switch (size) {
   case 4: for (i = saddr; i<send; i+=size) {
               unsigned int wd = my_rand();
               *(unsigned int*)i = wd; //MEM_WRITE_G(i, &wd, size, 1);
               rotating_cursor(i);
           }
           break;
   case 2: for (i = saddr; i<send; i+=size) {
               unsigned short wd = my_rand()&mask;
               *(unsigned short*)i = wd; //MEM_WRITE_G(i, &wd, size, 1);
               rotating_cursor(i);
           }
           break;
   default: for (i = saddr; i<send; i+=size) {
               unsigned char wd = my_rand()&mask;
               *(unsigned char*)i = wd; //MEM_WRITE_G(i, &wd, size, 1);
               rotating_cursor(i);
           }
           break;
   }
   err = 0;
   my_srand(7);
   switch (size) {
   case 4: for (i = saddr; i<send; i+=size) {
               unsigned int ex = my_rand();
               unsigned int rd = *(unsigned int*)i;//MEM_READ_G(i, &rd, size, 1);
               if (ex!=rd) {
                   err++;
                   printf("mis-match at 0x%08x, 0x%08x read, but 0x%08x expected\n",
                           i, rd, ex);
               }
               rotating_cursor(i);
           }
           break;
   case 2: for (i = saddr; i<send; i+=size) {
               unsigned short ex = my_rand()&mask;
               unsigned short rd = *(unsigned short*)i;//MEM_READ_G(i, &rd, size, 1);
               rd = rd&mask;
               if (ex!=rd) {
                   err++;
                   printf("mis-match at 0x%08x, 0x%04x read, but 0x%04x expected\n",
                           i, rd, ex);
               }
               rotating_cursor(i);
           }
           break;
   default: for (i = saddr; i<send; i+=size) {
               unsigned char ex = my_rand()&mask;
               unsigned char rd = *(unsigned short*)i;//MEM_READ_G(i, &rd, size, 1);
               rd = rd&mask;
               if (ex!=rd) {
                   err++;
                   printf("mis-match at 0x%08x, 0x%02x read, but 0x%02x expected\n",
                           i, rd, ex);
               }
               rotating_cursor(i);
           }
           break;
   }
   if (!err) printf(" OK\n");
   else      printf(" %d mis-match", err);
   fflush(stdout);
   return(err);
}

int
MemTestBurstRAW(unsigned int saddr, unsigned int depth, unsigned int leng) {
   unsigned int i, j, ex, err;
   unsigned int send;
   unsigned int *data;
   unsigned int wleng, rleng;
   //static unsigned int my_rand(void);
   //static void my_srand(unsigned int seed);
   //static void rotating_cursor(int t);

   printf("Info: Burst %d Test from 0x%x 0x%x ",
                       leng, saddr, saddr+depth);
   fflush(stdout);
   if ((saddr+depth)%leng) {
	   send = ((saddr+depth)/leng)*leng;
   } else {
           send = saddr+depth;
   }

   data = NULL;
   if ((data = (unsigned int*)malloc(leng*4))==NULL) {
      printf("cannot alloca memory\n");
   }
  //------------------------------------------------
   wleng = leng;
   for (i = saddr; i<send; i+=(wleng*4)) {
      for (j = 0; j<wleng; j++) {
          data[j] = i+j+1; //my_rand();
      }
      memcpy((void*)i, (void*)data, 4*wleng);//MEM_WRITE_G(i, data, size, wleng);
      rotating_cursor(i);
   }
  //------------------------------------------------
   err = 0;
   my_srand(7);
   rleng = leng;
   //printf("read %d-------------------------------\n", rleng);
   for (i=saddr; i<send; i+=(rleng*4)) {
       memcpy((void*)data, (void*)i, 4*rleng);//MEM_READ_G(i, data, size, rleng);
       for (j = 0; j<rleng; j++) {
           ex = i+j+1; //my_rand();
           if (data[j] != ex) {
              err++;
              printf("mis-match at 0x%x, 0x%x read, but 0x%x expected\n",
                   i+j*4, data[j], ex);
	   }
//else {
//printf("    match at 0x%x, 0x%x read\n", i+j*4, data[j]);
//}
       }
       rotating_cursor(i);
   }

   if (!err) printf(" OK\n");
   else     {printf(" %d mis-match\n", err);
              exit(0);
   }
   if (data!=NULL) free(data);
   fflush(stdout);
   return(err);
}

static void rotating_cursor(int t) {
   static char cnext = '|';
   static int next  = 0;
   if ((t%0xFF)==0) {
          putchar(cnext); fflush(stdout);
          switch (next) {
          case 0: cnext = '/';  next = 1; break;
          case 1: cnext = '-';  next = 2; break;
          case 2: cnext = 0x5C; next = 3; break;
          case 3: cnext = '|';  next = 0; break;
          }
          putchar('');
   }
   //putchar(''); fflush(stdout);
}

#define MY_RAND_MAX 0xFFFFFFFF
static unsigned long _Randseed = 1;

static unsigned int my_rand(void)
{
  _Randseed = _Randseed * 1103515245 + 12345;
  return((unsigned int)_Randseed);
}

static void my_srand(unsigned int seed)
{
  _Randseed = seed;
}

//********************************************************
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//********************************************************

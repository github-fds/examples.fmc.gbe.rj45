//--------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// strtoi.c
//--------------------------------------------------------
// VERSION = 2018.10.02.
//--------------------------------------------------------

//--------------------------------------------------------
// Convert string to integer
// Treat hex when string starts '0x' or '0X'
// Ignore '_'
int strtoi(char *str)
{
   int i, val, minus;
   val = 0;
   if (str[0]=='-') { minus = 1; i=1;}
   else             { minus = 0; i=0;}
   if ((str[i]=='0')&&((str[i+1]=='x')||(str[i+1]=='X'))) {
       for (i+=2; (str[i]!='\0'); i++) {
            if ((str[i]>='0')&&(str[i]<='9')) val = (val*16)+(str[i]-'0');
            else if ((str[i]>='a')&&(str[i]<='f')) val = (val*16)+(str[i]-'a'+10);
            else if ((str[i]>='A')&&(str[i]<='F')) val = (val*16)+(str[i]-'A'+10);
            else if (str[i]=='_') continue;
            else return 0;
       }
   } else {
       for (; (str[i]!='\0'); i++) {
            if ((str[i]>='0')&&(str[i]<='9')) val = (val*10)+(str[i]-'0');
            else if (str[i]=='_') continue;
            else return 0;
       }
   }
   if (minus) val *= -1;
   return val;
}

//--------------------------------------------------------
// Convert string to integer
// Treat hex when string starts '0x' or '0X'
// Ignore '_'
unsigned int strtoui(char *str)
{
   int i, val, minus;
   val = 0;
   if (str[0]=='-') { minus = 1; i=1;}
   else             { minus = 0; i=0;}
   if ((str[i]=='0')&&((str[i+1]=='x')||(str[i+1]=='X'))) {
       for (i+=2; (str[i]!='\0'); i++) {
            if ((str[i]>='0')&&(str[i]<='9')) val = (val*16)+(str[i]-'0');
            else if ((str[i]>='a')&&(str[i]<='f')) val = (val*16)+(str[i]-'a'+10);
            else if ((str[i]>='A')&&(str[i]<='F')) val = (val*16)+(str[i]-'A'+10);
            else if (str[i]=='_') continue;
            else return 0;
       }
   } else {
       for (; (str[i]!='\0'); i++) {
            if ((str[i]>='0')&&(str[i]<='9')) val = (val*10)+(str[i]-'0');
            else if (str[i]=='_') continue;
            else return 0;
       }
   }
   if (minus) val *= -1;
   return (unsigned int)val;
}

//--------------------------------------------------------
// Revision History
//
// 2018.10.02: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------

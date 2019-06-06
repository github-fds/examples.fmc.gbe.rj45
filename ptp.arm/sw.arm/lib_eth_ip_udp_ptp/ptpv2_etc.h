#ifndef PTPV2_ETC_H
#define PTPV2_ETC_H

#define PTPV2_DEBUG(fmt, x...) \
    do { \
        if(debug) { \
            printf("%s:%i:%s() " fmt, __FILE__, __LINE__, __FUNCTION__, ##x);\
        } \
    } while(0)

#define PTPV2_ERROR(fmt, x...) \
    do { printf("%s:%i:%s() ERROR" fmt, __FILE__, __LINE__, __FUNCTION__, ##x);\
    } while(0)

#endif

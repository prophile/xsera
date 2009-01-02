#ifndef __apollo_logging_h
#define __apollo_logging_h

#define LOG_MESSAGE 1
#define LOG_NOTICE 2
#define LOG_WARNING 3
#define LOG_ERROR 4
#define LOG_NONE 5

// define to the relevant one
#define LOG_LEVEL LOG_NOTICE

#include <stdio.h>

void __Log ( const char* subsystem, int level, const char* messageFormat, ... );
#define LOG(subsystem, level, messageFormat...) { if (level > LOG_LEVEL) { __Log(subsystem, level, messageFormat , ## messageFormat); } }

#endif

#ifdef WIN32
#include <stdafx.h>
#endif

#include "Logging.h"
#include <stdarg.h>

static inline const char* LogLevel (int lv)
{
    switch (lv)
    {
        case LOG_MESSAGE:
            return "Message";
        case LOG_NOTICE:
            return "Notice";
        case LOG_WARNING:
            return "Warning";
        case LOG_ERROR:
            return "Error";
    }
    return "?";
}

void __Log ( const char* subsystem, int level, const char* message, ... )
{
	va_list va;
	va_start(va, message);
	char formatBuffer[512];
	sprintf(formatBuffer, "[%s] %s: %s\n", subsystem, LogLevel(level), message);
	vfprintf(stderr, formatBuffer, va);
	va_end(va);
}


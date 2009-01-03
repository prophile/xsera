#ifndef __apollo_logging_h
#define __apollo_logging_h

/**
 * A message - typically notifying that a file is loaded, changing state or level
 */
#define LOG_MESSAGE 1
/**
 * A notice - typically notifying that a deprecated API is being used or such trivial warnings
 */
#define LOG_NOTICE 2
/**
 * A warning - typically notifying that a fallback has been used, a file cannot be loaded
 */
#define LOG_WARNING 3
/**
 * An error - typically a message indicating an unrecoverable state, followed by an ungraceful exit
 */
#define LOG_ERROR 4
/**
 * No log messages
 */
#define LOG_NONE 5

// define to the relevant one
/**
 * The current log level
 */
#ifdef NDEBUG
#define LOG_LEVEL LOG_WARNING
#else
#define LOG_LEVEL LOG_MESSAGE
#endif

#include <stdio.h>

void __Log ( const char* subsystem, int level, const char* messageFormat, ... );
/**
 * Logs a message
 * @param subsystem The name of the subsystem to use
 * @param level The level of message
 * @param message A format string, followed by printf-style arguments
 */
#define LOG(subsystem, level, messageFormat...) { if (level > LOG_LEVEL) { __Log(subsystem, level, messageFormat , ## messageFormat); } }

#endif

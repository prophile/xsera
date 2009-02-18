#ifndef __enetadapt_h
#define __enetadapt_h

#include <enet/enet.h>
#ifdef WIN32
#undef SendMessage
#undef GetMessage	//apparently, these are windows directives
#endif

#endif
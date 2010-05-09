#ifndef __XNET_MESSAGE_IDS__
#define __XNET_MESSAGE_IDS__

#include "XNet.h"

namespace XNet
{

const MessageID MID_NONE                   = 0x0000;
const MessageID MID_SYN                    = 0x0001;
const MessageID MID_ACK                    = 0x0002;
const MessageID MID_SEQ                    = 0x0003;
const MessageID MID_SPLIT                  = 0x0004;
const MessageID MID_PART                   = 0x0005;
const MessageID MID_PING                   = 0x0006;
const MessageID MID_PONG                   = 0x0007;
const MessageID MID_SERVER_HELLO           = 0x0008;
const MessageID MID_CLIENT_HELLO           = 0x0009;
const MessageID MID_SERVER_KEY             = 0x000A;
const MessageID MID_SERVER_REJECT          = 0x000B;
const MessageID MID_CLIENT_PASSWORD        = 0x000C;
const MessageID MID_SERVER_PASSWORD_ACCEPT = 0x000D;
const MessageID MID_SERVER_PASSWORD_REJECT = 0x000E;
const MessageID MID_ORD                    = 0x000F;

const MessageID MID_TEST_HARNESS_0         = 0xFFFF;
const MessageID MID_TEST_HARNESS_1         = 0xFFFE;
const MessageID MID_TEST_HARNESS_2         = 0xFFFD;
const MessageID MID_TEST_HARNESS_3         = 0xFFFC;

}

#endif

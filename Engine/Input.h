#ifndef __apollo_input_h
#define __apollo_input_h

#include <string>
#include <Utilities/Vec2.h>

namespace Input
{

struct Event
{
public:
    enum Type
    {
        NOP,
        KEYDOWN,
        KEYUP,
        MOUSEMOVE,
        CLICK,
        RELEASE,
        SCROLL,
        QUIT
    };
    Event () : t(NOP) {}
    Event ( Type _t, std::string _object, vec2 _mouse ) : t(_t), object(_object), mouse(_mouse) {}
    Type t;
    std::string object; // contains key name in key events, undefined in mousemove, left or right or middle in click/release, and up or down in scroll
    vec2 mouse;
};

void Pump ();
Event* Next ();

}

#endif
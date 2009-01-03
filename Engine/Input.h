#ifndef __apollo_input_h
#define __apollo_input_h

#include <string>
#include <Utilities/Vec2.h>

namespace Input
{

/**
 * A single input event
 */
struct Event
{
public:
    enum Type
    {
        NOP,        //< No event
        KEYDOWN,    //< A key pressed
        KEYUP,      //< A key released
        MOUSEMOVE,  //< The mouse moved
        CLICK,      //< A mouse button pressed
        RELEASE,    //< A mouse button released
        SCROLL,     //< The scroll wheel scrolled
        QUIT        //< Operating system wants app to quit
    };
    /**
     * Blank constructor
     */
    Event () : type(NOP) {}
    /**
     * Constructor with data
     */
    Event ( Type _t, std::string _object, vec2 _mouse ) : type(_t), object(_object), mouse(_mouse) {}
    /**
     * The type of event
     */
    Type type;
    /**
     * The object.
     *
     * For a KEYDOWN or KEYUP event, this contains the name of the key.
     * For a CLICK or RELEASE event, this contains the name of the mouse button.
     * For a SCROLL event, this contains either "up" or "down"
     * For a NOP, MOUSEMOVE or QUIT event, the contents are undefined
     */
    std::string object; // contains key name in key events, undefined in mousemove, left or right or middle in click/release, and up or down in scroll
    /**
     * The position of the mouse
     */
    vec2 mouse;
};

/**
 * Fetches all events from the operating system
 */
void Pump ();
/**
 * Fetches the next event in the queue
 * @return A pointer to an Event. Do not delete this. The value is only defined until the next call to Input::Next
 */
Event* Next ();

}

#endif
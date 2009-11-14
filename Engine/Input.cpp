#include "Input.h"

#include <SDL/SDL.h>
#include <SDL/SDL_OpenGL.h>

#include <queue>

namespace Input
{

namespace Internal
{

std::string MapKey ( SDLKey k )
{
	switch (k)
	{
#define KEYCASE(sym, string) case SDLK_ ## sym: return string
#define DIRECTCASE(sym) KEYCASE(sym, #sym)
		DIRECTCASE(a);
		DIRECTCASE(b);
		DIRECTCASE(c);
		DIRECTCASE(d);
		DIRECTCASE(e);
		DIRECTCASE(f);
		DIRECTCASE(g);
		DIRECTCASE(h);
		DIRECTCASE(i);
		DIRECTCASE(j);
		DIRECTCASE(k);
		DIRECTCASE(l);
		DIRECTCASE(m);
		DIRECTCASE(n);
		DIRECTCASE(o);
		DIRECTCASE(p);
		DIRECTCASE(q);
		DIRECTCASE(r);
		DIRECTCASE(s);
		DIRECTCASE(t);
		DIRECTCASE(u);
		DIRECTCASE(v);
		DIRECTCASE(w);
		DIRECTCASE(x);
		DIRECTCASE(y);
		DIRECTCASE(z);
		DIRECTCASE(0);
		DIRECTCASE(1);
		DIRECTCASE(2);
		DIRECTCASE(3);
		DIRECTCASE(4);
		DIRECTCASE(5);
		DIRECTCASE(6);
		DIRECTCASE(7);
		DIRECTCASE(8);
		DIRECTCASE(9);
		DIRECTCASE(F1);
		DIRECTCASE(F2);
		DIRECTCASE(F3);
		DIRECTCASE(F4);
		DIRECTCASE(F5);
		DIRECTCASE(F6);
		DIRECTCASE(F7);
		DIRECTCASE(F8);
		DIRECTCASE(F9);
		DIRECTCASE(F10);
		DIRECTCASE(F11);
		DIRECTCASE(F12);
		DIRECTCASE(KP0);
		DIRECTCASE(KP1);
		DIRECTCASE(KP2);
		DIRECTCASE(KP3);
		DIRECTCASE(KP4);
		DIRECTCASE(KP5);
		DIRECTCASE(KP6);
		DIRECTCASE(KP7);
		DIRECTCASE(KP8);
		DIRECTCASE(KP9);
		KEYCASE(BACKSPACE, "backspace");
		KEYCASE(TAB, "tab");
		KEYCASE(RETURN, "return");
		KEYCASE(ESCAPE, "escape");
		KEYCASE(SPACE, " ");
		KEYCASE(QUOTE, "\'");
		KEYCASE(LEFTPAREN, "(");
		KEYCASE(RIGHTPAREN, ")");
		KEYCASE(ASTERISK, "*");
		KEYCASE(PLUS, "+");
		KEYCASE(COMMA, ",");
		KEYCASE(MINUS, "-");
		KEYCASE(PERIOD, ".");
		KEYCASE(SLASH, "/");
		KEYCASE(COLON, ":");
		KEYCASE(SEMICOLON, ";");
		KEYCASE(AT, "at_sign");
		KEYCASE(LESS, "<");
		KEYCASE(EQUALS, "=");
		KEYCASE(GREATER, ">");
		KEYCASE(QUESTION, "?");
		KEYCASE(LEFTBRACKET, "[");
		KEYCASE(RIGHTBRACKET, "]");
		KEYCASE(BACKSLASH, "backslash");
		KEYCASE(CARET, "^");
		KEYCASE(UNDERSCORE, "_");
		KEYCASE(LEFT, "left");
		KEYCASE(RIGHT, "right");
		KEYCASE(UP, "up");
		KEYCASE(DOWN, "down");
		KEYCASE(KP_PERIOD, "KPperiod");
		KEYCASE(KP_DIVIDE, "KPdivide");
		KEYCASE(KP_MULTIPLY, "KPmultiply");
		KEYCASE(KP_MINUS, "KPminus");
		KEYCASE(KP_PLUS, "KPplus");
		KEYCASE(KP_ENTER, "KPenter");
		KEYCASE(KP_EQUALS, "KPequals");
		KEYCASE(INSERT, "ins");
		KEYCASE(HOME, "home");
		KEYCASE(END, "end");
		KEYCASE(PAGEUP, "pgup");
		KEYCASE(PAGEDOWN, "pgdn");
		KEYCASE(DELETE, "del");
		//modifier keys
		KEYCASE(CAPSLOCK, "Mcaps");
		KEYCASE(RSHIFT, "MshiftR");
		KEYCASE(LSHIFT, "MshiftL");
		KEYCASE(RCTRL, "MctrlR");
		KEYCASE(LCTRL, "MctrlL");
		KEYCASE(RALT, "MaltR");
		KEYCASE(LALT, "MaltL");
		KEYCASE(RMETA, "MmetaR");
		KEYCASE(LMETA, "MmetaL");
	}
	return "unhandled";
}

std::queue<Event*> events;
Event* currentEvent = NULL;
vec2 mousePosition;
double xdest = 0.0;
double ydest = 0.0;
double zdest = 0.0;
bool lmbPressed = false;

void UpdateMouse ( Sint16 px, Sint16 py )
{
    SDL_Surface* screen = SDL_GetVideoSurface();
    mousePosition.X() = float(px) / float(screen->w);
    mousePosition.Y() = 1.0f - (float(py) / float(screen->h));
}

std::string MouseButtonName ( Uint32 button )
{
	switch (button)
	{
		case SDL_BUTTON_LEFT:
			return "left";
			break;
		case SDL_BUTTON_MIDDLE:
			return "middle";
			break;
		case SDL_BUTTON_RIGHT:
			return "right";
			break;
	}
	return "unknown";
}

}

using namespace Internal;

void Pump ()
{
    SDL_Event evt;
    while (SDL_PollEvent(&evt))
    {
        switch (evt.type)
        {
            case SDL_KEYDOWN:
                events.push(new Event(Event::KEYDOWN, MapKey(evt.key.keysym.sym), mousePosition));
                break;
            case SDL_KEYUP:
                events.push(new Event(Event::KEYUP, MapKey(evt.key.keysym.sym), mousePosition));
                break;
            case SDL_QUIT:
                events.push(new Event(Event::QUIT, "", mousePosition));
                break;
            case SDL_MOUSEMOTION:
            	UpdateMouse(evt.button.x, evt.button.y);
            	break;
			case SDL_MOUSEBUTTONDOWN:
				UpdateMouse(evt.button.x, evt.button.y);
				events.push(new Event(Event::CLICK, MouseButtonName(evt.button.button), mousePosition));
				break;
			case SDL_MOUSEBUTTONUP:
				UpdateMouse(evt.button.x, evt.button.y);
				events.push(new Event(Event::RELEASE, MouseButtonName(evt.button.button), mousePosition));
				break;
        }
    }
}

Event* Next ()
{
    if (currentEvent)
        delete currentEvent;
    if (events.empty())
    {
        currentEvent = NULL;
        return NULL;
    }
    else
    {
        currentEvent = events.front();
        events.pop();
        return currentEvent;
    }
}

vec2 MousePosition ()
{
	return mousePosition;
}

}

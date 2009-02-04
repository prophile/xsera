#ifdef WIN32
#include "stdafx.h"
#endif

#include "Input.h"
#ifdef WIN32
#include "SDL.h"
#else
#include <SDL/SDL.h>
#endif
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
		KEYCASE(TAB, "tab");
		KEYCASE(RETURN, "return");
		KEYCASE(ESCAPE, "escape");
		KEYCASE(SPACE, " ");
		KEYCASE(LEFT, "arrow_left");
		KEYCASE(RIGHT, "arrow_right");
		KEYCASE(UP, "arrow_up");
		KEYCASE(DOWN, "arrow_down");
		KEYCASE(PLUS, "plus");
		KEYCASE(MINUS, "minus");
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
    mousePosition.X() = screen->w / float(px);
    mousePosition.Y() = 1.0f - (screen->h / float(py));
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
                UpdateMouse(evt.motion.x, evt.motion.y);
                events.push(new Event(Event::MOUSEMOVE, "", mousePosition));
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

}

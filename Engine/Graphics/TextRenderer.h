#ifndef __apollo_graphics_text_renderer_h
#define __apollo_graphics_text_renderer_h

#include <string>
#ifdef WIN32
#include <gl/gl.h>
#include <SDL/SDL_ttf.h>
#else
#include <OpenGL/gl.h>
#include <SDL_ttf/SDL_ttf.h>
#endif
#include "Utilities/Vec2.h"

namespace Graphics
{

namespace TextRenderer
{

TTF_Font* GetFont ( const std::string& name, int size );
vec2 TextDimensions ( const std::string& font, const std::string& text, int size );
GLuint TextObject ( const std::string& font, const std::string& text, int size );
void Prune ();
void Flush ();

}

}

#endif
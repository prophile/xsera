#ifndef __xsera_graphics_graphics_h
#define __xsera_graphics_graphics_h

#include <string>
#include "Utilities/Vec2.h"
#include "Utilities/Colour.h"

namespace Graphics
{

void Init ( int w, int h, bool fullscreen );

vec2 SpriteDimensions ( const std::string& sheetname, int sheet_x, int sheet_y );
void DrawSprite ( const std::string& sheetname, int sheet_x, int sheet_y, vec2 location, vec2 size, float rotation );
inline void DrawImage ( const std::string& imageName, vec2 location, vec2 size )
	{ DrawSprite("+" + imageName, 0, 0, location, size, 0.0f); }
void DrawText ( const std::string& text, const std::string& font, vec2 location, float height, colour col, float rotation );
void DrawLine ( vec2 coordinate1, vec2 coordinate2, float width, colour col );
void DrawCircle ( vec2 centre, float radius, float width, colour col );
void DrawParticles ( const vec2* locations, unsigned int count, colour col );

void SetCamera ( vec2 corner1, vec2 corner2, float rotation );

void BeginFrame ();
void EndFrame ();

}

#endif

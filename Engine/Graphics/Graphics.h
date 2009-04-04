#ifndef __apollo_graphics_graphics_h
#define __apollo_graphics_graphics_h

#include <string>
#include "Utilities/Vec2.h"
#include "Utilities/Colour.h"

namespace Graphics
{

/**
 * Initialises the graphics subsystem
 * @param w The width of the context
 * @param h The height of the context
 * @param fullscreen Whether to make the context fullscreen
 */
void Init ( int w, int h, bool fullscreen );

/**
 * Gets the dimensions of a sprite from a sheet
 * @param sheetname The sprite sheet - all sprites on a sheet are the same size
 * @return The size of the sprites
 */
vec2 SpriteDimensions ( const std::string& sheetname );
/**
 * Draws a sprite.
 * @note For rotational sprites, pass 0 for sheet_x and sheet_y
 * @note This may be used to draw images, using a + before the name of the sprite sheet
 * @param sheetname The sprite sheet to use
 * @param sheet_x The x position on the sprite sheet
 * @param sheet_y The y position on the sprite sheet
 * @param location The location of the centre of the sprite in world coordinates
 * @param size The size of the sprite in world coordinates
 * @param rotation The rotation of the sprite, in radians
 */
void DrawSprite ( const std::string& sheetname, int sheet_x, int sheet_y, vec2 location, vec2 size, float rotation );
/**
 * Draws an image
 * @param imageName The name of the image
 * @param location The location of the centre of the image in world coordinates
 * @param size The size of the image in world coordinates
 */
inline void DrawImage ( const std::string& imageName, vec2 location, vec2 size )
	{ DrawSprite("+" + imageName, 0, 0, location, size, 0.0f); }
/**
 * Draws a string of text
 * @param text The text to draw
 * @param font The font to use
 * @param location The location of the centre of the text on-screen
 * @param height The height of the text
 * @param col The colour of the text
 * @param rotation The rotation of the text
 */
void DrawTextSDL ( const std::string& text, const std::string& font, vec2 location, float height, colour col, float rotation );
/**
 * Draws a line between two points
 * @param coordinate1 The start of the line
 * @param coordinate2 The end of the line
 * @param width The width of the line, in pixels
 * @param col The colour of the line
 */
void DrawLine ( vec2 coordinate1, vec2 coordinate2, float width, colour col );
/**
 * Draws a box
 * @param top The top side of the box
 * @param left The left side of the box
 * @param bottom The bottom side of the box
 * @param right The right side of the box
 * @param width The width of the surrounding line, in pixels (zero means no surrounding line)
 * @param col The colour of the surrounding line
 */
void DrawBox ( float top, float left, float bottom, float right, float width, colour col );
/**
 * Draws a non-filled circle
 * @param centre The position of the centre of the circle
 * @param radius The radius of the circle
 * @param width The width of the circle, in pixels
 * @param col The colour of the circle
 */
void DrawCircle ( vec2 centre, float radius, float width, colour col );
/**
 * Draws a set of particles
 * @param locations An array of locations
 * @param count The size of the locations array
 * @param col The colour of the particles
 */
void DrawParticles ( const vec2* locations, unsigned int count, colour col );
/**
 * Draws a star-field that covers the whole screen
 * @param depth The depth of the star-field, for parallax
 */
void DrawStarfield ( float depth );

/**
 * Gives the aspect ratio of the screen
 * @return Aspect ratio, defined as width/height
 */
float AspectRatio ();
/**
 * Maps a point in window coordinates to a corresponding point in the current camera
 * @param point The window point
 * @return The point in the camera
 */
vec2 MapPoint ( vec2 windowCoords );
/**
 * Checks if a circle lies entirely outside the current camera position
 * @param location The centre of the circle
 * @param radius The radius of the circle
 * @return Whether the circle is culled
 */
bool IsCulled ( vec2 location, float radius );
/**
 * Sets the camera
 * @param corner1 One corner of the camera
 * @param corner2 The other corner of the camera
 * @param rotation The camera rotation in radians
 */
void SetCamera ( vec2 corner1, vec2 corner2, float rotation );

/**
 * Begins a graphics frame
 */
void BeginFrame ();
/**
 * Ends a graphics frame
 */
void EndFrame ();

}

#endif

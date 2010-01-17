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
 * @note This may be used to draw images, using a '+' before the name of the sprite sheet
 * @param sheetname The sprite sheet to use
 * @param sheet_x The x position on the sprite sheet
 * @param sheet_y The y position on the sprite sheet
 * @param position The position of the centre of the sprite in world coordinates
 * @param size The size of the sprite in world coordinates
 * @param rotation The rotation of the sprite, in radians
 * @param col The colour of the image
 */
void DrawSprite ( const std::string& sheetname, int sheet_x, int sheet_y, vec2 position, vec2 size, float rotation, colour col );
/**
 * Draws a specific frame from spritesheet.
 * @param sheetname The sprite sheet to use
 * @param position The position of the centre of the sprite in world coordinates
 * @param size The size of the sprite in world coordinates
 * @param the index of the sprite
 * @param rotation The rotation of the sprite, in radians
 * @param col The colour of the image
 */
void DrawSpriteFrame ( const std::string& sheetname, vec2 position, vec2 size, int index, float rotation, colour col );
/**
 * Draws an image
 * @param imageName The name of the image
 * @param position The position of the centre of the image in world coordinates
 * @param size The size of the image in world coordinates
 */
inline void DrawImage ( const std::string& imageName, vec2 position, vec2 size )
	{ DrawSprite("+" + imageName, 0, 0, position, size, 0.0f, colour(1.0f, 1.0f, 1.0f, 1.0f)); }
/**
 * Draws a string of text
 * @param text The text to draw
 * @param font The font to use
 * @param justify The justification of the text (should be "left", "right", or "center")
 * @param position The position of the centre of the text on-screen
 * @param height The height of the text
 * @param col The colour of the text
 * @param rotation The rotation of the text
 */
void DrawTextSDL ( const std::string& text, const std::string& font, const char* justify, vec2 position, float height, colour col, float rotation );
/**
 * Draws a line
 * @param coordinate1 Beginning coordinates of the line
 * @param coordinate2 Ending coordinates of the line
 * @param width The width, in pixels, of the line
 * @param col The colour of the line
 */
void DrawLine ( vec2 coordinate1, vec2 coordinate2, float width, colour col );
/**
 * Draws a lightning effect
 * @param coordinate1 Beginning of the lightning
 * @param coordinate2 End of the lightning
 * @param width The width of the lightning, in pixels
 * @param chaos The chaos of the lightning
 * @param col The colour of the lightning
 * @param tailed If tailed is true, the lightning tapers down to the endpoint. If
 * tailed is false, the lightning does not taper down to the endpoint but
 * instead ends somewhere around the endpoint.
 */
void DrawLightning ( vec2 coordinate1, vec2 coordinate2, float width, float chaos, colour col, bool tailed );
/**
 * Draws a filled box
 * @param top the top bound of the box
 * @param bottom the bottom bound of the box
 * @param left the left bound of the box
 * @param right the right bound of the box
 * @param width The width of the border to the box, in pixels
 * @param col The colour of the circle
 */
void DrawBox ( float top, float left, float bottom, float right, float width, colour col );
/**
 * Draws an approximated circle
 * @param centre The location of the centre of the circle
 * @param radius The radius of the circle
 * @param width The width of the lines that compose the approximated circle
 * @param col The colour of the circle
 */	
void DrawCircle ( vec2 centre, float radius, float width, colour col );
/**
 * Draws a small triangle to represent a ship
 * @param point1 the first point of the triangle
 * @param point2 the second point of the triangle
 * @param point3 the third point of the triangle
 * @param col The colour of the triangle
 */
void DrawTriangle ( const vec2 point1, const vec2 point2, const vec2 point3, colour col );
/**
 * Draws a small diamond to represent a capital ship
 * @param top the top bound of the box
 * @param bottom the bottom bound of the box
 * @param left the left bound of the box
 * @param right the right bound of the box
 * @param col The colour of the triangle
 */
void DrawDiamond ( float top, float left, float bottom, float right, colour col );
/**
 * Draws a star-field that covers the whole screen
 * @param depth The depth of the star-field, for parallax
 */
void DrawStarfield ( float depth );
/**
 * Draws all outstanding particles
 */
void DrawParticles ();
/**
 * Clears the particles
 */
void ClearParticles ();
/**
 * Add a new particle system
 * @param name The name of the particle texture
 * @param particleCount The number of particles to add
 * @param centre The centre of the particle system
 * @param velocity The average of the particle system
 * @param velocityVariance The variation in the velocity of the particles
 * @param acceleration The acceleration of the particles
 * @param sizeFactor The factor of the original size that particles will grow to over their lifetime
 * @param lifetime The lifetime of the particles
 */
void AddParticles ( const std::string& name, unsigned long particleCount, vec2 centre, vec2 velocity, vec2 velocityVariance, vec2 acceleration, float sizeFactor, float lifetime );
/**
 * Draws a 3D object for ambient lighting
 * @param name The name of the object
 * @param centre The centre of the object
 * @param ambient The ambient colour
 * @param scale The scale of the object
 * @param angle The angle of the object
 * @param bank The bank of the object
 */
void DrawObject3DAmbient ( std::string name, vec2 centre, colour ambient, float scale, float angle, float bank = 0.0f );
/**
 * Draws a 3D object for directional lighting
 * @param centre The centre of the object
 * @param light The light colour
 * @param lightAngle The angle of the light
 * @param scale The scale of the object
 * @param angle The angle of the object
 * @param bank The bank of the object
 */
void DrawObject3DDirectional ( std::string name, vec2 centre, colour light, float lightAngle, float scale, float angle, float bank = 0.0f );
/**
 * Draws a 3D object for directional lighting
 * @param centre The centre of the object
 * @param light The light colour
 * @param lightCentre The origin of the light
 * @param lightRadius The radius of this light
 * @param scale The scale of the object
 * @param angle The angle of the object
 * @param bank The bank of the object
 */
void DrawObject3DSpot ( std::string name, vec2 centre, colour light, vec2 lightCentre, float lightRadius, float scale, float angle, float bank = 0.0f );
/**
 * Draws a 3D object for glow lighting
 * @param centre The centre of the object
 * @param glow The scale of the glow on the lighting
 * @param scale The scale of the object
 * @param angle The angle of the object
 * @param bank The bank of the object
 */
void DrawObject3DGlow ( std::string name, vec2 centre, float glow, float scale, float angle, float bank = 0.0f );

/**
 * Gives the aspect ratio of the screen
 * @return Aspect ratio, defined as width/height
 */
float AspectRatio ();
/**
 * Maps a point in window coordinates to a corresponding point in the current camera
 * @param windowCoords The point to be mapped
 * @return The point in the camera
 */
vec2 MapPoint ( vec2 windowCoords );
/**
 * Checks if a circle lies entirely outside the current camera position
 * @param position The centre of the circle
 * @param radius The radius of the circle
 * @return Whether the circle is culled
 */
bool IsCulled ( vec2 position, float radius );
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

/**
 * Begin rendering for a Warp effect
 *
 * @param magnitude The magnitude of the warp, as a value between 0 and 1.
 * @param angle The angle of the warp, as an angle in radians.
 * @param scale The scale.
 */
void BeginWarp ( float magnitude, float angle, float scale );

/**
 * End rendering of a Warp effect
 */
void EndWarp ();

}

#endif

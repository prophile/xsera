#include "Graphics.h"
#include <OpenGL/gl.h>
#include <SDL/SDL.h>
#include "SpriteSheet.h"
#include "TextRenderer.h"
#include <map>
#include "Starfield.h"
#include "Graphics.h"
#include "Utilities/Matrix2x3.h"

#define DEG2RAD(x) ((x / 180.0f) * M_PI)
#define RAD2DEG(x) ((x / M_PI) * 180.0f)

const static float circlePoints[] = {
   0.000, 1.000,
   0.098, 0.995,
   0.195, 0.981,
   0.290, 0.957,
   0.383, 0.924,
   0.471, 0.882,
   0.556, 0.831,
   0.634, 0.773,
   0.707, 0.707,
   0.773, 0.634,
   0.831, 0.556,
   0.882, 0.471,
   0.924, 0.383,
   0.957, 0.290,
   0.981, 0.195,
   0.995, 0.098,
   1.000, -0.000,
   0.995, -0.098,
   0.981, -0.195,
   0.957, -0.290,
   0.924, -0.383,
   0.882, -0.471,
   0.831, -0.556,
   0.773, -0.634,
   0.707, -0.707,
   0.634, -0.773,
   0.556, -0.831,
   0.471, -0.882,
   0.383, -0.924,
   0.290, -0.957,
   0.195, -0.981,
   0.098, -0.995,
   -0.000, -1.000,
   -0.098, -0.995,
   -0.195, -0.981,
   -0.290, -0.957,
   -0.383, -0.924,
   -0.471, -0.882,
   -0.556, -0.831,
   -0.634, -0.773,
   -0.707, -0.707,
   -0.773, -0.634,
   -0.831, -0.556,
   -0.882, -0.471,
   -0.924, -0.383,
   -0.957, -0.290,
   -0.981, -0.195,
   -0.995, -0.098,
   -1.000, 0.000,
   -0.995, 0.098,
   -0.981, 0.195,
   -0.957, 0.290,
   -0.924, 0.383,
   -0.882, 0.471,
   -0.831, 0.556,
   -0.773, 0.634,
   -0.707, 0.707,
   -0.634, 0.773,
   -0.556, 0.831,
   -0.471, 0.882,
   -0.383, 0.924,
   -0.290, 0.957,
   -0.195, 0.981,
   -0.098, 0.995,
   -0.000, 1.000};

typedef std::map<std::string, Graphics::SpriteSheet*> SheetMap;
static SheetMap spriteSheets;

namespace Graphics
{

/*
 Other files can use:
 
 namespace Matrices
 {
 
 void SetProjectionMatrix ( const matrix2x3& m );
 void SetViewMatrix ( const matrix2x3& m );
 void SetModelMatrix ( const matrix2x3& m );
 
 }
 */

namespace Matrices
{

static matrix2x3 projectionMatrix;
static matrix2x3 viewMatrix;
static matrix2x3 modelMatrix;

static void LoadMatrix ( const matrix2x3& m )
{
	GLfloat array[16];
	m.FillOpenGLMatrix(array);
	glLoadMatrixf(array);
}

void SetProjectionMatrix ( const matrix2x3& m )
{
	projectionMatrix = m;
	glMatrixMode(GL_PROJECTION);
	LoadMatrix(projectionMatrix);
	glMatrixMode(GL_MODELVIEW);
}

void SetViewMatrix ( const matrix2x3& m )
{
	viewMatrix = m;
}

// the state is only guaranteed after a SetModelMatrix call
void SetModelMatrix ( const matrix2x3& m )
{
	modelMatrix = m;
	LoadMatrix(viewMatrix);
	//LoadMatrix(viewMatrix * modelMatrix);
}

}

void Init ( int w, int h, bool fullscreen )
{
	SDL_InitSubSystem ( SDL_INIT_VIDEO );
	SDL_GL_SetAttribute ( SDL_GL_RED_SIZE, 8 );
	SDL_GL_SetAttribute ( SDL_GL_BLUE_SIZE, 8 );
	SDL_GL_SetAttribute ( SDL_GL_GREEN_SIZE, 8 );
	SDL_GL_SetAttribute ( SDL_GL_ALPHA_SIZE, 0 );
	SDL_GL_SetAttribute ( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_GL_SetAttribute ( SDL_GL_DEPTH_SIZE, 0 );
	SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLESAMPLES, 4 );
	SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLEBUFFERS, 1 );
	SDL_GL_SetAttribute ( SDL_GL_SWAP_CONTROL, 1 );
	Uint32 flags = SDL_OPENGL;
	if (fullscreen)
		flags |= SDL_FULLSCREEN;
	if (!SDL_SetVideoMode(w, h, 0, flags))
	{
		SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLESAMPLES, 0 );
		SDL_GL_SetAttribute ( SDL_GL_MULTISAMPLEBUFFERS, 0 );
		printf("[GRAPHICS] Warning: card does not support FSAA\n");
		if (!SDL_SetVideoMode(w, h, 0, flags))
		{
			printf("[GRAPHICS] Warning: card does not support normal video options\n");
			SDL_GL_SetAttribute ( SDL_GL_RED_SIZE, 5 );
			SDL_GL_SetAttribute ( SDL_GL_GREEN_SIZE, 5 );
			SDL_GL_SetAttribute ( SDL_GL_BLUE_SIZE, 5 );
			if (!SDL_SetVideoMode(w, h, 0, flags))
			{
				printf("[GRAPHICS] Error: bad graphics driver!\n");
				exit(1);
			}
		}
	}
	
	glClear ( GL_COLOR_BUFFER_BIT );
	
	glEnable ( GL_BLEND );
	glBlendFunc ( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	glEnable ( GL_LINE_SMOOTH );
	glEnable ( GL_POINT_SMOOTH );
	
	glHint ( GL_LINE_SMOOTH_HINT, GL_NICEST );
	glHint ( GL_POINT_SMOOTH_HINT, GL_NICEST );
#ifdef __MACH__
    glHint ( GL_TRANSFORM_HINT_APPLE, GL_FASTEST );
#endif
	
	glEnableClientState ( GL_VERTEX_ARRAY );
}

static bool texturingEnabled = false;

static void EnableTexturing ()
{
	if (!texturingEnabled)
	{
		glEnable ( GL_TEXTURE_RECTANGLE_ARB );
		glEnableClientState ( GL_TEXTURE_COORD_ARRAY );
		texturingEnabled = true;
	}
}

static void DisableTexturing ()
{
	if (texturingEnabled)
	{
		glDisable ( GL_TEXTURE_RECTANGLE_ARB );
		glDisableClientState ( GL_TEXTURE_COORD_ARRAY );
		texturingEnabled = false;
	}
}

static bool blendingEnabled = true;

static void EnableBlending ()
{
	if (!blendingEnabled)
	{
		glEnable(GL_BLEND);
		blendingEnabled = true;
	}
}

static void DisableBlending ()
{
	if (blendingEnabled)
	{
		glDisable(GL_BLEND);
		blendingEnabled = false;
	}
}

static void SetColour ( const colour& col )
{
	if (sizeof(col) == sizeof(float) * 4)
	{
		glColor4fv((const GLfloat*)&col);
	}
	else
	{
		glColor4f(col.red(), col.green(), col.blue(), col.alpha());
	}
}

static void ClearColour ()
{
	const uint32_t white = 0xFFFFFFFF;
	glColor4ubv((const GLubyte*)&white);
}

vec2 SpriteDimensions ( const std::string& sheetname )
{
	SpriteSheet* sheet;
	SheetMap::iterator iter = spriteSheets.find(sheetname);
	if (iter == spriteSheets.end())
	{
		// load it
		sheet = new SpriteSheet(sheetname);
		spriteSheets[sheetname] = sheet;
	}
	else
	{
		sheet = iter->second;
	}
	assert(sheet);
	return vec2(sheet->TileSizeX(), sheet->TileSizeY());
}

void DrawSprite ( const std::string& sheetname, int sheet_x, int sheet_y, vec2 location, vec2 size, float rotation )
{
	EnableTexturing();
	EnableBlending();
	ClearColour();
	SpriteSheet* sheet;
	SheetMap::iterator iter = spriteSheets.find(sheetname);
	if (iter == spriteSheets.end())
	{
		// load it
		sheet = new SpriteSheet(sheetname);
		spriteSheets[sheetname] = sheet;
	}
	else
	{
		sheet = iter->second;
	}
	Matrices::SetViewMatrix(matrix2x3::Translate(location));
	Matrices::SetModelMatrix(matrix2x3::Identity());
	if (sheet->IsRotational())
	{
		assert(sheet_x == 0);
		assert(sheet_y == 0);
		sheet->DrawRotation(size, rotation);
	}
	else
	{
		glRotatef(RAD2DEG(rotation), 0.0f, 0.0f, 1.0f);
		sheet->Draw(sheet_x, sheet_y, size);
	}
}

void DrawText ( const std::string& text, const std::string& font, vec2 location, float height, colour col, float rotation )
{
	// TODO
	EnableTexturing();
	EnableBlending();
	SetColour(col);
	GLuint texID = TextRenderer::TextObject(font, text);
	Matrices::SetViewMatrix(matrix2x3::Translate(location));
	Matrices::SetModelMatrix(matrix2x3::Rotation(rotation));
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texID);
	vec2 dims = TextRenderer::TextDimensions(font, text);
	vec2 halfSize = (dims * (height / dims.Y())) * 0.5f;
	GLfloat textureArray[] = { 0.0f, 0.0f, dims.X(), 0.0f, dims.X(), dims.Y(), 0.0f, dims.Y() };
	GLfloat vertexArray[] = { -halfSize.X(), halfSize.Y(), halfSize.X(), halfSize.Y(),
	                          halfSize.X(), -halfSize.Y(), -halfSize.X(), -halfSize.Y() };
	glVertexPointer(2, GL_FLOAT, 0, vertexArray);
	glTexCoordPointer(2, GL_FLOAT, 0, textureArray);
	glDrawArrays(GL_QUADS, 0, 4);
}

void DrawLine ( vec2 coordinate1, vec2 coordinate2, float width, colour col )
{
	DisableTexturing();
	if (col.alpha() < 1.0f)
	{
		DisableBlending();
	}
	else
	{
		EnableBlending();
	}
	glLineWidth(width);
	Matrices::SetViewMatrix(matrix2x3::Identity());
	Matrices::SetModelMatrix(matrix2x3::Identity());
	SetColour(col);
	float vertices[4] = { coordinate1.X(), coordinate1.Y(),
	                      coordinate2.X(), coordinate2.Y() };
	glVertexPointer ( 2, GL_FLOAT, 0, vertices );
	glDrawArrays ( GL_LINES, 0, 2 );
}

void DrawCircle ( vec2 centre, float radius, float width, colour col )
{
	DisableTexturing();
	if (col.alpha() < 1.0f)
	{
		DisableBlending();
	}
	else
	{
		EnableBlending();
	}
	glLineWidth(width);
	Matrices::SetViewMatrix(matrix2x3::Translate(centre));
	Matrices::SetModelMatrix(matrix2x3::Scale(radius));
	SetColour ( col );
	glVertexPointer(2, GL_FLOAT, 0, circlePoints);
	glDrawArrays(GL_LINE_LOOP, 0, sizeof(circlePoints) / (2 * sizeof(float)));
}

void DrawParticles ( const vec2* locations, unsigned int count, colour col )
{
	DisableTexturing();
	if (col.alpha() < 1.0f)
	{
		DisableBlending();
	}
	else
	{
		EnableBlending();
	}
	Matrices::SetViewMatrix(matrix2x3::Identity());
	Matrices::SetModelMatrix(matrix2x3::Identity());
	glVertexPointer ( 2, GL_FLOAT, 0, locations );
	SetColour(col);
	glDrawArrays ( GL_POINTS, 0, count );
}

static Starfield* sfld = NULL;

void DrawStarfield ( float depth )
{
	if (!sfld)
	{
		sfld = new Starfield;
	}
	EnableTexturing();
	DisableBlending();
	ClearColour();
	Matrices::SetViewMatrix(matrix2x3::Identity());
	Matrices::SetModelMatrix(matrix2x3::Identity());
	sfld->Draw(depth, vec2(0.0f, 0.0f));
}

static vec2 cameraCorner1;
static vec2 cameraCorner2;
static float cameraRotation;

bool IsCulled ( vec2 location, float radius )
{
	if ((location.X() + radius) < cameraCorner1.X())
		return true;
	if ((location.X() - radius) > cameraCorner2.X())
		return true;
	if ((location.Y() + radius) < cameraCorner1.Y())
		return true;
	if ((location.Y() - radius) > cameraCorner2.Y())
		return true;
	return false;
}

void SetCamera ( vec2 corner1, vec2 corner2, float rotation )
{
	matrix2x3 projection ( matrix2x3::Ortho(corner1.X(), corner2.X(), corner1.Y(), corner2.Y()) );
	if (fabs(rotation) > 0.00004f)
		projection *= matrix2x3::Rotation(rotation);
	Matrices::SetProjectionMatrix(projection);
	cameraCorner1 = corner1;
	cameraCorner2 = corner2;
}

void BeginFrame ()
{
	glClear(GL_COLOR_BUFFER_BIT);
	Matrices::SetViewMatrix(matrix2x3::Identity());
	Matrices::SetModelMatrix(matrix2x3::Identity());
}

void EndFrame ()
{
#ifdef __MACH__
    glSwapAPPLE();
#else
	SDL_GL_SwapBuffers();
#endif
	TextRenderer::Prune();
}

}

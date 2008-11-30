#include "Starfield.h"
#include <SDL_image/SDL_image.h>
#include <string>
#include <vector>
#include "TinyXML/tinyxml.h"
#include "Utilities/ResourceManager.h"

namespace Graphics
{

namespace StarfieldBuilding
{

std::vector<std::pair<SDL_Surface*, float> > starTypes;

void InitStars ()
{
	if (starTypes.empty())
	{
		// load the XML config file
		SDL_RWops* rwops = ResourceManager::OpenFile("Stars/Starfield.xml");
		assert(rwops);
		size_t len;
		char* ptr = (char*)ResourceManager::ReadFull(&len, rwops, 1);
		assert(ptr);
		TiXmlDocument xmlDoc;
		xmlDoc.Parse(ptr);
		assert(!xmlDoc.Error());
		TiXmlElement* root = xmlDoc.RootElement();
		assert(root);
		TiXmlElement* child = root->FirstChildElement("star");
		do
		{
			const char* starName = child->GetText();
			assert(starName);
			double starFrequency = 0.2f;
			child->Attribute("frequency", &starFrequency);
			SDL_RWops* rwops = ResourceManager::OpenFile(std::string("Stars/") + starName + ".png");
			assert(rwops);
			SDL_Surface* surface = IMG_Load_RW(rwops, 1);
			assert(surface);
			starTypes.push_back(std::make_pair(surface, (float)starFrequency));
		} while (child = child->NextSiblingElement());
	}
}

static SDL_Surface* surfaceTexture = NULL;

void CreateStarfieldTexture ()
{
	void* base = calloc(4, STARFIELD_WIDTH * STARFIELD_HEIGHT);
	surfaceTexture = SDL_CreateRGBSurfaceFrom(base, STARFIELD_WIDTH, STARFIELD_HEIGHT, 24, STARFIELD_WIDTH * 3, 0xFF0000, 0x00FF00, 0x0000FF, 0);
}

void UploadStarfieldTexture ()
{
	glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGB, STARFIELD_WIDTH, STARFIELD_HEIGHT, 0, SDL_BYTEORDER == SDL_BIG_ENDIAN ? GL_BGR : GL_RGB, GL_UNSIGNED_BYTE, surfaceTexture->pixels);
	SDL_FreeSurface(surfaceTexture);
	surfaceTexture = NULL;
}

void SpatterStars ( SDL_Surface* source, float freq );

void SpatterAllStars ( )
{
	for (std::vector<std::pair<SDL_Surface*, float> >::iterator iter = starTypes.begin(); iter != starTypes.end(); iter++)
	{
		SpatterStars(iter->first, iter->second);
	}
}

void SpatterStars ( SDL_Surface* source, float freq )
{
	int count = freq * (STARFIELD_WIDTH);
	count += (rand() % 3 - 1);
	if (count < 0) count = 0;
	int w_border = source->w / 2;
	int h_border = source->h / 2;
	int min_x = w_border;
	int max_x = STARFIELD_WIDTH - w_border;
	int min_y = h_border;
	int max_y = STARFIELD_HEIGHT - h_border;
	int x_w = max_x - min_x;
	int y_w = max_y - min_y;
	assert(w_border >= 0);
	assert(h_border >= 0);
	assert(min_x >= 0);
	assert(max_x >= 0);
	assert(min_y >= 0);
	assert(max_y >= 0);
	assert(x_w > 0);
	assert(y_w > 0);
	for (int i = 0; i < count; i++)
	{
		int x, y;
		x = (rand() % x_w) + min_x;
		y = (rand() % y_w) + min_y;
		assert(x >= 0);
		assert(y >= 0);
		assert(x < STARFIELD_WIDTH);
		assert(y < STARFIELD_HEIGHT);
		SDL_Rect dstRect;
		dstRect.x = (x - w_border);
		dstRect.y = (y - h_border);
		dstRect.w = w_border * 2;
		dstRect.h = h_border * 2;
		//glTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, x - w_border, y - w_border, source->w, source->h, SDL_BYTEORDER == SDL_BIG_ENDIAN ? GL_RGBA : GL_ABGR_EXT, GL_UNSIGNED_BYTE, source->pixels);
		SDL_BlitSurface(source, NULL, surfaceTexture, &dstRect);
		//printf("Blitted star of dimensions (%d, %d) at position (%d, %d)\n", source->w, source->h, x, y);
	}
}

}

using namespace StarfieldBuilding;

Starfield::Starfield ()
{
	glGenTextures(1, &texID);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texID);
	InitStars();
	CreateStarfieldTexture();
	SpatterAllStars();
	UploadStarfieldTexture();
}

Starfield::~Starfield ()
{
	glDeleteTextures(1, &texID);
}

vec2 Starfield::Dimensions ( float depth )
{
	(void)depth;
	return vec2(STARFIELD_WIDTH, STARFIELD_HEIGHT);
}

const static float starfieldScale = 1.6f;
const static float starfieldTexCoords[] =
	{ 0.0f, 0.0f,
	  (float)STARFIELD_WIDTH, 0.0f,
	  (float)STARFIELD_WIDTH, (float)STARFIELD_HEIGHT,
	  0.0f, (float)STARFIELD_HEIGHT };
const static float starfieldVertices[] =
	{ -(float)STARFIELD_WIDTH * starfieldScale, -(float)STARFIELD_HEIGHT * starfieldScale,
	   (float)STARFIELD_WIDTH * starfieldScale, -(float)STARFIELD_HEIGHT * starfieldScale,
	   (float)STARFIELD_WIDTH * starfieldScale, (float)STARFIELD_HEIGHT * starfieldScale,
	   -(float)STARFIELD_WIDTH * starfieldScale, (float)STARFIELD_HEIGHT * starfieldScale };

void Starfield::Draw ( float depth, vec2 centre )
{
	(void)depth;
	glPushMatrix();
	glTranslatef(centre.X(), centre.Y(), 0.0f);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texID);
	
	glVertexPointer(2, GL_FLOAT, 0, starfieldVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, starfieldTexCoords);
	glDrawArrays(GL_QUADS, 0, 4);
	
	glPopMatrix();
}

}

#ifdef WIN32
#define _USE_MATH_DEFINES
#include <cmath>
#endif

#include "Apollo.h"
#include "SpriteSheet.h"
#include "Utilities/ResourceManager.h"
#include "TinyXML/tinyxml.h"
#include "Logging.h"
#include "ImageLoader.h"

namespace Graphics
{

void SpriteSheet::MakeResident ()
{
	texID = ImageLoader::CreateTexture(surface, false);
}

SpriteSheet::SpriteSheet ( const std::string& name )
: texID(0)
{
	std::string configPath, imagePath;
	if (name[0] == '+')
	{
		configPath = "";
		imagePath = "Images/" + name.substr(1, std::string::npos) + ".png";
	}
	else
	{
		if (Preferences::Get("Sprite/Original", "blah") == "blah")	//[ALISTAIR]: Why doesn't this work?
		{
			configPath = "NewResources/Sprites/" + name + ".xml";
			imagePath = "NewResources/Sprites/" + name + ".png";
			SDL_RWops* imageRWOps = ResourceManager::OpenFile(imagePath);
			if (!imageRWOps)
			{
				configPath = "Sprites/" + name + ".xml";
				imagePath = "Sprites/" + name + ".png";
			}
		} else
		{
			configPath = "Sprites/" + name + ".xml";
			imagePath = "Sprites/" + name + ".png";
		}
	}
	SDL_RWops* configRWOps = ResourceManager::OpenFile(configPath);
	surface = ImageLoader::LoadImage(imagePath);
	if (!surface)
	{
        // TODO: make this work gracefully
        LOG("Graphics::SpriteSheet", LOG_ERROR, "Failed to load image: %s", name.c_str());
		abort();
		delete configRWOps;
	}
	if (configRWOps)
	{
		// load config
		size_t confLength;
		char* confData = (char*)ResourceManager::ReadFull(&confLength, configRWOps, 1);
		TiXmlDocument* xmlDoc = new TiXmlDocument(name + ".xml");
		confData = (char*)realloc(confData, confLength + 1);
		confData[confLength] = '\0';
		xmlDoc->Parse(confData);
		free(confData);
		if (xmlDoc->Error())
		{
            LOG("Graphics::SpriteSheet", LOG_ERROR, "XML error: %s", xmlDoc->ErrorDesc());
			abort();
		}
		TiXmlElement* root = xmlDoc->RootElement();
		assert(root);
		TiXmlElement* dimensions = root->FirstChild("dimensions")->ToElement();
		assert(dimensions);
		TiXmlElement* scale = root->FirstChild("scale")->ToElement();
		int rc;
		if (scale)
		{
			rc = scale->QueryFloatAttribute("factor", &scaleFactor);
			if (rc != TIXML_SUCCESS)
				scaleFactor = 1.0f;
		}
		else
		{
			scaleFactor = 1.0f;
		}
		rc = dimensions->QueryIntAttribute("x", &sheetTilesX);
		assert(rc == TIXML_SUCCESS);
		rc = dimensions->QueryIntAttribute("y", &sheetTilesY);
		assert(rc == TIXML_SUCCESS);
		assert(sheetTilesX > 0);
		assert(sheetTilesY > 0);
		tileSizeX = surface->w / sheetTilesX;
		tileSizeY = surface->h / sheetTilesY;
		if (root->FirstChild("rotational"))
			rotational = true;
		else
			rotational = false;
		delete xmlDoc;
	}
	else
	{
		// assume it's just one sprite
		sheetTilesX = 1;
		sheetTilesY = 1;
		rotational = false;
		tileSizeX = surface->w;
		tileSizeY = surface->h;
		scaleFactor = 1.0f;
	}
}

SpriteSheet::~SpriteSheet ()
{
	if (texID)
		glDeleteTextures(1, &texID);
	SDL_FreeSurface(surface);
}

void SpriteSheet::Draw ( int x, int y, const vec2& size )
{
	vec2 halfSize = size / 2.0f;
	if (texID)
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texID);
	else
		MakeResident();
	if (scaleFactor <= 0)
	{
		printf("Trouble with scaleFactor value.");
		abort();
	}
	float vx = halfSize.X() * scaleFactor, vy = halfSize.Y() * scaleFactor;
	GLfloat vertices[] = { -vx, -vy, vx, -vy, vx, vy, -vx, vy };
	float texBLX, texBLY, texWidth = tileSizeX, texHeight = tileSizeY;
	texBLX = (tileSizeX * x);
	texBLY = (tileSizeY * y);
	GLfloat texCoords[] = { texBLX, texBLY + texHeight,
		texBLX + texWidth, texBLY + texHeight,
		texBLX + texWidth, texBLY,
	texBLX, texBLY };
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_QUADS, 0, 4);
}

/* [ADAMLATER]
void SpriteSheet::DrawTile ( int x, int y, float vx, float vy, const vec2& size )
{
	vec2 halfSize = size / 2.0f;
	if (texID)
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texID);
	else
		MakeResident();
	if (scaleFactor <= 0)
	{
		printf("Trouble with scaleFactor value.");
		abort();
	}
	GLfloat vertices[] = { -vx, -vy, vx, -vy, vx, vy, -vx, vy };
	float texBLX, texBLY, texWidth = tileSizeX, texHeight = tileSizeY;
	texBLX = (tileSizeX * x);
	texBLY = (tileSizeY * y);
	GLfloat texCoords[] = { texBLX, texBLY + texHeight,
		texBLX + texWidth, texBLY + texHeight,
		texBLX + texWidth, texBLY,
	texBLX, texBLY };
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_QUADS, 0, 4);
}*/

void SpriteSheet::DrawRotation ( const vec2& size, float angle )
{
	int numObjects = sheetTilesX * sheetTilesY;
	angle += (M_PI / float(numObjects));
	angle -= M_PI / 2.0;
	if (angle < 0.0)
		angle += 2.0*M_PI;
	// angle is now 0 = north, 2π = north, anticlockwise
	angle /= 2.0*M_PI;
	// angle is now 0=north, 1=north, anticlockwise
	angle = 1.0f - angle;
	int index = (int)((angle - 0.00001f) * numObjects) + 1;
	if (index == sheetTilesX * sheetTilesY)
		index = 0;
	int x = index % sheetTilesX;
	int y = (index - x) / sheetTilesX;
	Draw(x, y, size);
}

}

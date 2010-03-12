#include "TextRenderer.h"

#ifdef WIN32
#include <gl/gl.h>
#include <SDL/SDL_ttf.h>
#else
#include <OpenGL/gl.h>
#include <SDL_ttf/SDL_ttf.h>
#endif

#include <SDL/SDL.h>

#include "Apollo.h"
#include <map>
#include "Utilities/ResourceManager.h"
#include "Utilities/GameTime.h"
#include "Logging.h"

namespace
{

uint32_t Hash ( const std::string& input )
{
	uint32_t base = 0xBAADF00D;
	uint32_t a = 0, b = 0x8D470010;
	const unsigned char* data = (const unsigned char*)input.data();
	size_t len = input.length();
	for (size_t i = 0; i < len; i++)
	{
		a <<= 5;
		b ^= data[i];
		a ^= b;
		base ^= a;
		a += b;
		if (i != 0)
			a ^= (data[i - 1] << 16);
	}
	return b ^ a;
}

struct TextEntry
{
	uint32_t hash;
	SDL_Surface* surface;
	GLuint texID;
	float lastUse;
	~TextEntry ()
	{
		SDL_FreeSurface(surface);
		if (texID)
			glDeleteTextures(1, &texID);
	}
};

typedef std::map<uint32_t, TextEntry*> TextEntryTable;
TextEntryTable textEntries;

std::map<std::string, TTF_Font*> fonts;
#define DEFAULT_FONT "prototype"

static bool ttf_initted = false;

// [ADAM, ALISTAIR]: this is where size affects things... how would we figure out how to correct the size?
TTF_Font* GetFont ( const std::string& name, float size )
{
	if (!ttf_initted)
	{
		TTF_Init();
		ttf_initted = true;
	}
	std::map<std::string, TTF_Font*>::iterator iter = fonts.find(name);
	if (iter != fonts.end())
	{
		return iter->second;
	}
	SDL_RWops* rwops = ResourceManager::OpenFile("Fonts/" + name + ".ttf");
	TTF_Font* loadedFont;
	if (!rwops)
		goto loadFail;
	loadedFont = TTF_OpenFontRW(rwops, 1, size);
	if (!loadedFont)
		goto loadFail;
	fonts[name] = loadedFont;
	return loadedFont;
loadFail:
	if (name == DEFAULT_FONT)
	{
        LOG("Graphics::TextRenderer", LOG_ERROR, "Unable to load default font: %s", DEFAULT_FONT);
		exit(1);
	}
	loadedFont = GetFont(DEFAULT_FONT, size);
	fonts[name] = loadedFont;
	LOG("Graphics::TextRenderer", LOG_WARNING, "Unable to load font '%s', defaulted to '%s'", name.c_str(), DEFAULT_FONT);
	return loadedFont;
}

TextEntry* GetEntry ( const std::string& font, const std::string& text, float size )
{
	uint32_t hash = Hash(font + "@" + text);
	TextEntryTable::iterator iter;
	iter = textEntries.find(hash);
	if (iter != textEntries.end())
	{
		return iter->second;
	}
	else
	{
		TextEntry* newEntry = new TextEntry;
		newEntry->hash = hash;
		newEntry->texID = 0;
		newEntry->surface = NULL;
		newEntry->lastUse = 0.0f;
		TTF_Font* fontObject = GetFont(font, size);
		const SDL_Color fg = { 0xFF, 0xFF, 0xFF, 0xFF };
		newEntry->surface = TTF_RenderUTF8_Blended(fontObject, text.c_str(), fg);
		assert(newEntry->surface);
		// generate textures
		glGenTextures(1, &(newEntry->texID));
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, newEntry->texID);
#ifdef __BIG_ENDIAN__
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, newEntry->surface->w, newEntry->surface->h, 0, GL_ABGR_EXT, GL_UNSIGNED_BYTE, newEntry->surface->pixels);
#else
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, newEntry->surface->w, newEntry->surface->h, 0, GL_RGBA, GL_UNSIGNED_BYTE, newEntry->surface->pixels);
#endif
		textEntries[hash] = newEntry;
		return newEntry;
	}
}

}

namespace Graphics
{

namespace TextRenderer
{

vec2 TextDimensions ( const std::string& font, const std::string& text, float size )
{
	int xcoord = 0;
	int ycoord = 0;
	TTF_Font* fontObject = GetFont(font, size);
	if (TTF_SizeUTF8(fontObject, text.c_str(), &xcoord, &ycoord) != 0)
	{
		printf("Trouble with text '%s', line %d\n", text.c_str(), __LINE__);
	}
	return vec2(xcoord, ycoord);
}

GLuint TextObject ( const std::string& font, const std::string& text, float size )
{
	TextEntry* entry = GetEntry(font, text, size);
	assert(entry);
	entry->lastUse = GameTime();
	return entry->texID;
}

void Prune ()
{
	float time = GameTime();
	for (TextEntryTable::iterator iter = textEntries.begin(); iter != textEntries.end(); iter++)
	{
		if (time - iter->second->lastUse > 14.0f) // text objects expire in 14 seconds
		{
			delete iter->second;
			textEntries.erase(iter);
			return; // difficulties arise here with the iterator once erased, might as well just prune one per pass
		}
	}
}

void Flush ()
{
	for (TextEntryTable::iterator iter = textEntries.begin(); iter != textEntries.end(); iter++)
	{
		delete iter->second;
	}
	textEntries.clear();
}

}

}

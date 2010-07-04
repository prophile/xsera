#include "Sound.h"
#include <alure/alure.h>
#include <map>
#include "ResourceManager.h"
#include <assert.h>

namespace Sound
{

typedef std::map<std::string, ALuint> BufferMap;
BufferMap sounds;

int soundSourceCount;
ALuint* soundSources;
ALuint musicSource;
int soundSourceIndex = 0;

static ALuint GetSound(const std::string& name)
{
	BufferMap::iterator iter = sounds.find(name);
	if (iter != sounds.end())
		return iter->second;
	size_t length;
	SDL_RWops* rwops = ResourceManager::OpenFile("Sounds/" + name + ".aiff");
	assert(rwops);
	void* data = ResourceManager::ReadFull(&length, rwops, 1);
	ALuint buf = alureCreateBufferFromMemory((const ALubyte*)data, length);
	free(data);
	sounds.insert(std::make_pair(name, buf));
	return buf;
}

void Init(int frequency, int resolution, int sources)
{
	(void)resolution;
	--sources; // one spare source for music
	ALCint attribs[] = {
		ALC_FREQUENCY, frequency,
		ALC_MONO_SOURCES, sources,
		ALC_STEREO_SOURCES, 1,
		0
	};
	alureInitDevice(NULL, attribs);
	soundSources = new ALuint[sources];
	alGenSources(sources, soundSources);
	alGenSources(1, &musicSource);
	soundSourceCount = sources;
}

static ALuint GetFreeSource()
{
	int idx = soundSourceIndex++;
	soundSourceIndex = soundSourceIndex % soundSourceCount;
	return soundSources[idx];
}

void Preload(const std::string& name)
{
	GetSound(name);
}

void PlaySound(const std::string& name, float gain, float pan)
{
	ALuint buf    = GetSound(name);
	ALuint source = GetFreeSource();
	alSourcei(source, AL_BUFFER, buf);
	alSourcePlay(source);
}

void PlayMusic(const std::string& name)
{
}

void StopMusic()
{
}

std::string MusicName()
{
	return "";
}

float MusicVolume()
{
	return 1.0f;
}

void SetMusicVolume(float mvol)
{
}

float SoundVolume()
{
	return 1.0f;
}

void SetSoundVolume(float mvol)
{
}

}

#include "Sound.h"
#include <alure/alure.h>
#include <map>
#include "ResourceManager.h"
#include <assert.h>
#include "Engine/Logging.h"

namespace Sound
{

const int CHUNK_LENGTH = 16386;

typedef std::map<std::string, ALuint> BufferMap;
BufferMap sounds;

int soundSourceCount;
ALuint* soundSources;
ALuint musicSource;
ALuint musicBufs[2];
alureStream* currentMusicStream = NULL;
std::string currentMusicName = "";
int soundSourceIndex = 0;

void DieUnpleasantly()
{
	StopMusic();
}

ALubyte* GetSoundData(const std::string& path, size_t& length)
{
	SDL_RWops* rwops = ResourceManager::OpenFile(path + ".aiff");
	if (!rwops)
		rwops = ResourceManager::OpenFile(path + ".ogg");
	if (!rwops)
	{
		length = 0;
		return NULL;
	}
	return (ALubyte*)ResourceManager::ReadFull(&length, rwops, 1);
}

static ALuint GetSound(const std::string& name)
{
	BufferMap::iterator iter = sounds.find(name);
	if (iter != sounds.end())
		return iter->second;
	size_t length;
	ALubyte* data = GetSoundData("Sounds/" + name, length);
	ALuint buf = alureCreateBufferFromMemory(data, length);
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
	//alGenBuffers(2, musicBufs);
	soundSourceCount = sources;
	atexit(DieUnpleasantly);
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

static void MusicEndCallback(void* ud, ALuint source)
{
	alureDestroyStream(currentMusicStream, 2, musicBufs);
	currentMusicStream = NULL;
	currentMusicName = "";
	free(ud);
}

void PlayMusic(const std::string& name)
{
	if (currentMusicStream)
		alureStopSource(musicSource, AL_TRUE);
	size_t length;
	ALubyte* data = GetSoundData("Music/" + name, length);
	currentMusicName = name;
	currentMusicStream = alureCreateStreamFromStaticMemory(data, length, CHUNK_LENGTH, 2, musicBufs);
	alurePlaySourceStream(musicSource, currentMusicStream, 2, 1, MusicEndCallback, data);
	LOG("Sound", LOG_MESSAGE, "Music: %s", name.c_str());
	if (!data)
		LOG("Sound", LOG_WARNING, "failed to find music");
}

void StopMusic()
{
	if (!currentMusicStream)
		return;
	alureStopSource(musicSource, AL_TRUE);
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

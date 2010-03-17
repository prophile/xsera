#include "Sound.h"
#ifdef WIN32
#include <SDL/SDL_mixer.h>
#else
#include <SDL_mixer/SDL_mixer.h>
#endif
#include <SDL/SDL.h>
#include <queue>

#include <map>
#include <math.h>
#include "Utilities/ResourceManager.h"
#include "Logging.h"

namespace Sound
{

namespace Internal
{

typedef std::map<std::string, Mix_Chunk*> EffectsMap;
typedef std::map<std::string, Mix_Music*> MusicMap;
std::queue<std::string> preloadQueue;
EffectsMap effects;
MusicMap musics;

SDL_mutex* effectMapLock = NULL;
SDL_mutex* preloadQueueLock = NULL;
SDL_cond* preloadQueueCondition = NULL;

Mix_Chunk* SoundNamed ( const std::string& name )
{
	SDL_LockMutex(effectMapLock);
	EffectsMap::iterator iter = effects.find(name);
	if (iter == effects.end())
	{
		// load the sound
		std::string path = "Sounds/" + name + ".aiff";
		SDL_RWops* ops = ResourceManager::OpenFile(path);
		Mix_Chunk* newChunk = Mix_LoadWAV_RW(ops, 1);
		if (!newChunk)
		{
            LOG("Sound", LOG_WARNING, "Decoding sound '%s' failed! Error: %s", name.c_str(), Mix_GetError());
			effects[name] = NULL;
			SDL_UnlockMutex(effectMapLock);
			return NULL;
		}
		effects[name] = newChunk;
		SDL_UnlockMutex(effectMapLock);
		return newChunk;
	}
	else
	{
		SDL_UnlockMutex(effectMapLock);
		return iter->second;
	}
}

void PreloadingThread ()
{
	SDL_LockMutex(preloadQueueLock);
	while (SDL_CondWait(preloadQueueCondition, preloadQueueLock))
	{
		while (!preloadQueue.empty())
		{
			std::string nextSound = preloadQueue.front();
			preloadQueue.pop();
			SoundNamed(nextSound); 
		}
	}
}

const char* extensions[] =
{
	".ogg",
	".xm",
	".mod",
	".aiff",
	NULL
};

Mix_Music* MusicNamed ( const std::string& name )
{
	MusicMap::iterator iter = musics.find(name);
	if (iter == musics.end())
	{
		// load the sound
		Mix_Music* newMusic = NULL;
		for (unsigned i = 0; extensions[i] != NULL; i++)
		{
			std::string path = "Music/" + name + extensions[i];
			SDL_RWops* ops = ResourceManager::OpenFile(path);
			if (!ops)
				continue;
			newMusic = Mix_LoadMUS_RW(ops);
			if (newMusic)
				break;
		}
		musics[name] = newMusic;
		return newMusic;
	}
	else
	{
		return iter->second;
	}
}

std::string songName;

}

using namespace Internal;

static bool disable_music = false;

void Init ( int frequency, int resolution, int sources )
{
	Mix_Init(MIX_INIT_MOD|MIX_INIT_OGG);
	int volume_sound = MIX_MAX_VOLUME, volume_music = MIX_MAX_VOLUME;
	Uint16 format;
	switch (resolution)
	{
		case 8:
			format = AUDIO_S8;
			break;
		case 16:
			format = AUDIO_S16SYS;
			break;
/*		case 24:
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
			format = 0x8018;
#else
			format = 0x9018;
#endif
			break;*/
		default:
            LOG("Sound", LOG_NOTICE, "Unsupported audio format, defaulting to 16-bit");
			format = AUDIO_S16SYS;
			break;
	}
	Mix_OpenAudio(frequency, format, 2, 4096);
	Mix_AllocateChannels(sources);
	Mix_VolumeMusic(volume_music);
	Mix_Volume(-1, volume_sound);
#ifndef NDEBUG
	if (getenv("APOLLO_MUSIC_DISABLE"))
//		disable_music = true;
#endif
	effectMapLock = SDL_CreateMutex();
	preloadQueueLock = SDL_CreateMutex();
	preloadQueueCondition = SDL_CreateCond();
}

void Preload ( const std::string& name )
{
	SDL_LockMutex(preloadQueueLock);
	preloadQueue.push(name);
	SDL_UnlockMutex(preloadQueueLock);
	SDL_CondSignal(preloadQueueCondition);
}

void PlaySoundSDL ( const std::string& name, float gain, float pan )
{
	Mix_Chunk* chunk = SoundNamed(name);
	if (!chunk)
		return;
	Uint8 ipan = pan * 127;
	int ivolume = gain * (MIX_MAX_VOLUME / 2);
	int channel = Mix_GroupAvailable(-1);
	Mix_UnregisterAllEffects(channel);
	if (ipan != 127)
		Mix_SetPanning(channel, 0xFF - ipan, ipan);
	if (fabs(gain - 1.0f) > 0.0003f)
		Mix_SetDistance(channel, 1 / gain);
	Mix_PlayChannel(channel, chunk, 0);
}

void PlayMusic ( const std::string& music )
{
//	if (disable_music)
//		return;
	Mix_Music* mus = MusicNamed(music);
	printf("%d", mus);
	if (mus)
	{
		Mix_PlayMusic(mus, -1);
		songName = music;
	}
}

void StopMusic ()
{
	songName = "(no song)";
	Mix_HaltMusic();
}

std::string MusicName ()
{
	return songName;
}

float MusicVolume ()
{
	return Mix_VolumeMusic(-1) / (float)MIX_MAX_VOLUME;
}

void SetMusicVolume ( float _mvol )
{
	Mix_VolumeMusic(_mvol * MIX_MAX_VOLUME);
}

float SoundVolume ()
{
	return Mix_Volume(-1, -1) / (float)MIX_MAX_VOLUME;
}

void SetSoundVolume ( float _mvol )
{
	Mix_Volume(-1, MIX_MAX_VOLUME * _mvol);
}

}

#ifdef WIN32
#include <stdafx.h>
#endif

#include "Sound.h"
#include <SDL/SDL.h>
#include <SDL_mixer/SDL_mixer.h>
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
EffectsMap effects;
MusicMap musics;

void ClearSoundAndMusic ()
{
}

Mix_Chunk* SoundNamed ( const std::string& name )
{
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
			return NULL;
		}
		effects[name] = newChunk;
		return newChunk;
	}
	else
	{
		return iter->second;
	}
}

const char* extensions[] =
{
	".s3m",
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
	if (getenv("APOLLO_MUSIC_DISABLE"))
		disable_music = true;
}

void PlaySound ( const std::string& name, float gain, float pan )
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
	songName = "(no song)";
}

void PlayMusic ( const std::string& music )
{
	if (disable_music)
		return;
	Mix_Music* mus = MusicNamed(music);
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

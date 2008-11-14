#include "Sound.h"
#include <SDL/SDL.h>
#include <SDL_mixer/SDL_mixer.h>
#include <map>
#include <math.h>
#include "Utilities/ResourceManager.h"

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
		effects[path] = newChunk;
		return newChunk;
	}
	else
	{
		return iter->second;
	}
}

Mix_Music* MusicNamed ( const std::string& name )
{
	MusicMap::iterator iter = musics.find(name);
	if (iter == musics.end())
	{
		// load the sound
		std::string path = "Music/" + name + ".s3m";
		SDL_RWops* ops = ResourceManager::OpenFile(path);
		Mix_Music* newMusic = Mix_LoadMUS_RW(ops);
		if (!newMusic)
		{
			std::string path = "Music/" + name + ".ogg";
			SDL_RWops* ops = ResourceManager::OpenFile(path);
			newMusic = Mix_LoadMUS_RW(ops);
		}
		musics[path] = newMusic;
		return newMusic;
	}
	else
	{
		return iter->second;
	}
}

}

using namespace Internal;

void Init ( int frequency, int resolution, int sources )
{
	int volume_sound = MIX_MAX_VOLUME / 2, volume_music = MIX_MAX_VOLUME / 2;
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
			printf("Unsupported audio format, defaulting to 16-bit");
			format = AUDIO_S16SYS;
			break;
	}
	Mix_OpenAudio(frequency, format, 2, 4096);
	Mix_AllocateChannels(sources);
	Mix_VolumeMusic(volume_music);
	Mix_Volume(-1, volume_sound);
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
}

void PlayMusic ( const std::string& music )
{
	Mix_Music* mus = MusicNamed(music);
	if (mus)
	{
		Mix_PlayMusic(mus, -1);
	}
}

void StopMusic ()
{
	Mix_HaltMusic();
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

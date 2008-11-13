#include "Sound.h"
#include <SDL/SDL.h>
#include <SDL_mixer/SDL_mixer.h>

namespace Sound
{

namespace Internal
{

void ClearSoundAndMusic ()
{
}

Mix_Chunk* SoundNamed ( const std::string& name )
{
	return NULL;
}

Mix_Music* MusicNamed ( const std::string& name )
{
	return NULL;
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
}

void PlayMusic ( const std::string& music )
{
}

void StopMusic ()
{
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

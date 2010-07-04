#include "Sound.h"

namespace Sound
{

void Init(int frequency, int resolution, int sources)
{
}

void Preload(const std::string& name)
{
}

void PlaySound(const std::string& name, float gain, float pan)
{
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

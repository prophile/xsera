#ifndef __xsera_sound_sound_h
#define __xsera_sound_sound_h

#include <string>

namespace Sound
{

void Init ( int frequency, int resolution, int sources );

void PlaySound ( const std::string& name, float gain = 1.0f, float pan = 0.0f );
void PlayMusic ( const std::string& music );
void StopMusic ();

float MusicVolume ();
void SetMusicVolume ( float _mvol );
float SoundVolume ();
void SetSoundVolume ( float _mvol );

}

#endif

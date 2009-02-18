#ifndef __apollo_sound_sound_h
#define __apollo_sound_sound_h

#include <string>

namespace Sound
{

/**
 * Start, or re-start, the sound subsystem
 * @param frequency The sampling rate to use, typically 44100, although 48000 is recommended
 * @param resolution The resolution to use, typically 16, although 24 is recommended
 * @param sources The number of mixing channels to use. Typically 64, although 128 is recommended
 */
void Init ( int frequency, int resolution, int sources );

/**
 * Plays a sound
 * @param name The name of the sound
 * @param gain The gain of the sound. 1 is normal gain, 2 is twice as loud, et cetera.
 * @param pan The pan of the sound. 0 is central, -1 is full left, 1 is full right
 */
void PlaySoundSDL ( const std::string& name, float gain = 1.0f, float pan = 0.0f );
/**
 * Plays music
 * @param music The name of the track to play
 */
void PlayMusic ( const std::string& music );
/**
 * Stops the music
 */
void StopMusic ();
/**
 * Returns the name of the current song
 */
std::string MusicName ();
/**
 * Gets the current music volume
 */
float MusicVolume ();
/**
 * Sets the current music volume
 */
void SetMusicVolume ( float _mvol );
/**
 * Gets the current sound volume
 */
float SoundVolume ();
/**
 * Sets the current sound volume
 */
void SetSoundVolume ( float _mvol );

}

#endif

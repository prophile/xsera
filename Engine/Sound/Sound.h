#ifndef __apollo_sound_sound_h
#define __apollo_sound_sound_h

#include <string>
#include "Utilities/Vec2.h"

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
 * Shut down the sound subsystem.
 */
void Quit ();

/**
 * Preloads a sound
 *
 * @param name The name of the sound to preload
 */
void Preload ( const std::string& name );
/**
 * Plays a sound
 * @param name The name of the sound
 * @param gain The gain of the sound. 1 is normal gain, 2 is twice as loud, et cetera.
 */
void PlaySound ( const std::string& name, float gain = 1.0f );
/**
 * Plays a sound, positionally
 * @param name The name of the sound
 * @param pos The origin of the sound
 * @param gain The gain of the sound
 */
void PlaySoundPositional ( const std::string& name, vec2 pos, vec2 vel = vec2(0.0f, 0.0f), float gain = 1.0f );
/**
 * Set the position of the listener.
 * @param pos The listener's position.
 * @param vel The listener's velocity.
 */
void SetListener(vec2 pos, vec2 vel);
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

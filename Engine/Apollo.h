#ifndef __apollo_h
#define __apollo_h

#ifdef WIN32
#define assert(x) { if (! ( x ) ) { printf("Assertion failure: %s\n\tFile: %s\n\tLine: %d\n", # x , __FILE__, __LINE__ ); abort(); } }
#undef SendMessage
#undef GetMessage	//apparently, these are Windows directives
#endif
#include <SDL/SDL.h>

#include "Logging.h"
#include "Utilities/Colour.h"
#include "Utilities/Matrix2x3.h"
#include "Utilities/Vec2.h"
#include "Utilities/ResourceManager.h"
#include "Utilities/GameTime.h"
#include "Utilities/TestHarness.h"
#include "Utilities/MachinePower.h"
#include "Input.h"
#include "Modes/ModeManager.h"
#include "Graphics/Graphics.h"
#include "Net/Net.h"
#include "Scripting/Scripting.h"
#include "Scripting/Compile.h"
#include "Sound/Sound.h"
#include "Preferences.h"
#include "enetadapt.h"

extern "C"
{

extern void Init ();
extern void MainLoop ();
extern void Shutdown ();

}

#endif

/**
 * @mainpage
 * Contained within is the documentation for Apollo, the engine for Xsera.\n\n
 * We will try to keep this documentation as up-to-date as possible, but this is
 * no easy task. If you can make an improvement to the documentation, please
 * contact us through the official Xsera repository at
 * http://github.com/xsera/xsera
 */
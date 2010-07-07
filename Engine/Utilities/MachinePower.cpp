#include "MachinePower.h"

#ifdef __MACH__

#include <sys/types.h>
#include <sys/sysctl.h>
#include <string.h>
#include <stdlib.h>
#include "ResourceManager.h"
#include <CoreFoundation/CoreFoundation.h>

extern "C" long NSRunAlertPanel(CFStringRef title, CFStringRef msg, CFStringRef defaultButton, CFStringRef alternateButton, CFStringRef otherButton, ...);

MachinePower GetMachinePower()
{
	char nameBuf[64];
	size_t nameLen = sizeof(nameBuf);
	memset(nameBuf, 0, sizeof(nameBuf));
	sysctlbyname("hw.model", &nameBuf, &nameLen, NULL, NULL);
	if (nameLen == 0)
		return MACHINE_POWER_CAPABLE; // assume capable
	else
	{
		// check our list
		SDL_RWops* ops = ResourceManager::OpenFile("Config/MacModels.txt");
		if (!ops)
			return MACHINE_POWER_CAPABLE;
		size_t length;
		void* ptr = ResourceManager::ReadFull(&length, ops, 1);
		if (!ptr)
			return MACHINE_POWER_CAPABLE;
		bool found = strnstr((const char*)ptr, nameBuf, length);
		free(ptr);
		return found ? MACHINE_POWER_MIGHTY : MACHINE_POWER_WIMPY;
	}
}

void CheckMachinePowerSanity()
{
	MachinePower power = GetMachinePower();
	if (power == MACHINE_POWER_WIMPY)
	{
		long result = NSRunAlertPanel(CFSTR("Underpowered Machine"),
		                              CFSTR("Your machine does not have enough power to run the Apollo engine properly. If you choose to continue, you may experience performance difficulties."),
									  CFSTR("Quit"),
									  CFSTR("Continue"),
									  0);
		if (result != 0)
			exit(0);
	}
}

#else

#warning GetMachinePower is not implemented on this architecture

MachinePower GetMachinePower()
{
	// return an average guess
	return MACHINE_POWER_CAPABLE;
}

void CheckMachinePowerSanity()
{
}

#endif

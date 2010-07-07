#ifndef __apollo_utilities_machine_power_h
#define __apollo_utilities_machine_power_h

enum MachinePower
{
	MACHINE_POWER_WIMPY,
	MACHINE_POWER_CAPABLE,
	MACHINE_POWER_MIGHTY
};

MachinePower GetMachinePower();
void CheckMachinePowerSanity();

#endif

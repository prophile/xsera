#ifndef __aresx_modes_modemanager_h
#define __aresx_modes_modemanager_h

class Mode
{
public:
	Mode () {}
	virtual ~Mode () {}

	virtual void Activate () {}
	virtual void Render () = 0;
	virtual void Update () = 0;
	virtual void Deactivate () {}
};

class ModeManager
{
private:
	Mode* activeMode;
public:
	ModeManager ();
	~ModeManager ();

	Mode* ActiveMode ();
	static ModeManager* SharedModeManager ();

	void SwitchMode ( Mode* newMode );
};

#endif

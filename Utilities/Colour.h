#ifndef __aresx_utilities_colour_h
#define __aresx_utilities_colour_h

#include <string.h>

#ifndef WIN32
#define COLOUR_VECTOR_SUPPORT
#else
#warning Vector support unavailable on this platform, using scalar fallbacks for colour
#endif

class col
{
public:
	#ifdef COLOUR_VECTOR_SUPPORT
	typedef float v4f __attribute__ ((vector_size (16)));
	#endif
	typedef float a4f[4];
	#ifdef COLOUR_VECTOR_SUPPORT
	typedef union _v4
	{
		v4f vector;
		a4f array;
	} v4;
	#else
	typedef union _v4
	{
		a4f array;
	} v4;
	#endif
private:
	v4 data;
public:
	col ();
	col ( float l, float a );
	col ( float r, float g, float b );
	col ( float r, float g, float b, float a );
	col ( const col& ocol );
	col ( const float vec[4] );
#ifdef COLOUR_VECTOR_SUPPORT
	col ( const v4f vec ) { data.vector = vec; }
	col& operator= ( const col& ocol ) { data.vector = ocol.data.vector; return *this; }
#else
	col& operator= ( const col& ocol );
#endif
	
	float red   () const { return data.array[0]; }
	float green () const { return data.array[1]; }
	float blue  () const { return data.array[2]; }
	float alpha () const { return data.array[3]; }
	
	float& red   () { return data.array[0]; }
	float& green () { return data.array[1]; }
	float& blue  () { return data.array[2]; }
	float& alpha () { return data.array[3]; }
	
	col operator- () const;
	col operator+ ( const col& ocol ) const;
	col& operator+= ( const col& ocol );
	col operator- ( const col& ocol ) const;
	col& operator-= ( const col& ocol );
	col operator* ( const col& ocol ) const;
	col& operator*= ( const col& ocol );
	col operator/ ( const col& ocol ) const;
	col& operator/= ( const col& ocol );
	col operator* ( float factor ) const;
	col& operator*= ( float factor );
	col operator/ ( float factor ) const;
	col& operator/= ( float factor );
};

#endif

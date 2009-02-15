#ifndef __apollo_utilities_colour_h
#define __apollo_utilities_colour_h

#include <string.h>

#ifndef WIN32
#define COLOUR_VECTOR_SUPPORT
#else
//commented by command of Alastair
//#warning Vector support unavailable on this platform, using scalar fallbacks for colour
#endif

/**
 * A colour
 */
class colour
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
	colour ();
	colour ( float l, float a );
	colour ( float r, float g, float b );
	colour ( float r, float g, float b, float a );
	colour ( const colour& ocol );
	colour ( const float vec[4] );
#ifdef COLOUR_VECTOR_SUPPORT
	colour ( const v4f vec ) { data.vector = vec; }
	colour& operator= ( const colour& ocol ) { data.vector = ocol.data.vector; return *this; }
#else
	colour& operator= ( const colour& ocol );
#endif
	
	float red   () const { return data.array[0]; }
	float green () const { return data.array[1]; }
	float blue  () const { return data.array[2]; }
	float alpha () const { return data.array[3]; }
	
	float& red   () { return data.array[0]; }
	float& green () { return data.array[1]; }
	float& blue  () { return data.array[2]; }
	float& alpha () { return data.array[3]; }
	
	colour operator- () const;
	colour operator+ ( const colour& ocol ) const;
	colour& operator+= ( const colour& ocol );
	colour operator- ( const colour& ocol ) const;
	colour& operator-= ( const colour& ocol );
	colour operator* ( const colour& ocol ) const;
	colour& operator*= ( const colour& ocol );
	colour operator/ ( const colour& ocol ) const;
	colour& operator/= ( const colour& ocol );
	colour operator* ( float factor ) const;
	colour& operator*= ( float factor );
	colour operator/ ( float factor ) const;
	colour& operator/= ( float factor );
};

#endif

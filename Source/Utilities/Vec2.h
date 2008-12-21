#ifndef __xsera_utilities_vec2_h
#define __xsera_utilities_vec2_h

#include <math.h>

class vec2
{
private:
	float x, y;
public:
	vec2 () : x(0.0f), y(0.0f) {}
	vec2 ( float _x, float _y ) : x(_x), y(_y) {}
	
	static vec2 AngleModulus ( float angle, float mod )
		{ return vec2(cosf(angle)*mod, sinf(angle)*mod); }
	
	float X () const { return x; }
	float Y () const { return y; }
	float& X () { return x; }
	float& Y () { return y; }
	
	float Modulus () const { return hypotf(y, x); }
	float ModulusSquared () const { return x*x + y*y; }
	float Angle () const { return atan2f(y, x); }
	
	vec2 UnitVector () const { return (*this / Modulus()); }
	
	vec2 operator+ ( const vec2& ov2 ) const
		{ return vec2(x + ov2.x, y + ov2.y); }
	vec2& operator+= ( const vec2& ov2 )
		{ x += ov2.x; y += ov2.y; return *this; }
	vec2 operator- ( const vec2& ov2 )const
		{ return vec2(x - ov2.x, y - ov2.y); }
	vec2& operator-= ( const vec2& ov2 )
		{ x -= ov2.x; y -= ov2.y; return *this; }
	float operator* ( const vec2& ov2 ) const // dot product
		{ return x*ov2.x + y*ov2.y; }
	vec2 operator* ( float factor ) const
		{ return vec2(x*factor, y*factor); }
	vec2& operator*= ( float factor )
		{ x *= factor; y *= factor; return *this; }
	vec2 operator/ ( float factor ) const
		{ return vec2(x/factor, y/factor); }
	vec2& operator/= ( float factor )
		{ x /= factor; y /= factor; return *this; }
	vec2 operator- () const
		{ return vec2(-x, -y); }
		
	static float Distance ( const vec2& v1, const vec2& v2 )
		{ return (v2 - v1).Modulus(); }
    static float DistanceSquared ( const vec2& v1, const vec2& v2 )
        { return (v2 - v1).ModulusSquared(); }
};

#endif

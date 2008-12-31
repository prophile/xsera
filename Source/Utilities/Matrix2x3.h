#ifndef __included_matrix2x3_h
#define __included_matrix2x3_h

#include "Vec2.h"

class matrix2x3
{
private:
	// TODO: vectorise
	float _m11, _m12, _m21, _m22, _tX, _tY;
public:
	matrix2x3() : _m11(1.0f), _m12(0.0f), _m21(0.0f), _m22(1.0f), _tX(0.0f), _tY(0.0f) {}
	matrix2x3(float m11, float m12, float m21, float m22, float tX, float tY) : _m11(m11), _m12(m12), _m21(m21), _m22(m22), _tX(tX), _tY(tY) {}
	matrix2x3(const float* mat) : _m11(mat[0]), _m12(mat[1]), _m21(mat[3]), _m22(mat[4]), _tX(mat[2]), _tY(mat[5]) {}
	matrix2x3(const matrix2x3& om2) : _m11(om2._m11), _m12(om2._m12), _m21(om2._m21), _m22(om2._m22), _tX(om2._tX), _tY(om2._tY) {}
	
	void FillOpenGLMatrix ( float* pointer ) const;
	
	vec2 operator* ( const vec2& srcv2 ) const;
	matrix2x3 operator* ( const matrix2x3& srcm2 ) const;
	matrix2x3& operator*= ( const matrix2x3& srcm2 );

	matrix2x3& operator= ( const matrix2x3& srcm2 );

	static matrix2x3 Identity () { return matrix2x3(); }
	static matrix2x3 Scale ( float x, float y ) { return matrix2x3(x, 0.0f, 0.0f, y, 0.0f, 0.0f); }
	static matrix2x3 Scale ( vec2 scale ) { return matrix2x3(scale.X(), 0.0f, 0.0f, scale.Y(), 0.0f, 0.0f); }
	static matrix2x3 Scale ( float sf ) { return matrix2x3(sf, 0.0f, 0.0f, sf, 0.0f, 0.0f); }
	static matrix2x3 Rotation ( float angle );
	static matrix2x3 Translate ( vec2 translate ) { return matrix2x3(1.0f, 0.0f, 0.0f, 1.0f, translate.X(), translate.Y()); }
	static matrix2x3 Translate ( float x, float y ) { return matrix2x3(1.0f, 0.0f, 0.0f, 1.0f, x, y); }
	static matrix2x3 ShearX ( float amount ) { return matrix2x3(1.0f, amount, 0.0f, 1.0f, 0.0f, 0.0f); }
	static matrix2x3 ShearY ( float amount ) { return matrix2x3(1.0f, 0.0f, amount, 1.0f, 0.0f, 0.0f); }
	static matrix2x3 Ortho ( float left, float right, float bottom, float top );
};

#endif

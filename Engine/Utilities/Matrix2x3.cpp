#ifdef WIN32
#include <stdafx.h>
#endif

#include "Matrix2x3.h"
#include "Vec2.h"
#include <math.h>

void matrix2x3::FillOpenGLMatrix ( float* pointer ) const
{
	pointer[0] = _m11;
	pointer[1] = _m21;
	pointer[2] = 0.0f;
	pointer[3] = 0.0f;
	pointer[4] = _m12;
	pointer[5] = _m22;
	pointer[6] = 0.0f;
	pointer[7] = 0.0f;
	pointer[8] = 0.0f;
	pointer[9] = 0.0f;
	pointer[10] = 1.0f;
	pointer[11] = 0.0f;
	pointer[12] = _tX;
	pointer[13] = _tY;
	pointer[14] = 0.0f;
	pointer[15] = 1.0f;
}

vec2 matrix2x3::operator* ( const vec2& srcv2 ) const
{
	float ix, iy, ox, oy;
	ix = srcv2.X();
	iy = srcv2.Y();
	ox = (ix * _m11) + (iy * _m12) + _tX;
	oy = (ix * _m21) + (iy * _m22) + _tY;
	return vec2(ox, oy);
}

static void MatrixMultiply3 ( const float* inMatrix1, const float* inMatrix2, float* outMatrix )
{
	// a sane compiler will unroll this loop
#define MA(matrix,x,y) matrix[(3*y)+x]
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			MA(outMatrix,i,j) = 0.0f;
			for (int k = 0; k < 3; k++)
			{
				MA(outMatrix,i,j) += MA(inMatrix1,i,k) * MA(inMatrix2,k,j);
			}
		}
	}
}

matrix2x3 matrix2x3::operator* ( const matrix2x3& srcm2 ) const
{
	float inMatrix1[] = { _m11, _m12, _tX,
                              _m21, _m22, _tY,
                              0.0f, 0.0f, 1.0f };
	float inMatrix2[] = { srcm2._m11, srcm2._m12, srcm2._tX,
                              srcm2._m21, srcm2._m22, srcm2._tY,
                              0.0f,       0.0f,       1.0f };
	float outMatrix[9];
	MatrixMultiply3(inMatrix1, inMatrix2, outMatrix);
	return matrix2x3 ( outMatrix );
}

matrix2x3& matrix2x3::operator*= ( const matrix2x3& srcm2 )
{
	float inMatrix1[] = { _m11, _m12, _tX,
                              _m21, _m22, _tY,
                              0.0f, 0.0f, 1.0f };
	float inMatrix2[] = { srcm2._m11, srcm2._m12, srcm2._tX,
                              srcm2._m21, srcm2._m22, srcm2._tY,
                              0.0f,       0.0f,       1.0f };
	float outMatrix[9];
	MatrixMultiply3(inMatrix1, inMatrix2, outMatrix);
	_m11 = outMatrix[0];
	_m12 = outMatrix[1];
	_m21 = outMatrix[3];
	_m22 = outMatrix[4];
	_tX = outMatrix[2];
	_tY = outMatrix[5];
	return *this;
}

matrix2x3& matrix2x3::operator= ( const matrix2x3& srcm2 )
{
	_m11 = srcm2._m11;
	_m12 = srcm2._m12;
	_m21 = srcm2._m21;
	_m22 = srcm2._m22;
	_tX = srcm2._tX;
	_tY = srcm2._tY;
	return (*this);
}

matrix2x3 matrix2x3::Rotation ( float angle )
{
	return matrix2x3(cosf(angle), -sinf(angle), sinf(angle), cosf(angle), 0.0f, 0.0f);
}

matrix2x3 matrix2x3::Ortho ( float left, float right, float bottom, float top )
{
	float tx = (right + left) / (right - left);
	float ty = (top + bottom) / (top - bottom);
	float m11 = 2.0f / (right - left);
	float m22 = 2.0f / (top - bottom);
	return matrix2x3(m11, 0.0f, 0.0f, m22, tx, ty);
}

matrix2x3 matrix2x3::Inverse () const
{
	float det = (_m11 * _m22) - (_m21 * _m12);
	float newMatrix[6];
	newMatrix[0] = _m22 / det;
	newMatrix[1] = -_m12 / det;
	newMatrix[2] = ((_m12 * _tY) - (_tX * _m22)) / det;
	newMatrix[3] = -_m21 / det;
	newMatrix[4] = _m11 / det;
	newMatrix[5] = ((_tX * _m21) - (_m11 * _tY)) / det;
	return matrix2x3(newMatrix);
}

#include "Colour.h"

col::col ()
{
	data.array[0] = data.array[1] = data.array[2] = 0.0f;
	data.array[3] = 1.0f;
}

col::col ( float l, float a )
{
	data.array[0] = data.array[1] = data.array[2] = l;
	data.array[3] = a;
}

col::col ( float r, float g, float b )
{
	data.array[0] = r;
	data.array[1] = g;
	data.array[2] = b;
	data.array[3] = 1.0f;
}

col::col ( float r, float g, float b, float a )
{
	data.array[0] = r;
	data.array[1] = g;
	data.array[2] = b;
	data.array[3] = a;
}

col::col ( const float vec[4] )
{
	memcpy(data.array, vec, sizeof(vec));
}

#ifdef COLOUR_VECTOR_SUPPORT
col::col ( const col& ocol )
{
	data.vector = ocol.data.vector;
}
#else
col::col ( const col& ocol )
{
	memcpy(data.array, ocol.data.array, sizeof(data.array));
}
#endif

#ifndef COLOUR_VECTOR_SUPPORT
col& col::operator= ( const col& ocol )
{
	data.array[0] = ocol.data.array[0];
	data.array[1] = ocol.data.array[1];
	data.array[2] = ocol.data.array[2];
	data.array[3] = ocol.data.array[3];
	return *this;
}
#endif

col col::operator- () const
{
	static const col def ( 1.0f, 1.0f, 1.0f, 1.0f );
	return def - *this;
}

col col::operator+ ( const col& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return col(data.vector + ocol.data.vector);
#else
	return col(red() + ocol.red(),
	           green() + ocol.green(),
	           blue() + ocol.blue(),
			   alpha() + ocol.alpha());
#endif
}

col& col::operator+= ( const col& ocol )
{
#ifdef COLOUR_VECTOR_SUPPORT
	data.vector += ocol.data.vector;
#else
	data.array[0] += ocol.data.array[0];
	data.array[1] += ocol.data.array[1];
	data.array[2] += ocol.data.array[2];
	data.array[3] += ocol.data.array[3];
#endif
	return *this;
}

col col::operator- ( const col& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return col(data.vector - ocol.data.vector);
#else
	return col(red() - ocol.red(),
	           green() - ocol.green(),
	           blue() - ocol.blue(),
			   alpha() - ocol.alpha());
#endif
}

col& col::operator-= ( const col& ocol )
{
#ifdef COLOUR_VECTOR_SUPPORT
	data.vector -= ocol.data.vector;
#else
	data.array[0] -= ocol.data.array[0];
	data.array[1] -= ocol.data.array[1];
	data.array[2] -= ocol.data.array[2];
	data.array[3] -= ocol.data.array[3];
#endif
	return *this;
}

col col::operator* ( const col& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return col(data.vector * ocol.data.vector);
#else
	return col(red() * ocol.red(),
	           green() * ocol.green(),
	           blue() * ocol.blue(),
			   alpha() * ocol.alpha());
#endif
}

col& col::operator*= ( const col& ocol )
{
#ifdef COLOUR_VECTOR_SUPPORT
	data.vector *= ocol.data.vector;
#else
	data.array[0] *= ocol.data.array[0];
	data.array[1] *= ocol.data.array[1];
	data.array[2] *= ocol.data.array[2];
	data.array[3] *= ocol.data.array[3];
#endif
	return *this;
}

col col::operator/ ( const col& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return col(data.vector / ocol.data.vector);
#else
	return col(red() / ocol.red(),
	           green() / ocol.green(),
	           blue() / ocol.blue(),
			   alpha() / ocol.alpha());
#endif
}

col& col::operator/= ( const col& ocol )
{
#ifdef COLOUR_VECTOR_SUPPORT
	data.vector /= ocol.data.vector;
#else
	data.array[0] /= ocol.data.array[0];
	data.array[1] /= ocol.data.array[1];
	data.array[2] /= ocol.data.array[2];
	data.array[3] /= ocol.data.array[3];
#endif
	return *this;
}

col col::operator* ( float factor ) const
{
	return col(data.array[0] * factor,
	           data.array[1] * factor,
	           data.array[2] * factor,
			   data.array[3] * factor);
}

col& col::operator*= ( float factor )
{
	data.array[0] *= factor;
	data.array[1] *= factor;
	data.array[2] *= factor;
	data.array[3] *= factor;
	return *this;
}

col col::operator/ ( float factor ) const
{
	return col(data.array[0] / factor,
	           data.array[1] / factor,
	           data.array[2] / factor,
			   data.array[3] / factor);
}

col& col::operator/= ( float factor )
{
	data.array[0] /= factor;
	data.array[1] /= factor;
	data.array[2] /= factor;
	data.array[3] /= factor;
	return *this;
}




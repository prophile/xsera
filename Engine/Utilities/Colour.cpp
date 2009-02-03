#ifdef WIN32
#include <stdafx.h>
#endif

#include "Colour.h"

/*
 ______________________________________ 
/ HELLO FROM #MACDEV, YOUR CODE IS ALL \
\ SHIT -rudy                           /
 -------------------------------------- 
\                             .       .
 \                           / `.   .' " 
  \                  .---.  <    > <    >  .---.
   \                 |    \  \ - ~ ~ - /  /    |
         _____          ..-~             ~-..-~
        |     |   \~~~\.'                    `./~~~/
       ---------   \__/                        \__/
      .'  O    \     /               /       \  " 
     (_____,    `._.'               |         }  \/~~~/
      `----.          /       }     |        /    \__/
            `-.      |       /      |       /      `. ,~~|
                ~-.__|      /_ - ~ ^|      /- _      `..-'   
                     |     /        |     /     ~-.     `-. _  _  _
                     |_____|        |_____|         ~ - . _ _ _ _ _>
					 */

colour::colour ()
{
	data.array[0] = data.array[1] = data.array[2] = 0.0f;
	data.array[3] = 1.0f;
}

colour::colour ( float l, float a )
{
	data.array[0] = data.array[1] = data.array[2] = l;
	data.array[3] = a;
}

colour::colour ( float r, float g, float b )
{
	data.array[0] = r;
	data.array[1] = g;
	data.array[2] = b;
	data.array[3] = 1.0f;
}

colour::colour ( float r, float g, float b, float a )
{
	data.array[0] = r;
	data.array[1] = g;
	data.array[2] = b;
	data.array[3] = a;
}

colour::colour ( const float vec[4] )
{
	memcpy(data.array, vec, sizeof(vec));
}

#ifdef COLOUR_VECTOR_SUPPORT
colour::colour ( const colour& ocol )
{
	data.vector = ocol.data.vector;
}
#else
colour::colour ( const colour& ocol )
{
	memcpy(data.array, ocol.data.array, sizeof(data.array));
}
#endif

#ifndef COLOUR_VECTOR_SUPPORT
colour& colour::operator= ( const colour& ocol )
{
	data.array[0] = ocol.data.array[0];
	data.array[1] = ocol.data.array[1];
	data.array[2] = ocol.data.array[2];
	data.array[3] = ocol.data.array[3];
	return *this;
}
#endif

colour colour::operator- () const
{
	static const colour def ( 1.0f, 1.0f, 1.0f, 1.0f );
	return def - *this;
}

colour colour::operator+ ( const colour& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return colour(data.vector + ocol.data.vector);
#else
	return colour(red() + ocol.red(),
	              green() + ocol.green(),
	              blue() + ocol.blue(),
			      alpha() + ocol.alpha());
#endif
}

colour& colour::operator+= ( const colour& ocol )
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

colour colour::operator- ( const colour& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return colour(data.vector - ocol.data.vector);
#else
	return colour(red() - ocol.red(),
	              green() - ocol.green(),
	              blue() - ocol.blue(),
			      alpha() - ocol.alpha());
#endif
}

colour& colour::operator-= ( const colour& ocol )
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

colour colour::operator* ( const colour& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return colour(data.vector * ocol.data.vector);
#else
	return colour(red() * ocol.red(),
	              green() * ocol.green(),
	              blue() * ocol.blue(),
			      alpha() * ocol.alpha());
#endif
}

colour& colour::operator*= ( const colour& ocol )
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

colour colour::operator/ ( const colour& ocol ) const
{
#ifdef COLOUR_VECTOR_SUPPORT
	return colour(data.vector / ocol.data.vector);
#else
	return colour(red() / ocol.red(),
	              green() / ocol.green(),
	              blue() / ocol.blue(),
			      alpha() / ocol.alpha());
#endif
}

colour& colour::operator/= ( const colour& ocol )
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

colour colour::operator* ( float factor ) const
{
	return colour(data.array[0] * factor,
	              data.array[1] * factor,
	              data.array[2] * factor,
			      data.array[3] * factor);
}

colour& colour::operator*= ( float factor )
{
	data.array[0] *= factor;
	data.array[1] *= factor;
	data.array[2] *= factor;
	data.array[3] *= factor;
	return *this;
}

colour colour::operator/ ( float factor ) const
{
	return colour(data.array[0] / factor,
	              data.array[1] / factor,
	              data.array[2] / factor,
			  	  data.array[3] / factor);
}

colour& colour::operator/= ( float factor )
{
	data.array[0] /= factor;
	data.array[1] /= factor;
	data.array[2] /= factor;
	data.array[3] /= factor;
	return *this;
}




varying vec2 tx;
varying vec4 colour;

void main ()
{
	tx = gl_MultiTexCoord0.st;
	colour = gl_Color;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}


varying vec2 tx;
varying vec4 colour;
uniform sampler2DRect texture;

void main ()
{
	gl_FragColor = texture2DRect(texture, tx) * colour;
}

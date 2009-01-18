#extension GL_ARB_texture_rectangle : require

varying vec2 tx;
uniform sampler2DRect texture;

void main ()
{
	gl_FragColor = texture2DRect(texture, tx);
}


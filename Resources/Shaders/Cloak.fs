#extension GL_ARB_texture_rectangle : require

varying vec2 tx;
uniform sampler2DRect texture;
const float alphaMax = 1.0/10.0;

void main()
{
	gl_FragColor = texture2DRect(texture, tx);
	gl_FragColor.a = clamp(gl_FragColor.a,0.0,alphaMax);
}

uniform sampler2D tex;
varying vec2 TX;
uniform vec3 Ambient;

void main()
{
	vec3 sample = texture2D(tex, TX).rgb;
	gl_FragColor = vec4(Ambient * sample, 1.0);
}

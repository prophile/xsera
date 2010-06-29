#define SPECTEX

#ifdef SPECTEX
uniform sampler2D spectex;
#endif

varying vec2 TX;
varying vec3 N;
varying vec3 V;

uniform sampler2D tex;
uniform vec3 lightPosition;
uniform vec3 lightColour;
uniform float lightIntensity;

const vec3 EyeDir   = vec3(0.0, 0.0, 1.0);

const float ATT_CONST = 0.6;
const float ATT_LINEAR = 0.2;
const float ATT_QUAD = 0.08;

const float SHININESS = 12.0;

vec4 overlay(in vec4 src, in vec4 dst)
{
	src.rgb *= src.a;
	dst += src;
	return dst;
}

void main()
{
	vec3 aux = lightPosition - V;
	float dist = length(aux);
	vec3 lightDir = normalize(aux);
	vec3 halfDir = normalize(lightDir + EyeDir);
	float NdotL = max(0.0, dot(N, lightDir));
	vec4 colour = vec4(0.0);
	vec4 sample = texture2D(tex, TX);
	if (NdotL > 0.0)
	{
		//gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
		//return;
		float att = 1.0 / (ATT_CONST +
                            ATT_LINEAR*dist +
                            ATT_QUAD*dist*dist);
		gl_FragColor = vec4(sample.rgb, sample.a*att);
		colour += att*lightIntensity*vec4(lightColour, 1.0)*sample*NdotL;
		float NdotHV = max(0.0, dot(N, halfDir));
		float specAmount = 0.5;
#ifdef SPECTEX
		specAmount = texture2D(spectex, TX).x;
#endif
		colour += att*lightIntensity*specAmount*vec4(lightColour, 1.0)*pow(NdotHV, SHININESS);
	}
	//gl_FragColor = overlay(colour, sample);
	gl_FragColor = colour;
}

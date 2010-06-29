#define SPECTEX

uniform sampler2D tex;

const float SHININESS = 11.0;
const float SPECSCALE = 8.0;

const float C1 = 0.429043;
const float C2 = 0.511664;
const float C3 = 0.743125;
const float C4 = 0.886227;
const float C5 = 0.247708;

const vec3 LightDir = vec3(0.71, 0.71, 0.3);
const vec3 LightCol = vec3( 0.95,  0.80, 0.6);
const vec3 L00  = vec3( 0.7870665,  0.9379944,  0.9799986);
const vec3 L1m1 = vec3( 0.4376419,  0.5579443,  0.7024107);
const vec3 L10  = vec3(-0.1020717, -0.1824865, -0.2749662);
const vec3 L11  = vec3( 0.4543814,  0.3750162,  0.1968642);
const vec3 L2m2 = vec3( 0.1841687,  0.1396696,  0.0491580);
const vec3 L2m1 = vec3(-0.1417495, -0.2186370, -0.3132702);
const vec3 L20  = vec3(-0.3890121, -0.4033574, -0.3639718);
const vec3 L21  = vec3( 0.0872238,  0.0744587,  0.0353051);
const vec3 L22  = vec3( 0.6662600,  0.6706794,  0.5246173);

const vec3 EyeDir   = vec3(0.0, 0.0, 1.0);

varying vec2 TX;
varying vec3 N;

void main()
{
	vec2 texCoord = TX;
	vec3 HalfDir  = normalize(LightDir + EyeDir);
	vec4 fullSample = texture2D(tex, texCoord);
	vec3 sample = fullSample.rgb;
	float specSample = fullSample.a;
	vec3 tnorm = normalize(N);
	vec3 light;
     light =        C1 * L22 * (tnorm.x * tnorm.x - tnorm.y * tnorm.y) +
                    C3 * L20 * tnorm.z * tnorm.z +
                    C4 * L00 -
                    C5 * L20 +
                    2.0 * C1 * L2m2 * tnorm.x * tnorm.y +
                    2.0 * C1 * L21 * tnorm.x * tnorm.z +
                    2.0 * C1 * L2m1 * tnorm.y * tnorm.z +
                    2.0 * C2 * L11 * tnorm.x +
                    2.0 * C2 * L1m1 * tnorm.y +
                    2.0 * C2 * L10 * tnorm.z;
	vec3 L = normalize(LightDir);
#ifdef SPECTEX
	float NdL = dot(tnorm, L);
	if (NdL > 0.0)
	{
		float NdotHV = max(dot(tnorm, HalfDir), 0.0);
		float powf = pow(NdotHV, SHININESS);
		light += SPECSCALE * powf * LightCol * specSample;
	}
#endif
	gl_FragColor = vec4(light * sample, 1.0);
	//gl_FragColor = vec4(tnorm, 1.0);
}

const float C1 = 0.429043;
const float C2 = 0.511664;
const float C3 = 0.743125;
const float C4 = 0.886227;
const float C5 = 0.247708;

const vec3 L00  = vec3( 0.7870665,  0.9379944,  0.9799986);
const vec3 L1m1 = vec3( 0.4376419,  0.5579443,  0.7024107);
const vec3 L10  = vec3(-0.1020717, -0.1824865, -0.2749662);
const vec3 L11  = vec3( 0.4543814,  0.3750162,  0.1968642);
const vec3 L2m2 = vec3( 0.1841687,  0.1396696,  0.0491580);
const vec3 L2m1 = vec3(-0.1417495, -0.2186370, -0.3132702);
const vec3 L20  = vec3(-0.3890121, -0.4033574, -0.3639718);
const vec3 L21  = vec3( 0.0872238,  0.0744587,  0.0353051);
const vec3 L22  = vec3( 0.6662600,  0.6706794,  0.5246173);

vec3 calculateDiffuseLight(in vec3 normal)
{
	return C1 * L22 * (normal.x * normal.x - normal.y * normal.y) +
           C3 * L20 * normal.z * normal.z +
           C4 * L00 -
           C5 * L20 +
           2.0 * C1 * L2m2 * normal.x * normal.y +
           2.0 * C1 * L21 * normal.x * normal.z +
           2.0 * C1 * L2m1 * normal.y * normal.z +
           2.0 * C2 * L11 * normal.x +
           2.0 * C2 * L1m1 * normal.y +
           2.0 * C2 * L10 * normal.z;
}

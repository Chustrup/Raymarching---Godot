float sd_sphere(vec3 pos, vec3 sphere_pos, float r) {
	return length(pos) - r;
}

float sd_plane(vec3 pos, vec3 plane_pos) {
	return pos.y - plane_pos.y;
}

float sd_box( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float DE(vec3 pos, int iterations, float bailout, float power) {
	vec3 z = pos;
	float dr = 1.0;
	float r = 10.0;
	for (int i = 0; i < iterations ; i++) {
		r = length(z);

		if (r>bailout) break;

		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow(r, power-1.0)*power*dr + 1.0;

		// scale and rotate the point
		float zr = pow( r,power);
		theta = theta*power;
		phi = phi*power;

		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}
	return 0.5*log(r)*r/dr;
}

float sd_capped_cone( vec3 p, vec3 a, vec3 b, float ra, float rb )
{
  float rba  = rb-ra;
  float baba = dot(b-a,b-a);
  float papa = dot(p-a,p-a);
  float paba = dot(p-a,b-a)/baba;
  float x = sqrt( papa - paba*paba*baba );
  float cax = max(0.0,x-((paba<0.5)?ra:rb));
  float cay = abs(paba-0.5)-0.5;
  float k = rba*rba + baba;
  float f = clamp( (rba*(x-ra)+paba*baba)/k, 0.0, 1.0 );
  float cbx = x-ra - f*rba;
  float cby = paba - f;
  float s = (cbx<0.0 && cay<0.0) ? -1.0 : 1.0;
  return s*sqrt( min(cax*cax + cay*cay*baba,
                     cbx*cbx + cby*cby*baba) );
}
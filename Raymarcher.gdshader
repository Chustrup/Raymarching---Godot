shader_type spatial;

uniform int shapeCount = 10;
uniform float widths[100];
uniform float heights[100];
uniform int types[100];
uniform mat4 matrices[100];
uniform float minInfluences[100];
uniform vec3 colors[100];

group_uniforms Lightning;
uniform bool lightning = true;
uniform bool shadows = true;
uniform float shadow_intensity: hint_range(0.0, 1.0, 0.1) = .1;
uniform vec3 shadow_color: source_color;
uniform float light_intensity: hint_range(0.0, 1.0, 0.1) = .1;
uniform vec3 light_color: source_color;
group_uniforms;

group_uniforms Shape;
uniform vec3 shape_color: source_color;
group_uniforms;

uniform float max_dist = 100.0;
uniform int max_steps = 100;

group_uniforms Mandelbulb;
uniform int iterations: hint_range(0, 10) = 1;
uniform float power = 1.0;
uniform float bailout = 1.0;
group_uniforms;



varying vec3 CAMERA_POSITION;
varying vec3 CAMERA_DIRECTION;
varying mat4 _CAMERA_MATRIX;
varying mat4 _INVERSE_PROJECTION;

struct Light {
	vec3 pos;
};



void vertex() {
	
	CAMERA_POSITION = CAMERA_POSITION_WORLD;
	CAMERA_DIRECTION = CAMERA_DIRECTION_WORLD;
	_INVERSE_PROJECTION = INV_PROJECTION_MATRIX;
	_CAMERA_MATRIX = INV_VIEW_MATRIX;
	POSITION = vec4(VERTEX, 1.0);
	
}

float sd_sphere(vec3 pos, vec3 sphere_pos, float r) {
	return length(pos) - r;
}

float sd_plane(vec3 pos, vec3 plane_pos) {
	return pos.y - plane_pos.y;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec2 smin( float a, float b, float k )
{
    float h = 1.0 - min( abs(a-b)/(4.0*k), 1.0 );
    float w = h*h;
    float m = w*0.5;
    float s = w*k;
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

float DE(vec3 pos) {	
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

vec4 get_dist(vec3 pos) {
	
	float sum = max_dist;
	vec3 color;	
	for (int i = 0; i < shapeCount; i++) {
		
		mat4 matrix = matrices[i];
		int type = types[i];
		float width = widths[i];
		float height = heights[i];
		float minInfluence = minInfluences[i];
		
		
		vec4 transformed4 = (matrix * vec4(pos, 1.0));
		vec3 transformed = transformed4.xyz / transformed4.w;
	
		float sdf;
	
		switch (type) {
			case 0:
				sdf = sd_sphere(transformed, vec3(0.0), width);
				break;
			case 1:
				sdf = sdBox(transformed, vec3(1.0));
				break;
		};
		
		vec2 _min = smin(sum, sdf, minInfluence);
		if (color == vec3(-1.0)) {

			color = colors[i];
			
		} else {
			
			color = mix(color, colors[i], _min.y);
			
		}
		sum = _min.x;
	}
	
	return vec4(color, sum);
} 


vec3 get_normal(vec3 pos) {
	float epsilon = 0.001;
	vec2 epsilonVec = vec2(epsilon, 0.0);
	
	float curr_dist = get_dist(pos).w;
	
	float x = get_dist(pos - epsilonVec.xyy).w;
	float y = get_dist(pos - epsilonVec.yxy).w;
	float z = get_dist(pos - epsilonVec.yyx).w;
	
	return normalize(curr_dist - vec3(x, y, z));
}



Light create_light(vec3 pos) {
	
	Light light;
	light.pos = pos;
	
	
	return light;
}

vec4 RayMarch(vec3 ro, vec3 rd) {
	
	float dist_marched = 0.0;
	const float min_dist = 0.001;
	int steps = 0;
	
	vec3 result_color;
	
	for (int i = 0; i < max_steps; i++) {
		steps = i;
		vec3 currPos = ro + rd * dist_marched;
		vec4 dist_result = get_dist(currPos);
		result_color = dist_result.xyz;
		float currDist = dist_result.w;
		dist_marched += currDist;
		
		if (dist_marched >= max_dist || currDist <= min_dist) {
			break;
		}
		
	}
	
	return vec4(result_color, dist_marched);
	
}

float get_light(vec3 pos, Light light) {
	
	vec3 toLight = light.pos - pos;
	vec3 normal = get_normal(pos);
	
	float intensity = dot(normal, normalize(toLight));
	
	return intensity * light_intensity;
}

float get_shadow(vec3 pos, Light light) {
	vec3 toLight = light.pos - pos;
	vec3 dir = normalize(toLight);
	vec4 march_result = RayMarch(pos, dir);
	float march = march_result.w;
	
	float result = float(march * march > dot(toLight, toLight));
	result *= shadow_intensity;
	return result;
}



void fragment() {
	
	vec2 uv = SCREEN_UV;
	
	uv = (uv * 2.0) - 1.0;

	vec3 rd4 = (_INVERSE_PROJECTION * vec4(uv, .0, 1.0)).xyz;
	rd4 = (_CAMERA_MATRIX * vec4(rd4, 0)).xyz;
	rd4 = normalize(rd4);
	
	vec3 ro = CAMERA_POSITION;
	vec3 rd = rd4;
	vec4 march_result = RayMarch(ro, rd);
	float dist_marched = march_result.w;
	if (dist_marched > max_dist) {
		discard;
	}
	
	vec3 rayPos = ro + rd * dist_marched;
	
	Light light = create_light(vec3(0.0, 10.0, -5.0));
	
	vec3 col = march_result.xyz;
	
	vec3 normal = get_normal(rayPos);
	
	if (lightning) {
		float light = get_light(rayPos, light);
		col *= light;
	}
	
	if (shadows) {
		float shadow = get_shadow(rayPos - rd * 0.005, light);
		col = col * shadow;
	}
	
	//ALBEDO.xyz = mix((vec3(19, 0, 90)) / 255.0, vec3(3, 201, 136) / 255.0, col.x);
	ALBEDO.xyz = col;
}

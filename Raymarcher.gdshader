shader_type spatial;

uniform bool lightning = false;

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


float sd_sphere(vec3 pos, float r) {
	
	return length(pos) - r;
	
}

float get_dist(vec3 pos) {
	
	float sphere = sd_sphere(pos, 1.0);
	
	return sphere;
	
} 

vec3 get_normal(vec3 pos) {
	
	
	float epsilon = 0.01;
	vec2 epsilonVec = vec2(epsilon, 0.0);
	
	float x = get_dist(pos + epsilonVec.xyy);
	float y = get_dist(pos + epsilonVec.yxy);
	float z = get_dist(pos + epsilonVec.yyx);
	
	return normalize(vec3(x, y, z));
}



Light create_light(vec3 pos) {
	
	Light light;
	light.pos = pos;
	
	
	return light;
}

float RayMarch(vec3 ro, vec3 rd) {
	
	float dist_marched = 0.0;
	const float max_dist = 100.0;
	const float min_dist = 0.001;
	for (int i = 0; i < 50; i++) {
		
		vec3 currPos = ro + rd * dist_marched;
		float currDist = get_dist(currPos);
		
		dist_marched += currDist;
		
		if (dist_marched >= max_dist || currDist <= min_dist) {
			
			break;
			
		}
		
	}
	
	return dist_marched;
	
}

float get_light(vec3 pos, Light light) {
	
	vec3 toLight = light.pos - pos;
	vec3 normal = get_normal(pos);
	
	float intensity = dot(normal, normalize(toLight));
	
	return intensity;
}



void fragment() {
	
	vec2 uv = SCREEN_UV;
	
	uv = (uv * 2.0) - 1.0;

	
	vec3 rd4 = (_INVERSE_PROJECTION * vec4(uv, .0, 1.0)).xyz;
	rd4 = (_CAMERA_MATRIX * vec4(rd4, 0)).xyz;
	rd4 = normalize(rd4);
	
	vec3 ro = CAMERA_POSITION;
	vec3 rd = rd4;
	float max_dist = 100.0;
	float dist_marched = RayMarch(ro, rd);
	if (dist_marched >= max_dist) {
		discard;
	}
	
	vec3 rayPos = ro + rd * dist_marched;
	
	Light light = create_light(vec3(5.0));
	
	
	
	vec3 col = vec3(dist_marched * 0.1);
	
	vec3 normal = get_normal(rayPos);
	
	if (lightning) {
		float lightIntensity = get_light(rayPos, light);
		col *= lightIntensity;
	}
	col *= vec3(1.0, 0.0, 0.0);
	// Called for every pixel the material is visible on.
	ALBEDO.xyz = col;
}

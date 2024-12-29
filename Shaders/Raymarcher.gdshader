shader_type spatial;

render_mode unshaded, fog_disabled;

#include "res://Shaders/includes/sdfs.gdshaderinc"
#include "includes/math.gdshaderinc"

uniform int shapeCount = 10;
uniform int lightsCount = 10;
uniform float widths[100];
uniform float heights[100];
uniform float depths[100];
uniform int types[100];
uniform mat4 matrices[100];
uniform float minInfluences[100];
uniform vec3 colors[100];
uniform vec3 lights[100];
uniform int operations[100];

group_uniforms Lightning;
uniform bool lightning = true;
uniform bool shadows = true;
uniform float shadow_intensity: hint_range(0.0, 1.0, 0.1) = .1;
uniform vec3 shadow_color: source_color;
uniform float light_intensity: hint_range(0.0, 10.0, 0.1) = .1;
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

uniform sampler2D depth_texture : hint_depth_texture;

struct Light {
	vec3 pos;
};

struct RaymarchResult {
	vec4 color;
	float dist;
};

void vertex() {

	CAMERA_POSITION = CAMERA_POSITION_WORLD;
	CAMERA_DIRECTION = CAMERA_DIRECTION_WORLD;
	_INVERSE_PROJECTION = INV_PROJECTION_MATRIX;
	_CAMERA_MATRIX = INV_VIEW_MATRIX;
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);

}

vec4 get_dist(vec3 pos) {

	float sum = max_dist;
	vec3 color;
	for (int i = 0; i < shapeCount; i++) {

		mat4 matrix = matrices[i];
		int type = types[i];
		float width = widths[i];
		float height = heights[i];
		float depth = depths[i];
		int operation = operations[i];
		float minInfluence = minInfluences[i];

		vec4 transformed4 = (matrix * vec4(pos, 1.0));
		vec3 transformed = transformed4.xyz / transformed4.w;

		float sdf;
			
		switch (type) {
			// Sphere
			case 0:
				sdf = sd_sphere(transformed, vec3(0.0), width);
				break;
			// Cube
			case 1:
				sdf = sd_box(transformed, vec3(width, height, depth));
				break;
			// Mandelbulb
			case 2:
				sdf = DE(transformed, iterations, bailout, power);
				break;
			// Capped Cone
			case 3:
				sdf = sd_capped_cone(transformed, vec3(0.0, height, 0.0), vec3(0.0, -height, 0.0), width, width * 2.0);
				break;
		};
		
		vec2 _min;
		
		switch (operation) {
			case 0:
				_min = s_union(sum, sdf, minInfluence);
				break;
			case 1:
				_min = vec2(s_intersection(sum, sdf, minInfluence));
				break;
			case 2:
				_min = vec2(s_subtraction(sum, sdf, minInfluence));
				break;
		}
		
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

RaymarchResult RayMarch(vec3 ro, vec3 rd) {

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
	
	RaymarchResult result = RaymarchResult(vec4(result_color, 1.0), dist_marched);

	return result;

}

float get_light(vec3 pos) {
	float intensity = 0.0;

	for (int i = 0; i < lightsCount; i++) {

		vec3 currLight = lights[i];

		vec3 toLight = currLight - pos;
		vec3 normal = get_normal(pos);
		float dist = length(toLight);
		intensity += dot(normal, normalize(toLight));
	}

	intensity = clamp(intensity, 0.0, 1.0);

	return intensity;
}

float get_shadow(vec3 pos) {
	float totalResult = 0.0;
	
	for (int i = 0; i < lightsCount; i++) {
		
		Light light = create_light(lights[i]);
		
		vec3 toLight = light.pos - pos;
		vec3 dir = normalize(toLight);
		RaymarchResult march_result = RayMarch(pos, dir);
		float march = march_result.dist;
		totalResult = max(float(march * march > dot(toLight, toLight)), totalResult);
	}
	
	return totalResult * shadow_intensity;
}

void fragment() {

	vec2 uv = SCREEN_UV;

	uv = (uv * 2.0) - 1.0;

	float depth = texture(depth_texture, SCREEN_UV).x;

	vec3 ndc = vec3(uv, depth);
	vec4 view = _INVERSE_PROJECTION *  vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z / 4000.0;
	vec3 rd4 = view.xyz;
	rd4 = (_CAMERA_MATRIX * vec4(rd4, 0)).xyz;
	rd4 = normalize(rd4);

	vec3 ro = CAMERA_POSITION;
	vec3 rd = rd4;
	RaymarchResult march_result = RayMarch(ro, rd);
	float dist_marched = march_result.dist;
	float march_percent = dist_marched / 4000.0;
	
	if (dist_marched > max_dist || march_percent > linear_depth) {
		discard;
	}
	
	vec3 rayPos = ro + rd * dist_marched;


	vec4 col = march_result.color;

	if (lightning) {
		float light = max(get_light(rayPos), 0.05);
		col *= light * light_intensity;
	}

	if (shadows) {
		float shadow = get_shadow(rayPos - rd * 0.005);
		col *= shadow;
	}
	
	ALBEDO.xyz = vec3(col.xyz);
}

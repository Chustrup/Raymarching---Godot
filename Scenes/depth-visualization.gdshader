shader_type spatial;

render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D depth_texture: hint_depth_texture;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void fragment() {
	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc =  vec3(SCREEN_UV * 2.0 - 1.0, depth);

	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

	ALBEDO.xyz = vec3(linear_depth / 2.0);

}



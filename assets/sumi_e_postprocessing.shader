shader_type canvas_item;

uniform float k;
uniform float power;
uniform float paper_mix_value : hint_range(0, 1);
uniform sampler2D paper_texture : hint_black;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	mat3 gauss_kernel = 1./16. * mat3(vec3(1., 2., 1.), vec3(2., 4., 2.), vec3(1., 2., 1.));
	
	vec3 col = vec3(0);
	col += texture(TEXTURE, UV + vec2(k*-1.*TEXTURE_PIXEL_SIZE.x, k*-1.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[0][0];
	col += texture(TEXTURE, UV + vec2(k*-1.*TEXTURE_PIXEL_SIZE.x, k*0.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[0][1];
	col += texture(TEXTURE, UV + vec2(k*-1.*TEXTURE_PIXEL_SIZE.x, k*1.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[0][2];
	
	col += texture(TEXTURE, UV + vec2(k*0.*TEXTURE_PIXEL_SIZE.x, k*-1.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[1][0];
	col += texture(TEXTURE, UV + vec2(k*0.*TEXTURE_PIXEL_SIZE.x, k*0.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[1][1];
	col += texture(TEXTURE, UV + vec2(k*0.*TEXTURE_PIXEL_SIZE.x, k*1.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[1][2];
	
	col += texture(TEXTURE, UV + vec2(k*1.*TEXTURE_PIXEL_SIZE.x, k*-1.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[2][0];
	col += texture(TEXTURE, UV + vec2(k*1.*TEXTURE_PIXEL_SIZE.x, k*0.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[2][1];
	col += texture(TEXTURE, UV + vec2(k*1.*TEXTURE_PIXEL_SIZE.x, k*1.*TEXTURE_PIXEL_SIZE.y)).rgb * gauss_kernel[2][2];
	
	vec3 filtered_col = vec3(pow(col.x, power), pow(col.y, power), pow(col.z, power));
	
	vec3 orig_color = texture(TEXTURE, UV).rgb;
	
	vec3 paper = texture(paper_texture, UV).rgb;
	vec3 fin_col = filtered_col * orig_color;
	fin_col = mix(filtered_col * orig_color, paper, paper_mix_value);
	
	vec3 hsv_fin = rgb2hsv(fin_col);
	hsv_fin.x *= 1.;
	fin_col = hsv2rgb(hsv_fin);
	
	COLOR.rgb = fin_col;
}
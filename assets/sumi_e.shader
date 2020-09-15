shader_type spatial;
render_mode specular_disabled;

uniform sampler2D paper_tex : hint_black;

uniform float silhouette_lower_bound : hint_range(0, 1);
uniform float silhouette_upper_bound : hint_range(0, 1);
uniform sampler2D brush_texture : hint_black;
uniform sampler2D diffuse_gradient_texture : hint_black;

void fragment() {
	float n_dot_view = dot(NORMAL, VIEW);
	n_dot_view = smoothstep(silhouette_lower_bound, silhouette_upper_bound, n_dot_view);
	vec3 silhouette = n_dot_view * vec3(1); // Extract  silhouette

	// Sphere mapping
	vec3 r = 2. * (dot(normalize(NORMAL), normalize(VERTEX))) * (normalize(NORMAL) - normalize(VERTEX));
	float m = 2.*sqrt(pow(r.x, 2.) + pow(r.y, 2.) + pow((r.z + 1.), 2.));
	vec2 uv_tex = vec2((r.x/m) + .5, (r.y/m) + .5);

	vec3 brush = texture(brush_texture, uv_tex).xyz;
	vec3 paper = texture(paper_tex, UV).rgb;

	ALBEDO = (silhouette + brush) * paper;
}

void light() {
	float diffuse = clamp(dot(NORMAL, LIGHT), 0., 1.);
	vec2 uv_diffuse = vec2(min(1., diffuse * (.3*ALBEDO.r + .59*ALBEDO.g + .11*ALBEDO.b)), .5);
	float diffuse_grad = texture(diffuse_gradient_texture, vec2(uv_diffuse)).x;
	DIFFUSE_LIGHT += diffuse_grad * ALBEDO * ATTENUATION;
}
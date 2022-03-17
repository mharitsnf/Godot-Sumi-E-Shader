shader_type spatial;
render_mode specular_disabled;

uniform vec4 albedo_col : hint_color;

uniform float metallic : hint_range(0, 1);
uniform float roughness : hint_range(0, 1);
uniform float subsurface_scattering_strength : hint_range(0, 1);

uniform sampler2D paper_tex : hint_black;

uniform float silhouette_lower_bound : hint_range(0, 1);
uniform float silhouette_upper_bound : hint_range(0, 1);
uniform sampler2D brush_texture : hint_black;
uniform sampler2D diffuse_gradient_texture : hint_black;

void fragment() {
	float n_dot_view = dot(NORMAL, VIEW);
	n_dot_view = smoothstep(silhouette_lower_bound, silhouette_upper_bound, n_dot_view);
	vec3 silhouette = vec3(n_dot_view); // Extract  silhouette

	// Sphere mapping
	vec3 r = 2. * dot(normalize(NORMAL), normalize(-VIEW)) * normalize(NORMAL) - normalize(-VIEW); // Refl vector
	float m = 2. * sqrt(r.x*r.x + r.y*r.y + ((r.z + 1.)*(r.z + 1.)));
	vec2 uv_tex = vec2((r.x/m) + .5, (r.y/m) + .5);

	vec3 brush = texture(brush_texture, uv_tex).xyz;
	vec3 paper = texture(paper_tex, uv_tex).rgb;

	ALBEDO = (brush * albedo_col.rgb) + (paper * .4);
//	ALBEDO = (silhouette * albedo_col.rgb) + (paper * .4);	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SSS_STRENGTH = subsurface_scattering_strength;
}

void light() {
	float diffuse = clamp(dot(NORMAL, LIGHT), 0., 1.);
	vec3 s_albedo = diffuse * ALBEDO;
	vec2 uv_diffuse = vec2(min(1., diffuse * (.3*ALBEDO.r + .59*ALBEDO.g + .11*ALBEDO.b)), .5);
	float diffuse_grad = texture(diffuse_gradient_texture, vec2(uv_diffuse)).x;
	DIFFUSE_LIGHT += diffuse_grad * s_albedo * ATTENUATION;
}
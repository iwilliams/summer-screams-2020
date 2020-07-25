shader_type spatial;

render_mode skip_vertex_transform;
render_mode blend_mix, depth_draw_always, cull_back ,diffuse_burley ,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform float metallic : hint_range(0,1);
uniform float roughness : hint_range(0,1);
uniform float specular : hint_range(0,1);
uniform vec4 emission : hint_color;
uniform float emission_energy : hint_range(0, 1);

uniform float normal_scale : hint_range(-16,16);

uniform sampler2D albedoTex : hint_albedo;
uniform sampler2D normal_tex : hint_normal;

uniform float texture_scale : hint_range(1,10);
uniform float snap_scale;

// Added
uniform float cull_distance : hint_range(0, 100) = 5;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform float resolution = 256;
varying vec4 vertex_coordinates;
uniform bool use_normal_mapping = false; // possible performance improvement if not needed

varying vec4 uv;

vec4 vertex_jitter(vec4 snap, float ratio){
	vec4 vertex = snap;
	vertex.xyz = snap.xyz / snap.w;
	vertex.x = floor(snap_scale * vertex.x) / (snap_scale);
	vertex.y = floor(ratio * snap_scale * vertex.y) / (ratio * snap_scale);
	vertex.xyz *= snap.w;
	return vertex;
}

vec2 make_affine(vec4 p) {
	return p.xy / p.z;
}

//void vertex() {
//	vec4 vertex = vertex_jitter(
//		MODELVIEW_MATRIX * vec4(VERTEX, 1.),
//		VIEWPORT_SIZE.x / VIEWPORT_SIZE.y
//	);
//	VERTEX = vertex.xyz;
//    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.)).xyz;
//    uv = vec4(texture_scale * UV * VERTEX.z, VERTEX.z, 0.);
//}

void vertex() {
	UV = UV * uv_scale + uv_offset;

	float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));

//	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    VERTEX = vertex_jitter(
		MODELVIEW_MATRIX * vec4(VERTEX, 1.),
		VIEWPORT_SIZE.x / VIEWPORT_SIZE.y
	).xyz;
	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);

	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float nPos_w = (PROJECTION_MATRIX * vec4(NORMAL, 0.0)).w;
	NORMAL.xy = nPos_w * floor(resolution * NORMAL.xy / nPos_w) / resolution;

//	if (use_normal_mapping)
//		BINORMAL = (MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz;
//		float bnPos_w = (PROJECTION_MATRIX * vec4(BINORMAL, 0.0)).w;
//		BINORMAL.xy = bnPos_w * floor(resolution * BINORMAL.xy / bnPos_w) / resolution;
//
//		TANGENT = (MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz;
//		float tPos_w = (PROJECTION_MATRIX * vec4(TANGENT, 0.0)).w;
//		TANGENT.xy = tPos_w * floor(resolution * TANGENT.xy / tPos_w) / resolution;

	if (vertex_distance > cull_distance)
		VERTEX = vec3(.0);
        uv = vec4(texture_scale * UV * VERTEX.z, VERTEX.z, 0.);
}

void fragment() {
	ALBEDO = texture(albedoTex, make_affine(uv)).rgb * albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMALMAP = texture(normal_tex, make_affine(uv)).rgb;
	NORMALMAP_DEPTH = normal_scale;
	EMISSION = emission.rgb * emission_energy;
	ALPHA = textureLod(albedoTex, make_affine(uv), 0.).a;
}

//shader_type spatial; 
//render_mode skip_vertex_transform, diffuse_lambert_wrap;//, specular_phong;//, ambient_light_disabled;
//
//uniform vec4 color : hint_color;
//uniform sampler2D albedoTex : hint_albedo;
//uniform float specular_intensity : hint_range(0, 1);
//uniform float resolution = 256;
//uniform float cull_distance = 5;
//uniform vec2 uv_scale = vec2(1.0, 1.0);
//uniform vec2 uv_offset = vec2(.0, .0);
//
//varying vec4 vertex_coordinates;
//
//void vertex() {
//	UV = UV * uv_scale + uv_offset;
//
//	float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
//
//	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
//	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
//	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
//	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);
//
//	if (vertex_distance > cull_distance)
//		VERTEX = vec3(.0);
//}
//
//void fragment() {
//	vec4 tex = texture(albedoTex, vertex_coordinates.xy / vertex_coordinates.z);
//
//	ALBEDO = tex.rgb * color.rgb;
//	SPECULAR = specular_intensity;
//}

shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap;//, specular_phong;//, ambient_light_disabled;

uniform vec4 color : hint_color;
uniform sampler2D albedoTex : hint_albedo;
uniform float specular_intensity : hint_range(0, 1) = 0.5;
uniform float resolution = 256;
uniform float cull_distance = 25;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform bool affine = true;
uniform bool use_normal_mapping = false; // possible performance improvement if not needed

varying vec4 vertex_coordinates;

void vertex() {
	UV = UV * uv_scale + uv_offset;

	float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));

	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);

	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float nPos_w = (PROJECTION_MATRIX * vec4(NORMAL, 0.0)).w;
	NORMAL.xy = nPos_w * floor(resolution * NORMAL.xy / nPos_w) / resolution;

	if (use_normal_mapping)
		BINORMAL = (MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz;
		float bnPos_w = (PROJECTION_MATRIX * vec4(BINORMAL, 0.0)).w;
		BINORMAL.xy = bnPos_w * floor(resolution * BINORMAL.xy / bnPos_w) / resolution;

		TANGENT = (MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz;
		float tPos_w = (PROJECTION_MATRIX * vec4(TANGENT, 0.0)).w;
		TANGENT.xy = tPos_w * floor(resolution * TANGENT.xy / tPos_w) / resolution;

	if (vertex_distance > cull_distance)
		VERTEX = vec3(.0);
}

void fragment() {
	vec4 tex;
	if (affine) {
		tex = texture(albedoTex, vertex_coordinates.xy / vertex_coordinates.z);
	} else {
 		tex = texture(albedoTex, vec2(UV.x, UV.y));
	}

	ALBEDO = tex.rgb * color.rgb;
	SPECULAR = specular_intensity;
}
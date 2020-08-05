shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap, specular_phong, shadows_disabled;

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
//Geometric resolution for vert sna[
uniform float snapRes = 50.0;


void vertex() {
	UV = UV * uv_scale + uv_offset;
	

    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.xyz = floor(VERTEX.xyz * snapRes) / snapRes;
    float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));

//	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
//	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);
	
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
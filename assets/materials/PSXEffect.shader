shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap, specular_phong, shadows_disabled;

uniform vec4 color : hint_color;
uniform sampler2D albedoTex : hint_albedo;
//uniform float resolution = 256;

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform bool affine = true;

const float snapRes = 50.0;
const float cull_distance = 30.;

varying vec4 vertex_coordinates;

void vertex() {
	UV = UV * uv_scale + uv_offset;
	

    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.xyz = floor(VERTEX.xyz * snapRes) / snapRes;
    float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
//
//	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
//	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);
	
	if (vertex_distance > cull_distance)
		VERTEX = vec3(.0);
        
//    if (!OUTPUT_IS_SRGB) {
//		COLOR.rgb = mix( pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb* (1.0 / 12.92), lessThan(COLOR.rgb,vec3(0.04045)) );
//	}
}

void fragment() {
	vec4 tex;
	if (affine) {
		tex = texture(albedoTex, vertex_coordinates.xy / vertex_coordinates.z);
	} else {
 		tex = texture(albedoTex, vec2(UV.x, UV.y));
	}
	
	ALBEDO = tex.rgb * COLOR.rgb * color.rgb;
}
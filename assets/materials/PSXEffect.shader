shader_type spatial;
render_mode skip_vertex_transform, diffuse_lambert_wrap, shadows_disabled;

uniform vec4 color : hint_color;
uniform vec4 emission: hint_color;
uniform sampler2D albedoTex : hint_albedo;
uniform sampler2D albedoTex2 : hint_albedo;
//uniform float resolution = 256;

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform bool affine = true;
uniform bool vertexColorBlend = false;
uniform bool breathe = false;

const float snapRes = 35.0;
const float cull_distance = 30.;

varying vec4 vertex_coordinates;

uniform bool posterize = true;
//Gamma
uniform float gamma = 0.6;
//Number of colors for posterization
uniform float numColors = 24.0;

void vertex() {
	UV = UV * uv_scale + uv_offset;

    if (breathe) {
        float scaler = 1.;
        if (vertexColorBlend) {
            scaler *= COLOR.r;
        }
        UV = UV + (sin(TIME)*(.05*scaler));   
    }
	

    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.xyz = floor(VERTEX.xyz * snapRes) / snapRes;
    float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
//
//	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
//	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);
	
//	if (vertex_distance > cull_distance)
//		VERTEX = vec3(.0);
        
//    if (!OUTPUT_IS_SRGB) {
//		COLOR.rgb = mix( pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb* (1.0 / 12.92), lessThan(COLOR.rgb,vec3(0.04045)) );
//	}
}

void fragment() {
	vec4 tex;
    vec2 uvCoords;
    
	if (affine) {
        uvCoords = mix(vertex_coordinates.xy / vertex_coordinates.z, UV.xy, .7);
	} else {
 		uvCoords = vec2(UV.x, UV.y);
	}
    tex = texture(albedoTex, uvCoords);

    vec3 c;

    if (vertexColorBlend) {
        vec4 tex2 = texture(albedoTex2, uvCoords);
        c = mix(tex2, tex, COLOR.r).rgb;
    } else {
	   c = tex.rgb * COLOR.rgb * color.rgb;
    }
    
    if (posterize) {
        c = pow(c, vec3(gamma, gamma, gamma));
        c = c * numColors;
        c = floor(c);
        c = c / numColors;
        c = pow(c, vec3(1.0/gamma));
    }
	ALBEDO = c;
    
    
    EMISSION = emission.rgb;
}
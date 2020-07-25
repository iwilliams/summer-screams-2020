shader_type spatial;

//render_mode unshaded;
render_mode unshaded, depth_draw_always, cull_disabled;

uniform sampler2D albedoTex : hint_albedo;
uniform sampler2D alphaTex : hint_albedo;

void vertex() {
    UV.x = UV.x + 1. * TIME;
}

void fragment() {
    ALBEDO = vec3(COLOR[0], COLOR[1], COLOR[2]);
//    ALBEDO = texture(albedoTex, UV).rgb;
    ALPHA = mix(.2, 1., texture(alphaTex, UV).r);
}
shader_type canvas_item;

// --- BIOME RENKLERİ ---
uniform vec4 grass_color  : source_color = vec4(0.0, 0.537, 0.149, 1.0);
uniform vec4 desert_color : source_color = vec4(0.878, 0.753, 0.333, 1.0);
uniform vec4 snow_color   : source_color = vec4(0.937, 1.0, 1.0, 1.0);

// --- MESAFE SINIRLARI ---
uniform float grass_limit  = 3000.0;
uniform float desert_limit = 6000.0;
uniform float snow_limit   = 15000.0;

// --- KAMERA X (Game.gd'den set edeceğiz) ---
uniform float camera_x = 0.0;

// --- DOKU / DALGA AYARLARI ---
uniform float noise_scale     = 7.0;
uniform float noise_strength  = 0.12;
uniform float wave_strength   = 0.06;  // 0.03 - 0.10 arası ideal
uniform float wave_freq       = 12.0;  // büyüdükçe dalga sıklaşır
uniform float top_light       = 1.08;  // üst taraf aydınlık
uniform float bottom_dark     = 0.88;  // alt taraf koyu

float hash(vec2 p){
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p){
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f*f*(3.0-2.0*f);
	return mix(a, b, u.x) + (c - a)*u.y*(1.0 - u.x) + (d - b)*u.x*u.y;
}

void fragment() {
	// Dünya X hesabı (daha stabil): ekranın sol kenarı + UV.x * ekran genişliği
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float world_x = camera_x - (screen_size.x * 0.5) + (UV.x * screen_size.x);

	vec4 base_color;

	if (world_x < grass_limit)      base_color = grass_color;
	else if (world_x < desert_limit) base_color = desert_color;
	else                            base_color = snow_color;

	// Üstten alta gradient (zemin düz görünmesin)
	float grad = mix(top_light, bottom_dark, UV.y);

	// Noise (zemin dokusu)
	float n = noise(UV * noise_scale);

	// Hafif dalga/topografya hissi
	float w = sin((UV.x * wave_freq) + TIME * 0.4) * 0.5 + 0.5;

	float tex = (n - 0.5) * noise_strength + (w - 0.5) * wave_strength;

	COLOR = base_color * (grad + tex);
}

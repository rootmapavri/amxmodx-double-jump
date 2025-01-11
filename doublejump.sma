#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGIN_NAME "Double Jump"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "Alazul"

#define ADMIN_ACCESS ADMIN_CHAT

new jump_count[33] = {0}; // Oyuncunun zıplama sayısını tutar
new bool:can_jump[33] = {false}; // Zıplama durumu

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR); // Bu satır kaldırıldı
    register_cvar("amx_maxjumps", "1"); // Maksimum zıplama sayısı
    register_cvar("amx_mjadminonly", "0"); // Yalnızca adminler için
}

public client_putinserver(id)
{
    jump_count[id] = 0; // Oyuncu sunucuya girdiğinde zıplama sayısını sıfırla
    can_jump[id] = false; // Zıplama durumunu sıfırla
}

public client_disconnect(id)
{
    jump_count[id] = 0; // Oyuncu sunucudan çıktığında zıplama sayısını sıfırla
    can_jump[id] = false; // Zıplama durumunu sıfırla
}

public client_PreThink(id)
{
    if (!is_user_alive(id)) return PLUGIN_CONTINUE; // Oyuncu hayatta değilse devam etme
    if (get_cvar_num("amx_mjadminonly") && !access(id, ADMIN_ACCESS)) return PLUGIN_CONTINUE; // Admin kontrolü

    new current_buttons = get_user_button(id); // Yeni buton durumu
    new previous_buttons = get_user_oldbutton(id); // Eski buton durumu

    // Zıplama butonuna basıldıysa ve oyuncu havadaysa
    if ((current_buttons & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(previous_buttons & IN_JUMP))
    {
        if (jump_count[id] < get_cvar_num("amx_maxjumps")) // Maksimum zıplama sayısını kontrol et
        {
            can_jump[id] = true; // Zıplama yapılacak
            jump_count[id]++; // Zıplama sayısını artır
        }
    }

    // Oyuncu yere düştüyse zıplama sayısını sıfırla
    if ((current_buttons & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
    {
        jump_count[id] = 0; // Zıplama sayısını sıfırla
    }

    return PLUGIN_CONTINUE; // Devam et
}

public client_PostThink(id)
{
    if (!is_user_alive(id)) return PLUGIN_CONTINUE; // Oyuncu hayatta değilse devam etme
    if (get_cvar_num("amx_mjadminonly") && !access(id, ADMIN_ACCESS)) return PLUGIN_CONTINUE; // Admin kontrolü

    if (can_jump[id]) // Zıplama durumu kontrolü
    {
        new Float:velocity[3];	
        entity_get_vector(id, EV_VEC_velocity, velocity); // Mevcut hızı al
        velocity[2] = random_float(265.0, 285.0); // Zıplama yüksekliğini ayarla
        entity_set_vector(id, EV_VEC_velocity, velocity); // Yeni hızı uygula
        can_jump[id] = false; // Zıplama durumu sıfırla
    }

    return PLUGIN_CONTINUE; // Devam et
}

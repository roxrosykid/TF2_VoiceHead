#include <sourcemod>
#include <sdktools>
#include <clientprefs>

new Handle:g_hHeadScaleTimers[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};
new Float:g_fHeadScale[MAXPLAYERS + 1] = {1.0, ...};
new bool:g_bHeadEnlargementEnabled[MAXPLAYERS + 1] = {true, ...};

new Handle:g_hCookie_HeadEnlargement = INVALID_HANDLE;
new Handle:g_hCvar_SineWaveFrequency = INVALID_HANDLE;
new Handle:g_hCvar_SineWaveAmplitude = INVALID_HANDLE;
new Handle:g_hCvar_BaseScale = INVALID_HANDLE;

new Float:g_fSineWaveFrequency = 25.0;
new Float:g_fSineWaveAmplitude = 0.4;
new Float:g_fBaseScale = 1.5;

public Plugin myinfo = 
{
    name = "[TF2] VoiceHead",
    author = "roxrosykid",
    description = "Change players head dynamically, as they speak.",
    version = "1.0.4",
    url = "https://github.com/roxrosykid"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);
    
    g_hCookie_HeadEnlargement = RegClientCookie("head_enlargement_enabled", "Toggle head enlargement", CookieAccess_Public);
    
    SetCookieMenuItem(CookieMenu_HeadEnlargement, 0, "Head Enlargement");
    
    g_hCvar_SineWaveFrequency = CreateConVar("sm_headscale_frequency", "", "Frequency of the sine wave", FCVAR_NONE, true, 0.0);
    g_hCvar_SineWaveAmplitude = CreateConVar("sm_headscale_amplitude", "0.4", "Amplitude of the sine wave", FCVAR_NONE, true, 0.0);
    g_hCvar_BaseScale = CreateConVar("sm_headscale_base_scale", "1.5", "Base scale when the player starts speaking", FCVAR_NONE, true, 0.0);
    
    HookConVarChange(g_hCvar_SineWaveFrequency, OnCvarChanged);
    HookConVarChange(g_hCvar_SineWaveAmplitude, OnCvarChanged);
    HookConVarChange(g_hCvar_BaseScale, OnCvarChanged);
    
    AutoExecConfig(true, "head_scale_wobble");
}

public void OnConfigsExecuted()
{
    g_fSineWaveFrequency = GetConVarFloat(g_hCvar_SineWaveFrequency);
    g_fSineWaveAmplitude = GetConVarFloat(g_hCvar_SineWaveAmplitude);
    g_fBaseScale = GetConVarFloat(g_hCvar_BaseScale);
}

public void OnCvarChanged(Handle hCvar, const char[] oldValue, const char[] newValue)
{
    if (hCvar == g_hCvar_SineWaveFrequency)
    {
        g_fSineWaveFrequency = StringToFloat(newValue);
    }
    else if (hCvar == g_hCvar_SineWaveAmplitude)
    {
        g_fSineWaveAmplitude = StringToFloat(newValue);
    }
    else if (hCvar == g_hCvar_BaseScale)
    {
        g_fBaseScale = StringToFloat(newValue);
    }
}

public void OnClientSpeaking(int client)
{
    if (!IsPlayerAlive(client) || !g_bHeadEnlargementEnabled[client])
        return;

    if (g_hHeadScaleTimers[client] == INVALID_HANDLE)
    {
        g_fHeadScale[client] = g_fBaseScale;
        g_hHeadScaleTimers[client] = CreateTimer(0.1, Timer_UpdateHeadScale, client, TIMER_REPEAT);
    }
}

public void OnClientSpeakingEnd(int client)
{
    if (g_hHeadScaleTimers[client] != INVALID_HANDLE)
    {
        KillTimer(g_hHeadScaleTimers[client]);
        g_hHeadScaleTimers[client] = INVALID_HANDLE;
        SetEntPropFloat(client, Prop_Send, "m_flHeadScale", 1.0);
    }
}

public Action Timer_UpdateHeadScale(Handle timer, any client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        g_hHeadScaleTimers[client] = INVALID_HANDLE;
        return Plugin_Stop;
    }

    float time = GetGameTime();
    float scale = g_fBaseScale + g_fSineWaveAmplitude * Sine(g_fSineWaveFrequency * time);

    SetEntPropFloat(client, Prop_Send, "m_flHeadScale", scale);

    return Plugin_Continue;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && g_hHeadScaleTimers[client] != INVALID_HANDLE)
    {
        KillTimer(g_hHeadScaleTimers[client]);
        g_hHeadScaleTimers[client] = INVALID_HANDLE;
        SetEntPropFloat(client, Prop_Send, "m_flHeadScale", 1.0);
    }
}

public void OnClientDisconnect(int client)
{
    if (g_hHeadScaleTimers[client] != INVALID_HANDLE)
    {
        KillTimer(g_hHeadScaleTimers[client]);
        g_hHeadScaleTimers[client] = INVALID_HANDLE;
    }
}

public void OnClientCookiesCached(int client)
{
    char sCookieValue[8];
    GetClientCookie(client, g_hCookie_HeadEnlargement, sCookieValue, sizeof(sCookieValue));
    g_bHeadEnlargementEnabled[client] = (sCookieValue[0] == '\0' || StringToInt(sCookieValue) != 0);
}

public void CookieMenu_HeadEnlargement(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
    if (action == CookieMenuAction_DisplayOption)
    {
        // No need to do anything here
    }
    else if (action == CookieMenuAction_SelectOption)
    {
        SendHeadEnlargementMenu(client);
    }
}

public void SendHeadEnlargementMenu(int client)
{
    Menu menu = new Menu(HeadEnlargementMenuHandler);
    menu.SetTitle("VoiceHead Settings");
    
    char sOption[64];
    if (g_bHeadEnlargementEnabled[client])
    {
        Format(sOption, sizeof(sOption), "Enabled (Current)");
    }
    else
    {
        Format(sOption, sizeof(sOption), "Disabled (Current)");
    }
    
    menu.AddItem("toggle", sOption);
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int HeadEnlargementMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        char sInfo[16];
        menu.GetItem(param2, sInfo, sizeof(sInfo));
        
        if (StrEqual(sInfo, "toggle"))
        {
            g_bHeadEnlargementEnabled[param1] = !g_bHeadEnlargementEnabled[param1];
            SetClientCookie(param1, g_hCookie_HeadEnlargement, g_bHeadEnlargementEnabled[param1] ? "1" : "0");
            PrintToChat(param1, "[SM] Voice head reaction is now %s", g_bHeadEnlargementEnabled[param1] ? "Enabled" : "Disabled");
        }
        
        SendHeadEnlargementMenu(param1);
    }
    else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
    {
        ShowCookieMenu(param1);
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    return 1;
}
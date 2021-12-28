#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_hud_util;

main()
{
	replacefunc(maps/mp/zombies/_zm::fade_out_intro_screen_zm, ::fade_out_intro_screen_zm);
	replacefunc(maps/mp/zombies/_zm::init, ::init_zm);
	replacefunc(maps/mp/zombies/_zm_perks::give_perk, ::give_perk);
	replacefunc(maps/mp/zombies/_zm_perks::perk_think, ::perk_think);
}

init()
{
	PrecacheShader("hud_grenadeicon");
	PrecacheShader("hud_cymbal_monkey");
	PrecacheShader("hud_empgrenade");
	PrecacheShader("hud_us_grenade");
	PrecacheShader("damage_feedback");
	PrecacheShader("hud_obit_death_suicide");
	PrecacheShader("hud_obit_death_falling");
	PrecacheShader("hud_obit_death_crush");
	PrecacheShader("hud_obit_knife");
	PrecacheShader("hud_obit_ballistic_knife");
	PrecacheShader("hud_obit_death_grenade_round");
	PrecacheShader("hud_obit_hatchet");
	onplayerconnect_callback( ::player_connect_hud );
}

player_connect_hud()
{
	self.weaponTierBackground = self createIcon("progress_bar_bg", 116, 15);
	self.weaponTierBackground SetPoint("CENTER", "BOTTOM_RIGHT", -123, 18);
	self.weaponTierBackground.sort = -3;
	self.weaponTierBackground.hidewheninmenu = 1;
	self.weaponTierBackground.alpha = 0.6;
	self.weaponTierBackground.color = ( 1, 0, 0 );
	self.weaponTierBackground.foreground = 1;

	self.weapon_name_hud = self CreateFontString("Objective", 1);
	self.weapon_name_hud SetPoint("RIGHT", "BOTTOM_RIGHT", -67, 18);
	self.weapon_name_hud.hidewheninmenu = 1;
	self.weapon_name_hud.foreground = 1;

	self.AmmoBackground = self createIcon("progress_bar_bg", 35, 25);
	self.AmmoBackground SetPoint("RIGHT", "BOTTOM_RIGHT", -65, 0);
	self.AmmoBackground.sort = -3;
	self.AmmoBackground.hidewheninmenu = 1;
	self.AmmoBackground.alpha = 0.6;
	self.AmmoBackground.color = ( 0, 0, 0 );
	self.AmmoBackground.foreground = 1;

	self.stockValue = self CreateFontString("default", 1.7);
	self.stockValue SetPoint("RIGHT", "BOTTOM_RIGHT", -69, 0);
	self.stockValue.hidewheninmenu = 1;
	self.stockValue.foreground = 1;

	self.clipValue = self CreateFontString("default", 2.4);
	self.clipValue SetPoint("RIGHT", "BOTTOM_RIGHT", -105, -0.55);
	self.clipValue.hidewheninmenu = 1;
	self.clipValue.sort = 1;
	self.clipValue.foreground = 1;

	self.lhclipValue = self CreateFontString("default", 1.6);
	self.lhclipValue SetParent(self.clipValue);
	self.lhclipValue SetPoint("RIGHT", "CENTER", -25, 0);
	self.lhclipValue.hidewheninmenu = 1;
	self.lhclipValue.sort = 1;
	self.lhclipValue.alpha = 0;
	self.lhclipValue.foreground = 1;

	self.fragIcon = self createIcon("hud_grenadeicon", 20, 20);
	self.fragIcon SetPoint("CENTER", "BOTTOM_RIGHT", 0, 10);
	self.fragIcon.hidewheninmenu = 1;
	self.fragIcon.alpha = 1;
	self.fragIcon.foreground = 1;

	self.tacticalIcon = self createIcon("hud_cymbal_monkey", 20, 20);
	self.tacticalIcon SetPoint("CENTER", "BOTTOM_RIGHT", -30, 10);
	self.tacticalIcon.hidewheninmenu = 1;
	self.tacticalIcon.shader = "hud_cymbal_monkey";
	self.tacticalIcon.alpha = 1;
	self.tacticalIcon.foreground = 1;

	//LEFT SIDE

	self.scoreValue = self CreateFontString("default", 1);
	self.scoreValue SetPoint("LEFT", "BOTTOM_LEFT", -38, -6);
	self.scoreValue.label = &"^3$   ^7";
	self.scoreValue.hidewheninmenu = 1;
	self.scoreValue.foreground = 1;

	self.playerNameHud = self CreateFontString("default", 1);
	self.playerNameHud SetPoint("LEFT", "BOTTOM_LEFT", -45, 18);
	self.playerNameHud.label = &"^6*  ^7";
	self.playerNameHud.hidewheninmenu = 1;
	self.playerNameHud SetText(self.name);
	self.playerNameHud.foreground = 1;

	self.healthValue = self CreateFontString("default", 1.2);
	self.healthValue SetPoint("LEFT", "BOTTOM_LEFT", 46, 4);
	self.healthValue.hidewheninmenu = 1;
	self.healthValue.foreground = 1;

	/*self.healthBar = self createBar((1,1,1), 78, 3);
	self.healthBar SetPoint("CENTER", "BOTTOM_LEFT", -3, 7);
	self.healthBar.hidewheninmenu = 1;
	self.healthBar.bar.hidewheninmenu = 1;
	self.healthBar.foreground = 1;
	self.healthBar.bar.foreground = 1;*/
	self.healthBar = NewClientHudElem(self);
	self.healthBar.x = 0;
	self.healthBar.y = 0;
	self.healthBar setshader( "progress_bar_fill", 78, 3 );
	//self.healthBar SetPoint("CENTER", "BOTTOM_LEFT", -3, 7);
	self.healthBar.alignx = "left";
	self.healthBar.aligny = "middle";
	self.healthBar.horzalign = "left";
	self.healthBar.vertalign = "bottom";
	self.healthBar.x += -42;
	self.healthBar.y += 7;
	self.healthBar.hidewheninmenu = 1;
	self.healthBar.width = 78;
	self.healthBar.height = 3;
	self.healthBar.color = (1,1,1);
	self.healthBar.sort = 0;
	self.healthBar.foreground = 1;

	self.healthBackground = self createIcon("progress_bar_bg", 80, 5);
	self.healthBackground SetPoint("CENTER", "BOTTOM_LEFT", -3, 7);
	self.healthBackground.sort = -3;
	self.healthBackground.hidewheninmenu = 1;
	self.healthBackground.alpha = 0.6;
	self.healthBackground.color = ( 0, 0, 0 );
	self.healthBackground.foreground = 1;

	self.cw_hitmarker = newClientHUDElem( self );
    self.cw_hitmarker.horzalign = "center";
    self.cw_hitmarker.vertalign = "middle";
    self.cw_hitmarker.x = -12;
    self.cw_hitmarker.y = -12;
    self.cw_hitmarker.alpha = 0;
    self.cw_hitmarker setshader( "damage_feedback", 24, 48 );
    self.cw_hitmarker.foreground = 1;

    self.powerup_hud = createIcon( "specialty_doublepoints_zombies", 32, 32 );
	self.powerup_hud SetPoint("CENTER", "BOTTOM", 0, -48);
	self.powerup_hud.alpha = 1;
	self.powerup_hud.hidewheninmenu = 1;
	self.powerup_hud.foreground = 1;
    self thread update_weapontier_hud();
	self thread update_hud();
}

update_hud()
{
	self endon("disconnect");
	level endon("end_game");
	while(1)
	{
		if(level.zombie_vars[ self.team ][ "zombie_powerup_insta_kill_on" ] == 1 && level.zombie_vars[ self.team ][ "zombie_powerup_point_doubler_on" ] == 1)
		{
			self.powerup_hud SetShader("specialty_instakill_zombies", 32, 32);
			self.powerup_hud.alpha = 1;
		}
		else if(level.zombie_vars[ self.team ][ "zombie_powerup_insta_kill_on" ] == 1 && level.zombie_vars[ self.team ][ "zombie_powerup_point_doubler_on" ] == 0)
		{
			self.powerup_hud SetShader("specialty_instakill_zombies", 32, 32);
			self.powerup_hud.alpha = 1;
		}
		else if(level.zombie_vars[ self.team ][ "zombie_powerup_insta_kill_on" ] == 0 && level.zombie_vars[ self.team ][ "zombie_powerup_point_doubler_on" ] == 1)
		{
			self.powerup_hud SetShader("specialty_doublepoints_zombies", 32, 32);
			self.powerup_hud.alpha = 1;
		}
		else
		{
			self.powerup_hud.alpha = 0;
		}
		if(self GetWeaponAmmoClip(self get_player_lethal_grenade()) > 0 && self.fragIcon.alpha == 0)
			self.fragIcon.alpha = 1;
		else if(self GetWeaponAmmoClip(self get_player_lethal_grenade()) <= 0 && self.fragIcon.alpha == 1)
			self.fragIcon.alpha = 0;
		if(self GetWeaponAmmoClip(self get_player_tactical_grenade()) > 0 && self.tacticalIcon.alpha == 0)
			self.tacticalIcon.alpha = 1;
		else if(self GetWeaponAmmoClip(self get_player_tactical_grenade()) <= 0 && self.tacticalIcon.alpha == 1)
			self.tacticalIcon.alpha = 0;
		if(self get_player_tactical_grenade() != "" && getTacShader(self get_player_tactical_grenade()) != self.tacticalIcon.shader)
		{
			tacShader = getTacShader(self get_player_tactical_grenade());
			self.tacticalIcon SetShader(tacShader, 20, 20);
			self.tacticalIcon.shader = tacShader;
		}
		self.healthBar SetShader("progress_bar_fill", int( ( 78 * (self.health / self.maxHealth) ) ), 3);
		//self.healthBar updateBar(self.health / self.maxhealth);
		if(isdefined(self.health))
			self.healthValue SetValue(self.health);
		if(isdefined(self.score))
			self.scoreValue SetValue(self.score);
		if(self GetCurrentWeapon() != "none")
		{
			self.stockValue SetValue(self GetWeaponAmmoStock(self GetCurrentWeapon()));
			self.clipValue SetValue(self GetWeaponAmmoClip(self GetCurrentWeapon()));
			self.lhclipValue SetValue(self GetWeaponAmmoClip(weapondualwieldweaponname(self GetCurrentWeapon())));
		}
		wait .1;
	}
}

getTacShader(weap)
{
	if(weap == "cymbal_monkey_zm")
		return "hud_cymbal_monkey";
	if(weap == "emp_grenade_zm")
		return "hud_empgrenade";
	if(weap == "beacon_zm")
		return "hud_homing_beacon";
}

update_weapontier_hud()
{
	self endon("disconnect");
	level endon("end_game");
	while(1)
	{
		self waittill("weapon_change");
		self.weapon_name_hud FadeOverTime(0.1);
		self.weapon_name_hud.alpha = 0;
		self.weaponTierBackground FadeOverTime(0.1);
		self.weaponTierBackground.alpha = 0;
		self.AmmoBackground FadeOverTime(0.1);
		self.AmmoBackground.alpha = 0;
		self.stockValue.alpha = 0;
		self.clipValue.alpha = 0;
		self.lhclipValue.alpha = 0;
		self waittill("weapon_change_complete");
		weapon = get_base_name(self GetCurrentWeapon());
		if(is_ultra_weapon(weapon))
		{
			self.weaponTiers[weapon] = 5;
		}
		if(is_true(self.weaponTiers[weapon] == 0))
		{
			self.weaponTierBackground.color = ( 1, 0, 0 );
		}
		else if(is_true(self.weaponTiers[weapon] == 1))
		{
			self.weaponTierBackground.color = ( 0, 1, 0 );
		}
		else if(is_true(self.weaponTiers[weapon] == 2))
		{
			self.weaponTierBackground.color = ( 0.29, 0.59, 1 );
		}
		else if(is_true(self.weaponTiers[weapon] == 3))
		{
			self.weaponTierBackground.color = ( 0.85, 0, 1 );
		}
		else if(is_true(self.weaponTiers[weapon] == 4))
		{
			self.weaponTierBackground.color = ( 1, 0.4, 0 );
		}
		else if(is_true(self.weaponTiers[weapon] == 5))
		{
			self.weaponTierBackground.color = ( 1, 1, 0 );
		}
		else
		{
			self.weaponTierBackground.color = (0,0,0);
		}
		if(is_true(self.weaponPapTiers[get_base_name(self GetCurrentWeapon())] > 0))
			displayName = "Level " + self.weaponPapTiers[get_base_name(self GetCurrentWeapon())] + " " + get_weapon_display_name(self GetCurrentWeapon());
		else
			displayName = get_weapon_display_name(self GetCurrentWeapon());
		if(displayName != "None")
		{
			self.weapon_name_hud SetText(displayName);
			self.weapon_name_hud FadeOverTime(0.1);
			self.weapon_name_hud.alpha = 1;
		}
		self.weaponTierBackground FadeOverTime(0.1);
		self.weaponTierBackground.alpha = 0.6;
		self.AmmoBackground FadeOverTime(0.1);
		self.AmmoBackground.alpha = 0.6;
		self.stockValue FadeOverTime(0.1);
		self.stockValue.alpha = 1;
		self.clipValue FadeOverTime(0.1);
		self.clipValue.alpha = 1;
		if(is_true(weapondualwieldweaponname(self GetCurrentWeapon()) != "none") && self.lhclipValue.alpha == 0)
		{
			self.lhclipValue FadeOverTime(0.1);
			self.lhclipValue.alpha = 1;
			self.clipValue.fontscale = 1.6;
		}
		else if(is_true(weapondualwieldweaponname(self GetCurrentWeapon()) == "none"))
		{
			self.clipValue.fontscale = 2.4;
		}
		else if(!isdefined(weapondualwieldweaponname(self GetCurrentWeapon())))
		{
			self.clipValue.fontscale = 2.4;
		}
	}
}

is_ultra_weapon(weapon)
{
	foreach(ultra in level.ultra_weapons)
		if(weapon == ultra)
			return 1;
	return 0;
}

init_zm() //checked matches cerberus output
{
	//notes
	/*
		since for loops with continues cause infinite loops for some unknown reason
		all for loops with continues are changed to while loops 
		the functionality is the same but i wish i could use for loops instead since
		it looks cleaner
	*/
	//begin debug code
	level.custom_zm_loaded = 1;
	maps/mp/zombies/_zm_bot::init();
	if ( !isDefined( level.debugLogging_zm ) )
	{
		level.debugLogging_zm = 0;
	}
	if ( !isDefined( level.disable_blackscreen_clientfield ) )
	{
		level.disable_blackscreen_clientfield = 0;
	}
	if ( !isDefined( level._no_equipment_activated_clientfield ) )
	{
		level._no_equipment_activated_clientfield = 0;
	}
	if ( !isDefined( level._no_navcards ) )
	{
		level._no_navcards = 0;
	}
	if ( !isDefined( level.use_clientside_board_fx ) )
	{
		level.use_clientside_board_fx = 1;
	}
	if ( !isDefined( level.disable_deadshot_clientfield ) )
	{
		level.disable_deadshot_clientfield = 0; //needs to be 0 even if the map doesn't have the perk
	}
	if ( !isDefined( level.use_clientside_rock_tearin_fx ) )
	{
		level.use_clientside_rock_tearin_fx = 1;
	}
	if ( !isDefined( level.no_end_game_check ) )
	{
		level.no_end_game_check = 0;
	}
	if ( !isDefined( level.noroundnumber ) )
	{
		level.noroundnumber = 0;
	}
	if ( !isDefined( level.host_ended_game ) )
	{
		level.host_ended_game = 0;
	}
	if ( !isDefined( level.zm_disable_recording_stats ) )
	{
		level.zm_disable_recording_stats = 0;
	}
	//end debug code
	level.player_out_of_playable_area_monitor = 1;
	level.player_too_many_weapons_monitor = 1;
	level.player_too_many_weapons_monitor_func = ::player_too_many_weapons_monitor;
	level.player_too_many_players_check = 0; 
	level.player_too_many_players_check_func = ::player_too_many_players_check;
	level._use_choke_weapon_hints = 1;
	level._use_choke_blockers = 1;
	level.passed_introscreen = 0;
	if ( !isDefined( level.custom_ai_type ) )
	{
		level.custom_ai_type = [];
	}
	level.custom_ai_spawn_check_funcs = [];
	level.spawn_funcs = [];
	level.spawn_funcs[ "allies" ] = [];
	level.spawn_funcs[ "axis" ] = [];
	level.spawn_funcs[ "team3" ] = [];
	level thread maps/mp/zombies/_zm_ffotd::main_start();
	level.zombiemode = 1;
	level.revivefeature = 0;
	level.swimmingfeature = 0;
	level.calc_closest_player_using_paths = 0;
	level.zombie_melee_in_water = 1;
	level.put_timed_out_zombies_back_in_queue = 1;
	level.use_alternate_poi_positioning = 1;
	level.zmb_laugh_alias = "zmb_laugh_richtofen";
	level.sndannouncerisrich = 1;
	level.scr_zm_ui_gametype = getDvar( "ui_gametype" );
	level.scr_zm_ui_gametype_group = getDvar( "ui_zm_gamemodegroup" );
	level.scr_zm_map_start_location = getDvar( "ui_zm_mapstartlocation" );
	level.curr_gametype_affects_rank = 0;
	gametype = tolower( getDvar( "g_gametype" ) );
	if ( gametype == "zclassic" || gametype == "zstandard" )
	{
		level.curr_gametype_affects_rank = 1;
	}
	level.grenade_multiattack_bookmark_count = 1;
	level.rampage_bookmark_kill_times_count = 3;
	level.rampage_bookmark_kill_times_msec = 6000;
	level.rampage_bookmark_kill_times_delay = 6000;
	level thread watch_rampage_bookmark();
	
	//taken from the beta dump _zm
	level.GAME_MODULE_CLASSIC_INDEX = 0;
	maps\mp\zombies\_zm_game_module::register_game_module(level.GAME_MODULE_CLASSIC_INDEX,"classic",undefined,undefined);	
	maps\mp\zombies\_zm_game_module::set_current_game_module(level.scr_zm_game_module);
	
	if ( !isDefined( level._zombies_round_spawn_failsafe ) )
	{
		level._zombies_round_spawn_failsafe = ::round_spawn_failsafe;
	}
	level.zombie_visionset = "zombie_neutral";
	if ( getDvar( "anim_intro" ) == "1" )
	{
		level.zombie_anim_intro = 1;
	}
	else
	{
		level.zombie_anim_intro = 0;
	}
	precache_shaders();
	precache_models();
	precacherumble( "explosion_generic" );
	precacherumble( "dtp_rumble" );
	precacherumble( "slide_rumble" );
	precache_zombie_leaderboards();
	level._zombie_gib_piece_index_all = 0;
	level._zombie_gib_piece_index_right_arm = 1;
	level._zombie_gib_piece_index_left_arm = 2;
	level._zombie_gib_piece_index_right_leg = 3;
	level._zombie_gib_piece_index_left_leg = 4;
	level._zombie_gib_piece_index_head = 5;
	level._zombie_gib_piece_index_guts = 6;
	level._zombie_gib_piece_index_hat = 7;
	if ( !isDefined( level.zombie_ai_limit ) )
	{
		level.zombie_ai_limit = 24;
	}
	if ( !isDefined( level.zombie_actor_limit ) )
	{
		level.zombie_actor_limit = 31;
	}
	maps/mp/_visionset_mgr::init();
	init_dvars();
	init_strings();
	init_levelvars();
	init_sounds();
	init_shellshocks();
	init_flags();
	init_client_flags();
	registerclientfield( "world", "zombie_power_on", 1, 1, "int" );
	if ( !is_true( level._no_navcards ) )
	{
		if ( level.scr_zm_ui_gametype_group == "zclassic" && !level.createfx_enabled )
		{
			registerclientfield( "allplayers", "navcard_held", 1, 4, "int" );
			level.navcards = [];
			level.navcards[ 0 ] = "navcard_held_zm_transit";
			level.navcards[ 1 ] = "navcard_held_zm_highrise";
			level.navcards[ 2 ] = "navcard_held_zm_buried";
			level thread setup_player_navcard_hud();
		}
	}
	maps/mp/zombies/_zm_utility::register_offhand_weapons_for_level_defaults();
	level thread drive_client_connected_notifies();

	maps/mp/zombies/_zm_zonemgr::init();
	maps/mp/zombies/_zm_unitrigger::init();
	maps/mp/zombies/_zm_audio::init();
	maps/mp/zombies/_zm_blockers::init();
	//maps/mp/zombies/_zm_bot::init();
	maps/mp/zombies/_zm_clone::init();
	maps/mp/zombies/_zm_buildables::init();
	maps/mp/zombies/_zm_equipment::init();
	maps/mp/zombies/_zm_laststand::init();
	maps/mp/zombies/_zm_magicbox::init();
	if(is_true(level.script == "zm_highrise"))
		scripts/zm/cw_perks::perks_init_highrise();
	else
		scripts/zm/cw_perks::perks_init();
	
	maps/mp/zombies/_zm_playerhealth::init();
	
	maps/mp/zombies/_zm_power::init();
	maps/mp/zombies/_zm_powerups::init();
	maps/mp/zombies/_zm_score::init();
	maps/mp/zombies/_zm_spawner::init();
	maps/mp/zombies/_zm_gump::init();
	//maps/mp/zombies/_zm_timer::init();
	maps/mp/zombies/_zm_traps::init();
	maps/mp/zombies/_zm_weapons::init();
	init_function_overrides();
	level thread last_stand_pistol_rank_init();
	level thread maps/mp/zombies/_zm_tombstone::init();
	level thread post_all_players_connected();
	init_utility();
	maps/mp/_utility::registerclientsys( "lsm" );
	maps/mp/zombies/_zm_stats::init();
	initializestattracking();
	if ( get_players().size <= 1 )
	{
		incrementcounter( "global_solo_games", 1 );
	}
	/*
	else if ( level.systemlink )
	{
		incrementcounter( "global_systemlink_games", 1 );
	}
	else if ( getDvarInt( "splitscreen_playerCount" ) == get_players().size )
	{
		incrementcounter( "global_splitscreen_games", 1 );
	}
	*/
	else
	{
		incrementcounter( "global_coop_games", 1 );
	}
	maps/mp/zombies/_zm_utility::onplayerconnect_callback( ::zm_on_player_connect );
	maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_init();
	set_demo_intermission_point();
	level thread maps/mp/zombies/_zm_ffotd::main_end();
	level thread track_players_intersection_tracker();
	level thread onallplayersready();
	level thread startunitriggers();
	level thread maps/mp/gametypes_zm/_zm_gametype::post_init_gametype();
}

fade_out_intro_screen_zm( hold_black_time, fade_out_time, destroyed_afterwards ) //checked changed to match cerberus output
{
	if ( !isDefined( level.introscreen ) )
	{
		level.introscreen = newhudelem();
		level.introscreen.x = 0;
		level.introscreen.y = 0;
		level.introscreen.horzalign = "fullscreen";
		level.introscreen.vertalign = "fullscreen";
		level.introscreen.foreground = 0;
		level.introscreen setshader( "black", 640, 480 );
		level.introscreen.immunetodemogamehudsettings = 1;
		level.introscreen.immunetodemofreecamera = 1;
		wait 0.05;
	}
	level.introscreen.alpha = 1;
	if ( isDefined( hold_black_time ) )
	{
		wait hold_black_time;
	}
	else
	{
		wait 0.2;
	}
	if ( !isDefined( fade_out_time ) )
	{
		fade_out_time = 1.5;
	}
	level.introscreen fadeovertime( fade_out_time );
	level.introscreen.alpha = 0;
	wait 1.6;
	level.passed_introscreen = 1;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] setclientuivisibilityflag( "hud_visible", 0 );
		if ( is_true( level.player_movement_suppressed ) )
		{
			players[ i ] freezecontrols( level.player_movement_suppressed );
			i++;
			continue;	
		}
		else
		{
			players[ i ] freezecontrols( 0 );
		}
		i++;
	}
	if ( destroyed_afterwards == 1 )
	{
		level.introscreen destroy();
	}
	flag_set( "initial_blackscreen_passed" );
}

zm_on_player_connect() //checked matches cerberus output
{
	if ( level.passed_introscreen )
	{
		self setclientuivisibilityflag( "hud_visible", 0 );
	}
	thread refresh_player_navcard_hud();
	self thread watchdisconnect();
}

perk_hud_create( perk )
{
	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
	}


	shader = getPerkShader(perk);

	hud = create_simple_hud( self );
	hud.foreground = true; 
	hud.sort = 1; 
	hud.hidewheninmenu = 1; 
	hud.alignX = "center"; 
	hud.alignY = "bottom";
	hud.horzAlign = "user_center"; 
	hud.vertAlign = "user_bottom";
	hud.x = 0; 
	hud.y = -8; 
	hud.alpha = 1;
	hud SetShader( shader, 22, 22 );

	self.perk_hud[ perk ] = hud;

	self update_perk_hud();
}

perk_hud_destroy(perk)
{
	self.perk_hud[ perk ] destroy_hud();
	self.perk_hud[ perk ] = undefined;
	self update_perk_hud();
}

update_perk_hud()
{
	if(self.perk_hud.size <= 0)
		return;
	i=0;
	foreach(element in self.perk_hud)
	{
		element.x = i * 12;
		for(k=i+1;k<self.perk_hud.size;k++)
			element.x -= 12;
		i++;
	}
}

getPerkShader(perk)
{
	shader = "";
	if(level.script == "zm_transit")
	{
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
			shader = "specialty_juggernaut_zombies_pro";
			break;
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
			shader = "specialty_quickrevive_zombies_pro";
			break;
		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload_upgrade":
			shader = "specialty_fastreload_zombies_pro";
			break;
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;
			
		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			shader = "specialty_marathon_zombies";
			break;
			
		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "hud_us_grenade";
			break;
			
		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "hud_obit_death_crush"; 
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "hud_obit_death_falling";
			break;

		case "specialty_scavenger":
			shader = "specialty_tombstone_zombies";
			break;

		case "specialty_elementalpop":
			shader = "hud_obit_death_suicide";
			break;
			
		default:
			shader = "";
			break;
		}
	}
	else if(level.script == "zm_nuked")
	{
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
			shader = "specialty_juggernaut_zombies_pro";
			break;
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
			shader = "specialty_quickrevive_zombies_pro";
			break;
		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload_upgrade":
			shader = "specialty_fastreload_zombies_pro";
			break;
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;
			
		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			shader = "hud_obit_ballistic_knife";
			break;
			
		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "hud_us_grenade";
			break;
			
		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "hud_obit_death_crush"; 
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "hud_obit_death_falling";
			break;

		case "specialty_scavenger":
			shader = "hud_obit_knife";
			break;

		case "specialty_elementalpop":
			shader = "hud_obit_death_suicide";
			break;
			
		default:
			shader = "";
			break;
		}
	}
	else if(level.script == "zm_highrise")
	{
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
			shader = "specialty_juggernaut_zombies_pro";
			break;
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
			shader = "specialty_quickrevive_zombies_pro";
			break;
		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload_upgrade":
			shader = "specialty_fastreload_zombies_pro";
			break;
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;
			
		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			shader = "hud_obit_ballistic_knife";
			break;
			
		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "hud_us_grenade";
			break;
			
		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "hud_obit_death_crush"; 
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "hud_obit_death_falling";
			break;

		case "specialty_scavenger":
			shader = "hud_obit_knife";
			break;

		case "specialty_elementalpop":
			shader = "hud_obit_death_suicide";
			break;
			
		default:
			shader = "";
			break;
		}
	}
	else if(level.script == "zm_prison")
	{
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
			shader = "specialty_juggernaut_zombies_pro";
			break;
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
			shader = "specialty_quickrevive_zombies_pro";
			break;
		case "specialty_quickrevive":
			shader = "hud_obit_hatchet";
			break;

		case "specialty_fastreload_upgrade":
			shader = "specialty_fastreload_zombies_pro";
			break;
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;
			
		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			shader = "hud_obit_death_grenade_round";
			break;
			
		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "hud_us_grenade";
			break;
			
		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "hud_obit_death_crush"; 
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "hud_obit_death_falling";
			break;

		case "specialty_scavenger":
			shader = "hud_obit_knife";
			break;

		case "specialty_elementalpop":
			shader = "hud_obit_death_suicide";
			break;
			
		default:
			shader = "";
			break;
		}
	}
	else if(level.script == "zm_buried")
	{
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
			shader = "specialty_juggernaut_zombies_pro";
			break;
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
			shader = "specialty_quickrevive_zombies_pro";
			break;
		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload_upgrade":
			shader = "specialty_fastreload_zombies_pro";
			break;
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;
			
		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			shader = "specialty_marathon_zombies";
			break;
			
		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "hud_us_grenade";
			break;
			
		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "hud_obit_death_crush"; 
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "specialty_additionalprimaryweapon_zombies";
			break;

		case "specialty_scavenger":
			shader = "hud_obit_knife";
			break;

		case "specialty_elementalpop":
			shader = "hud_obit_death_suicide";
			break;
			
		default:
			shader = "";
			break;
		}
	}
	else if(level.script == "zm_tomb")
	{
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
			shader = "specialty_juggernaut_zombies_pro";
			break;
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive_upgrade":
			shader = "specialty_quickrevive_zombies_pro";
			break;
		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload_upgrade":
			shader = "specialty_fastreload_zombies_pro";
			break;
		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;
			
		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			shader = "specialty_marathon_zombies";
			break;
			
		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			shader = "specialty_divetonuke_zombies";
			break;
			
		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			shader = "specialty_ads_zombies"; 
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			shader = "specialty_additionalprimaryweapon_zombies";
			break;

		case "specialty_scavenger":
			shader = "hud_obit_knife";
			break;

		case "specialty_elementalpop":
			shader = "hud_obit_death_suicide";
			break;
			
		default:
			shader = "";
			break;
		}
	}
	return shader;
}

give_perk( perk, bought ) //checked changed to match cerberus output
{
	self setperk( perk );
	self.num_perks++;
	if ( is_true( bought ) )
	{
		self maps/mp/zombies/_zm_audio::playerexert( "burp" );
		if ( is_true( level.remove_perk_vo_delay ) )
		{
			self maps/mp/zombies/_zm_audio::perk_vox( perk );
		}
		else
		{
			self delay_thread( 1.5, ::perk_vox, perk );
		}
		self setblur( 4, 0.1 );
		wait 0.1;
		self setblur( 0, 0.1 );
		self notify( "perk_bought", perk );
	}
	self perk_set_max_health_if_jugg( perk, 1, 0 );
	if ( !is_true( level.disable_deadshot_clientfield ) )
	{
		if ( perk == "specialty_deadshot" )
		{
			self setclientfieldtoplayer( "deadshot_perk", 1 );
		}
		else if ( perk == "specialty_deadshot_upgrade" )
		{
			self setclientfieldtoplayer( "deadshot_perk", 1 );
		}
	}
	if ( perk == "specialty_scavenger" )
	{
		self.hasperkspecialtytombstone = 1;
	}
	players = get_players();
	if ( perk == "specialty_finalstand" )
	{
		self.lives = 1;
		self.hasperkspecialtychugabud = 1;
		self notify( "perk_chugabud_activated" );
	}
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].player_thread_give ) )
	{
		self thread [[ level._custom_perks[ perk ].player_thread_give ]]();
	}
	self perk_hud_create(perk);
	maps/mp/_demo::bookmark( "zm_player_perk", getTime(), self );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "perks_drank" );
	self maps/mp/zombies/_zm_stats::increment_client_stat( perk + "_drank" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( perk + "_drank" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "perks_drank" );
	if ( !isDefined( self.perk_history ) )
	{
		self.perk_history = [];
	}
	self.perk_history = add_to_array( self.perk_history, perk, 0 );
	if ( !isDefined( self.perks_active ) )
	{
		self.perks_active = [];
	}
	self.perks_active[ self.perks_active.size ] = perk;
	self notify( "perk_acquired" );
	self thread perk_think( perk );
}

perk_think( perk ) //checked changed to match cerberus output
{
/*
/#
	if ( getDvarInt( "zombie_cheat" ) >= 5 )
	{
		if ( isDefined( self.perk_hud[ perk ] ) )
		{
			return;
#/
		}
	}
*/
	perk_str = perk + "_stop";
	result = self waittill_any_return( "fake_death", "death", "player_downed", perk_str );
	do_retain = 1;
	if ( do_retain )
	{
		if ( is_true( self._retain_perks ) )
		{
			return;
		}
		else if ( isDefined( self._retain_perks_array ) && is_true( self._retain_perks_array[ perk ] ) )
		{
			return;
		}
	}
	self unsetperk( perk );
	self.num_perks--;

	switch( perk )
	{
		case "specialty_armorvest":
			self setmaxhealth( 100 );
			break;
		case "specialty_additionalprimaryweapon":
			if ( result == perk_str )
			{
				self scripts/zm/cw_mule_kick_retained::take_additionalprimaryweapon();
			}
			break;
		case "specialty_deadshot":
			if ( !is_true( level.disable_deadshot_clientfield ) )
			{
				self setclientfieldtoplayer( "deadshot_perk", 0 );
			}
			break;
		case "specialty_deadshot_upgrade":
			if ( !is_true( level.disable_deadshot_clientfield ) )
			{
				self setclientfieldtoplayer( "deadshot_perk", 0 );
			}
			break;
	}
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].player_thread_take ) )
	{
		self thread [[ level._custom_perks[ perk ].player_thread_take ]]();
	}
	self perk_hud_destroy(perk);
	self.perk_purchased = undefined;
	if ( isDefined( level.perk_lost_func ) )
	{
		self [[ level.perk_lost_func ]]( perk );
	}
	if ( isDefined( self.perks_active ) && isinarray( self.perks_active, perk ) )
	{
		arrayremovevalue( self.perks_active, perk, 0 );
	}
	self notify( "perk_lost" );
}

#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_perks;

main()
{
	if(ToLower( GetDvar( "mapname" ) ) == "zm_highrise")
	{
		replacefunc(maps/mp/zombies/_zm_perks::init, ::perks_init_highrise);
		replacefunc(maps/mp/zombies/_zm_perks::vending_trigger_think, ::vending_trigger_think_highrise);
	}
	else
	{
		replacefunc(maps/mp/zombies/_zm_perks::init, ::perks_init);
		replacefunc(maps/mp/zombies/_zm_perks::vending_trigger_think, ::vending_trigger_think);
	}
}

spawn_cw_wunderfizz(origin)
{
	if(level.script == "zm_prison" || level.script == "zm_nuked")
		perk_powerup_model = "t6_wpn_zmb_perk_bottle_doubletap_world";
	else
		perk_powerup_model = "zombie_pickup_perk_bottle";
	perk_model = spawn("script_model", origin + (0,0,40));
	perk_model SetModel(perk_powerup_model);
	PlayFXOnTag(level._effect[ "powerup_on" ], perk_model, "tag_origin");
	perk_model thread wobble();
	perk_model.unitrigger_stub = spawnstruct();
	perk_model.unitrigger_stub.origin = perk_model.origin - (0,0,20);
	perk_model.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	perk_model.unitrigger_stub.cursor_hint = "HINT_NOICON";
	perk_model.unitrigger_stub.require_look_at = 0;
	perk_model.unitrigger_stub.script_width = 50;
	perk_model.unitrigger_stub.script_height = 50;
	perk_model.unitrigger_stub.script_length = 100;
	perk_model.unitrigger_stub.trigger_target = perk_model;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( perk_model.unitrigger_stub, 1 );
	perk_model.unitrigger_stub.prompt_and_visibility_func = ::perk_update_prompt;
	thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( perk_model.unitrigger_stub, ::perk_unitrigger_think );
}

wobble()
{
	level endon("end_game");
	while ( isDefined( self ) )
	{
		waittime = randomfloatrange( 2.5, 5 );
		yaw = randomint( 360 );
		if ( yaw > 300 )
		{
			yaw = 300;
		}
		else
		{
			if ( yaw < 60 )
			{
				yaw = 60;
			}
		}
		yaw = self.angles[ 1 ] + yaw;
		new_angles = ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) );
		self rotateto( new_angles, waittime, waittime * 0.5, waittime * 0.5 );
		wait randomfloat( waittime - 0.1 );
	}
}

perk_update_prompt(player)
{
	self.cost = 2000;
	if(isdefined(player.num_perks))
		self.cost = 2000 + (500 * player.num_perks);
	if(player.num_perks >= 10)
	{
		self SetHintString("");
		return;
	}
	self SetHintString("Hold ^3&&1^7 for Perk [Cost: " + self.cost + "]");
}

perk_machine_update_prompt(player)
{
	if(is_false(self.stub.orig_trig.power_on))
	{
		self SetHintString(&"ZOMBIE_NEED_POWER");
		return;
	}
	self.cost = 2000;
	if(isdefined(player.num_perks))
		self.cost = 2000 + (500 * player.num_perks);
	switch( self.script_noteworthy )
	{
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			self sethintstring( &"ZOMBIE_PERK_JUGGERNAUT", self.cost );
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			self sethintstring( &"ZOMBIE_PERK_QUICKREVIVE", self.cost );
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			self sethintstring( &"ZOMBIE_PERK_FASTRELOAD", self.cost );
			break;
		case "specialty_rof":
		case "specialty_rof_upgrade":
			self sethintstring( &"ZOMBIE_PERK_DOUBLETAP", self.cost );
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			self sethintstring( &"ZOMBIE_PERK_MARATHON", self.cost );
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			self sethintstring( &"ZOMBIE_PERK_DEADSHOT", self.cost );
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			self sethintstring( &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", self.cost );
			break;
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			self sethintstring( &"ZOMBIE_PERK_TOMBSTONE", self.cost );
			break;
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			self sethintstring( &"ZOMBIE_PERK_CHUGABUD", self.cost );
			break;
		case "specialty_elementalpop":
			self SetHintString( "Hold ^3&&1^7 for Elemental Pop [Cost: " + self.cost + "]");
			break;
		default:
			self sethintstring( ( perk + " Cost: " ) + level.zombie_vars[ "zombie_perk_cost" ] );
	}
	if ( isDefined( level._custom_perks ) )
	{
		if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].cost ) && isDefined( level._custom_perks[ perk ].hint_string ) )
		{
			self sethintstring( level._custom_perks[ perk ].hint_string, level._custom_perks[ perk ].cost );
		}
	}
}

perk_unitrigger_think()
{
	self endon("kill_trigger");
	while(1)
	{
		self waittill("trigger", player);
		if(player.num_perks >= 10)
			continue;
		if ( !is_player_valid( player ) )
		{
			continue;
		}
		if ( !player maps/mp/zombies/_zm_magicbox::can_buy_weapon() )
		{
			wait 0.1;
			continue;
		}
		if ( player has_powerup_weapon() )
		{
			wait 0.1;
			continue;
		}
		if ( player.score < self.cost )
		{
			self playsound( "evt_perk_deny" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}
		playsoundatposition( "evt_bottle_dispense", self.origin );
		player maps/mp/zombies/_zm_score::minus_to_player_score( self.cost, 1 );
		player.perk_purchased = player give_random_perk();
		wait .1;
		self [[ self.stub.prompt_and_visibility_func ]]( player );
	}
}

give_random_perk() //checked partially changed to match cerberus output
{
	random_perk = undefined;
	vending_triggers = getperks();
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ];
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) && !self has_active_perk( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		IPrintLn(random_perk);
		self give_perk( random_perk );
	}
	else
	{
		self playsoundtoplayer( level.zmb_laugh_alias, self );
	}
	return random_perk;
}

has_active_perk( cperk )
{
	foreach(perk in self.perks_active)
		if(is_true(perk == cperk))
			return 1;
	return 0;
}

getPerks()
{
	perks = [];
	//Order is Rainbow
	if(isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
	{
		perks[perks.size] = "specialty_armorvest";
	}
	if(isDefined(level._custom_perks[ "specialty_nomotionsensor"] ))
	{
		//perks[perks.size] = "specialty_nomotionsensor";
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		perks[perks.size] = "specialty_rof";
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		perks[perks.size] = "specialty_longersprint";
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		perks[perks.size] = "specialty_fastreload";
	}
	if(isDefined(level.zombiemode_using_additionalprimaryweapon_perk) && level.zombiemode_using_additionalprimaryweapon_perk)
	{
		perks[perks.size] = "specialty_additionalprimaryweapon";
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		perks[perks.size] = "specialty_quickrevive";
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk)
	{
		perks[perks.size] = "specialty_finalstand";
	}
	if ( isDefined( level._custom_perks[ "specialty_grenadepulldeath" ] ))
	{
		//perks[perks.size] = "specialty_grenadepulldeath";
	}
	if ( isDefined( level._custom_perks[ "specialty_flakjacket" ]) )
	{
		perks[perks.size] = "specialty_flakjacket";
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		perks[perks.size] = "specialty_deadshot";
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		perks[perks.size] = "specialty_scavenger";
	}
	if ( isdefined( level.zombiemode_using_elementalpop_perk ) && level.zombiemode_using_elementalpop_perk )
	{
		perks[perks.size] = "specialty_elementalpop";
	}
	return perks;
}

vending_trigger_think_highrise() //checked changed to match cerberus output
{
	self endon( "death" );
	wait 0.01;
	perk = self.script_noteworthy;
	solo = 0;
	start_on = 0;
	level.revive_machine_is_solo = 0;
	
	if ( isdefined( perk ) && perk == "specialty_quickrevive" || perk == "specialty_quickrevive_upgrade" )
	{
		flag_wait("start_zombie_round_logic");
		solo = use_solo_revive();
		self endon("stop_quickrevive_logic");
		level.quick_revive_trigger = self;
		if( solo )
		{
			if ( !is_true( level.revive_machine_is_solo ) )
			{
				start_on = 1;
				players = get_players();
				foreach ( player in players )
				{
					if ( !isdefined( player.lives ) )
					{
						player.lives = 0;
					}
				}
				level maps/mp/zombies/_zm::set_default_laststand_pistol( 1 );
			}
			level.revive_machine_is_solo = 1;
		}
	}
	self sethintstring( &"ZOMBIE_NEED_POWER" );
	self setcursorhint( "HINT_NOICON" );
	self usetriggerrequirelookat();
	cost = level.zombie_vars[ "zombie_perk_cost" ];
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].cost ) )
	{
		cost = level._custom_perks[ perk ].cost;
	}
	if ( !start_on )
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}
	start_on = 0;
	if ( !isDefined( level._perkmachinenetworkchoke ) )
	{
		level._perkmachinenetworkchoke = 0;
	}
	else
	{
		level._perkmachinenetworkchoke++;
	}
	for ( i = 0; i < level._perkmachinenetworkchoke; i++ )
	{
		wait_network_frame();
	}
	self thread maps/mp/zombies/_zm_audio::perks_a_cola_jingle_timer();
	self thread check_player_has_perk( perk );
	self sethintstring( "Hold ^3&&1^7 to buy Perk" );
	for ( ;; )
	{
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			wait 0.1;
			continue;
		}
		if ( player in_revive_trigger() )
		{
			wait 0.1;
			continue;
		}
		if ( !player maps/mp/zombies/_zm_magicbox::can_buy_weapon() )
		{
			wait 0.1;
			continue;
		}
		if ( player isthrowinggrenade() )
		{
			wait 0.1;
			continue;
		}
		if ( player isswitchingweapons() )
		{
			wait 0.1;
			continue;
		}
		if ( player.is_drinking > 0 )
		{
			wait 0.1;
			continue;
		}
		if ( player hasperk( perk ) || player has_perk_paused( perk ) )
		{
			cheat = 0;
			/*
/#
			if ( getDvarInt( "zombie_cheat" ) >= 5 )
			{
				cheat = 1;
#/
			}
			*/
			if ( cheat != 1 )
			{
				self playsound( "deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
				continue;
			}
		}
		if ( isDefined( level.custom_perk_validation ) )
		{
			valid = self [[ level.custom_perk_validation ]]( player );
			if ( !valid )
			{
				continue;
			}
		}
		cost = 2000;
		if(isdefined(player.num_perks))
			cost = 2000 + (500 * player.num_perks);
		current_cost = cost;
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			current_cost = player maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );
		}
		if ( player.score < current_cost )
		{
			self playsound( "evt_perk_deny" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}
		
		if ( player.num_perks >= player get_player_perk_purchase_limit() )
		{
			self playsound( "evt_perk_deny" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}
		sound = "evt_bottle_dispense";
		playsoundatposition( sound, self.origin );
		player maps/mp/zombies/_zm_score::minus_to_player_score( current_cost, 1 );
		player.perk_purchased = perk;
		self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( self.script_label );
		self thread vending_trigger_post_think( player, perk );
	}
}

vending_trigger_think()
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = self.origin;
	unitrigger_stub.angles = self.angles;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.script_width = 60;
	unitrigger_stub.script_height = 50;
	unitrigger_stub.script_length = 60;
	unitrigger_stub.script_noteworthy = self.script_noteworthy;
	if(unitrigger_stub.script_noteworthy == "specialty_grenadepulldeath")
		unitrigger_stub.script_noteworthy = "specialty_elementalpop";
	unitrigger_stub.orig_trig = self;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = ::perk_machine_update_prompt;
	thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::vending_unitrigger_think );
	self SetInvisibleToAll();
}

vending_unitrigger_think() //checked changed to match cerberus output
{
	self endon( "kill_trigger" );
	perk = self.script_noteworthy;
	if(is_false(self.stub.orig_trig.power_on))
	{
		return;
	}
	self thread maps/mp/zombies/_zm_audio::perks_a_cola_jingle_timer();
	self thread check_player_has_perk( perk );
	for ( ;; )
	{
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			wait 0.1;
			continue;
		}
		if ( player in_revive_trigger() )
		{
			wait 0.1;
			continue;
		}
		if ( !player maps/mp/zombies/_zm_magicbox::can_buy_weapon() )
		{
			wait 0.1;
			continue;
		}
		if ( player isthrowinggrenade() )
		{
			wait 0.1;
			continue;
		}
		if ( player isswitchingweapons() )
		{
			wait 0.1;
			continue;
		}
		if ( player.is_drinking > 0 )
		{
			wait 0.1;
			continue;
		}
		if ( player hasperk( perk ) || player has_perk_paused( perk ) )
		{
			cheat = 0;
			/*
/#
			if ( getDvarInt( "zombie_cheat" ) >= 5 )
			{
				cheat = 1;
#/
			}
			*/
			if ( cheat != 1 )
			{
				self playsound( "deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
				continue;
			}
		}
		current_cost = self.cost;
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			current_cost = player maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );
		}
		if ( player.score < current_cost )
		{
			self playsound( "evt_perk_deny" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}
		
		if ( player.num_perks >= player get_player_perk_purchase_limit() )
		{
			self playsound( "evt_perk_deny" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}
		sound = "evt_bottle_dispense";
		playsoundatposition( sound, self.origin );
		player maps/mp/zombies/_zm_score::minus_to_player_score( current_cost, 1 );
		player.perk_purchased = perk;
		self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( self.script_label );
		self thread vending_trigger_post_think( player, perk );
	}
}

perks_init() //checked partially changed to match cerberus output
{
	level.additionalprimaryweapon_limit = 3;
	level.perk_purchase_limit = 4;
	if ( !level.createfx_enabled )
	{
		perks_register_clientfield(); //fixed
	}
	if ( !level.enable_magic )
	{
		return;
	}
	initialize_custom_perk_arrays();
	perk_machine_spawn_init();
	vending_weapon_upgrade_trigger = [];
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		if ( isDefined( vending_triggers[ i ].script_noteworthy ) && vending_triggers[ i ].script_noteworthy == "specialty_weapupgrade" )
		{
			vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = vending_triggers[ i ];
			arrayremovevalue( vending_triggers, vending_triggers[ i ] );
		}
	}
	old_packs = getentarray( "zombie_vending_upgrade", "targetname" );
	i = 0;
	for ( i = 0; i < old_packs.size; i++ )
	{
		vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = old_packs[ i ];
	}
	flag_init( "pack_machine_in_use" );
	if ( vending_triggers.size < 1 )
	{
		return;
	}
	if ( vending_weapon_upgrade_trigger.size >= 1 )
	{
		array_thread( vending_weapon_upgrade_trigger, scripts/zm/cw_weapon_tiers::vending_weapon_upgrade );
	}
	level.machine_assets = [];
	if ( !isDefined( level.custom_vending_precaching ) )
	{
		level.custom_vending_precaching = ::default_vending_precaching;
	}
	[[ level.custom_vending_precaching ]]();
	if ( !isDefined( level.packapunch_timeout ) )
	{
		level.packapunch_timeout = 15;
	}
	set_zombie_var( "zombie_perk_cost", 2000 );
	set_zombie_var( "zombie_perk_juggernaut_health", 160 );
	set_zombie_var( "zombie_perk_juggernaut_health_upgrade", 190 );
	array_thread( vending_triggers, scripts/zm/cw_perks::vending_trigger_think );
	array_thread( vending_triggers, ::electric_perks_dialog );

	if ( is_true( level.zombiemode_using_doubletap_perk ) )
	{
		level thread turn_doubletap_on();
	}
	if ( is_true( level.zombiemode_using_marathon_perk ) )
	{
		level thread turn_marathon_on();
	}
	if ( is_true( level.zombiemode_using_juggernaut_perk ) )
	{
		level thread turn_jugger_on();
	}
	if ( is_true( level.zombiemode_using_revive_perk ) )
	{
		level thread turn_revive_on();
	}
	if ( is_true( level.zombiemode_using_sleightofhand_perk ) )
	{
		level thread turn_sleight_on();
	}
	if ( is_true( level.zombiemode_using_deadshot_perk ) )
	{
		level thread turn_deadshot_on();
	}
	if ( is_true( level.zombiemode_using_tombstone_perk ) )
	{
		level thread turn_tombstone_on();
	}
	if ( is_true( level.zombiemode_using_additionalprimaryweapon_perk ) )
	{
		level thread turn_additionalprimaryweapon_on();
	}
	if ( is_true( level.zombiemode_using_chugabud_perk ) )
	{
		level thread turn_chugabud_on();
	}
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isdefined( level._custom_perks[ a_keys[ i ] ].perk_machine_thread ) )
			{
				level thread [[ level._custom_perks[ a_keys[ i ] ].perk_machine_thread ]]();
			}
		}
	}
	if ( isDefined( level._custom_turn_packapunch_on ) )
	{
		level thread [[ level._custom_turn_packapunch_on ]]();
	}
	else
	{
		level thread turn_packapunch_on();
	}
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "give_nearest_perk", ::quantum_bomb_give_nearest_perk_result, 10, ::quantum_bomb_give_nearest_perk_validation );
	}
	level thread perk_hostmigration();

}

perks_init_highrise()
{
	level.additionalprimaryweapon_limit = 3;
	level.perk_purchase_limit = 4;
	if ( !level.createfx_enabled )
	{
		perks_register_clientfield(); //fixed
	}
	if ( !level.enable_magic )
	{
		return;
	}
	initialize_custom_perk_arrays();
	perk_machine_spawn_init();
	vending_weapon_upgrade_trigger = [];
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		if ( isDefined( vending_triggers[ i ].script_noteworthy ) && vending_triggers[ i ].script_noteworthy == "specialty_weapupgrade" )
		{
			vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = vending_triggers[ i ];
			arrayremovevalue( vending_triggers, vending_triggers[ i ] );
		}
	}
	old_packs = getentarray( "zombie_vending_upgrade", "targetname" );
	i = 0;
	for ( i = 0; i < old_packs.size; i++ )
	{
		vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = old_packs[ i ];
	}
	flag_init( "pack_machine_in_use" );
	if ( vending_triggers.size < 1 )
	{
		return;
	}
	if ( vending_weapon_upgrade_trigger.size >= 1 )
	{
		array_thread( vending_weapon_upgrade_trigger, scripts/zm/cw_weapon_tiers::vending_weapon_upgrade );
	}
	level.machine_assets = [];
	if ( !isDefined( level.custom_vending_precaching ) )
	{
		level.custom_vending_precaching = ::default_vending_precaching;
	}
	[[ level.custom_vending_precaching ]]();
	if ( !isDefined( level.packapunch_timeout ) )
	{
		level.packapunch_timeout = 15;
	}
	set_zombie_var( "zombie_perk_cost", 2000 );
	set_zombie_var( "zombie_perk_juggernaut_health", 160 );
	set_zombie_var( "zombie_perk_juggernaut_health_upgrade", 190 );
	array_thread( vending_triggers, scripts/zm/cw_perks::vending_trigger_think_highrise );
	array_thread( vending_triggers, ::electric_perks_dialog );

	if ( is_true( level.zombiemode_using_doubletap_perk ) )
	{
		level thread turn_doubletap_on();
	}
	if ( is_true( level.zombiemode_using_marathon_perk ) )
	{
		level thread turn_marathon_on();
	}
	if ( is_true( level.zombiemode_using_juggernaut_perk ) )
	{
		level thread turn_jugger_on();
	}
	if ( is_true( level.zombiemode_using_revive_perk ) )
	{
		level thread turn_revive_on();
	}
	if ( is_true( level.zombiemode_using_sleightofhand_perk ) )
	{
		level thread turn_sleight_on();
	}
	if ( is_true( level.zombiemode_using_deadshot_perk ) )
	{
		level thread turn_deadshot_on();
	}
	if ( is_true( level.zombiemode_using_tombstone_perk ) )
	{
		level thread turn_tombstone_on();
	}
	if ( is_true( level.zombiemode_using_additionalprimaryweapon_perk ) )
	{
		level thread turn_additionalprimaryweapon_on();
	}
	if ( is_true( level.zombiemode_using_chugabud_perk ) )
	{
		level thread turn_chugabud_on();
	}
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isdefined( level._custom_perks[ a_keys[ i ] ].perk_machine_thread ) )
			{
				level thread [[ level._custom_perks[ a_keys[ i ] ].perk_machine_thread ]]();
			}
		}
	}
	if ( isDefined( level._custom_turn_packapunch_on ) )
	{
		level thread [[ level._custom_turn_packapunch_on ]]();
	}
	else
	{
		level thread turn_packapunch_on();
	}
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "give_nearest_perk", ::quantum_bomb_give_nearest_perk_result, 10, ::quantum_bomb_give_nearest_perk_validation );
	}
	level thread perk_hostmigration();
}

playerlaststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked matches cerberus output //checked changed to match beta dump
{
	self notify( "entering_last_stand" );
	if ( isDefined( level._game_module_player_laststand_callback ) )
	{
		self [[ level._game_module_player_laststand_callback ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	}
	if ( self player_is_in_laststand() )
	{
		return;
	}
	if ( is_true( self.in_zombify_call ) )
	{
		return;
	}
	self thread player_last_stand_stats( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	if ( isDefined( level.playerlaststand_func ) )
	{
		[[ level.playerlaststand_func ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	}
	self.health = 1;
	self.laststand = 1;
	self.ignoreme = 1;
	self thread maps/mp/gametypes_zm/_gameobjects::onplayerlaststand();
	self thread maps/mp/zombies/_zm_buildables::onplayerlaststand();
	if ( !is_true( self.no_revive_trigger ) )
	{
		self revive_trigger_spawn();
	}
	else
	{
		self undolaststand();
	}
	if ( is_true( self.is_zombie ) )
	{
		self takeallweapons();
		if ( isDefined( attacker ) && isplayer( attacker ) && attacker != self )
		{
			attacker notify( "killed_a_zombie_player", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
		}
	}
	else
	{
		self laststand_disable_player_weapons();
		self laststand_give_pistol();
	}
	if ( is_true( level.playerSuicideAllowed ) && get_players().size > 1 )
	{
		if ( !isDefined( level.canplayersuicide ) || self [[ level.canplayersuicide ]]() )
		{
			self thread suicide_trigger_spawn();
		}
	}
	if ( isDefined( self.disabled_perks ) )
	{
		self.disabled_perks = [];
	}
	if ( level.laststandgetupallowed )
	{
		self thread laststand_getup();
	}
	else
	{
		bleedout_time = getDvarFloat( "player_lastStandBleedoutTime" );
		self thread laststand_bleedout( bleedout_time );
	}
	if ( level.gametype != "zcleansed" )
	{
		maps/mp/_demo::bookmark( "zm_player_downed", getTime(), self );
	}
	keys = GetArrayKeys(self.perks_active);
	for(i=0;i<keys.size;i++)
	{
		if(!isdefined(self._retain_perks))
			self._retain_perks = [];
		if(self._retain_perks.size > 2)
			break;
		self._retain_perks[self._retain_perks.size] = keys[i];
	}
	self notify( "player_downed" );
	self thread refire_player_downed();
	self thread cleanup_laststand_on_disconnect();
}
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_weap_claymore;

main()
{
	replacefunc(maps/mp/zombies/_zm_weapons::weapon_spawn_think, ::weapon_spawn_think);
	replacefunc(maps/mp/zombies/_zm_weapons::add_dynamic_wallbuy, ::add_dynamic_wallbuy);
}

init()
{
	weaponsMain();
}

weaponsMain()
{
	spawn_list = [];
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	if ( !is_true( level.headshots_only ) )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location == "default" || location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype;
	if ( location != "" )
	{
		match_string = match_string + "_" + location;
	}
	match_string_plus_space = " " + match_string;
	i = 0;
	while ( i < spawnable_weapon_spawns.size )
	{
		spawnable_weapon = spawnable_weapon_spawns[ i ];
		if ( isDefined( spawnable_weapon.zombie_weapon_upgrade ) && spawnable_weapon.zombie_weapon_upgrade == "sticky_grenade_zm" && is_true( level.headshots_only ) )
		{
			i++;
			continue;
		}
		if ( !isDefined( spawnable_weapon.script_noteworthy ) || spawnable_weapon.script_noteworthy == "" )
		{
			spawn_list[ spawn_list.size ] = spawnable_weapon;
			i++;
			continue;
		}
		matches = strtok( spawnable_weapon.script_noteworthy, "," );
		for ( j = 0; j < matches.size; j++ )
		{
			if ( matches[ j ] == match_string || matches[ j ] == match_string_plus_space )
			{
				spawn_list[ spawn_list.size ] = spawnable_weapon;
			}
		}
		i++;
	}
	for(i=0;i<spawn_list.size;i++)
	{
		if ( is_melee_weapon( spawn_list[ i ].trigger_stub.zombie_weapon_upgrade ) )
		{
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		else if ( spawn_list[ i ].trigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
		}
		else
		{
			spawn_list[ i ].trigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt2;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( spawn_list[ i ].trigger_stub, ::weapon_spawn_think );
			spawn_list[ i ].trigger_stub thread updateWallbuyTier();
		}
	}
}

add_dynamic_wallbuy( weapon, wallbuy, pristine ) //checked partially changed to match cerberus output
{
	spawned_wallbuy = undefined;
	for ( i = 0; i < level._spawned_wallbuys.size; i++ )
	{
		if ( level._spawned_wallbuys[ i ].target == wallbuy )
		{
			spawned_wallbuy = level._spawned_wallbuys[ i ];
			break;
		}
	}
	if ( !isDefined( spawned_wallbuy ) )
	{
		return;
	}
	if ( isDefined( spawned_wallbuy.trigger_stub ) )
	{
		return;
	}
	target_struct = getstruct( wallbuy, "targetname" );
	wallmodel = spawn_weapon_model( weapon, undefined, target_struct.origin, target_struct.angles );
	clientfieldname = spawned_wallbuy.clientfieldname;
	model = getweaponmodel( weapon );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = target_struct.origin;
	unitrigger_stub.angles = target_struct.angles;
	wallmodel.origin = target_struct.origin;
	wallmodel.angles = target_struct.angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	wallmodel setmodel( model );
	wallmodel useweaponhidetags( weapon );
	mins = wallmodel getmins();
	maxs = wallmodel getmaxs();
	absmins = wallmodel getabsmins();
	absmaxs = wallmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
	unitrigger_stub.script_width = bounds[ 1 ];
	unitrigger_stub.script_height = bounds[ 2 ];
	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = spawned_wallbuy.target;
	unitrigger_stub.targetname = "weapon_upgrade";
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.first_time_triggered = !pristine;
	if ( !is_melee_weapon( weapon ) )
	{
		if ( pristine || weapon == "claymore_zm" )
		{
			unitrigger_stub.hint_string = get_weapon_hint( weapon );
		}
		else
		{
			unitrigger_stub.hint_string = get_weapon_hint_ammo();
		}
		unitrigger_stub.cost = get_weapon_cost( weapon );
		unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
	}
	unitrigger_stub.weapon_upgrade = weapon;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.zombie_weapon_upgrade = weapon;
	unitrigger_stub.clientfieldname = clientfieldname;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( weapon ) )
	{
		if ( weapon == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps/mp/zombies/_zm_melee_weapon::add_stub( unitrigger_stub, weapon );
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else if ( weapon == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt2;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		unitrigger_stub thread updateWallbuyTier();
	}
	spawned_wallbuy.trigger_stub = unitrigger_stub;
	weaponidx = undefined;
	if ( isDefined( level.buildable_wallbuy_weapons ) )
	{
		for ( i = 0; i < level.buildable_wallbuy_weapons.size; i++ )
		{
			if ( weapon == level.buildable_wallbuy_weapons[ i ] )
			{
				weaponidx = i;
				break;
			}
		}
	}
	if ( isDefined( weaponidx ) )
	{
		level setclientfield( clientfieldname + "_idx", weaponidx + 1 );
		wallmodel delete();
		if ( !pristine )
		{
			level setclientfield( clientfieldname, 1 );
		}
	}
	else
	{
		level setclientfield( clientfieldname, 1 );
		wallmodel show();
	}
}

weapon_spawn_think() //checked changed to match cerberus output
{
	cost = get_weapon_cost( self.zombie_weapon_upgrade );
	ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
	is_grenade = weapontype( self.zombie_weapon_upgrade ) == "grenade";
	shared_ammo_weapon = undefined;
	second_endon = undefined;
	if ( isDefined( self.stub ) )
	{
		second_endon = "kill_trigger";
		self.first_time_triggered = self.stub.first_time_triggered;
	}
	if ( is_grenade )
	{
		self.first_time_triggered = 0;
		hint = get_weapon_hint( self.zombie_weapon_upgrade );
		self sethintstring( hint, cost );
	}
	else if ( !isDefined( self.first_time_triggered ) )
	{
		self.first_time_triggered = 0;
		if ( isDefined( self.stub ) )
		{
			self.stub.first_time_triggered = 0;
		}
	}
	else if ( self.first_time_triggered )
	{
		if ( is_true( level.use_legacy_weapon_prompt_format ) )
		{
			self weapon_set_first_time_hint( cost, get_ammo_cost( self.zombie_weapon_upgrade ) );
		}
	}
	for ( ;; )
	{
		self waittill( "trigger", player );
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}
		if ( !player can_buy_weapon() )
		{
			wait 0.1;
			continue;
		}
		if ( isDefined( self.stub ) && is_true( self.stub.require_look_from ) )
		{
			toplayer = player get_eye() - self.origin;
			forward = -1 * anglesToRight( self.angles );
			dot = vectordot( toplayer, forward );
			if ( dot < 0 )
			{
				continue;
			}
		}
		if ( player has_powerup_weapon() )
		{
			wait 0.1;
			continue;
		}
		player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );
		if ( !player_has_weapon && is_true( level.weapons_using_ammo_sharing ) )
		{
			shared_ammo_weapon = player get_shared_ammo_weapon( self.zombie_weapon_upgrade );
			if ( isDefined( shared_ammo_weapon ) )
			{
				player_has_weapon = 1;
			}
		}
		if ( is_true( level.pers_upgrade_nube ) )
		{
			player_has_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_should_we_give_raygun( player_has_weapon, player, self.zombie_weapon_upgrade );
		}
		cost = get_weapon_cost( self.zombie_weapon_upgrade );
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			cost = int( cost / 2 );
		}
		if ( player.score >= cost )
		{
			if ( self.first_time_triggered == 0 )
			{
				self show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
			}
			player maps/mp/zombies/_zm_score::minus_to_player_score( cost, 1 );
			bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin, "weapon" );
			level notify( "weapon_bought", player, self.zombie_weapon_upgrade );
			if ( self.zombie_weapon_upgrade == "riotshield_zm" )
			{
				player maps/mp/zombies/_zm_equipment::equipment_give( "riotshield_zm" );
				if ( isDefined( player.player_shield_reset_health ) )
				{
					player [[ player.player_shield_reset_health ]]();
				}
			}
			else if ( self.zombie_weapon_upgrade == "jetgun_zm" )
			{
				player maps/mp/zombies/_zm_equipment::equipment_give( "jetgun_zm" );
			}
			else if ( is_lethal_grenade( self.zombie_weapon_upgrade ) )
			{
				player takeweapon( player get_player_lethal_grenade() );
				player set_player_lethal_grenade( self.zombie_weapon_upgrade );
			}
			str_weapon = self.zombie_weapon_upgrade;
			if ( is_true( level.pers_upgrade_nube ) )
			{
				str_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_weapon_upgrade_check( player, str_weapon );
			}
			player weapon_give( str_weapon );
			player.weaponTiers[get_base_name(str_weapon)] = self.stub.weaponTier;
			player.weaponPapTiers[get_base_name(str_weapon)] = 0;
			player maps/mp/zombies/_zm_stats::increment_client_stat( "wallbuy_weapons_purchased" );
			player maps/mp/zombies/_zm_stats::increment_player_stat( "wallbuy_weapons_purchased" );
		}
		else
		{
			play_sound_on_ent( "no_purchase" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
		}
	}
}

updateWallbuyTier()
{
	if ( is_melee_weapon( self.zombie_weapon_upgrade ) || self.zombie_weapon_upgrade == "claymore_zm" )
	{
		return;
	}
	self.weaponTier = 1;
	while(1)
	{
		level waittill("start_of_round");
		if((level.round_number % 5) == 0)
		{
			level waittill("end_of_round");
			if(RandomInt(2) == 1 )
			{
				self.weaponTier++;
			}
		}
		if(self.weaponTier >= 4)
		{
			self.weaponTier = 4;
			return;
		}
	}
}

wall_weapon_update_prompt2( player )
{
	weapon = self.zombie_weapon_upgrade;
	cost = get_weapon_cost( weapon );
	if(!isdefined(self.stub.weaponTier) || self.stub.weaponTier == 1)
		weapon_display = "Uncommon " + get_weapon_display_name( weapon );
	else if(is_true(self.stub.weaponTier == 2))
		weapon_display = "Rare " + get_weapon_display_name( weapon );
	else if(is_true(self.stub.weaponTier == 3))
		weapon_display = "Epic " + get_weapon_display_name( weapon );
	else if(is_true(self.stub.weaponTier == 4))
		weapon_display = "Legendary " + get_weapon_display_name( weapon );
	self sethintstring( &"ZOMBIE_WEAPONCOSTONLY", weapon_display, cost );
	return 1;
}
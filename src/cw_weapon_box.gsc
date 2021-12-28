#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/gametypes_zm/_hud_util;

main()
{
	replacefunc(maps/mp/zombies/_zm_magicbox::treasure_chest_init, ::treasure_chest_init);
	replacefunc(maps/mp/zombies/_zm_magicbox::treasure_chest_think, ::treasure_chest_think);
}

treasure_chest_init( start_chest_name ) //checked changed to match cerberus output
{
	flag_init( "moving_chest_enabled" );
	flag_init( "moving_chest_now" );
	flag_init( "chest_has_been_used" );
	level.chest_moves = 0;
	level.chest_level = 0;
	if ( level.chests.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.chests.size; i++ )
	{
		level.chests[ i ].box_hacks = [];
		level.chests[ i ].orig_origin = level.chests[ i ].origin;
		level.chests[ i ] get_chest_pieces();
		if ( isDefined( level.chests[ i ].zombie_cost ) )
		{
			level.chests[ i ].old_cost = level.chests[ i ].zombie_cost;
		}
		else 
		{
			level.chests[ i ].old_cost = 950;
		}
	}
	if ( !level.enable_magic )
	{
		foreach( chest in level.chests )
		{
			chest hide_chest();
		}
		return;
	}
	level.chest_accessed = 0;
	if ( level.chests.size > 1 )
	{
		flag_set( "moving_chest_enabled" );
		level.chests = array_randomize( level.chests );
	}
	else
	{
		level.chest_index = 0;
		level.chests[ 0 ].no_fly_away = 1;
	}
	init_starting_chest_location( start_chest_name );
	array_thread( level.chests, ::treasure_chest_think );
}

treasure_chest_think() //checked changed to match cerberus output
{
	self endon( "kill_chest_think" );
	user = undefined;
	user_cost = undefined;
	self.box_rerespun = undefined;
	self.weapon_out = undefined;

	self thread unregister_unitrigger_on_kill_think();
	while ( 1 )
	{
		if ( !isdefined( self.forced_user ) )
		{
			self waittill( "trigger", user );
			if ( user == level )
			{
				wait 0.1;
				continue;
			}
		}
		else
		{
			user = self.forced_user;
		}
		if ( user in_revive_trigger() )
		{
			wait 0.1;
			continue;
		}
		if ( user.is_drinking > 0 )
		{
			wait 0.1;
			continue;
		}
		if ( is_true( self.disabled ) )
		{
			wait 0.1;
			continue;
		}
		if ( user getcurrentweapon() == "none" )
		{
			wait 0.1;
			continue;
		}
		reduced_cost = undefined;
		if ( is_player_valid( user ) && user maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			reduced_cost = int( self.zombie_cost / 2 );
		}
		if ( is_true( level.using_locked_magicbox ) && is_true( self.is_locked ) ) 
		{
			if ( user.score >= level.locked_magic_box_cost )
			{
				user maps/mp/zombies/_zm_score::minus_to_player_score( level.locked_magic_box_cost );
				self.zbarrier set_magic_box_zbarrier_state( "unlocking" );
				self.unitrigger_stub run_visibility_function_for_all_triggers();
			}
			else
			{
				user maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			}
			wait 0.1 ;
			continue;
		}
		else if ( isdefined( self.auto_open ) && is_player_valid( user ) )
		{
			if ( !isdefined( self.no_charge ) )
			{
				user maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
				user_cost = self.zombie_cost;
			}
			else
			{
				user_cost = 0;
			}
			self.chest_user = user;
			break;
		}
		else if ( is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
			user_cost = self.zombie_cost;
			self.chest_user = user;
			break;
		}
		else if ( isdefined( reduced_cost ) && user.score >= reduced_cost )
		{
			user maps/mp/zombies/_zm_score::minus_to_player_score( reduced_cost );
			user_cost = reduced_cost;
			self.chest_user = user;
			break;
		}
		else if ( user.score < self.zombie_cost )
		{
			play_sound_at_pos( "no_purchase", self.origin );
			user maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			wait 0.1;
			continue;
		}
		wait 0.05;
	}
	flag_set( "chest_has_been_used" );
	maps/mp/_demo::bookmark( "zm_player_use_magicbox", getTime(), user );
	user maps/mp/zombies/_zm_stats::increment_client_stat( "use_magicbox" );
	user maps/mp/zombies/_zm_stats::increment_player_stat( "use_magicbox" );
	if ( isDefined( level._magic_box_used_vo ) )
	{
		user thread [[ level._magic_box_used_vo ]]();
	}
	self thread watch_for_emp_close();
	if ( is_true( level.using_locked_magicbox ) )
	{
		self thread maps/mp/zombies/_zm_magicbox_lock::watch_for_lock();
	}
	self._box_open = 1;
	self._box_opened_by_fire_sale = 0;
	if ( is_true( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && !isDefined( self.auto_open ) && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		self._box_opened_by_fire_sale = 1;
	}
	if ( isDefined( self.chest_lid ) )
	{
		self.chest_lid thread treasure_chest_lid_open();
	}
	if ( isDefined( self.zbarrier ) )
	{
		play_sound_at_pos( "open_chest", self.origin );
		play_sound_at_pos( "music_chest", self.origin );
		self.zbarrier set_magic_box_zbarrier_state( "open" );
	}
	self.timedout = 0;
	self.weapon_out = 1;

	weaponTier = getWeaponTier();
	self.zbarrier thread treasure_chest_weapon_spawn( self, user, undefined, weaponTier );
	self.zbarrier thread treasure_chest_glowfx();
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
	self.zbarrier waittill_any( "randomization_done", "box_hacked_respin" );
	if ( flag( "moving_chest_now" ) && !self._box_opened_by_fire_sale && isDefined( user_cost ) )
	{
		user maps/mp/zombies/_zm_score::add_to_player_score( user_cost, 0 );
	}
	if ( flag( "moving_chest_now" ) && !level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && !self._box_opened_by_fire_sale )
	{
		self thread treasure_chest_move( self.chest_user );
	}
	else
	{
		self.grab_weapon_hint = 1;
		self.grab_weapon_name = self.zbarrier.weapon_string;
		self.chest_user = user;
		thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
		if ( isDefined( self.zbarrier ) && !is_true( self.zbarrier.closed_by_emp ) )
		{
			self thread treasure_chest_timeout();
		}
		while ( !is_true( self.closed_by_emp ) )
		{
			self waittill( "trigger", grabber );
			self.weapon_out = undefined;
			if ( is_true( level.magic_box_grab_by_anyone ) )
			{
				if ( isplayer( grabber ) )
				{
					user = grabber;
				}
			}
			if ( is_true( level.pers_upgrade_box_weapon ) )
			{
				self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_box_weapon_used( user, grabber );
			}
			if ( isDefined( grabber.is_drinking ) && grabber.is_drinking > 0 )
			{
				wait 0.1;
				continue;
			}
			if ( grabber == user && user getcurrentweapon() == "none" )
			{
				wait 0.1;
				continue;
			}
			if ( grabber != level && is_true( self.box_rerespun ) )
			{
				user = grabber;
			}
			if ( grabber == user || grabber == level )
			{
				self.box_rerespun = undefined;
				current_weapon = "none";
				if ( is_player_valid( user ) )
				{
					current_weapon = user getcurrentweapon();
				}
				if ( grabber == user && is_player_valid( user ) && !user.is_drinking && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon )
				{
					bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", user.name, user.score, level.round_number, self.zombie_cost, self.zbarrier.weapon_string, self.origin, "magic_accept" );
					self notify( "user_grabbed_weapon" );
					user notify( "user_grabbed_weapon" );
					user thread treasure_chest_give_weapon( self.zbarrier.weapon_string );
					user.weaponTiers[get_base_name(self.zbarrier.weapon_string)] = weaponTier;
					user.weaponPapTiers[get_base_name(self.zbarrier.weapon_string)] = 0;
					maps/mp/_demo::bookmark( "zm_player_grabbed_magicbox", getTime(), user );
					user maps/mp/zombies/_zm_stats::increment_client_stat( "grabbed_from_magicbox" );
					user maps/mp/zombies/_zm_stats::increment_player_stat( "grabbed_from_magicbox" );
					break;
				}
				else if ( grabber == level )
				{
					unacquire_weapon_toggle( self.zbarrier.weapon_string );
					self.timedout = 1;
					if ( is_player_valid( user ) )
					{
						bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %S", user.name, user.score, level.round_number, self.zombie_cost, self.zbarrier.weapon_string, self.origin, "magic_reject" );
					}
					break;
				}
			}
			wait 0.05;
		}
		self.grab_weapon_hint = 0;
		self.zbarrier notify( "weapon_grabbed" );
		if ( !is_true( self._box_opened_by_fire_sale ) )
		{
			level.chest_accessed += 1;
		}
		if ( level.chest_moves > 0 && isDefined( level.pulls_since_last_ray_gun ) )
		{
			level.pulls_since_last_ray_gun += 1;
		}
		if ( isDefined( level.pulls_since_last_tesla_gun ) )
		{
			level.pulls_since_last_tesla_gun += 1;
		}
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
		if ( isDefined( self.chest_lid ) )
		{
			self.chest_lid thread treasure_chest_lid_close( self.timedout );
		}
		if ( isDefined( self.zbarrier ) )
		{
			self.zbarrier set_magic_box_zbarrier_state( "close" );
			play_sound_at_pos( "close_chest", self.origin );
			self.zbarrier waittill( "closed" );
			wait 1;
		}
		else
		{
			wait 3;
		}
		if ( is_true( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) || self [[ level._zombiemode_check_firesale_loc_valid_func ]]() || self == level.chests[ level.chest_index ] )
		{
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
		}
	}
	self._box_open = 0;
	self._box_opened_by_fire_sale = 0;
	self.chest_user = undefined;
	self notify( "chest_accessed" );
	self thread treasure_chest_think();
}

treasure_chest_give_weapon( weapon_string ) //checked matches cerberus output
{
	self.last_box_weapon = getTime();
	self maps/mp/zombies/_zm_weapons::weapon_give( weapon_string, 0, 1 );
}

getWeaponTier()
{
	if(level.round_number <= 10)
	{
		rand = RandomFloat(100.0);
		if(rand < 0.5)
		{
			weaponTier = 5;
		}
		else if(rand >= 0.5 && rand < 3.0)
		{
			weaponTier = 4;
		}
		else if(rand >= 3.0 && rand < 8.5)
		{
			weaponTier = 3;
		}
		else if(rand >= 8.5 && rand < 37.5)
		{
			weaponTier = 2;
		}
		else
		{
			weaponTier = 1;
		}
	}
	else if(level.round_number <= 15)
	{
		rand = RandomFloat(100.0);
		if(rand < 1)
		{
			weaponTier = 5;
		}
		else if(rand >= 1 && rand < 3)
		{
			weaponTier = 4;
		}
		else if(rand >= 3 && rand < 18)
		{
			weaponTier = 3;
		}
		else if(rand >= 18 && rand < 70.5)
		{
			weaponTier = 2;
		}
		else
		{
			weaponTier = 1;
		}
	}
	else if(level.round_number <= 20)
	{
		rand = RandomFloat(100.0);
		if(rand < 2.5)
		{
			weaponTier = 5;
		}
		else if(rand >= 2.5 && rand < 5)
		{
			weaponTier = 4;
		}
		else if(rand >= 5 && rand < 35.5)
		{
			weaponTier = 3;
		}
		else if(rand >= 35.5 && rand < 80)
		{
			weaponTier = 2;
		}
		else
		{
			weaponTier = 1;
		}
	}
	else if(level.round_number <= 25)
	{
		rand = RandomFloat(100.0);
		if(rand < 2.5)
		{
			weaponTier = 5;
		}
		else if(rand >= 2.5 && rand < 12)
		{
			weaponTier = 4;
		}
		else if(rand >= 12 && rand < 74)
		{
			weaponTier = 3;
		}
		else if(rand >= 74 && rand < 97)
		{
			weaponTier = 2;
		}
		else
		{
			weaponTier = 1;
		}
	}
	else if(level.round_number <= 30)
	{
		rand = RandomFloat(100.0);
		if(rand < 2.5)
		{
			weaponTier = 5;
		}
		else if(rand >= 2.5 && rand < 37)
		{
			weaponTier = 4;
		}
		else if(rand >= 37 && rand < 87.5)
		{
			weaponTier = 3;
		}
		else if(rand >= 87.5 && rand < 99.5)
		{
			weaponTier = 2;
		}
		else
		{
			weaponTier = 1;
		}
	}
	else if(level.round_number <= 40)
	{
		rand = RandomFloat(100.0);
		if(rand < 5.5)
		{
			weaponTier = 5;
		}
		else if(rand >= 5.5 && rand < 73.5)
		{
			weaponTier = 4;
		}
		else if(rand >= 73.5 && rand < 99.5)
		{
			weaponTier = 3;
		}
		else
		{
			weaponTier = 2;
		}
	}
	else
	{
		rand = RandomFloat(100.0);
		if(rand < 10)
		{
			weaponTier = 5;
		}
		else if(rand >= 10 && rand < 90)
		{
			weaponTier = 4;
		}
		else
		{
			weaponTier = 3;
		}
	}
	return weaponTier;
}

treasure_chest_weapon_spawn( chest, player, respin, tier ) //checked changed to match cerberus output
{
	if ( is_true( level.using_locked_magicbox ) )
	{
		self.owner endon( "box_locked" );
		self thread maps/mp/zombies/_zm_magicbox_lock::clean_up_locked_box();
	}
	self endon( "box_hacked_respin" );
	self thread clean_up_hacked_box();

	self.weapon_string = undefined;
	modelname = undefined;
	rand = undefined;
	number_cycles = 40;
	if ( isDefined( chest.zbarrier ) )
	{
		if ( isDefined( level.custom_magic_box_do_weapon_rise ) )
		{
			chest.zbarrier thread [[ level.custom_magic_box_do_weapon_rise ]]();
		}
		else
		{
			chest.zbarrier thread magic_box_do_weapon_rise();
		}
	}
	for ( i = 0; i < number_cycles; i++ )
	{

		if ( i < 20 )
		{
			wait 0.05 ; 
		}
		else if ( i < 30 )
		{
			wait 0.1 ; 
		}
		else if ( i < 35 )
		{
			wait 0.2 ; 
		}
		else if ( i < 38 )
		{
			wait 0.3 ; 
		}
	}
	if ( isDefined( level.custom_magic_box_weapon_wait ) )
	{
		[[ level.custom_magic_box_weapon_wait ]]();
	}
	if ( is_true( player.pers_upgrades_awarded[ "box_weapon" ] ) )
	{
		rand = maps/mp/zombies/_zm_pers_upgrades_functions::pers_treasure_chest_choosespecialweapon( player );
	}
	else
	{
		rand = treasure_chest_chooseweightedrandomweapon( player, tier );
	}
	
	self.weapon_string = rand;
	wait 0.1;
	if ( isDefined( level.custom_magicbox_float_height ) )
	{
		v_float = anglesToUp( self.angles ) * level.custom_magicbox_float_height;
	}
	else
	{
		v_float = anglesToUp( self.angles ) * 40;
	}
	self.model_dw = undefined;
	self.weapon_model = spawn_weapon_model( rand, undefined, self.origin + v_float, self.angles + vectorScale( ( 0, 1, 0 ), 180 ) );
	if ( weapon_is_dual_wield( rand ) )
	{
		self.weapon_model_dw = spawn_weapon_model( rand, get_left_hand_weapon_model_name( rand ), self.weapon_model.origin - vectorScale( ( 0, 1, 0 ), 3 ), self.weapon_model.angles );
	}
	if ( getDvar( "magic_chest_movable" ) == "1" && !is_true( chest._box_opened_by_fire_sale ) && !is_true( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		random = randomint( 100 );
		if ( !isDefined( level.chest_min_move_usage ) )
		{
			level.chest_min_move_usage = 4;
		}
		if ( level.chest_accessed < level.chest_min_move_usage )
		{
			chance_of_joker = -1;
		}
		else
		{
			chance_of_joker = level.chest_accessed + 20;
			if ( level.chest_moves == 0 && level.chest_accessed >= 8 )
			{
				chance_of_joker = 100;
			}
			if ( level.chest_accessed >= 4 && level.chest_accessed < 8 )
			{
				if ( random < 15 )
				{
					chance_of_joker = 100;
				}
				else
				{
					chance_of_joker = -1;
				}
			}
			if ( level.chest_moves > 0 )
			{
				if ( level.chest_accessed >= 8 && level.chest_accessed < 13 )
				{
					if ( random < 30 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
				if ( level.chest_accessed >= 13 )
				{
					if ( random < 50 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
			}
		}
		if ( isDefined( chest.no_fly_away ) )
		{
			chance_of_joker = -1;
		}
		if ( isDefined( level._zombiemode_chest_joker_chance_override_func ) )
		{
			chance_of_joker = [[ level._zombiemode_chest_joker_chance_override_func ]]( chance_of_joker );
		}
		if ( chance_of_joker > random )
		{
			self.weapon_string = undefined;
			self.weapon_model setmodel( level.chest_joker_model );
			self.weapon_model.angles = self.angles + vectorScale( ( 0, 1, 0 ), 90 );
			if ( isDefined( self.weapon_model_dw ) )
			{
				self.weapon_model_dw delete();
				self.weapon_model_dw = undefined;
			}
			self.chest_moving = 1;
			flag_set( "moving_chest_now" );
			level.chest_accessed = 0;
			level.chest_moves++;
		}
	}
	self notify( "randomization_done" );
	if ( flag( "moving_chest_now" ) && !level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		if ( isDefined( level.chest_joker_custom_movement ) )
		{
			self [[ level.chest_joker_custom_movement ]]();
		}
		else
		{
			wait 0.5;
			level notify( "weapon_fly_away_start" );
			wait 2;
			if ( isDefined( self.weapon_model ) )
			{
				v_fly_away = self.origin + ( anglesToUp( self.angles ) * 500 );
				self.weapon_model moveto( v_fly_away, 4, 3 );
			}
			if ( isDefined( self.weapon_model_dw ) )
			{
				v_fly_away = self.origin + ( anglesToUp( self.angles ) * 500 );
				self.weapon_model_dw moveto( v_fly_away, 4, 3 );
			}
			self.weapon_model waittill( "movedone" );
			self.weapon_model delete();
			if ( isDefined( self.weapon_model_dw ) )
			{
				self.weapon_model_dw delete();
				self.weapon_model_dw = undefined;
			}
			self notify( "box_moving" );
			level notify( "weapon_fly_away_end" );
		}
	}
	else
	{
		if(tier == 1)
		{
			fx = level._effect[ "powerup_on" ];
		}
		else if(tier == 2)
		{
			fx = level._effect[ "powerup_on_solo" ];
		}
		else if(tier == 3)
		{
			fx = level._effect[ "monkey_glow" ];
		}
		else if(tier == 4)
		{
			fx = level._effect[ "powerup_on_caution" ];
		}
		else if(tier == 5)
		{
			fx = level._effect[ "powerup_on_caution" ];
		}
		PlayFXOnTag(fx, self.weapon_model, "tag_origin");
		acquire_weapon_toggle( rand, player );
		if ( rand == "tesla_gun_zm" || rand == "ray_gun_zm" )
		{
			if ( rand == "ray_gun_zm" )
			{
				level.pulls_since_last_ray_gun = 0;
			}
			if ( rand == "tesla_gun_zm" )
			{
				level.pulls_since_last_tesla_gun = 0;
				level.player_seen_tesla_gun = 1;
			}
		}
		if ( !isDefined( respin ) )
		{
			if ( isDefined( chest.box_hacks[ "respin" ] ) )
			{
				self [[ chest.box_hacks[ "respin" ] ]]( chest, player );
			}
		}
		else
		{
			if ( isDefined( chest.box_hacks[ "respin_respin" ] ) )
			{
				self [[ chest.box_hacks[ "respin_respin" ] ]]( chest, player );
			}
		}
		if ( isDefined( level.custom_magic_box_timer_til_despawn ) )
		{
			self.weapon_model thread [[ level.custom_magic_box_timer_til_despawn ]]( self );
		}
		else
		{
			self.weapon_model thread timer_til_despawn( v_float );
		}
		if ( isDefined( self.weapon_model_dw ) )
		{
			if ( isDefined( level.custom_magic_box_timer_til_despawn ) )
			{
				self.weapon_model_dw thread [[ level.custom_magic_box_timer_til_despawn ]]( self );
			}
			else
			{
				self.weapon_model_dw thread timer_til_despawn( v_float );
			}
		}
		self waittill( "weapon_grabbed" );
		if ( !chest.timedout )
		{
			if ( isDefined( self.weapon_model ) )
			{
				self.weapon_model delete();
			}
			if ( isDefined( self.weapon_model_dw ) )
			{
				self.weapon_model_dw delete();
			}
		}
	}
	self.weapon_string = undefined;
	self notify( "box_spin_done" );
}

treasure_chest_chooseweightedrandomweapon( player, tier ) //checked changed to match cerberus output
{
	keys = array_randomize( getarraykeys( level.zombie_weapons ) );
	if ( isDefined( level.customrandomweaponweights ) )
	{
		keys = player [[ level.customrandomweaponweights ]]( keys );
	}
	if(tier == 5)
	{
		keys = array_randomize(level.ultra_weapons);
	}
	else
	{
		foreach(weapon in level.ultra_weapons)
			ArrayRemoveValue(keys, weapon);
	}

	pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( treasure_chest_canplayerreceiveweapon( player, keys[ i ], pap_triggers ) )
		{
			return keys[ i ];
		}
	}
	return keys[ 0 ];
}

treasure_chest_canplayerreceiveweapon( player, weapon, pap_triggers ) //checked matches cerberus output
{
	if ( !get_is_in_box( weapon ) )
	{
		return 0;
	}
	if ( !player player_can_use_content( weapon ) )
	{
		return 0;
	}
	if ( isDefined( level.custom_magic_box_selection_logic ) )
	{
		if ( !( [[ level.custom_magic_box_selection_logic ]]( weapon, player, pap_triggers ) ) )
		{
			return 0;
		}
	}
	return 1;
}

treasure_chest_glowfx() //checked matches cerberus output
{
	self setclientfield( "magicbox_glow", 1 );
	self waittill_any( "randomization_done", "box_hacked_respin" );
	self setclientfield( "magicbox_glow", 0 );
}
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_laststand;

main()
{
	replacefunc(maps/mp/zombies/_zm::onallplayersready, ::onallplayersready);
}

init()
{
	level.perk_purchase_limit = 10;
	level.overrideplayerdamage = ::player_damage_override;
	level.playerlaststand_func = ::player_laststand;
}

onallplayersready() //checked changed to match cerberus output
{
	players = get_players();
	while ( players.size == 0 )
	{
		players = get_players();
		wait 0.1;
	}
	player_count_actual = 0;
	//fixed fast restart
	while ( player_count_actual < players.size )
	{
		players = get_players();
		player_count_actual = 0;
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ].sessionstate == "playing" )
			{
				player_count_actual++;
			}
		}
		wait 0.1;
	}
	setinitialplayersconnected(); 
	players = get_players();
	if ( players.size == 1 && getDvarInt( "scr_zm_enable_bots" ) == 1 )
	{
		level thread add_bots();
		flag_set( "initial_players_connected" );
	}
	else
	{
		players = get_players();
		if ( players.size == 1 )
		{
			flag_set( "solo_game" );
			level.solo_lives_given = 0;
			foreach ( player in players )
			{
				player.lives = 2;
			}
			level set_default_laststand_pistol( 1 );
		}
		flag_set( "initial_players_connected" );
		while ( !aretexturesloaded() )
		{
			wait 0.05;
		}
		thread start_zombie_logic_in_x_sec( 3 );
	}
	fade_out_intro_screen_zm( 5, 1.5, 1 );
}

player_laststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked changed to match cerberus output //checked against bo3 _zm.gsc matches within reason
{
	b_alt_visionset = 0;
	self allowjump( 0 );
	currweapon = self getcurrentweapon();
	statweapon = currweapon;
	if ( is_alt_weapon( statweapon ) )
	{
		statweapon = weaponaltweaponname( statweapon );
	}
	self addweaponstat( statweapon, "deathsDuringUse", 1 );
	if ( is_true( self.hasperkspecialtytombstone ) )
	{
		self.laststand_perks = maps/mp/zombies/_zm_tombstone::tombstone_save_perks( self );
	}
	if ( isDefined( self.pers_upgrades_awarded[ "perk_lose" ] ) && self.pers_upgrades_awarded[ "perk_lose" ] )
	{
		self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_perk_lose_save();
	}
	players = get_players();
	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( self.lives > 0 )
		{
			self thread wait_and_revive();
		}
	}
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = take_additionalprimaryweapon();
	}
	if ( is_true( self.hasperkspecialtytombstone ) )
	{
		self [[ level.tombstone_laststand_func ]]();
		self thread [[ level.tombstone_spawn_func ]]();
		self.hasperkspecialtytombstone = undefined;
		self notify( "specialty_scavenger_stop" );
	}
	self clear_is_drinking();
	self thread remove_deadshot_bottle();
	self thread remote_revive_watch();
	self maps/mp/zombies/_zm_score::player_downed_penalty();
	self disableoffhandweapons();
	self thread last_stand_grenade_save_and_return();
	if ( smeansofdeath != "MOD_SUICIDE" && smeansofdeath != "MOD_FALLING" )
	{
		if ( !is_true( self.intermission ) )
		{
			self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "revive_down" );
		}
		else
		{
			if ( isDefined( level.custom_player_death_vo_func ) &&  !self [[ level.custom_player_death_vo_func ]]() )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "exert_death" );
			}
		}
	}
	bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "downed", self.origin );
	if ( isDefined( level._zombie_minigun_powerup_last_stand_func ) )
	{
		self thread [[ level._zombie_minigun_powerup_last_stand_func ]]();
	}
	if ( isDefined( level._zombie_tesla_powerup_last_stand_func ) )
	{
		self thread [[ level._zombie_tesla_powerup_last_stand_func ]]();
	}
	if ( self hasperk( "specialty_grenadepulldeath" ) )
	{
		b_alt_visionset = 1;
		if ( isDefined( level.custom_laststand_func ) )
		{
			self thread [[ level.custom_laststand_func ]]();
		}
	}
	if ( is_true( self.intermission ) )
	{
		bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "died", self.origin );
		wait 0.5;
		self stopsounds();
		level waittill( "forever" );
	}
	if ( !b_alt_visionset )
	{
		visionsetlaststand( "zombie_last_stand", 1 );
	}
}

player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked changed to match cerberus output
{
	if ( isDefined( level._game_module_player_damage_callback ) )
	{
		self [[ level._game_module_player_damage_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	idamage = self check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	if ( is_true( self.use_adjusted_grenade_damage ) )
	{
		self.use_adjusted_grenade_damage = undefined;
		if ( self.health > idamage )
		{
			return idamage;
		}
	}
	if ( !idamage )
	{
		return 0;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( einflictor ) )
	{
		if ( is_true( einflictor.water_damage ) )
		{
			return 0;
		}
	}
	if ( isDefined( eattacker ) && is_true( eattacker.is_zombie ) || isplayer( eattacker ) )
	{
		if ( is_true( self.hasriotshield ) && isDefined( vdir ) )
		{
			if ( is_true( self.hasriotshieldequipped ) )
			{
				if ( self player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
			else if ( !isDefined( self.riotshieldentity ) )
			{
				if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
		}
	}
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( self.ignoreattacker ) && self.ignoreattacker == eattacker )
		{
			return 0;
		}
		if ( is_true( self.is_zombie ) && is_true( eattacker.is_zombie ) )
		{
			return 0;
		}
		if ( is_true( eattacker.is_zombie ) )
		{
			self.ignoreattacker = eattacker;
			self thread remove_ignore_attacker();
			if ( isDefined( eattacker.custom_damage_func ) )
			{
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			}
			else if ( isDefined( eattacker.meleedamage ) )
			{
				idamage = eattacker.meleedamage;
			}
			else
			{
				idamage = 50;
			}
		}
		eattacker notify( "hit_player" );
		if ( smeansofdeath != "MOD_FALLING" )
		{
			self thread playswipesound( smeansofdeath, eattacker );
			//changed to match bo3 _zm.gsc
			if ( is_true( eattacker.is_zombie ) || isplayer( eattacker ) )
			{
				self playrumbleonentity( "damage_heavy" );
			}
			canexert = 1;
			if ( is_true( level.pers_upgrade_flopper ) )
			{
				if ( is_true( self.pers_upgrades_awarded[ "flopper" ] ) )
				{
					if ( smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH" )
					{
						canexert = smeansofdeath;
					}
				}
			}
			if ( is_true( canexert ) )
			{
				if ( randomintrange( 0, 1 ) == 0 )
				{
					self thread maps/mp/zombies/_zm_audio::playerexert( "hitmed" );
				}
				else
				{
					self thread maps/mp/zombies/_zm_audio::playerexert( "hitlrg" );
				}
			}
		}
	}
	finaldamage = idamage;
	//checked changed to match bo1 _zombiemode.gsc
	if ( is_placeable_mine( sweapon ) || sweapon == "freezegun_zm" || sweapon == "freezegun_upgraded_zm" )
	{
		return 0;
	}
	if ( isDefined( self.player_damage_override ) )
	{
		self thread [[ self.player_damage_override ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	if ( smeansofdeath == "MOD_FALLING" )
	{
		if ( self hasperk( "specialty_flakjacket" ) && isDefined( self.divetoprone ) && self.divetoprone == 1 )
		{
			if ( isDefined( level.zombiemode_divetonuke_perk_func ) )
			{
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );
			}
			return 0;
		}
		if ( is_true( level.pers_upgrade_flopper ) )
		{
			if ( self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_flopper_damage_check( smeansofdeath, idamage ) )
			{
				return 0;
			}
		}
	}
	//checked changed to match bo1 _zombiemode.gsc
	if ( smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( self hasperk( "specialty_flakjacket" ) )
		{
			return 0;
		}
		if ( is_true( level.pers_upgrade_flopper ) )
		{
			if ( is_true( self.pers_upgrades_awarded[ "flopper" ] ) )
			{
				return 0;
			}
		}
		if ( self.health > 75 && !is_true( self.is_zombie ) )
		{
			return 75;
		}
	}
	if ( idamage < self.health )
	{
		if ( isDefined( eattacker ) )
		{
			if ( isDefined( level.custom_kill_damaged_vo ) )
			{
				eattacker thread [[ level.custom_kill_damaged_vo ]]( self );
			}
			else
			{
				eattacker.sound_damage_player = self;
			}
			if ( !is_true( eattacker.has_legs ) )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "crawl_hit" );
			}
			else if ( isDefined( eattacker.animname ) && eattacker.animname == "monkey_zombie" )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "monkey_hit" );
			}
		}
		return finaldamage;
	}
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( eattacker.animname ) && eattacker.animname == "zombie_dog" )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "killed_by_zdog" );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "killed_by_zdog" );
		}
		else if ( isDefined( eattacker.is_avogadro ) && eattacker.is_avogadro )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "killed_by_avogadro", 0 );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "killed_by_avogadro" );
		}
	}
	self thread clear_path_timers();
	if ( level.intermission )
	{
		level waittill( "forever" );
	}
	//changed from && to ||
	if ( self hasperk( "specialty_finalstand" ) || self hasperk("specialty_scavenger") )
	{

		if ( isDefined( level.chugabud_laststand_func ) )
		{
			self thread [[ level.chugabud_laststand_func ]]();
			return 0;
		}
	}
	players = get_players();
	count = 0;
	//subtle changes in logic in the if statements
	for ( i = 0; i < players.size; i++ )
	{
		//count of dead players
		//checked changed to match bo1 _zombiemode.gsc
		if ( players[ i ] == self || players[ i ].is_zombie || players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate == "spectator" )
		{
			count++;
		}
	}
	//checked against bo3 _zm.gsc changed to match 
	if ( count < players.size || isDefined( level._game_module_game_end_check ) && ![[ level._game_module_game_end_check ]]() )
	{
		if ( isDefined( self.lives ) && self.lives > 0 && is_true( level.force_solo_quick_revive ) )
		{
			self thread wait_and_revive();
		}
		return finaldamage;
	}
	solo_death = is_solo_death( self, players );
	non_solo_death = is_non_solo_death( self, players, count );
	if ( ( solo_death || non_solo_death ) && !is_true( level.no_end_game_check ) )
	{
		level notify( "stop_suicide_trigger" );
		self thread maps/mp/zombies/_zm_laststand::playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
		if ( !isDefined( vdir ) )
		{
			vdir = ( 1, 0, 0 );
		}
		self fakedamagefrom( vdir );
		if ( isDefined( level.custom_player_fake_death ) )
		{
			self thread [[ level.custom_player_fake_death ]]( vdir, smeansofdeath );
		}
		else
		{
			self thread player_fake_death();
		}
	}
	if ( count == players.size && !is_true( level.no_end_game_check ) )
	{
		if ( players.size == 1 && flag( "solo_game" ) )
		{
			if ( self.lives == 0 )
			{
				self.lives = 0;
				level notify( "pre_end_game" );
				wait_network_frame();
				if ( flag( "dog_round" ) )
				{
					increment_dog_round_stat( "lost" );
				}
				level notify( "end_game" );
			}
			else
			{
				return finaldamage;
			}
		}
		else
		{
			level notify( "pre_end_game" );
			wait_network_frame();
			if ( flag( "dog_round" ) )
			{
				increment_dog_round_stat( "lost" );
			}
			level notify( "end_game" );
		}
		return 0;
	}
	else
	{
		surface = "flesh";
		return finaldamage;
	}
}

is_solo_death( self, players )
{
	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( self.lives == 0 )
		{
			return 1;
		}
	}
	return 0;
}	

is_non_solo_death( self, players, count )
{
	if ( count > 1 || players.size == 1 && !flag( "solo_game" ) )
	{
		return 1;
	}
	return 0;
}
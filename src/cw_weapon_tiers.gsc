#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_magicbox;

//This Script is to be used with only the Cold War Mod. This will not be compatible with any other mods.
main()
{
	replacefunc(maps/mp/zombies/_zm_weapons::weapon_give, ::weapon_give);
	replacefunc(maps/mp/zombies/_zm_weapons::can_upgrade_weapon, ::can_upgrade_weapon);
	replacefunc(maps/mp/zombies/_zm_perks::third_person_weapon_upgrade, ::third_person_weapon_upgrade);
	replacefunc(maps/mp/zombies/_zm_perks::init, ::perk_init);
	replacefunc(maps/mp/zombies/_zm::ai_zombie_health, ::ai_zombie_health);
	replacefunc(maps/mp/zombies/_zm::ai_calculate_health, ::ai_calculate_health);
	replacefunc(maps/mp/zombies/_zm_score::player_add_points, ::player_add_points);
	replacefunc(maps/mp/zombies/_zm::actor_damage_override_wrapper, ::actor_damage_override_wrapper_cw);
}
init()
{
	precacheshader("damage_feedback");
	level.player_starting_points = 500000;
	onplayerconnect_callback( ::player_connect_tiers );
	if(level.script != "zm_tomb")
		thread callbacks();
	thread freeSalvage();
}

callbacks()
{
	level waittill("initial_blackscreen_passed");
	level.callbackactordamage = ::actor_damage_override_wrapper_cw;
}

player_connect_tiers()
{
	if(!isdefined(self.weaponTiers))
	{
		self.weaponTiers = [];
	}
	if(!isdefined(self.weaponPapTiers))
	{
		self.weaponPapTiers = [];
	}
	self.salvage = 0;
	self.rare_salvage = 0;

	self thread onplayerspawned();
	self thread meleeCoords();
}

meleeCoords()
{
	level endon("end_game");
	self endon("disconnnect");
	for(;;)
	{
		if(self meleeButtonPressed())
		{
			
			self IPrintLn("hello there");
			me = self.origin;
			you = self GetPlayerAngles();
			self IPrintLn("Origin = "+ me);
			angles = (0, (self GetPlayerAngles())[1] + 90, 0);
			logprint(self.origin + ", " + angles + "\n");
			wait 1;
			self IPrintLn("Angles = "+ you);


			/*IPrintLn("Changing Weapon Tier");
			weapon = maps/mp/zombies/_zm_weapons::get_base_name(self GetCurrentWeapon());
			if(!isdefined(self.weaponTiers))
			{
				self.weaponTiers = [];
			}
			if(!isdefined(self.weaponTiers[weapon]))
			{
				self.weaponTiers[weapon] = 0;
			}
			else
			{
				if(self.weaponTiers[weapon] == 4)
				{
					self.weaponTiers[weapon] = 0;
				}
				else
				{
					self.weaponTiers[weapon]++;
				}
			}*/
			/*
			for(i=0;i<level.chests.size;i++)
			{
				self IPrintLn(level.chests[i].script_noteworthy);
				wait 0.5;
			}*/
		}
		wait .5;
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	self setperk("specialty_additionalprimaryweapon");
    self setperk("specialty_armorpiercing");
    self setperk("specialty_armorvest");
    self setperk("specialty_bulletaccuracy");
    self setperk("specialty_bulletdamage");
    self setperk("specialty_bulletflinch");
    self setperk("specialty_bulletpenetration");
    self setperk("specialty_deadshot");
    self setperk("specialty_delayexplosive");
    self setperk("specialty_detectexplosive");
    self setperk("specialty_disarmexplosive");
    self setperk("specialty_earnmoremomentum");
    self setperk("specialty_explosivedamage");
    self setperk("specialty_extraammo");
    self setperk("specialty_fallheight");
    self setperk("specialty_fastads");
    self setperk("specialty_fastequipmentuse");
    self setperk("specialty_fastladderclimb");
    self setperk("specialty_fastmantle");
    self setperk("specialty_fastmeleerecovery");
    self setperk("specialty_fastreload");
    self setperk("specialty_fasttoss");
    self setperk("specialty_fastweaponswitch");
    self setperk("specialty_finalstand");
    self setperk("specialty_fireproof");
    self setperk("specialty_flakjacket");
    self setperk("specialty_flashprotection");
    self setperk("specialty_gpsjammer");
    self setperk("specialty_grenadepulldeath");
    self setperk("specialty_healthregen");
    self setperk("specialty_holdbreath");
    self setperk("specialty_immunecounteruav");
    self setperk("specialty_immuneemp");
    self setperk("specialty_immunemms");
    self setperk("specialty_immunenvthermal");
    self setperk("specialty_immunerangefinder");
    self setperk("specialty_killstreak");
    self setperk("specialty_longersprint");
    self setperk("specialty_loudenemies");
    self setperk("specialty_marksman");
    self setperk("specialty_movefaster");
    self setperk("specialty_nomotionsensor");
    self setperk("specialty_noname");
    self setperk("specialty_nottargetedbyairsupport");
    self setperk("specialty_nokillstreakreticle");
    self setperk("specialty_nottargettedbysentry");
    self setperk("specialty_pin_back");
    self setperk("specialty_pistoldeath");
    self setperk("specialty_proximityprotection");
    self setperk("specialty_quickrevive");
    self setperk("specialty_quieter");
    self setperk("specialty_reconnaissance");
    self setperk("specialty_rof");
    self setperk("specialty_scavenger");
    self setperk("specialty_showenemyequipment");
    self setperk("specialty_stunprotection");
    self setperk("specialty_shellshock");
    self setperk("specialty_sprintrecovery");
    self setperk("specialty_showonradar");
    self setperk("specialty_stalker");
    self setperk("specialty_twogrenades");
    self setperk("specialty_twoprimaries");
    self setperk("specialty_unlimitedsprint");
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self setclientuivisibilityflag("hud_visible",0);
		if(level.round_number <= 2)
		{
			if(!isdefined(self.weaponTiers[level.start_weapon]))
				self.weaponTiers[level.start_weapon] = 0;
		}
		else if(level.round_number <= 10)
		{
			if(!isdefined(self.weaponTiers[level.start_weapon]) || is_true(self.weaponTiers[level.start_weapon] < 1))
				self.weaponTiers[level.start_weapon] = 1;
		}
		else if(level.round_number <= 20)
		{
			self.salvage = 500;
			self.rare_salvage = 100;
			if(!isdefined(self.weaponTiers[level.start_weapon]) || is_true(self.weaponTiers[level.start_weapon] < 2))
				self.weaponTiers[level.start_weapon] = 2;
		}
		else if(level.round_number <= 30)
		{
			self.salvage = 1000;
			self.rare_salvage = 500;
			if(!isdefined(self.weaponTiers[level.start_weapon]) || is_true(self.weaponTiers[level.start_weapon] < 3))
				self.weaponTiers[level.start_weapon] = 3;
		}
		else
		{
			self.salvage = 1500;
			self.rare_salvage = 1000;
			if(!isdefined(self.weaponTiers[level.start_weapon]) || is_true(self.weaponTiers[level.start_weapon] < 4))
				self.weaponTiers[level.start_weapon] = 4;
		}
	}
}

actor_damage_override_wrapper_cw( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked does not match cerberus output did not change
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( ( self.health - damage_override ) > 0 || !is_true( self.dont_die_on_me ) )
	{
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	else 
	{
		self [[ level.callbackactorkilled ]]( inflictor, attacker, damage, meansofdeath, weapon, vdir, shitloc, psoffsettime );
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked changed to match cerberus output //checked against bo3 _zm.gsc partially changed to match
{
	if ( !isDefined( self ) || !isDefined( attacker ) )
	{
		return damage;
	}
	if ( weapon == "tazer_knuckles_zm" || weapon == "jetgun_zm" )
	{
		self.knuckles_extinguish_flames = 1;
	}
	else if ( weapon != "none" )
	{
		self.knuckles_extinguish_flames = undefined;
	}
	if ( isDefined( attacker.animname ) && attacker.animname == "quad_zombie" )
	{
		if ( isDefined( self.animname ) && self.animname == "quad_zombie" )
		{
			return 0;
		}
	}
	if ( !isplayer( attacker ) && isDefined( self.non_attacker_func ) )
	{
		if ( isDefined( self.non_attack_func_takes_attacker ) && self.non_attack_func_takes_attacker )
		{
			return self [[ self.non_attacker_func ]]( damage, weapon, attacker );
		}
		else
		{
			return self [[ self.non_attacker_func ]]( damage, weapon );
		}
	}
	if ( !isplayer( attacker ) && !isplayer( self ) )
	{
		return damage;
	}
	if ( !isDefined( damage ) || !isDefined( meansofdeath ) )
	{
		return damage;
	}
	if ( meansofdeath == "" )
	{
		return damage;
	}
	old_damage = damage;
	final_damage = damage;
	if ( isDefined( self.actor_damage_func ) )
	{
		final_damage = [[ self.actor_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	if ( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	{
		attacker = attacker.owner;
	}
	if ( isDefined( self.in_water ) && self.in_water )
	{
		if ( int( final_damage ) >= self.health )
		{
			self.water_damage = 1;
		}
	}
	attacker thread maps/mp/gametypes_zm/_weapons::checkhit( weapon );
	if ( attacker maps/mp/zombies/_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() && is_headshot( weapon, shitloc, meansofdeath ) )
	{
		final_damage *= 2;
	}
	if ( is_true( level.headshots_only ) && isDefined( attacker ) && isplayer( attacker ) )
	{
		//changed to match bo3 _zm.gsc behavior
		if ( meansofdeath == "MOD_MELEE" && shitloc == "head" || meansofdeath == "MOD_MELEE" && shitloc == "helmet" )
		{
			return int( final_damage );
		}
		if ( is_explosive_damage( meansofdeath ) )
		{
			return int( final_damage );
		}
		else if ( !is_headshot( weapon, shitloc, meansofdeath ) )
		{
			return 0;
		}
	}
	if ( is_true( level.zombiemode_using_deadshot_perk ) && isDefined( attacker ) && isPlayer( attacker ) && attacker hasPerk( "specialty_deadshot" ) && is_headshot( weapon, shitloc, meansofdeath ) && self.health >= self.maxHealth )
	{
		final_damage *= 2;
	}
	base_weapon = get_base_name(weapon);
	if(is_true(base_weapon == "m1911_zm"))
	{
		final_damage = final_damage * 6.24;
	}
	else if(is_true(base_weapon == "rottweil72_zm"))
	{
		final_damage = final_damage * 2;
	}
	else if(is_true(base_weapon == "ak74u_upgraded_zm") || is_true(base_weapon == "ak74u_extclip_upgraded_zm"))
	{
		final_damage = final_damage * 1.26;
	}
	else if(is_true(base_weapon == "mp5k_upgraded_zm"))
	{
		final_damage = final_damage * 1.43;
	}
	else if(is_true(base_weapon == "judge_upgraded_zm") || is_true(base_weapon == "ballista_upgraded_zm"))
	{
		final_damage = final_damage * 0.75;
	}
	else if(is_true(base_weapon == "m14_upgraded_zm"))
	{
		final_damage = final_damage * 0.65;
	}
	else if(is_true(base_weapon == "ak47_upgraded_zm") || is_true(base_weapon == "kard_upgraded_zm"))
	{
		final_damage = final_damage * 1.50;
	}
	else if(is_true(base_weapon == "saritch_upgraded_zm") || is_true(base_weapon == "fnfal_upgraded_zm") || is_true(base_weapon == "tar21_upgraded_zm") || is_true(base_weapon == "xm8_upgraded_zm") || is_true(base_weapon == "m16_gl_upgraded_zm"))
	{
		final_damage = final_damage * 1.33;
	}
	else if(is_true(base_weapon == "beretta93r_upgraded_zm") || is_true(base_weapon == "beretta94r_extclip_upgraded_zm") || is_true(base_weapon == "ksg_upgraded_zm") || is_true(base_weapon == "dsr50_upgraded_zm") || is_true(base_weapon == "mg08_upgraded_zm"))
	{
		final_damage = final_damage * 1.60;
	}
	else if(is_true(base_weapon == "python_upgraded_zm") || is_true(base_weapon == "rnma_upgraded_zm"))
	{
		final_damage = final_damage * 2.00;
	}
	else if(is_true(base_weapon == "srm1216_upgraded_zm"))
	{
		final_damage = final_damage * 0.57;
	}
	else if(is_true(base_weapon == "qcw05_upgraded_zm"))
	{
		final_damage = final_damage * 1.25;
	}
	else if(is_true(base_weapon == "uzi_upgraded_zm"))
	{
		final_damage = final_damage * 0.87;
	}
	else if(is_true(base_weapon == "mp40_upgraded_zm") || is_true(base_weapon == "mp40_stalker_upgraded_zm"))
	{
		final_damage = final_damage * 1.10;
	}
	else if(is_true(base_weapon == "type95_upgraded_zm"))
	{
		final_damage = final_damage * 1.38;
	}
	else if(is_true(base_weapon == "hk416_upgraded_zm") || is_true(base_weapon == "galil_upgraded_zm"))
	{
		final_damage = final_damage * 1.36;
	}
	else if(is_true(base_weapon == "scar_upgraded_zm"))
	{
		final_damage = final_damage * 1.40;
	}
	else if(is_true(base_weapon == "an94_upgraded_zm") || is_true(base_weapon == "mp44_upgraded_zm") || is_true(base_weapon == "barretm82_upgraded_zm"))
	{
		final_damage = final_damage * 1.20;
	}
	else if(is_true(base_weapon == "svu_upgraded_zm"))
	{
		final_damage = final_damage * 1.22;
	}
	else if(is_true(base_weapon == "lsat_upgraded_zm") || is_true(base_weapon == "hamr_upgraded_zm"))
	{
		final_damage = final_damage * 1.52;
	}
	else if(is_true(base_weapon == "rpd_upgraded_zm"))
	{
		final_damage = final_damage * 1.56;
	}
	else if(is_true(base_weapon == "ray_gun_upgraded_zm"))
	{
		if(meansofdeath == "MOD_PROJECTILE_SPLASH")
		{
			final_damage = final_damage * 1.5;
		}
		else
		{
			final_damage = final_damage * 2;
		}
	}
	if(isdefined(attacker.weaponTiers) && isdefined(attacker.weaponTiers[base_weapon]))
	{
		if(attacker.weaponTiers[base_weapon] == 1)
		{
			final_damage = final_damage * 0.48;
		}
		else if(attacker.weaponTiers[base_weapon] == 2)
		{
			final_damage = final_damage * 0.64;
		}
		else if(attacker.weaponTiers[base_weapon] == 3)
		{
			final_damage = final_damage * 0.96;
		}
		else if(attacker.weaponTiers[base_weapon] == 4)
		{
			final_damage = final_damage * 1.28;
		}
		else if(attacker.weaponTiers[base_weapon] == 5)
		{
			if(is_true(base_weapon == "ray_gun_zm") || is_true(base_weapon == "ray_gun_upgraded_zm") || is_true(base_weapon == "raygun_mark2_zm") || is_true(base_weapon == "raygun_mark2_upgraded_zm" ))
			{
				final_damage = final_damage * 0.4;
			}
		}
		else 
		{
			final_damage = final_damage * 0.32;
		}
	}
	if(isdefined(attacker.weaponPapTiers) && isdefined(attacker.weaponPapTiers[base_weapon]))
	{
		if(attacker.weaponPapTiers[base_weapon] == 2)
		{
			final_damage = final_damage * 2;
		}
		if(attacker.weaponPapTiers[base_weapon] == 3)
		{
			final_damage = final_damage * 4;
		}
	}
	if(attacker HasPerk("specialty_rof") && is_double_tap_weapon(meansofdeath))
	{
		final_damage = final_damage * 0.5;
	}
	if(self.health <= final_damage)
	{
		if(isdefined(attacker) && !is_true(self.ignore_enemy_count))
		{
			attacker.cw_hitmarker.color = (1,0,0);
			attacker.cw_hitmarker.alpha = 1;
			attacker.cw_hitmarker fadeOverTime( 0.5 );
			attacker.cw_hitmarker.alpha = 0;
		}
		if(RandomInt(100) < 25)
		{
			if(level.round_number <= 5)
			{
				if(RandomInt(100) < 87)
				{
					thread salvageDrop(0, self.origin, self.angles);
				}
				else
				{
					thread salvageDrop(1, self.origin, self.angles);
				}
			}
			else if(level.round_number <= 10)
			{
				if(RandomInt(100) < 77)
				{
					thread salvageDrop(0, self.origin, self.angles);
				}
				else
				{
					thread salvageDrop(1, self.origin, self.angles);
				}
			}
			else if(level.round_number <= 15)
			{
				if(RandomInt(100) < 63)
				{
					thread salvageDrop(0, self.origin, self.angles);
				}
				else
				{
					thread salvageDrop(1, self.origin, self.angles);
				}
			}
			else if(level.round_number <=25)
			{
				if(RandomInt(100) < 47)
				{
					thread salvageDrop(0, self.origin, self.angles);
				}
				else
				{
					thread salvageDrop(1, self.origin, self.angles);
				}
			}
			else
			{
				if(RandomInt(100) < 38)
				{
					thread salvageDrop(0, self.origin, self.angles);
				}
				else
				{
					thread salvageDrop(1, self.origin, self.angles);
				}
			}
		}
	}
	else
	{
		if(isdefined(attacker) && !is_true(self.ignore_enemy_count))
		{
			attacker.cw_hitmarker.color = (1,1,1);
			attacker.cw_hitmarker.alpha = 1;
			attacker.cw_hitmarker fadeOverTime( 0.5 );
			attacker.cw_hitmarker.alpha = 0;
		}
	}
	if(isdefined(attacker))
	{
		if(attacker scripts/zm/cw_perks::has_active_perk("specialty_elementalpop") && !is_true(self.ignore_enemy_count) && attacker.elementalpop_cooldown <= 0 && chance_of_activation(meansofdeath) == 0)
		{
			attacker notify("elementalpop_activated");
			attacker._health_overlay.color = (0.7,1,1);
			attacker._health_overlay.alpha = 0.75;
			attacker._health_overlay FadeOverTime(2);
			attacker._health_overlay.color = (1,1,1);
			attacker._health_overlay.alpha = 0;
			attacker.elementalpop_cooldown = 40;
			rand = RandomInt(3);
			if(rand == 0)
			{
				IPrintLn("Brain Rot AAT");
				self set_zombie_run_cycle("sprint");
				self.team = "allies";
				self.favoriteenemy = self;
				self.magic_bullet_shield = true;
				self.maxHealth = 999999;
				self.health = self.maxHealth;
				PlayFXOnTag(level._effect[ "powerup_on" ], self, "j_head");
				self EnableInvulnerability();
				self thread turned_aat(attacker);
				self thread turned_timeout(attacker);
				self.ignore_enemy_count = 1;
				final_damage = 0;
			}
			else if(rand == 1)
			{
				IPrintLn("Train Go Boom AAT");
				radiusdamage( self.origin, 300, self.maxHealth * 1.2, self.maxHealth * 0.4, attacker, "MOD_GRENADE_SPLASH" );
				attacker playsound( "zmb_phdflop_explo" );
				fx = loadfx("explosions/fx_default_explosion");
				playfx( fx, self.origin );
			}
			else
			{
				IPrintLn("Thunder Wall AAT");
				self thread thunderwall_aat(attacker);
				final_damage = 0;
			}
		}
	}
	return int( final_damage );
}

chance_of_activation(meansofdeath)
{
	//if(is_double_tap_weapon(meansofdeath))
		//return RandomInt(20);
	return RandomInt(10);
}

thunderwall_aat( attacker )
{
	blast_pos = self.origin;
	attacker_facing_forward_dir = VectortoAngles( blast_pos - attacker.origin );
	attacker_facing = attacker GetWeaponForwardDir();
	attacker_angles = attacker.angles;
	zombies = get_array_of_closest( self.origin, GetAIArray( level.zombie_team ) );
	if(!isdefined(zombies))
		return;
	thunder_wall_range_sq = 180 * 180;
	thunder_wall_effect_sq = 180 * 180 * 9;
	end_pos = blast_pos + VectorScale(attacker_facing, 180);
	zombies_flung = 0;
	for( i=0; i<zombies.size; i++ )
	{
		if(!isdefined(zombies[i]) || !IsAlive(zombies[i]))
			continue;
		if(zombies[i] == self)
		{
			curr_zombie_origin = self.origin;
			curr_zombie_origin_sq = 0;
		}
		else
		{
			curr_zombie_origin = zombies[i].origin;
			curr_zombie_origin_sq = DistanceSquared( blast_pos, curr_zombie_origin );
		}

		if(curr_zombie_origin_sq < thunder_wall_range_sq)
		{
			zombies[i] DoDamage(zombies[i].maxHealth + 666, curr_zombie_origin, zombies[i] );
			attacker player_add_points("brain_rot_aat",50);
			attacker.kills++;
			random_x = RandomFloatRange( -3, 3 );
			random_y = RandomFloatRange( -3, 3 );
			zombies[i] StartRagdoll(true);
			zombies[i] LaunchRagdoll(200 * VectorNormalize(curr_zombie_origin - blast_pos + (random_x, random_y, 30)), "torso_lower");
			zombies_flung++;
		}

		if(zombies_flung >= 6)
		{
			break;
		}
	}
}

turned_timeout(player)
{
	self endon("death");
	wait 15;
	self DisableInvulnerability();
	self.magic_bullet_shield = false;
	self DoDamage(self.maxHealth, self.origin, self);
	player player_add_points("brain_rot_aat", 50);
}

turned_aat(player)
{
	self endon("death");
	while(1)
	{
		self notify( "stop_find_flesh" );
		zombies = get_array_of_closest( self.origin, GetAIArray( level.zombie_team ) );
		ArrayRemoveValue(zombies, self);
		if ( isDefined( zombies ) && zombies.size > 0 )
		{
			self.favoriteenemy = zombies[ 0 ];
			
			if ( distance( self.favoriteenemy.origin, self.origin ) < 64 )
			{
				self.favoriteenemy DoDamage( self.favoriteenemy.maxHealth + 666, self.favoriteenemy.origin, self );
				player player_add_points("brain_rot_aat", 50);
				wait .5;
			}
			else			
				self SetGoalPos( zombies[ 0 ].origin );
		}
		else
		{
			self.favoriteenemy = self;
		}
		wait .05;
	}
}

is_double_tap_weapon(meansofdeath)
{
	if(is_true(meansofdeath == "MOD_RIFLE_BULLET") || is_true(meansofdeath == "MOD_PISTOL_BULLET"))
		return 1;
	return 0;
}

salvageDrop(rare_salvage, origin, angles)
{
	level endon("end_game");
	salvage = Spawn("script_model", origin + (0,0,30));
	salvage SetModel("zombie_ammocan");
	salvage.angles = angles;
	salvage.scale = 0.5;
	salvage PhysicsLaunch();
	if(is_true(rare_salvage))
		fx = level._effect[ "powerup_on_solo" ];
	else
		fx = level._effect[ "powerup_on" ];
	PlayFXOnTag(fx, salvage, "tag_origin");
	time = 30;
	pickedup = 0;
	while(time > 0)
	{
		foreach(player in GetPlayers())
		{
			if(Distance(player.origin, salvage.origin) < 60)
			{
				if(is_true(rare_salvage))
					player.rare_salvage += 10;
				else
					player.salvage += 50;
				pickedup = 1;
				player PlaySound("zmb_buildable_piece_add");
				break;
			}
		}
		if(pickedup)
			break;
		time -= .1;
		wait .1;
	}
	salvage Delete();
}

weapon_give( weapon, is_upgrade, magic_box, nosound ) //checked changed to match cerberus output
{
	primaryweapons = self getweaponslistprimaries();
	current_weapon = self getcurrentweapon();
	current_weapon = self maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
	if ( !isDefined( is_upgrade ) )
	{
		is_upgrade = 0;
	}
	weapon_limit = get_player_weapon_limit( self );
	if ( is_equipment( weapon ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_give( weapon );
	}
	if ( weapon == "riotshield_zm" )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	if ( is_melee_weapon( weapon ) )
	{
		current_weapon = maps/mp/zombies/_zm_melee_weapon::change_melee_weapon( weapon, current_weapon );
	}
	else if ( is_lethal_grenade( weapon ) )
	{
		old_lethal = self get_player_lethal_grenade();
		if ( isDefined( old_lethal ) && old_lethal != "" )
		{
			self takeweapon( old_lethal );
			unacquire_weapon_toggle( old_lethal );
		}
		self set_player_lethal_grenade( weapon );
	}
	else if ( is_tactical_grenade( weapon ) )
	{
		old_tactical = self get_player_tactical_grenade();
		if ( isDefined( old_tactical ) && old_tactical != "" )
		{
			self takeweapon( old_tactical );
			unacquire_weapon_toggle( old_tactical );
		}
		self set_player_tactical_grenade( weapon );
	}
	else if ( is_placeable_mine( weapon ) )
	{
		old_mine = self get_player_placeable_mine();
		if ( isDefined( old_mine ) )
		{
			self takeweapon( old_mine );
			unacquire_weapon_toggle( old_mine );
		}
		self set_player_placeable_mine( weapon );
	}
	if ( !is_offhand_weapon( weapon ) )
	{
		self maps/mp/zombies/_zm_weapons::take_fallback_weapon();
	}
	if ( primaryweapons.size >= weapon_limit )
	{
		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}
		if ( isDefined( current_weapon ) )
		{
			if ( !is_offhand_weapon( weapon ) )
			{
				if(self has_weapon_or_upgrade(weapon))
				{
					if(self has_upgrade(weapon))
					{
						foreach(gun in primaryweapons)
						{
							if(level.zombie_weapons[gun].upgrade_name == get_base_name(weapon))
							{
								self thread drop_cw_weapon(gun, self.weaponTiers[get_base_name(gun)], self.weaponPapTiers[get_base_name(gun)], self GetWeaponAmmoClip(gun), self GetWeaponAmmoStock(gun));
								self TakeWeapon(gun);
							}
						}
					}
					else
					{
						foreach(gun in primaryweapons)
						{
							if(get_base_name(weapon) == get_base_name(gun))
							{
								self thread drop_cw_weapon(gun, self.weaponTiers[get_base_name(gun)], self.weaponPapTiers[get_base_name(gun)], self GetWeaponAmmoClip(gun), self GetWeaponAmmoStock(gun));
								self TakeWeapon(gun);
							}
						}
					}
				}
				else
				{
					if ( current_weapon == "tesla_gun_zm" )
					{
						level.player_drops_tesla_gun = 1;
					}
					if ( issubstr( current_weapon, "knife_ballistic_" ) )
					{
						self notify( "zmb_lost_knife" );
					}
					self thread drop_cw_weapon(current_weapon, self.weaponTiers[get_base_name(current_weapon)], self.weaponPapTiers[get_base_name(current_weapon)], self GetWeaponAmmoClip(current_weapon), self GetWeaponAmmoStock(current_weapon));
					self takeweapon( current_weapon );
					self.weaponTiers[get_base_name(current_weapon)] = undefined;
					self.weaponPapTiers[get_base_name(current_weapon)] = undefined;
					unacquire_weapon_toggle( current_weapon );
				}
			}
		}
	}
	else
	{
		if(self has_upgrade(weapon))
		{
			foreach(gun in primaryweapons)
			{
				if(level.zombie_weapons[gun].upgrade_name == get_base_name(weapon))
				{
					self thread drop_cw_weapon(gun, self.weaponTiers[get_base_name(gun)], self.weaponPapTiers[get_base_name(gun)], self GetWeaponAmmoClip(gun), self GetWeaponAmmoStock(gun));
					self TakeWeapon(gun);
				}
			}
		}
		else
		{
			foreach(gun in primaryweapons)
			{
				if(get_base_name(weapon) == get_base_name(gun))
				{
					self thread drop_cw_weapon(gun, self.weaponTiers[get_base_name(gun)], self.weaponPapTiers[get_base_name(gun)], self GetWeaponAmmoClip(gun), self GetWeaponAmmoStock(gun));
					self TakeWeapon(gun);
				}
			}
		}
	}
	if ( isDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if ( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
		{
			return;
		}
	}
	if ( weapon == "cymbal_monkey_zm" )
	{
		self maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
	{
		weapon = self maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	}
	else if ( weapon == "claymore_zm" )
	{
		self thread maps/mp/zombies/_zm_weap_claymore::claymore_setup();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( isDefined( level.zombie_weapons_callbacks ) && isDefined( level.zombie_weapons_callbacks[ weapon ] ) )
	{
		self thread [[ level.zombie_weapons_callbacks[ weapon ] ]]();
		play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( !is_true( nosound ) )
	{
		self play_sound_on_ent( "purchase" );
	}
	if ( weapon == "ray_gun_zm" )
	{
		playsoundatposition( "mus_raygun_stinger", ( 0, 0, 0 ) );
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		self giveweapon( weapon );
	}
	else
	{
		self giveweapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	}
	acquire_weapon_toggle( weapon, self );
	self GiveMaxAmmo( weapon );
	if ( !is_offhand_weapon( weapon ) )
	{
		if ( !is_melee_weapon( weapon ) )
		{
			if(!isdefined(self.weaponTiers[get_base_name(weapon)]))
			{
				self.weaponTiers[get_base_name(weapon)] = 1;
			}
			if(!isdefined(self.weaponPapTiers[get_base_name(weapon)]))
			{
				self.weaponPapTiers[get_base_name(weapon)] = 0;
			}
			self switchtoweapon( weapon );
		}
		else
		{
			self switchtoweapon( current_weapon );
		}
	}
	self play_weapon_vo( weapon, magic_box );
}

drop_cw_weapon(weapon, tier, papTier, clip, stock)
{
	cw_weapon = Spawn("script_model", self.origin + (0,0,55));
	cw_weapon SetModel(GetWeaponModel(weapon));
	cw_weapon fake_physicslaunch(self.origin + (0,0,15), 100);
	wait .5;
	if(tier == 0)
		fx = "";
	else if(tier == 1)
		fx = level._effect[ "powerup_on" ];
	else if(tier == 2)
		fx = level._effect[ "powerup_on_solo" ];
	else if(tier == 3)
		fx = level._effect[ "monkey_glow" ];
	else if(tier == 4)
		fx = level._effect[ "powerup_on_caution" ];
	else if(tier == 5)
		fx = level._effect[ "powerup_on_caution" ];
	PlayFXOnTag(fx, cw_weapon, "tag_origin");
	wait .5;
	time = 15;
	while(time > 0)
	{
		players = get_players();
		for(i=0;i<players.size;i++)
		{
			if(players[i] UseButtonPressed() && Distance(players[i].origin, cw_weapon.origin) < 60 && players[i] is_player_looking_at(cw_weapon.origin,0.96, 0, undefined) && players[i].team != level.zombie_team && players[i] can_buy_weapon())
			{
				players[i] weapon_give(weapon, 0, 0, 1);
				players[i].weaponTiers[get_base_name(weapon)] = tier;
				players[i].weaponPapTiers[get_base_name(weapon)] = papTier;
				players[i] SetWeaponAmmoClip(weapon, clip);
				players[i] SetWeaponAmmoStock(weapon,stock);
				players[i] PlaySound("zmb_buildable_piece_add");
				time = 0;
			}
		}
		wait .05;
		time -= .05;
	}
	cw_weapon Delete();
}

vending_weapon_upgrade() //checked matches cerberus output
{
	level endon( "Pack_A_Punch_off" );
	wait 0.01;
	perk_machine = getent( self.target, "targetname" );
	self.perk_machine = perk_machine;
	perk_machine_sound = getentarray( "perksacola", "targetname" );
	packa_rollers = spawn( "script_origin", self.origin );
	packa_timer = spawn( "script_origin", self.origin );
	packa_rollers linkto( self );
	packa_timer linkto( self );
	if ( isDefined( perk_machine.target ) )
	{
		perk_machine.wait_flag = getent( perk_machine.target, "targetname" );
	}
	pap_is_buildable = self is_buildable();
	if ( pap_is_buildable )
	{
		self trigger_off();
		perk_machine hide();
		if ( isDefined( perk_machine.wait_flag ) )
		{
			perk_machine.wait_flag hide();
		}
		wait_for_buildable( "pap" );
		self trigger_on();
		perk_machine show();
		if ( isDefined( perk_machine.wait_flag ) )
		{
			perk_machine.wait_flag show();
		}
	}
	self usetriggerrequirelookat();
	self sethintstring( &"ZOMBIE_NEED_POWER" );
	self setcursorhint( "HINT_NOICON" );
	power_off = !self maps/mp/zombies/_zm_power::pap_is_on();
	if ( power_off )
	{
		pap_array = [];
		pap_array[ 0 ] = perk_machine;
		level thread do_initial_power_off_callback( pap_array, "packapunch" );
		level waittill( "Pack_A_Punch_on" );
	}
	self enable_trigger();
	if ( isDefined( level.machine_assets[ "packapunch" ].power_on_callback ) )
	{
		perk_machine thread [[ level.machine_assets[ "packapunch" ].power_on_callback ]]();
	}
	self thread vending_machine_trigger_think();
	perk_machine playloopsound( "zmb_perks_packa_loop" );
	self thread shutoffpapsounds( perk_machine, packa_rollers, packa_timer );
	self thread vending_weapon_upgrade_cost();
	for ( ;; )
	{
		self.pack_player = undefined;
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		current_weapon = player getcurrentweapon();
		current_weapon = player maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
		if ( isDefined( level.custom_pap_validation ) )
		{
			valid = self [[ level.custom_pap_validation ]]( player );
			if ( !valid )
			{
				continue;
			}
		}
		if ( player maps/mp/zombies/_zm_magicbox::can_buy_weapon() && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !is_true( player.intermission ) || player isthrowinggrenade() && !player maps/mp/zombies/_zm_weapons::can_upgrade_weapon( current_weapon ) )
		{
			wait 0.1;
			continue;
		}
		if ( is_true( level.pap_moving ) )
		{
			continue;
		}
		if ( player isswitchingweapons() )
		{
			wait 0.1;
			if ( player isswitchingweapons() )
			{
				continue;
			}
		}
		if ( !maps/mp/zombies/_zm_weapons::is_weapon_or_base_included( current_weapon ) )
		{
			continue;
		}
		
		current_cost = self.cost;
		if(isdefined(player.weaponPapTiers[get_base_name(current_weapon)]))
		{
			if(player.weaponPapTiers[get_base_name(current_weapon)] == 1)
			{
				current_cost = current_cost * 3;
			}
			else if(player.weaponPapTiers[get_base_name(current_weapon)] == 2)
			{
				current_cost = current_cost * 6;
			}
		}
		player.restore_ammo = undefined;
		player.restore_clip = undefined;
		player.restore_stock = undefined;
		player.restore_clip_size = undefined;
		player.restore_max = undefined;
		upgrade_as_attachment = will_upgrade_weapon_as_attachment( current_weapon );
		if ( upgrade_as_attachment )
		{
			player.restore_ammo = 1;
			player.restore_clip = player getweaponammoclip( current_weapon );
			player.restore_clip_size = weaponclipsize( current_weapon );
			player.restore_stock = player getweaponammostock( current_weapon );
			player.restore_max = weaponmaxammo( current_weapon );
		}
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			current_cost = player maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );
		}
		if ( player.score < current_cost ) 
		{
			self playsound( "deny" );
			if ( isDefined( level.custom_pap_deny_vo_func ) )
			{
				player [[ level.custom_pap_deny_vo_func ]]();
			}
			else
			{
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			}
			continue;
		}
		self.pack_player = player;
		flag_set( "pack_machine_in_use" );
		maps/mp/_demo::bookmark( "zm_player_use_packapunch", getTime(), player );
		player maps/mp/zombies/_zm_stats::increment_client_stat( "use_pap" );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "use_pap" );
		self thread destroy_weapon_in_blackout( player );
		self thread destroy_weapon_on_disconnect( player );
		player maps/mp/zombies/_zm_score::minus_to_player_score( current_cost, 1 );
		sound = "evt_bottle_dispense";
		playsoundatposition( sound, self.origin );
		self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( "mus_perks_packa_sting" );
		player maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", "upgrade_wait" );
		self disable_trigger();
		if ( !is_true( upgrade_as_attachment ) )
		{
			player thread do_player_general_vox( "general", "pap_wait", 10, 100 );
		}
		else
		{
			player thread do_player_general_vox( "general", "pap_wait2", 10, 100 );
		}
		player TakeWeapon(current_weapon);
		self playsound( "zmb_perks_packa_upgrade" );
		self.current_weapon = current_weapon;
		if(player.weaponPapTiers[get_base_name(current_weapon)] == 0)
			upgrade_name = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( current_weapon, upgrade_as_attachment );
		else
			upgrade_name = current_weapon;
		if(get_base_name(current_weapon) != get_base_name(upgrade_name))
		{
			player.weaponTiers[get_base_name(upgrade_name)] = player.weaponTiers[get_base_name(current_weapon)];
			player.weaponTiers[get_base_name(current_weapon)] = undefined;
			player.weaponPapTiers[get_base_name(upgrade_name)] = player.weaponPapTiers[get_base_name(current_weapon)];
			player.weaponPapTiers[get_base_name(current_weapon)] = undefined;
		}
		self.current_weapon = current_weapon;
		self.upgrade_name = upgrade_name;
		self enable_trigger();
		if ( isDefined( player ) )
		{
			self setinvisibletoall();
			self setvisibletoplayer( player );
			self wait_for_player_to_take( player, current_weapon, packa_timer, upgrade_as_attachment );
		}
		self.current_weapon = "";
		if ( isDefined( self.worldgun ) && isDefined( self.worldgun.worldgundw ) )
		{
			self.worldgun.worldgundw delete();
		}
		if ( isDefined( self.worldgun ) )
		{
			self.worldgun delete();
		}
		if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
		{
			self sethintstring( "Hold ^3&&1^7 to Pack a Punch [5000, 15000, 30000]" );
		}
		else
		{
			self sethintstring( "Hold ^3&&1^7 to Pack a Punch [5000, 15000, 30000]" );
		}
		self setvisibletoall();
		self.pack_player = undefined;
		flag_clear( "pack_machine_in_use" );	
	}
}

wait_for_player_to_take( player, weapon, packa_timer, upgrade_as_attachment ) //changed 3/30/20 4:22 pm //checked matches cerberus output
{
	current_weapon = self.current_weapon;
	upgrade_name = self.upgrade_name;

	upgrade_weapon = upgrade_name;
	self endon( "pap_timeout" );
	level endon( "Pack_A_Punch_off" );
	trigger_player = player;

	packa_timer stoploopsound( 0.05 );
	if ( trigger_player == player ) //working
	{
		player maps/mp/zombies/_zm_stats::increment_client_stat( "pap_weapon_grabbed" );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "pap_weapon_grabbed" );
		current_weapon = player getcurrentweapon();

		maps/mp/_demo::bookmark( "zm_player_grabbed_packapunch", getTime(), player );
		self notify( "pap_taken" );
		player notify( "pap_taken" );
		player.pap_used = 1;
		if ( !is_true( upgrade_as_attachment ) )
		{
			player thread do_player_general_vox( "general", "pap_arm", 15, 100 );
		}
		else
		{
			player thread do_player_general_vox( "general", "pap_arm2", 15, 100 );
		}
		weapon_limit = get_player_weapon_limit( player );
		player maps/mp/zombies/_zm_weapons::take_fallback_weapon();
		primaries = player getweaponslistprimaries();
		if(!isdefined(player.weaponPapTiers[get_base_name(upgrade_weapon)]))
			player.weaponPapTiers[get_base_name(upgrade_weapon)] = 0;
		if ( isDefined( primaries ) && primaries.size >= weapon_limit )
		{
			player maps/mp/zombies/_zm_weapons::weapon_give( upgrade_weapon );
			player.weaponPapTiers[get_base_name(upgrade_weapon)]++;
		}
		else
		{
			player giveweapon( upgrade_weapon, 0, player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
			player givestartammo( upgrade_weapon );
			player.weaponPapTiers[get_base_name(upgrade_weapon)]++;
		}
		player switchtoweapon( upgrade_weapon );
		if ( is_true( player.restore_ammo ) )
		{
			new_clip = player.restore_clip + ( weaponclipsize( upgrade_weapon ) - player.restore_clip_size );
			new_stock = player.restore_stock + ( weaponmaxammo( upgrade_weapon ) - player.restore_max );
			player setweaponammostock( upgrade_weapon, new_stock );
			player setweaponammoclip( upgrade_weapon, new_clip );
		}
		player.restore_ammo = undefined;
		player.restore_clip = undefined;
		player.restore_stock = undefined;
		player.restore_max = undefined;
		player.restore_clip_size = undefined;
		player maps/mp/zombies/_zm_weapons::play_weapon_vo( upgrade_weapon );
	}
}

vending_weapon_upgrade_cost() //checked 3/30/20 4:19 pm //checked matches cerberus output
{
	level endon( "Pack_A_Punch_off" );
	while ( 1 )
	{
		self.cost = 5000;
		self.attachment_cost = 2000;
		if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
		{
			self sethintstring( "Hold ^3&&1^7 to Pack a Punch [5000, 15000, 30000]" );
		}
		else
		{
			self sethintstring( "Hold ^3&&1^7 to Pack a Punch [5000, 15000, 30000]" );
		}
		level waittill( "powerup bonfire sale" );
		self.cost = 1000;
		self.attachment_cost = 1000;
		if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
		{
			self sethintstring( "Hold ^3&&1^7 to Pack a Punch [1000, 3000, 6000]" );
		}
		else
		{
			self sethintstring( "Hold ^3&&1^7 to Pack a Punch [1000, 3000, 6000]" );
		}
		level waittill( "bonfire_sale_off" );
	}
}

third_person_weapon_upgrade( current_weapon, upgrade_weapon, packa_rollers, perk_machine, trigger ) //checked matches cerberus output
{
	level endon( "Pack_A_Punch_off" );
	trigger endon( "pap_player_disconnected" );
	rel_entity = trigger.perk_machine;
	origin_offset = ( 0, 0, 0 );
	angles_offset = ( 0, 0, 0 );
	origin_base = self.origin;
	angles_base = self.angles;
	if ( isDefined( rel_entity ) )
	{
		if ( isDefined( level.pap_interaction_height ) )
		{
			origin_offset = ( 0, 0, level.pap_interaction_height );
		}
		else
		{
			origin_offset = vectorScale( ( 0, 0, 1 ), 35 );
		}
		angles_offset = vectorScale( ( 0, 1, 0 ), 90 );
		origin_base = rel_entity.origin;
		angles_base = rel_entity.angles;
	}
	else
	{
		rel_entity = self;
	}
	forward = anglesToForward( angles_base + angles_offset );
	interact_offset = origin_offset + ( forward * -25 );
	if ( !isDefined( perk_machine.fx_ent ) )
	{
		perk_machine.fx_ent = spawn( "script_model", origin_base + origin_offset + ( 0, 1, -34 ) );
		perk_machine.fx_ent.angles = angles_base + angles_offset;
		perk_machine.fx_ent setmodel( "tag_origin" );
		perk_machine.fx_ent linkto( perk_machine );
	}
	if ( isDefined( level._effect[ "packapunch_fx" ] ) )
	{
		fx = playfxontag( level._effect[ "packapunch_fx" ], perk_machine.fx_ent, "tag_origin" );
	}
	offsetdw = vectorScale( ( 1, 1, 1 ), 3 );
	weoptions = self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( current_weapon );
	trigger.worldgun = spawn_weapon_model( current_weapon, undefined, origin_base + interact_offset, self.angles, weoptions );
	worldgundw = undefined;
	if ( maps/mp/zombies/_zm_magicbox::weapon_is_dual_wield( current_weapon ) )
	{
		worldgundw = spawn_weapon_model( current_weapon, maps/mp/zombies/_zm_magicbox::get_left_hand_weapon_model_name( current_weapon ), origin_base + interact_offset + offsetdw, self.angles, weoptions );
	}
	trigger.worldgun.worldgundw = worldgundw;
	if ( isDefined( level.custom_pap_move_in ) )
	{
		perk_machine [[ level.custom_pap_move_in ]]( trigger, origin_offset, angles_offset, perk_machine );
	}
	else
	{
		perk_machine pap_weapon_move_in( trigger, origin_offset, angles_offset );
	}
	self playsound( "zmb_perks_packa_upgrade" );
	if ( isDefined( perk_machine.wait_flag ) )
	{
		perk_machine.wait_flag rotateto( perk_machine.wait_flag.angles + vectorScale( ( 1, 0, 0 ), 179 ), 0.25, 0, 0 );
	}
	wait 0.35;
	trigger.worldgun delete();
	if ( isDefined( worldgundw ) )
	{
		worldgundw delete();
	}
	wait 3;
	if ( isDefined( self ) )
	{
		self playsound( "zmb_perks_packa_ready" );
	}
	else
	{
		return;
	}
	if(get_base_name(current_weapon) != get_base_name(upgrade_weapon))
	{
		self.weaponTiers[get_base_name(upgrade_weapon)] = self.weaponTiers[get_base_name(current_weapon)];
		self.weaponTiers[get_base_name(current_weapon)] = undefined;
		self.weaponPapTiers[get_base_name(upgrade_weapon)] = self.weaponPapTiers[get_base_name(current_weapon)];
		self.weaponPapTiers[get_base_name(current_weapon)] = undefined;
	}
	upoptions = self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon );
	trigger.current_weapon = current_weapon;
	trigger.upgrade_name = upgrade_weapon;
	trigger.worldgun = spawn_weapon_model( upgrade_weapon, undefined, origin_base + origin_offset, angles_base + angles_offset + vectorScale( ( 0, 1, 0 ), 90 ), upoptions );
	worldgundw = undefined;
	if ( maps/mp/zombies/_zm_magicbox::weapon_is_dual_wield( upgrade_weapon ) )
	{
		worldgundw = spawn_weapon_model( upgrade_weapon, maps/mp/zombies/_zm_magicbox::get_left_hand_weapon_model_name( upgrade_weapon ), origin_base + origin_offset + offsetdw, angles_base + angles_offset + vectorScale( ( 0, -1, 0 ), 90 ), upoptions );
	}
	trigger.worldgun.worldgundw = worldgundw;
	if ( isDefined( perk_machine.wait_flag ) )
	{
		perk_machine.wait_flag rotateto( perk_machine.wait_flag.angles - vectorScale( ( 1, 0, 0 ), 179 ), 0.25, 0, 0 );
	}
	if ( isDefined( level.custom_pap_move_out ) )
	{
		rel_entity thread [[ level.custom_pap_move_out ]]( trigger, origin_offset, interact_offset );
	}
	else
	{
		rel_entity thread pap_weapon_move_out( trigger, origin_offset, interact_offset );
	}
	return trigger.worldgun;
}

perk_init() //checked partially changed to match cerberus output
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
		array_thread( vending_weapon_upgrade_trigger, ::vending_weapon_upgrade );
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
	array_thread( vending_triggers, ::vending_trigger_think );
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

can_upgrade_weapon( weaponname ) //checked changed to match cerberus output
{
	if ( !isDefined( weaponname ) || weaponname == "" || weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	if ( !is_weapon_upgraded( weaponname ) && isDefined( level.zombie_weapons[ weaponname ].upgrade_name ) )
	{
		return 1;
	}
	if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
	{
		if(is_true(self.weaponTiers[weaponname] < 5) || weaponname == "ray_gun_upgraded_zm" || weaponname == "raygun_mark2_upgraded_zm")
		{
			if(self.weaponPapTiers[weaponname] < 3)
			{
				return 1;
			}
		}
	}
	return 0;
}

ai_zombie_health( round_number ) //checked changed to match cerberus output
{
	zombie_health = level.zombie_vars[ "zombie_health_start" ];
	i = 2;
	while ( i <= round_number )
	{
		if( i < 12 )
			zombie_health = int( zombie_health + 60 );
		else if ( i < 17 )
			zombie_health = int( zombie_health + 100 );
		else if(i < 22)
			zombie_health = int( zombie_health + 300 );
		else if(i < 27)
			zombie_health = int( zombie_health + 750 );
		else if(i < 32)
			zombie_health = int( zombie_health + 1400 );
		else if(i < 37)
			zombie_health = int( zombie_health + 1750 );
		else if(i < 55)
			zombie_health = int( zombie_health + 2000 );
		else
			return 60000;
		i++;
	}
	if(zombie_health > 60000)
		zombie_health = 60000;
	return zombie_health;
}

ai_calculate_health( round_number ) //checked changed to match cerberus output
{
	level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
	i = 2;
	while ( i <= round_number )
	{
		if( i < 12 )
			level.zombie_health = int( level.zombie_health + 60 );
		else if ( i < 17 )
			level.zombie_health = int( level.zombie_health + 100 );
		else if(i < 22)
			level.zombie_health = int( level.zombie_health + 300 );
		else if(i < 27)
			level.zombie_health = int( level.zombie_health + 750 );
		else if(i < 32)
			level.zombie_health = int( level.zombie_health + 1400 );
		else if(i < 37)
			level.zombie_health = int( level.zombie_health + 1750 );
		else if(i < 55)
			level.zombie_health = int( level.zombie_health + 2000 );
		else
			return 60000;
		i++;
	}
	if(level.zombie_health > 60000)
		level.zombie_health = 60000;
}

freeSalvage()
{
	base_round = 11;
	while(1)
	{
		level waittill("end_of_round");
		round = level.round_number;
		if(round < base_round)
			continue;
		addedSalvage = 0;
		addedRareSalvage = 0;
		round_difference = round - base_round;
		if((round_difference % 5) == 0)
		{
			addedSalvage = 100 + (20 * round_difference);
			addedRareSalvage = 100 + (10*round_difference);
			if(addedSalvage > 500)
				addedSalvage = 500;
			if(addedRareSalvage > 250)
				addedRareSalvage = 250;
			foreach(player in GetPlayers())
			{
				player.salvage += addedSalvage;
				player.rare_salvage += addedRareSalvage;
			}
		}
	}
}

player_add_points( event, mod, hit_location, is_dog, zombie_team, damage_weapon ) //checked changed to match cerberus output
{
	if ( level.intermission )
	{
		return;
	}
	if ( !is_player_valid( self ) )
	{
		return;
	}
	player_points = 0;
	team_points = 0;
	multiplier = get_points_multiplier( self );
	switch( event )
	{
		case "death":
			player_points = 90;
			team_points = get_zombie_death_team_points();
			points = self player_add_points_kill_bonus( mod, hit_location );
			if ( level.zombie_vars[ self.team ][ "zombie_powerup_insta_kill_on" ] == 1 && mod == "MOD_UNKNOWN" )
			{
				points *= 2;
			}
			player_points += points;
			if ( team_points > 0 )
			{
				team_points += points;
			}
			if ( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "grenade_kills" );
				self maps/mp/zombies/_zm_stats::increment_player_stat( "grenade_kills" );
			}
			break;
		case "ballistic_knife_death":
			player_points = 115;
			break;
		case "damage_light":
			player_points = 0;
			break;
		case "damage":
			player_points = 0;
			break;
		case "damage_ads":
			player_points = 0;
			break;
		case "carpenter_powerup":
		case "rebuild_board":
			player_points = mod;
			break;
		case "bonus_points_powerup":
			player_points = mod;
			break;
		case "nuke_powerup":
			player_points = mod;
			team_points = mod;
			break;
		case "jetgun_fling":
		case "riotshield_fling":
		case "thundergun_fling":
			player_points = mod;
			break;
		case "hacker_transfer":
			player_points = mod;
			break;
		case "reviver":
			player_points = mod;
			break;
		case "vulture":
			player_points = mod;
			break;
		case "build_wallbuy":
			player_points = mod;
			break;
		case "brain_rot_aat":
			player_points = mod;
			break;
		default:
		/*
/#
			assert( 0, "Unknown point event" );
#/
		*/
			break;
	}
	player_points = multiplier * round_up_score( player_points, 5 );
	team_points = multiplier * round_up_score( team_points, 5 );
	if ( isDefined( self.point_split_receiver ) && event == "death" || isDefined( self.point_split_receiver ) && event == "ballistic_knife_death" )
	{
		split_player_points = player_points - round_up_score( player_points * self.point_split_keep_percent, 10 );
		self.point_split_receiver add_to_player_score( split_player_points );
		player_points -= split_player_points;
	}
	if ( is_true( level.pers_upgrade_pistol_points ) )
	{
		player_points = self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_pistol_points_set_score( player_points, event, mod, damage_weapon );
	}
	self add_to_player_score( player_points );
	self.pers[ "score" ] = self.score;
	if ( isDefined( level._game_module_point_adjustment ) )
	{
		level [[ level._game_module_point_adjustment ]]( self, zombie_team, player_points );
	}
}

player_add_points_kill_bonus( mod, hit_location ) //checked matches cerberus output
{
	if ( mod == "MOD_MELEE" )
	{
		return 25;
	}
	if ( mod == "MOD_BURNED" )
	{
		return 10;
	}
	score = 0;
	if ( isDefined( hit_location ) )
	{
		switch( hit_location )
		{
			case "head":
			case "helmet":
				score = 25;
				break;
			case "neck":
				score = 10;
				break;
			case "torso_lower":
			case "torso_upper":
				score = 0;
				break;
			default:
				break;
		}
	}
	return score;
}

spawnAmmoStations(origin, angles)
{
	crate = spawn("script_model", origin + (0,0,40));
	crate SetModel("zombie_ammocan");
	crate.angles = angles + (0,90,0);
	PlayFXOnTag(level._effect["powerup_on_solo"], crate, "tag_origin");
	crate.unitrigger_stub = spawnstruct();
	crate.unitrigger_stub.origin = crate.origin - (0,0,20);
	crate.unitrigger_stub.angles = angles;
	crate.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	crate.unitrigger_stub.cursor_hint = "HINT_NOICON";
	crate.unitrigger_stub.require_look_at = 0;
	crate.unitrigger_stub.script_width = 50;
	crate.unitrigger_stub.script_height = 50;
	crate.unitrigger_stub.script_length = 100;
	crate.unitrigger_stub.trigger_target = crate;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( crate.unitrigger_stub, 1 );
	crate.unitrigger_stub.prompt_and_visibility_func = ::crate_update_prompt;
	thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( crate.unitrigger_stub, ::crate_unitrigger_think );
}

crate_update_prompt(player)
{
	current_weapon = player GetCurrentWeapon();
	self.cost = 10000;
	if(is_true(player.weaponTiers[get_base_name( current_weapon )] < 5))
	{
		if(player.weaponPapTiers[get_base_name( current_weapon )] == 0)
		{
			self.cost = 250;
		}
		else if(player.weaponPapTiers[get_base_name( current_weapon )] == 1)
		{
			self.cost = 1000;
		}
		else if(player.weaponPapTiers[get_base_name( current_weapon )] == 2)
		{
			self.cost = 2500;
		}
		else if(player.weaponPapTiers[get_base_name( current_weapon )] == 3)
		{
			self.cost = 5000;
		}
	}
	self SetHintString("Hold ^3&&1^7 for Ammo [Cost: " + self.cost + "]");
}

crate_unitrigger_think()
{
	self endon("kill_trigger");
	self thread playerSwap();
	while(1)
	{
		self waittill("trigger", player);
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
		if ( player has_powerup_weapon() )
		{
			wait 0.1;
			continue;
		}
		current_weapon = player GetCurrentWeapon();
		if(player.score < self.cost)
		{
			play_sound_on_ent( "no_purchase" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
		}
		else
		{
			player SetWeaponAmmoClip(current_weapon, weaponclipsize(current_weapon));
			player GiveMaxAmmo(current_weapon);
			player maps/mp/zombies/_zm_score::minus_to_player_score( self.cost, 1 );
		}
		wait 1;
	}
}
playerSwap()
{
	self endon("kill_trigger");
	while(1)
	{
		self.parent_player waittill("weapon_change_complete");
		self [[ self.stub.prompt_and_visibility_func ]]( self.parent_player );
	}
}

spawnSalvageStations(origin, angles)
{
	table = spawn("script_model", origin);
	if(level.script == "zm_nuked")
	{
		table SetModel("p6_zm_nuked_table_end_wood");
		PlayFXOnTag(level._effect["powerup_on_caution"], table, "tag_origin");
	}
	else
	{
		table SetModel("p6_zm_work_bench");
	}
	table.angles = angles;
	table.unitrigger_stub = spawnstruct();
	table.unitrigger_stub.origin = table.origin + (0,0,20);
	table.unitrigger_stub.angles = table.angles;
	table.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	table.unitrigger_stub.cursor_hint = "HINT_NOICON";
	table.unitrigger_stub.require_look_at = 1;
	table.unitrigger_stub.script_width = 50;
	table.unitrigger_stub.script_height = 50;
	table.unitrigger_stub.script_length = 100;
	table.unitrigger_stub.trigger_target = table;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( table.unitrigger_stub, 1 );
	table.unitrigger_stub.prompt_and_visibility_func = ::table_update_prompt;
	thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( table.unitrigger_stub, ::table_unitrigger_think );
}

table_unitrigger_think()
{
	self endon( "kill_trigger" );
	self thread playerSwap();
	while(1)
	{
		self waittill("trigger", player);
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
		if ( player has_powerup_weapon() )
		{
			wait 0.1;
			continue;
		}
		current_weapon = player GetCurrentWeapon();
		if(player.weaponTiers[get_base_name( current_weapon )] >= 4)
			continue;
		if(player.weaponTiers[get_base_name( current_weapon )] == 0 && player.salvage >= 500)
		{
			player.salvage -= 500;
		}
		else if(player.weaponTiers[get_base_name( current_weapon )] == 1 && player.salvage >= 1000)
		{
			player.salvage -= 1000;
		}
		else if(player.weaponTiers[get_base_name( current_weapon )] == 2 && player.rare_salvage >= 500)
		{
			player.rare_salvage -= 500;
		}
		else if(player.weaponTiers[get_base_name( current_weapon )] == 3 && player.rare_salvage >= 1000)
		{
			player.rare_salvage -= 1000;
		}
		else
		{
			wait 0.1;
			continue;
		}
		player TakeWeapon(current_weapon);
		player weapon_give(current_weapon);
		player.weaponTiers[get_base_name( current_weapon )]++;
		self [[ self.stub.prompt_and_visibility_func ]]( player, current_weapon );
		wait 1;
	}
}

table_update_prompt(player, current_weapon)
{
	if(!isdefined(current_weapon))
		current_weapon = player GetCurrentWeapon();
	if(player.weaponTiers[get_base_name( current_weapon )] == 0)
	{
		self SetHintString("Hold ^3&&1^7 to Upgrade [500 Salvage] (You have " + player.salvage + ")");
	}
	else if(player.weaponTiers[get_base_name( current_weapon )] == 1)
	{
		self SetHintString("Hold ^3&&1^7 to Upgrade [1000 Salvage] (You have " + player.salvage + ")");
	}
	else if(player.weaponTiers[get_base_name( current_weapon )] == 2)
	{
		self SetHintString("Hold ^3&&1^7 to Upgrade [500 High-Grade Salvage] (You have " + player.rare_salvage + ")");
	}
	else if(player.weaponTiers[get_base_name( current_weapon )] == 3)
	{
		self SetHintString("Hold ^3&&1^7 to Upgrade [1000 High-Grade Salvage] (You have " + player.rare_salvage + ")");
	}
	else
	{
		self SetHintString("");
	}
}
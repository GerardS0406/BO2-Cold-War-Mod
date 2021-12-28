#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_afterlife;
#include maps/mp/zombies/_zm_clone;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;

main()
{
	replacefunc(maps/mp/zombies/_zm_afterlife::afterlife_spawn_corpse, ::afterlife_spawn_corpse);
	replacefunc(maps/mp/zombies/_zm_afterlife::afterlife_revive_do_revive, ::afterlife_revive_do_revive);
	replacefunc(maps/mp/zombies/_zm_afterlife::afterlife_laststand_cleanup, ::afterlife_laststand_cleanup);
	replacefunc(maps/mp/zombies/_zm_afterlife::afterlife_mana_watch, ::afterlife_mana_watch);
	level.afterlife_player_damage_override = ::afterlife_player_damage_callback_override;
}

init()
{
	level.afterlife_save_loadout = ::afterlife_save_loadout;
	level.afterlife_give_loadout = ::afterlife_give_loadout;
}

afterlife_mana_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	self.manabar = NewClientHudElem(self);
	self.manabar.x = 0;
	self.manabar.y = 0;
	self.manabar SetShader( "progress_bar_fill", level.primaryprogressbarwidth, level.primaryprogressbarheight_ss );
	self.manabar.width = level.primaryprogressbarwidth;
	self.manabar.height = level.primaryprogressbarheight_ss;
	self.manabar.alignx = "center";
	self.manabar.aligny = "middle";
	self.manabar.horzalign = "center";
	self.manabar.vertalign = "bottom";
	self.manabar.color = (0.5,0.5,1);
	while ( self.manacur > 0 )
	{
		wait 0.05;
		self afterlife_reduce_mana( 0.05 * self.afterlifedeaths * 3 );
		if ( self.manacur < 0 )
		{
			self.manacur = 0;
		}
		barwidth = int( ( self.manabar.width * (self.manacur / 200) ) + 0.5 );
		self.manabar SetShader("progress_bar_fill", barwidth, self.manabar.height);
		n_mapped_mana = linear_map( self.manacur, 0, 200, 0, 1 );
		self setclientfieldtoplayer( "player_afterlife_mana", n_mapped_mana );
	}
	self.manabar Destroy();
	if ( isDefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
		{
			wait 0.05;
		}
	}
	corpse notify( "stop_revive_trigger" );
	self thread fadetoblackforxsec( 0, 0.5, 0.5, 0.5, "black" );
	wait 0.5;
	self notify( "out_of_mana" );
	self afterlife_leave( 0 );
}

afterlife_save_loadout()
{
	self.loadout = spawnstruct();
	self.loadout.player = self;
	self.loadout.weapons = [];
	self.loadout.score = self.score;
	self.loadout.current_weapon = 0;
	self.loadout.perks = afterlife_save_perks( self );
	primaries = self getweaponslistprimaries();
	currentweapon = self getcurrentweapon();
	_a1516 = primaries;
	index = getFirstArrayKey( _a1516 );
	while ( isDefined( index ) )
	{
		weapon = _a1516[ index ];
		self.loadout.weapons[ index ] = weapon;
		self.loadout.stockcount[ index ] = self getweaponammostock( weapon );
		self.loadout.clipcount[ index ] = self getweaponammoclip( weapon );
		if ( weaponisdualwield( weapon ) )
		{
			weapon_dw = weapondualwieldweaponname( weapon );
			self.loadout.clipcount2[ index ] = self getweaponammoclip( weapon_dw );
		}
		weapon_alt = weaponaltweaponname( weapon );
		if ( weapon_alt != "none" )
		{
			self.loadout.stockcountalt[ index ] = self getweaponammostock( weapon_alt );
			self.loadout.clipcountalt[ index ] = self getweaponammoclip( weapon_alt );
		}
		if ( weapon == currentweapon )
		{
			self.loadout.current_weapon = index;
		}
		index = getNextArrayKey( _a1516, index );
	}
	self.loadout.equipment = self get_player_equipment();
	if ( isDefined( self.loadout.equipment ) )
	{
		self equipment_take( self.loadout.equipment );
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.loadout.hasclaymore = 1;
		self.loadout.claymoreclip = self getweaponammoclip( "claymore_zm" );
	}
	if ( self hasweapon( "emp_grenade_zm" ) )
	{
		self.loadout.hasemp = 1;
		self.loadout.empclip = self getweaponammoclip( "emp_grenade_zm" );
	}
	if ( self hasweapon( "bouncing_tomahawk_zm" ) || self hasweapon( "upgraded_tomahawk_zm" ) )
	{
		self.loadout.hastomahawk = 1;
		self setclientfieldtoplayer( "tomahawk_in_use", 0 );
	}
	lethal_grenade = self get_player_lethal_grenade();
	if ( self hasweapon( lethal_grenade ) )
	{
		self.loadout.grenade = self getweaponammoclip( lethal_grenade );
	}
	else
	{
		self.loadout.grenade = 0;
	}
	self.loadout.lethal_grenade = lethal_grenade;
	self set_player_lethal_grenade( undefined );
}

afterlife_save_perks( ent )
{
	if ( ent hasperk( "specialty_additionalprimaryweapon" ) )
	{
		weapon_to_take = ent scripts/zm/cw_mule_kick_retained::take_additionalprimaryweapon();
		ent TakeWeapon(weapon_to_take);
	}
	perk_array = [];
	foreach(perk in ent.perks_active)
	{
		ent notify(perk + "_stop");
		perk_array[ perk_array.size ] = perk;
	}
	return perk_array;
}

afterlife_laststand_cleanup( corpse )
{
	self afterlife_give_loadout();
	self afterlife_corpse_cleanup( corpse );
}

afterlife_give_loadout()
{
	self takeallweapons();
	primaries = self getweaponslistprimaries();
	if ( self.loadout.weapons.size > 1 || primaries.size > 1 )
	{
		_a1601 = primaries;
		_k1601 = getFirstArrayKey( _a1601 );
		while ( isDefined( _k1601 ) )
		{
			weapon = _a1601[ _k1601 ];
			self takeweapon( weapon );
			_k1601 = getNextArrayKey( _a1601, _k1601 );
		}
	}
	i = 0;
	while ( i < self.loadout.weapons.size )
	{
		if ( !isDefined( self.loadout.weapons[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( self.loadout.weapons[ i ] == "none" )
		{
			i++;
			continue;
		}
		else
		{
			weapon = self.loadout.weapons[ i ];
			stock_amount = self.loadout.stockcount[ i ];
			clip_amount = self.loadout.clipcount[ i ];
			if ( !self hasweapon( weapon ) )
			{
				self giveweapon( weapon, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
				self setweaponammostock( weapon, stock_amount );
				self setweaponammoclip( weapon, clip_amount );
				if ( weaponisdualwield( weapon ) )
				{
					weapon_dw = weapondualwieldweaponname( weapon );
					self setweaponammoclip( weapon_dw, self.loadout.clipcount2[ i ] );
				}
				weapon_alt = weaponaltweaponname( weapon );
				if ( weapon_alt != "none" )
				{
					self setweaponammostock( weapon_alt, self.loadout.stockcountalt[ i ] );
					self setweaponammoclip( weapon_alt, self.loadout.clipcountalt[ i ] );
				}
			}
		}
		i++;
	}
	self setspawnweapon( self.loadout.weapons[ self.loadout.current_weapon ] );
	self switchtoweaponimmediate( self.loadout.weapons[ self.loadout.current_weapon ] );
	if ( isDefined( self get_player_melee_weapon() ) )
	{
		self giveweapon( self get_player_melee_weapon() );
	}
	self maps/mp/zombies/_zm_equipment::equipment_give( self.loadout.equipment );
	if ( isDefined( self.loadout.hasclaymore ) && self.loadout.hasclaymore && !self hasweapon( "claymore_zm" ) )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", self.loadout.claymoreclip );
	}
	if ( isDefined( self.loadout.hasemp ) && self.loadout.hasemp )
	{
		self giveweapon( "emp_grenade_zm" );
		self setweaponammoclip( "emp_grenade_zm", self.loadout.empclip );
	}
	if ( isDefined( self.loadout.hastomahawk ) && self.loadout.hastomahawk )
	{
		self giveweapon( self.current_tomahawk_weapon );
		self set_player_tactical_grenade( self.current_tomahawk_weapon );
		self setclientfieldtoplayer( "tomahawk_in_use", 1 );
	}
	self.score = self.loadout.score;
	if( isDefined( self.keep_perks ) && self.keep_perks && isDefined( self.loadout.perks ) && self.loadout.perks.size > 0 )
	{
		i = 0;
		while ( i < self.loadout.perks.size )
		{
			self maps/mp/zombies/_zm_perks::give_perk( self.loadout.perks[ i ] );
			i++;
		}
	}
	self.keep_perks = undefined;
	self set_player_lethal_grenade( self.loadout.lethal_grenade );
	if ( self.loadout.grenade > 0 )
	{
		curgrenadecount = 0;
		if ( self hasweapon( self get_player_lethal_grenade() ) )
		{
			self getweaponammoclip( self get_player_lethal_grenade() );
		}
		else
		{
			self giveweapon( self get_player_lethal_grenade() );
		}
		self setweaponammoclip( self get_player_lethal_grenade(), self.loadout.grenade + curgrenadecount );
	}
}

afterlife_spawn_corpse()
{
	if ( isDefined( self.is_on_gondola ) && self.is_on_gondola && level.e_gondola.destination == "roof" )
	{
		trace_start = self.origin;
		trace_end = self.origin + vectorScale( ( 0, 0, 1 ), 500 );
		corpse_trace = playerphysicstrace( trace_start, trace_end );
		corpse = maps/mp/zombies/_zm_clone::spawn_player_clone( self, corpse_trace, undefined );
	}
	else
	{
		corpse = maps/mp/zombies/_zm_clone::spawn_player_clone( self, self.origin, undefined );
	}
	corpse.angles = self.angles;
	corpse.ignoreme = 1;
	corpse maps/mp/zombies/_zm_clone::clone_give_weapon( "m1911_zm" );
	corpse maps/mp/zombies/_zm_clone::clone_animate( "afterlife" );
	corpse thread afterlife_revive_trigger_spawn();
	if ( flag( "solo_game" ) )
	{
		corpse thread afterlife_corpse_create_pois();
	}
	return corpse;
}

afterlife_revive_do_revive( playerbeingrevived, revivergun )
{
	revivetime = 3;
	playloop = 0;
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		playloop = 1;
		revivetime = 1;
	}
	timer = 0;
	revived = 0;
	playerbeingrevived.revivetrigger.beingrevived = 1;
	playerbeingrevived.revivetrigger sethintstring( "" );
	if ( isplayer( playerbeingrevived ) )
	{
		playerbeingrevived startrevive( self );
	}
	if ( !isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar = self createprimaryprogressbar();
	}
	if ( !isDefined( self.revivetexthud ) )
	{
		self.revivetexthud = newclienthudelem( self );
	}
	self thread revive_clean_up_on_gameover();
	self thread laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );
	if ( !isDefined( self.is_reviving_any ) )
	{
		self.is_reviving_any = 0;
	}
	self.is_reviving_any++;
	self thread laststand_clean_up_reviving_any( playerbeingrevived );
	self.reviveprogressbar updatebar( 0.01, 1 / revivetime );
	self.revivetexthud.alignx = "center";
	self.revivetexthud.aligny = "middle";
	self.revivetexthud.horzalign = "center";
	self.revivetexthud.vertalign = "bottom";
	self.revivetexthud.y = -113;
	if ( self issplitscreen() )
	{
		self.revivetexthud.y = -347;
	}
	self.revivetexthud.foreground = 1;
	self.revivetexthud.font = "default";
	self.revivetexthud.fontscale = 1.8;
	self.revivetexthud.alpha = 1;
	self.revivetexthud.color = ( 1, 1, 1 );
	self.revivetexthud.hidewheninmenu = 1;
	if ( isDefined( self.pers_upgrades_awarded[ "revive" ] ) && self.pers_upgrades_awarded[ "revive" ] )
	{
		self.revivetexthud.color = ( 0.5, 0.5, 1 );
	}
	self.revivetexthud settext( &"GAME_REVIVING" );
	self thread check_for_failed_revive( playerbeingrevived );
	e_fx = spawn( "script_model", playerbeingrevived.revivetrigger.origin );
	e_fx setmodel( "tag_origin" );
	e_fx thread revive_fx_clean_up_on_disconnect( playerbeingrevived );
	playfxontag( level._effect[ "afterlife_leave" ], e_fx, "tag_origin" );
	if ( isDefined( playloop ) && playloop )
	{
		e_fx playloopsound( "zmb_afterlife_reviving", 0.05 );
	}
	while ( self is_reviving_afterlife( playerbeingrevived ) )
	{
		wait 0.05;
		timer += 0.05;
		if ( self player_is_in_laststand() )
		{
			break;
		}
		else if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
		{
			break;
		}
		else
		{
			if ( timer >= revivetime )
			{
				self.manabar Destroy();
				revived = 1;
				break;
			}
		}
	}
	e_fx delete();
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
	if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
	{
	}
	else if ( !revived )
	{
		if ( isplayer( playerbeingrevived ) )
		{
			playerbeingrevived stoprevive( self );
		}
	}
	playerbeingrevived.revivetrigger sethintstring( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	playerbeingrevived.revivetrigger.beingrevived = 0;
	self notify( "do_revive_ended_normally" );
	self.is_reviving_any--;

	if ( !revived )
	{
		playerbeingrevived thread checkforbleedout( self );
	}
	return revived;
}

afterlife_player_damage_callback_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( eattacker.is_zombie ) && eattacker.is_zombie )
		{
			if ( isDefined( eattacker.custom_damage_func ) )
			{
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			}
			else
			{
				if ( isDefined( eattacker.meleedamage ) && smeansofdeath != "MOD_GRENADE_SPLASH" )
				{
					idamage = eattacker.meleedamage;
				}
			}
			if ( isDefined( self.afterlife ) && self.afterlife )
			{
				self afterlife_reduce_mana( 10 );
				self clientnotify( "al_d" );
				return 0;
			}
		}
	}
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	if ( isDefined( eattacker ) && isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
	{
		if ( isDefined( self.hasriotshield ) && self.hasriotshield && isDefined( vdir ) )
		{
			item_dmg = 100;
			if ( isDefined( eattacker.custom_item_dmg ) )
			{
				item_dmg = eattacker.custom_item_dmg;
			}
			if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
			{
				if ( self player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
					return 0;
				}
			}
			else
			{
				if ( !isDefined( self.riotshieldentity ) )
				{
					if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isDefined( self.player_shield_apply_damage ) )
					{
						self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
						return 0;
					}
				}
			}
		}
	}
	if ( smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath == "MOD_GRENADE" && smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( sweapon == "blundersplat_explosive_dart_zm" )
		{
			if ( self hasperk( "specialty_flakjacket" ) )
			{
				self.use_adjusted_grenade_damage = 1;
				idamage = 0;
			}
			if ( isalive( self ) && isDefined( self.is_zombie ) && !self.is_zombie )
			{
				self.use_adjusted_grenade_damage = 1;
				idamage = 10;
			}
		}
		else
		{
			if ( self hasperk( "specialty_flakjacket" ) )
			{
				return 0;
			}
			if ( self.health > 75 && isDefined( self.is_zombie ) && !self.is_zombie )
			{
				idamage = 75;
			}
		}
	}
	if ( sweapon == "tower_trap_zm" || sweapon == "tower_trap_upgraded_zm" )
	{
		self.use_adjusted_grenade_damage = 1;
		return 0;
	}
	if ( idamage >= self.health && isDefined( level.intermission ) && !level.intermission )
	{
		if(self HasPerk("specialty_scavenger"))
		{
			return idamage;
		}
		if ( self.lives > 0 && isDefined( self.afterlife ) && !self.afterlife )
		{
			self playsoundtoplayer( "zmb_afterlife_death", self );
			self afterlife_remove();
			self.afterlife = 1;
			self thread afterlife_laststand();
			if ( self.health <= 1 )
			{
				return 0;
			}
			else
			{
				idamage = self.health - 1;
			}
		}
		else
		{
			self thread last_stand_conscience_vo();
		}
	}
	return idamage;
}
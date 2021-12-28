#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_chugabud;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_tombstone;

main()
{
	replacefunc(maps/mp/zombies/_zm_tombstone::tombstone_save_perks, ::tombstone_save_perks);
	replacefunc(maps/mp/zombies/_zm_chugabud::chugabud_fake_revive, ::chugabud_fake_revive);
	replacefunc(maps/mp/zombies/_zm_chugabud::chugabud_fake_death, ::chugabud_fake_death);
	replacefunc(maps/mp/zombies/_zm_chugabud::chugabud_bleed_timeout, ::chugabud_bleed_timeout);
	replacefunc(maps/mp/zombies/_zm_chugabud::chugabud_laststand_cleanup, ::chugabud_laststand_cleanup);
	replacefunc(maps/mp/zombies/_zm_chugabud::chugabud_corpse_cleanup, ::chugabud_corpse_cleanup);
}

init()
{
	level.chugabud_laststand_func = ::chugabud_laststand;
}

chugabud_laststand() //checked changed to match cerberus output
{
	self endon( "player_suicide" );
	self endon( "disconnect" );
	self endon( "chugabud_bleedout" );
	self.ignore_insta_kill = 1;
	self.health = self.maxhealth;
	self chugabud_fake_death();
	wait 3;
	if ( isDefined( self.insta_killed ) && self.insta_killed || isDefined( self.disable_chugabud_corpse ) )
	{
		create_corpse = 0;
	}
	else
	{
		create_corpse = 1;
	}
	if ( create_corpse == 1 )
	{
		if ( isDefined( level._chugabug_reject_corpse_override_func ) )
		{
			reject_corpse = self [[ level._chugabug_reject_corpse_override_func ]]( self.origin );
			if ( reject_corpse )
			{
				create_corpse = 0;
			}
		}
	}
	if ( create_corpse == 1 )
	{
		self thread activate_chugabud_effects_and_audio();
		corpse = self chugabud_spawn_corpse();
		corpse thread chugabud_corpse_revive_icon( self );
		self.e_chugabud_corpse = corpse;
		corpse thread chugabud_corpse_cleanup_on_spectator( self );
		if ( isDefined( level.whos_who_client_setup ) )
		{
			corpse setclientfield( "clientfield_whos_who_clone_glow_shader", 1 );
		}
	}
	self chugabud_fake_revive();
	wait 0.1;
	self.ignore_insta_kill = undefined;
	self.disable_chugabud_corpse = undefined;
	if ( create_corpse == 0 )
	{
		self notify( "chugabud_effects_cleanup" );
		return;
	}
	bleedout_time = 45;
	self thread chugabud_bleed_timeout( bleedout_time, corpse );
	self thread chugabud_handle_multiple_instances( corpse );
	self thread tombstone_track_down(corpse);
	corpse waittill( "player_revived", e_reviver );
	if ( isDefined( e_reviver ) && e_reviver == self )
	{
		self notify( "whos_who_self_revive" );
	}
	self perk_abort_drinking( 0.1 );
	//self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	self setorigin( corpse.origin );
	self setplayerangles( corpse.angles );
	if ( self player_is_in_laststand() )
	{
		self thread chugabud_laststand_cleanup( corpse, "player_revived" );
		self enableweaponcycling();
		self enableoffhandweapons();
		self auto_revive( self, 1 );
		return;
	}
	self chugabud_laststand_cleanup( corpse, undefined );
}

tombstone_track_down( corpse )
{
	level endon("end_game");
	corpse endon("death");
	self waittill("player_downed");
	self thread tombstone_instakill();
	self thread chugabud_corpse_cleanup(corpse, 0);
}

tombstone_instakill()
{
	if(!(players.size == 1 && flag( "solo_game" )))
	{
		self notify( "bled_out" );
		wait_network_frame();
		self maps/mp/zombies/_zm_laststand::bleed_out();
	}
}

chugabud_laststand_cleanup( corpse, str_notify ) //checked matches cerberus output
{
	if ( isDefined( str_notify ) )
	{
		self waittill( str_notify );
	}
	self chugabud_corpse_cleanup( corpse, 1 );
}

chugabud_fake_revive() //checked matches cerberus output
{
	level notify( "fake_revive" );
	self notify( "fake_revive" );
	playsoundatposition( "evt_ww_disappear", self.origin );
	//playfx( level._effect[ "chugabud_revive_fx" ], self.origin );
	spawnpoint = chugabud_get_spawnpoint();
	if ( isDefined( level._chugabud_post_respawn_override_func ) )
	{
		self [[ level._chugabud_post_respawn_override_func ]]( spawnpoint.origin );
	}
	if ( isDefined( level.chugabud_force_corpse_position ) )
	{
		if ( isDefined( self.e_chugabud_corpse ) )
		{
			self.e_chugabud_corpse forceteleport( level.chugabud_force_corpse_position );
		}
		level.chugabud_force_corpse_position = undefined;
	}
	if ( isDefined( level.chugabud_force_player_position ) )
	{
		spawnpoint.origin = level.chugabud_force_player_position;
		level.chugabud_force_player_position = undefined;
	}
	self setorigin( spawnpoint.origin );
	self setplayerangles( spawnpoint.angles );
	playsoundatposition( "evt_ww_appear", spawnpoint.origin );
	//playfx( level._effect[ "chugabud_revive_fx" ], spawnpoint.origin );
	self allowstand( 1 );
	self allowcrouch( 1 );
	self allowprone( 1 );
	self.ignoreme = 0;
	self setstance( "stand" );
	self freezecontrols( 0 );
	wait 1;
	self disableinvulnerability();
}

chugabud_bleed_timeout( delay, corpse ) //checked changed to match cerberus output
{
	self endon( "player_suicide" );
	self endon( "disconnect" );
	corpse endon( "death" );
	wait delay;
	if ( isDefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
		{
			wait 0.01;
		}
	}
	self DoDamage(self.maxHealth, self.origin);
	self chugabud_corpse_cleanup( corpse, 0 );
	self tombstone_instakill();
}

chugabud_corpse_cleanup( corpse, was_revived ) //checked matches cerberus output
{
	self notify( "chugabud_effects_cleanup" );
	if ( was_revived )
	{
		playsoundatposition( "evt_ww_appear", corpse.origin );
		//playfx( level._effect[ "chugabud_revive_fx" ], corpse.origin );
	}
	else
	{
		playsoundatposition( "evt_ww_disappear", corpse.origin );
		//playfx( level._effect[ "chugabud_bleedout_fx" ], corpse.origin );
		self notify( "chugabud_bleedout" );
	}
	if ( isDefined( corpse.revivetrigger ) )
	{
		corpse notify( "stop_revive_trigger" );
		corpse.revivetrigger delete();
		corpse.revivetrigger = undefined;
	}
	if ( isDefined( corpse.revive_hud_elem ) )
	{
		corpse.revive_hud_elem destroy();
		corpse.revive_hud_elem = undefined;
	}
	if ( isDefined( corpse.revive_hud ) )
	{
		corpse.revive_hud destroy();
		corpse.revive_hud = undefined;
	}
	self.loadout = undefined;
	wait 0.1;
	corpse delete();
	self.e_chugabud_corpse = undefined;
}

tombstone_save_perks( ent ) //checked matches cerberus output
{
	perk_array = [];
	foreach(perk in ent.perks_active)
	{
		perk_array[ perk_array.size ] = perk;
		if(perk_array.size >= 3)
			break;
	}
	return perk_array;
}

chugabud_fake_death() //checked matches cerberus output
{
	self allowstand( 0 );
	self allowcrouch( 0 );
	self allowprone( 1 );
	self.ignoreme = 1;
	self enableinvulnerability();
	self notify("specialty_scavenger_stop");
	wait 0.1;
	self freezecontrols( 1 );
	wait 0.9;
}

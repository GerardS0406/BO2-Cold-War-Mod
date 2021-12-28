#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_playerhealth;

main()
{
	replacefunc(maps/mp/zombies/_zm_playerhealth::playerhealthregen, ::playerhealthregen);
}

playerhealthregen() //checked changed to match cerberus output
{
	self notify( "playerHealthRegen" );
	self endon( "playerHealthRegen" );
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( self.flag ) )
	{
		self.flag = [];
		self.flags_lock = [];
	}
	if ( !isDefined( self.flag[ "player_has_red_flashing_overlay" ] ) )
	{
		self player_flag_init( "player_has_red_flashing_overlay" );
		self player_flag_init( "player_is_invulnerable" );
	}
	self player_flag_clear( "player_has_red_flashing_overlay" );
	self player_flag_clear( "player_is_invulnerable" );
	self thread healthoverlay();
	oldratio = 1;
	health_add = 0;
	regenrate = 0.1;
	veryhurt = 0;
	playerjustgotredflashing = 0;
	invultime = 0;
	hurttime = 0;
	newhealth = 0;
	lastinvulratio = 1;
	self thread playerhurtcheck();
	if ( !isDefined( self.veryhurt ) )
	{
		self.veryhurt = 0;
	}
	self.bolthit = 0;
	if ( getDvar( "scr_playerInvulTimeScale" ) == "" )
	{
		setdvar( "scr_playerInvulTimeScale", 1 );
	}
	playerinvultimescale = getDvarFloat( "scr_playerInvulTimeScale" );
	for ( ;; )
	{
		wait 0.05;
		waittillframeend;
		if ( self.health == self.maxhealth )
		{
			if ( self player_flag( "player_has_red_flashing_overlay" ) )
			{
				player_flag_clear( "player_has_red_flashing_overlay" );
			}
			lastinvulratio = 1;
			playerjustgotredflashing = 0;
			veryhurt = 0;
			continue;
		}
		if ( self.health <= 0 )
		{
			/*
/#
			showhitlog();
#/
			*/
			return;
		}
		wasveryhurt = veryhurt;
		health_ratio = self.health / self.maxhealth;
		if ( health_ratio <= level.healthoverlaycutoff )
		{
			veryhurt = 1;
			if ( !wasveryhurt )
			{
				hurttime = getTime();
				self startfadingblur( 3.6, 2 );
				self player_flag_set( "player_has_red_flashing_overlay" );
				playerjustgotredflashing = 1;
			}
		}
		if ( self.hurtagain )
		{
			hurttime = getTime();
			self.hurtagain = 0;
		}
		if ( health_ratio >= oldratio )
		{
			long_regen_time = level.longregentime;
			if(self HasPerk("specialty_quickrevive"))
			{
				long_regen_time /= 3;
			}
			if ( (getTime() - hurttime) < level.playerhealth_regularregendelay )
			{
				continue;
			}
			if ( veryhurt )
			{
				self.veryhurt = 1;
				newhealth = health_ratio;
				if ( getTime() > ( hurttime + long_regen_time ) )
				{
					newhealth += regenrate;
				}
			}
			else
			{
				newhealth = 1;
				self.veryhurt = 0;
			}
			if ( newhealth > 1 )
			{
				newhealth = 1;
			}
			if ( newhealth <= 0 )
			{
				return;
			}
			/*
/#
			if ( newhealth > health_ratio )
			{
				logregen( newhealth );
#/
			}
			*/
			self setnormalhealth( newhealth );
			oldratio = self.health / self.maxhealth;
			continue;
		}
		invulworthyhealthdrop = lastinvulratio - health_ratio > level.worthydamageratio;
		if ( self.health <= 1 )
		{
			self setnormalhealth( 2 / self.maxhealth );
			invulworthyhealthdrop = 1;
			/*
/#
			if ( !isDefined( level.player_deathinvulnerabletimeout ) )
			{
				level.player_deathinvulnerabletimeout = 0;
			}
			if ( level.player_deathinvulnerabletimeout < getTime() )
			{
				level.player_deathinvulnerabletimeout = getTime() + getDvarInt( "player_deathInvulnerableTime" );
#/
			}
			*/
		}
		oldratio = self.health / self.maxhealth;
		level notify( "hit_again" );
		health_add = 0;
		hurttime = getTime();
		self startfadingblur( 3, 0.8 );
		if ( !invulworthyhealthdrop || playerinvultimescale <= 0 )
		{
			/*
/#
			loghit( self.health, 0 );
#/
			*/
			continue;
		}
		if ( self player_flag( "player_is_invulnerable" ) )
		{
			continue;
		}
		self player_flag_set( "player_is_invulnerable" );
		level notify( "player_becoming_invulnerable" );
		if ( playerjustgotredflashing )
		{
			invultime = level.invultime_onshield;
			playerjustgotredflashing = 0;
		}
		else if ( veryhurt )
		{
			invultime = level.invultime_postshield;
		}
		else
		{
			invultime = level.invultime_preshield;
		}
		invultime *= playerinvultimescale;
		/*
/#
		loghit( self.health, invultime );
#/
		*/
		lastinvulratio = self.health / self.maxhealth;
		self thread playerinvul( invultime );
	}
}

playerinvul( timer ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( timer > 0 )
	{
		/*
/#
		level.playerinvultimeend = getTime() + ( timer * 1000 );
#/	
		*/
		wait timer;
	}
	self player_flag_clear( "player_is_invulnerable" );
}
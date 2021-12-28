#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/_zm;

main()
{
	replacefunc(maps/mp/zombies/_zm::take_additionalprimaryweapon, ::take_additionalprimaryweapon);
}

init()
{
	onplayerconnect_callback( ::mule_player_connect );
}

mule_player_connect()
{
	self thread watchforperk();
}

watchforperk()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("perk_acquired");
		if(scripts/zm/cw_perks::has_active_perk("specialty_additionalprimaryweapon"))
		{
			if(isdefined(self.retain_mule_weapon))
			{
				self maps/mp/zombies/_zm_weapons::weapon_give(self.retain_mule_weapon);
				self.retain_mule_weapon = undefined;
			}
		}
	}
}

take_additionalprimaryweapon() //checked changed to match cerberus output
{
	weapon_to_take = undefined;
	if ( is_true( self._retain_perks ) || isDefined( self._retain_perks_array ) && isDefined( self._retain_perks_array[ "specialty_additionalprimaryweapon" ] ) && self._retain_perks_array[ "specialty_additionalprimaryweapon" ] )
	{
		return weapon_to_take;
	}
	primary_weapons_that_can_be_taken = [];
	primaryweapons = self getweaponslistprimaries();
	for ( i = 0; i < primaryweapons.size; i++ )
	{
		if ( maps/mp/zombies/_zm_weapons::is_weapon_included( primaryweapons[ i ] ) || maps/mp/zombies/_zm_weapons::is_weapon_upgraded(primaryweapons[ i ] ) )
		{
			primary_weapons_that_can_be_taken[ primary_weapons_that_can_be_taken.size ] = primaryweapons[ i ];
		}
	}
	pwtcbt = primary_weapons_that_can_be_taken.size;
	while ( pwtcbt >= 3 )
	{
		weapon_to_take = primary_weapons_that_can_be_taken[ pwtcbt - 1 ];
		pwtcbt--;

		if ( weapon_to_take == self getcurrentweapon() )
		{
			self switchtoweapon( primary_weapons_that_can_be_taken[ 0 ] );
		}
		self.retain_mule_weapon = weapon_to_take;
		self takeweapon( weapon_to_take );
	}
	return weapon_to_take;
}
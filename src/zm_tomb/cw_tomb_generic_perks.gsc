#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_tomb;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_perk_random;

main()
{
	replacefunc(maps/mp/zm_tomb::include_perks_in_random_rotation, ::include_perks_in_random_rotation);
}

init()
{
	level.zombiemode_using_tombstone_perk = 1;
}

include_perks_in_random_rotation() //checked matches cerberus output
{
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_armorvest" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_quickrevive" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_fastreload" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_rof" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_longersprint" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_deadshot" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_additionalprimaryweapon" );
	maps/mp/zombies/_zm_perk_random::include_perk_in_random_rotation( "specialty_flakjacket" );
	level.custom_random_perk_weights = ::tomb_random_perk_weights;
}

tomb_random_perk_weights() //checked matches cerberus output
{
	temp_array = [];
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_rof", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_deadshot", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_additionalprimaryweapon", 0 );
	}
	if ( randomint( 4 ) == 0 )
	{
		arrayinsert( temp_array, "specialty_flakjacket", 0 );
	}
	temp_array = array_randomize( temp_array );
	level._random_perk_machine_perk_list = array_randomize( level._random_perk_machine_perk_list );
	level._random_perk_machine_perk_list = arraycombine( level._random_perk_machine_perk_list, temp_array, 1, 0 );
	keys = getarraykeys( level._random_perk_machine_perk_list );
	return keys;
}
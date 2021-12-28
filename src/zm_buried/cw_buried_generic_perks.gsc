#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;

init()
{
	level.zombiemode_using_deadshot_perk = 1;
	level.zombiemode_using_tombstone_perk = 1;
	perk_machine_removal("specialty_nomotionsensor");
}
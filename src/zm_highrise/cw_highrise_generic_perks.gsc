#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;

main()
{
	structs = getstructarray( "zm_perk_machine", "targetname" );
	foreach(struct in structs)
		if(struct.script_noteworthy == "specialty_finalstand")
			struct Delete();
}

init()
{
	level.zombiemode_using_deadshot_perk = 1;
	level.zombiemode_using_tombstone_perk = 1;
	level.zombiemode_using_marathon_perk = 1;
	level.zombiemode_using_chugabud_perk = 0;
	thread closeWhosWho();
}

closeWhosWho()
{
	level waittill("initial_blackscreen_passed");
	machine_triggers = getentarray( "vending_chugabud", "target" );
	machine_trigger = machine_triggers[ 0 ];
	machine = getent("vending_chugabud", "targetname");
	foreach(elevator in level.elevators)
	{
		if(elevator.body.perk_type == "vending_chugabud")
		{
			machine_trigger Delete();
			machine Delete();
		}
	}
}
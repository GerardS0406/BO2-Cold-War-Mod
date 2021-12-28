#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;

main()
{
	level.zombiemode_using_elementalpop_perk = 1;
	maps/mp/zombies/_zm_perks::register_perk_basic_info( "specialty_elementalpop", "elementalpop", 2000, &"ZOMBIE_PERK_DIVETONUKE", "zombie_perk_bottle_cherry" );
	maps/mp/zombies/_zm_perks::register_perk_machine( "specialty_elementalpop", ::elementalpop_perk_machine_setup, ::elementalpop_perk_machine_think );
	maps/mp/zombies/_zm_perks::register_perk_threads( "specialty_elementalpop", ::elementalpop_give, ::elementalpop_take);
}

elementalpop_give()
{
	self thread elementalpopcooldown();
	if(level.script == "zm_tomb" || level.script == "zm_prison")
	{
		self thread maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_reload_attack();
	}
}

elementalpopcooldown()
{
	self endon("disconnect");
	level endon("end_game");
	while(1)
	{
		if(self.elementalpop_cooldown > 0)
		{
			self.elementalpop_cooldown--;
			wait 1;
			continue;
		}
		self waittill("elementalpop_activated");
	}
}

elementalpop_take()
{
	self notify( "stop_electric_cherry_reload_attack" );
}

elementalpop_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision ) //checked matches cerberus output
{
	use_trigger.script_sound = "mus_perks_phd_jingle";
	use_trigger.script_string = "elementalpop_perk";
	use_trigger.script_label = "mus_perks_phd_sting";
	use_trigger.target = "vending_elementalpop";
	perk_machine.script_string = "elementalpop_perk";
	perk_machine.targetname = "vending_elementalpop";
	if ( isDefined( bump_trigger ) )
	{
		bump_trigger.script_string = "elementalpop_perk";
	}
}

elementalpop_perk_machine_think() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_elementalpop", "targetname" );
		machine_triggers = getentarray( "vending_elementalpop", "target" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "juggernog" ].off_model );
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level thread do_initial_power_off_callback( machine, "elementalpop" );
		level waittill( "elementalpop_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "juggernog" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "elementalpop_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_elementalpop_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "juggernog" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "juggernog" ].power_on_callback );
		}
		level waittill( "elementalpop_off" );
		if ( isDefined( level.machine_assets[ "juggernog" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "juggernog" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}
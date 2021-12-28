#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	put_weapons_in_box();
	spawn_salvage_ammo_stations();
}

put_weapons_in_box()
{
	level.ultra_weapons = array("ray_gun_zm", "raygun_mark2_zm", "staff_air_zm", "staff_air_upgraded_zm", "staff_fire_zm", "staff_fire_upgraded_zm", "staff_lightning_zm", "staff_lightning_upgraded_zm", "staff_water_zm", "staff_water_upgraded_zm");
	weaponsArray = array( "mg08_zm", "hamr_zm", "type95_zm", "galil_zm", "fnfal_zm", "m14_zm", "mp44_zm", "scar_zm", "870mcs_zm", "srm1216_zm", "ksg_zm", "ak74u_zm", "ak74u_extclip_zm", "pdw57_zm", "thompson_zm", "qcw05_zm", "mp40_zm", "mp40_stalker_zm", "evoskorpion_zm", "ballista_zm", "dsr50_zm", "beretta93r_zm", "beretta93r_extclip_zm", "kard_zm", "fiveseven_zm", "python_zm", "c96_zm", "fivesevendw_zm", "m32_zm" );
	weaponsArray = array_randomize(weaponsArray);
	level.start_weapon = weaponsArray[0];

	foreach(weapon in weaponsArray)
		level.zombie_weapons[weapon].is_in_box = 1;
}

spawn_salvage_ammo_stations()
{
	//Salvage Stations p6_zm_nuked_table_end_wood
	//thread scripts/zm/cw_weapon_tiers::spawnSalvageStations((2283,200,2880), (0,329,0));
	//Ammo Boxes
	//thread scripts/zm/cw_weapon_tiers::spawnAmmoStations((2056,61,2880), (0,150,0));

	//Wunderfizz
	thread scripts/zm/cw_perks::spawn_cw_wunderfizz((2466,4464,-316));
}
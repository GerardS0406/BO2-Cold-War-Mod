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
	level.ultra_weapons = array("ray_gun_zm", "raygun_mark2_zm", "blundergat_zm", "blunderspat_zm");
	weaponsArray = array( "m1911_zm", "judge_zm", "fiveseven_zm", "beretta93r_zm", "fivesevendw_zm", "uzi_zm", "thompson_zm", "mp5k_zm", "pdw57_zm", "870mcs_zm", "rottweil72_zm", "saiga12_zm", "ak47_zm", "m14_zm", "tar21_zm", "galil_zm", "fnfal_zm", "dsr50_zm", "barretm82_zm", "lsat_zm", "usrpg_zm" );
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
	thread scripts/zm/cw_perks::spawn_cw_wunderfizz((2075,10388,1336));
}
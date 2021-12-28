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
	level.ultra_weapons = array("ray_gun_zm", "raygun_mark2_zm", "slipgun_zm");
	weaponsArray = array( "m1911_zm", "python_zm", "judge_zm", "kard_zm", "fiveseven_zm", "beretta93r_zm", "fivesevendw_zm", "ak74u_zm", "mp5k_zm", "qcw05_zm", "pdw57_zm", "870mcs_zm", "rottweil72_zm", "saiga12_zm", "srm1216_zm", "m14_zm", "saritch_zm", "m16_zm", "xm8_zm", "type95_zm", "tar21_zm", "galil_zm", "fnfal_zm", "dsr50_zm", "barretm82_zm", "svu_zm", "rpd_zm", "hamr_zm", "usrpg_zm", "m32_zm", "an94_zm", "knife_ballistic_zm" );
	weaponsArray = array_randomize(weaponsArray);
	level.start_weapon = weaponsArray[0];

	foreach(weapon in weaponsArray)
		level.zombie_weapons[weapon].is_in_box = 1;
}

spawn_salvage_ammo_stations()
{
	//Salvage Stations p6_zm_nuked_table_end_wood
	thread scripts/zm/cw_weapon_tiers::spawnSalvageStations((2283,200,2880), (0,329,0));
	thread scripts/zm/cw_weapon_tiers::spawnSalvageStations((1411,2606,3040), (0,180,0));
	thread scripts/zm/cw_weapon_tiers::spawnSalvageStations((2603,281,1296), (0,330,0));

	//Ammo Boxes
	thread scripts/zm/cw_weapon_tiers::spawnAmmoStations((2056,61,2880), (0,150,0));
	thread scripts/zm/cw_weapon_tiers::spawnAmmoStations((1855,1445,3392), (0,85,0));
	thread scripts/zm/cw_weapon_tiers::spawnAmmoStations((3227,1941,2957), (0,128,0));
	thread scripts/zm/cw_weapon_tiers::spawnAmmoStations((2822,1868,1403), (0,270,0));
	thread scripts/zm/cw_weapon_tiers::spawnAmmoStations((2362,-57,1296), (0,150,0));

	//Wunderfizz
	thread scripts/zm/cw_perks::spawn_cw_wunderfizz((1822,1462,3040));
}
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	scripts/zm/cw_field_upgrades::register_coldwar_fieldupgrade( "custom_field_upgrade", "Custom Field Upgrade", "SHADER", ::use_custom_field_upgrade );
}

init()
{
	PrecacheShader("SHADER"); //Make Sure You Use A Shader not already used by the mod!
}

/*================================================================

The below function is what happens when field upgrade is activated
					self = player who activated

================================================================*/
use_custom_field_upgrade()
{
	self endon("disconnect");
	//below colors your screen to show a field upgrade is active!
	self scripts/zm/cw_field_upgrades::setOverlayColor((0,0.9,1), 0.5); //(R,G,B), ALPHA(transparency)
	//Add Field Upgrade Functionality Here!
	self scripts/zm/cw_field_upgrades::setOverlayColor((0.4,0,0), 0); //DON'T TOUCH. RESET TO RED FOR REDSCREEN
}

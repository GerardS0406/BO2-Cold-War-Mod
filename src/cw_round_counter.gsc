#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	precacheshader("hud_chalk_1");
	precacheshader("hud_chalk_2");
	precacheshader("hud_chalk_3");
	precacheshader("hud_chalk_4");
	precacheshader("hud_chalk_5");
	level.round_think_func = ::round_think;
	thread round_hud();
}

round_hud()
{
	level waittill("start_of_round");
	if(level.round_number > 5)
	{
		roundCounter = createserverfontstring("default", 3);
		roundCounter SetPoint("RIGHT", "TOPRIGHT", 50, 0);
		roundCounter.hidewheninmenu = 1;
		roundCounter.alpha = 0;
		roundCounter.color = (1,1,1);
		roundCounter FadeOverTime(2);
		roundCounter.alpha = 1;
		roundCounter.color = (0.75,0,0);
		roundCounter SetValue(level.round_number);
	}
	else
	{
		roundCounter = createservericon( "hud_chalk_1", 40, 40 );
		roundCounter SetPoint("RIGHT", "TOPRIGHT", 50 + 30);
		roundCounter.alpha = 1;
		roundCounter.hidewheninmenu = 1;
		roundCounter.color = (0.75,0,0);
		roundCounter.xoffset = 50 + 32;
	}
	while(1)
	{
		level waittill("end_of_round");
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 0;
		roundCounter.color = (1,1,1);
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 1;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 0;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 1;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 0;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 1;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 0;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 1;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 0;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 1;
		wait .5;
		roundCounter FadeOverTime(0.5);
		roundCounter.alpha = 0;
		level waittill("between_round_over");
		if(level.round_number > 6)
		{
			roundCounter SetValue(level.round_number);
			roundCounter FadeOverTime(2);
			roundCounter.alpha = 1;
			roundCounter.color = (0.75,0,0);
		}
		else if(level.round_number == 2)
		{
			roundCounter SetShader("hud_chalk_2", 40, 40);
			roundCounter SetPoint("RIGHT", "TOPRIGHT", 50 + 20);
			roundCounter FadeOverTime(2);
			roundCounter.alpha = 1;
			roundCounter.color = (0.75,0,0);
		}
		else if(level.round_number == 3)
		{
			roundCounter SetShader("hud_chalk_3", 40, 40);
			roundCounter SetPoint("RIGHT", "TOPRIGHT", 50 + 10);
			roundCounter FadeOverTime(2);
			roundCounter.alpha = 1;
			roundCounter.color = (0.75,0,0);
		}
		else if(level.round_number == 4)
		{
			roundCounter SetShader("hud_chalk_4", 40, 40);
			roundCounter SetPoint("RIGHT", "TOPRIGHT", 50);
			roundCounter FadeOverTime(2);
			roundCounter.alpha = 1;
			roundCounter.color = (0.75,0,0);
		}
		else if(level.round_number == 5)
		{
			roundCounter SetShader("hud_chalk_5", 40, 40);
			roundCounter SetPoint("RIGHT", "TOPRIGHT", 50);
			roundCounter.xoffset = 50 + 0;
			roundCounter FadeOverTime(2);
			roundCounter.alpha = 1;
			roundCounter.color = (0.75,0,0);
		}
		else if(level.round_number == 6)
		{
			roundCounter destroyElem();
			roundCounter = createserverfontstring("default", 3);
			roundCounter SetPoint("RIGHT", "TOPRIGHT", 50, 0);
			roundCounter.hidewheninmenu = 1;
			roundCounter.alpha = 0;
			roundCounter.color = (1,1,1);
			roundCounter FadeOverTime(2);
			roundCounter.alpha = 1;
			roundCounter.color = (0.75,0,0);
			roundCounter SetValue(level.round_number);
		}
	}
}

round_think( restart ) //checked changed to match cerberus output
{
	if ( !isDefined( restart ) )
	{
		restart = 0;
	}
	level endon( "end_round_think" );
	if ( !is_true( restart ) )
	{
		if ( isDefined( level.initial_round_wait_func ) )
		{
			[[ level.initial_round_wait_func ]]();
		}
		players = get_players();
		foreach ( player in players )
		{
			if ( is_true( player.hostmigrationcontrolsfrozen ) ) 
			{
				player freezecontrols( 0 );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
		}
	}
	for ( ;; )
	{
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		{
			maxreward = 500;
		}
		level.zombie_vars[ "rebuild_barrier_cap_per_round" ] = maxreward;
		level.pro_tips_start_time = getTime();
		level.zombie_last_run_time = getTime();
		if ( isDefined( level.zombie_round_change_custom ) )
		{
			[[ level.zombie_round_change_custom ]]();
		}
		else
		{
			level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
			round_one_up();
		}
		maps/mp/zombies/_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, ::rebuild_barrier_reward_reset );
		if ( !is_true( level.headshots_only ) && !restart )
		{
			level thread award_grenades_for_survivors();
		}
		level.round_start_time = getTime();
		while ( level.zombie_spawn_locations.size <= 0 )
		{
			wait 0.1;
		}
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();
		for ( index = 0; index < players.size; index++  )
		{
			zonename = players[ index ] get_current_zone();
			if ( isDefined( zonename ) )
			{
				players[ index ] recordzombiezone( "startingZone", zonename );
			}
		}
		if ( isDefined( level.round_start_custom_func ) )
		{
			[[ level.round_start_custom_func ]]();
		}
		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		uploadstats();
		if ( isDefined( level.round_end_custom_logic ) )
		{
			[[ level.round_end_custom_logic ]]();
		}
		players = get_players();
		if ( is_true( level.no_end_game_check ) )
		{
			level thread last_stand_revive();
			level thread spectators_respawn();
		}
		else if ( players.size != 1 )
		{
			level thread spectators_respawn();
		}
		players = get_players();
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
		}
		if ( level.gamedifficulty == 0 )
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
		}
		else
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
		}
		level.round_number++;
		matchutctime = getutc();
		players = get_players();
		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
			{
				player maps/mp/zombies/_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps/mp/zombies/_zm_stats::update_playing_utc_time( matchutctime );
		}
		check_quickrevive_for_hotjoin(); //was commented out
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}
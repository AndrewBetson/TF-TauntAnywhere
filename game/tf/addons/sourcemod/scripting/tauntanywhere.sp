/**
 * Copyright Andrew Betson.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#include <dhooks>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

#define WL_WAIST 2

DHookSetup	g_hDetour_IsAllowedToTaunt;
DHookSetup	g_hDetour_IsAllowedToInitiateTauntWithPartner;
DHookSetup	g_hDetour_ShouldStopTaunting;

ConVar		sv_tauntanywhere_allow_already_taunting;
ConVar		sv_tauntanywhere_allow_cloaked_spies;
ConVar		sv_tauntanywhere_allow_disguised_spies;
ConVar		sv_tauntanywhere_allow_grappled_to_player;
ConVar		sv_tauntanywhere_allow_in_halloween_kart;

ConVar		sv_tauntanywhere_allow_underwater;
ConVar		sv_tauntanywhere_disable_water_taunt_cancellation;

ConVar		sv_tauntanywhere_allow_all;

public Plugin myinfo =
{
	name		= "[TF2] Taunt Anywhere",
	author		= "Andrew \"andrewb\" Betson",
	description	= "Removes certain restrictions on where/when players can taunt (i.e high-fiving while facing a wall)",
	version		= "1.1.0",
	url			= "https://www.github.com/AndrewBetson/TF-TauntAnywhere"
};

public void OnPluginStart()
{
	if ( GetEngineVersion() != Engine_TF2 )
	{
		SetFailState( "Taunt Anywhere is only compatible with Team Fortress 2." );
	}

	Handle hGameData = LoadGameConfigFile( "tauntanywhere.games" );
	if ( !hGameData )
	{
		SetFailState( "Failed to load tauntanywhere gamedata." );
	}

	g_hDetour_IsAllowedToTaunt						= DHookCreateFromConf( hGameData, "CTFPlayer_IsAllowedToTaunt" );
	g_hDetour_IsAllowedToInitiateTauntWithPartner	= DHookCreateFromConf( hGameData, "CTFPlayer_IsAllowedToInitiateTauntWithPartner" );
	g_hDetour_ShouldStopTaunting					= DHookCreateFromConf( hGameData, "CTFPlayer_ShouldStopTaunting" );

	delete hGameData;

	if ( !DHookEnableDetour( g_hDetour_IsAllowedToTaunt, false, Detour_IsAllowedToTaunt ) )
	{
		SetFailState( "Failed to detour CTFPlayer::IsAllowedToTaunt, tell Andrew to update the signatures." );
	}
	if ( !DHookEnableDetour( g_hDetour_IsAllowedToInitiateTauntWithPartner, false, Detour_IsAllowedToInitiateTauntWithPartner ) )
	{
		SetFailState( "Failed to detour CTFPlayer::IsAllowedToInitiateTauntWithPartner, tell Andrew to update the signatures." );
	}
	if ( !DHookEnableDetour( g_hDetour_ShouldStopTaunting, false, Detour_ShouldStopTaunting ) )
	{
		SetFailState( "Failed to detour CTFPlayer::ShouldStopTaunting, tell Andrew to update the signatures." );
	}

	sv_tauntanywhere_allow_already_taunting				= CreateConVar( "sv_tauntanywhere_allow_already_taunting", "0", "Allow players to taunt while they are already taunting." );
	sv_tauntanywhere_allow_cloaked_spies				= CreateConVar( "sv_tauntanywhere_allow_cloaked_spies", "0", "Allow Spies to taunt while cloaked." );
	sv_tauntanywhere_allow_disguised_spies				= CreateConVar( "sv_tauntanywhere_allow_disguised_spies", "0", "Allow Spies to taunt while disguised." );
	sv_tauntanywhere_allow_grappled_to_player			= CreateConVar( "sv_tauntanywhere_allow_grappled_to_player", "0", "Allow players to taunt while grappled onto another player." );
	sv_tauntanywhere_allow_in_halloween_kart			= CreateConVar( "sv_tauntanywhere_allow_in_halloween_kart", "0", "Allow players to taunt while in Halloween go-karts." );

	sv_tauntanywhere_allow_underwater					= CreateConVar( "sv_tauntanywhere_allow_underwater", "0", "Allow players to taunt while underwater." );
	sv_tauntanywhere_disable_water_taunt_cancellation	= CreateConVar( "sv_tauntanywhere_disable_water_taunt_cancellation", "0", "Disable taunt cancellation on entering water." );

	sv_tauntanywhere_allow_all							= CreateConVar( "sv_tauntanywhere_allow_all", "0", "Remove all restrictions on taunting. Effectively the same as setting all \"allow_(x)\" cvars to 1." );
	AutoExecConfig( true, "tauntanywhere" );
}

public void OnPluginEnd()
{
	if ( g_hDetour_IsAllowedToTaunt != INVALID_HANDLE )
	{
		DHookDisableDetour( g_hDetour_IsAllowedToTaunt, false, Detour_IsAllowedToTaunt );
	}

	if ( g_hDetour_IsAllowedToInitiateTauntWithPartner != INVALID_HANDLE )
	{
		DHookDisableDetour( g_hDetour_IsAllowedToInitiateTauntWithPartner, false, Detour_IsAllowedToInitiateTauntWithPartner );
	}

	if ( g_hDetour_ShouldStopTaunting != INVALID_HANDLE )
	{
		DHookDisableDetour( g_hDetour_ShouldStopTaunting, false, Detour_ShouldStopTaunting );
	}
}

public MRESReturn Detour_IsAllowedToTaunt( int nClientID, DHookReturn hReturn, DHookParam hParams )
{
	if ( IsClientAllowedToTaunt( nClientID ) )
	{
		hReturn.Value = true;
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn Detour_IsAllowedToInitiateTauntWithPartner( int nClientID, DHookReturn hReturn, DHookParam hParams )
{
	// Original impl of this function only does wall/ledge checks, so this can just always return true.
	hReturn.Value = true;

	return MRES_Supercede;
}

public MRESReturn Detour_ShouldStopTaunting( int nClientID, DHookReturn hReturn, DHookParam hParams )
{
	if ( sv_tauntanywhere_disable_water_taunt_cancellation.BoolValue || sv_tauntanywhere_allow_underwater.BoolValue || sv_tauntanywhere_allow_all.BoolValue )
	{
		hReturn.Value = false;
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

bool IsClientAllowedToTaunt( int nClientID )
{
	// These would probably either do nothing or crash the server and/or client, so don't allow them regardless of allow_all setting.
	if ( !IsPlayerAlive( nClientID ) || TF2_IsPlayerInCondition( nClientID, TFCond_HalloweenGhostMode ) )
	{
		return false;
	}

	if ( sv_tauntanywhere_allow_all.BoolValue )
	{
		return true;
	}

	bool bCanTaunt_AlreadyTaunting	= !( TF2_IsPlayerInCondition( nClientID, TFCond_Taunting )			&& !sv_tauntanywhere_allow_already_taunting.BoolValue );
	bool bCanTaunt_Cloaked			= !( TF2_IsPlayerInCondition( nClientID, TFCond_Cloaked )			&& !sv_tauntanywhere_allow_cloaked_spies.BoolValue );
	bool bCanTaunt_Disguised		= !( TF2_IsPlayerInCondition( nClientID, TFCond_Disguised )			&& !sv_tauntanywhere_allow_disguised_spies.BoolValue );
	bool bCanTaunt_GrappledToPlayer	= !( TF2_IsPlayerInCondition( nClientID, TFCond_GrappledToPlayer )	&& !sv_tauntanywhere_allow_grappled_to_player.BoolValue );
	bool bCanTaunt_Kart				= !( TF2_IsPlayerInCondition( nClientID, TFCond_HalloweenKart )		&& !sv_tauntanywhere_allow_in_halloween_kart.BoolValue );
	bool bCanTaunt_Underwater		= !( GetEntProp( nClientID, Prop_Send, "m_nWaterLevel" ) > WL_WAIST	&& !sv_tauntanywhere_allow_underwater.BoolValue );

	return
		bCanTaunt_AlreadyTaunting	&&
		bCanTaunt_Cloaked			&&
		bCanTaunt_Disguised			&&
		bCanTaunt_GrappledToPlayer	&&
		bCanTaunt_Kart				&&
		bCanTaunt_Underwater;
}

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

#pragma semicolon 1
#pragma newdecls required

DHookSetup	g_hDetour_IsAllowedToTaunt;
DHookSetup	g_hDetour_IsAllowedToInitiateTauntWithPartner;

ConVar		sv_tauntanywhere_allow_cloaked_or_disguised_spies;
ConVar		sv_tauntanywhere_really_anywhere;

public Plugin myinfo =
{
	name		= "[TF2] Taunt Anywhere",
	author		= "Andrew \"andrewb\" Betson",
	description	= "Removes certain restrictions on where/when players can taunt (i.e high-fiving while facing a wall)",
	version		= "1.0.1",
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

	g_hDetour_IsAllowedToTaunt = DHookCreateFromConf( hGameData, "CTFPlayer_IsAllowedToTaunt" );
	g_hDetour_IsAllowedToInitiateTauntWithPartner = DHookCreateFromConf( hGameData, "CTFPlayer_IsAllowedToInitiateTauntWithPartner" );

	delete hGameData;

	if ( !DHookEnableDetour( g_hDetour_IsAllowedToTaunt, true, Detour_IsAllowedToTaunt ) )
	{
		SetFailState( "Failed to detour CTFPlayer::IsAllowedToTaunt, tell Andrew to update the signatures." );
	}
	if ( !DHookEnableDetour( g_hDetour_IsAllowedToInitiateTauntWithPartner, true, Detour_IsAllowedToInitiateTauntWithPartner ) )
	{
		SetFailState( "Failed to detour CTFPlayer::IsAllowedToInitiateTauntWithPartner, tell Andrew to update the signatures." );
	}

	sv_tauntanywhere_allow_cloaked_or_disguised_spies	= CreateConVar( "sv_tauntanywhere_allow_cloaked_or_disguised_spies", "0", "Allow Spies to taunt while cloaked and/or disguised." );
	sv_tauntanywhere_really_anywhere					= CreateConVar( "sv_tauntanywhere_really_anywhere", "0", "Remove all restrictions on taunting. Very buggy, enable at your own risk." );
	AutoExecConfig( true, "tauntanywhere" );
}

public void OnPluginEnd()
{
	DHookDisableDetour( g_hDetour_IsAllowedToTaunt, false, Detour_IsAllowedToTaunt );
	DHookDisableDetour( g_hDetour_IsAllowedToInitiateTauntWithPartner, false, Detour_IsAllowedToInitiateTauntWithPartner );
}

public MRESReturn Detour_IsAllowedToTaunt( int nClientID, DHookReturn hReturn, DHookParam hParams )
{
	if ( sv_tauntanywhere_really_anywhere.BoolValue )
	{
		hReturn.Value = true;
		return MRES_Supercede;
	}

	if ( sv_tauntanywhere_allow_cloaked_or_disguised_spies.BoolValue )
	{
		bool bCanSpyTaunt = !(
			TF2_IsPlayerInCondition( nClientID, TFCond_Taunting )			||
			TF2_IsPlayerInCondition( nClientID, TFCond_HalloweenGhostMode )	||
			TF2_IsPlayerInCondition( nClientID, TFCond_HalloweenKart )		||
			TF2_IsPlayerInCondition( nClientID, TFCond_GrappledToPlayer )
		);

		if ( TF2_GetPlayerClass( nClientID ) == TFClass_Spy && bCanSpyTaunt )
		{
			hReturn.Value = true;
			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}

public MRESReturn Detour_IsAllowedToInitiateTauntWithPartner( int nClientID, DHookReturn hReturn, DHookParam hParams )
{
	// IsAllowedToTaunt still gets queried when doing partner taunts, so this can just always return true.
	hReturn.Value = true;

	return MRES_Supercede;
}

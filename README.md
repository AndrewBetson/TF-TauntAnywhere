A SourceMod plugin for Team Fortress 2 that removes (some) restrictions on when/where players can taunt.

# Console Elements
Taunt Anywhere exposes the following console elements:
- `sv_tauntanywhere_allow_already_taunting (def. 0`				- Allow players to taunt while they are already taunting. Some taunt combos will cause players to continue vocalizing until they respawn.
- `sv_tauntanywhere_allow_cloaked_spies (def. 0)`				- Allow Spies to taunt while cloaked.
- `sv_tauntanywhere_allow_disguised_spies (def. 0)`				- Allow Spies to taunt while disguised.
- `sv_tauntanywhere_allow_grappled_to_player (def. 0)`			- Allow players to taunt while grappled onto another player.
- `sv_tauntanywhere_allow_in_halloween_kart (def. 0)`			- Allow players to taunt while in a Halloween go-kart.
- `sv_tauntanywhere_allow_underwater (def. 0)`					- Allow players to initiate taunts underwater. Implies `sv_tauntanywhere_disable_water_taunt_cancellation = 1`.
- `sv_tauntanywhere_disable_water_taunt_cancellation (def. 0)`	- Disable taunts being cancelled when players enter water.
- `sv_tauntanywhere_allow_all (def. 0)`							- Remove all restrictions on taunting. Effectively the same as enabling all above CVars.

# License
Taunt Anywhere is released under version 3 of the GNU Affero General Public License. For more info, see `LICENSE.md`.

# Notes
Currently only works on servers hosted on Linux machines. (which are the majority, so w/e)

Servers running a SourceMod version <1.11.6820 will need to manually install [DHooks](https://forums.alliedmods.net/showthread.php?p=2588686#post2588686).

# TODO
- Look into adding an option to allow moving during *all* taunts. (`CTFPlayer::CanMoveDuringTaunt()`?)
- Taunt UI doesn't appear in normally un-tauntable scenarios because client code uses own impl. of IsAllowedToTaunt(). Try to find a workaround.

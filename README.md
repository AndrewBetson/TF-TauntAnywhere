A SourceMod plugin for Team Fortress 2 that removes (some) restrictions on when/where players can taunt.

# Console Elements
Taunt Anywhere exposes the following console-elements:
- `sv_tauntanywhere_allow_cloaked_or_disguised_spies (def. 0)` - Allow Spies to taunt while cloaked and/or disguised.
- `sv_tauntanywhere_really_anywhere (def. 0)` - Remove all restrictions on taunting. Very buggy, enable at your own risk.

# License
Taunt Anywhere is released under version 3 of the GNU Affero General Public License. For more info, see `LICENSE.md`.

# Notes
Currently only works on servers hosted on Linux machines. (which are the majority, so w/e)

Servers running a SourceMod version <1.11.6820 will need to manually install [DHooks](https://forums.alliedmods.net/showthread.php?p=2588686#post2588686).

# TODO
- Add Windows signatures for `CTFPlayer::IsAllowedToTaunt` and `CTFPlayer::IsAllowedToInitiateTauntWithPartner`
- Make really_anywhere mode less buggy. (may require placing *light* restrictions on taunting)
- Maybe separate `sv_tauntanywhere_allow_cloaked_or_disguised_spies` into two cvars.

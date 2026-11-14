# Bundled libraries

- LibButtonGlow-1.0: upstream release 1.3.0, internal minor 7, by Hendrik
  "nevcairiel" Leppkes. Distributed under the BSD-style license preserved in
  LibButtonGlow-1.0/LibButtonGlow-1.0.lua.
- LibStub: major 2 / minor 2, public domain; credits retained in LibStub/LibStub.lua.

The files are unmodified copies from the official LibButtonGlow 1.3.0 archive:
https://www.curseforge.com/wow/addons/libbuttonglow-1-0/files/3078379
Archive: https://edge.forgecdn.net/files/3078/379/LibButtonGlow-1.0-1.3.0.zip

Load LibStub before LibButtonGlow. LibStub:NewLibrary avoids initialization if
an equal/newer library is registered, or upgrades an older shared table in place.
Do not patch third-party files or change their version numbers locally.

## AceGUI-3.0

AceGUI-3.0 minor 41 and all standard widgets are bundled from the official Ace3
repository. AceConfig and its dependencies are now bundled too, as described below.
AceAddon and AceDB are not needed.

- Source revision: ac3d1225037e0dc74e025a72342c0f7824aae147
- Source: https://github.com/WoWUIDev/Ace3/tree/ac3d1225037e0dc74e025a72342c0f7824aae147
- Downloaded source archive SHA-256: e415834e8a71c3714ae74549f6c24a2d0f036c9b8c760f8fdb1828ec06fba206
- License: AceGUI-3.0/LICENSE.txt (unmodified upstream Ace3 license).

Load AceGUI-3.0/AceGUI-3.0.xml after LibStub and before our modules. The upstream
core skips initialization if an equal/newer library exists; widget modules do
the same independently with their widget versions. Older versions upgrade in
place. Keep original library/widget names in DEV builds so sharing still works.

## AceConfig-3.0 and CallbackHandler-1.0

Bundled unmodified from the same pinned Ace3 source revision/archive as AceGUI:
ac3d1225037e0dc74e025a72342c0f7824aae147 (SHA-256 above).

- AceConfig-3.0 minor 3 (wrapper).
- AceConfigRegistry-3.0 minor 22.
- AceConfigCmd-3.0 minor 14.
- AceConfigDialog-3.0 minor 93.
- CallbackHandler-1.0 minor 8.
- License copies: AceConfig-3.0/LICENSE.txt and CallbackHandler-1.0/LICENSE.txt.

Load CallbackHandler after LibStub, then the upstream AceConfig XML after AceGUI.
The AceConfig XML loads Registry, Cmd and Dialog before the wrapper. AceConsole
is only required for AceConfigCmd chat command registration, which we do not use:
/sam stays registered by Main.lua. Each upstream component negotiates its version
through LibStub; reuse equal/newer versions and upgrade older shared tables.
Keep library namespaces intact in staged DEV copies.

Settings.lua registers one options table for both the first-use window and the
AddOns category. Current upstream AddToBlizOptions uses the modern Settings API;
our legacy fallback feeds that same table into an upstream BlizOptionsGroup.
No custom skins or changes to library/widget internals are applied.

## Minimap / DataBroker

Unmodified upstream Lua files downloaded 2026-11-14:

- LibDataBroker-1.1 minor 4: https://github.com/tekkub/libdatabroker-1-1
  commit 1a63ede0248c11aa1ee415187c1f9c9489ce3e02. The upstream repository ships
  no separate license file; its README is preserved.
- LibDBIcon-1.0 minor 57: https://repos.wowace.com/wow/libdbicon-1-0/trunk/LibDBIcon-1.0/LibDBIcon-1.0.lua
  License declared by upstream: Ace3 Style BSD,
  https://www.wowace.com/projects/libdbicon-1-0 .
  LICENSE.txt preserves the Ace3 Style BSD notice shown at
  https://www.wowace.com/project/15552/license .

Load CallbackHandler, then LibDataBroker, then LibDBIcon. Both negotiate shared
versions through LibStub; keep their names and source files unchanged in DEV.

SHA-256 libs/LibDataBroker-1.1/LibDataBroker-1.1.lua: `f3d4758f2060215492c9764b1d7dc2a336826d4cd253cd54ff9ff7c6d78f04e2`.

SHA-256 libs/LibDBIcon-1.0/LibDBIcon-1.0.lua: `cafa823dfb9f216eb476af4bcd2fad4c25c718f39b7565fa1c924dbebac41f91`.

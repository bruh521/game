--[[

**DO NOT MIX UP CLIENTREMOTES & SERVERSCRIPTS**

**DO NOT MIX UP CLIENTREMOTES & SERVERSCRIPTS**

**DO NOT MIX UP CLIENTREMOTES & SERVERSCRIPTS**

--   Free Plugins   --

To use, Under ServerStorage.Plugins

1. Right click the one you want
2. Save to file
3. Under Plugins, press plugin Folder
4. Drop inside plugins folder


Current Plugins

 -- Moon Animator 2
 -- DataStore Editor 3


Main -- Serverside main obviously
	Handles remote funcs & events
		calling remotefuncs and events REQUIRE table with string Type
			Example 
			RemoteEvent:FireServer({
			Type = "Teleport", -- TYPE is the function 
			
			})
			
			OR 
			
			RemoteEvent:FireServer({
			Type = "Teleport," -- TYPE IS Function
			OtherValues = 'Spawn' -- OTHER VALUES IF OPTIONAL OR REQUIRED
			})
			
			Same for RemoteFuncs  (RemoteFunction:InvokeServer({
			Type = 'idk' -- required later
			}))
			
			-- YOU CREATE FUNCTIONS FOR REMOTES IN [game.ServerScriptService.ServerScripts.ClientRemotes]
			
	

Config -- config... idk what else to say

DataStores -- We use ProfileService (https://madstudioroblox.github.io/ProfileService/)

StarterPlayerScripts -- main code for that (nothing yet)

ServerMain -- game is heavily module based, most server side modules will be in there

ClientMain -- client funcs idk lol

AttributeHandler -- handles attributes based on function name (case sensitive)



			
]]

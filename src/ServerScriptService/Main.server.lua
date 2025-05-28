local Players = game:WaitForChild("Players")
local Lighting = game:WaitForChild("Lighting")
local ReplicatedFirst = game:WaitForChild("ReplicatedFirst")
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
local ClientScripts = require(ReplicatedStorage:WaitForChild("ClientScripts"):WaitForChild("ClientMain"))
local Remotes = ReplicatedStorage:WaitForChild("Remote")
local RemoteEvent = Remotes:WaitForChild("RemoteEvent")
local ServerStorage = game:WaitForChild("ServerStorage")
local ServerScriptService = game:WaitForChild("ServerScriptService")
local ServerScripts = ServerScriptService:WaitForChild("ServerScripts")
local ServerMain = require(ServerScripts:WaitForChild("ServerMain"))
local StarterChar = ReplicatedStorage:WaitForChild("StarterChar")
local Settings = require(ServerScripts:WaitForChild("Settings"))
local Alive = workspace:WaitForChild("Alive")
local ClientScripts = require(ReplicatedStorage.ClientScripts.ClientMain)
local NPCs = workspace:FindFirstChild("NPCs")
local ClientRemotes = require(ServerScripts:WaitForChild("ClientRemotes"))
local ClientFunctions = require(ServerScripts:WaitForChild("ClientFunctions"))
local startTick = Settings.StartTick
local LatencyFuncTest
-- only if -tick
local function RemoteEVENT()
	Remotes.RemoteEvent.OnServerEvent:Connect(function(plr, arg)
		if ClientRemotes[arg.Type] then -- faster to remove 'Type' and then st leave it?
			ClientRemotes[arg.Type](plr, arg) 
		else
			if Settings.DevMode == true  then
				warn('Didnt set a type OR FUNCTION DOES NOT EXIST FIX: '.. tostring(arg.Type))
			else
				task.wait(math.random(21.51094,100.61))
				plr:Kick("If this is a bug, report it! 35")
			end
		end
	end)
end

local function RemoteFUNCS()
	Remotes.RemoteFunction.OnServerInvoke = function(plr, arg)
		if ClientFunctions[arg.Type] then
			return ClientFunctions[arg.Type](plr,arg)
		else
			if Settings.DevMode == true  then
				warn('Didnt set a type OR FUNCTION DOES NOT EXIST FIX: '.. tostring(arg.Type))
			else
				task.wait(math.random(27.51094,120.61))
				plr:Kick("If this is a bug, report it! 36")
			end
		end
	end
end

local function RemoteFUNCSLATENCYTEST()
	Remotes.RemoteFunction.OnServerInvoke = function(plr, arg)
		if ClientFunctions[arg.Type] then
			local sct = tick()
			return ClientFunctions[arg.Type](plr,arg,sct)
		else
			if Settings.DevMode == true  then
				warn('Didnt set a type OR FUNCTION DOES NOT EXIST FIX: '.. tostring(arg.Type))
			else
				task.wait(math.random(27.51094,120.61))
				plr:Kick("If this is a bug, report it! 36")
			end
		end
	end
end



local function RemoteEVENTLATENCYTEST()
	Remotes.RemoteEvent.OnServerEvent:Connect(function(plr, arg)
		if ClientRemotes[arg.Type] then -- faster to remove 'Type' and then st leave it?
			local sct = tick()
			ClientRemotes[arg.Type](plr, arg,sct)
		else
			if Settings.DevMode == true then
				warn('Didnt set a type OR FUNCTION DOES NOT EXIST FIX: '.. tostring(arg.Type))
			else
				task.wait(math.random(21.51094,100.61))
				plr:Kick("If this is a bug, report it! 35")
			end
		end
	end)
end

 --------------- SERVER STARTUP STUFF ------------------




 -- ENABLE/DISABLE DEV STUFF
if (game:GetService("RunService"):IsStudio() or Settings.ServerSettings.AllowStudioInGame == true) and Settings.ServerSettings.ForceGameSettingsInStudio == false then
	Settings.DevMode = true
	LatencyFuncTest = task.spawn(RemoteEVENTLATENCYTEST)
	LatencyFuncTest = task.spawn(RemoteFUNCSLATENCYTEST)
	----------------------------------------------
else
	--------------------------------------------

	-- remove DevRemotes
local DevRemotes = ClientRemotes.DevRemotes

for DevRemotesI, DevRemoteName in pairs(DevRemotes) do
	ClientRemotes[DevRemotes[DevRemotesI]] = nil
end
--[[local a = require(game.ServerScriptService.ServerScripts.ClientRemotes)
local b = a.DevRemotes

for i, v in pairs(b) do
	print(b[i])
end

for i, v in pairs(workspace.Map.Model:GetDescendants()) do
	if v:IsA("Script") then
		print("Removing " .. v.Name)
		v:Remove()
	end
end
]]

local RemoveEventThread = task.spawn(RemoteEVENT)
local RemoteFuncsThread = task.spawn(RemoteFUNCS)



end



-- Player Startup
local function onCharacterAdded(character)
	--character:WaitForChild("UpperTorso")
	character:WaitForChild("Head")
	character:WaitForChild("Humanoid")
	character:WaitForChild("HumanoidRootPart")
	--workspace:WaitForChild(character.Name)
	ServerMain.SetupCharacter({
		Character = character
	})
end

local function onCharacterRemoving(character)
	print('Character Removing?')
end
--[[	task.wait(character.Humanoid:GetAttribute("RespawnTime"))
	character:GetPlayerFromCharacter():Respawn()]]

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)
	player:LoadCharacter()

end


Players.PlayerAdded:Connect(onPlayerAdded)


for i, v in pairs(NPCs:GetChildren()) do
	if v:FindFirstChild("Dialogue") then
		ServerMain.ActivateDialogue(v)
	end
end

ServerMain.setBouncers()
---------------------------------------------


--[[game.Players.PlayerAdded:Connect(function(plr)
	if plr.Name == 'rjplaysanime' then
		plr:Kick('loser')
	end
end)
]]
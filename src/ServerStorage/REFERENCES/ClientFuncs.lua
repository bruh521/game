
-- bad old code 

local clientFuncs = {}
local Thread = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Thread"))
local workspaceLocations = workspace:WaitForChild("Locations")
local tweenService = game:GetService("TweenService")
local LP = game.Players.LocalPlayer
local curLocation = nil
local Locations = {} 
local LPGui = LP.PlayerGui
local curTrack = nil
local tweenSongTime = 4.3
local songVol = .5
local LocationTracks = nil
local rayParams = RaycastParams.new()
local weatherTween = nil
local weatherTweenTime = 3
local Lighting = game:GetService("Lighting")
function clientFuncs.createLocationTracks()
	LocationTracks = Instance.new("Folder")
	LocationTracks.Name = "LocationTracks"
	LocationTracks.Parent = LP.Character
	rayParams.FilterType = Enum.RaycastFilterType.Include -- Whitelist is the same why!!!! (is it cause it has the word white in it real and black @obssa33)
	rayParams.FilterDescendantsInstances = Locations 
end

function clientFuncs.setLocations()
	Locations = {}
	for _,v in pairs(workspace.Locations:GetChildren()) do
		table.insert(Locations,v)

	end
end
function clientFuncs.MusicPlayer(tracks)
	if LocationTracks:FindFirstChild("BGM") then
		local startTime = tick()
		local LocationBGM = LocationTracks.BGM
		tweenService:Create(LocationBGM,TweenInfo.new(tweenSongTime-.1,Enum.EasingStyle.Quad),{
			Volume = 0
		}):Play()
		repeat
			task.wait(.1)
		until LocationBGM.Volume == 0 or tick() >= startTime + 5
		LocationBGM:Remove()
	end	
	local randomSongI 
	local song 
	repeat 
		randomSongI = math.random(1,#tracks:GetChildren())
		song = tracks:GetChildren()[randomSongI]:Clone()
	until song.soundId ~= curTrack or #tracks:GetChildren() <=1
	curTrack = song.SoundId 
	song.Name = "BGM"
	if LocationTracks:FindFirstChild("BGM") then 
		LocationTracks.BGM:Remove()
	end
	song.Parent = LocationTracks
	tweenService:Create(song,TweenInfo.new(tweenSongTime,Enum.EasingStyle.Quad),{
		Volume = songVol
	}):Play()
	song:Play()
	song.Ended:Connect(function()
		song:Remove()
		clientFuncs.MusicPlayer(tracks)
	end)
	LocationTracks.DescendantRemoving:Connect(function(obj)
		if obj.Name == "BGM" then
			return
		end
	end)

end


function clientFuncs.DetermineLocation()
	curTrack = nil
	curLocation = nil
	local Head = LP.Character.Head
	while true do
		if not LPGui:FindFirstChild('LocationGui') then
			local rayResult = workspace:Raycast(Head.Position, Vector3.new(0, 10000, 0), rayParams)
			if rayResult then
				local rayInstance = rayResult.Instance
				if curLocation ~= rayInstance.Name then
					curLocation = rayInstance.Name
					if rayInstance:FindFirstChild("LocationGui") then
						rayInstance.LocationGui:Clone().Parent = LPGui
						-- finally holy shit so many checks
						-- update lighting and music shit

			
						-- music!
						if rayInstance:FindFirstChild("Songs") then
							local Tracks = rayInstance:FindFirstChild("Songs")

							task.wait()
							clientFuncs.MusicPlayer(Tracks)
						end

						---
						local LStuff = {}
						
						if rayInstance:FindFirstChild("Lighting") then
							LStuff.Lighting = rayInstance.Lighting
						end
						clientFuncs.updateLighting(LStuff)
					end
				end
			end
		end
		task.wait(.511062061104865195456718984597435763458765438764531786343518762345387162345378613425308791634235870631453987634501387963450587364581786430451786234578634578602345786344578763245788567342935876453745876458348725967845873462457598789292345984797225739974292938547798723296355727645378426596287654367864305863148756348057364587036458730645087604837633485569838734496855967382579498273924534987742534987225839872982344598779824545897987279875764535424588763452957863458247865345987634475587634985248767534589782634547578623489458576723894573249857258298191657809167567865745643654365346543654653434566593465019864534815932859751419958191976)
	end

end
function clientFuncs.updateLighting(...)
	local info = ... or {}
	if info.Lighting ~= nil then
		local SetTo = {}
		for i, v in pairs(info.Lighting:GetChildren()) do
		SetTo[v.Name] = v.Value
		end
		
		weatherTween = tweenService:Create(Lighting, TweenInfo.new(weatherTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), SetTo)

		weatherTween:Play()
		-- ADD DEFAULT IF NOTHING! FIX!
	end
end
function clientFuncs.ReturnToZero()
	for i, v in pairs(workspaceLocations:GetDescendants()) do
		if v:IsA("Sound") then
			v.Volume = 0
		end
	end
end
function clientFuncs.playerDied()
	curTrack = nil
	curLocation = nil
	if LP.Character:FindFirstChild("LocationTracks") then
		if LP.Character.LocationTracks:FindFirstChild("BGM") then 
			tweenService:Create(LP.Character.LocationTracks.BGM,TweenInfo.new(game.Players.RespawnTime-.01,Enum.EasingStyle.Quad),{
				Volume = 0
			}):Play()
		end
	end
	
	
end

function clientFuncs.gambl()
	game.ReplicatedStorage.Remotes.RemoteEvent:FireServer({
		Type = 'gambl',
	})
	print('yay work')
end




return clientFuncs
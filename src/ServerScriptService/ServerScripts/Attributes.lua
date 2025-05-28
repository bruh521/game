local module = {}


function module.AddWalkSpeed(plr,info)
  local CharHum = plr.Character:FindFirstChild("Humanoid") 
  local NewSpeed = CharHum:GetAttribute("WalkSpeed")+info.Speed
  CharHum:SetAttribute("WalkSpeed",NewSpeed)
  if info.Duration ~= nil then
    task.wait(info.Duration)
    CharHum:SetAttribute("WalkSpeed",CharHum:GetAttribute("WalkSpeed")-info.Speed)
  end
end
--[[
local Attributes = require(game.ServerScriptService.ServerScripts.Attributes)
Attributes.AddWalkSpeed(game.Players.DeanNoobLeader,{
    ["Speed"] = 300,
    ["Duration"] = 5,
})
    ]]

function module.AddJumpHeight(plr,info)
  local CharHum = plr.Character:FindFirstChild("Humanoid") 
  local NewSpeed = CharHum:GetAttribute("JumpHeight")+info.Speed
  CharHum:SetAttribute("JumpHeight",NewSpeed)
  if info.Duration ~= nil then
    task.wait(info.Duration)
    CharHum:SetAttribute("JumpHeight",CharHum:GetAttribute("JumpHeight")-info.Speed)
  end
end


























return module

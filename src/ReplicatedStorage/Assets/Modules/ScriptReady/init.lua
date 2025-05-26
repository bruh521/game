local scriptReady = {}

function scriptReady:Get()
	local Ready = script.Ready:Clone()
	local LP,Char,Hum,HRP = require(Ready).Ready()
	Ready:Destroy()
	
	return LP,Char,Hum,HRP
end

return scriptReady
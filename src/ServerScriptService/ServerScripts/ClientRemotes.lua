local module = {}

module.DevRemotes = {
	'ChangeMove',
	'LatencyTest', -- lets client change a move
}
function module.LatencyTest(plr,info,fst)
    local NumMult = 100
	local ServerTick = tick()
	local ClientTick = info.ClientTick
	local FirstServerTick = fst
print(ServerTick)
print(ClientTick)
print(FirstServerTick)
    print('-------------------------------------------------------------------------')
    print("\n\n\n\n")
    print("NUMBERS ARE *100 FOR READABILITY")
	print("Time from client to first server: ".. (FirstServerTick-ClientTick)*NumMult)
	print("Time from FirstServer to Server: ".. (ServerTick-FirstServerTick)*NumMult)
	print("Total time from client to last server: ".. (ServerTick-ClientTick)*NumMult)
end
return module

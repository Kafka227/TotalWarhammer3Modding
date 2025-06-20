local wbfs = core:get_static_object("kafka_wbfs")

function wbfs:log(str)
    if not wbfs:getConfigEnableLogging() then
        return
    end
	local logFile = io.open("kafka.txt", "a")
	if (logFile == nil) then
		return
	end
	logFile:write("[wbfs] " .. str .. "\n")
	logFile:flush()
	logFile:close()
end
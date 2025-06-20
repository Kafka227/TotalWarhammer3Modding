local rfpo = core:get_static_object("kafka_rfpo")

function rfpo:log(str)
    if not rfpo.settings.debug_internal then
        return
    end
	local logFile = io.open("kafka.txt", "a")
	if (logFile == nil) then
		return
	end
	logFile:write("[rfpo] " .. str .. "\n");
	logFile:flush();
	logFile:close();
end
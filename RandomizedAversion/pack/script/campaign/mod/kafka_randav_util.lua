local ranav = core:get_static_object("kafka_randomized_aversion")

function ranav:log(str)
    if not ranav.settings.debug_internal then
        return
    end
	local logFile = io.open("kafka.txt", "a")
	if (logFile == nil) then
		return
	end
	logFile:write("[ranav] " .. str .. "\n");
	logFile:flush();
	logFile:close();
end
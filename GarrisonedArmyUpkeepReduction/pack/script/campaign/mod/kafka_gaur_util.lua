local gaur = core:get_static_object("gaur")

function gaur:log(str)
    if not gaur.settings.debug_internal then
        return
    end
	local logFile = io.open("kafka.txt", "a")
	if (logFile == nil) then
		return
	end
	logFile:write("[gaur] " .. str .. "\n");
	logFile:flush();
	logFile:close();
end
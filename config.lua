--
-- config.lua
--
-- Define basic configuration, and load extra configuration from file
--
print("config: loading");

config = {
	-- Some reasonable defaults for NodeMCU
	pin_hello = 4,
	pin_button = 3,
}

-- config_update - Given a JSON string, parse it and merge into current config
function config_update(json)
	local new_cfg = cjson.decode(json)
	for k,v in pairs(cfg) do config[k]=v end
	return true
end

-- Read a file containing JSON (if present) and merge it into current config
function read_config(filename)
	if not file.exists(filename) then returen false end
	print("config: reading "..filename);
	local buf = '';
	file.open(filename , "r")
	local result = config_update(file.read()) -- FIXME will only read 1024 bytes max
	file.close()
	return result
end

read_config('config.json')
read_config('credentials.json')
print("config: done");

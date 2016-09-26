--
-- app.lua
--
-- Begin the application.
--
-- This is the first file loaded by init.lua and it does the following
--
-- If init.lua is missing/disabled, load this file using your IDE to start the application
--
-- This file initiates:
--		Load the configuration
--		Set up basic Input/Output
--		Load Wifi
--		Load MQTT once wifi is ready (if needed)
--		Load the application program itself once MQTT is ready
--
--
print "app: loading"

-- Read configuration (will parse config.json if present, max size 1kB)
dofile("config.lua")
-- Set up IO pins
dofile("iosetup.lua");

-- event-ready - this is called when the IoT core is ready to pass control to the application
function event_ready()
	local app = config.application_name
	if (app) then
		dofile(app..".lua")
		node.input(app.."_start()")
	end

	-- Now change the hello-world  LED to a
	-- 2-second flash to signify application has started
	tmr.interval(0, 1000)
	print("app: ready");
end

-- event_wifi_ready - A callback for when the WiFi has connected
function event_wifi_ready(ip)
	-- This callback resumes initialsation after WiFi is connected.
	-- If MQTT is configured, load and initialise this, otherwise skip
	-- direct to application start.

	-- Change the hello-world  LED to a
	-- 1-second flash to signify WiFi has connected
	flash_hello(500)

	-- Load the slack library if slack is configured
	if config.slack_webhook_url or config.slack_mqtt_topic then dofile("slack.lua") end

	-- Load the MQTT library if MQTT is configure
	if config.mqtt_server then
		--
		-- Load the MQTT client and initiate connection.
		-- This will call back to event_app_ready when ready
		--
	   event_mqtt_ready = event_ready
	   dofile("mqtt.lua")
	else
		--
		-- We're not using MQTT, move directly to loading
		-- the application
		--
		event_ready()
	end

end

-- Now, load the WiFi library and return to the above callback when connected
dofile("wifi.lua")

print "app: loaded"

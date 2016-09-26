--
-- mqtt.lua
--
-- Connect to an MQTT message-queue server,
-- and call back to event_mqtt_ready() when connected.
--
print("mqtt: loading")

mqtt_client = nil
mqtt_online = false
mqtt_timer = 3
mqtt_client_id = config.mqtt_client_id or string.gsub(wifi.sta.getmac(),':','')
mqtt_client_topic = "clients/"..mqtt_client_id
mqtt_subscriptions = {}

-- mqtt_on_disconnect - called when connection is lost to MQTT server
-- This will get triggered if deep sleep is enabled, so ignore it in that instance
function mqtt_on_disconnect(client)
	print ("mqtt: offline")
	mqtt_online = false
	if (have_ip and not config.use_dsleep) then
		-- Initiate reconnection
		mqtt_connect()
	end
end

-- mqtt_on_connect - called when a successful connection to the MQTT server is established
function mqtt_on_connect(client)
	print("mqtt: connected")
	mqtt_online = true

	-- Set up a heartbeat monitor that will reboot if connection is lost and auto-recovery fails
	mqtt_subscribe("system/time", 0, mqtt_on_heartbeat)
	mqtt_on_heartbeat()

	-- Publish a message indicating this device is online,
	-- then pass control to application ready callback.
	mqtt_client:publish(
		mqtt_client_topic, have_ip, 0, 1,
		function() -- publish success callback
			print("mqtt: ready")
			if event_mqtt_ready then
			   print("mqtt: invoking application mqtt ready callback")
			   event_mqtt_ready()
			end
		end
	)
end

-- mqtt_on_connectfail - If connection fails, wait 30 seconds and retry
function mqtt_on_connectfail(client, reason)
	print("mqtt: connection failed: "..reason)
	if (have_ip) then
		tmr.alarm(mqtt_reconnect_timer, 30000, tmr.ALARM_SINGLE, mqtt_connect)
	end
end

-- mqtt_match_topic - Perform a wildcard match on subscription patterns, for dispatching messages
function mqtt_match_topic(topic, pattern)
	-- TODO implement wild cards
	return topic == pattern
end

-- mqtt_no_heartbeat - we have lost connection with the server, and retry failed.  Reboot.
function mqtt_no_heartbeat()
	print "mqtt: no heartbeat, rebooting"
	node.restart()
end

-- mqtt_on_heartbeat - extend the time until we consider the server connection lost
function mqtt_on_heartbeat()
	-- Set an alarm to reboot in a few minutes if no heartbeat was received
	-- Loss of heartbeat can mean that the wifi auto-reconnect has failed due to flaky AP
	-- Could also mean server is down, so don't make the timeout too short
	tmr.alarm(2, config.mqtt_watchdog or 10*60*1000, tmr.ALARM_SINGLE, mqtt_no_heartbeat)
end

-- mqtt_on_mesage - called when a message is received.
-- Search the subscription dispatch table to find the first appropriate callback function.
function mqtt_on_message(conn, topic, data)
	print("mqtt: receive message "..topic.." <= "..data)
	for pattern,callback in pairs(mqtt_subscriptions) do
		if mqtt_match_topic(topic, pattern) then
			print("mqtt: callback for pattern "..pattern)
			callback(conn, topic, data)
			break
		end
	end
end

-- mqtt_subscribe - subscribe to a topic and register a
-- callback function to which messages are routed
function mqtt_subscribe(topic, qos, callback)
	print("mqtt: register subscription for topic "..topic)
	-- Save the callback for topic in the dispatch table
	mqtt_subscriptions[topic]=callback
	-- Subscribe to the topic
	mqtt_client:subscribe(topic, qos)
end

--mqtt_publish - publish a message on a topic, and invoke a callback (optional) when complete
function mqtt_publish(topic, message, qos, retain, callback)
	print("mqtt: publish message on topic "..topic.." => "..message)
	return mqtt_client:publish(
		topic,
		message,
		qos or 0,
		retain or 0,
		callback or function() print("mqtt: publish complete") end
	)
end

-- mqtt_setup - create an MQTT client and set up event handlers
function mqtt_setup()
	print("mqtt: setup")

	-- Create an MQTT client object
	mqtt_client=mqtt.Client(mqtt_client_id, 120, config.mqtt_user, config.mqtt_pass)


	-- Set up callbacks for the MQTT client object
	mqtt_client:lwt(mqtt_client_topic, "0", 0, 1)
	mqtt_client:on("connect", mqtt_on_connect)
	mqtt_client:on("offline", mqtt_on_disconnect)
	mqtt_client:on("message", mqtt_on_message)
end

-- mqtt_connect - initiate connection to the MQTT server
function mqtt_connect()
	print("mqtt: connecting")
	flash_hello(500)
	mqtt_client:connect(
		config.mqtt_server,
		config.mqtt_port,
		config.mqtt_secure,
		config.mqtt_autoreconnect,
		function(client) -- connection success callback
			print("mqtt: why are there two success callbacks?")
		end,
		function(client, reason) -- connection failure callback
			print("mqtt: connection failed reason: "..reason)
		end
	)
end

mqtt_setup()
mqtt_connect()

print("mqtt: done")

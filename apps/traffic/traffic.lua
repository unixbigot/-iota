-- Project status display using WS2812 "traffic light"
print("traffic: begin")

traffic_colour = nil  -- current colour
traffic_state = nil   -- current mode, 'on', 'off', or 'flash'

traffic_on = true; -- current state if flashing
traffic_colours = { -- GRB
	off = string.char(0,0,0,0,0,0,0,0,0),
	red = string.char(0,0,0,0,0,0,0,255,0),
	amber = string.char(0,0,0,126,255,0,0,0,0),
	green = string.char(255,0,0,0,0,0,0,0,0)
}

-- set_traffic_colour - set the colour (and optionally state) of the LEDs
function set_traffic_colour(colour, state)
	traffic_colour = colour
	traffic_state = state or 'on'
end

-- traffic_receive - callback from MQTT when a message is received
function traffic_receive(conn, topic, data)
	print("traffic: received "..topic.." <= "..data);

	-- Interpret either colour names or status names as colours, and update the settings
	if data=="red" or data=="danger" then
		set_traffic_colour('red')
	elseif data=="amber" or data == "yellow" or data=="warning" then
		set_traffic_colour('amber')
	elseif data=="green" or data=="good" then
		set_traffic_colour('green')
	else
		print("traffic: Unrecognized status: "..data)
		set_traffic_colour('amber', 'flash')
	end
end

-- traffic_alarm - 1 second event to implement flashing and changes of colour
function traffic_alarm()
	-- print("traffic_alarm state="..traffic_state.." colour="..traffic_colour)

	-- Look up what colour we are showing from the table, and then take
	-- flashing into account if enabled.
	local triplet = traffic_colours[traffic_colour]
	if traffic_state == 'flash' then
		if traffic_on then triplet = traffic_colours.off end
		traffic_on = not traffic_on
	elseif traffic_state == 'off' then
		triplet = traffic_colours.off
	end

	-- Send the desired colours to the LED string
	ws2812.write(triplet)
end

-- traffic_start - initially flash until a message is received from the server
--
-- Subscribe to receive project status.
--
-- You should use retained messages on the server so that the device receives the
-- current status as soon as it subscribes.
function traffic_start()
	print("traffic: start")
	set_traffic_colour('amber', 'flash')
	mqtt_register("projects/"..(config.traffic_project or "+").."/status", 0, traffic_receive)
	tmr.alarm(3, 1000, tmr.ALARM_AUTO, traffic_alarm)
end

print("traffic: done")

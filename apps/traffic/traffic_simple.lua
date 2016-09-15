-- Project status display using WS2812 "traffic light"
print("traffic: begin")

-- This is the simplest possible implementation, without any flashing.

-- traffic_simple_receive - when a status or colour is received, send it to LEDs immediately
function traffic_simple_receive(conn, topic, data)
	print("traffic: received "..topic.." <= "..data);

	-- Remember WS2812 toakes a string of Green-Red-Blue values
	if data=="red" or data=="danger" then
		ws2812.write(string.char(0,0,0,0,0,0,0,255,0))
	elseif data=="amber" or data == "yellow" or data=="warning" then
		ws2812.write(string.char(0,0,0,126,255,0,0,0,0))
	elseif data=="green" or data=="good" then
		ws2812.write(string.char(255,0,0,0,0,0,0,0,0))
	else
		print("traffic: Unrecognized status: "..data)
	end
end

-- traffic_simple_start - register to receive changes of status
function traffic_simple_start()
	print("traffic: start")
	mqtt_register("projects/"..(config.traffic_project or "+").."/status", 0, traffic_simple_receive)
end

print("traffic: done")

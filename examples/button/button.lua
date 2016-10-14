print("button_meeting: loading")

button_state = 'idle'
button_alarm = false

button_topic = "teams/"..config.button_team.."/meeting"

-- event_button - this is called by the button service whenever the button is pushed
function button_event(level)
	print("button: event level="..level)
    if level == 1 then return end -- ignore button up events

	if (button_state == 'idle') then
		-- initiate a meeting
		button_initiate()
	else
	    -- We are called to a meeting, acknowledge
		button_acknowledge()
	end
end

function button_initiate()
	print("button: initiate")
	slack(config.button_message)
    mqtt_publish(button_topic, "1")
	button_alarm_start('called')
end

function button_acknowledge()
	print("button: ack")
	slack(config.button_acknowledge)
	button_alarm_stop()
    if button_state == 'called' then
        mqtt_publish(button_topic, "0")
    end
    button_state = 'idle'
end

-- button_receive - called when an MQTT message arrives on a topic to which we subscribe
function button_receive(conn, topic, data)
    print("button: receive "..data)
    if (data == "1") then
		button_alarm_start('invited')
	else
		button_alarm_stop()
	end
end

function button_alarm_on()
    print "button: alarm_on"
	gpio.write(config.pin_alarm, 1)
	button_alarm = true
end

function button_alarm_off()
    print "button: alarm_off"
	gpio.write(config.pin_alarm, 0)
	button_alarm = false
end

function button_alarm_start(reason)
    print("button: alarm_start " .. reason)
	button_alarm_on()
	tmr.alarm(3, 500, tmr.ALARM_AUTO, button_alarm_flash)
    button_state = reason or 'invited'
end

function button_alarm_stop()
    print "button: alarm_stop"
	tmr.stop(3)
	button_alarm_off()
	button_state = 'idle'
end

function button_alarm_flash()
	if button_state ~= 'alarm' then return end
    print("button: flash")
	if button_alarm then
		button_alarm_off()
	else
		button_alarm_on()
	end
end

function button_start()
	print("button: start")
	-- Ask the button service to call our function every time the button is pressed
	gpio.mode(config.pin_alarm, gpio.OUTPUT);
	button_alarm_stop()
	register_button(config.pin_button, "down", button_event)
	mqtt_subscribe(button_topic, 0, button_receive)
    print("button: ready\n")
end

print "button_meeting: loaded"

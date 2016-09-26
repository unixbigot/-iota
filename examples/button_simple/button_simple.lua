print("button_simple: loading")

-- event_button - this is called by the button service whenever the button is pushed
function event_button(level)
	print("Button press")
	slack(config.button_message);
end

function button_simple_start()
	-- Ask the button service to call our function every time the button is pressed
	register_button(config.pin_button, "down", event_button)
end

print "button_simple: loaded"

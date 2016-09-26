--
-- iosetup.lua
--
-- This file configures what pins are used,
-- and sets up the ESP Module's status LED to blink at varying rates
--
--
print("iosetup: loading")

--
-- Configure the diagnostic "hello world" LED to use timer zero
--
-- Every time timer 0 expires, invert the state of the status LED
--
-- 100ms cycle -- waiting for WiFi
-- 1s    cycle -- ready
--

hello_state = 0
function event_hello()
	if not config.pin_hello then return end;
	if hello_state == 1 then
		hello_state = 0
		gpio.write(config.pin_hello, gpio.LOW)
	else
		hello_state = 1
		gpio.write(config.pin_hello, gpio.HIGH)
	end
	--print("hello_state now "..hello_state)
end

function flash_hello(rate)
	print("iosetup: flash_hello "..rate)
	if not config.pin_hello then return end;
	tmr.stop(0)
	if (rate > 0) then
		tmr.alarm(0, rate, tmr.ALARM_AUTO, event_hello)
	end
end

function stop_hello()
	print("iosetup: stop_hello")
	if not config.pin_hello then return end;
	tmr.stop(0)
	hello_state=1
	gpio.write(config.pin_hello,gpio.HIGH)
end

if config.pin_hello then
	print("iosetup: diagnostic 'hello world' LED on pin "..config.pin_hello)
	gpio.mode(config.pin_hello, gpio.OUTPUT)
	flash_hello(100)
end

--
-- Configure basic button support
--
if config.pin_button then
  print("iosetup: button on pin "..config.pin_button)
  gpio.mode(config.pin_button, gpio.INT, gpio.PULLUP)
end

button_registry = {}

function button_dispatch(pin, level)
    print("iosetup: button_dispatch pin="..pin.." level="..level)
	-- Get the control record for this pin
	button_info = button_registry[pin];
	local debounce_delay = (config.button_debounce or 100) * 1000

	-- Ignore duplicate events in rapid succession, mechaninical switches can "bounce" for a few milliseconds
	if (button_info.last_event and (tmr.now() - button_info.last_event) < debounce_delay) then return end

	button_info.callback(level)
end

function register_button(pin, trigger, callback)
    print("iosetup: register_button pin="..pin.." trigger="..trigger)
	if callback then
		-- Set up delivery of button events
		button_registry[pin] = {["callback"] = callback}
		gpio.trig(pin, trigger, function(level) button_dispatch(pin, level) end)
	else
		-- Cancel delivery of button events
		gpio.trig(pin, "none")
		button_registry[pin] = nil
	end
end

--
-- Configure 'neopixel' addressable LED support
--
if config.pin_ws2812 then
  print("iosetup: WS2812 LED string on pin"..config.pin_ws2812) -- actually only on pin 4
  ws2812.init()
end




print("iosetup: loaded")

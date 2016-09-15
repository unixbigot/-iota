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
-- Configure basic IO pins
--
if config.pin_button then 
  print("iosetup: button on pin "..config.pin_button)
  gpio.mode(config.pin_button, gpio.INT, gpio.PULLUP) 
end

if config.pin_ws2812 then 
  print("iosetup: WS2812 LED string on pin"..config.pin_ws2812) -- actually only on pin 4
  ws2812.init()
end




print("iosetup: loaded")

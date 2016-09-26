--
-- init.lua
--
-- the NodeMCU firmware loads and executes this file at startup.
--
-- This file waits for a brief time, then loads another file (app.lua).
--
-- The wait is so that if your code ends up in a crash loop,
-- you have a way to escape to the command prompt.
--

--
-- First, set the serial port configuration to the defacto standard
--							115200bps, 8-bits, no parity, 1 stop bit.
-- This is the normal speed used by most serial IoT boards.
--
-- The NodeMCU firmware may use a different speed to output
-- some debug information, so you may see a burst of gibberish at startup.

uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)

--
-- Second, wait a short time and load the application program.
-- You can type "tmr.stop(0)" during the wait to cancel application startup.
--
print("\n\n")
print("Manfred - IoT made easy.  https://github.com/unixbigot/manfred\n")
print("Starting app in 5 seconds.  Type tmr.stop(0) to abort.\n\n")
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function() print("\ninit: loading app"); dofile("app.lua") end)

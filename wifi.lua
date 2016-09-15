---
--- wifi.lua
---
--- Generic code for setting up the wifi module in the ESP8266.
--- This is shared by many of my projects, control is returned to
--- application logic via a callback named event_wifi_ready() which is
--- triggered when the device receives an IP address from DHCP
---
--- When this file is load it commences scanning for networks.
--- If a network is seen that is in the config.wifi_passwords table,
--- then that network is joined.
---

print("wifi: loading")

-- State flags
joined_ap = false
have_ip = false

---
-- Set the wifi in station mode and configure callbacks for all state changes
---
wifi.setmode(wifi.STATION)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("wifi: no AP found") end)
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("wifi: idle") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("wifi: connecting") end)

wifi.sta.eventMonReg(wifi.STA_WRONGPWD,
	function()
		-- This is called when a network login fails
		print("wifi: wrong password")
		joined_ap=nil
	end
)

wifi.sta.eventMonReg(wifi.STA_FAIL,
	function()
		-- This is called when a network connection fails
		print("wifi: connection failed")
		joined_ap = nil
		seek_ap()
	end
)

wifi.sta.eventMonReg(wifi.STA_GOTIP,
	function()
		-- This is called when an IP address is obtained.
		-- Control passes to event_wifi_ready()
		ip=wifi.sta.getip()
		if ip then
			print("wifi: got IP="..ip)
			joined_ap = true
			have_ip=ip
			if event_wifi_ready then event_wifi_ready(ip) end
		end
	end
)

wifi.sta.eventMonStart()

--
-- list_ap() - this is the callback for the 'getap' operation, it
-- receives a list of discovered networks and attempts to
-- join the first one that it recognises.
--
function list_ap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
	print("\n"..string.format("%32s","SSID").."\tBSSID\t\t\t\t	RSSI\t\tAUTHMODE\tCHANNEL")
	for ssid,v in pairs(t) do
		local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
		print(string.format("%32s",ssid).."\t"..
				  bssid.."\t	"..rssi.."\t\t"..authmode.."\t\t\t"..channel)
		if not joined_ap and config.wifi_passwords[ssid] then
			print("wifi: joining "..ssid)
			joined_ap=ssid
			wifi.sta.config(ssid, config.wifi_passwords[ssid]);
			wifi.sta.connect()
		end
	end
	if not joined_ap then
		print "wifi: No networks found, trying again in 5 seconds"
		tmr.alarm(1, 5000, tmr.ALARM_SINGLE, seek_ap)
	end
end

--
-- seek_ap() - initiate an Access Point scan, and call list_ap with the result
--
function seek_ap()
	if joined_ap then return end
	print "wifi: looking for networks"
	wifi.sta.getap(list_ap)
end

seek_ap()
print("wifi: loaded")

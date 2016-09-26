---
--- slack.lua
---
--- SLACK incoming webhook interface
---
print("slack: loading")


-- Set fake_slack true to print what would be sent, but send nothing
fake_slack = true


-- slack()
--
-- Simple function to send a message to a slack channel
--
function slack(msg, channel, user, emoji)
	print('slack: posting '..msg)

	local function rcv(sck,c) print("RCV: "..c) end
	local post_headers=	   "Content-Type: application/json\r\n"
	local message = {
		channel = channel or config.slack_channel or "#general",
		username = user or config.slack_user or "nodemcu",
		icon_emoji = emoji or config.slack_emoji or ":vertical_traffic_light:",
		text = msg,
		mrkdwn = true
	}
	local post_body = cjson.encode(message)
	if message['icon_emoji'] == 'none' then message['icon_emoji']=nil end

	if config.fake_slack or (config.slack_webhook_url==nil and config.slack_mqtt_topic==nil) then
		print("slack: FAKE POST: "..post_body)
		return
	end


	if config.slack_webhook_url then
		print("Post URL  = "..config.slack_webhook_url)
		print("Post hdrs = "..post_headers)
		print('Post body = '..post_body)
		http.post(config.slack_webhook_url, post_headers, post_body,
			function(code, data)
				if (code < 0) then
					print("slack: HTTP request failed: code "..code)
				else
					print("slack: received response: ", code, data)
				end
			end
		)
	elseif config.slack_mqtt_topic then
		-- Around mid Sept 2016 Slack's SSL proposals stopped working with NodeMCU
		-- Until I can fix this, I made a workaround to support posting to slack via MQTT
		print("Slack via MQTT: "..post_body)
		mqtt_publish(config.slack_mqtt_topic, post_body)
	end

end
print "slack: loaded"

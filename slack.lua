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
	print('Slacking '..msg)

	local function rcv(sck,c) print("RCV: "..c) end
	local post_headers=	   'Content-Type: application/json\r\n'
	local message = {
		channel = channel or config.slack_channel or "#iot",
		username = user or config.slack_user or "nodemcu",
		icon_emoji = emoji or config.slack_emoji or ":vertical_traffic_light:",
		text = msg,
		mrkdwn = true,
	}
	local post_body = cjson.encode(message)

	if config.fake_slack or not config.slack_webhook_url then
		print("FAKE SLACK: "..post_body)
		return
	end

	http.post(config.slack_webhook_url, post_headers, post_body,
		function(code, data)
			if (code < 0) then
				print("slack: HTTP request failed: code "..code)
			else
				print("slack: received response: ", code, data)
			end
		end
	)
end
print "slack: loaded"

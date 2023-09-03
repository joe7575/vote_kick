local tempbans = {}

local function chat_send_miniminer(msg)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if minetest.check_player_privs(name, "miniminer") then
			minetest.chat_send_player(name, msg)
		end
	end
end

minetest.register_on_prejoinplayer(function(name, ip)
	if tempbans[name] or tempbans[ip] then
		return "You are temporarily banned"
	end
end)

minetest.register_on_joinplayer(function(ObjectRef, last_login)
	-- Stop mute a player (see: miniminer/init.lua)
	ObjectRef:get_meta():set_string("muted", nil)
end)

-- Ban a player until the next server start
minetest.register_chatcommand("vote_ban", {
	privs = {
		miniminer = true,
	},
	func = function(name, param)
		if not minetest.get_player_by_name(param) then
			minetest.chat_send_player(name, "There is no player called '" ..
					param .. "'")
			return
		end
		if minetest.check_player_privs(param, "miniminer") then
			minetest.chat_send_player(name, 
				"Players with miniminer privs cannot be banned")
			return
		end

		vote.new_vote(name, {
			description = "Ban " .. param,
			help = "/yes,  /no  or  /abstain",
			name = param,
			duration = 60,
			perc_needed = 0.8,

			on_result = function(self, result, results)
				if result == "yes" then
					chat_send_miniminer("Vote passed, " ..
							#results.yes .. " to " .. #results.no .. ", " ..
							self.name .. " will be temporarily banned.")
					local ip = minetest.get_player_ip(self.name) or "0"
					tempbans[ip] = true
					tempbans[self.name] = true
					minetest.kick_player(self.name, "The vote to ban you passed")
				else
					chat_send_miniminer("Vote failed, " ..
							#results.yes .. " to " .. #results.no .. ", " ..
							self.name .. " remains ingame.")
				end
			end,

			on_vote = function(self, name, value)
				chat_send_miniminer(name .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

-- Mute a player until he rejoins (see: miniminer/init.lua)
minetest.register_chatcommand("vote_mute", {
	privs = {
		miniminer = true,
	},
	func = function(name, param)
		if not minetest.get_player_by_name(param) then
			minetest.chat_send_player(name, "There is no player called '" ..
					param .. "'")
			return
		end
		if minetest.check_player_privs(param, "miniminer") then
			minetest.chat_send_player(name, 
				"Players with miniminer privs cannot be muted")
			return
		end

		vote.new_vote(name, {
			description = "Mute " .. param,
			help = "/yes,  /no  or  /abstain",
			name = param,
			duration = 60,
			perc_needed = 0.8,

			on_result = function(self, result, results)
				if result == "yes" then
					chat_send_miniminer("Vote passed, " ..
							#results.yes .. " to " .. #results.no .. ", " ..
							self.name .. " will be temporarily muted.")
					minetest.get_player_by_name(self.name):get_meta():set_string("muted", "true")
				else
					chat_send_miniminer("Vote failed, " ..
							#results.yes .. " to " .. #results.no .. ", " ..
							self.name .. " remains talkative.")
				end
			end,

			on_vote = function(self, name, value)
				chat_send_miniminer(name .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

-- Kick a player
minetest.register_chatcommand("vote_kick", {
	privs = {
		miniminer = true,
	},
	func = function(name, param)
		if not minetest.get_player_by_name(param) then
			minetest.chat_send_player(name, "There is no player called '" ..
					param .. "'")
			return
		end
		if minetest.check_player_privs(param, "miniminer") then
			minetest.chat_send_player(name, 
				"Players with miniminer privs cannot be kicked")
			return
		end

		vote.new_vote(name, {
			description = "Kick " .. param,
			help = "/yes,  /no  or  /abstain",
			name = param,
			duration = 60,
			perc_needed = 0.8,

			on_result = function(self, result, results)
				if result == "yes" then
					chat_send_miniminer("Vote passed, " ..
							#results.yes .. " to " .. #results.no .. ", " ..
							self.name .. " will be kicked.")
					minetest.kick_player(self.name, "The vote to kick you passed")
				else
					chat_send_miniminer("Vote failed, " ..
							#results.yes .. " to " .. #results.no .. ", " ..
							self.name .. " remains ingame.")
				end
			end,

			on_vote = function(self, name, value)
				chat_send_miniminer(name .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

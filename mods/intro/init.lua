-- intro mod

intro = {}

-- set to true to enable non-random spawn points for medium to large servers

-- alternatively, use "true" to

intro.use_random_spawn_point = false

-- hardcoded, feel free to change them as you please

intro.audiofile = "solar_plains_intro"

intro.spawn_x = 0
intro.spawn_y = 20
intro.spawn_z = 0

local title_entity = {

	visual = "mesh",
	mesh = "intro_1.x",
	textures = {"intro_title.png", "intro_title_start.png"},
	visual_size = {x=1, y=1},
	player_id = nil,
	timer = 0
}

function title_entity:on_step(dtime)
	
	local entities = minetest.get_objects_inside_radius(self.object:get_pos(), 0.1)
	
	if entities[1] == nil then self.object:remove() return end
	
	if entities[1]:is_player() == true then
	
		self.player_id = entities[1]
	
	end
	
	if entities[2] == nil then self.object:remove() return end
	
	if entities[2]:is_player() == true then
	
		self.player_id = entities[2]
	
	end
	
	if self.player_id == nil or self.player_id:get_attribute("intro_completed") == "true" then self.object:remove() return end
		
	self.player_id:set_look_vertical(0)
	self.player_id:set_look_horizontal(0)
	
	if self.player_id:get_player_control().sneak then
		intro.hud_bg(self.player_id)
		hud.custom_hud(self.player_id)
		self.player_id:set_detach()
		self.player_id:set_attribute("core_display_hud", "true")
		self.player_id:set_attribute("intro_completed", "true")
		intro.teleport_on_sneak(self.player_id)
		hudclock.display_bg(self.player_id)
		self.player_id:hud_set_flags({crosshair = true, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
		self.object:remove()
		
	end
	
	self.timer = self.timer + dtime
	
	if self.timer > 25 then
		intro.hud_bg(self.player_id)
		hud.custom_hud(self.player_id)
		self.player_id:set_detach()
		self.player_id:hud_set_flags({crosshair = true, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
		self.player_id:set_attribute("core_display_hud", "true")
		self.player_id:set_attribute("intro_completed", "true")
		intro.teleport_on_sneak(self.player_id)
		hudclock.display_bg(self.player_id)
		self.object:remove()
		self.timer = 0
	end
	
end

function title_entity:on_activate(staticdata, dtime_s) -- start the entity up

	self.object:set_animation({x=0, y=59}, 15, 0, true)

end

minetest.register_entity("intro:title", title_entity)

function intro.teleport_on_sneak(player)
	
	local tx = math.random(-20000, 20000) -- make area load before teleporting and consistent;
	local tz = math.random(-20000, 20000)
	
	if intro.use_random_spawn_point == true then
		minetest.forceload_block({x=tx, y=30000, z=tz}, true)
		player:set_pos({x=tx, y=20, z=tz})
	elseif intro.use_random_spawn_point == false then
		player:set_pos({x=intro.spawn_x, y=intro.spawn_y, z=intro.spawn_z})
	end

end

function intro.hud_bg(player)
	player:hud_add({
		hud_elem_type = "image",
		position = {x=0.5, y=1},
		offset = {x=0.5, y=-67},
		scale = {x=1, y=1},
		text = "hud_stat_bg.png",
	})
	
	player:hud_add({
		hud_elem_type = "image",
		position = {x=0.5, y=1},
		offset = {x=-171, y=-54},
		scale = {x=1, y=1},
		text = "intro_heart.png",
	})
	
	player:hud_add({
		hud_elem_type = "image",
		position = {x=0.5, y=1},
		offset = {x=-171, y=-66},
		scale = {x=1, y=1},
		text = "intro_hunger.png",
	})
	
	player:hud_add({
		hud_elem_type = "image",
		position = {x=0.5, y=1},
		offset = {x=-171, y=-79}, -- note; these offsets are in pixels.
		scale = {x=1, y=1},
		text = "intro_bubble.png",
	})
end

minetest.register_on_joinplayer(function(player)
	-- start checks at 0, +30k, 0
	-- y is a static value so that doesn't need to be played with or incremented
	
	--player:set_attribute("intro_completed", "true")
	
	if player:get_attribute("intro_completed") == "true" then 
	
		intro.hud_bg(player)
		hud.custom_hud(player)
		player:hud_set_flags({crosshair = true, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
		player:set_attribute("core_display_hud", "true")
		player:set_attribute("intro_completed", "true")
		
		hudclock.display_bg(player)
	
		return
	
	end
	
	local x = 0
	local z = 0
	
	local found_intro_position = nil
	
	repeat
		
		minetest.forceload_block({x=x, y=30000, z=z})
		
		local entity = minetest.get_objects_inside_radius({x=x, y=30000, z=z}, 0.1)
		
		if entity[1] ~= nil or entity[2] ~= nil then
		
			x = x + 5
		
		end
		
		entity = minetest.get_objects_inside_radius({x=x, y=30000, z=z}, 0.1)
		
		if entity[1] == nil then
		
			minetest.add_entity({x=x, y=30000, z=z}, "intro:title")
			
			entity = minetest.get_objects_inside_radius({x=x, y=30000, z=z}, 0.1)
			
			player:set_pos({x=x, y=30000, z=z})
			player:hud_set_flags({crosshair = false, hotbar = false, healthbar = false, wielditem = false, breathbar = false})
			player:set_attribute("core_display_hud", "false")
			player:set_attach(entity[1], "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			local pname = player:get_player_name()
			local intro_music = minetest.sound_play(intro.audiofile, {
			
				to_player = pname,
				gain = 1,
			
			})
			
			found_intro_position = true
			
		end
		
		
	
	until found_intro_position == true
end)

-- somtimes intro fails to teleport the player; use this command if you get stuck.

minetest.register_chatcommand("intro_warp", {

	description = "This can only run once per player, use this if you get stuck from the title screen.",
	func = function(name) -- engine should provide a player's ObjectRef too, but get_player_by_name works for now.
		
		player = minetest.get_player_by_name(name)
		
		if player:get_attribute("intro_warp") == nil then
		
			intro.teleport_on_sneak(player)
			
			player:set_attribute("intro_warp", "true")
			
			print ("[Intro]: Player '"..name.."' used their only intro to spawn teleport.")
			
		end
	
	end,
})

-- admin variant that can be used infinitely

minetest.register_chatcommand("intro_warp_admin", {

	description = "This command resets a player if the intro fails, using their name as a reference; eg 'TenPlus1' or 'Evergreen'",
	param = "target player's name",
	privs = {server = true},
	func = function(name, param)
		
		player = minetest.get_player_by_name(param)
		
		if player == nil then return end
		
		intro.teleport_on_sneak(player)
		
		print ("[Intro]: Admin '"..name.."' sent player '"..param.."' to spawn.")
		
	end,
})
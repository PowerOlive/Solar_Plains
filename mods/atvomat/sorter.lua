-- avtomat - (automatico, automation)
-- part of solar plains, by jordach

-- register ingots for sorting:

--[[

list of item inventories for the sorter

face outputs for sorting:

up 
down
left
right
front
back

main -- single slot for storing items.

]]--

local atsorter = 
	"size[8,9]" ..
	"list[current_name;main;3.5,3.25;1,1]" ..
	"list[current_name;up;0,0;3,1]" .. 
	"list[current_name;down;5,0;3,1]" .. 
	"list[current_name;left;0,1;3,1]" .. 
	"list[current_name;right;5,1;3,1]" .. 
	"list[current_name;back;0,2;3,1]" .. 
	"list[current_name;front;5,2;3,1]" .. 
	"list[current_player;main;0,4.5;8,1;]" ..
	"list[current_player;main;0,6;8,3;8]" ..
	"listring[current_name;main]" ..
	"listring[current_player;main]" ..
	"background[-0.45,-0.5;8.9,10;atvomat_sorter_interface.png]"..
	"listcolors[#3a4466;#8b9bb4;#ffffff;#4e5765;#ffffff]"

local function reboot_mover(pos)
	if minetest.get_node_timer(pos):is_started() == false then
		minetest.get_node_timer(pos):start(1)
	end
end

local function insert_into_mover(inv, inputstack, inputname, mover_inv)
	if mover_inv:room_for_item("main", inputstack) then		
		inputstack:take_item()
		mover_inv:add_item("main", inputname)
		inv:set_stack("main", 1, inputstack)
	end
end

local function sort_by_item(inv, inputstack, inputname, mover_inv, face_pos)
	local node = minetest.get_node_or_nil(face_pos)
	
	if node.name == "atvomat:mover" and node.name ~= nil then
		-- push item into mover :^)
		local mover_inv = minetest.get_meta(face_pos):get_inventory()
		reboot_mover(face_pos)
		insert_into_mover(inv, inputstack, inputname, mover_inv)
		return true
	end
	
	return false
end

local function sorting_card(inv, inputstack, inputname, sort_table, face_pos)
	local is_match = false
	
	for k, v in pairs(sort_table) do -- check through the list of items to sort based on this card
		-- todo, make k the node/item name like how the mover operates;
		if inputname ~= "" then
			if k == inputname then
				local node = minetest.get_node_or_nil(face_pos)
				
				if node.name == "atvomat:mover" and node.name ~= nil then
					-- push item into mover :^)
					local mover_inv = minetest.get_meta(face_pos):get_inventory()
					reboot_mover(face_pos)
					insert_into_mover(inv, inputstack, inputname, mover_inv)
					is_match = true
				end
			end
		end
	end

	if is_match == true then return true
	else return false end
end

local function sort(pos, elapsed)
	local inv = minetest.get_meta(pos):get_inventory() -- sorter storage
	
	local inputstack = inv:get_stack("main", 1) -- the stack contained in the input slot
	local inputname = inputstack:get_name()
	local stackstr = ""
	
	local face_pos = table.copy(pos)

	for i=1,6 do -- let's loop through the faces and make face_pos correct per direction
		face_pos = table.copy(pos)

		if i == 1 then stackstr = "up"; face_pos.y = face_pos.y + 1 
		elseif i == 2 then stackstr = "down"; face_pos.y = face_pos.y - 1
		elseif i == 3 then stackstr = "left"; face_pos.x = face_pos.x - 1
		elseif i == 4 then stackstr = "right"; face_pos.x = face_pos.x + 1
		elseif i == 5 then stackstr = "front"; face_pos.z = face_pos.z + 1
		elseif i == 6 then stackstr = "back"; face_pos.z = face_pos.z - 1
		end

		-- let's check sorting inv slots
		for s=1,3 do
			local stack = inv:get_stack(stackstr, s) -- the stack contained in the sorting slots
			local stackname = stack:get_name()
		
			if stackname ~= "" then
				if inputname ~= "" then
					if inputname == stackname then
						local mover_inv = minetest.get_meta(face_pos):get_inventory()	
						if sort_by_item(inv, inputstack, inputname, mover_inv, face_pos) == true then return true end
					end
					
					if stackname == "atvomat:sorter_card_wood" then -- detect sorter cards! see init.lua:174 for the ordering of sorter cards.
						if sorting_card(inv, inputstack, inputname, atvomat.wood_sort, face_pos) == true then return true end	
					elseif stackname == "atvomat:sorter_card_ore" then
						if sorting_card(inv, inputstack, inputname, atvomat.ore_sort, face_pos) == true then return true end	
					elseif stackname == "atvomat:sorter_card_ingot" then	
						if sorting_card(inv, inputstack, inputname, atvomat.ingot_sort, face_pos) == true then return true end	
					elseif stackname == "atvomat:sorter_card_block" then
						if sorting_card(inv, inputstack, inputname, atvomat.ingot_block_sort, face_pos) == true then return true end
					elseif stackname == "atvomat:sorter_card_tool" then
						if sorting_card(inv, inputstack, inputname, atvomat.tool_sort, face_pos) == true then return true end
					elseif stackname == "atvomat:sorter_card_dye" then
						if sorting_card(inv, inputstack, inputname, atvomat.dye_sort, face_pos) == true then return true end
					elseif stackname == "atvomat:sorter_card_farm" then
						if sorting_card(inv, inputstack, inputname, atvomat.farm_sort, face_pos) == true then return true end
					elseif stackname == "atvomat:sorter_card_fuel" then
						if sorting_card(inv, inputstack, inputname, atvomat.fuel_sort, face_pos) == true then return true end
					end
				end
			end
		end
	end
	
	for i=1,6 do
		face_pos = table.copy(pos)
		
		if i == 1 then stackstr = "up"; face_pos.y = face_pos.y + 1 
		elseif i == 2 then stackstr = "down"; face_pos.y = face_pos.y - 1
		elseif i == 3 then stackstr = "left"; face_pos.x = face_pos.x - 1
		elseif i == 4 then stackstr = "right"; face_pos.x = face_pos.x + 1
		elseif i == 5 then stackstr = "front"; face_pos.z = face_pos.z + 1
		elseif i == 6 then stackstr = "back"; face_pos.z = face_pos.z - 1
		end
		
		for s=1,3 do
			local stack = inv:get_stack(stackstr, s) -- the stack contained in the sorting slots
			local stackname = stack:get_name()
			
			if stackname ~= "" then
				if inputname ~= "" then
					-- after we've literally done everything, let's do the ejecting cards;
					if stackname == "atvomat:eject_card" then
						local mover_inv = minetest.get_meta(face_pos):get_inventory()
						if sort_by_item(inv, inputstack, inputname, mover_inv, face_pos) == true then end
					end
				end
			end
		end
	end

	return true
end

minetest.register_node("atvomat:sorter", {
	description = "Sorter",
	paramtype = "light",
	tiles = {"atvomat_sorter_mesh.png"},
	drawtype = "mesh",
	mesh = "atvomat_sorter.b3d",
	groups = {oddly_breakable_by_hand=3},
	
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", atsorter)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
		inv:set_size("up", 3)
		inv:set_size("down", 3)
		inv:set_size("left", 3)
		inv:set_size("right", 3)
		inv:set_size("front", 3)
		inv:set_size("back", 3)
		minetest.get_node_timer(pos):start(1.0)
	end,
	
	on_punch = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_timer = sort,
})

-- register recipes for the sorter and associated cards;

minetest.register_craft({
	output = "atvomat:sorter",
	recipe = {
		{"group:planks", "core:chest", "group:planks"},
		{"core:chest", "core:mese", "core:chest"},
		{"group:planks", "core:chest", "group:planks"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_ore",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "group:ore", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_ingot",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:diamond", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_block",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:iron_block", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_dye",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "group:dye", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_wood",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:oak_sapling", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_wood",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:pine_sapling", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_wood",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:cherry_sapling", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_wood",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:birch_sapling", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_fuel",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:coal_lump", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_farm",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "farming:seed_wheat", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_tool",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "core:iron_pickaxe", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})

minetest.register_craft({
	output = "atvomat:sorter_card_eject",
	recipe = {
		{"core:cactus", "core:mese_crystal", "core:cactus"},
		{"core:mese_crystal", "", "core:mese_crystal"},
		{"core:cactus", "core:mese_crystal", "core:cactus"},
	},
})



local S = minetest.get_translator()

enhanced_beginnings = {}

local function mod_loaded(str)
  if minetest.get_modpath(str) ~= nil then
    return true
  else
    return false
  end
end


local bens_gear_exists = mod_loaded("bens_gear")



function enhanced_beginnings.node_sound_twig_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "enhanced_beginnings_twig_dig", gain = 0.6}
	table.dig = table.dig or
			{name = "enhanced_beginnings_twig_dig", gain = 0.4}
	table.dug = table.dug or
			{name = "enhanced_beginnings_twig_break", gain = 1.0}
	return table
end

minetest.register_craftitem("enhanced_beginnings:pebbles", {
	description = S("Pebbles"),
	inventory_image = "enhanced_beginnings_pebbles.png",
	groups = {pebbles=1}
})

minetest.register_craftitem("enhanced_beginnings:pebbles_desert", {
	description = S("Desert Pebbles"),
	inventory_image = "enhanced_beginnings_pebbles_desert.png",
	groups = {pebbles=1}
})

minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"default:clay_lump","group:pebbles","default:clay_lump"},
		{"group:pebbles","group:pebbles","group:pebbles"},
		{"default:clay_lump","group:pebbles","default:clay_lump"},
	}
})

minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"default:clay_lump","enhanced_beginnings:pebbles","default:clay_lump"},
		{"enhanced_beginnings:pebbles","enhanced_beginnings:pebbles","enhanced_beginnings:pebbles"},
		{"default:clay_lump","enhanced_beginnings:pebbles","default:clay_lump"},
	}
})

minetest.register_craft({
	output = "default:desert_cobble",
	recipe = {
		{"default:clay_lump","enhanced_beginnings:pebbles_desert","default:clay_lump"},
		{"enhanced_beginnings:pebbles_desert","enhanced_beginnings:pebbles_desert","enhanced_beginnings:pebbles_desert"},
		{"default:clay_lump","enhanced_beginnings:pebbles_desert","default:clay_lump"},
	}
})


minetest.register_node("enhanced_beginnings:stick_node", {
	description = S("Twig"),
	tiles = {
		"default_tree.png",
		"default_tree.png",
		"default_tree.png",
		"default_tree.png",
		"default_tree.png",
		"default_tree.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.0625, 0.5, -0.3125, 0.125}, -- NodeBox1
			{0.0625, -0.3125, -0.0625, 0.25, -0.1875, 0.125}, -- NodeBox2
		}
	},
	drop = "default:stick",
	sounds = enhanced_beginnings.node_sound_twig_defaults(),
	groups = {dig_immediate=2, falling_node = 1}
})

enhanced_beginnings.flint_tool_functions = {}


minetest.register_tool("enhanced_beginnings:axe_flint", {
		description = S("Flint Axe"),
		inventory_image = "enhanced_beginnings_flint_axe.png",
		tool_capabilities = {
			full_punch_interval = 1.2,
			max_drop_level=0,
			groupcaps={
				choppy = {times={[2]=3.50, [3]=3.0}, uses=5, maxlevel=1},
			},
			damage_groups = {fleshy=2},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = {axe = 1}
	})
	
	minetest.register_tool("enhanced_beginnings:shovel_flint", {
		description = S("Flint Shovel"),
		inventory_image = "enhanced_beginnings_flint_shovel.png",
		wield_image = "enhanced_beginnings_flint_shovel.png^[transformR90",
		tool_capabilities = {
			full_punch_interval = 1.3,
			max_drop_level=0,
			groupcaps={
				crumbly = {times={[1]=3.02, [2]=1.64, [3]=0.64}, uses=5, maxlevel=1},
			},
			damage_groups = {fleshy=1},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = {shovel = 1}
	})
	
	minetest.register_craft({
		output = "enhanced_beginnings:shovel_flint",
		recipe = {
			{"default:flint"},
			{"group:stick"},
			{"group:stick"},
		}
	})
	
	minetest.register_craft({
		output = "enhanced_beginnings:axe_flint",
		recipe = {
			{"default:flint","default:flint"},
			{"default:flint","group:stick"},
			{"","group:stick"},
		}
})


local old_handle_node_drops = minetest.handle_node_drops
function minetest.handle_node_drops(pos, drops, digger, ...)
	if digger == nil then
		return old_handle_node_drops(pos, drops, digger, ...)
	end
	local current_tool = digger:get_wielded_item():get_name()
	if current_tool == "enhanced_beginnings:axe_flint" then
		local node = minetest.get_node(pos).name
		local output = minetest.get_craft_result({
		method = "normal",
		width = 1,
		items = {ItemStack(node)},
		})
		if (output.item:is_empty()) then
			return old_handle_node_drops(pos, drops, digger, ...)
		end
		return old_handle_node_drops(pos,{output.item:to_table().name},digger)
	end
	
	if current_tool == "default:pick_wood" or (string.find(current_tool,"bens_gear:pickaxe_default_wood")) then
		local node = minetest.get_node(pos).name
		if (minetest.get_node(pos + vector.new(0,-1,0)).name == "air") then
			minetest.spawn_falling_node(pos)
			return old_handle_node_drops(pos,{},digger)
		end
		if (minetest.get_node(pos + vector.new(0,1,0)).name ~= "air") then
			minetest.spawn_falling_node(pos + vector.new(0,1,0))
		end
	end
  
	return old_handle_node_drops(pos, drops, digger, ...)
end


minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass","default:dirt_with_dry_grass","default:dirt_with_rainforest_litter"},
	sidelen = 2,
	fill_ratio = 0.02,
	decoration = "enhanced_beginnings:stick_node"

})



minetest.register_on_mods_loaded(function()
	minetest.override_item("default:gravel", {drop = {
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 6},
			{items = {"default:gravel"}}
		}
	}})
	
	minetest.override_item("default:stone", {drop = "enhanced_beginnings:pebbles"})
	
	minetest.override_item("default:desert_stone", {drop = "enhanced_beginnings:pebbles_desert"})
	for i, thing in pairs(minetest.registered_nodes) do
		if (thing.groups) then
			if ((thing.groups["tree"] ~= nil and thing.groups["tree"] ~= 0) or string.find(i,"stem")) then
				local group_clone = thing.groups
				group_clone["oddly_breakable_by_hand"] = nil
				minetest.override_item(i, {groups = group_clone})
			end
		end
	end
end)

-- << main | berserk_limiter

local _G = _G
local wesnoth = wesnoth
local T = wml.tag
local ipairs = ipairs
local print = print

local function berserk_limiter_apply()
	local limit = wesnoth.get_variable("berserk_limit_value")
	for _, unit_userdata in ipairs(wesnoth.get_units {side = wesnoth.current.side}) do
		wesnoth.wml_actions.store_unit {
			T.filter { id = unit_userdata.id },
			kill = false,
			variable = "berserk_limiter_units"
		}
		local unit_var = wesnoth.get_variable("berserk_limiter_units")
		for attack in wml.child_range(unit_var, "attack") do
			for specials in wml.child_range(attack, "specials") do
				for _, special in ipairs(specials) do
					local name = special[1]
					local tag = special[2]
					if name == "berserk" then
						print("applying berserk limit to " .. unit_var.id)
						if tag.cumulative then
							tag.value = tag.value + 1
							tag.cumulative = false
						end
						if tag.value > limit then
							tag.value = limit
							if tag.description then
								local upper_name = string.gsub(tostring(tag.name), "^%l", string.upper)
								tag.description = upper_name
									.. " limited to " .. limit .. " rounds.\n"
									.. "Old description: \n" .. tag.description
							end
							if tag.name then tag.name = tag.name .. "_limit_" .. limit end
							if tag.name_inactive then tag.name_inactive = tag.name_inactive .. "_limit_" .. limit end
						end
					end
				end
			end
		end
		wesnoth.set_variable("berserk_limiter_units", unit_var)
		wesnoth.wml_actions.unstore_unit {
			variable = "berserk_limiter_units",
		}
		wesnoth.set_variable("afterlife_unit", nil)
	end
end


_G.berserk_limiter_apply = berserk_limiter_apply


wesnoth.wml_actions.event {
	name = "side turn end",
	T.lua { code = "berserk_limiter_apply()" }
}

-- >>

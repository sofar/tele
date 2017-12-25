
--[[

 Copyright (C) 2017 - Auke Kok

Permission to use, copy, modify, and/or distribute this software for
any purpose with or without fee is hereby granted, provided that the
above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR
BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES
OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

]]--

local context = {}
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	context[name] = nil
end)

minetest.register_node("tele:port", {
	description = "A teleport node",
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local name = clicker:get_player_name()
		local formspec
		if minetest.check_player_privs(clicker, "server") then
			-- send admin formspec
			formspec = "field[target;target;(0,0,0)]"
		else
			-- send teleport formspec
			formspec = "size[8,8]button[1,1;6,6;teleport;teleport]"
		end
		context[name] = minetest.pos_to_string(pos)
		minetest.show_formspec(name, "tele:port", formspec)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	local pos = context[name]
	if not pos then
		return true
	end
	pos = minetest.string_to_pos(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "tele:port" then
		context[name] = nil
		return true
	end
	if fields.target and minetest.check_player_privs(player, "server") then
		local meta = minetest.get_meta(pos)
		meta:set_string("target", fields.target)
	end
	if fields.teleport then
		local meta = minetest.get_meta(pos)
		local target = meta:get_string("target")
		player:set_pos(minetest.string_to_pos(target))
	end

	context[name] = nil
end)

--hop climber
--by lazy crow studio
window_center = 64
window_size = 128

tile_size = 8
wrap_rows = 32
title = "hop climber"

flags = {
    solid = 0,
    hazard = 1,
}

playback = {
    loop = 0,
    once = 1,
    ping_pong = 2,
}

shapes = {
    circle = 0,
    rectangle = 1,
}

white = 7


global = _ENV

class = setmetatable(
    {
        new = function(self, tbl)
            tbl = tbl or {}

            setmetatable(
                tbl, { __index = self }
            )

            return tbl
        end
    },

    { __index = _ENV }
)


session = class:new({
    mode = {
        "play",
        "stageselect"
    },
    modeselected = 1,
    lifemax = 5,
    lives = 5,
    hops = 0,
    nice_hops = 0,
    great_hops = 0,
    holy_hops = 0,

    get_lives = function (_ENV)
        return lives
    end,

    reset_lives = function(_ENV)
        lives = lifemax
    end,

    get_nice = function (_ENV)
        return nice_hops
    end,

    add_nice = function (_ENV)
        nice_hops += 1
    end,
    get_great = function (_ENV)
        return great_hops
    end,

    add_great = function (_ENV)
        great_hops += 1
    end,
    get_holy = function (_ENV)
        return holy_hops
    end,

    add_holy = function (_ENV)
        holy_hops += 1
    end,

    reset_hops = function (_ENV)
        nice_hops = 0
        great_hops = 0
        holy_hops = 0
    end,

    reset_score = function (_ENV)
        score_manager:reset_score()
    end,

    reset_stats = function (_ENV)
        reset_lives(_ENV)
        reset_hops(_ENV)
        reset_score(_ENV)
    end,

    get_gamemode = function(_ENV)
        return mode[modeselected]
    end,

    reset_gamemode = function(_ENV)
        modeselected = 1
    end
})


hud = class:new({
    bar_height = 96,

    draw_circle_marker = function(_x, _y, _inner_col, _outer_col)
        -- fill
        rect(_x, _y - 2, _x + 1, _y + 1, _inner_col)
        rect(_x - 1, _y - 1, _x + 2, _y, _inner_col)

        pset(_x - 1, _y - 2, _outer_col)
        pset(_x + 2, _y - 2, _outer_col)
        pset(_x - 1, _y + 1, _outer_col)
        pset(_x + 2, _y + 1, _outer_col)

        line(_x, _y - 3, _x + 1, _y - 3, _outer_col)
        line(_x, _y + 2, _x + 1, _y + 2, _outer_col)
        line(_x - 2, _y - 1, _x - 2, _y, _outer_col)
        line(_x + 3, _y - 1, _x + 3, _y, _outer_col)
    end,
    draw_markers = function(_ENV, _color)
        local _x = 123 + 7
        local _y = 16 + cam:get_y()
        local _c = _color
        for i = 0, 4 do
            draw_circle_marker(_x, _y, 0, 5)
            _y += 24
        end
    end,
    draw_markers_bg = function(_ENV)
        local _y = 16
        for i = 0, 4 do
            draw_circle_marker(123 + 8, _y + cam:get_y(), 2, 0, 0)
            _y += 24
        end
    end,
    draw_arrow = function(_x, _y)
        line(_x, _y - 1, _x + 2, _y + 1, 0)
        line(_x, _y + 3, _x + 2, _y + 1, 0)
        line(_x - 1, _y - 1, _x - 1, _y + 3, 0)
        pset(_x + 1, _y + 1, white)
        pset(_x, _y, white)
        pset(_x, _y + 1, white)
        pset(_x, _y + 2, white)
    end,
    draw_top_line = function(_x, _y)
        line(_x, _y, _x + 3, _y, 2)
        line(_x + 1, _y, _x + 2, _y, white)
    end,

    get_relative_bar_top = function(_ENV)
        local _map_height = 256 * 8
        local _cam_position = cam:get_y() + window_size
        local _relative_top = _cam_position / _map_height
        local _bar_top = flr(_relative_top * bar_height)

        return _bar_top
    end,

    draw_checkpoints = function(_ENV)
        local _x = 123 + 8
        local _y = 112 + cam:get_y()
        local _color = 8
        local _top = 16 + get_relative_bar_top(_ENV) + cam:get_y()
        for i = 0, 4 do
            if _y >= _top then
                -- custom drawing a circle
                draw_circle_marker(_x-1, _y, 0, 1)
                rectfill(_x - 2, _y - 2, _x + 1, _y + 1, _color)
                pset(_x - 2, _y - 2, 2)
                pset(_x + 1, _y - 2, 2)
                pset(_x - 2, _y + 1, 2)
                pset(_x + 1, _y + 1, 2)

                rectfill(_x - 1, _y - 1, _x, _y, 0)
                pset(_x, _y - 1, white)
            end
            _y -= 24
        end
    end,

    draw_bar = function(_ENV)
        local _x = 121 + 8
        local _y = 16 + cam:get_y()
        local _width = 3
        local _outer_color = 1
        local _inner_color = 5

        rect(_x, _y, _x + _width, _y + bar_height, _outer_color)
        rectfill(_x + 1, _y, _x + _width - 1, _y + bar_height, _inner_color)
    end,

    draw_progress_bar = function(_ENV)
        local _color = 2
        local _x = 122 + 8
        local _x2 = 123 + 8
        local _y = 16 + get_relative_bar_top(_ENV) + cam:get_y()
        local _y2 = 112 + cam:get_y()
        rectfill(_x, _y, _x2, _y2, _color)
    end,

    draw = function(_ENV)
        draw_markers_bg(_ENV)
        draw_bar(_ENV)
        draw_markers(_ENV, 5)
        draw_progress_bar(_ENV)
        draw_arrow(117 + 8, 16 + get_relative_bar_top(_ENV) + cam:get_y() - 1)
        draw_top_line(121 + 8, 16 + get_relative_bar_top(_ENV) + cam:get_y())
        draw_checkpoints(_ENV)
    end
})


-- functions
function throw_error(_message)
  assert(false, _message)
end

pad4 = function(n)
    local s = "" .. n
    return sub("0000" .. s, -4)
end

score_greater = function(_ENV,
    a1,a2,
    b1,b2
)
    if a1 != b1 then
        return a1 > b1
    end

    return a2 > b2
end

function get_hex_tile(_string, _tile_index, _chars_per_tile)
  if _chars_per_tile <= 0 then
    throw_error("Argument _chars_per_tile should be greater than 0")
  end

  local _start_position = _tile_index * _chars_per_tile + 1
  local _hex_string = sub(_string, _start_position, _start_position + _chars_per_tile - 1)

  if _hex_string == "" then
    return 0
  end

  local _tile_number = string_to_hex(_hex_string)

  return _tile_number
end

function string_to_hex(_string)
  return tonum("0x" .. _string)
end

function byte_to_hex_string(_byte)
  local hex = "0123456789abcdef"
  _byte = flr(_byte)

  return sub(hex, flr(_byte / 16) + 1, flr(_byte / 16) + 1)
      .. sub(hex, (_byte % 16) + 1, (_byte % 16) + 1)
end

outline = {
  down = 0x40,
  left = 0x08,
  right = 0x10,
  full = 0xff
}

function string_get_width(_string)
  return print(_string, 0, -100)
end

function string_get_center_x(_string)
  local _string_width = string_get_width(_string)
  local _cam_x = 0
  if cam then
    _cam_x = cam:get_x()
  end
  local _x = _cam_x + window_center - _string_width / 2
  return _x
end

function string_get_center_y(_string)
  local _string_height = 6
  local _cam_y = 0
  if cam then
    _cam_y = cam:get_y()
  end
  local _y = _cam_y + window_center - _string_height / 2
  return _y
end

function print_menu_buttons()
  print("❘:BACK", 4, 120, 0)
end

function draw_title()
  local _string = title
  local _x = string_get_center_x(_string)
  local _y = 48 + sin(t/60)*2
  print_with_outline(_string, _x, _y, white, 0, outline.full)
  print_with_outline(_string, _x, _y-1, white, 0, outline.full)
  print_with_outline(_string, _x, _y-2, white, 0, outline.full)
end

print_with_outline = function(_text, _x, _y, _color, _outline_color, _outline_mask)
  if not _outline_color or not _outline_mask then
    return print(_text, _x, _y, _color)
  end
  _outline_color_hex = sub("0123456789abcdef", _outline_color + 1, _outline_color + 1)
  _outline_mask = byte_to_hex_string(_outline_mask)

  local _prefix = "\^o" .. _outline_color_hex .. _outline_mask
  local _final_text = _prefix .. _text

  return print(_final_text, _x, _y, _color)
end

draw_string_texture = function(_string_texture)
  print(_string_texture, 0, 16)
end

function diff(a, b)
  return abs(a - b)
end

function random_angle()
  if rnd() < 0.5 then
    return 0.1 + rnd() * 0.3
  else
    return 0.6 + rnd() * 0.3
  end
end

function clamp_to_screen(_Entity)
  _Entity.x = mid(0, x, window_size - _Entity.width)
  _Entity.y = mid(0, y, window_size - _Entity.height)
end

function is_on_screen(_entity)
  return _entity.y > cam:get_y() and _entity.y < cam:get_y() + window_size
end

function sign_deadzone(x, dz)
  if abs(x) < dz then
    return 0
  else
    return sgn(x)
  end
end

function approach(value, target, amount)
  if value < target then
    return min(value + amount, target)
  elseif value > target then
    return max(value - amount, target)
  end
  return value
end

function move_selection(i, _list, _dir)
  i -= 1
  --make zero based
  --if i != 0 then
  local _len = #_list
  i = (i + _dir + _len) % _len
  --wrap
  --end
  return i + 1
  --make 1 based
end

--string centering functions

function hcenter(_string)
  -- screen window_center minus the
  -- string length times the
  -- pixels in a char's width,
  -- cut in half
  local _font_half_width = 2
  return window_center - #_string * _font_half_width
end

function vcenter(_string)
  -- screen window_center minus the
  -- string height in pixels,
  -- cut in half
  local _font_mid_height = 3
  return window_center - _font_mid_height
end

function print_ui(_string, _x, _y, _color, _outline_color, _outline_mask)
  _x = _x or 0
  _y = _y or 0
  _color = _color or white

  _x += cam:get_x()
  _y += cam:get_y()
  return print_with_outline(_string, _x, _y, _color, _outline_color, _outline_mask)
end

function printcenter(s, c, ox, oy)
  c = c or 7
  ox = ox or 0
  oy = oy or 0

  print(
    s, hcenter(s) + ox,
    vcenter(s) + oy, c
  )
end

function anybtnp()
  return btnp(❘) or btnp(🅾️)
end

function input_axis_x()
  local _right = btn(➡️) and 1 or 0
  local _left = btn(⬅️) and 1 or 0

  return _right - _left
end
function input_axis_y()
  local _down = btn(⬇️) and 1 or 0
  local _up = btn(⬆️) and 1 or 0

  return _down - _up
end

function input_axis_y_pressed()
  local _down = btnp(⬇️) and 1 or 0
  local _up = btnp(⬆️) and 1 or 0

  return _down - _up
end

function fills(c)
  rectfill(0, 0 + cam:get_y(), 127, 127 + cam:get_y(), c)
end

--cel helper functions
position_to_tile = function(_position)
  return flr(_position / tile_size)
end

tile_to_position = function(_tile)
  return _tile * tile_size
end

get_center_tile = function(_x, _y, _width, _height)
  local _cx = position_to_tile(_x + ((_width * tile_size) / 2))
  local _cy = position_to_tile(_y + ((_height * tile_size) / 2))
  if wrap_rows then
    _cy %= wrap_rows
  end
  local _tile = mget(_cx, _cy)
  return _tile
end

function position_has_flag(_x, _y, _flag)
  local _tile_x = position_to_tile(_x)
  local _tile_y = position_to_tile(_y)

  return tile_has_flag(_tile_x, _tile_y, _flag)
end

function tile_has_flag(_tile_x, _tile_y, _flag)
  if wrap_rows then
    _tile_y %= wrap_rows
  end
  return fget(mget(_tile_x, _tile_y), _flag)
end


scene = class:new({
    on_scene_exit = function(_ENV)
    end,
    draw_ui = function (_ENV)
    end,
})


--Game Manager
game = class:new({
    init = function(_ENV)
        scene_manager:init()
        particle_manager:init()
        callout_manager:init()
        map_manager:init()
        score_manager:init()
        cam:init()
    end,

    update = function(_ENV)
        scene_manager:update()
        entity_manager:update()
        particle_manager:update()
        callout_manager:update()
        score_manager:update()
        cam:update()
    end,

    draw = function(_ENV)
        scene_manager:draw()
        entity_manager:draw()
        particle_manager:draw()
        callout_manager:draw()
        scene_manager:draw_ui()
    end
})


function _init()
    t = 0
    cartdata("dungeonclimber")
    game:init()
end

function _update60()
    t += 1
    game:update()
end

function _draw()
    game:draw()
end


scene_manager = class:new({
    scenes = {},
    current = nil,

    set_scene = function (_ENV, _scene)
        if current != nil then
            current:on_scene_exit()
        end
        current = _scene
        current:init()
    end,

    init = function (_ENV)
        set_scene(_ENV, scenes.splash)
    end,

    update = function(_ENV)
        current:update()
    end,
    draw = function (_ENV)
        current:draw()
    end,
    draw_ui = function (_ENV)
        current:draw_ui()
    end,
})


entity_manager = class:new({
    entities = {},

    get_entities_by_tag = function(_ENV, _tag)
        local _matching_entities = {}

        for _entity in all(entities) do
            if _entity:is_active() and _entity.tag == _tag and not _entity.destroyed then
                add(_matching_entities, _entity)
            end
        end

        return _matching_entities
    end,

    clean_destroyed_entities = function(_ENV)
        for _entity in all(entities) do
            if _entity.destroyed then
                del(entities, _entity)
                _entity = nil
            end
        end
    end,

    clear_all_entities = function(_ENV)
        entities = {}
    end,

    update = function(_ENV)
        update_all(entities)
        clean_destroyed_entities(_ENV)
    end,
    draw = function(_ENV)
        draw_all(entities)
    end
})


player_manager = class:new({
    player = nil,
    spawn = {
        x = 60,
        y = 110,
    },

    spawn_player = function(_ENV)
        player = character:new({
            x = spawn.x, y = spawn.y + cam:get_y(),
            tag = "player"
        })
        player:init()
        add(entity_manager.entities, player)
    end,

    get_player = function(_ENV)
        return player
    end,

    get_player_state = function(_ENV)
        return player and player.state or "none"
    end,

    is_player_dead = function(_ENV)
        return get_player_state(_ENV) == "dead"
    end,

    reset_player = function(_ENV)
        if player then
            del(entity_manager.entities, player)
            player = nil
        end

        spawn_player(_ENV)
    end
})


callout_manager = class:new({
    callouts = {},
    callout_types = {},

    spawn = function (_ENV, _ct, _x, _y)

        local _callout = _ct:new({})
        _callout.x = _x or _ct.x 
        _callout.y = _y or _ct.y 
        add(callouts, _callout)
    end,

    show_ready = function (_ENV)
        spawn(_ENV, callout_types.ready)
    end,

    init = function(_ENV)
    end,
    update = function(_ENV)
        for _callout in all(callouts) do
            _callout:update()

            if _callout:is_dead() then
                del(callouts, _callout)
            end
        end
    end,
    draw = function(_ENV)
        draw_all(callouts)
    end
})


particle_manager = class:new({
    particles = {},

    clear_dead_particles = function(_ENV)
        for _particle in all(particles) do
            if _particle:is_dead() then
                del(particles, _particle)
                _particle = nil
            end
        end
    end,
    clear_all_particles = function(_ENV)
        particles = {}
    end,

    spawn_attach_particle = function(_ENV, _x, _y)
        for i = 1, flr(rnd(4) + 2) do
            local _particle = particle_attach:new({
                x = _x + rnd(10),
                y = _y + rnd(10),
                x_spd = 0.5 * (rnd(2) - 1),
                y_spd = 0.5 * (rnd(1) - 1),
                friction = (rnd(2) + 1) / 100,
                radius = 2 + rnd(1)
            })
            add(particles, _particle)
        end
    end,

    spawn_climb_particle = function(_ENV, _x, _y)
        local _particle = particle_attach:new({
            x = _x + rnd(5),
            y = _y + rnd(5) + 4,
            x_spd = 0.5 * (rnd(2) - 1),
            y_spd = 0.5 * (rnd(1) - 1),
            friction = (rnd(2) + 1) / 100,
            radius = flr(rnd(2) + 1)
        })
        add(particles, _particle)
    end,

    init = function(_ENV)
    end,
    update = function(_ENV)
        clear_dead_particles(_ENV)
        update_all(particles)
    end,
    draw = function(_ENV)
        draw_all(particles)
    end
})


--Map Manager
map_manager = class:new({
	data = {
		[1] = "400000011110000000000000011111000000000000031113000000000000023332011100000000000224031100000011110440023300000111130000042400000311320010114000000233240030111100000442400040731100000004000000027300000011100000045400000011300000001100000033200000011100000002400110031100050000100330023300011000300420042400011100200816004110031100400030001110023300000040001130044200100000003320000401100000002440000001300000014000000003200000011000001004400000031000003000001100023000004000001110040000011000001110000000111001111110000000313001377330000000232001240240000000424001400400000000040001111111008110000003333771008110001144222401000330011300444001000240011440011111000400011000013333000000031100012200000000043110011100000000042330033160000000004240002160000000000400000100000000000000001100000000000000001300000000000000041200000000000001443400000000000003402000000000000002004100000000000104000300008100000300104200000300000400341400100200001000407000300400003000000010200000002410000030440100004430000440010300000040001400070400000000003000000000000010002000000000000030004010000000000040000030000100010000100024100300070000300044300400000004200140200100400014400300400300000030000400100400000020010000300000000044030000200000000041120010400000000011110030000000000031130040011000000023321100111000000000001100333000000000011100424000000000033300040000000000042400000000000000004110000000000000001130000000000000001120100000000000103340110000000000104200110000000001100400110000000001100000334000000011100500424100000011108160040300000011300700000200000031200000114400000023400001134000000042000011120000000004100011340000000011100113200000000011100332400000000011300424000000000111200000000000000113400000000000000332000000000000000424000100000000000001100110000000000081100111160000000003300311160000000004240231100000001000441423110000001100001142330000001111003114240000001111002110400000001111004310000000001111000211000100003111005431000300002113001023000400004312001144000100000234003100001100000420001100003300000040011100042400000000111300011000000000111600033000010001111600022000011003113000041100011002332000003300033004424010002400042000040111011000004111000113033000000111100332424000000331100424040000000423340041110000000042241003111000000000411002311000000000033004233000000000042000424000400001111000040000000011111000000000000031113000010000000023372000111000000042224000111100000011140000111100001111111000771110001111111100421110011113311111041110031162233311111130021164412231111320041110034223113200003310020412332000004230040034220000000420000020411100000040000040011300000000000000111200000000001000311400000010011000233000000030011100424000010040811110040000030000077110000000024000002330000000014000000420000010011100000011000110031160000011001130421100000033081120041100000042481140001100000004041100003300005500003300004240011150004200000400111110001100000000111110001100000000311110003300000000033130002400000000002322144000000000000224114000000000000044110000000000000001110000000000000001111000000000000003311000000000000002213000000000111140812000000011111114234000000433733334420000000044024240040000011000040400000000033000000000000000044001100000000000000003300000000000000004200110000000000000400331100000000000000421111000000000000441333000000000000043224000000000000002444000000000000004001100000000000011003300000000000033004200000001100022000400000003300040000000000002400000000000000144000000000000001100000000000000403300000000000000004200110000000000000400330000050000000000420011110000000110040011110000000330000031130000000240000023340000000400000222400000000000001240001000000000011140003000041112231100004000011112211300000000011112433400011100071114040000011100043330000000021200004222000010022400000421100030004000000011110420000000000011132240000000000031122111100000000043322111100000000000442111100000000000004311300000000000000033220000000000000004211000000000000000111100000000000000111100000000000000311100000110000012233300001110000034224000007110000040400000004330001000000000000240003000110000000400004000110000001110000000130000001111100000340000001111100000400000003113340000000000004332220000000000000040421111000000000000041111200000001000003113220000003000002332211000004000014244211100000000030402231100000000040112223300000000111112242400001000311132004000003000433324000000002400042240000000004400004000000000001114100000000000003111110000000000002311330000000000004221240000000000000411100000000000000111340024000000000333221112240000000424211111400000000040111111000000000000111111000000000000311113040000000000431134000000000000043320000000",
	},
	current = 1,
	charspertile = 1,

	x_offset = tile_size,
	stage_cel_width = 18,
	stage_cel_height_max = 256,
	stage_cel_height = 256, -- 32 for temporary small map
	tile_rows = {},
	--map draw variables
	chunk_cel_width = 18,
	chunk_cel_height = 32,
	chunk_height = 32 * tile_size,
	chunk_y = {
		[0] = 0,
		[1] = 0
	},
	last_chunk = 0,
	last_row = 0,

	set_stage = function(_ENV, s)
		current = s
	end,

	next_stage = function(_ENV)
		current += 1
	end,

	reset_stage_count = function(_ENV)
		current = 1
	end,

	get_count = function(_ENV)
		return #data
	end,

	is_last = function(_ENV)
		return current >= get_count(_ENV)
	end,

	get_height = function(_ENV)
		return tile_to_position(stage_cel_height)
	end,

	fillrowdata = function(_ENV)
		local _mapdata = data[current]
		rowwidth = stage_cel_width * charspertile

		tile_rows = {}

		for i = 1, #_mapdata, rowwidth do
			add(tile_rows, sub(_mapdata, i, i + rowwidth - 1))
		end
	end,

	get_chunk = function(_ENV)
		local _chunk = flr(cam:get_y() / chunk_height)
		return _chunk
	end,

	total_chunks = function(_ENV)
		return flr(stage_cel_height / chunk_cel_height)
	end,

	init_chunk_y = function(_ENV)
		local _chunk = total_chunks(_ENV) - 1

		local _active = _chunk % 2
		local _other = 1 - _active

		-- initialize both
		chunk_y[_active] = _chunk * chunk_height
		chunk_y[_other] = (_chunk - 1) * chunk_height

		last_chunk = _chunk
		last_row = position_to_tile(stage_cel_height)
	end,

	handle_chunk_y = function(_ENV)
		local _chunk = get_chunk(_ENV)

		if _chunk != last_chunk then
			local active = _chunk % 2

			-- update only active
			chunk_y[active] = _chunk * chunk_height

			last_chunk = _chunk
		end
	end,

	init_map_rows = function(_ENV)
		for _row = stage_cel_height - chunk_cel_height, stage_cel_height - 1 do
			setrow(_ENV, _row)
		end
	end,

	setrow = function(_ENV, _row_index)
		local _encoded_row = tile_rows[_row_index + 1]

		-- convert each tile in the row
		for _x = 1, stage_cel_width do
			-- convert 1-based loop index to 0-based map tile index
			local _map_index = _x - 1

			-- decode tile from string
			local tile_id = get_hex_tile(_encoded_row, _map_index, 1)

			-- compute vertical position in chunk
			local _y = (_row_index % chunk_cel_height)

			-- place tile in map
			mset(_x - 1, _y, tile_id)
		end
	end,

	ringbuffer = function(_ENV)
		top_row = position_to_tile(cam:get_y())
		bottom_row = top_row + 15

		if bottom_row != last_row and top_row > 0 then
			setrow(_ENV, top_row - 1)
			last_row = bottom_row
		end
	end,

	init = function(_ENV)
		set_stage(_ENV, current)
		init_chunk_y(_ENV)
		fillrowdata(_ENV)
		init_map_rows(_ENV)
	end,

	update = function(_ENV)
		handle_chunk_y(_ENV)
		ringbuffer(_ENV)
	end,

	draw = function(_ENV)
		palt(3)
		pal()
		map(0, 0, 0, chunk_y[0])
		map(0, 0, 0, chunk_y[1])
		palt()
	end
})


score_manager = class:new({
    score_1 = 0,
    score_2 = 0,
    score_count_1 = 0,
    score_count_2 = 0,
    x = 0,
    y = 0,
    color_id = white,
    outline_color = 0,
    outline_mask = outline.full,


    handle_count = function(_ENV)
        local _scores = { score_1, score_2 }
        local _sc = { score_count_1, score_count_2 }

        -- find the first chunk that is different
        local _active = 2

        for i = 1, 2 do
            if _scores[i] != _sc[i] then
                _active = i
                break
            end
        end

        local _diff = _scores[_active] - _sc[_active]

        if _diff > 0 then
            _sc[_active] += max(1, flr(_diff * 0.1))
        end

        score_count_1 = _sc[1]
        score_count_2 = _sc[2]
    end,

    add_score = function(_ENV, _amount)
        score_2 += _amount

        if score_2 >= 10000 then
            score_2 -= 10000
            score_count_2 = score_2
            score_1 += 1
        end
    end,

    get_score = function(_ENV)
        return pad4(score_count_1)
                .. pad4(score_count_2)
    end,
    --[[get_highscore = function(_ENV)
        return pad4(highscore_1)
                .. pad4(highscore_2)
    end,]]

    reset_score = function(_ENV)
        score_1 = 0
        score_2 = 0
        score_count_1 = 0
        score_count_2 = 0
    end,

    init = function(_ENV)
        --highscore_1 = dget(0)
        --highscore_2 = dget(1)
    end,

    update = function(_ENV)
        handle_count(_ENV)
    end,
    draw_ui = function(_ENV)
        local _score_displayed = get_score(_ENV)
        local _x = string_get_center_x(_score_displayed) - cam:get_x()
        print_ui(_score_displayed, _x, y, color_id, outline_color, outline_mask)
    end
})



callout = class:new({
    x = 0,
    y = 0,
    x_spd = 0,
    y_spd = 0,
    duration = 60,
    sprite = 0,
    text = "",
    color_id = white,
    outline_color = nil,
    outline_mask = nil,
    visible = true,
    flicker = false,
    gravity = 0,

    is_dead = function(_ENV)
        return duration <= 0
    end,
    init = function(_ENV)
    end,
    update = function(_ENV)
        y_spd += gravity
        x += x_spd
        y += y_spd
        duration -= 1
        if flicker and duration < 30 then
            if duration % 2 == 0 then
                visible = not visible
            end
        end
    end,
    draw = function(_ENV)
        if visible then
            print_ui(text, x, y, color_id, outline_color, outline_mask)
        end
    end
})


callout_manager.callout_types.ready = callout:new({
    x = 50,
    y = 50,
    y_spd = -0.5,
    gravity = 0.01,
    text = "ready?",
    x = string_get_center_x(text),
    y = string_get_center_y(text),
    duration = 60,
    color_id = white,
    outline_color = 0,
    outline_mask = outline.full,
    flicker = true,
})


callout_manager.callout_types.nice = callout:new({
    x_spd = 0.3,
    y_spd = -0.1,
    gravity = 0.01,
    text = "nice",
    color_id = 12,
    outline_color = 0,
    outline_mask = outline.full,
    flicker = true,
})

callout_manager.callout_types.great = callout:new({
    x_spd = 0.3,
    y_spd = -0.1,
    gravity = 0.01,
    text = "great",
    color_id = 9,
    outline_color = 0,
    outline_mask = outline.full,
    flicker = true,
})

callout_manager.callout_types.holy = callout:new({
    x_spd = 0.3,
    y_spd = -0.1,
    gravity = 0.01,
    text = "holy",
    color_id = 8,
    outline_color = 0,
    outline_mask = outline.full,
    flicker = true,
})



hitbox = class:new({
    owner = nil,
    offset_x = 0,
    offset_y = 0,
    width = 0,
    height = 0,

    left = function(_ENV)
        return owner.x + offset_x
    end,
    top = function(_ENV)
        return owner.y + offset_y
    end,
    right = function(_ENV)
        return left(_ENV) + width - 1
    end,
    bottom = function(_ENV)
        return top(_ENV) + height - 1
    end,

    overlaps = function(_ENV, _other, _move_x, _move_y)
        _move_x = _move_x or 0
        _move_y = _move_y or 0

        return not (top(_ENV) + _move_y > _other:bottom()
                    or _other:top() > bottom(_ENV) + _move_y
                    or left(_ENV) + _move_x > _other:right()
                    or _other:left() > right(_ENV) + _move_x)
    end,

    collision_with_flag = function(_ENV, _flag, _move_x, _move_y)
        _move_x = _move_x or 0
        _move_y = _move_y or 0

        local _left = position_to_tile(left(_ENV) + _move_x)
        local _right = position_to_tile(right(_ENV) + _move_x)
        local _top = position_to_tile(top(_ENV) + _move_y)
        local _bottom = position_to_tile(bottom(_ENV) + _move_y)

        for _tile_y = _top, _bottom do
            for _tile_x = _left, _right do
                if tile_has_flag(_tile_x, _tile_y, _flag) then
                    return true
                end
            end
        end
        return false
    end,

    collision_with_entity = function (_ENV, _list, _move_x, _move_y)
        for _entity in all(_list) do
            if overlaps(_ENV, _entity.hitboxes.body, _move_x, _move_y) then
                return true
            end
        end
    end,

    collision_with_entity_by_tag = function(_ENV, _list, _tag, _move_x, _move_y)
        local _tagged_list = entity_manager:get_entities_by_tag( _tag)
        return collision_with_entity(_ENV, _tagged_list, _move_x, _move_y)
    end,

    draw = function(_ENV, _color)
        rect(left(_ENV), top(_ENV), right(_ENV), bottom(_ENV), _color or 8)
    end
})

hitbox.create = function(_owner, _offset_x, _offset_y, _width, _height)
    return hitbox:new({
        owner = _owner,
        offset_x = _offset_x,
        offset_y = _offset_y,
        width = _width,
        height = _height
    })
end


animation = class:new({
    frames = {1},
    frame_duration = 6,
    playback_mode = playback.loop,
})


animation_player = class:new({
    current_animation = nil,
    frame = 1,
    frame_timer = 0,
    direction = 1,
    finished = false,

    reset_playback = function(_ENV)
        frame = 1
        frame_timer = 0
        direction = 1
        finished = false
    end,

    get_frame = function(_ENV)
        return current_animation.frames[frame]
    end,

    set_animation = function(_ENV, _animation)
        if current_animation == _animation then return end

        current_animation = _animation
        reset_playback(_ENV)
    end,

    handle_playback = function(_ENV)
        local _last_frame = #current_animation.frames
        local _mode = current_animation.playback_mode

        if _mode == playback.loop then
            handle_loop(_ENV, _last_frame)
        elseif _mode == playback.once then
            handle_once(_ENV, _last_frame)
        elseif _mode == playback.ping_pong then
            handle_pingpong(_ENV, _last_frame)
        end
    end,

    handle_loop = function(_ENV, _last_frame)
        if frame > _last_frame then
            frame = 1
        end
    end,

    handle_once = function(_ENV, _last_frame)
        if frame > _last_frame then
            frame = _last_frame
            finished = true
        end
    end,

    handle_pingpong = function(_ENV, _last_frame)
        if frame >= _last_frame then
            frame = _last_frame
            direction = -1
        elseif frame <= 1 then
            frame = 1
            direction = 1
        end
    end,

    update = function(_ENV)
        if not current_animation then return end

        frame_timer += 1
        if frame_timer < current_animation.frame_duration then return end
        frame_timer = 0

        frame += direction

        handle_playback(_ENV)
    end
})


shake_controller = class:new({
    x = 0,
    y = 0,
    timer = 0,
    duration = 0,
    strength = 0,

    shake = function(_ENV, _stg, _dur)
        timer = _dur
        duration = _dur
        strength = _stg
    end,
    update = function(_ENV)
        if timer > 0 then
            local _stg = strength * (timer / duration)
            x = flr(rnd(_stg * 2 + 1)) - _stg
            y = flr(rnd(_stg * 2 + 1)) - _stg

            timer -= 1
        else
            x = 0
            y = 0
        end
    end
})


visual = class:new({
    width = 2,
    height = 2,

    visible = true,

    blink_visible = true,
    blink_duration = 0,
    blink_timer = 0,
    blink_frequency = 3,

    offset_x = 0,
    offset_y = 0,

    flip_x = false,
    flip_y = false,

    animator = {},
    shaker = {},

    animations = {
        default = animation:new()
    },

    set_animation = function(_ENV, _animation)
        animator:set_animation(_animation)
    end,

    set_visible = function(_ENV, _visible)
        visible = _visible
    end,

    check_visible = function(_ENV)
        return visible and blink_visible
    end,

    blink = function(_ENV, _duration, _frequency)
        blink_frequency = _frequency or blink_frequency
        blink_timer = blink_frequency
        blink_duration = _duration
    end,

    toggle_blink = function(_ENV)
        blink_visible = not blink_visible
    end,

    apply_blink = function(_ENV)
        if blink_duration < 0 then 
            blink_visible = true
            return 
        end

        blink_duration -= 1

        if blink_timer > 0 then
            blink_timer -= 1
        else
            toggle_blink(_ENV)
            blink_timer = blink_frequency
        end
    end,

    is_blinking = function (_ENV)
        return blink_duration > 0
    end,

    set_mirrored = function(_ENV, _mirrored)
        flip_x = _mirrored
    end,

    shake = function(_ENV, _strength, _duration)
        shaker:shake(_strength, _duration)
    end,

    init = function(_ENV)
        animator = animation_player:new()
        animator:set_animation(animations.default)

        shaker = shake_controller:new()
    end,
    update = function(_ENV)
        animator:update()
        shaker:update()
        apply_blink(_ENV)
    end,
    draw = function(_ENV, _x, _y)
        _x += offset_x + shaker.x
        _y += offset_y + shaker.y
        if check_visible(_ENV) then
            spr(animator:get_frame(), _x, _y, width, height, flip_x, flip_y)
        end
    end
})



entity = class:new({
    x = 0,
    y = 0,
    z = 0,
    tag = "",
    width = 1,
    height = 1,
    intent_x = 0,
    intent_y = 0,
    velocity_x = 0,
    velocity_y = 0,
    gravity = 0,
    spd = 0,
    destroyed = false,
    hitboxes = nil,
    visuals = {},
    state = "state not set",
    states = {},
    set_state = function(_ENV, s)
        if state == s then return end
        assert(
            states[s],
            "unknown state: " .. s
        )
        state = s
        if states[s].init then
            states[s].init(_ENV)
        end
    end,

    normalize_direction = function(_ENV)
        local s = sqrt((intent_x * intent_x) + (intent_y * intent_y))
        if s > 0.01 then
            intent_x /= s
            intent_y /= s
        end
    end,

    is_active = function(_ENV)
        local _margin = 64
        return y > cam:get_y() - _margin
                and y < cam:get_y() + window_size + _margin
    end,

    destroy = function(_ENV)
        if destroyed then return end
        on_destroy(_ENV)
        destroyed = true
    end,

    on_destroy = function(_ENV)
    end,


    init = function(_ENV)
        hitboxes = {}
        hitboxes.body = hitbox.create(_ENV, 0, 0, width * tile_size, height * tile_size)
        visuals = visual:new({})
        visuals:init()
        if states[state].init then
            states[state].init(_ENV)
        end
    end,
    update = function(_ENV)
        if y > cam:get_y() + window_size + 64 then
            destroy(_ENV)
        end
        if not is_active(_ENV) then return end

        visuals:update()
        states[state].update(_ENV)
    end,
    draw = function(_ENV)
        if not is_active(_ENV) then return end

        visuals:draw(x, y)
        if states[state].draw then
            states[state].draw(_ENV)
        end
    end
})


--Camera
cam = class:new({
    x = 0,
    y = 0,
    spd = 0.2,
    scrolling = false,

    shaker = {},

    get_x = function(_ENV)
        return x
    end,
    get_y = function(_ENV)
        return y
    end,

    shake = function(_ENV, _strength, _duration)
        shaker:shake(_strength, _duration)
    end,

    set_position = function(_ENV, _x, _y)
        x = _x
        y = _y
    end,

    set_scrolling = function(_ENV, _scrolling)
        scrolling = _scrolling
    end,

    reset_position = function(_ENV)
        set_position(_ENV, 0, 0)
        set_scrolling(_ENV, false)
    end,

    gameplay_reset = function(_ENV)
        local _y = map_manager:get_height() - window_size
        set_position(_ENV, map_manager.x_offset, _y)
        set_scrolling(_ENV, true)
    end,

    scroll = function(_ENV)
        if y - spd < 0 then
            set_position(_ENV, map_manager.x_offset, 0)
        else
            y -= spd
        end
    end,

    init = function(_ENV)
        camera(x, y)
        shaker = shake_controller:new()
    end,

    update = function(_ENV)
        if scrolling then
            scroll(_ENV)
        end

        shaker:update()
        local _x = x + shaker.x
        local _y = y + shaker.y
        camera(_x, _y)
    end
})


character = entity:new({
    id = 0, --joystick, negative=cpu

    width = 2,
    height = 2,
    spd = 0.7,
    maxspd = 2,
    vertical_hop_strength = -2,
    side_hop_strength = -1.5,
    gravity = 0.1,
    air_friction = 0.015,
    edge = 7,
    attached_to = nil,
    visuals = {},
    state = "spawn",
    hitboxes = {},
    attach = {
        offset_x = 4,
        offset_y = 4,
        width = 8,
        height = 8
    },
    hop_time = 0,
    add_hop_time = function (_ENV)
        hop_time += 1
    end,
    score_hop_time = function (_ENV)
        if hop_time <= 0 then return end

        if hop_time <= 40 then
            score_manager:add_score(500)
            session:add_nice()
            callout_manager:spawn(callout_manager.callout_types.nice, x - cam:get_x(), y-cam:get_y())
        elseif hop_time <= 60 then
            score_manager:add_score(3000)
            session:add_great()
            callout_manager:spawn(callout_manager.callout_types.great, x - cam:get_x(), y-cam:get_y())
        elseif hop_time > 60 then
            score_manager:add_score(20000)
            session:add_holy()
            callout_manager:spawn(callout_manager.callout_types.holy, x - cam:get_x(), y-cam:get_y())
        end

        reset_hop_time(_ENV)
    end,
    reset_hop_time = function (_ENV)
        hop_time = 0
    end,

    states = {
        spawn = {
            update = function(_ENV)
                set_state(_ENV, "airtime")
                visuals:blink(100, 1)
            end
        },

        attached = {
            init = function(_ENV)
                sfx(2)
                particle_manager:spawn_attach_particle(x, y)
                score_hop_time(_ENV)
            end,
            update = function(_ENV)
                if death_check(_ENV) then return end

                if get_input_direction(_ENV) then
                    visuals:set_animation(visuals.animations.attached)
                    if t % 17 == 0 then
                        sfx(1)
                        particle_manager:spawn_climb_particle(x, y)
                    end
                else
                    visuals:set_animation(visuals.animations.idle)
                end

                apply_input(_ENV)

                attach_check(_ENV)
                if hop_check(_ENV) then return end
                if detach_check(_ENV) then
                    velocity_y = 0.5
                    return
                end

                apply_sprite_mirroring(_ENV)

                stop_on_collision(_ENV)

                apply_wall_motion(_ENV)
                stop_on_collision(_ENV)

                apply_movement(_ENV)
                clamp_position_on_screen_top(_ENV)
            end
        },

        hop = {
            init = function(_ENV)
                sfx(0)
                attached_to = nil
                velocity_x = sign_deadzone(intent_x, 0.1) * 1
                if input_axis_y() > 0 then
                    velocity_y = 1
                elseif input_axis_x() == 0 then
                    velocity_y = vertical_hop_strength
                else
                    velocity_y = side_hop_strength
                end
                visuals:set_animation(visuals.animations.hop)
            end,

            update = function(_ENV)
                add_hop_time(_ENV)
                apply_air_friction(_ENV)
                apply_gravity(_ENV)
                apply_sprite_mirroring(_ENV)

                if fall_check(_ENV) then return end

                apply_movement(_ENV)
            end
        },

        fall = {
            update = function(_ENV)
                add_hop_time(_ENV)
                apply_air_friction(_ENV)
                apply_gravity(_ENV)
                apply_sprite_mirroring(_ENV)

                if attach_check(_ENV) then return end
                if death_check(_ENV) then return end

                apply_movement(_ENV)
            end
        },

        airtime = {
            init = function(_ENV)
                sfx(10)
                reset_hop_time(_ENV)
                velocity_y = -8
                visuals:set_animation(visuals.animations.hop)
            end,

            update = function(_ENV)
                get_input_x(_ENV)
                apply_input_x(_ENV)

                apply_air_friction(_ENV)
                apply_gravity(_ENV)

                apply_sprite_mirroring(_ENV)

                if velocity_y > 0 and attach_check(_ENV) then return end

                if death_check(_ENV) then return end

                apply_movement(_ENV)
            end
        },

        dead = {
            update = function(_ENV)
                reset_hop_time(_ENV)
            end
        }
    },

    -- helpers
    get_input_x = function(_ENV)
        intent_x = input_axis_x()
    end,
    get_input_y = function(_ENV)
        intent_y = input_axis_y()
    end,
    get_input_direction = function(_ENV)
        get_input_x(_ENV)
        get_input_y(_ENV)
        normalize_direction(_ENV)

        if intent_x != 0 or intent_y != 0 then
            return true
        end
    end,

    apply_input_x = function(_ENV)
        velocity_x = intent_x * spd
    end,
    apply_input_y = function(_ENV)
        velocity_y = intent_y * spd
    end,
    apply_input = function(_ENV)
        apply_input_x(_ENV)
        apply_input_y(_ENV)
    end,

    apply_air_friction = function(_ENV)
        velocity_x = approach(velocity_x, 0, air_friction)
    end,

    apply_gravity = function(_ENV)
        velocity_y += gravity
    end,

    clamp_movement = function(_ENV)
        velocity_x = mid(-maxspd, velocity_x, maxspd)
        velocity_y = mid(-maxspd, velocity_y, maxspd)
    end,

    apply_wall_motion = function(_ENV)
        if not attached_to then return end
        if not attached_to.get_velocity_x then return end
        local _wall_velocity_x = attached_to:get_velocity_x()
        local _wall_velocity_y = attached_to:get_velocity_y()

        velocity_x += _wall_velocity_x
        velocity_y += _wall_velocity_y
    end,

    apply_movement = function(_ENV)
        clamp_movement(_ENV)
        x += velocity_x
        y += velocity_y
    end,

    stop_on_collision = function(_ENV)
        if not collision_with_wall(hitboxes.attach, velocity_x, 0) then
            velocity_x = 0
        end
        if not collision_with_wall(hitboxes.attach, 0, velocity_y) then
            velocity_y = 0
        end
    end,

    set_attached_to = function(_ENV, _wall)
        if _wall then
            _wall:set_grabbed(true)
            attached_to = _wall
        end
    end,

    collision_with_wall = function(_hitbox, _move_x, _move_y)
        if _hitbox:collision_with_flag(flags.solid, _move_x, _move_y) then
            return true
        end
        return false
    end,

    collision_with_hazard = function(_hitbox, _move_x, _move_y)
        if _hitbox:collision_with_entity_by_tag(entity_manager.entities, "hazard", _move_x, _move_y)
                or _hitbox:collision_with_flag(flags.hazard, _move_x, _move_y) then
            return true
        end
        return false
    end,

    clamp_position_on_screen_top = function(_ENV)
        if y < cam:get_y() then
            y = cam:get_y()
        end
    end,

    apply_sprite_mirroring = function(_ENV)
        if input_axis_x() < 0 then
            visuals:set_mirrored(true)
        elseif input_axis_x() > 0 then
            visuals:set_mirrored(false)
        end
    end,

    -- checks
    hop_check = function(_ENV)
        if btnp(🅾️) then
            set_state(_ENV, "hop")
            return true
        end
    end,

    fall_check = function(_ENV)
        if velocity_y >= 0 then
            set_state(_ENV, "fall")
            return true
        end
    end,

    attach_check = function(_ENV)
        if not is_on_screen(_ENV) then return end
        if collision_with_wall(hitboxes.attach) and not btn(🅾️) then
            set_state(_ENV, "attached")

            return true
        end
    end,

    detach_check = function(_ENV)
        if not collision_with_wall(hitboxes.attach) then
            attached_to = nil
            set_state(_ENV, "fall")
            return true
        end
        local _on_tile = hitboxes.attach:collision_with_flag(flags.solid, velocity_x, velocity_y)
        if _on_tile then
            attached_to = nil
        end
    end,

    death_check = function(_ENV)
        local _bottom_death = y > cam:get_y() + window_size + 4
        local _hazard_death = collision_with_hazard(hitboxes.hurt)
        if visuals:is_blinking() then _hazard_death = false end

        if _bottom_death or _hazard_death then
            set_state(_ENV, "dead")
            sfx(8)
            sfx(9)
            cam:shake(2, 10)
            return true
        end

        return false
    end,


    init = function(_ENV)
        visuals = visual:new({})
        visuals.animations.idle = animation:new({
            frames = { 16 },
            frame_duration = 6,
            playback_mode = playback.once
        })
        visuals.animations.attached = animation:new({
            frames = { 16, 18, 20, 22, 24, 26 },
            frame_duration = 6,
            playback_mode = playback.loop
        })
        visuals.animations.hop = animation:new({
            frames = { 20 },
            frame_duration = 12,
            playback_mode = playback.once
        })
        visuals:init()
        hitboxes = {}
        hitboxes.body = hitbox.create(_ENV, 0, 0, width * tile_size, height * tile_size)
        hitboxes.hurt = hitbox.create(_ENV, 4, 4, 8, 8)
        hitboxes.attach = hitbox.create(_ENV, attach.offset_x, attach.offset_y, attach.width, attach.height)
    end,
    draw = function(_ENV)
        palt(3, true)
        palt(0, false)
        visuals:draw(x, y)
        palt()
    end
})


-- particle effects
particle = entity:new({
	x = 0,
	y = 0,
	x_offset = 0,
	y_offset = 0,
	lifetime = 60,
	gravity = 0,
	friction = 0,
	radius = 10,
	width = 10,
	height = 10,

	color_id = white,
	growth = 0,
	x_spd = 0,
	y_spd = 0,
	shape = shapes.circle,

	is_dead = function(_ENV)
		return lifetime <= 0
	end,

	update = function(_ENV)
		lifetime -= 1
		radius += growth
		x += x_spd
		y += y_spd

		if friction > 0 then
			x_spd = approach(x_spd, 0, friction)
			y_spd = approach(y_spd, 0, friction)
		end
	end,

	draw = function(_ENV)
		local _x = x + x_offset
		local _y = y + y_offset
		if shape == shapes.circle then
			circfill(_x, _y, radius, color_id)
		end
		if shape == shapes.rectangle then
			rectfill(_x, _y, _x + width, _y + height, color_id)
		end
	end
})

particle_attach = particle:new({
	x_spd = 0.7,
	y_spd = -0.7,
	radius = 3,
	x_offset = 4,
	y_offset = 4,
	lifetime = 30,
	friction = 0.05,
	growth = -0.05
})

particle_wood = particle:new({
	height = 3,
	width = 3,
	direction = 0,
	shape = shapes.rectangle,
})


hazard = entity:new({
    tag = "hazard",
})



scene_manager.scenes.splash = scene:new({
    splashscr="-bx8y8    -#0.\0\0\0\0\0█?p-#a.\0\0\0\0\0\0\0█-#0.\0\0\0\0\0o?0-#a.\0\0\0\0\0\0\0?-#0.\0\0\0\0\0\0         \n   .\0\0\0\0\0\0█?-#.?????~C-#a.\0\0\0\0\0█??0.????????-#0.¥⁙-#a.-#   0.\0\0\0\0\0\0p?-#.\0\0\0\0\0??-#a.\0\0\0\0\0\0\0?-#0.????C-#a.\0\0\0000????-#0.。「▮「「<d-#a.\0•-#  \n   0.???█\0\0\0\00a.????????.?○??????-#0.■▮??<、-#a.????-#0.\0、???88「-#a.\0\0\0???-#0.\0\0\0\0⬇️?8\0-#a.\0\0\0\0\0\0??-#0.\0\0?|?⬇️█?-#a.\0\0\0█`|○?-#0.????????-#a.`088<>>?0.????????.???????○-#0.``08、-#a.゜゜\0\0-#  \n   0.\0\0\0████?0a.????????.?○??????.?、゛???◆?.??????w7.??????x>.??◆?\0\0?.????????.???????○-#0.??p8、>??-#a.?゜\0<-#0.\0\0\0\0\0\0  \n   -#.?????ppx-#a.\0\0\0\0\0███0.????○???.????゛\0??.?▒????.█??????.゜????.`p<?゜◆??.??????○?.?????.xpppy???-#0.\r-#a.\0\0\0-#  \n  0.\0\0\0\0████-#.、3•゜?-#a.??????? 0.?????█?.?????\0゜?.?○○?゜◆??.?\0x????.?~、????.???█♥◆゜?.?????0&.██??????.???○????-#0.。「「「-#a.\0-#  \n  -#0.█??p8x??-#a.\0\0\0█?█\0\00.、???????.???゜\0.?○|8「██.??゜♥???.○??◆????.???♥⬇️???.????????.C???????.????????-#0.\0\0█?`8、-#a.??○?゜-#0.\0\0\0\0\0-#a.\0\0\0\0\0\0\0-#  \n  -#0.p088、、<<-#a.█???????a 0.????\0\0\0.?⁙「🐱?-#.゛8>○{-#a.??????██0.??⬇️゜???.?○゜\0\0a?.????????.????????-#0.\0█??p8p`-#a.?○?゜゜-#0.\0\0\0\0\0   \n  -#.|????\0\0\0-#a.█\0\0\0\0\0\0\0-#0.\0\0????█-#a.????\0\0\0\0-#0.██??a7゜゜-#a.○○?゜゛\0\0-#0.??\0\0\0\0\0-#.y08<???\0-#a.█???\0\0\0\0-#0.\0\0??゜?○😐-#a.????0█p-#0.8゛??Q[[•-#a.\0\0????-#0.?????uUQ-#a.?\0\0\0&⌂??0.???▮-#0.@l|<゛-#a.?⁙\0\0\0-#    \n    0.\0\0\0\0\0\0  .??\0\0\0\0\0\0.??\0\0\0\0\0\0.??\0\0\0\0\0\0.゜\0\0\0\0\0\0     ",
    fdstart = true,
    logotimer = 120,

    init = function(_ENV)
        cam:reset_position()
    end,

    update = function(_ENV)
        logotimer -= 1

        if anybtnp() or logotimer <= 0 then
            global.fadestep = 16
            fademax()
            scene_manager:set_scene(scene_manager.scenes.startsc)
        end
    end,

    draw = function(_ENV)
        fills(5)
        draw_string_texture(splashscr)

        if fdstart then
            fadein(white, 2)
        end
        if fadestop == "in"
                and logotimer < 60 then
            fdstart = false
            fadeout(white, 2)
        end
    end
})


scene_manager.scenes.credits = scene:new({
    
    init = function(_ENV)
        cam:reset_position()
    end,

    update = function(_ENV)
        if anybtnp() then
            sfx(4)
            scene_manager:set_scene(scene_manager.scenes.mainmenu)
        end
    end,

    draw = function(_ENV)
        fills(0)
        _credits = [[
        game made by
        giulianno bessa (illugion)
        ]]
        print(_credits, cam:get_x() - 32, 32, 7)
    end
})


scene_manager.scenes.gameover = scene:new({
    init = function(_ENV)
        cam:reset_position()
        random_tip = flr(rnd(5))
    end,

    update = function(_ENV)
        if btnp(❘) then
            sfx(7)
            scene_manager:set_scene(scene_manager.scenes.mainmenu)
        end
    end,

    draw = function(_ENV)
        fills(5)
        local _string = "game over"
        local _x = string_get_center_x(_string)
        local _y = string_get_center_y(_string)
        print_with_outline(_string, _x, _y, white, 0, outline.full)
        print_menu_buttons()

        if random_tip <= 1 then
            printcenter("tip: let go of hop", 0, 0, 40)
            printcenter("to grab walls", 0, 0, 46)
        elseif random_tip == 2 then
            printcenter("tip: all hop arcs", 0, 0, 40)
            printcenter("are fixed", 0, 0, 46)
        elseif random_tip == 3 then
            printcenter("tip: move as close to the edge", 0, 0, 40)
            printcenter("as possible before hopping", 0, 0, 46)
        else
            printcenter("tip: you can hold hop", 0, 0, 40)
            printcenter("to free fall", 0, 0, 46)
        end
    end
})


scene_manager.scenes.gameplay = scene:new({
    count_end = 60*5,
    check_win = function(_ENV)
        local _player = player_manager:get_player()
        

        if cam:get_y() <= 0 then
            count_end -=1
        end

        return _player.y < 0 or count_end <= 0
    end,

    on_stage_start = function()
        map_manager:init()
        cam:gameplay_reset()
        player_manager:reset_player()
        callout_manager:show_ready()
    end,
    on_stage_end = function()
        entity_manager:clear_all_entities()
    end,
    
    on_scene_exit = function(_ENV)
        on_stage_end()
        map_manager:reset_stage_count()
        session:reset_gamemode()
    end,

    go_to_next_stage = function(_ENV)
        on_stage_end()
        map_manager:next_stage()
        on_stage_start()
    end,

    init = function(_ENV)
        on_stage_start()
        count_end = 60*10
    end,

    update = function(_ENV)
        map_manager:update()

        if player_manager:is_player_dead() then
            session.lives -= 1
            player_manager:reset_player()
        end

        if check_win(_ENV) then
            if session:get_gamemode() != "stageselect" and not map_manager:is_last() then
                go_to_next_stage(_ENV)
            else
                scene_manager:set_scene(scene_manager.scenes.victory)
            end
        end

        if session.lives < 0 then
            scene_manager:set_scene(scene_manager.scenes.gameover)
        end
    end,

    draw = function(_ENV)
        cls()
        map_manager:draw()
    end,

    draw_ui = function (_ENV)
        print_ui("lives: " .. session.lives, 0, 0, white, 0, outline.full)
        hud:draw()
        if cam:get_y() <= 0 then
            local _s = "you did it!"
            local _sx = string_get_center_x(_s)  - cam:get_x()
            local _sy = 40
            print_ui(_s, _sx, _sy, white, 0, outline.full)
            local _s = "exiting in"
            local _sx = string_get_center_x(_s)  - cam:get_x()
            _sy += 10
            print_ui(_s, _sx, _sy, white, 0, outline.full)
            local _s = tostr(flr(count_end/60 + 1))
            local _sx = string_get_center_x(_s)  - cam:get_x()
            _sy += 8
            print_ui(_s, _sx, _sy, 8, 0, outline.full)
        end
        score_manager:draw_ui()
    end,
})


scene_manager.scenes.startsc = scene:new({
    startlabel = true,

    init = function(_ENV)
        cam:reset_position()
    end,
    update = function(_ENV)
        if anybtnp() then
            sfx(7)
            scene_manager:set_scene(scene_manager.scenes.mainmenu)
        end
    end,

    draw = function(_ENV)
        fadein(white, 1)

        fills(2)

        draw_title()

        local _string = "press 🅾️ or ❘"
        local _x = string_get_center_x(_string)
        local _y = string_get_center_y(_string) + 32
        print_with_outline(_string, _x, _y + 1, 10, 0, outline.full)

        if startlabel then
            print_with_outline(_string, _x, _y + 1, white, 0, outline.full)
            print_with_outline(_string, _x, _y, white, 0, outline.full)
        end

        if t % 20 == 0 then
            startlabel = not startlabel
        end

        printcenter("GAME BY", 0, 0, 0)
        printcenter("GIULIANNO BESSA (ILLUGION)", 0, 0, 8)
    end
})


scene_manager.scenes.victory = scene:new({
    init = function(_ENV)
        lives_left = session:get_lives()
        nice_done = session:get_nice()
        great_done = session:get_great()
        holy_done = session:get_holy()

        cam:reset_position()
        _c = 4

        for i = 1, lives_left do
            score_manager:add_score(10000)
        end

        --[[if score_greater(
            score_manager.score_1, score_manager.score_2,
            score_manager.highscore_1, score_manager.highscore_2
        ) then
            score_manager.highscore_1 = score_manager.score_1
            score_manager.highscore_2 = score_manager.score_2

            dset(0, score_manager.highscore_1)
            dset(1, score_manager.highscore_2)
        end]]
    end,

    update = function(_ENV)
        if btnp(❘) then
            sfx(7)
            scene_manager:set_scene(scene_manager.scenes.mainmenu)
        end
    end,

    draw = function(_ENV)
        fills(6)
        local _s = "victory!"
        local _x = string_get_center_x(_s)
        local _y = string_get_center_y(_s) - 32
        print_with_outline(_s, _x, _y, white, 0, outline.full)
        _s = "lives left: " .. tostr(lives_left) .. " x 10000"
        _x = string_get_center_x(_s)
        _y += 10

        print_with_outline(_s, _x, _y, white, 0, outline.full)
        _s = "nice hops: " .. tostr(nice_done) .. " x 500"
        _x = string_get_center_x(_s)
        _y += 10
        print_with_outline(_s, _x, _y, white, 0, outline.full)
        _s = "great hops: " .. tostr(great_done) .. " x 3000"
        _x = string_get_center_x(_s)
        _y += 10
        print_with_outline(_s, _x, _y, white, 0, outline.full)
        _s = "holy hops: " .. tostr(holy_done) .. " x 20000"
        _x = string_get_center_x(_s)
        _y += 10
        print_with_outline(_s, _x, _y, white, 0, outline.full)

        _s = "final score: " .. tostr(score_manager:get_score())
        _x = string_get_center_x(_s)
        _y += 20
        if t % 3 == 0 then
            _c += 1
        end
        if _c > 15 then _c = 4 end
        print_with_outline(_s, _x, _y, _c, 0, outline.full)

        --[[_s = "high score: " .. tostr(score_manager:get_highscore())
        _x = string_get_center_x(_s)
        _y += 10
        print_with_outline(_s, _x, _y, white, 0, outline.full)]]

        print_menu_buttons()
    end
})


scene_manager.scenes.mainmenu = scene:new({
    selection = {
        "play",
        --"credits",
        "system"
    },
    selected = 1,
    bar_y = window_center + 8 + 6,

    init = function(_ENV)
        cam:reset_position()
        session:reset_stats()
    end,

    update = function(_ENV)
        local _delta = input_axis_y_pressed()
        if _delta != 0 then
            sfx(3)
            selected = move_selection(
                selected,
                selection, _delta
            )
        end

        if btnp(🅾️) then
            
            local _selection = selection[selected]

            if _selection == "system" then
                extcmd("pause")
            elseif _selection == "play" then
                sfx(6)
                scene_manager:set_scene(scene_manager.scenes.gameplay)
                session.modeselected = 1
            elseif _selection == "credits" then
                sfx(7)
                scene_manager:set_scene(scene_manager.scenes.credits)
            end
        end
        if btnp(❘) then
            sfx(4)
            scene_manager:set_scene(scene_manager.scenes.startsc)
            selected = 1
        end
    end,

    draw = function(_ENV)
        pal()
        fills(1)

        draw_title()
        
        bar_y = approach(bar_y, window_center + 8 + selected * 6, 2)
        rectfill(0, bar_y - 3, 128, bar_y + 6, 8)

        for i = 1, #selection, 1 do
            local _c = 8
            local _y_off = 0
            if i == selected then
                _c = white
                _y_off = -1
            end
            local _x = string_get_center_x(selection[i])
            local _y = window_center + 8 + i * 6 + _y_off
            print_with_outline(selection[i], _x, _y + 1, _c, 0, outline.full)
            print_with_outline(selection[i], _x, _y, _c, 0, outline.full)
        end

        print_menu_buttons()
    end
})







-- transitions

--COULD IMPLEMENT ASYNC STUFF HERE

-- starttransit(transit,time)
-- sets current transition and
-- time for the animation
-- stops at the fullest point
-- and waits for exit

-- exittransit()
-- uses the current transition
-- and timer to exit

local fadetable = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 1, 129, 129, 129, 129, 129, 129, 129, 129, 0, 0, 0, 0, 0 },
    { 2, 2, 2, 130, 130, 130, 130, 130, 128, 128, 128, 128, 128, 0, 0 },
    { 3, 3, 3, 131, 131, 131, 131, 129, 129, 129, 129, 129, 0, 0, 0 },
    { 4, 4, 132, 132, 132, 132, 132, 132, 130, 128, 128, 128, 128, 0, 0 },
    { 5, 5, 133, 133, 133, 133, 130, 130, 128, 128, 128, 128, 128, 0, 0 },
    { 6, 6, 134, 13, 13, 13, 141, 5, 5, 5, 133, 130, 128, 128, 0 },
    { 7, 6, 6, 6, 134, 134, 134, 134, 5, 5, 5, 133, 130, 128, 0 },
    { 8, 8, 136, 136, 136, 136, 132, 132, 132, 130, 128, 128, 128, 128, 0 },
    { 9, 9, 9, 4, 4, 4, 4, 132, 132, 132, 128, 128, 128, 128, 0 },
    { 10, 10, 138, 138, 138, 4, 4, 4, 132, 132, 133, 128, 128, 128, 0 },
    { 11, 139, 139, 139, 139, 3, 3, 3, 3, 129, 129, 129, 0, 0, 0 },
    { 12, 12, 12, 140, 140, 140, 140, 131, 131, 131, 1, 129, 129, 129, 0 },
    { 13, 13, 141, 141, 5, 5, 5, 133, 133, 130, 129, 129, 128, 128, 0 },
    { 14, 14, 14, 134, 134, 141, 141, 2, 2, 133, 130, 130, 128, 128, 0 },
    { 15, 143, 143, 134, 134, 134, 134, 5, 5, 5, 133, 133, 128, 128, 0 }
}

local whitetable = {
    { 0, 128, 130, 133, 5, 5, 5, 134, 134, 134, 134, 6, 6, 6, 7 },
    { 1, 1, 5, 5, 13, 13, 13, 13, 13, 6, 6, 6, 6, 6, 7 },
    { 2, 141, 141, 134, 134, 134, 134, 134, 6, 6, 6, 6, 6, 7, 7 },
    { 3, 3, 3, 3, 13, 13, 13, 13, 6, 6, 6, 6, 6, 7, 7 },
    { 4, 4, 4, 134, 134, 134, 143, 143, 143, 15, 15, 15, 15, 7, 7 },
    { 5, 5, 134, 134, 134, 134, 134, 134, 6, 6, 6, 6, 6, 7, 7 },
    { 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7 },
    { 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 },
    { 8, 8, 8, 142, 142, 14, 14, 14, 14, 14, 15, 15, 15, 7, 7 },
    { 9, 9, 9, 10, 10, 143, 143, 135, 135, 15, 15, 15, 15, 7, 7 },
    { 10, 10, 10, 135, 135, 135, 135, 135, 135, 15, 15, 15, 7, 7, 7 },
    { 11, 11, 11, 11, 11, 138, 138, 6, 6, 6, 6, 6, 6, 7, 7 },
    { 12, 12, 12, 12, 12, 12, 6, 6, 6, 6, 6, 6, 7, 7, 7 },
    { 13, 13, 13, 13, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7 },
    { 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 7, 7, 7, 7 },
    { 15, 15, 15, 15, 15, 15, 15, 7, 7, 7, 7, 7, 7, 7, 7 }
}

fadestep = 16
fadestop = "out"

function fademax()
    fadestep = 16
    fadestop = "out"
end

function fademin()
    fadestep = 1
    fadestop = "in"
end
function fadein(tgt, intrv)
    local mode = "in"
    if t % intrv == 0
            and fadestep >= 1
            and fadestop != "in" then
        fade(mode, tgt, intrv)
        fadestep -= 1
    end
    if fadestep < 1 then
        pal()
        fadestop = "in"
    end
end

function fadeout(tgt, intrv)
    local mode = "out"
    if t % intrv == 0
            and fadestep < 15
            and fadestop != "out" then
        fade(mode, tgt, intrv)
        fadestep += 1
    end
    if fadestep >= 15 then
        fadestop = "out"
    end
end

function fade(mode, tgt, intrv)
    local i = fadestep
    local ftable = fadetable
    local _color = 0
    if tgt == white then
        ftable = whitetable
        _color = white
    end
    for c = 0, 15 do
        if mode == "out"
                and flr(i + 1) <= 1 then
            pal()
        end
        if mode == "in"
                and flr(i + 1) >= 16 then
            pal(c, _color)
        else
            pal(c, ftable[c + 1][flr(i + 1)])
        end
    end
end


function for_all(_table,_callback)
    for _item in all(_table) do
        _callback(_item)
    end
end

function init_all(_table)
    for_all(_table,function(t)
    t:init()
    end)
end

function update_all(_table)
    for_all(_table,function(t)
    t:update()
    end)
end

function draw_all(_table)
    for_all(_table,function(t)
    t:draw()
    end)
end

function table_average(_table)
  if #_table == 0 then
    return 0
  end

  local sum = 0
  for v in all(_table) do
    sum += v
  end

  return sum / #_table
end



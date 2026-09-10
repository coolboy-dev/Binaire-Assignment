--retro rewind 1 (standalone)
--by mabbees and cj

function _init()	
	-- global state
	t = 0
	scn = {}
	
	tracks = {
		"retro_rewind_1_trk1",
		"retro_rewind_1_trk2",
		"retro_rewind_1_trk3",
		"retro_rewind_1_trk4",
	}
	
	local is_bbs = stat(101) != nil
	local function preload()
		local dat = join(tracks)
		dat ..= ","..stat(101)
		load("#retro_rewind_1_trk1",nil,dat)
	end
	if is_bbs then
		for cart in all(tracks) do
			if reload(0,0,1,cart..".p8.png")==0 then
				preload()
			end
		end
		reload(0,0,1)
	end

	-- flow
	local game_flow = flow.seq({
		presented_by_scn,
		flow.loop(
			flow.seq({
				title_scn,
				casette_scn,
				-- reload spritesheet and map
				flow.once(function(nxt)
					reload(
						0x0000,
						0x0000,
						0x3000
					)
					return {
						draw = noop,
						update = nxt,
					}
				end),
			})
		),
	})

	local trans = transition_scn(fade_to_black)
	transition_flow(game_flow, trans).go(
		function(s)
			scn = s
		end,
		noop
	)
end

function _draw()
	cls()
	
	draw_scn(scn)
		()
end

function _update()
	local t0 = t
	t = time()
	local dt = t-t0
	
	scn:update(dt)
end

-->8
-- library

-- functions ------------------

-- requires:
-- none!


function id(d) return d end

function const(x)
	return function() return x end
end

function noop() end

function compose(f,g)
	return function(...)
		return g(f(...))
	end
end

function apply(x,f)
	return f(x)
end

function suspend(f)
	return function(...)
		local args = {...}
		return function()
			f(unpack(args))
		end
	end
end

function reduce(f,seed)
	return function(list)
		local ret = seed
		for x in all(list) do
			ret = f(ret, x)
		end
		return ret
	end
end

chain = reduce(compose,id)

function once(f)
	local done
	return function(val)
		if not done then
			done = true
			f(val)
		end
	end
end

function list_copy(list)
	local ret = {}
	foreach(list, function(x)
		add(ret,x)
	end)
	return ret
end

function list_append(xs,last)
	local ret = list_copy(xs)
	add(ret,last)
	return ret
end

function list_cons(x)
	return function(xs)
		return {x, unpack(xs)}
	end
end




-- math functions -------------

-- requires:
-- none!


function lerp(a,b)
	return function(t)
		return a + t*(b-a)
	end
end

function remap(s0,s1,d0,d1)
	return function(t)
		local u = (t-s0)/(s1-s0)
		return d0 + u*(d1-d0)
	end
end

function scale(s)
	return function(x)
		return s*x
	end
end


-- algebriac functions --------

-- requires:
-- * func (const, list_append, reduce)


function monad_loop(m)
	return m:flatmap(function()
		return monad_loop(m)
	end)
end

-- traverse a list, accumulate all results
function monad_seq_all(empty)
	return reduce(function(acc,p)
		return acc:flatmap(function(xs)
			return p:map(function(x)
				return list_append(xs,x)
			end)
		end)
	end, empty)
end

-- traverse a list, return the last result
function monad_seq(empty)
	return reduce(
		function(a,m)
			return a:flatmap(const(m))
		end,
		empty
	)
end

function monoid_concat(empty)
	return reduce(
		function(a,m)
			return a:concat(m)
		end,
		empty
	)
end

function lift(f)
	return function(mx)
		return mx:map(f)
	end
end

function lift2(f)
	return function(mx,my)
		return mx:flatmap(function(x)
			return my:map(function(y)
				return f(x,y)
			end)
		end)
	end
end

function lift_a2(f)
	return function(ax,ay)
		local af = ax:map(function(x)
			return function(y)
				return f(x,y)
			end
		end)
		return ay:apply(af)
	end
end


-- emit -----------------------

-- requires:
-- * func    (apply, noop)
-- * algebra (monad_seq)


emit = {}

emit_meta = {
	__index={
		map=function(e,f)
			return emit.create(function(cb)
				e.run(compose(f,cb))
			end)
		end,
		filter=function(e,f)
			return emit.create(function(cb)
				e.run(function(x)
					if(f(x)) then
						cb(x)
					end
				end)
			end)
		end,
		flatmap=function(e,f)
			return emit.create(function(cb)
				e.run(function(x)
					f(x).run(cb)
				end)
			end)
		end,
		thru=apply,
	}
}

function emit.create(run)
	return setmetatable({
		run=run
	},emit_meta)
end

function emit.of(val)
	return emit.create(function(cb)
		cb(val)
	end)
end

emit.seq = monad_seq(emit.of(nil))

-- return a linked
-- emitter/trigger pair
function emit.fork()
	local cb = noop
	local function call_both(f,g)
		return function(x)
			f(x)
			g(x)
		end
	end
	local e = emit.create(function(f)
		cb = call_both(cb,f)
	end)
	local b = function(x)
		cb(x)
	end
	return e,b
end


-- reader ---------------------

-- requires:
-- * func (apply)

function rdr(f)
	return setmetatable(
		{ run=f },
		rdr_meta
	)
end

rdr_meta={
	__index={
		map=function(r,f)
			return rdr(
				compose(r.run, f)
			)
		end,
		flatmap=function(r,f)
			return rdr(
				function(e)
					return f(r.run(e)).run(e)
				end
			)
		end,
		memo=function(r,hash)
			-- todo: make sure memo is declared?
			return rdr(memo(r.run, hash))
		end,
		thru = apply,
	}
}

rdr_local=function(f,r)
	return rdr(compose(f, r.run))
end



-- list -----------------------

-- requires:
-- * func    (apply, compose, reduce)
-- * algebra ()

list = {}

function list_map(l,f)
	local ret = {}
	for i,x in ipairs(l) do
		add(ret, f(x,i))
	end
	return list.create(ret)
end

function list_flatmap(l,f)
	return list.concat(list_map(l,f))
end

function list_filter(l,f)
	local ret = {}
	foreach(l, function(x)
		if f(x) then
			add(ret, x)
		end
	end)
	return list.create(ret)
end

function list_concat(l1,l2)
	local ret = {}
	local function append(x)
		add(ret,x)
	end
	foreach(l1, append)
	foreach(l2, append)
	return list.create(ret)
end

function list_reduce(l,f,seed)
	return reduce(f,seed)(l)
end

list_meta = {
	__index= {
		map     = list_map,
		flatmap = list_flatmap,
		filter  = list_filter,
		concat  = list_concat,
		reduce  = list_reduce,
		thru    = apply,
	}
}

function list.create(tbl)
	return setmetatable(tbl,list_meta)
end

list.from_tbl = compose(list_copy, list.create)

function list.from_range(lo,hi)
	local ret = {}
	for i=lo,hi do
		add(ret,i)
	end
	return list.create(ret)
end

function list.repeat_n(v,n)
	local ret = {}
	for i=1,n do
		add(ret,v)
	end
	return list.create(ret)
end

list.empty = list.create({})

list.concat = monoid_concat(list.empty)



-- signal ---------------------

-- requires:
-- * func    (apply, const, id)
-- * algebra (lift_a2)
-- * list    (list.from_tbl)

signal = {}

signal_meta = {
	__mul=lift_a2(function(x,y)
		return x*y
	end),
	__add=lift_a2(function(x,y)
		return x+y
	end),
	__sub=lift_a2(function(x,y)
		return x-y
	end),
	__index={
		map=function(s,f)
			return signal.create(
				compose(s.at, f),
				s.dur
			)
		end,
		apply=function(s,s2)
			return signal.create(function(t)
				local x = s.at(t)
				local f = s2.at(t)
				return f(x)
			end, min(s.dur, s2.dur))
		end,
		ease=function(s,e)
			return signal.create(
				compose(e,s.at),
				s.dur
			)
		end,
		delay=function(s,d)
			return signal.create(function(t)
				return s.at(max(0,t-d))
			end, s.dur+d)
		end,
		hold=function(s,d)
			return signal.create(function(t)
				return s.at(min(t, s.dur))
			end, s.dur+d)
		end,
		scale=function(s,fac)
			return signal.create(function(t)
				return s.at(t/fac)
			end, s.dur*fac)
		end,
		concat=function(s,s2)
			return signal.create(function(t)
				return t <= s.dur
					and s.at(t)
					or s2.at(t - s.dur)
			end, s.dur + s2.dur)
		end,
		thru = apply,
	},
}

function signal.create(at, dur)
	dur = dur or 1
	return setmetatable({
		at=at,
		dur=dur
	}, signal_meta)
end

function signal.const(v,d)
	return signal.create(const(v),d)
end

signal.linear = signal.create(id)

signal.concat = monoid_concat(signal.const(nil,0))

function signal.from_tbl(tbl)
	local dur = 0
	for k,v in pairs(tbl) do
		dur = max(v.dur, dur)
	end
	return signal.create(function(t)
		local ret = {}
		for k,v in pairs(tbl) do
			ret[k] = v.at(t)
		end
		return ret
	end, dur)
end

function signal.from_list(tbl)
	local dur = 0
	for v in all(tbl) do
		dur = max(v.dur, dur)
	end
	return signal.create(function(t)
		return list.from_tbl(tbl)
			:map(function(s)
				return s.at(t)
			end)
	end, dur)
end


-- song -----------------------

-- requires:
-- * emit    (fork)
-- * func    (id)

function is_music_playing()
	return stat(54) > -1
end

function memo_once(f)
	local cache1, cache2
	return function(...)
		if not cache1 then
			cache1, cache2 = f(...)
		end
		return cache1, cache2
	end
end


function pause_music(pat)
	pat = pat or 0
	music(-1)

	return {
		is_playing = false,
		play = memo_once(function()
			return play_song(pat)
		end),
		update = id,
	}
end

function play_song(pat)
	pat = pat or 0
	music(pat)
	
	local on_finish, do_finish = emit.fork()
	return {
		is_playing = true,
		pause = memo_once(function(s)
			local pat = stat(54)
			return pause_music(pat)
		end),
		update = function(s,dt)
			local did_finish = s.is_playing
				and not is_music_playing()
			if did_finish then
				do_finish()
				return pause_music()
			end
			return s
		end,
	}, on_finish
end

function song()
	local trk = pause_music()
	local on_finish, do_finish = emit.fork()
	return {
		on_finish = on_finish,
		is_playing = function()
			return trk.is_playing
		end,
		update = function(s,dt)
			trk = trk:update(dt)
		end,
		play = function(s)
			if trk.play then
				local new_trk, trk_finish = trk:play()
				trk_finish.run(do_finish)
				trk = new_trk
			end
		end,
		pause = function(s)
			if trk.pause then
				local new_trk = trk:pause()
				trk = new_trk
			end
		end,
		thru = apply,
	}
end


-- flow -----------------------

-- requires:
-- * func    (apply, compose, once)
-- * algebra (monad_loop, monad_seq)

flow = {}

flow_meta={
	__index={
		map=function(m,f)
			return flow.create(
				function(nxt, done)
					m.go(nxt, compose(f,done))
				end)
		end,
		flatmap=function(m,f)
			return flow.create(
				function(nxt, done)
					m:map(f).go(nxt, function(n)
						n.go(nxt, done)
					end)
				end)
		end,
		thru = apply,
	}
}

function flow.create(go)
	return setmetatable({
		go=go
	},flow_meta)
end

function flow.of(value)
	return flow.create(function(nxt, done)
		done(value)
	end)
end

function flow.once(make_scene)
	return flow.create(function(nxt, done)
		nxt(make_scene(once(done)))
	end)
end

flow.seq = monad_seq(flow.of(nil))

flow.loop = monad_loop



-- behavior -------------------
-- (includes error handling)

-- requires:
-- * func    (apply, const, id, noop)
-- * list    (list_map)
-- * algebra (monad_loop, monad_seq)

behavior = {}


b_success_meta={
	__index={
		type="success",
		map=function(b,f)
			return behavior.success(f(b.value))
		end,
		flatmap=function(b,f)
			return f(b.value)
		end,
		handle_err=function(b,f)
			return b
		end,
		thru = apply,
	}
}
function behavior.success(value)
 return setmetatable({
 	value=value,
 }, b_success_meta)
end

b_error_meta={
	__index={
		type="error",
		map=id,
		flatmap=id,
		handle_err=function(b,f)
			return f(b.error)
		end,
		thru = apply,
	}
}
function behavior.error(error)
 return setmetatable({
 	error=error,
 }, b_error_meta)
end

b_running_meta={
	__index={
		type="running",
		map=function(b,f)
			return behavior.run(function(actor,dt)
				return b.update(actor,dt):map(f)
			end)
		end,
		flatmap=function(b,f)
			return behavior.run(function(actor,dt)
				return b.update(actor,dt):flatmap(f)
			end)
		end,
		handle_err=function(b,f)
			return behavior.run(function(actor,dt)
				return b.update(actor,dt):handle_err(f)
			end)
		end,
		thru = apply,
	}
}
function behavior.run(update)
	local nxt = {}
	
	local b = setmetatable({
		update=function(actor,dt)
			return update(actor,dt,nxt)
		end,
	}, b_running_meta)
	
	nxt.done = behavior.success
	nxt.err  = behavior.error
	nxt.cont = const(b)
	
	return b
end

behavior.seq = monad_seq(behavior.success(nil))

function behavior.par(bs)
	for b in all(bs) do
		if b.type == "error" then return b end
	end
	for b in all(bs) do
		if b.type == "success" then return b end
	end
	
	return behavior.run(function(actor,dt)
		return behavior.par(
			list_map(bs, function(b)
				return b.update(actor,dt)
			end)
		)
	end)
end

behavior.loop = monad_loop

function behavior.once(f)
	return behavior.run(function(actor,dt,nxt)
		return nxt.done(f(actor,dt))
	end)
end

function behavior.always(f)
	return behavior.run(function(actor,dt,nxt)
		f(actor,dt)
		return nxt.cont()
	end)
end

function behavior.poll(f)
	return behavior.run(function(actor,dt,nxt)
		return f(actor)
			and nxt.done()
			or  nxt.cont()
	end)
end

behavior.never = behavior.always(noop)


-- text utils -----------------

-- requires:
-- none!


function wrap_lines(txt,width)
	local buffer,len = "", 0

	for i, word in words(txt) do
		local w = word_width(word)
		if len+w > width then
			-- push next word to next line
			buffer = buffer.."\n"..word
			len=w
		else
			-- next word still fits on the line
			buffer = buffer..word
			len += w
		end
		
		if txt[i-1] == "\n" then
			-- word break is also a line break
			buffer = buffer.."\n"
			len=0
		else
			-- word break is a space
			buffer = buffer.." "
			len += 4
		end
	end
	
	return buffer
end

function words(txt)
	local function iter(txt, start)
		if start > #txt then return nil end
		for i=start,#txt do
			if txt[i] == " " or txt[i] == "\n" then
				return i+1, sub(txt,start,i-1)
			end
		end
		return #txt+1, sub(txt,start,#txt)
	end
	return iter, txt, 1
end

function word_width(word)
	-- todo: adjust for special
	-- characters, but don't call
	-- "print" because it is slow
	
	-- hacks for special characters
	if word[1] == "❘" or word[1] == "🅾️" then
		return 3 + 4 * #word
	end
	
	return 4 * #word
end

function text_width(txt)
	local w = print(txt, 0, -1000)
	-- todo: save/restore cursor?
	cursor()
	return w
end

function text_height(txt)	
	-- todo: wrong result
	-- when txt has p8scii
	-- tall mode turned on
	local height=6
	for i=1,#txt do
		local c = txt[i]
		if c=="\n" then
			height += 6
		end
	end
	return height
end

function glyphs(txt)
	local gen = all(txt)
	return function()
		local c = gen()
		-- coalesce one-off chars
		if c == "" then
			for i=0,16 do
				c ..= gen()
			end
		end
		return c
	end
end

function str_len(str)
	local l = 0
	for s in glyphs(str) do
		l+=1
	end
	return l
end

function str_sub(str, len)
	local ret = ""
	local l = 0
	for s in glyphs(str) do
		if l >= len then
			return ret
		end
		ret ..= s
		l += 1
	end
	return ret
end



-- ui components --------------

-- requires:
-- * func    (apply, const, id)
-- * algebra (?)
-- * reader  (rdr, rdr_local)
-- * text    (text_height, text_width, wrap_lines)

-- memoization helpers
function memo(f, hash)
	hash = hash or id
	local cache = {}
	return function(x)
		local key = hash(x)
		if cache[key] == nil then
			cache = prune(cache,4)
			cache[key] = f(x)
		end
		return cache[key]
	end
end

function prune(tbl,n)
	local ret, i = {}, n
	for k,v in pairs(tbl) do
		ret[k] = v
		i -= 1
		if i <= 0 then break end
	end
	return ret
end

function hash_dims(dims)
	local w,h=unpack(dims)
	return w..":"..h
end

-- 
local ui = {}

zeros=rdr(const({0,0}))

no_offset=zeros

empty_dims=zeros

screen_bounds = {0,0,128,128}

full_dims=rdr(id)

function measure_ui(c, bnds)
	local ox,oy,ow,oh = unpack(bnds)
	local x,y = unpack(c.offset.run({ow,oh}))
	local w,h = unpack(c.dims.run({ow,oh}))
	return {x+ox,y+oy,w,h}
end

function draw_ui(c, bnds)
	c:draw(measure_ui(c,bnds))
end

-- constructors
function ui.create(def)
	return setmetatable(def, ui_meta)
end

function ui.from_draw(draw)
	return ui.create({
		offset   = no_offset,
		min_dims = empty_dims,
		dims     = full_dims,
		draw = function(c,bnds)
			draw(unpack(bnds))
		end,
	})
end

function ui.from_ui(c1,c2)
	local keys={
		"draw",
		"offset",
		"min_dims",
		"dims",
	}
	local copy={}
	for key in all(keys) do
		copy[key] = c2[key] or c1[key]
	end
	return ui.create(copy)
end

function ui.from_rdr(r)
	return ui.create({
		draw     = function(tbl,bnds)
			local x,y,w,h = unpack(bnds)
			local c = r.run({w,h})
			c.draw(tbl,bnds)
		end,
		offset   = r:flatmap(function(c) return c.offset end),
		min_dims = r:flatmap(function(c) return c.min_dims end),
		dims     = r:flatmap(function(c) return c.dims end),
	})
end

-- layouts
function ui_offset(c,dx,dy)
	return ui.from_ui(c, {
		offset = c.offset:map(function(off)
			local x,y = unpack(off)
			return {x+dx,y+dy}
		end),
	})
end

function ui_inset(c,m)
	local function adjust(dims)
		local w,h=unpack(dims)
		return {
			w-2*m,
			h-2*m,
		}
	end
	local function readjust(dims)
		local w,h=unpack(dims)
		return {
			w+2*m,
			h+2*m,
		}
	end
			
	return ui.from_ui(c, {
		draw     = function(_,bnds)
			local x,y,w,h = unpack(bnds)
			c:draw({
				x+m,
				y+m,
				w-2*m,
				h-2*m,
			})
		end,
		min_dims = rdr_local(adjust, c.min_dims):map(readjust),
		dims     = rdr_local(adjust, c.dims):map(readjust),
	})
end


-- ui_size
--  w_size: "fit" | number | function | "fill"
--  h_size: "fit" | number | function | "fill"
function ui_size(c, w_size, h_size)
	if type(w_size)=="number" and type(h_size) == "number" then
		local dims = rdr(const({w_size,h_size}))
		return ui.from_ui(c, {
			min_dims = dims,
			dims     = dims,
		})
	end
	
	local dims=rdr(function(dims)
		local wmin,hmin = unpack(c.min_dims.run(dims))
		local wmax,hmax = unpack(dims)
		
		-- width
		if type(w_size)=="number" then
			w=w_size
		elseif type(w_size)=="function" then
			w=w_size(dims)
		elseif w_size=="fit" then
			w=wmin
		elseif w_size=="fill" then
			w=wmax
		end
		-- height
		if type(h_size)=="number" then
			h=h_size
		elseif type(h_size)=="function" then
			h=h_size(dims)
		elseif h_size=="fit" then
			h=hmin
		elseif h_size=="fill" then
			h=hmax
		end
		
		return {w,h}
	end):memo(hash_dims)
	return ui.from_ui(c, {
		min_dims = dims,
		dims     = dims,
	})
end

-- ui_align
--  x_align: "left" | "center" | "right"
--  y_align: "top" | "center" | "bottom"
function ui_align(c, x_align, y_align)
	return ui.from_ui(c, {
		offset = rdr(function(dims)
			local bw,bh = unpack(dims)
			local w,h = unpack(c.dims.run(dims))

			local dx = 0
			if x_align == "left" then
				-- noop. dx is already 0
				-- dx = 0
			elseif x_align == "center" then
				dx = (bw - w)/2
			elseif x_align == "right" then
				dx = bw - w
			end
		
			local dy = 0
			if y_align == "top" then
				-- noop. dy is already 0
				-- dy = 0
			elseif y_align == "center" then
				dy = (bh - h)/2
			elseif y_align == "bottom" then
				dy = bh - h
			end
			
			return {dx,dy}
		end):memo(hash_dims),
	})
end

-- groups
function ui_group(cs)
	local bound_all = rdr(function(dims)
		local xmin,xmax=0,0
		local ymin,ymax=0,0
		for c in all(cs) do
			local x,y=unpack(c.offset.run(dims))
			local w,h=unpack(c.dims.run(dims))
			xmin=mid(0,xmin,x)
			ymin=mid(0,ymin,y)
			xmax=max(xmax,x+w)
			ymax=max(ymax,y+h)
		end
		return {xmax-xmin,ymax-ymin}
	end)
	
	return ui.create({
		offset   = no_offset,
		min_dims = rdr_local(
			const({0,0}),
			bound_all
		),
		dims     = bound_all,
		draw = function(g,bnds)
			foreach(cs, function(c)
				draw_ui(c,bnds)
			end)
		end
	})
end

-- ui_layout
--  dir: "stack" | "inline"
function ui_layout(cs,dir,m)
	m = m or 0

	local function get_offset(dx,dy,w,h)
		if dir == "stack" then
			return dx, dy+m+h
		elseif dir == "inline" then
			return dx+m+w, dy
		end
	end
	local layout = rdr(function(dims)
		local arr = {}
		local dx,dy = 0,0
		for c in all(cs) do
			add(arr, ui_offset(c,dx,dy))
			-- increment offset
			dx,dy = get_offset(
				dx,dy,
				unpack(c.dims.run(dims))
			)
		end
		return arr
	end):map(ui_group)
	
	return ui.from_rdr(layout)
end

-- ui_effect
--  draw_effect: draw_fn -> draw_fn
function ui_effect(c, draw_effect)
	return ui.from_ui(c, {
		draw = function(o,bnds)
			return draw_effect(function()
				c:draw(bnds)
			end)()
		end,
	})
end

-- metatable
ui_meta = {
	__index = {
		inset     = ui_inset,
		align     = ui_align,
		translate = ui_offset,
		size      = ui_size,
		effect    = ui_effect,
		thru=apply,
	}
}

-- prims
ui_empty = ui.create({
	offset   = no_offset,
	min_dims = zeros,
	dims     = full_dims,
	draw     = noop,
})

function ui_box(fill,stroke)
	return ui.from_draw(function(x,y,w,h)
		rectfill(x,y,x+w-1,y+h-1,fill)
		if stroke!=nil then
			rect(x,y,x+w-1,y+h-1,stroke)
		end
	end)
end

function ui_text(str,col)
	local w=text_width(str)
	local h=text_height(str)
	local dims = rdr(const({w,h-1}))
	return ui.create({
		offset   = no_offset,
		min_dims = dims,
		dims     = dims,
		draw=function(c,bnds)
			local x,y=unpack(bnds)
			print(str,x,y,col)
		end
	})
end

function ui_wrap_text(str,c)
	return ui.from_rdr(rdr(function(dims)
		local w,h = unpack(dims)
		local txt = wrap_lines(str,w)
		return ui_text(txt,c)
	end):memo(hash_dims))
end



-- palette --------------------

-- requires:
-- * func    (id, compose, apply)
-- * algebra (monoid_concat)

palette = {}

function palette.to_tbl(p)
	local tbl = {}
	for i=0,15 do
		tbl[i] = p.get(i)
	end
	return tbl
end


palette_meta = {
	__index= {
		map    = function(p,f)
			return palette.create(compose(p.get, f))
		end,
		concat = function(p,p2)
			return palette.create(compose(p.get, p2.get))
		end,
		to_tbl = palette.to_tbl,
		thru   = apply,
	}
}

function palette.create(remap)
	return setmetatable({
		get=remap,
	}, palette_meta)
end

palette.default = palette.create(id)

palette.monochrome = compose(const, palette.create)

palette.concat = monoid_concat(palette.default)

-- string version:
-- longer code, compact data
function palette.from_str(str)
	return palette.create(function(c)
		local i = c
		if (i>=128) then i -= 112 end
		v = ord(sub(str,i+1,i+1)) - 154
		if(v>=16) then v += 112 end
		return v
	end)
end

-- table version:
-- compact code, longer data
function palette.from_tbl(tbl)
	return palette.create(function(c)
		return tbl[c] or c
	end)
end



-- drawing --------------------

-- requires:
-- * func    (chain, compose, suspend)
-- * algebra (required by palette)
-- * palette (palette.monochrome)


draw_spr = suspend(spr)
draw_map = suspend(map)
draw_txt = suspend(print)

function draw_with_color(col)
	return suspend(function(draw)
		local c = peek(0x5f25)
		color(col)
		draw()
		poke(0x5f25, c)
	end)
end


-- in case the draw call itself
-- makes changes to palette
-- we want the "outer" palette
-- to remain active
override_pal = false
function draw_with_palette(p)
	if p.to_tbl then
		p = p:to_tbl()
	end
	return suspend(function(draw)
		if override_pal then
			draw()
		else
			override_pal = true
			local p1,p2,p3,p4 = peek4(0x5f00,4)
			pal(p, 0)
			draw()
			poke4(0x5f00,p1,p2,p3,p4)
			override_pal = false
		end
	end)
end

-- todo: can/should this be unified
-- with draw_with_palette?
_screen_pal = palette.default
function draw_with_screen_pal(p)
	return suspend(function(draw)
		local sp = _screen_pal
		_screen_pal = p:concat(sp)
		pal(_screen_pal:to_tbl(),1)
		draw()
		_screen_pal = sp
	end)
end

draw_monochrome = compose(palette.monochrome, draw_with_palette)

function draw_with_offset(dx, dy)
	return suspend(function(draw)
		local cx,cy =	peek2(0x5f28, 2)
		camera(cx-dx, cy-dy)
		draw()
		poke2(0x5f28,cx,cy)
	end)
end

function draw_with_outline_4(col)
	return suspend(function(draw)
		draw_monochrome(col)(
			function()
				draw_with_offset( 1, 0)(draw)()
				draw_with_offset( 0, 1)(draw)()
				draw_with_offset(-1, 0)(draw)()
				draw_with_offset( 0,-1)(draw)()
			end
		)()
		draw()
	end)
end

function draw_with_outline_9(col,size)
	local size = size or 1
	return suspend(function(draw)
		draw_monochrome(col)(
			function()
				for i=-size,size do
					for j=-size,size do
						draw_with_offset(i,j)(draw)()
					end
				end
			end
		)()
		draw()
	end)
end

function draw_with_shadow(col,dx,dy)
	dx = dx or 0
	dy = dy or 1	
	return suspend(function(draw)
		chain({
			draw_monochrome(col),
			draw_with_offset(dx,dy),
		})(draw)()
		draw()
	end)
end

function draw_with_clip(x,y,w,h)
	return suspend(function(draw)
		local cx,cy,cw,ch = clip(x,y,w,h)
		draw()
		clip(cx,cy,cw,ch)
	end)
end

draw_seq = suspend(function(tbl)
	foreach(tbl, function(c)
		c()
	end)
end)




-->8
-- game library

function join(arr)
	local ret=""
	for v in all(arr) do
		if ret=="" then
			ret=v
		else
			ret..=","..v
		end
	end
	return ret
end

-- box drawing functions ------

-- requires:
-- none!

function box(c)
	return function(x,y,w,h)
		rect(x,y,x+w-1,y+h-1,c)
	end
end

function boxfill(c)
	return function(x,y,w,h)
		rectfill(x,y,x+w-1,y+h-1,c)
	end
end

function box9(coords)
	local xs,ys = unpack(coords)
	local sx0,sx1,sx2,sx3 = unpack(xs)
	local sy0,sy1,sy2,sy3 = unpack(ys)
	
	return function(x,y,w,h)
		local sw0,sw1,sw2 = sx1-sx0, sx2-sx1, sx3-sx2
		local sh0,sh1,sh2 = sy1-sy0, sy2-sy1, sy3-sy2
		local dx0,dx1,dx2,dx3 = x,x+sw0,x+w-sw2,x+w
		local dy0,dy1,dy2,dy3 = y,y+sh0,y+h-sh2,y+h
		local dw0,dw1,dw2 = dx1-dx0,dx2-dx1,dx3-dx2
		local dh0,dh1,dh2 = dy1-dy0,dy2-dy1,dy3-dy2
		
		sspr(sx0, sy0, sw0, sh0, dx0, dy0, dw0, dh0)
		sspr(sx1, sy0, sw1, sh0, dx1, dy0, dw1, dh0)
		sspr(sx2, sy0, sw2, sh0, dx2, dy0, dw2, dh0)
		sspr(sx0, sy1, sw0, sh1, dx0, dy1, dw0, dh1)
		sspr(sx1, sy1, sw1, sh1, dx1, dy1, dw1, dh1)
		sspr(sx2, sy1, sw2, sh1, dx2, dy1, dw2, dh1)
		sspr(sx0, sy2, sw0, sh2, dx0, dy2, dw0, dh2)
		sspr(sx1, sy2, sw1, sh2, dx1, dy2, dw1, dh2)
		sspr(sx2, sy2, sw2, sh2, dx2, dy2, dw2, dh2)
	end
end



-- input behaviors ------------

-- requires:
-- * func     (const)
-- * behavior (behavior.par, behavior.poll)


input_await_not❘ = behavior.poll(function()
	return not btn(❘)
end)

input_await_not❘🅾️ = behavior.poll(function()
	return not (btn(❘) or btn(🅾️))
end)

input_await_❘ = behavior.poll(function()
	return btn(❘)
end)

input_await_🅾️ = behavior.poll(function()
	return btn(🅾️)
end)

input_await_❘🅾️ = behavior.par({
	input_await_❘:map(const(❘)),
	input_await_🅾️:map(const(🅾️)),
})

function input_await_press(b)
	return behavior.poll(function()
		return btnp(b)
	end)
	:map(const(b))
end


-- behavior extensions --------

-- requires:
-- * behavior (behavior.run, behavior.success)

function behavior_wait(t)
	return t <= 0
		and behavior.success()
		or  behavior.run(function(_,dt)
			return behavior_wait(t-dt)
		end)
end

function behavior_retry(b)
	return b:handle_err(function(e)
		return behavior_retry(b)
	end)
end


-- transition -----------------

-- requires:
-- * math    (lerp)
-- * flow    (flow.create)
-- * list    (list.repeat_n)
-- * palette (palette.concat, palette.default, palette.from_str)
-- * signal  (signal.concat, signal.const, signal.linear)

-- palettes

darker_palette = palette.from_str("????????????????????????????????")
lighter_palette = palette.from_str("????????????????????????????????")

function pal_darken(fac)
	local n = flr(fac * 7)
	return palette.concat(
		list.repeat_n(darker_palette, n)
	)
end

function pal_lighten(fac)
	local n = flr(fac * 7)
	return palette.concat(
		list.repeat_n(lighter_palette, n)
	)
end

-- animation

function anim_reverse(anim)
	return anim:ease(lerp(anim.dur,0))
end

-- transitions

-- f: flow<scene>
-- transition: (scn,scn) -> scn
function transition_flow(f, transition)
	local prev
	return flow.create(function(nxt,done)
		f.go(function(cur)
			nxt(transition(cur, prev))
			prev = cur
		end, done)
	end)
end

-- trans: (scene,scene) -> signal<draw>
function transition_scn(trans)
	-- cur: scene
	-- prv: scene
	return function(cur,prv)
		local t = 0
		local draw_cur = signal.const(draw_scn(cur), 0)
		local anim = prv
			and trans(cur,prv):concat(draw_cur)
			or  draw_cur
		return {
			update=function(scn,dt)
				t += dt
				if t < 0.5*anim.dur and prv then
					prv:update(dt)
				else
					cur:update(dt)
				end
			end,
			draw=function(scn)
				anim.at(t)()
			end,
		}
	end
end

-- build a full transition
-- from two separate half-transition
function transition_out_in(t_out, t_in)
	return function(cur,prv)
		return signal.concat({
			t_out:map(function(draw)
				return draw(draw_scn(prv))
			end),
			t_in:map(function(draw)
				return draw(draw_scn(cur))
			end),
		}):scale(0.5)
	end
end

-- build a full transition
-- from a single half-transition
function transition_symm(t)
	return transition_out_in(
		t,
		anim_reverse(t)
	)
end

draw_scn = suspend(function(scn)
	scn:draw()
end)

--

half_trans_fade_to_black = signal.linear
	:map(pal_darken)
	:map(draw_with_screen_pal)

half_trans_fade_to_white = signal.linear
	:map(pal_lighten)
	:map(draw_with_screen_pal)

fade_to_black = transition_symm(half_trans_fade_to_black)
fade_to_white = transition_symm(half_trans_fade_to_white)
	


-- transition -----------------

-- requires:
-- * func    (reduce, suspend)
-- * algebra (lift_a2)
-- * math    (scale)
-- * signal  (signal.const, signal.linear)
-- * extensions/transition (anim_reverse, transition_out_in)

chain_trans = reduce(lift_a2(compose), signal.const(id))

-- half transitions

half_vignette = signal.linear
	:map(scale(24))
	:map(function(m)
		return suspend(function(draw)
			local cx,cy =	peek2(0x5f28, 2)
			local px,py,pw,ph = clip(
				m-cx,
				m-cy,
				128-2*m,
				128-2*m
			)
			draw()
			clip(px,py,pw,ph)
		end)
	end)

half_pan_right = signal.linear
	:map(scale(128))
	:map(function(x)
		return draw_with_offset(x,0)
	end)

half_pan_left = signal.linear
	:map(scale(-128))
	:map(function(x)
		return draw_with_offset(x,0)
	end)

half_carousel_left = chain_trans({
	half_vignette,
	half_pan_left,
	half_trans_fade_to_black,
})

half_carousel_right = chain_trans({
	half_vignette,
	half_pan_right,
	half_trans_fade_to_black,
})

-- full transitions

pan_left = transition_out_in(
	half_pan_left,
	anim_reverse(half_pan_right)
)
pan_right = transition_out_in(
	half_pan_right,
	anim_reverse(half_pan_left)
)

carousel_left = transition_out_in(
	half_carousel_left,
	anim_reverse(half_carousel_right)
)

carousel_right = transition_out_in(
	half_carousel_right,
	anim_reverse(half_carousel_left)
)


-- ui extensions --------------

-- requires:
-- * ui (draw_ui, screen_bounds)


function ui_scn(scn)
	return setmetatable(scn, { __index = {
		update=function(scn,dt)
			if scn.behavior.type == "running" then
				scn.behavior = scn.behavior.update(scn,dt)
			end
		end,
		draw=function(scn)
			draw_ui(scn:ui(), screen_bounds)
		end,
	}})
end


-- presented by scene ---------

-- requires:
-- * func      (const, suspend)
-- * flow      (flow.once)
-- * ui        (ui_box, ui_group, ui_text)
-- * behavior  (behavior.once, behavior.seq)
-- * extensions/ui       (ui_scn)
-- * extensions/behavior (behavior_wait)

presented_by_scn = flow.once(function(nxt)
	return ui_scn({
		ui = const(
			ui_group({
				ui_box(0),
				ui_text("studio terranova presents...",7)
					:align("center","center"),
			}):size("fill","fill")
		),
		behavior=behavior.seq({
			behavior_wait(2),
			behavior.once(nxt),
		}),
	})
end)


-- chapter select -------------

-- requires:
-- * func      (const, suspend)
-- * flow      (flow.once)
-- * ui        (ui_box, ui_empty, ui_group, ui_layout, ui.from_draw)
-- * behavior  (behavior.once, behavior.par, behavior.seq)
-- * drawing   (draw_with_outline_9)
-- * extensions/ui       (ui_scn)
-- * extensions/behavior (behavior_retry, behavior_wait)
-- * extensions/input    (input_await_press)
-- * extensions/transition_carousel (half_carousel_left, half_carousel_right)


function empty_scn(param)
	return flow.once(function(nxt)
		return ui_scn({
			id = param,
			ui = const(ui_empty),
			behavior = behavior.once(nxt),
		})
	end)
end

function proxy_scn(cart, cur_cart)
	local scn = ui_scn({
		id = cart,
		ui = const(
			ui_box(0)
				:size("fill","fill")
		),
		behavior = behavior.seq({
			behavior_wait(0.5),
			behavior.once(function()
				load(cart, "back to title", cur_cart)
			end)
		}),
	})
	return flow.once(const(scn))
end

-- opts: {
--  id,
--  onstart,
--  onnext,
--  onprev,
-- }
function select_scn(scn, opts)
	-- local vignette = animate_clip
	
	local state = "change"
	
	local ui_select = ui_layout({
			ui_text(
				"⬅️",
				opts.onprev and 7 or 6
			),
			ui_text("❘ select",7),
			ui_text(
			 "➡️",
				opts.onnext and 7 or 6
			),
		}, "inline", 28)
	
	local ui_confirm = ui_layout({
			ui_text("❘ start", 7),
			ui_text("🅾️ chapter select", 7),
		}, "stack", 4)
	
	local b_select = behavior.par({
		input_await_press(❘),
		behavior.always(function()
			if btnp(⬅️) and opts.onprev then
				state = "change"
				opts.onprev()
			end
			if btnp(➡️) and opts.onnext then
				state = "change"
				opts.onnext()
			end
		end),
	})
	
	local b_confirm = behavior.par({
		input_await_press(❘),
		input_await_press(🅾️)
			:flatmap(behavior.error),
	})
	
	local b = behavior.seq({
		behavior_wait(0.5),
		behavior.seq({
			behavior.once(function()
				state = "select"
				-- vignette = vignette.set(1)
			end),
			b_select,
			behavior.once(function()
				state = "confirm"
				-- vignette = vignette.set(0)
			end),
			b_confirm,
			behavior.once(opts.onstart),
		})
		:thru(behavior_retry),
	})
	-- todo: add vignetting to behavior
	-- vignette = vignette.update(dt)
	
	return ui_scn({
		id=opts.id,
		behavior=b,
		ui=function()
			return ui_group({
				-- scene
				ui.from_draw(draw_scn(scn)),
				-- :effect(suspend(function(draw)
				-- 	local x,y,w,h = unpack(vignette.get())
				-- 	local px,py,pw,ph = clip(x,y,w,h,true)
				-- 	draw()
				-- 	clip(px,py,pw,ph)
				-- end)),
				-- overlay
				(
					false
					or (state == "select"  and ui_select)
					or (state == "confirm" and ui_confirm)
					or (state == "change"  and ui_empty)
				)
				:inset(4)
				:effect(draw_with_outline_9(5))
				:effect(draw_with_shadow(0))
				:align("center","bottom"),
			})
		end,
	})
end

-- exports --------------------
function chapter_select_scn(title, opts)
	return flow.once(function(nxt)
		return select_scn(title, {
			id = opts.cur_cart,
			onstart = suspend(nxt)(❘),
			onnext  = opts.next_cart
				and suspend(nxt)(➡️)
				or  nil,
			onprev  = opts.prev_cart
				and suspend(nxt)(⬅️)
				or  nil,
		})
	end)
	:flatmap(function(sel)
		if sel == ❘ then
			return flow.of(❘)
		end
		if sel == ⬅️ then
			return proxy_scn(
				opts.prev_cart,
				opts.cur_cart
			)
		end
		if sel == ➡️ then
			return proxy_scn(
				opts.next_cart,
				opts.cur_cart
			)
		end
	end)
end

function half_trans(t, scn)
	return t
		:map(function(draw)
			return draw(draw_scn(scn))
		end)
		:scale(0.5)
end

function chapter_select_transition(opts, fallback)
	return function(cur,prv)
		if cur.id == opts.next_cart then
			return half_trans(
				half_carousel_left,
				prv
			)
		end
		if cur.id == opts.prev_cart then
			return half_trans(
				half_carousel_right,
				prv
			)
		end
		if prv.id == opts.next_cart then
			return half_trans(
				anim_reverse(half_carousel_left),
				cur
			)
		end
		if prv.id == opts.prev_cart then
			return half_trans(
				anim_reverse(half_carousel_right),
				cur
			)
		end
		return fallback(cur,prv)
	end
end





-- extras

function draw_with_transparency(col)
	return suspend(function(draw)
		palt(0,false)
		palt(col,true)
		draw()
		palt()
	end)
end


-- easing functions -----------

function ease_q(t)
	return t*t
end

function ease_out_q(t)
	return 1 - ease_q(1-t)
end

-- anim extras ----------------

function anim_clamp(s)
	return s:ease(function(t)
		return mid(0,t,s.dur)
	end)
end


-- stateful animator ----------

animator_meta = {
	__index={
		update=function(s,dt)
			s.t += dt
			s.beh = s.beh.update(s,dt)
		end,
		draw=function(s)
			return s.anim.at(s.t)()
		end,
		--
		run=function(s,a)
			local on_end, do_end = emit.fork()
			s.anim = a
			s.t = 0
			s.beh = behavior.seq({
				behavior.poll(function()
					return s.t >= a.dur
				end),
				behavior.once(do_end),
				behavior.never
			})
			return on_end
		end,
	}
}

function animator()
	return setmetatable({
		t=0,
		anim=signal.const(noop),
		beh=behavior.never,
	}, animator_meta)
end
-->8
-- components

casette_pal = palette.from_tbl({
	 [2] = 128+ 5,
	 [3] = 128+11,
	 [4] = 128+ 1,
	[10] = 128+10,
})

title_pal = palette.from_tbl({
	 [1] = 128+ 1,
	 [2] = 128+ 5,
	 [3] = 128+11,
	 [4] = 128+ 1,
	[10] = 128+10,
})


function casette_player()
	local anim = animator()
	anim:run(casette_empty_anim)
	
	anim.insert = function()
		return anim:run(casette_put_in_anim)
	end
	anim.play = function()
		return anim:run(casette_playing_anim)
	end
	anim.pause = function()
		return anim:run(casette_stopped_anim)
	end
	anim.eject = function()
		return anim:run(casette_take_out_anim)
	end
	
	return anim
end

button_palette = palette.from_tbl(
	{[13] = 10}
)

function casette_controls(st)
	local function ui_spr(n)
		return ui.from_draw(function(x,y,w,h)
			spr(n,x,y)
		end)
		:size(7,7)
	end
	
	local function button(c,is_selected,is_pressed)
		return ui_group({
			ui_box(13)
				:translate(0,is_pressed and 0 or 2),
			ui_group({
				ui_box(5, is_selected and 10 or 13),
				c:inset(3),
			})
			:size("fit","fit")
		})
		:effect(
			is_selected
				and draw_with_palette(button_palette)
				or  id
		)
		:size("fit","fit")
		:translate(0,is_pressed and 2 or 0)
	end
	
	return ui_layout({
		ui_layout({
			button(ui_spr(75), st.sel == 1, st.sel == 1 and btn(❘)),
			button(ui_spr(76), st.sel == 2, st.sel == 2 and btn(❘)),
			button(ui_spr(77), st.sel == 3, st.playing),
			button(ui_spr(78), st.sel == 4, st.sel == 4 and btn(❘)),
		}, "inline", 2),
		button(ui_spr(79), st.sel == 5, st.sel == 5 and btn(❘)),
	}, "inline", 16)
end

function controls_scn()
	local on_emit, do_emit = emit.fork()

	return ui_scn({
		on_emit = on_emit,
		playing = false,
		sel = 3,
		ui = function(s)
			return casette_controls({
				sel = s.sel,
				playing = s.playing,
			})
			:size("fit", 14)
			:align("center","bottom")
			:translate(0,-4)
		end,				
		behavior = behavior.always(function(s)
			-- navigation
			if btnp(⬅️) then
				s.sel -= 1
			end
			if btnp(➡️) then
				s.sel += 1
			end
			s.sel = mid(1,s.sel,5)

			-- button press
			if btnp(❘) then
				if s.sel == 1 then
					do_emit("prev_track")
				end
				if s.sel == 2 then
					do_emit("pause")
				end
				if s.sel == 3 then
					do_emit("play")
				end
				if s.sel == 4 then
					do_emit("next_track")
				end
				if s.sel == 5 then
					do_emit("eject")
				end
			end
		end),
	})
end
-->8
-- scenes

scn_empty = {
	update = noop,
	draw   = noop,
}

-- casette scene --------------

function casette_flow(casette, songs)
	local load_casette_flow = flow.once(function(nxt)
		return ui_scn({
			ui = const(
				ui_text("press ❘ to load tape",7)
					:align("center","center")
					:translate(0,40)
					:effect(draw_with_outline_9(5))
			),
			behavior = behavior.seq({
				input_await_not❘,
				input_await_❘,
				behavior.once(nxt),
			}),
		})
	end)
	
	local reload_casette_flow = flow.once(function(nxt)
		return ui_scn({
			ui = const(
				ui_layout({
					ui_text("press ❘ to play again",7)
						:size("fit","fit")
						:align("center","top"),
					ui_text("press 🅾️ to end",7)
						:size("fit","fit")
						:align("center","top"),
				}, "stack", 4)
					:align("center","center")
					:translate(0,44)
					:effect(draw_with_outline_9(5))
			),
			behavior = behavior.par({
				behavior.seq({
					input_await_not❘,
					input_await_❘,
					behavior.once(function()
						nxt("again")
					end),
				}),
				behavior.seq({
					input_await_not🅾️,
					input_await_🅾️,
					behavior.once(function()
						nxt("done")
					end),
				}),
			})
		})
	end)
	
	local play_casette_flow = flow.seq({
			-- animate load tape
		flow.once(function(nxt)
			casette:insert()
				.run(nxt)
			return scn_empty
		end),
		-- controls anim
		flow.once(function(nxt)				
			local anim = animator()
			anim:run(reveal_controls)
				.run(nxt)
			return anim
		end),
		-- controls
		flow.once(function(nxt)
			local scn = controls_scn()
			
			scn.on_emit
				.run(function(e)
					if e == "play" then
						if songs:is_playing() then
							songs:pause()
						else
							songs:play()
						end
					end
					if e == "pause" then
						songs:pause()
					end
					if e == "next_track" then
						songs:next_track()
					end
					if e == "prev_track" then
						songs:prev_track()
					end
					if e == "eject" then
						songs:pause()
						nxt()
					end
				end)
				
			songs.on_emit
				:filter(function(e)
					return false
						or e[1] == "play"
						or e[1] == "pause"
				end)
				.run(function()
					scn.playing = songs:is_playing()
				end)
				
			return scn
		end),
		-- controls anim
		flow.once(function(nxt)				
			local anim = animator()
			anim:run(hide_controls)
				.run(nxt)
			return anim
		end),
		-- animate eject tape
		flow.once(function(nxt)
			casette:eject()
				.run(nxt)
			return scn_empty
		end),
	})
	
	local function casette_loop_flow(flw)
		return flw:flatmap(function(e)
			if e == "again" then
				return casette_loop_flow(flw)
			end
			if e == "done" then
				return flow.of(nil)
			end
		end)
	end
	
	return flow.seq({
		load_casette_flow,
		flow.seq({
			play_casette_flow,
			reload_casette_flow,
		})
		:thru(casette_loop_flow),
	})
end

casette_scn = flow.once(function(nxt)
	local songs = nil
	local casette = casette_player()
	local bloop = animator()
	
	bloop:run(cherry1_vis)
	
	return {
		did_init=false,
		init=function(scn)
			-- copy spritesheet and map
			reload(
				0x0000,
				0x0000,
				0x3000,
				tracks[1]..".p8.png"
			)
			
			-- load songs
			songs = track_list(tracks)
			
			songs.on_emit
				:filter(function(e)
					return e[1] == "play"
				end)
				.run(function()
					casette:play()
				end)
			songs.on_emit
				:filter(function(e)
					return e[1] == "pause"
				end)
				.run(function()
					casette:pause()
				end)
			songs.on_emit
				:filter(function(e)
					return e[1] == "track_loaded"
				end)
				.run(function(e)
					local track = e[2]
					local waves = {
						cherry1_vis,
						cherry2_vis,
						sendaria1_vis,
						sendaria2_vis,
					}
					bloop:run(waves[track])
				end)
			
			casette_flow(casette, songs)
				.go(
					function(s)
						scn.action = s
					end,
					nxt
				)
		end,
		update=function(scn,dt)
			if not scn.did_init then
				scn:init()
				scn.did_init = true
			end
			
			scn.action:update(dt)
			songs:update(dt)
			casette:update(dt)
			
			if songs.is_playing() then
				bloop:update(dt)
			end
		end,
		draw=function(scn)
			cls(14)
		
			if songs.is_playing() then
				bloop:draw()
			end
		
			chain({
				draw_with_screen_pal(casette_pal),
				draw_with_offset(16,24),
			})(
				draw_scn(casette)
			)()
			
			scn.action:draw()
		end,
	}
end)

-- presented by and title -----

title_scn = flow.once(function(nxt)	
	local is_ready = false
	
	local ui = ui_group({
		ui_group({
			ui.from_draw(function(x,y,w,h)
				sspr(0,0,128,128,0,0)
			end)
		})
		:size("fill","fill")
		:effect(
			draw_with_screen_pal(title_pal)
		),
		
		ui_text("press ❘ to start", 7)
			:inset(4)
			:align("center","bottom")
			:translate(0,-12)
			:effect(function(draw)
				local blink = (t*3) % 1 > 0.5
				local eff = (is_ready and blink)
					and draw_with_outline_9(14)
					or  draw_with_outline_9(5)
				return eff(draw)
			end),
	})
	:size("fill","fill")
	
	return {
		behavior=behavior.seq({
			behavior_wait(1),
			input_await_❘,
			behavior.once(function()
				is_ready = true
			end),
			behavior_wait(1),
			behavior.once(nxt),
			behavior.never
		}),
		update=function(scn,dt)
			scn.behavior = scn.behavior.update(scn,dt)
		end,
		draw=function(scn)
			cls()
			draw_ui(ui, screen_bounds)
		end,
	}
end)

-->8
-- music player

-- load sfx and music from
-- another cart
function load_track(track)
	reload(
		0x3100,
		0x3100,
		0x1200,
		track..".p8.png"
	)
	return song()
end


function track_list(tracks)
	local idx, trk, beh = 1
	local on_emit, do_emit = emit.fork()

	local function load_song(i)
			do_emit({
				"track_loaded",
				i,   -- new track
				idx, -- old track
			})

			idx = i
			trk = load_track(tracks[idx])
			
			-- when a song finishes,
			-- load and play next song
			-- after a slight delay
			trk.on_finish
				.run(function()
					beh = behavior.seq({
						behavior_wait(2),
						behavior.once(function(s)
							s:next_track()
						end),
						behavior.never,
					})
				end)
	end
	beh = behavior.never
	load_song(1)

	return {
		on_emit = on_emit,
		is_playing = function()
			return trk.is_playing()
		end,
		update = function(s,dt)
			beh = beh.update(s,dt)
			trk:update(dt)
		end,
		play = function()
			trk:play()
			do_emit({"play"})
		end,
		pause = function()
			trk:pause()
			do_emit({"pause"})
		end,
		next_track = function(s)
			local nxt = idx == #tracks
				and 1
				or  idx+1
			load_song(nxt)
			s:play()
		end,
		prev_track = function(s)
			local prv = idx == 1
				and #tracks
				or  idx-1
			load_song(prv)
			s:play()
		end,
		thru = apply,
	}
end
-->8
-- animation


draw_player_base =
	suspend(map)(0,0,0,0,12,10)

draw_player_buttons = suspend(function(is_playing)
	if is_playing then
		spr(36,48,0)
	else
		spr(37,48,0)
	end
end)

draw_casette_tape =
	chain({
		draw_with_transparency(15)
	})
	(suspend(map)(25,0,0,0,8,5))

draw_player_cover = function(ang)
	local  w, h = 96,72
	local x0,y0 =  0, 0
	local x1,y1 =
		x0 + w/4*sin(ang),
		y0 +   h*cos(ang)
	local mx,my = 12, 0
	
	return draw_with_offset(
	 	 - x1,
		h - y1
	)(draw_textured_rect(
		x0,y0,
		x1,y1,
		 w, h,
		mx,my
	))
end

draw_textured_rect = suspend(
	function(x0,y0,x1,y1,w,h,mx,my)
		for dy=0,h do
			local fac = dy/h
			local x = lerp(x0,x1)(fac)
			local y = lerp(y0,y1)(fac)
			tline(
				x,   ceil(y),
				x+w, ceil(y),
				mx,  my+dy/8
			)
		end
	end
)

-- anim

do
	local casette_base_anim =
		signal.const(
			draw_seq({
				chain({
						draw_monochrome(11),
						draw_with_offset(4,0),
						draw_with_clip(0,32,128,64),
					})
						(draw_player_base),
				draw_player_base,
			})
		)
	
	local casette_tape_anim = signal.linear
		:map(lerp(-80,24))
		:map(function(y)
			return draw_with_offset(16,y)
				(draw_casette_tape)
		end)
		:ease(ease_out_q)
		:ease(function(t)
			return mid(0,t,1)
		end)
		:delay(0.5)

	local casette_cover_open_anim = signal.linear
		:map(function(ang)
			return -ang/5
		end)
		:map(function(ang)
			return draw_player_cover(ang)
		end)

	local casette_cover_anim = signal.concat({
		-- open cover
		casette_cover_open_anim
			:scale(0.5),
		-- wait for tape
		signal.const(
			draw_player_cover(-1/5)
		):scale(1),
		-- close cover
		casette_cover_open_anim
			:ease(function(t)
				return mid(0, 1-t, 1)
			end)
			:scale(0.5),
	})
	
	local casette_sprocket_anim = signal.linear
		:map(suspend(function(t)
			local x,y = 0.5,0.5
			circfill(x,y,3,0)
			-- draw casette 'sprockets'
			for i=0,1,1/6 do
				local r = 3
				local a = i + t/2
				local xx,yy = -r*cos(a),r*sin(a)
				pset(x+xx,y+yy,7)
			end
		end))
		
	-- export
	casette_empty_anim = signal.from_list({
		casette_base_anim,
		signal.const(
			draw_player_buttons(false)
		),
		signal.const(
			draw_player_cover(0)
		),
	}):map(draw_seq)
	
	casette_put_in_anim = signal.from_list({
		casette_base_anim,
		signal.const(
			draw_player_buttons(false)
		),
		casette_tape_anim,
		casette_cover_anim,
	}):map(draw_seq)
	
	casette_take_out_anim = casette_put_in_anim
		:thru(anim_clamp)
		:thru(anim_reverse)
	
	casette_playing_anim = signal.from_list({
		casette_base_anim,
		-- press play button in
		signal.const(
			draw_player_buttons(true)
		),
		signal.const(
			draw_with_offset(16,24)
				(draw_casette_tape)
		),
		-- animate sprockets
		casette_sprocket_anim
			:map(draw_with_offset(32,44)),
		casette_sprocket_anim
			:map(draw_with_offset(63,44)),
		signal.const(
			draw_player_cover(0)
		),
	}):map(draw_seq)
	
	casette_stopped_anim = signal.from_list({
		casette_base_anim,
		signal.const(
			draw_player_buttons(false)
		),
		signal.const(
			draw_with_offset(16,24)
				(draw_casette_tape)
		),
		signal.const(
			draw_player_cover(0)
		),
	}):map(draw_seq)
end

reveal_controls = signal.linear
	:map(lerp(16,-4))
	:map(function(off)
		return casette_controls({})
			:size("fit", 14)
			:align("center","bottom")
			:effect(draw_with_offset(0,off))
	end)
	:map(suspend(function(c)
		draw_ui(c, screen_bounds)
	end))
	:scale(0.25)

hide_controls = reveal_controls
	:thru(anim_reverse)


-- sound visualisation

draw_circ = suspend(function(r)
	fillp(▒)
	circ(0,0,r,7)
	fillp()
end)

draw_polygon = function(n,a)
	a = a or 0
	return suspend(function(r)
		fillp(0b1010000010100000.1)
		for i=1,n do
			local a1,a2 = a + i/n, a + (i+1)/n
			local x0,y0 = r*cos(a1), r*sin(a1)
			local x1,y1 = r*cos(a2), r*sin(a2)
			line(x0,y0,x1,y1,7)
		end
		fillp()
	end)
end


bloops = signal.linear
	:ease(ease_out_q)
	:ease(function(t)
		return t % 1
	end)

function bloop_overlap(s)
	return signal.create(function(t)
		return draw_seq({
			s.at(t),
			s.at(t - (1/8) * s.dur),
			s.at(t - (1/4) * s.dur),
		})
	end, s.dur)
end
	
function set_tempo(tempo)
	return function(s)
		local t = tempo * 4 * 8 / (22050/183)
		return s:scale(t)
	end
end

cherry1_vis = bloops
	:thru(set_tempo(6))
	:ease(function(t)
		return t+0.25
	end)
	:map(function(t)
		return t*116
	end)
	:map(draw_circ)
	:map(draw_with_offset(64,64))
	:thru(bloop_overlap)

cherry2_vis = bloops
	:thru(set_tempo(10))
	:map(function(t)
		return t*128
	end)
	:map(draw_polygon(4))
	:map(draw_with_offset(64,64))
	:thru(bloop_overlap)
	
sendaria1_vis = bloops
	:thru(set_tempo(16))
	:map(function(t)
		return t*128
	end)
	:map(draw_polygon(5, -1/10))
	:map(draw_with_offset(64,64))
	:thru(bloop_overlap)

sendaria2_vis = bloops
	:thru(set_tempo(8))
	:map(function(t)
		return t*128
	end)
	:map(draw_polygon(6, -1/12))
	:map(draw_with_offset(64,64))
	:thru(bloop_overlap)

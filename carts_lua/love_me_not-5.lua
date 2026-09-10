function lerp(a,b,t)
 return a+t*(b-a)
end


function remap(in_a,in_b,out_a,out_b,val)
	return lerp(out_a,out_b,(val-in_a)/(in_b-in_a))
end


function hcntr_print(str,y)
	--measure text width offscreen
	local w=print(str,0,0x7fff.ffff)
	local x=63.5-0.5*w
	print(str,x,y)
end


function swap_del(arr,idx)
	arr[idx]=arr[#arr]
	arr[#arr]=nil
end


function rnd_rng(a,b)
	if a>b then a,b=b,a end
	return a+rnd(b-a)
end


-- vector.p8 v2.3.1
-- by @thacuber2a03

function vector(x,y) return {x=x or 0,y=y or 0} end

function v_eq(a,b) return a.x==b.x and a.y==b.y end
function v_polar(a,l) return vector(l*cos(a),l*sin(a)) end
function v_copy(v)    return vector(v.x,v.y) end

function v_add(a,b)   return vector(a.x+b.x, a.y+b.y) end
function v_sub(a,b)   return v_add(a, v_neg(b)) end
function v_scale(v,n) return vector(v.x*n, v.y*n) end
function v_div(v,n)   return v_scale(v, 1/n) end
function v_neg(v)     return v_scale(v, -1) end

function v_dot(a,b)    return a.x*b.x+a.y*b.y end
function v_magsq(v)    return v_dot(v,v) end
function v_mag(v)      return sqrt(v_magsq(v)) end
function v_distsq(a,b) return v_magsq(v_sub(b,a)) end
function v_dist(a,b)   return sqrt(v_distsq(a,b)) end
function v_norm(v)     return v_div(v,v_mag(v)) end
function v_perp(v)     return vector(v.y, -v.x) end
function v_dir(a,b)    return v_norm(v_sub(b,a)) end

function v_angle(v)   return atan2(v.x,v.y)        end
function v_rot(v,a)   return v_polar(a, v_mag(v))  end
function v_rotby(v,a) return v_rot(v,v_angle(v)+a) end

function v_lerp(a,b,t) return v_add(a,v_scale(v_sub(b,a),t)) end


function draw_menu(menu,y,prefix)
 prefix=prefix or ""
	for i=1,#menu.items do
		local txt=menu.items[i].txt
		if i==menu.idx then
			txt="> "..txt.." <"
		end
		hcntr_print(prefix..txt,y+7*i)
	end
end

function update_menu(menu)
	if btnp(❘) or btnp(🅾️) then
		menu.items[menu.idx].func()
		sfx(10)
	end
	if btnp(⬇️) then
	 menu.idx+=1
		sfx(2)
	end
	if btnp(⬆️) then
		menu.idx-=1
		sfx(2)
	end
	menu.idx=1+(menu.idx-1)%#menu.items
end


function add_smoke(pos,sz,col)
	add(smokes,{
			pos=v_copy(pos),
			rad=sz,
			col=col
		})
end

function update_smokes()
 for idx=#smokes,1,-1 do
		local smoke=smokes[idx]
		smoke.rad*=0.8
		if smoke.rad<0.5 then
		 swap_del(smokes,idx)
		end
	end
end

function draw_smokes(smokes)
	for smoke in all(smokes) do
		circfill(
			smoke.pos.x,smoke.pos.y,
			smoke.rad,smoke.col
		)
	end
end


function new_anim(start,fin,func)
	return {
		start=start,
		fin=fin,
		func=func
	}
end

function update_anims(anims,anim_t)
	for i=#anims,1,-1 do
		local anim=anims[i]
		if anim_t>=anim.start do
			anim.func(remap(anim.start,anim.fin,0,1,anim_t))
		end
		if anim_t>=anim.fin do
			swap_del(anims,i)
		end
	end
end


--pin map, see readme
lb_base=0x5f80
lb_p_req=lb_base+0
lb_p_status=lb_base+1
lb_p_arg=lb_base+2
lb_p_count=lb_base+3
lb_p_namelen=lb_base+4
lb_p_name=lb_base+5
lb_p_score=lb_base+21
lb_p_magic=lb_base+28
lb_p_ver=lb_base+29

lb_magic_val=0x8b
lb_ver_val=1

--requests, lua writes
lb_rq_none=0
lb_rq_submit=1
lb_rq_fetch=2
lb_rq_row=3
lb_rq_whoami=4

lb_req_of={
	submit=lb_rq_submit,
	fetch=lb_rq_fetch,
	whoami=lb_rq_whoami,
	row=lb_rq_row,
}

--status, shell writes
lb_sv_idle=0
lb_sv_ok=2
lb_sv_err=3

function lb_init()
	lb_board={}
	lb_pending={}

	lb_ver=peek(lb_p_ver)

	if peek(lb_p_magic)!=lb_magic_val then
		lb_state="disabled"
		return
	end
	if lb_ver!=lb_ver_val then
		lb_state="disabled"
		lb_msg="shell v"..lb_ver..", cart v"..lb_ver_val
		return
	end

	poke(lb_p_req,lb_rq_none)
	poke(lb_p_status,lb_sv_idle)

	lb_state="loading"
	lb_whoami()
end

function lb_enqueue(job,score)
	if lb_state=="disabled" then
		return false
	end
	add(lb_pending,{job=job,score=score})
	return true
end

function lb_submit(score)
	return lb_enqueue("submit",score)
end

function lb_fetch()
	return lb_enqueue("fetch")
end

function lb_whoami()
	return lb_enqueue("whoami")
end

function lb_start(job)
	poke(lb_p_status,lb_sv_idle)
	poke(lb_p_req,lb_req_of[job])
	lb_job=job
	lb_busy=true
	lb_wait=0
end

function lb_send(p)
	if p.job=="submit" then
		poke4(lb_p_score,p.score)
		--kept so the reply can place it
		lb_sent_score=p.score
	end
	if p.job=="fetch" and lb_state=="error" then
		lb_state="loading"
	end
	lb_start(p.job)
end

function lb_ask_row()
	lb_row+=1
	poke(lb_p_arg,lb_row)
	lb_start("row")
end

function lb_read_name()
	local n=min(peek(lb_p_namelen),16)
	local s=""
	for idx=0,n-1 do
		s=s..chr(peek(lb_p_name+idx))
	end
	if s=="" then
		return nil
	end
	return s
end

--ack shell and free line
function lb_free()
	poke(lb_p_status,lb_sv_idle)
	lb_busy=false
end

--a request died. we only fall back to
--"error" if we have never had a board:
--once ready we keep showing the old one.
function lb_failed(why)
	lb_msg=why
	lb_free()
	if lb_state!="ready" then
		lb_state="error"
	end
end

function lb_update()
	if lb_state=="disabled" then
		return
	end

	if not lb_busy then
		if #lb_pending>0 then
			lb_send(deli(lb_pending,1))
		end
		return
	end

	lb_wait+=1
	if lb_wait>300 then
		poke(lb_p_req,lb_rq_none)
		lb_failed("timed out")
		return
	end

	local st=peek(lb_p_status)
	if st==lb_sv_err then
		lb_failed("request failed")
		return
	end
	if st!=lb_sv_ok then
		return
	end

	--job landed, process it
	lb_free()
	if lb_job=="whoami" then
		lb_name=lb_read_name()
	elseif lb_job=="submit" then
  --submit may pickup updated username
		lb_name=lb_read_name()
		lb_insert(lb_name,lb_sent_score)
	elseif lb_job=="fetch" then
		lb_rows=peek(lb_p_count)
  --rows arrive one by one, double buffer
		lb_next={}
		lb_row=0
		if lb_rows>0 then
			lb_ask_row()
		else
			lb_board={}
			lb_state="ready"
		end
	elseif lb_job=="row" then
		add(lb_next,{
			name=lb_read_name() or "???",
			score=peek4(lb_p_score),
		})
		if lb_row<lb_rows then
			lb_ask_row()
		else
   --done, swap double buffer
			lb_board=lb_next
			lb_state="ready"
		end
	end
end

function lb_ready()
	return lb_state=="ready"
end

function lb_insert(name,score)
	if lb_state!="ready" or not name then
		return false
	end

	local pos

	for idx=1,#lb_board do
		local row=lb_board[idx]
		if not pos and score>row.score then
			pos=idx
		end
		if row.name==name then
			if not pos then
				return false
			end
			deli(lb_board,idx)
			break
		end
	end

	pos=pos or #lb_board+1
	if pos>10 then
		return false
	end

	add(lb_board,{name=name,score=score},pos)
	if #lb_board>10 then
		deli(lb_board)
	end
	return true
end



function circ_xsect_line(l,c_pos,c_rad)
	local l_diff=v_sub(l.tail,l.head)
	local c_diff=v_sub(c_pos,l.head)

	local t=mid(0,1,v_dot(c_diff,l_diff)/v_magsq(l_diff))
	return v_magsq(v_sub(c_diff,v_scale(l_diff,t)))<=c_rad^2
end

function flwr_off(flwr)
	return v_polar(flwr.ang,2)
end

function flwr_head(flwr)
	return v_add(flwr.pos,flwr_off(flwr))
end

function flwr_tail(flwr)
	return v_sub(flwr.pos,flwr_off(flwr))
end

function flwr_ends()
	return flwr_head(plyr),flwr_tail(plyr)
end

function draw_flwr(flwr)
	stem_color=11
	local h=flwr_head(flwr)
	local t=flwr_tail(flwr)
	line(h.x,h.y,t.x,t.y,stem_color)
	circfill(h.x,h.y,1,10)
	pset(h.x,h.y,7)
end

function enter_bubble(bub)
	puff(plyr.pos,2)
	plyr.state=plyr_bub
	plyr.spd=vector(0,0)
	plyr.pos=bub.pos
	bub_tmr=45
	cam_shake=1
	sfx(12,0)
end

function stun(norm)
	cam_shake=4
	plyr.charge=0

	local align=v_dot(plyr.spd,norm)
	if align<0 then
		plyr.spd=v_sub(
			plyr.spd,v_scale(norm,2*align)
		)
	end
	plyr.spd=v_rotby(plyr.spd,rnd_rng(-1/64,1/64))
	--slough speed
	plyr.spd=v_scale(plyr.spd,0.8)

	plyr.spd=v_div(
		plyr.spd,
		mid(1,1/64,v_mag(plyr.spd)/(3/4))
	)

	ensure_sep(norm)

	plyr.rot_spd=-sgn(plyr.spd.x)*(1+abs(plyr.spd.x))/16

	if plyr.state!=plyr_stun then
		plyr.state=plyr_stun
		stun_tmr=2
	end

	local hs=6

	stun_tmr-=1
	if stun_tmr<=0 then
		hs=12
		sfx(11,0)
		free_stun()
	else
		sfx(3,0)
	end

	xray=4
	hitstop(hs,function()
		puff(plyr.pos,3)
	end)
end

function free_stun()
	stun_tmr=0
	plyr.state=plyr_spin
end

--guarantee we leave the surface, or
--well be back on it next frame
function ensure_sep(norm)
	plyr.spd=v_add(
		plyr.spd,
		v_scale(norm,max(
			0,
			min_sep-v_dot(plyr.spd,norm)
		))
	)
end

function leave_cave()
	if state!=state_play then
		return
	end
	state=state_leaving

	total_t=game_t()
	best_t=total_t
	if dget(0)!=0 then
		best_t=min(best_t,dget(0))
	else
		clock_vis=true
	end
	dset(0,best_t)
	--lowest is best
	lb_submit(-total_t)
	lb_fetch()

	plyr.rot_spd=0
	add(flwr_pals,plyr)
end

function rndi_rng(a,b)
	return flr(rnd_rng(flr(a),flr(b)))
end

function puff(pos,sz,col)
	if col==nil do col=7 end
	for idx=1,sz^2-sz do
		add_smoke(vector(
		 pos.x+rnd_rng(-sz,sz),
			pos.y+rnd_rng(-sz,sz)
		),
		rnd_rng(2,sz),col)
	end
end

function init_walls()
	--cave floor
	l_walls={{
		tail=vector(64,bot_y),
		head=vector(36,bot_y-1),
		v_tail=vector(64,bot_y),
		v_head=vector(36,bot_y-1)
	}}
	local r_x=rndi_rng(70,92)
	r_walls={{
		tail=vector(64,bot_y),
		head=vector(r_x,bot_y-1),
		v_tail=vector(64,bot_y),
		v_head=vector(r_x,bot_y-1)
	}}
	wall_groups={
  [-1]=l_walls,
  [01]=r_walls,
	}
end

function grow_walls(num_walls)
	mouth_y=bot_y-num_walls*wall_h

	for x_dir,walls in pairs(wall_groups) do
		--cave walls
		for w_idx=#walls,num_walls do
			local prev=walls[#walls]
			local head=vector(
				64+x_dir*rndi_rng(48,60),
				bot_y-w_idx*wall_h-1
			)
			add(walls,{
				tail=v_copy(prev.head),
				head=head,
				is_spiky=false,
				v_tail=v_copy(prev.v_head),
				v_head=v_copy(head)
			})
		end
	end
end

function set_vtx(walls,w_idx,x)
	walls[w_idx].head.x=x
	local nxt=walls[w_idx+1]
	if nxt then
		nxt.tail.x=x
	end
end

function set_v_vtx(walls,w_idx,x)
	walls[w_idx].v_head.x=x
	if w_idx<#walls then
		walls[w_idx+1].v_tail.x=x
	end
end

function chunk_idx(w_idx)
	return mid(
		1,num_chunks,
		1+(w_idx-1)\walls_per_chunk
	)
end

function gen_walls()
	local curr_h=ceil(1.5+y_to_h(cam_y)/wall_h)
	local w_groups=wall_groups

	while gen_h>curr_h+1 do
		gen_h-=1

  -- cleanup rabbits
		for x_dir,walls in pairs(w_groups) do
			walls[gen_h].hole=nil
		end

		--cleanup flies
		if (gen_h-1-fly_off)%walls_per_chunk==0 then
			deli(flies,chunk_idx(gen_h))
		end

		--cleanup moles
		for x_dir,walls in pairs(w_groups) do
			local mole=walls[gen_h].mole
			if mole then
				del(moles,mole)
				foreach(mole.bubs,function(bub)
					del(bubbles,bub)
				end)
			end
			walls[gen_h].mole=nil
		end
	end

	while gen_h<curr_h and gen_h<=#l_walls do
		local chunk=chunk_idx(gen_h)
		local b=biomes[chunk]

		local wriggle=b.wriggle

		local min_mid_dist=8
		local max_mid_dist=b.max_mid_dist

		local min_l=4
		local max_r=123
		local max_l=min(b.max_l,max_r)
		local min_r=max(b.min_r,min_l)

		local fly_dist=(gen_h-1-fly_off)%walls_per_chunk
		fly_dist=min(fly_dist,walls_per_chunk-fly_dist)
		local is_fly=fly_dist==0

		--cant spawn walls over moles
		for chk_i=gen_h-1,max(gen_h-3,1),-1 do
			for x_dir,walls in pairs(w_groups) do
				local chk_w=walls[chk_i]
				if chk_w.mole then
					max_l=min(max_l,chk_w.mole.pos.x-8)
					min_r=max(min_r,chk_w.mole.pos.x+8)
				end
			end
		end

		local prev_l=32
		local prev_r=96
		if gen_h>1 then
			prev_l=l_walls[gen_h-1].head.x
			prev_r=r_walls[gen_h-1].head.x
		end

		if fly_dist<=1 then
			min_mid_dist=max(min_mid_dist,20)
			wriggle=min(wriggle,-abs(prev_r-prev_l)/2)
		end

		local is_tutorial=gen_h<tutorial_h

		local l=mid(prev_l-wriggle,min_l+min_mid_dist,max_r-min_mid_dist)
		local r=mid(prev_r+wriggle,min_l+min_mid_dist,max_r-min_mid_dist)
		local mid_x=rndi_rng(l,r)
		if is_tutorial then
			mid_x=64
		end

		for x_dir,walls in pairs(w_groups) do
			--create a random range
			--relative to the chosen
			--midpoint.
			local inner=mid_x+x_dir*min_mid_dist
			local outer=mid_x+x_dir*min(max_mid_dist,60)
			--don't leave bounds
			--(screen edge, etc)
			local inner=mid(inner,min_l,max_r)
			local outer=mid(outer,min_l,max_r)
			--don't enter bounds
			--(over mole, etc)
			if x_dir==-1 then
				inner=min(inner,max_l)
				outer=min(outer,max_l)
			else
				inner=max(inner,min_r)
				outer=max(outer,min_r)
			end

			local wall_x=rndi_rng(inner,outer)

			--easy plateaus in starting
			--screen
			if is_tutorial then
				if x_dir==-1 then
					local terrace=flr(gen_h/2)
					local overhang=(gen_h)%2
					local x_off=20+rndi_rng(10,15)*terrace-rndi_rng(15,30)*overhang
					x_off=max(x_off,10)
					wall_x=mid_x+x_dir*x_off
				end
			end

			set_vtx(walls,gen_h,wall_x)

			walls[gen_h].is_spiky=b.spike_odds>0 and rndi_rng(0,b.spike_odds)==0 and not walls[max(1,gen_h-1)].is_spiky

			--spawn moles
			local w=walls[gen_h]
			local x_diff=w.head.x-w.tail.x
			local y_diff=w.head.y-w.tail.y
			local is_flat=sgn(x_diff)==x_dir and abs(x_diff)>=1.5*abs(y_diff)
			local wall_valid=gen_h>tutorial_h and gen_h<side_walls-3 and is_flat and fly_dist>2
			local rng=b.mole_odds>0 and rndi_rng(0,b.mole_odds)==0
			if not walls[gen_h].is_spiky and wall_valid and rng then
				local mole={
					pos=v_lerp(
						w.head,
						w.tail,
						rnd_rng(1/4,3/4)
					),
					x_dir=-x_dir,
					bub_tmr=max_bub_tmr,
					bubs={}
				}
				w.mole=mole
				add(moles,mole)
				puff(mole.pos,7,11)

				--preload moles with bubbles
				--so they're relevant quicker
				for i=0,2 do
					local bub=spawn_bub(mole)
					bub.pos.y-=i*bub_y_spd*max_bub_tmr
				end
			end
		end

		-- spawn flies
		local wall_y=l_walls[gen_h].head.y
		local mid_pos=vector(mid_x,wall_y)

		local is_hole=b.hole_odds>0 and rndi_rng(0,b.hole_odds)==0 and not l_walls[gen_h].is_spiky and not r_walls[gen_h].is_spiky and l_walls[gen_h].mole==nil and r_walls[gen_h].mole==nil
		for chk_h=gen_h,max(gen_h-3,1),-1 do
			if l_walls[chk_h].hole then
				is_hole=false
				break
			end
		end
		
		if is_fly then
			add(flies,{
				pos=v_copy(mid_pos),
				home=v_copy(mid_pos),
				spd=vector(0,0),
				num=1+num_chunks-chunk,
				frame=0,
			})
			puff(mid_pos,7,11)
		end

		if is_hole then
			--one struct shared by both walls.
			--vis runs -1..1: which side the
			--rabbit is on, and how far out
			local side=rnd({-1,1})
			local hole={
				vis=side,
				vis_trgt=side,
				holes={},
			}
			for x_dir,walls in pairs(w_groups) do
				local w=walls[gen_h]
				hole.holes[x_dir]={
					pos=v_lerp(w.head,w.tail,0.5)
				}
				w.hole=hole
			end
		end

		gen_h+=1
	end
end

function spawn_bub(mole)
	local bub_pos=snore_pos(mole,bub_rad)
	local bub={
		pos=bub_pos,
	}
	add(bubbles,bub)
	add(mole.bubs,bub)
	return bub
end

function wall_x(walls,y)
	local wall=walls[y_to_wall(y)]
	return x_of_y(wall,y)
end

function x_of_y(wall,y)
	return remap(
		wall.v_head.y,wall.v_tail.y,
		flr(wall.v_head.x),flr(wall.v_tail.x),
		y
	)
end

function bound_x(walls,y)
	local w=walls[y_to_wall(y)]
	return remap(
		w.head.y,w.tail.y,
		w.head.x,w.tail.x,
		y
	)
end

function charge_lvl()
	return mid(
		0,#charge_cols-1,
		flr(plyr.charge+1/12)
	)
end

function hitstop(tmr,func)
	hitstop_tmr=max(hitstop_tmr,tmr)
	if func then
		add(hitstop_funcs,func)
	end
end

function init_world(num_walls)
	clock_menu()
	game_pal()

	cam_off=cam_rest
	cam_shake=0
	xray=0

	hitstop_tmr=0
	hitstop_funcs={}
	smokes={}

	liz_thresh=8
	
	best_y=liz_thresh
	next_freeze=750
	freeze_tmr=0
	game_tmr=0
	game_mins=0
	
	notif_tmr=0

	flies={}
	moles={}
	bubbles={}

	plyr={
		pos=vector(64,bot_y-5),
--		pos=vector(64,bot_y-320),
		ang=0.25,
		rot_spd=0,
		--total turn for frame, gets stepped
		rot_frame=0,
		spd=vector(0,0.75),
		state=plyr_spin,
		charge=0,
		springing=false,
	}
	bub_tmr=0
	stun_tmr=0
	
	tick=0
	outro_t=0
	outro_txts={
		"petal sister",
		"strong of stem",
		"returned to us",
		"we dance again",
		"",
		"z/❘ to continue"
	}

	grow_walls(num_walls)
	gen_h=2
end

function start_menu()
	init_walls()
	init_world(24)
	state=state_menu
end

function start_game()
	sfx(-1)
	init_world(side_walls)
	cam_y=12
	state=state_play
end

function new_biome(params)
	local biome={
		max_mid_dist=127,
		max_l=127,
		min_r=0,
		wriggle=0,
		mole_odds=0,
		hole_odds=0,
		spike_odds=0,
	}
	for key,val in pairs(params) do
		biome[key]=val
	end
	return biome
end

function game_pal()
	pal()
	pal({[0]=0,-15,1,3,-16,-14,4,7,8,9,10,11,-4,13,14,15},1)
end

function clock_label()
	return "clock: "..(clock_vis and "on" or "off")
end

function clock_menu()
	menuitem(3, clock_label(),function()
	 clock_vis=not clock_vis
		clock_menu()
		return true
	end)
end

function _init()
	cartdata("turps_love_me_not")

 lb_init()
 lb_fetch()

	clock_vis=dget(0)!=0

	num_chunks=5
	walls_per_chunk=20

	fly_off=flr(walls_per_chunk/2)
	wall_h=16
	chunk_h=wall_h*walls_per_chunk
	side_walls=num_chunks*walls_per_chunk

	bot_y=127
	bot_pad=12

	cam_rest=96
	cam_fall=022
	cam_slack=16

	wall_margin=1/16

	max_bub_tmr=300
	bub_y_spd=1/8
	bub_rad=5
	fly_rad=4

	game_pal()
	xray_pal={[0]=0,0,0,7,0,0,7,7,7,7,7,7,0,0,0,0}

	state_play,state_leaving,state_intro,state_menu,state_lb=0,1,2,3,4
	plyr_spin,plyr_float,plyr_stun,plyr_bub=0,1,2,3

	charge_cols={10,9,8}
	spring_sfxs={1,5,6}

	tutorial_h=7
	biomes={
		new_biome({}),
		new_biome({mole_odds=1}),
		new_biome({max_l=032,wriggle=15,hole_odds=2}),
		new_biome({max_mid_dist=32,wriggle=8,spike_odds=4}),
		new_biome({mole_odds=2,hole_odds=4,spike_odds=6})
	}

	max_spd=2.0
	min_sep=0.3

	tips={
		"⬅️/➡️ to spin",
		"❘/z to float",
		"spin to jump higher",
		"hold ⬅️/➡️ to drift",
		"tap ⬅️/➡️ to adjust",
	}

	home_menu={
		idx=1,
		items={
			{txt="play",func=function()
				init_walls()
				start_intro()
				cam_y=mouth_y-256
			end},
			{txt="skip intro",func=function()
				music(0)
				init_walls()
				start_game()
			end},
			{txt="leaderboard",func=function()
				state=state_lb
			end}
		}
	}

	start_menu()
	cam_y=mouth_y-256

	flwr_pals={}
	for i=1,50 do
		add(flwr_pals,{
			pos=vector(
				rnd_rng(0,127),
				rnd_rng(mouth_y-6,mouth_y-127+6)
			),
			ang=rnd_rng(0,1)
		})
	end
end

function start_intro()
	init_world(24)

	l_witch_pos=vector(-8,mouth_y-9)
	r_witch_pos=vector(80,mouth_y-9)
	l_witch_spr=0
	l_witch_pal=nil

	intro_t=0
	intro_anims={
		new_anim(0,64,function(t)
			cam_y=lerp(mouth_y-256,mouth_y-128,t)
		end),
		new_anim(100,169,function(t)
			local x=flr(lerp(-8,60,t))
			local y_off=2*abs(sin(1/4+x/16))
			if (x-2)%8==0 do
				sfx(2)
				puff(v_add(l_witch_pos,vector(-2,7)),2.5)
			end
			r_witch_pos.y=mouth_y-9
			l_witch_pos=vector(
				x,mouth_y-9-y_off
			)
		end),
		new_anim(220,220,function(t)
			l_witch_spr=1
			sfx(12)
		end),
		new_anim(310,422,function(t)
			local x=flr(lerp(80,136,t))
			r_witch_pos.x=x
		end),
		new_anim(422,450,function(t)
			l_witch_pal={[15]=14}
		end),
		new_anim(450,500,function(t)
			if intro_t%6==0 then
				sfx(3,0,8)
				puff(v_add(l_witch_pos,vector(4,-6)),2.5)
			end
			l_witch_pal={[15]=8}
		end),
		new_anim(500,554,function(t)
			cam_y=lerp(mouth_y-128,mouth_y-64,t)
		end),
		new_anim(600,600,function(t)
			l_witch_spr=0
			cam_shake=3
			sfx(13,1,0,3)
			sfx(9,0)
		end),
		new_anim(600,739,function(t)
			plyr.pos=vector(
				64,
				lerp(mouth_y-9,bot_y-3,t)
			)
			plyr.ang=plyr.pos.y/64
			cam_y=max(mouth_y-64,plyr.pos.y-113)
		end),
		new_anim(740,740,function(t)
			sfx(3,0)
			puff(plyr.pos,7)
			plyr.ang=1/4
			cam_shake=50
		end),
		new_anim(800,899,function(t)
			l_witch_pal=nil
			l_witch_pos=vector(64,64+2*sin(t*4))
		end),
		new_anim(800,800,function(t)
			puff(l_witch_pos,8,11)
			sfx(14)
		end),
		new_anim(850,850,function(t)
			l_witch_spr=2
			wall_wiggle=true
			sfx(15)
		end),
		new_anim(850,950,function(t)
			for x_dir=-1,1,2 do
				add_smoke(
					v_add(
						l_witch_pos,
						vector(
							x_dir*6+rndi_rng(-1,1),
							rndi_rng(-1,1)
						)
					),
					rnd_rng(2,4),11
				)
			end
			cam_shake=3
		end),
		new_anim(950,950,function(t)
			puff(l_witch_pos,8,11)
			sfx(14)
			l_witch_pos=vector(64,mouth_y-9)
		end),
		new_anim(1100,1100,function(t)
			music(0)
			start_game()
		end)
	}

	state=state_intro
end

function charge_force()
	return 0.45*charge_lvl()
end

function spring(nrm,dir_weight)
	local tan=v_perp(nrm)
	local launch=max(
		0.5,
		1.5*dir_weight*abs(v_dot(plyr.spd,nrm))
	)+charge_force()

	plyr.spd=v_add(
		v_scale(
			tan,
			v_dot(plyr.spd,tan)*(1-dir_weight)
		),
		v_polar(plyr.ang,launch)
	)
	plyr.has_sprung=true

	--avoid tangent landings
	ensure_sep(nrm)

	if plyr.trgt then
		plyr.trgt.spd=v_neg(plyr.spd)
	end

	plyr.springing=true
	sfx(-1,1)
	sfx(2)
	hitstop(3+mid(
		0,7,7*v_mag(plyr.spd)/max_spd
	),function()
		local len=5
		if plyr.trgt then
			len=32
		end
		local fx=spring_sfxs[1+charge_lvl()]
		sfx(fx,-1,0,len)
		puff(flwr_tail(plyr),2.5+launch)
		plyr.charge=0
		plyr.trgt=nil
		plyr.springing=false
	end)
end

function out_side(p)
	if p.y>bot_y then return 0 end
	if p.x<bound_x(l_walls,p.y) then return -1 end
	if p.x>bound_x(r_walls,p.y) then return 1 end
end

function wall_norm(side,y)
	if side==0 then return vector(0,-1) end

	local i=y_to_wall(y)
	local norm,w=face_norm(i,side)

	--a vertex is a corner: two faces meet
	--there and y_to_wall names only one.
	--if that one overhangs, its normal
	--points down-and-in, so a flower
	--falling onto the corner reads as
	--separating -- land() drops the
	--contact and rewinds, and the frame
	--nets nothing, every frame. take the
	--face we are most heading into.
	--y sits inside section i, so these
	--differences are never negative and
	--need no abs
	local k=i
	if y-w.head.y<1 then k=i+1
	elseif w.tail.y-y<1 then k=i-1 end

	if wall_groups[side][k] then
		local n,nb=face_norm(k,side)
		if v_dot(plyr.spd,n)<v_dot(plyr.spd,norm) then
			return n,nb,k
		end
	end
	return norm,w,i
end

function face_norm(i,side)
	local w=wall_groups[side][i]
	local n=v_perp(v_norm(v_sub(w.tail,w.head)))
	--face into cave
	if n.x*side>0 then n=v_neg(n) end
	return n,w
end

function within(a,b,dist)
	return max(abs(a.y-b.y),abs(a.x-b.x))<dist and v_dist(a,b)<dist
end

--fractions along the stem worth testing
function stem_fs(head,tail)
	local fs={1,0}
	--a level stem gives ylo==yhi, and
	--then no vy can sit strictly between
	--them, so the walk is a no-op
	local ylo=min(head.y,tail.y)
	local yhi=max(head.y,tail.y)
	for k=y_to_wall(yhi),y_to_wall(ylo) do
		local vy=l_walls[k].head.y
		if vy>ylo and vy<yhi then
			add(fs,remap(tail.y,head.y,0,1,vy))
		end
	end
	return fs
end

--rewind to last good spot
function land(norm,was_pos,was_ang)
	plyr.pos=was_pos
	plyr.ang=was_ang
	if v_dot(plyr.spd,norm)<=0 then return true end
	plyr.rot_frame=0
end

function warp(w,x_dir,w_idx)
	puff(plyr.pos,4)
	sfx(14)

	local trgt_w=wall_groups[-x_dir][w_idx]
	local trgt_pos=w.hole.holes[-x_dir].pos
	local trgt_norm=v_rotby(v_dir(trgt_w.tail,trgt_w.head),-x_dir/4)

	local turn=ang_diff(
		v_angle(v_neg(
			v_rotby(v_dir(w.tail,w.head),x_dir/4)
		)),
		v_angle(trgt_norm)
	)

	local spd_turn=turn+ang_diff(
		v_angle(plyr.spd)+turn,
		v_angle(trgt_norm)
	)/2

	plyr.ang+=turn
	plyr.spd=v_rotby(plyr.spd,spd_turn)

	plyr.spd=v_div(
		plyr.spd,
		mid(1,1/64,v_mag(plyr.spd)/0.8)
	)
	cam_shake=4

	hitstop(10,function()
		plyr.pos=v_add(trgt_pos,v_scale(trgt_norm,3))
		puff(plyr.pos,4)
		sfx(14)
		cam_shake=4

		free_stun()
	end)
end

function plyr_collide(was_pos,was_ang)
	if state!=state_play then return end

	local head,tail=flwr_ends()

	for f in all(stem_fs(head,tail)) do
		local p=v_lerp(tail,head,f)
		local side=out_side(p)
		if side then
			local norm,w,w_idx=wall_norm(side,p.y)
			if not land(norm,was_pos,was_ang) then return end
			if w and w.hole
				and v_dist(w.hole.holes[side].pos,plyr.pos)<=8 then
				warp(w,side,w_idx)
			elseif f<0.5
				and not (w and w.is_spiky)
				and plyr.state!=plyr_stun then
				spring(norm,0.6)
			else
				stun(norm)
			end
			return true
		end
	end

	for fly in all(flies) do
		for point in all{head,tail} do
			if within(fly.pos,point,fly_rad) then
				local norm=v_norm(v_sub(point,fly.pos))
				if not land(norm,was_pos,was_ang) then return end
				if point==tail and plyr.state!=plyr_stun then
					plyr.trgt=fly
					spring(norm,0.68)
				else
					stun(norm)
				end
				return true
			end
		end
	end
end

--enough steps that no control point
--moves more than half a pixel. they
--sit 2 out from pos, so a full turn
--drags them 2*pi*2 further than the
--body itself travels
function plyr_substeps()
	return mid(
		1,16,
		1+flr((
			v_mag(plyr.spd)
			+12.6*abs(plyr.rot_frame)
		)/0.5)
	)
end

--step movement, rollback collision
function wall_push()
	local head,tail=flwr_ends()
	local pr,pl=0,0
	foreach(stem_fs(head,tail),function(f)
		local p=v_lerp(tail,head,f)
		if p.y<=bot_y then
			pr=max(pr,bound_x(l_walls,p.y)-p.x+wall_margin)
			pl=min(pl,bound_x(r_walls,p.y)-p.x-wall_margin)
		end
	end)
	--pr is never negative, so it is its
	--own abs. take the deeper side, not
	--the sum: summing lands on a value
	--that satisfies neither when the
	--flower is wider than the gap
	local push=abs(pl)>pr and pl or pr
	--clear the boundary rather than
	--landing exactly on it
	if push!=0 then push+=sgn(push)/32 end
	return push
end

--push out of flies
function fly_escape()
	local head,tail=flwr_ends()
	local best,best_d=nil,0
	foreach(flies,function(fly)
		if within(fly.pos,plyr.pos,8) then
			for p in all{head,tail} do
				local d=v_sub(p,fly.pos)
				if v_magsq(d)<fly_rad^2 then
					local depth=fly_rad-v_mag(d)+1/32
					if depth>best_d then
						local n=v_norm(d)
						if n.x==0 and n.y==0 then
							n=vector(0,-1)
						end
						best_d=depth
						--capped here so it reads as a
						--nudge, not a pop
						best=v_scale(n,min(depth,1))
					end
				end
			end
		end
	end)
	return best
end

function depenetrate()
	if state!=state_play then return end

	local esc=fly_escape()
	if esc then
		plyr.pos=v_add(plyr.pos,esc)
	end

	for i=1,3 do
		local push=wall_push()
		if push==0 then break end
		plyr.pos.x+=push
	end
end

function move_plyr()
	depenetrate()

	local steps=plyr_substeps()
	local dt=1/steps

	for i=1,steps do
		local was_pos=v_copy(plyr.pos)
		local was_ang=plyr.ang

		plyr.ang=(
			plyr.ang+plyr.rot_frame*dt
		)%1
		plyr.pos=v_add(
			plyr.pos,v_scale(plyr.spd,dt)
		)

		if plyr_collide(was_pos,was_ang) then
			break
		end
	end
	depenetrate()
end

function ang_diff(a,b)
	local d=(b-a)%1
	if d>0.5 then d-=1 end
	return d
end

--set spd and rot_frame
function play_input()
	local mv=0
	if btn(➡️) then
		mv-=1
	end
	if btn(⬅️) then
		mv+=1
	end

	if plyr.state==plyr_stun then
		plyr.spd.y+=0.02
		plyr.rot_frame=plyr.rot_spd
		return
	elseif plyr.state==plyr_bub then
		spin(mv)

		bub_tmr=max(0,bub_tmr-1)
		if bub_tmr<=0 then
			plyr.spd=v_polar(plyr.ang,1.0+charge_force())
			plyr.state=plyr_spin
			puff(flwr_tail(plyr),charge_lvl()+1)
			plyr.charge=0
			cam_shake=2
			sfx(13,0)
		end

		return
	end

	local next_float=plyr.has_sprung!=nil and (btn(❘) or btn(🅾️))
	if next_float!=(plyr.state==plyr_float) then
		--todo: custom sound
		puff(flwr_head(plyr),next_float and 3 or 2)
		sfx(2)
	end

	if next_float then
		plyr.state=plyr_float
		plyr.spd.x+=0.02*-mv

		plyr.charge=0
		plyr.spd.y=mid(0.2,-0.6,plyr.spd.y)
		plyr.spd.x=mid(0.5,-0.5,plyr.spd.x)

		local trgt_dir=v_norm(v_lerp(
			vector(0,-1),
			vector(plyr.spd.x,0),
			min(v_mag(plyr.spd),7/8)
		))
		--same heading by the end of the
		--frame as the old lerp gave, just
		--handed over as an angle
		plyr.rot_frame=ang_diff(
			plyr.ang,
			v_angle(v_norm(v_lerp(
				v_polar(plyr.ang,1),
				trgt_dir,
				0.25
			)))
		)
	else
		plyr.state=plyr_spin
		plyr.spd.x+=0.015*-mv
		spin(mv)
	end
	plyr.spd.y+=0.02
end

function spin(dir)
	--allow micro adjustments
	if dir==0 or sgn(dir)!=sgn(plyr.rot_spd) then
		plyr.rot_spd=0
	end
	plyr.rot_spd=mid(-6/128,6/128,plyr.rot_spd+1/128*dir)
	plyr.rot_frame=plyr.rot_spd

	local prev_lvl=charge_lvl()
	plyr.charge+=abs(plyr.rot_spd)
	if prev_lvl!=charge_lvl() then
		sfx(6+charge_lvl())
	end
end

function fly_flwr(flwr,y1,y2)
	flwr.ang=(
		flwr.ang+rnd_rng(0.01,0.02)
	)%1
	flwr.pos.x+=rnd_rng(1.3,1.6)
	if flwr.pos.x>132 then
		flwr.pos.x=-4
		flwr.pos.y=rnd_rng(y1,y2)
		flwr.spd=vector(0,0)
	end
end

function update_intro()
 update_anims(intro_anims,intro_t)
	intro_t+=1

	if wall_wiggle do
		for_screen_walls(function(w,w_idx,x_dir,walls)
			if w_idx>1 and v_dist(w.v_head,w.head)<1 do
				set_vtx(
					walls,w_idx,
					rndi_rng(64+60*x_dir,64+24*x_dir)
				)
			end
		end)
	end
end

function update_bub(i)
	local bub=bubbles[i]
 --todo: ideally check both head and tail
	if within(bub.pos,plyr.pos,bub_rad) then
		enter_bubble(bub)
		swap_del(bubbles,i)
		return
	end

	bub.pos.y-=bub_y_spd
	bub.pos.x+=1/16*sin(t()/4)

	foreach(flies,function(fly)
		if bub.pos.y<mouth_y+bub_rad or within(fly.pos,bub.pos,fly_rad+bub_rad) then
			puff(bub.pos,2.5)
			swap_del(bubbles,i)
			return
		end
	end)

	for y_dir=-1,1 do
		for x_dir,walls in pairs(wall_groups) do
			local w_idx=y_to_wall(bub.pos.y+y_dir*wall_h)
			local w=walls[w_idx]
			if w and circ_xsect_line(w,bub.pos,bub_rad+1) then
				puff(bub.pos,2.5)
				swap_del(bubbles,i)
				return
			end
		end
	end
end
function btnp_go()
	return btnp(❘) or btnp(🅾️)
end

function cam_appr(y,rate)
	rate=rate or 1/8
 cam_y=cam_y+rate*(y-cam_y)
end

function _update()
	tick+=1
 lb_update()

	if cam_y<mouth_y then
		foreach(flwr_pals,function(flwr)
			fly_flwr(
				flwr,
				min(mouth_y-128,cam_y),
				min(cam_y+128,mouth_y-6)
			)
		end)
	end

 if state==state_leaving then
  cam_appr(mouth_y-116,1/32)
  outro_t+=1
  if btnp_go() then
  	sfx(10)
  	outro_t=0
  	state=state_lb
  end
 elseif state==state_menu then
  update_menu(home_menu)
		cam_appr(mouth_y-256)
		return
	elseif state==state_lb then
		if btnp_go() then
			sfx(10)
 		state=state_menu
 	end
 	cam_appr(mouth_y-116)
		return
	end

	if freeze_tmr>0 then
		freeze_tmr-=1
	else
		game_tmr+=1
		if game_tmr>=1800 then
			game_mins+=1
			game_tmr=0
		end
	end

	for_screen_walls(function(w,w_idx,x_dir,walls)
		set_v_vtx(
			walls,w_idx,
			(3*w.v_head.x+w.head.x)/4
		)
		if v_dist(w.v_head,w.head)>1 then
			add_smoke(
				v_lerp(w.v_head,w.v_tail,rnd_rng(0,1)),
				rnd_rng(2,4),11
			)
		end
	end)

	cam_shake=max(0,cam_shake-1)
 update_smokes()

	xray=max(0,xray-1)
	if hitstop_tmr>0 then
		hitstop_tmr-=1
		if hitstop_tmr<=0 then
			foreach(hitstop_funcs,function(func)
				func()
			end)
			hitstop_funcs={}
		end
		return
	end

	if state==state_intro then
		update_intro()
		return
	end

	if state==state_play then
		play_input()
	else
		plyr.spd.y*=0.99
		plyr.rot_frame=0
	end

	foreach(flies,function(fly)
		fly.spd.y=fly.spd.y*0.99+0.03
		fly.spd.x*=0.9

		fly.pos=v_add(fly.pos,fly.spd)

		local max_frame=6

		fly.frame+=0.4375
		if fly.pos.y>fly.home.y+8 then
			if fly.frame>=max_frame then
				fly.frame=0
			end

			local home_diff=v_sub(fly.home,fly.pos)
			local flap_acc=0.1
			fly.spd=v_add(
				fly.spd,
				v_scale(
					v_norm(home_diff),
					min(flap_acc,v_mag(home_diff))
				)
			)
		end
	end)

	plyr.spd=v_div(
		plyr.spd,
		max(1,max(0.01,v_mag(plyr.spd))/max_spd)
	)

	move_plyr()

	foreach(moles,function(mole)
		if abs(offscreen_by(mole.pos.y))<=chunk_h then
			mole.bub_tmr+=1
			if mole.bub_tmr>=max_bub_tmr then
				mole.bub_tmr=0
				spawn_bub(mole)
			end
		end
	end)

	for_screen_walls(function(w,w_idx,x_dir,walls)
		if w.hole==nil then
			return
		end
		local h=w.hole
		local pos=h.holes[x_dir].pos

		if x_dir==-1 then
			local d_l=v_dist(plyr.pos,h.holes[-1].pos)
			local d_r=v_dist(plyr.pos,h.holes[01].pos)
			local close=min(d_l,d_r)

			if close<12 then
				h.vis_trgt=0
			elseif close>32 then
				if h.vis_trgt==0 then
					h.vis_trgt=-sgn(plyr.pos.x-64)
				end
			else
				h.vis_trgt=sgn(d_r-d_l)
			end
			h.vis+=(h.vis_trgt-h.vis)/4
		end
	end)

	for i=#bubbles,1,-1 do
		update_bub(i)
	end

	notif_tmr=max(0,notif_tmr-1)
	if state==state_play then		
		local fall=mid(0,1,plyr.spd.y/max_spd)
		local trgt=lerp(cam_rest,cam_fall,fall)
		cam_off+=(trgt-cam_off)/32
		cam_y=mid(
			cam_y,
			plyr.pos.y-cam_off-cam_slack,
			plyr.pos.y-cam_off+cam_slack
		)
		cam_y=min(bot_pad,cam_y)
				
		if liz==nil and offscreen_by(best_y)<=-liz_thresh then
			--fell below best
			liz={
				y=best_y,
				tongue=true
			}
		end
		
		if liz then
			if plyr.pos.y<liz.y and liz.tongue then
				local pop_x=0
				while pop_x<128 do
					pop_x+=flr(rnd_rng(1,4))
					add_smoke(
						vector(pop_x,liz.y+rnd_rng(-2,2)),
						rnd_rng(2,4),
						7
					)
				end
	
				sfx(10,0)
				notif_txt="new best!"
				notif_tmr=90
				liz.tongue=false
				
				if next_freeze>0 then
					freeze_tmr+=next_freeze
					next_freeze-=150
				end
			end

			if offscreen_by(liz.y)>=liz_thresh then
				--climbed above liz
				liz=nil	
			end
		end
		
		best_y=min(best_y,plyr.pos.y)
	end

	gen_walls()
	if plyr.pos.y<mouth_y then
		leave_cave()
	end
end

function rock_depth(w_width,px_x,px_y)
	--shallow slopes reach further
	return 20
		+w_width/8
		-4*sin(px_y/32)
end

function draw_wall(w,col)
	line(
		w.v_tail.x,w.v_tail.y,
		w.v_head.x,w.v_head.y,
		col
	)
end

function grass_wall(w,y_dir)
	local x_len=abs(w.v_head.x-w.v_tail.x)
	for i=0,x_len do
		local prog=i/x_len
		local pos=v_lerp(w.v_head,w.v_tail,prog)
		local px=flr(pos.x)
		local py=flr(pos.y)
		local len=(abs(sin(123.14*(px+20*y_dir)/10)))*3.0
		line(px,py,px,py+y_dir*len,3)
	end
	draw_wall(w,3)
end

function snap_out(v,n)
	local x,y=flr(v.x),flr(v.y)
	if n.x>=0 then x=ceil(v.x) end
	if n.y>=0 then y=ceil(v.y) end
	return x,y
end

function draw_rabbit(pos,vis,norm,x_dir)
	local anim=pulse(t(),0.5)
	local embed=2+anim
	local n=flr(16*vis)
	if n<=embed then return end

	local ns=v_dot(norm,vector(0,-1))
	local ew=v_dot(norm,vector(-1,0))

	if abs(ew)*3/4>abs(ns) then
		--sideways
		local left=x_dir==1
		local x=pos.x+embed*x_dir
		if left then x-=n end
		sspr(
			32-n,72,n,6,
			x,pos.y-3,
			n,6,
			left
		)
	else
		local up=ns>0
		local y=pos.y-embed
		if up then y=pos.y+embed-n end
		sspr(
			56,80,6,n,
			pos.x-3,y,
			6,n,
			x_dir==1,
			not up
		)
	end
end

function spike_wall(w,x_dir)
	local wall_dir=v_dir(w.v_tail,w.v_head)
	local wall_norm=v_rotby(wall_dir,x_dir*1/4)
	local tip_off=v_scale(wall_norm,2.5)

	local step=4/v_dist(w.v_tail,w.v_head)
	for i=step,1-step,step do
		local a=v_lerp(w.v_tail,w.v_head,i)

		local tx,ty=snap_out(
			v_add(a,tip_off),wall_norm
		)

		for root_off=-1,1,1 do
			local bx,by=snap_out(
				v_add(a,v_scale(wall_dir,root_off)),
				wall_norm
			)
			local col=8
			if root_off==-1 then
				col=5
			end
			line(bx,by,tx,ty,col)
		end
	end
	draw_wall(w,11)
end

function fmt_t(t)
	local txt=""
	if t<0 then
		txt="-"
		t*=-1
	end
	
	local t_int=flr(t)
	local t_frac=t-t_int

	local mins=flr(t_int/60)
	local secs=t_int-60*mins
	local ms=flr(100*t_frac)

	txt=txt..mins..":"

	if secs<10 then
		txt=txt.."0"
	end
	txt=txt..secs.."."

	if ms<10 then
		txt=txt.."0"
	end
	txt=txt..ms

	return txt
end

function game_t()
	return game_mins*60+game_tmr/30
end

function y_to_wall(y)
 return mid(
 	2,#l_walls,
 	2+flr((bot_y-1-y)/wall_h)
 )
end

function y_to_h(y)
	return 127-y
end
h_to_y=y_to_h

function offscreen_by(y)
	return y-mid(y,cam_y,cam_y+128)
end

function for_screen_walls(func)
	local walls_per_screen=ceil(1+(128/wall_h))
	local bot_idx=mid(1,#l_walls,1+flr(abs(min(cam_y,0))/wall_h))
	local top_idx=mid(1,#l_walls,1+bot_idx+walls_per_screen)

	for w_idx=bot_idx,top_idx do
		for x_dir,walls in pairs(wall_groups)	do
   local w=walls[w_idx]
			if func(w,w_idx,x_dir,walls) then
				return
			end
		end
	end
end


function snore_pos(mole,bub_sz)
	return vector(
		mole.pos.x+ceil(3.5+bub_sz)*mole.x_dir,
		mole.pos.y-3-bub_sz
	)
end

function pulse(ph,cut)
	return sin(ph)>cut and 1 or 0
end

function mole_anim(mole)
	local bub_sz=bub_rad*mole.bub_tmr/max_bub_tmr-1
	local anim=1
	if bub_sz<0 or bub_sz>=1 then
		anim=pulse(bub_sz+3/16,-0.92)
	end
	return anim,bub_sz
end

function draw_bub(pos)
	circ(pos.x,pos.y,bub_rad,7)
	pset(pos.x+2,pos.y-2,7)
end

function _draw()
	cls(12)

	if xray>0 then
		pal(xray_pal)
	else
		game_pal()
	end

	local bg_off=max(0,mouth_y-cam_y)
	palt(0)
	map(0,0,0,bg_off,16,16)
	palt()

	local shake=vector(0,0)
	if cam_shake>0 then
		shake=vector(
			rnd_rng(-2,2),
			rnd_rng(-2,2)
		)
	end
	camera(0+shake.x,cam_y+shake.y)

	if cam_y<mouth_y then
		foreach(flwr_pals,draw_flwr)
	end

	color(7)
	hcntr_print("\^ocff\^t\^wlove me not",mouth_y-196)
	hcntr_print("\^ocffBY JACK TURPITT",mouth_y-186)
	draw_menu(home_menu,mouth_y-176,"\^ocff")
	hcntr_print("\^ocffz/❘ to select",mouth_y-136)

	if state==state_lb or state==state_menu then
		color(7)
		if total_t then
			print("\^ocfftime: "..fmt_t(total_t),4,mouth_y-110)
			print("\^ocffbest: "..fmt_t(best_t),68,mouth_y-110)
		end
		local lb_y=mouth_y-96
		local y_off=64
		hcntr_print("\^ocffleaderboard",lb_y)
		for idx=1,max(10,#lb_board) do
			local row=lb_board[idx] or {name="........",score=0}
			local y=lb_y+7*idx
		 print("\^ocff"..idx..". "..row.name,12,y)
		 local s=""..fmt_t(-row.score)
		 print("\^ocff"..s,116-4*#s,y)
		end
		hcntr_print("\^ocffz/❘ to continue",mouth_y-12)
	end

	if state==state_intro then
		if l_witch_pal then
			pal(l_witch_pal)
		end
		sspr(
			16*l_witch_spr,80,
			16,16,
			l_witch_pos.x-8,l_witch_pos.y-8
		)

		pal({[15]=6,[6]=0,[5]=0})
		sspr(
			0,80,
			16,16,
			r_witch_pos.x-8,r_witch_pos.y-8,
			16,16,true
		)
		game_pal()
	end

	--draw outro
 color(7)
 local prog=outro_t/96
 for ln=1,min(#outro_txts,flr(prog)) do
 	local txt=outro_txts[ln]
 	local ln_prog=32*(prog-ln)
 	if ln_prog<#txt and ln_prog%1==0 then
 		sfx(4)
 	end
 	hcntr_print("\^ocff"..sub(txt,1,ln_prog),mouth_y-96+14*ln)
 end

	foreach(flies,function(fly)
		circfill(fly.pos.x,fly.pos.y+1,7,5)	
	end)

	foreach(flies,function(fly)
		local frame=mid(0,2,flr(fly.frame))
		sspr(frame*16,112,16,16,fly.pos.x-7,fly.pos.y-10)
		print(fly.num,fly.pos.x-1,fly.pos.y-2,10)
	end)

	--draw mole bodies
	foreach(moles,function(mole)
		local anim,bub_sz=mole_anim(mole)

		local flip_x=mole.x_dir==-1
		sspr(48,100+anim*16,12,12,mole.pos.x-6,mole.pos.y-9,12,12,flip_x)
		if bub_sz>=1 then
			local bub_pos=snore_pos(mole,flr(bub_sz))
			circ(bub_pos.x,bub_pos.y-anim,bub_sz,7)
		end
	end)

	function get_dirt_pos(w,x_dir,off)
		local wall_dir=v_dir(w.v_tail,w.v_head)
		local norm=v_rotby(wall_dir,x_dir*1/4)
		local hole_pos=v_add(
			v_lerp(w.v_head,w.v_tail,0.5),
			v_scale(norm,1)
		)
		return v_add(
			hole_pos,
			v_scale(wall_dir,off)
		),norm
	end

	for_screen_walls(function(w,w_idx,x_dir,walls)
		if w.hole then
			for off=-2.5,2.5,2.5 do
				local dirt_pos=get_dirt_pos(w,x_dir,off)
				circfill(dirt_pos.x,dirt_pos.y,2,5)
			end
			local rab_pos,norm=get_dirt_pos(w,x_dir,0)
			draw_rabbit(rab_pos,max(0,x_dir*w.hole.vis),norm,x_dir)
		end
	end)

	--draw player
	local stem_col=11
	local petal_col=charge_cols[1+charge_lvl()]
	if plyr.state==plyr_stun and tick%4<2 then
		stem_col=7
		petal_col=7
	end

	local head=flwr_head(plyr)
	local tail=flwr_tail(plyr)
	if plyr.springing then
		head=plyr.pos
	end

	line(head.x,head.y,tail.x,tail.y,stem_col)

	local petal_rad=1
	if plyr.state==plyr_float then
		petal_rad=2
	end
	circfill(head.x,head.y,petal_rad,petal_col)
	circfill(head.x,head.y,petal_rad-1,7)

	if plyr.state==plyr_bub then
		draw_bub(plyr.pos)
		local dot_pos=v_add(
			plyr.pos,
			v_polar(plyr.ang,7.5)
		)
		pset(dot_pos.x,dot_pos.y,7)
	end

	foreach(bubbles,function(bub)
		draw_bub(bub.pos)
	end)

 draw_smokes(smokes)

	rectfill(-4,bot_y,132,256,1)
	map(16,0,0,bot_y,16,2)
	color(5)
	hcntr_print("\^o1ff"..tips[1+flr(t()/5)%#tips],bot_y+5)

	--draw walls
	for_screen_walls(function(w,w_idx,x_dir,walls)
		if w.hole do	
			for off=-5,5,10 do
				local dirt_pos=get_dirt_pos(w,x_dir,off)
				circfill(dirt_pos.x,dirt_pos.y,2,6)
			end
		end

		local w_run=(w.v_head.x-w.v_tail.x)*x_dir

  --draw wall bg
  for px_y=w.v_head.y,w.v_tail.y do
   local px_x=x_of_y(w,px_y)
   if x_dir==-1 then
    px_x=flr(px_x)
   else
    px_x=ceil(px_x)
   end
   local edge_x=64+x_dir*68
   rectfill(edge_x,px_y,px_x,px_y,1)

   local rock_x=px_x+x_dir*rock_depth(
    abs(w_run),px_x,px_y
   )
   local tex_y=((px_y+1)/8)%16
   if x_dir==-1 then
    local tmp_x=rock_x
    rock_x=px_x
    px_x=tmp_x
   end
   px_x=flr(px_x)
   rock_x=flr(rock_x)
   local tex_x=16+px_x/8
   tline(px_x,px_y,rock_x,px_y,tex_x,tex_y)
  end

		--draw wall edge
		local w_rise=abs(w.v_head.y-w.v_tail.y)
	 if w.is_spiky then
	 	spike_wall(w,x_dir)
	 elseif w_run>=1.375*w_rise then
	 	grass_wall(w,1)
	 else
	 	--dirt
	 	draw_wall(w,6)
	 end
	end)

	--draw cave mouth
	local grass_w={
		v_head=vector(127,mouth_y),
		v_tail=vector(0,mouth_y),
	}
	grass_wall(grass_w,-1)
	grass_wall(grass_w,01)

	-- draw mole hands
	foreach(moles,function(mole)
		local x=mole.pos.x-2
		local anim=mole_anim(mole)
		sspr(59,112,5,4,x+flr((-1.5+anim)*mole.x_dir),mole.pos.y-2)
		sspr(59,112,5,4,x+flr((6.5-anim)*mole.x_dir),mole.pos.y-1)
	end)

	--draw liz
	if liz then
		local l_x=wall_x(l_walls,liz.y)
		local r_x=wall_x(r_walls,liz.y)
		local anim=pulse(t()/2.5,0.95)

		if liz.tongue then
			circfill(r_x+8,liz.y,3,1)
			line(l_x-5,liz.y,r_x+6,liz.y,8)
			circfill(r_x+8,liz.y,2,8)
			line(r_x+4,liz.y-1,r_x+8,liz.y-1,8)
			line(r_x+4,liz.y+1,r_x+8,liz.y+1,8)
		end
		sspr(0+24*anim,96,24,16,l_x-26,liz.y-7)
	end

	--ui
	camera(0,0)
	local flash_cols={7,10,9,8,9,10}
	local flash_col=flash_cols[1+tick\2%#flash_cols]
	if notif_tmr>0 then
		color(flash_col)
		hcntr_print(notif_txt,12)
	end

	if clock_vis and state==state_play then
		local tmr_col=7
		if freeze_tmr>0 then
			print(fmt_t(freeze_tmr/30),2,116,flash_col)
			tmr_col=13
		end
		print(fmt_t(game_t()),2,122,tmr_col)
	end
end
--♪ violet tactics - toby fox
--cover by squishyam, sept. 2026
function _init()
	init_vis()
	titles={}
	--⬇️wave scroll speed
	--zero to turn off
	scroll_speed=0.25
	
	--on: noise is a sprite
	--off:noise is a wave
	noise_as_sprite=false
	
	--makes square wave more
	--squareish and pointy
	better_square_wave=true
	
	--makes saw wave more
	--squareish and pointy
	pointy_saw_wave=false
	
	--makes all waves more
	--squareish and pointy
	jagged_waves=true
	
	--another fill type
	sea_wave=false
	
	disco_bg=false
	
	--⬇️start pattern
	if (#stat(6)>0)reload(0x3100,0x3100,0x1200,stat(6))
	music()
	
	--⬇️wave and background color
	--for each channel
	cols={8,15,11,14}
	cols={12,12,12,12}
	--cols={7,7,7,7}
	bgcols={0,0,0,0}
	--bgcols={2,4,3,1}
	
	notename={
		[0]="c-",
		[1]="c#",
		[2]="d-",
		[3]="d#",
		[4]="e-",
		[5]="f-",
		[6]="f#",
		[7]="g-",
		[8]="g#",
		[9]="a-",
		[10]="a#",
		[11]="b-",
	}
	tickoff={[0]=0,0,0,0}
	last_tickoff_pos={[0]=-1,-1,-1,-1}
	was_noise={false, false, false, false}
	channels={}
end

function _update60()
	update_vis()
	get_music_data()
end

function _draw()
	draw_vis()
	white_noise_cached=false
	--cls()
	local patno=stat(54)
	local subpat=channels[0].note_id\8
	local titletxt=titles[patno*4+subpat+1]
	if type(titletxt)=="string" then
		show_title=true
	else
		show_title=false
	end
	--show_title=true
	for chno=0,3 do
		local ch_dat=channels[chno]
		local cx=64
		local box_h=show_title and 15 or 16
		local cy=box_h+chno*box_h*2
		if(show_title and chno>1)cy+=8
		local col=cols[chno+1]
		local bgcol=bgcols[chno+1]
		--bg fill
		if disco_bg then
			clip(0,cy-16,128,32)
			circfill(63,cy+1,lerp(ch_dat.prev_note_volume,ch_dat.note.volume,ch_dat.note.progress)*12+sin(t()+chno/4)*ch_dat.note.volume/3,bgcol)
			clip()
		else
			--rectfill(0,cy-15,127,cy+14,bgcol)
		end
		local is_noise=ch_dat.note.wave==6 --and not ch_dat.note.custominst
		local detune=ch_dat.cheffs.detune
		--piano line
		if ch_dat.note.volume>0 then
			for detoff=0,(detune==2 and not is_noise) and 1 or 0 do
				local pit=ch_dat.note.pitch+detoff*12
				--if(pit>=0 and pit<64)line(1+pit,cy+14,1+pit,cy+14-ch_dat.note.volume*1.5*(3-detoff)/3,col)
			end
		end
		--channel border
		--rect(0,cy-box_h,127,cy+box_h-1,col)
		--dotted lines:
		--fillp(0b1010010110100101.1)
		--horizontal line
		--line(0,cy+box_h-15,126,cy+box_h-15,col)
		--vertical line
		--line(66,cy+1,66,cy+15)
		--fillp()
		--pit & vol info
		if ch_dat.note.volume>0 then
--			print("pit:"..notename[flr(ch_dat.note.pitch%12)]..ch_dat.note.pitch\12 --[[.."("..flr(ch_dat.note.pitch)..")"]],68,cy+box_h-13,col)
		else
			--print("pit:0",68,cy+box_h-13,col)
		end
		--print("vol:"..flr(ch_dat.note.volume),68,cy+box_h-7,col)
		if is_noise and noise_as_sprite then
			local halfh=ch_dat.note.volume/7*box_h/2
			if ch_dat.note.volume>0 then
				--[[
				--if not white_noise_cached then
					for addr=0x8000,0x8000+2048,4 do
						local densitymask=0xffff.ffff
						densitymask=densitymask>>>(((1-ch_dat.note.pitch/64)^2)*32)>><flr(rnd(16)*2)
						local val=rnd(0xffff)--noise
						val&=0x1111.1111--pixel mask
						val&=densitymask
						poke4(addr,val)--generate masked noise in extended ram
					end
				--	white_noise_cached=true
				--end
				poke(0x5f54,0x80)--spritesheet is extended ram
				pal(1,col)
				sspr(1,1,126,halfh*2,cx-63,cy-box_h\2-halfh+1)
				pal()
				poke(0x5f54,0)
				]]
				if not white_noise_cached then
					for addr=0x8000,0x8000+2048,4 do
						poke4(addr,rnd(0xffff.ffff))
					end
					white_noise_cached=true
				end
				poke(0x5f54,0x80)--spritesheet is extended ram
				--pal(1,col)
				--local palette={}
				local thres=ceil(15-ch_dat.note.pitch/64*15)
				for ci=0,thres-1 do
					palt(ci,true)
					--palette[ci+1]=0
				end
				for ci=thres,15 do
					pal(ci,col)
					--palette[ci+1]=col
				end
				--pal(palette)
				sspr(1,1,126,halfh*2,cx-63,cy-box_h\2-halfh+1)
				--pal({1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0},0)
				pal()
				poke(0x5f54,0)
				was_noise[chno]=true
			end
		else
			if ch_dat.note.volume>0 or not was_noise[chno] then
				was_noise[chno]=false
				--draw wave shenanigans
				local prev_dx,prev_dy
				local freq=1.5*2^(ch_dat.note.pitch/12)
				local freq2
				if(detune>0)freq2=1.5*2^((ch_dat.note.pitch-0.9)/12)*detune
				for dx=-64,64 do
					local pos=(dx/128)*freq
					local waveval=get_wave_val(ch_dat.note.wave,pos,ch_dat.note.customwave,scroll_speed)
					local dy=waveval*ch_dat.note.volume
					if freq2 then
						local pos2=(dx/128)*freq2
						local waveval2=get_wave_val(ch_dat.note.wave,pos2,ch_dat.note.customwave,scroll_speed+1)
						dy=dy*0.6+(waveval2*ch_dat.note.volume)*0.4
					end
					if(show_title)dy*=0.9
					dy-=7
					if (not prev_dx)prev_dx,prev_dy=dx,dy
					local pointy=jagged_waves or (better_square_wave and ch_dat.note.wave==3 or ch_dat.note.wave==4)or (pointy_saw_wave and ch_dat.note.wave==2)
					if sea_wave then
						line(cx+(pointy and dx or prev_dx+1),cy+1,cx+dx,cy+dy,col)
					else
						line(cx+(pointy and dx or prev_dx),(cy/2)+10+prev_dy,cx+dx,(cy/2)+dy+10,0)
						line(cx+(pointy and dx or prev_dx),(cy/2)+12+prev_dy,cx+dx,(cy/2)+dy+12,0)
						line(cx+(pointy and dx or prev_dx),(cy/2)+11+prev_dy,cx+dx,(cy/2)+dy+11,col)
--						line(cx+(pointy and dx or prev_dx),(cy/2)+9+prev_dy,cx+dx,(cy/2)+dy+11,0)
					end
					prev_dx,prev_dy=dx,dy
				end
			end
		end
	end
	local patno=stat(54)
	local subpat=channels[0].note_id\8
	local titletxt=titles[patno*4+subpat+1]
	if show_title and titletxt then
		local width=?titletxt,0,-100
		?"\#1\f0"..titletxt,64-width\2,61
	end
	
end

function get_music_data()
	for chno=0,3 do
		cur_calc_ch=chno
		cheffs={noiz=false,buzz=false,detune=0,reverb=0,dampen=0}
		local ticksno=stat(56)
		local chinfo={
			sfx_id=stat(46+chno),
		}
		chinfo.sfx_speed=@(0x3200+chinfo.sfx_id*68+65)
		chinfo.note_progress=ticksno/chinfo.sfx_speed%1
		chinfo.note_id=ticksno\chinfo.sfx_speed%32
		if channels[chno] then
			if channels[chno].note_id!=chinfo.note_id then
				--new note
				chinfo.new_note=true
				chinfo.prev_note=channels[chno].note
			else
				chinfo.prev_note=channels[chno].prev_note
			end
		else
			chinfo.prev_note={pitch=0,volume=0,effects={},wave=0,custom=0}
		end
		if chinfo.sfx_id!=-1 then
			local note=get_note_at_sfx(chinfo.sfx_id,chno)
			if #note.effects>0 then
				if count(note.effects,1)>0 then
					note.pitch=lerp(chinfo.prev_note.pitch,note.pitch,note.progress)
					note.volume=lerp(chinfo.prev_note.volume,note.volume,note.progress)
				end
				if count(note.effects,2)>0 then
					note.pitch+=sin(t()*10)*note.pitch/32
				end
				if count(note.effects,3)>0 and not note.custominst then
					note.pitch=lerp(note.pitch,0,sqrt(note.progress))
					note.volume=lerp(note.volume,0,note.progress)
				end
				if count(note.effects,4)>0 then
					note.volume=lerp(0,note.volume,note.progress)
				end
				if count(note.effects,5)>0 then
					note.volume=lerp(note.volume,0,note.progress)
				end
			end
			
			chinfo.note=note
		else
			chinfo.note={
				volume=0,pitch=0,wave=0,effects={},customwave=false
			}
		end
		chinfo.cheffs=cheffs
		channels[chno]=chinfo
	end
end

function loop(s,l0,l1)
	if l0==0 and l1==0
	or l0>=l1
	and l1!=0 then
		--nothing
	elseif l0>=l1 and l1==0 then
		--len
		if s>l0 then
			s=-1
		end
	elseif l0<l1 and l1!=0 then
		--loop
		if s>l0 then
			s-=l0
			s%=l1-l0
			s+=l0
		end
	end
	return s
end

function get_note_at_sfx(sfxid,chno,no_instrs,ctick)
	local tick=ctick or stat(56)
	local sf=get_sfx_info(sfxid)
	cheffs.buzz=cheffs.buzz or sf.buzz
	cheffs.noiz=cheffs.noiz or sf.noiz
	cheffs.detune=max(cheffs.detune,sf.detune)
	cheffs.reverb=max(cheffs.reverb,sf.reverb)
	cheffs.dampen=max(cheffs.dampen,sf.dampen)
	local noteid=loop(tick\sf.speed,sf.l0,sf.l1)
	if(noteid<0 or noteid>31)return{pitch=0,volume=0,wave=0,effects={},customwave=false,progress=0}
	local pn=get_note_at_pos(sfxid,noteid)
	pn.progress=tick/sf.speed%1
	if pn.effects[1]>5 then
		--arp
		local spd=pn.effects[1]==6 and 4 or 8
		if(sf.speed<9)spd/=2
		local pos=get_note_arp_pos(noteid,spd)
		pn.pitch=get_note_at_pos(sfxid,pos).pitch
	end
	if pn.custominst then
		if no_instrs then
			pn.custominst=false
			return pn
		else
			del(pn.effects,1)
			local prev_note=get_note_at_pos(sfxid,noteid-1)
			if last_tickoff_pos[chno]!=noteid and (noteid==0 or (not prev_note.custominst) or prev_note.wave!=pn.wave or (count(pn.effects,1)==0 and prev_note.pitch!=pn.pitch) or count(pn.effects,3)>0) then
				--new note
				last_tickoff_pos[chno]=noteid
				tickoff[chno]=stat(56)
			end
			local inst_tick=stat(56)-tickoff[chno]
			local sn=get_note_at_sfx(pn.wave,chno,true,inst_tick)
			sn.volume=ceil(pn.volume*sn.volume/7)
			sn.pitch=mid(sn.pitch+pn.pitch-24,63)
			sn.custominst=true
			add(sn.effects,pn.effects[1])
			return sn
		end
	end
	return pn
end

function get_note_at_pos(sfxid,pos)
	if(pos<0 or pos>=32)return {pitch=0,volume=0,wave=0,effects={}}
	local word=%(0x3200+sfxid*68+pos*2)
	local custom=word<0
	local note={
		pitch=word&(2^6-1),
		wave=word>>6&(2^3-1),
		volume=word>>9&(2^3-1),
		effects={word>>12&(2^3-1)},
	}
	if custom then
		if @(0x3242+68*note.wave)&128<=0 then
			note.custominst=true
		else
			note.customwave=true
		end
	end
	return note
end

function get_sfx_info(sfxid)
	local sfxaddr=0x3200+sfxid*68
	local result={}
	local byte=@(sfxaddr+64)
	result.noiz=byte%2>0
	result.buzz=byte%4>0
	result.detune=byte\8%3
	result.reverb=byte\24%3
	result.dampen=byte\72%3
	result.speed=@(sfxaddr+65)
	result.l0=@(sfxaddr+66)
	result.l1=@(sfxaddr+67)
	return result
end

function get_wave_val(shape,pos,custom,scroll)
	local pos=(pos+t()*(scroll or scroll_speed))%1
	local ret=0
	if custom and @(0x3242+68*shape)&128>0 then
		ret=(@flr(0x3200+shape*68+pos*64)/128-1)%2-1
	else
		if shape==0 then
			pos=(pos+0.25)%1
			ret=(abs((pos+0.5)%1-0.5)-0.25)*-4
		elseif shape==1 then
			pos=(pos+0.4)%1
			if pos>0.8 then
				ret=pos/0.2-4
			else
				ret=1-pos/0.8
			end
			ret=(ret-0.5)*2
		elseif shape==2 then
			pos=(pos+0.5)%1
			ret=(0.5-pos)*2
		elseif shape==3 then
			ret=(flr(pos*2)-0.5)*2
		elseif shape==4 then
			ret=pos<0.35 and -1 or 1
		elseif shape==5 then
			pos=(pos+0.125)%1
			ret=pos<0.5 and get_wave_val(0,pos*2-0.25) or get_wave_val(0,pos*2-0.25)*0.65+0.35
		elseif shape==6 then
			ret=rnd(2)-1
		elseif shape==7 then
			--fake af
			ret=get_wave_val(0,pos)*(sin(t()*4)*0.1+0.9)
		end
	end
	return ret
end

function get_note_arp_pos(pos,spd)
	return (pos\4)*4+(stat(56)\spd)%4
end

function lerp(a,b,t)
	return a*(1-t)+b*t
end

function init_titles()
	local i=1
	local prev_item
	while i<=#titles do
		local item=titles[i]
		if type(item)!="number" then
			prev_item=item
		else
			del(titles,item)
			for _=1,item do
				add(titles,prev_item,i)
			end
		end
		i+=1
	end
end
-->8
function init_vis()
	mapoffset=0
	ks=2
	music(0)
end

function update_vis()
	if mapoffset<=15.25 then
		mapoffset+=0.25
	else
		mapoffset=0
	end
	if ks<=3-(.125*2) then
		ks+=0.125
	else
		ks=0
	end
end

function draw_vis()
local kx=53 --kris sprite
	local ky=69
	--bg
	map(0,0,mapoffset-16,mapoffset-16)
	--sprite
	palt(11,true)
	palt(0,false)
	spr(80+((ks\1)*4),kx,ky,4,3)
	spr(92,kx-8,ky+24,4,2)
	--title
	print("\^o0ff♪ violet tactics - toby fox",8,114,7)
	--rect(0,0,127,127,1)
	--[[
	line(64,0,64,128,8)
	line(0,64,128,64,8)
	--]]
	--print(ks)
end
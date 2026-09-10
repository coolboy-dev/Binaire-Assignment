function _init()
		
		-- background color
		bclr = 0
		
		-- game score
		score = 0
		
  ply = get_ply()
		
		game_over = false
		
		grid = get_grid()
		-- enemy init cells
		-- error -> fix enys initing
		-- in the same cell
		icells = {}
		for c in all(grid) do
		  if c.idx != 1 and
		     c.col == 9 or
		     c.col == 10 then
		     
		     add(icells,c)
		  end
		end
		
		-- enemy init timer
		itmr = 0
		irest = 1
		
		-- destroyed enemy cost 
		cost = 0
		
-- func init ends
end

function _update60()

		if not(game_over) then
				
				bclr = 0
				
				if ply != nil then
				  
				  if ply.health <= 0 then
				    ply.health = 0
				    game_over = true
				  end
				
						ply:do_acts()
				end
		  
		  -- eny init decrease every minute
				if irest > 0.25 then
				  if time() - itmr > 10 then
				  		irest -= 0.05
				  		itmr = time()
				  end
				else
						irest = 0.25
				end
		
		  -- init enemies by timer
		  if time() - eny_tmr > irest then
		    
		    local eny = get_eny(icells)
		    add(enemies,eny)
		    eny_tmr = time()
		  end
		
		  if #enemies > 0 then
						    
		    for e in all(enemies) do
		      -- enemy goes off screen
		      if e.x+e.sz < 0 then
		        -- damage ply when
		        -- eny goes off screen?
		      		ply.health -= 5
		        e.live = false
		        del(enemies,e)
		        -- bgrnd flash red
		        bclr = 8
		        sfx(02)
		      end
		      
		      if e.live then
		        e:do_acts()
		      end
		      
		      -- man eny/ply-ammo collisions
		      for s in all(ply.ammo) do
		        
		        if did_hit(s,e) then
		          
		          -- set score here?
		          if e.t == "red" then
		          		cost = 50		
		          elseif e.t == "green" then
		          		cost = 30
		          elseif e.t == "orange" then
		          		cost = 15
		          elseif e.t == "pink" then
		          		cost = 10
		          end
		          
		          if e.live then
		            score += cost
		          end
		          
		          e.live = false
		          del(enemies,e)
		          sfx(01)
		          
		      		end
		      		
		     end
		     -- man ply/eny collisions
		     if did_hit(ply,e) then
		       -- ply takes damage here
		       ply.health -=10
		       e.live = false
		       del(enemies,e)
		       -- bgrnd flash red
		       bclr = 8
		       sfx(02)
		     end
		     
		    end
		  end
		  
		-- game_over
		end
		
-- func update ends
end

function _draw()

  cls(bclr)
  
  -- draw grid
  for c in all(grid) do  
    rect(c.x,c.y,c.x+c.w,c.y+c.h,1)
  end
  
  print("score: "..tostr(score),70,8,7)
  
  
  --print("irest: "..tostr(irest),8,16,7)
  
  -- print("eny count: "..tostr(#enemies),8,16,7)
		-- draw ply
		if ply != nil then
		    
		  -- draw gui
		  print("health: "..tostr(ply.health),12,8,7)
  
  		if ply.health <= 0 then
  		  print("game over",48,56,8)
  		end
  
  		-- draw ply
		  spr(ply.id,ply.x,ply.y,2,2)
		  
		  -- draw ply ammo
		  if #ply.ammo > 0 then
		  		
		  		for s in all(ply.ammo) do
		  		  spr(s.id,s.x,s.y,2,2)
		  		end
		  		
		  end
		end

		-- draw enemies
		if #enemies > 0 then
		  
		  local feny = enemies[1]
		  -- print("is live = "..tostr(feny.live),8,8,7)
		  for e in all(enemies) do  
		    spr(e.id,e.x,e.y,2,2)
		  end
		end
  
-- func draw ends
end
-->8
-- player tools

function get_ply()

		local iply = {
				id=1,sz=16,
				x=0,y=56,
				vx=0,vy=0,
				ang=0,
				drx=0,dry=0,
				can_fire=false,
				ftmr=0,frest=0.25,
				health=100,
				ammo={}
		}
		
		function iply:do_acts()
				
				local sd_r = self.x + (self.sz + self.vx)
				local sd_l = self.x + self.vx
				local sd_b = self.y + (self.sz + self.vy)
				local sd_t = self.y + self.vy
				
				local spd=3
				
				-- stop at bounds
				if sd_l < 0 then
				  self.x = 0
				elseif sd_r > 130 then
				  self.x = 130 - self.sz
				end
				if sd_t < 0 then
				  self.y = 0
				elseif sd_b > 128 then
				  self.y = 128 - self.sz
				end
				
				if btn(1) and sd_r < 130 then
						self.drx=1
				elseif btn(0) and sd_l > 0 then
				  self.drx=-1
				else
						self.drx=0
				end
				if btn(3) and sd_b < 128then
						self.dry=1
				elseif btn(2) and sd_t > 0 then
						self.dry=-1
				else
						self.dry=0
				end
				
				self.ang = atan2(self.drx,self.dry)
				
				if abs(self.drx) + abs(self.dry) == 0 then
						self.vx = 0
						self.vy = 0
				else
						self.vx = cos(self.ang) * spd
						self.vy = sin(self.ang) * spd
				end
				
		  self.x += self.vx
		  self.y += self.vy
		  
		  -- manage amm
		  self:man_ammo()
		  
		-- func do_acts ends
		end
		
		function iply:man_ammo()
				
				if btn(4) then
						self.can_fire=true
				else
						self.can_fire=false
				end
				
				if time() - self.ftmr > self.frest and
				   self.can_fire then
						
						self:shoot()
						sfx(00)
						self.ftmr = time()
				end
				
				for s in all(self.ammo) do
				  if s.fired then
				  		s.x += s.vx
				  		s.y += s.vy
				  end
				end
		-- func man_ammo ends
		end
		
		function iply:shoot()
				local ofs = 4
				local ishot = {
				  id=33,sz=8,
				  x=self.x+ofs*2,y=self.y+ofs,
				  vx=3,vy=0,
				  ang=0,
				  fired=true
				}
				
				add(self.ammo,ishot)
				
		-- func shoot ends
		end
		
		return iply

-- fun get_ply ends
end
-->8
-- enemy tools

enemies = {}
eny_tmr = 0

function get_eny(igrid)
  
  -- red,green,orange,pink
  local eids = {3,5,7,9}
  local types = {"red","green","orange","pink"}
  local ridx = ceil(rnd()*#eids)
  
  -- rand cell id
  local rid = ceil(rnd() * #igrid)
  -- rand cell
  local rc = igrid[rid]
  
  local ieny = {
    id=eids[ridx],t=types[ridx],sz=16,
  		x=rc.x,y=rc.y,
  		--x=144,y=2+rnd()*(108),
  		vx=0,vy=0,
  		ang=0,spd_base=-flr(1+rnd()*2),
  		health=100, live=true
  }
  
  function ieny:do_acts()
    
    local centx = self.x + (self.sz * 0.5)
    if centx < 128 then
      self.live = true
    end
    
    self.vx = self.spd_base
    
    self.x += self.vx
    self.y += self.vy
    
  end
		
		return ieny
-- func get_eny ends
end

-->8
-- entity tools

function is_out(ent)

		local out = false

		local sdr = ent.x + ent.sz
		local sdl = ent.x
		local sdb = ent.y + ent.sz
		local sdt = ent.y
		
		if sdr < 0 or sdl > 128 or
		   sdb < 0 or sdt > 128 then
		
		  out = true
		end

		return out
		
-- func is_out ends
end

function did_hit(enta,entb)

		local hit = false
		
  local ar = enta.x + enta.sz
  local al = enta.x
  local ab = enta.y + enta.sz
  local at = enta.y
  
  local br = entb.x + entb.sz
  local bl = entb.x
  local bb = entb.y + entb.sz
  local bt = entb.y
  
  if ar > bl and al < br and
     ab > bt and at < bb then
     
     hit = true
  end
  
  return hit

-- func did_hit ends
end
-->8
-- grid tools

function get_grid()
		-- 16x16 px cells,
		
		local irows = 8
		-- extra cols for eny init
		local icols = 10
		
		local igrid = {}
  local stx = 0
  local sty = 0
  local str = 1
  local stc = 1
  local csz = 15.9
  local ccnt = irows * icols
  
  for cidx=1,ccnt do
    
    if cidx != 1 and
       cidx % icols == 1 then
      stx = 0
      sty += csz
      
      -- init rows/cols
      stc = 1
      str += 1
    end
    
    local icell = {
    		idx=cidx,
    		row=str,col=stc,
    		x=stx,y=sty,
    		w=csz,h=csz
    }
    
    add(igrid,icell)
    
    stx += csz
    stc += 1
  end
  
  return igrid
  
-- func get_grid ends
end
-->8
-- game tools

function get_score(etype)
		
		local amt = 0
		
		if etype == "red" then
				amt = 50
		elseif etype == "green" then
		  amt = 20
		elseif etype == "orange" then
		  amt = 10
		elseif etype == "pink" then
				amt = 30
		end
		
		return amt
-- func set_score ends
end
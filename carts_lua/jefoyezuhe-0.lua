-- flappy bird clone
-- sprite 1 = bird
-- sprite 2 = pipe cap (top/bottom)
-- sprite 3 = pipe pole (body)
-- sprite 4 = sky tile

sprite_bird = 1
sprite_cap  = 2
sprite_pole = 3
sprite_sky  = 4

gravity = 0.15
flap_vel = -2
pipe_gap = 32
pipe_w = 8
pipe_speed = 1
pipe_spacing = 48

function _init()
 reset_game()
 state = "ready"
end

function reset_game()
 bird = {x=24, y=60, vy=0}
 pipes = {}
 score = 0
 spawn_pipe(128+16)
 spawn_pipe(128+16+pipe_spacing)
 spawn_pipe(128+16+pipe_spacing*2)
end

function spawn_pipe(x)
 local margin = 16
 local gapy = margin + rnd(128 - pipe_gap - margin*2)
 add(pipes, {x=x, gapy=gapy, passed=false})
end

function flap()
 if state == "ready" then
  state = "playing"
 end
 if state == "playing" then
  bird.vy = flap_vel
  sfx(0) -- jump sound
 end
 if state == "gameover" then
  reset_game()
  state = "ready"
 end
end

function _update()
 if btnp(4) or btnp(5) then
  flap()
 end

 if state != "playing" then return end

 -- falling faster and faster the longer you don't flap
 bird.vy += gravity
 bird.y += bird.vy

 for p in all(pipes) do
  p.x -= pipe_speed
  if not p.passed and p.x + pipe_w < bird.x then
   p.passed = true
   score += 1
  end
 end

 if #pipes > 0 and pipes[1].x < -pipe_w then
  deli(pipes, 1)
  local last_x = pipes[#pipes].x
  spawn_pipe(last_x + pipe_spacing)
 end

 -- floor / ceiling
 if bird.y + 8 >= 128 or bird.y <= 0 then
  state = "gameover"
  return
 end

 -- pipe collision
 for p in all(pipes) do
  local bx1, by1, bx2, by2 = bird.x+1, bird.y+1, bird.x+7, bird.y+7
  local top_y2 = p.gapy
  local bot_y1 = p.gapy + pipe_gap
  if bx2 > p.x and bx1 < p.x + pipe_w then
   if by1 < top_y2 or by2 > bot_y1 then
    state = "gameover"
    return
   end
  end
 end
end

function draw_sky()
 for y=0,127,8 do
  for x=0,127,8 do
   spr(sprite_sky, x, y)
  end
 end
end

function draw_pipe(p)
 local top_h = p.gapy
 local bot_y = p.gapy + pipe_gap

 -- top pipe: pole tiles, then cap flipped at the gap
 for y=0,top_h-8-1,8 do
  spr(sprite_pole, p.x, y)
 end
 spr(sprite_cap, p.x, top_h-8, 1, 1, false, true) -- flip_y for top cap

 -- bottom pipe: cap first, then pole tiles down to the floor
 spr(sprite_cap, p.x, bot_y)
 for y=bot_y+8,127,8 do
  spr(sprite_pole, p.x, y)
 end
end

-- draws an 8x8 sprite rotated around its center.
-- angle is in pico8 "turns" (0 to 1, same units cos()/sin() use).
-- color 0 is treated as transparent, same as spr() default.
function draw_rotated_sprite(id, x, y, angle)
 local sheet_x = (id % 16) * 8
 local sheet_y = flr(id / 16) * 8
 local cx, cy = 3.5, 3.5 -- center of an 8x8 sprite
 local ca, sa = cos(angle), sin(angle)

 for dy=0,7 do
  for dx=0,7 do
   local rx = dx - cx
   local ry = dy - cy
   -- inverse-rotate the destination pixel to find the source pixel
   local srcx = flr(ca*rx + sa*ry + cx + 0.5)
   local srcy = flr(-sa*rx + ca*ry + cy + 0.5)
   if srcx >= 0 and srcx < 8 and srcy >= 0 and srcy < 8 then
    local c = sget(sheet_x + srcx, sheet_y + srcy)
    if c != 0 then
     pset(x + dx, y + dy, c)
    end
   end
  end
 end
end

function draw_bird()
 -- tilt up when flapping (negative vy), tilt down the longer it falls
 local tilt_deg = mid(-25, 90, bird.vy * 12)
 local angle = -tilt_deg / 360 -- convert degrees to pico8 "turns"
 draw_rotated_sprite(sprite_bird, bird.x, bird.y, angle)
end

-- bold, bouncing "flappy bird" title with "x to start" underneath
function draw_title_screen()
 local txt = "flappy bird"
 local bouncey = 44 + flr(sin(t()*0.6) * 3)
 local x = 64 - (#txt * 4) / 2

 -- outline pass (draws the same text offset in every direction)
 -- to fake a bold/bigger look using only the built-in font
 for ox=-1,1 do
  for oy=-1,1 do
   if not (ox == 0 and oy == 0) then
    print(txt, x + ox, bouncey + oy, 5)
   end
  end
 end
 print(txt, x, bouncey, 10) -- bright title on top of the outline

 print("x to start", 40, bouncey + 16, 7)
end

function _draw()
 cls()
 draw_sky()
 for p in all(pipes) do
  draw_pipe(p)
 end
 draw_bird()

 print(score, 60, 4, 7)

 if state == "ready" then
  draw_title_screen()
 elseif state == "gameover" then
  print("game over", 44, 56, 8)
  print("score: "..score, 40, 64, 7)
  print("press z or x to retry", 8, 72, 7)
 end
end
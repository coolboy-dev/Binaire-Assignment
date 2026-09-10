--| generic 3d mesh renderer |--
--| render mode |--
mode = "fill" -- "wire" or "fill"

--| screen / projection |--
scrn_width  = 128
scrn_height = 128
half_scrn   = scrn_width * 0.5
fov         = 0.3

--| lighting |--
light_type = "point" -- "directional" or "point"
shadow_y   = 0     -- world height of the ground plane
shadow_pat = 0xa5a5.1 -- 50% dither, colour b transparent
shadows = true
occlusion = true

-- light ramp: palette colours from darkest (1) to brightest (15)
Blue_lights  = split"0x15,0x51,0xc6,0xcc,0xcc,0xcc" -- Blue surface
Red_lights   = split"0x15,0x12,0x21,0x28,0xe8,0x8e"      -- Red surface
Green_lights = split"0x15,0x31,0x13,0xb3,0x3b,0xb"  -- Green surface
White_lights = split"0x15,0x51,0xd6,0x76,0x67"       -- White surface
-- 16-bit fillp patterns, one per ramp step, for simulating in-between shades
dither = split"0xffff.1,0xa5a5.1,0xa5a5.1,0x9696.1,0"

-->8
--| profiler |--
--[[ lightweight stat(1) section timer.
     Usage: 
      prof_begin()     -- top of _update (resets the timeline)
      prof_lap("name") -- after each section you want measured
      prof_draw(x,y)   -- in _draw, prints windowed averages
      
      numbers are % of a 30fps frame budget (100% = dropping to 30fps).
]]

-- prof = { sum = {}, names = {}, n = 0, last = 0, win = 30 }

-- function prof_begin()
--   prof.last = stat(1)
-- end

-- function prof_lap(name)
--   local now = stat(1)
--   if prof.sum[name] == nil then 
--     prof.sum[name] = 0 
--     add(prof.names, name)
--   end
--   prof.sum[name] += now - prof.last 
--   prof.last = now 
-- end

-- function prof_draw(x, y)
--   prof.n += 1
--   for name in all(prof.names) do 
--     local avg = prof.sum[name] / prof.n 
--     print(name .. ":" .. (flr(avg * 1000 + .5) / 10) .. "%", x, y, 0)
--     y += 6 
--   end
--   -- total frame cost so far (incl. anything not lapped)
--   print("frame:" .. (flr(stat(1) * 1000 + .5) / 10) .. "%", x, y, 0)
--   -- reset the averaging window 
--   if prof.n >= prof.win then 
--     prof.sum, prof.name, prof.n = {}, {}, 0 
--   end
-- end

-->8
--| Math |--
-- Helpers to convert pico8 turns to radians
local function cosrad(r) return cos(r/6.283) end
local function sinrad(r) return sin(r/6.283) end
DegToRad = 0.017453

-- perspective scale factor: screen units per view unit at depth 1
function compute_k1(fov)
    local half_fov = fov/2
    local t = atan2(cos(half_fov),sin(half_fov))*6.283
    return half_scrn / t
end

--[[--| matrix math library |--
   flat 16-entry row-major affine transforms:
   [ 1  2  3  4 ]
   [ 5  6  7  8 ]
   [ 9 10 11 12 ]
   [ 0  0  0  1 ] 
]]
-- Faster matrix multiplication that assumes standard affine matrices
function fast_mat_mul(a, b) 
  return {
    a[1]*b[1] + a[2]*b[5] + a[3]*b[9],   a[1]*b[2] + a[2]*b[6] + a[3]*b[10],  a[1]*b[3] + a[2]*b[7] + a[3]*b[11],   a[1]*b[4] + a[2]*b[8] + a[3]*b[12] + a[4],
    a[5]*b[1] + a[6]*b[5] + a[7]*b[9],   a[5]*b[2] + a[6]*b[6] + a[7]*b[10],  a[5]*b[3] + a[6]*b[7] + a[7]*b[11],   a[5]*b[4] + a[6]*b[8] + a[7]*b[12] + a[8],
    a[9]*b[1] + a[10]*b[5] + a[11]*b[9], a[9]*b[2] + a[10]*b[6] + a[11]*b[10], a[9]*b[3] + a[10]*b[7] + a[11]*b[11],a[9]*b[4] + a[10]*b[8] + a[11]*b[12] + a[12],
    0, 0, 0, 1
  }
end

function mat_blank()
  return split"1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"
end

function update_model_matrix(m, pos, rot)
  local cx, sx = cosrad(rot[1]), sinrad(rot[1])
  local cy, sy = cosrad(rot[2]), sinrad(rot[2])
  local cz, sz = cosrad(rot[3]), sinrad(rot[3])

  -- Pre-compute shared terms to save CPU 
  local sxsy = sx * sy 
  local sxcy = sx * cy 

  m[1], m[2], m[3] = cz*cy - sz*sxsy, -sz*cx, cz*sy + sz*sxcy
  m[5], m[6], m[7] = sz*cy + cz*sxsy,  cz*cx, sz*sy - cz*sxcy
  m[9], m[10],m[11]= -cx*sy,           sx,    cx*cy

  m[4], m[8], m[12] = pos[1], pos[2], pos[3]
end

function update_view_matrix(m, cpos, crot)
  local cx, sx = cosrad(-crot[1]), sinrad(-crot[1])
  local cy, sy = cosrad(-crot[2]), sinrad(-crot[2])
  local cz, sz = cosrad(-crot[3]), sinrad(-crot[3])

  local sxsy = sx * sy
  local sxcy = sx * cy

  m[1], m[2], m[3] = cz*cy - sz*sxsy, -sz*cx, cz*sy + sz*sxcy
  m[5], m[6], m[7] = sz*cy + cz*sxsy,  cz*cx, sz*sy - cz*sxcy
  m[9], m[10],m[11]= -cx*sy,           sx,    cx*cy

  local tx, ty, tz = -cpos[1], -cpos[2], -cpos[3]
  m[4] = m[1]*tx + m[2]*ty + m[3]*tz
  m[8] = m[5]*tx + m[6]*ty + m[7]*tz
  m[12]= m[9]*tx + m[10]*ty + m[11]*tz
end

function qsort(a,c,l,r)
    c,l,r=c or function(a,b) return a<b end,l or 1,r or #a
    if l<r then
        if c(a[r],a[l]) then
            a[l],a[r]=a[r],a[l]
        end
        local lp,k,rp,p,q=l+1,l+1,r-1,a[l],a[r]
        while k<=rp do
            local swaplp=c(a[k],p)
            if swaplp or c(a[k],q) then
            else
                while c(q,a[rp]) and k<rp do
                    rp-=1
                end
                a[k],a[rp],swaplp=a[rp],a[k],c(a[rp],p)
                rp-=1
            end
            if swaplp then
                a[k],a[lp]=a[lp],a[k]
                lp+=1
            end
            k+=1
        end
        lp-=1
        rp+=1
        a[l],a[lp]=a[lp],a[l]
        a[r],a[rp]=a[rp],a[r]
        qsort(a,c,l,lp-1       )
        qsort(a,c,  lp+1,rp-1  )
        qsort(a,c,       rp+1,r)
    end
end

-->8
--| 3D MODEL DEFINITION |--
-- Winding order matters! (Clockwise/Counter-clockwise for backface culling)

function str_to_nested_table(s)
  local t = {}
  for sub in all(split(s,"\n")) do
    add(t, split(sub))
  end
  return t
end

-- Torus Diagram:
--[[
Slice view of torus (R = major radius, R2 = minor radius)
 (Theta steps) = 12          R2
       o---o       |       o | o       
    o    |    o    |    o    |    o     
   o     ,_____o___|___o__R__,     o    
   o           o   |   o           o   
    o         o    |    o         o     
       o   o       |       o   o    
                   |     
--------------------------------------------
Top view of torus:
              . - o - .    
         , '      |      ' ,    
       o          |          o---------+ (Phi steps) = 8
     '   \        |        /   '       |
    '       \    ,o,    /        '     |
   |          o'  |  'o           |    | 
  |          /  \ | /  \     R     |   |
  o---------o-----+-----o----+-----o---+ 
  |          \  / | \  /           |
   |          o,  |  ,o           |
    '       /    'o'    \        ' 
     \   /        |        \    /
       o          |          o'
         ' ,      |      , '      
              ' - o - '            
]]
-- theta = rings around the tube, phi = points per ring.
-- verts come out ring-major, so vert (i,j) is at i*phi_steps + j + 1.
function gen_torus(theta_steps, phi_steps, r, r2, scale)
  local verts, faces = {}, {}
  local pi2 = 6.283
  for i=0,theta_steps-1 do 
    local ti = i * pi2 / theta_steps 
    local ct, st = cosrad(ti), sinrad(ti)
    local ring = (r2 - r * ct) * scale 
    local z = r * st * scale

    for j=0,phi_steps-1 do 
      local p = j * pi2 / phi_steps
      local x = ring * cosrad(p)
      local y = ring * sinrad(p)
      add(verts, {x, y, z})
    end
  end

  for i=0, theta_steps-1 do 
    for j=0, phi_steps-1 do 
      local ni, nj = (i+1) % theta_steps, (j+1) % phi_steps

      add(faces, {
        i  * phi_steps + j  + 1, 
        ni * phi_steps + j  + 1, 
        ni * phi_steps + nj + 1, 
        i  * phi_steps + nj + 1
      })
    end
  end

  return verts, faces
end

function gen_icosphere(subdivisions, scale)
  -- Base math for a perfect radius 1 sphere 
  local t = (1.0 + sqrt(5.0)) * 0.5
  local len = sqrt(1 + t*t)
  local one = 1.0 / len 
  t /= len 
  local verts = {
    {-one,  t,  0}, { one,  t,  0}, {-one, -t,  0}, { one, -t,  0},
    {0, -one,  t}, {0, one,  t}, {0, -one, -t}, {0, one, -t},
    { t, 0, -one}, { t, 0, one}, {-t, 0, -one}, {-t, 0, one}
  }
  local faces = str_to_nested_table("1,6,2\n1,12,6\n1,11,12\n1,8,11\n1,2,8\n2,6,10\n6,12,5\n12,11,3\n11,8,7\n8,2,9\n10,6,5\n5,12,3\n3,11,7\n7,8,9\n9,2,10\n4,10,5\n4,5,3\n4,3,7\n4,7,9\n4,9,10")
  local cache = {} 
  -- Helper fn to find or create midpoint of an edge 
  local function get_midpoint(i1, i2)
    local small = min(i1, i2)
    local big = max(i1, i2)
    local key = small .. "_" .. big 

    -- If we already found this edge's midpoint, return its index 
    if cache[key] then return cache[key] end

    local v1, v2 = verts[i1], verts[i2]
    local mx = (v1[1] + v2[1]) * 0.5
    local my = (v1[2] + v2[2]) * 0.5 
    local mz = (v1[3] + v2[3]) * 0.5

    -- Normalize it (push it out to the sphere surface)
    local l = sqrt(mx*mx + my*my + mz*mz)
    verts[#verts+1] = {mx/l, my/l, mz/l}

    local new_idx = #verts
    cache[key] = new_idx 
    return new_idx
  end

  -- Subdivide each face 
  if subdivisions > 1 then
    for i=2, subdivisions do 
      local new_faces = {}
      cache = {} -- clear cache per level 

      for f=1, #faces do 
        local face = faces[f]
        local a, b, c = face[1], face[2], face[3]
        local ab = get_midpoint(a, b)
        local bc = get_midpoint(b, c)
        local ca = get_midpoint(c, a)

        -- Create 4 new faces from the original triangle
        add(new_faces, {a, ab, ca})
        add(new_faces, {b, bc, ab})
        add(new_faces, {c, ca, bc})
        add(new_faces, {ab, bc, ca})
      end
      faces = new_faces 
    end
  end

  -- Apply the final cache 
  for i=1, #verts do 
    verts[i][1] *= scale 
    verts[i][2] *= scale 
    verts[i][3] *= scale 
  end

  return verts, faces
end

function gen_cube(w, h, d, scale, subdivisions)
  local w, h, d, scale = w or 5, h or 5, d or 5, scale or 1
  local verts = {
    {-w,-h,-d}, { w,-h,-d}, { w, h,-d}, {-w, h,-d}, -- front 4
    {-w,-h, d}, { w,-h, d}, { w, h, d}, {-w, h, d}  -- back 4
  }
  local faces = str_to_nested_table("4,3,2,1\n5,6,7,8\n8,7,3,4\n1,2,6,5\n2,3,7,6\n5,8,4,1")
  local cache = {}

  local function get_midpoint(i1, i2)
    local key = min(i1, i2).."_"..max(i1, i2) 
    if cache[key] then return cache[key] end
    local v1, v2 = verts[i1], verts[i2]
    add(verts, {(v1[1]+v2[1])*0.5, (v1[2]+v2[2])*0.5, (v1[3]+v2[3])*0.5})
    cache[key] = #verts 
    return #verts
  end

  for s=1, subdivisions or 0 do 
    local new_faces = {}
    cache = {} 
    for face in all(faces) do 
      local a,b,c,e = face[1],face[2],face[3],face[4]
      local ab,bc,ce,ea = get_midpoint(a,b), get_midpoint(b,c), get_midpoint(c,e), get_midpoint(e,a)
      local v1,v2,v3,v4 = verts[a],verts[b],verts[c],verts[e]
      add(verts, {(v1[1]+v2[1]+v3[1]+v4[1])*0.25, 
                  (v1[2]+v2[2]+v3[2]+v4[2])*0.25, 
                  (v1[3]+v2[3]+v3[3]+v4[3])*0.25})
      local center = #verts
      add(new_faces, {a, ab, center, ea})
      add(new_faces, {ab, b, bc, center})
      add(new_faces, {center, bc, c, ce})
      add(new_faces, {ea, center, ce, e})
    end
    faces = new_faces 
  end
  
  for v in all(verts) do 
    v[1] *= scale
    v[2] *= scale 
    v[3] *= scale  
  end
  
  return verts, faces
end

function gen_plane(subdivisions, w, d, scale)
  local verts = str_to_nested_table("-1,0,1\n1,0,1\n1,0,-1\n-1,0,-1")
  local faces = str_to_nested_table("1,2,3\n1,3,4") 
  local cache = {} 

  local function get_midpoint(i1, i2)
    local small, big = min(i1, i2), max(i1, i2)
    local key = small.."_"..big 

    if cache[key] then return cache[key] end

    local v1, v2 = verts[i1], verts[i2]
    local mx, my, mz = (v1[1]+v2[1])*0.5, (v1[2]+v2[2])*0.5, (v1[3]+v2[3])*0.5

    add(verts, {mx, my, mz})

    local new_idx = #verts
    cache[key] = new_idx 
    return new_idx
  end

  if subdivisions > 1 then
    for i=1, subdivisions do 
      local new_faces = {}
      cache = {} 

      for face in all(faces) do 
        local a, b, c = face[1], face[2], face[3]
        local ab, bc, ca = get_midpoint(a, b), get_midpoint(b, c), get_midpoint(c, a)
        add(new_faces, {a, ab, ca})
        add(new_faces, {b, bc, ab})
        add(new_faces, {c, ca, bc})
        add(new_faces, {ab, bc, ca})
      end
      faces = new_faces 
    end
  end

  for v in all(verts) do 
    v[1] *= (w * scale) 
    v[2] *= scale 
    v[3] *= (d * scale) 
  end

  return verts, faces
end

-->8
--| scene setup and main loop |--
function mesh(v,f) return {v,f} end
scene = {}
function add_scene_object(name, m, pos, rot, casts, colour, layer)
  local verts, faces = m[1], m[2]
  local obj = {
    name = name,
    verts = verts,
    faces = faces,
    pos = pos,
    rot = rot,
    layer = layer or 0,
    model_matrix = mat_blank(),
    proj_verts = {},
    radius = 0,
    rr = 0,
    soft = 0,
    vcx = 0,
    vcy = 0,
    vcz = 0,
    col = colour or "White"
  }

  for i=1,#verts do
    obj.proj_verts[i] = {0,0,0,0,0,0}
  end

  if casts then
    obj.shad_verts = {}
    for i=1,#verts do obj.shad_verts[i] = {0,0,0,0,0,0} end

    -- Bounding-sphere radius for obj-on-obj occlusion
    local r2=0
    for v in all(verts) do 
      local d2=v[1]*v[1]+v[2]*v[2]+v[3]*v[3]
      if d2>r2 then r2=d2 end 
    end
    obj.radius=sqrt(r2)
    obj.rr=r2*1.96
    obj.soft=1/(r2*1.96-r2)
  end

  add(scene, obj)
  return #scene
end

function add_rotate_obj(id,x,y,z) 
  if(x) scene[id].rot[1] += x
  if(y) scene[id].rot[2] += y 
  if(z) scene[id].rot[3] += z
end

function set_translate_obj(id,x,y,z) 
  if(x) scene[id].pos[1] = x
  if(y) scene[id].pos[2] = y 
  if(z) scene[id].pos[3] = z
end

--| camera |--
-- rot chases t_rot so mouse movement eases instead of snapping
cam = {
  pos = split"0, 50, 20",
  rot = split"0, 0, 0",
  vel = split"0, 0, 0",
  t_rot = split"0, 0, 0" -- target rotation for the camera to chase
}

sphere1_id, torus1_id, cube1_id, light1_id = 0, 0, 0, 0

function _init()
  poke(0x5f2d, 5)
  k1 = compute_k1(fov)
  mat_view = mat_blank()

  local size,oz = 100,-40
  local wall  = mesh(gen_plane(1,1,1,size))
  local floor = mesh(gen_plane(2,1,1,size))

  sphere1_id = add_scene_object("sphere_1", mesh(gen_icosphere(2, 15)),      {  0,70,oz}, {0,0,0}, true, "green")
  torus1_id  = add_scene_object("torus_1",  mesh(gen_torus(8, 8, .6, 1, 15)),{-30,30,oz}, {0,0,0}, true, "red")
  cube1_id   = add_scene_object("cube_1",   mesh(gen_cube(1,1,1,10,0)),       { 30,30,oz}, {0,0,0}, true, "blue")

  add_scene_object("LeftWall",  wall,  {-size,size,oz},  {0,0,90*DegToRad},   false, "blue")
  add_scene_object("RightWall", wall,  {size,size,oz},   {0,0,-90*DegToRad},  false, "green")
  add_scene_object("BackWall",  wall,  {0,size,oz-size}, {-90*DegToRad,0,0},  false)
  add_scene_object("TopWall",   wall,  {0,size*2,oz},    {-180*DegToRad,0,0}, false)
  --add_scene_object("BotWall",   floor, {0,0,oz},         {0,0,0},             false)
  light1_id = add_scene_object("light_1", mesh(gen_cube(5,2,5,1,0)), {0,(size*2)-30,oz}, {0,0,0})
end

function _update()
  --prof_begin()

  --| mouse look |--
  -- read the raw distance the mouse moved
  local dx,dy = stat(38),stat(39) 
  local sensitivity,smooth = 0.0015,0.8

  cam.t_rot[2] += dx * sensitivity -- yaw
  cam.t_rot[1] += dy * sensitivity -- pitch

  -- Clamp pitch: prevent the camera from do a backflip
  cam.rot[1] = mid(-1.0, cam.rot[1], 1.0) 

  -- Lerp actual rotation towards target rotation for smooth camera movement
  cam.rot[1] += (cam.t_rot[1] - cam.rot[1]) * smooth
  cam.rot[2] += (cam.t_rot[2] - cam.rot[2]) * smooth

  -- Cam Controls
  local accel,friction = .7, 0.82
  local yaw,pitch = cam.rot[2], cam.rot[1]
  local sy,cy = sinrad(yaw),cosrad(yaw)
  local sp,cp = sinrad(pitch),cosrad(pitch)
  local fx,fy,fz = -sy * cp,sp,-cy * cp
  local rx,rz = cy,-sy

  -- Left/Right moves(strafe) along the Right vector
  if btn(0) then -- left
    cam.vel[1] -= rx * accel
    cam.vel[3] -= rz * accel
  end
  if btn(1) then -- right
    cam.vel[1] += rx * accel
    cam.vel[3] += rz * accel
  end
  -- Forward/Back moves along the Forward vector
  if btn(2) then -- up
    cam.vel[1] += fx * accel
    cam.vel[2] += fy * accel
    cam.vel[3] += fz * accel
  end
  if btn(3) then -- down
    cam.vel[1] -= fx * accel
    cam.vel[2] -= fy * accel
    cam.vel[3] -= fz * accel
  end

  cam.vel[1] *= friction 
  cam.vel[2] *= friction 
  cam.vel[3] *= friction
  
  cam.pos[1] += cam.vel[1]
  cam.pos[2] += cam.vel[2]
  cam.pos[3] += cam.vel[3]

  -- Calc global view matrix once per frame 
  update_view_matrix(mat_view, cam.pos, cam.rot)

  -- TRANSFORM THE LIGHT
  local lp = scene[light1_id].pos
  local lx, ly, lz = lp[1], lp[2], lp[3]

  if light_type == "directional" then
    light_view_x = lx*mat_view[1] + ly*mat_view[2] + lz*mat_view[3]
    light_view_y = lx*mat_view[5] + ly*mat_view[6] + lz*mat_view[7]
    light_view_z = lx*mat_view[9] + ly*mat_view[10]+ lz*mat_view[11]
    -- Normalize the light ONCE per frame
    local l_len = (light_view_x*light_view_x + light_view_y*light_view_y + light_view_z*light_view_z)^.5
    if l_len > 0 then
      light_view_x /= l_len
      light_view_y /= l_len
      light_view_z /= l_len
    end
  elseif light_type == "point" then
    -- POINT LIGHT (Position)
    -- We apply both Camera Rotation AND Camera Translation
    ly -= 3.89 -- lower the light a bit below light box
    light_view_x = lx*mat_view[1] + ly*mat_view[2] + lz*mat_view[3] + mat_view[4]
    light_view_y = lx*mat_view[5] + ly*mat_view[6] + lz*mat_view[7] + mat_view[8]
    light_view_z = lx*mat_view[9] + ly*mat_view[10]+ lz*mat_view[11]+ mat_view[12]
  end
  -- Ground plane (world y = shadow_y, normal +y) in view space 
  gnx, gny, gnz = mat_view[2], mat_view[6], mat_view[10]
  gd = gnx * (mat_view[2]*shadow_y + mat_view[4]) 
     + gny * (mat_view[6]*shadow_y + mat_view[8])
     + gnz * (mat_view[10]*shadow_y + mat_view[12])

  --| animation |--
  set_translate_obj(sphere1_id,20*cos(time()*.3),nil,-40+20*sin(time()*.3))
  add_rotate_obj(sphere1_id,nil,.03,nil)
  add_rotate_obj(torus1_id,.022,.015,.015)
  --add_rotate_obj(cube1_id,.02,.01,.01)

  --prof_lap("input")
  --| transform every object |--
  -- casters is rebuilt each frame and read by shade_tri's occlusion loop
  casters={}
  for obj in all(scene) do
    update_model_matrix(obj.model_matrix, obj.pos, obj.rot)
    local m_modelview = fast_mat_mul(mat_view, obj.model_matrix)
    compute_wireframe(obj, m_modelview)
    if obj.shad_verts then 
      -- Model origin = mesh center, so cols 4/8/12 are the view-space center
      obj.vcx,obj.vcy,obj.vcz = m_modelview[4],m_modelview[8],m_modelview[12]
      add(casters, obj)
      if shadows then compute_shadow(obj) end
    end
  end
  --prof_lap("xform")

  local key = stat(31)
  if key=="m" then mode = mode=="fill" and "wire" or "fill" end
  if key=="x" then shadows = not shadows end
  if key=="c" then occlusion = not occlusion end
end

-->8
--[[--| Transform |--
  both passes write into pre-allocated proj_vert / shad_vert slots:
  [1][2][3] view-space x, y, z
  [4]       depth (-z). 0 in shad_vert means "no shadow here"
  [5][6]    screen x, y

  The perspective divide is done by hand rather than through 
  projection matrix, so only k1 and -k1 are ever needed.
]]

-- MODEL space -> VIEW space -> SCREEN, for every vert of one object
function compute_wireframe(obj, m_modelview)
  local hw, hh = half_scrn, half_scrn
  -- projection only ever needs k1 / -k1 (perspective divide is done by hand)
  local p1, p6 = k1, -k1
  
  -- CACHE MATRIX VALUES LOCALLY
  local m1, m2, m3, m4 = m_modelview[1], m_modelview[2], m_modelview[3], m_modelview[4]
  local m5, m6, m7, m8 = m_modelview[5], m_modelview[6], m_modelview[7], m_modelview[8]
  local m9, m10, m11, m12 = m_modelview[9], m_modelview[10], m_modelview[11], m_modelview[12]
  
  for i=1,#obj.verts do 
      local vec = obj.verts[i]
      local pt_out = obj.proj_verts[i]
      
      local vx, vy, vz = vec[1], vec[2], vec[3]
      
      -- Use the fast local variables!
      local wx = vx*m1 + vy*m2 + vz*m3 + m4
      local wy = vx*m5 + vy*m6 + vz*m7 + m8
      local wz = vx*m9 + vy*m10+ vz*m11+ m12
      
      local view_z = -wz
      
      -- Store the TRUE depth so _draw knows if it's behind us
      pt_out[4] = view_z 
      
      -- Clamp a temporary variable just to prevent divide-by-zero
      local safe_z = view_z
      if safe_z < 1 then safe_z = 1 end 
      
      pt_out[1], pt_out[2], pt_out[3] = wx, wy, wz
      pt_out[5] = hw + (wx * p1) / safe_z
      pt_out[6] = hh + (wy * p6) / safe_z
  end
end

function compute_shadow(obj)
  local lx, ly, lz = light_view_x, light_view_y, light_view_z
  local pt = light_type == "point"
  local tmax = pt and 8 or 200

  for i=1,#obj.verts do 
    local v, s = obj.proj_verts[i], obj.shad_verts[i]
    local vx, vy, vz = v[1], v[2], v[3] 

    local dx, dy, dz 
    if pt then dx, dy, dz = vx-lx, vy-ly, vz-lz
    else dx, dy, dz = -lx, -ly, -lz end 

    s[4] = 0
    local nd = gnx * dx + gny * dy + gnz * dz 
    if nd < -.05 then 
      local t = (gd - (gnx * vx + gny * vy + gnz * vz)) / nd 
      if t > 0 then
        if t > tmax then t = tmax end
        local sx, sy, sz = vx + t*dx, vy + t*dy, vz + t*dz 

        local d = -sz
        if d == 0 then d = .001 end 
        s[1], s[2], s[3], s[4] = sx, sy, sz, d 

        local sd = d 
        if sd < 1 then sd = 1 end
        s[5] = half_scrn + (sx * k1) / sd 
        s[6] = half_scrn - (sy * k1) / sd 
      end
    end
  end
end

-->8
--[[--| Build |--
  Turns projected verts into the flat poly list _draw sorts and 
  rasterises. per face:
    normal -> shadow test -> backface cull -> clip -> emit 
  
  sort keys are view-space dpeth with two offsets baked in:
    + obj.layer  manual bias per object 
    - 1          shadows, so they always render behind the caster
]]

-- near-plane clip. returns 0, 1 or 2 triangles.
function clip_tri(p1, p2, p3)
  local near = 1.0 
  local pts = {p1, p2, p3}
  local new_pts = {}

  local function intersect(a, b)
    -- Calculate t safely to prevent overflow
    local dz = b[4] - a[4]
    if abs(dz) < 0.0001 then dz = 0.0001 end 
    local t = mid(0, (near - a[4]) / dz, 1)
    
    -- Interpolate View-Space coordinates
    local nx = a[1] + t * (b[1] - a[1])
    local ny = a[2] + t * (b[2] - a[2])
    local nz = a[3] + t * (b[3] - a[3])

    -- Project to Screen Space (near is 1, so we just use k1)
    -- Using the global k1 and 64 for center
    local sx = 64 + (nx * k1)
    local sy = 64 + (ny * -k1) 

    return {nx, ny, nz, near, sx, sy}
  end

  for i=1,3 do
    local p_cur = pts[i]
    local p_next = pts[(i%3)+1]
    
    local cur_in = p_cur[4] >= near
    local next_in = p_next[4] >= near
    
    if cur_in then
      if next_in then
        add(new_pts, p_next)
      else
        add(new_pts, intersect(p_cur, p_next))
      end
    elseif next_in then
      add(new_pts, intersect(p_cur, p_next))
      add(new_pts, p_next)
    end
  end

  local res = {}
  if #new_pts == 3 then
    add(res, {new_pts[1], new_pts[2], new_pts[3]})
  elseif #new_pts == 4 then
    -- Fan Triangulation: Stable winding for backface culling
    add(res, {new_pts[1], new_pts[2], new_pts[3]})
    add(res, {new_pts[1], new_pts[3], new_pts[4]})
  end
  return res
end

-- Fast path: fully in front of the near plane, so screen-bounds reject
-- and emit. Otherwise clip first and re-enter per resulting triangle.
function add_tri(polys, a, b, c, col, z, dither_p)
  local ia, ib, ic = a[4]>=1, b[4]>=1, c[4]>=1
  if ia and ib and ic then
    -- early cull for far away tris
    if max(a[5], max(b[5], c[5])) < 0   then return end
    if min(a[5], min(b[5], c[5])) > 127 then return end
    if max(a[6], max(b[6], c[6])) < 0   then return end
    if min(a[6], min(b[6], c[6])) > 127 then return end
    add(polys, {a,b,c,col,z,dither_p})
  elseif ia or ib or ic then
    for ct in all(clip_tri(a,b,c)) do
      add_tri(polys, ct[1],ct[2],ct[3],col,z,dither_p)
    end
  end
end

function build_scene_polys()
  local all_polys = {} 
  local is_pt = light_type == "point"
  
  for obj in all(scene) do
    local pv, sv, layer = obj.proj_verts, shadows and obj.shad_verts, obj.layer
    for i = 1, #obj.faces do 
      local f = obj.faces[i]
      local f1, f2, f3, f4 = f[1], f[2], f[3], f[4]
      local p1, p2, p3 = pv[f1], pv[f2], pv[f3]
      
      -- EARLY CULLING: Calculate un-normalized View-Space Normal
      local d = 24 -- arbitrary value to prevent overflow in normal calculation (only care about the sign, not the actual length)
      local ux, uy, uz = (p2[1]-p1[1])/d, (p2[2]-p1[2])/d, (p2[3]-p1[3])/d
      local vx, vy, vz = (p3[1]-p1[1])/d, (p3[2]-p1[2])/d, (p3[3]-p1[3])/d
      local nx = uy*vz - uz*vy
      local ny = uz*vx - ux*vz
      local nz = ux*vy - uy*vx

      -- SHADOW geometry(before the camera cull: back-facing polys still cast)
      if sv then 
        local ldx, ldy, ldz = light_view_x, light_view_y, light_view_z 
        if is_pt then 
          ldx, ldy, ldz = ldx - p1[1], ldy - p1[2], ldz - p1[3]
        end

        if nx * ldx + ny * ldy + nz * ldz > 0 then 
          local s1, s2, s3 = sv[f1], sv[f2], sv[f3]
          local s4 = f4 and sv[f4]
          if s1[4] ~= 0 and s2[4] ~= 0 and s3[4] ~= 0 and (not s4 or s4[4] ~= 0) then
            local sz = max(s1[4], max(s2[4], s3[4]))
            if sz < 1 then sz = 1 end

            if s4 then sz = max(sz, s4[4]) end 
            sz -= 1

            add_tri(all_polys, s1, s2, s3, 0x10, sz, shadow_pat)
            if s4 then add_tri(all_polys, s1, s3, s4, 0x10, sz, shadow_pat) end
          end
        end
      end
      
      -- CAMERA-FACING geometry: Backface culling
      if (nx*p1[1] + ny*p1[2] + nz*p1[3]) < 0 then 
        -- ONLY calculate color/dither if the face is visible
        local p4 = f4 and pv[f4]
        local face_col, dither_p = shade_tri(p1, p2, p3, 1, nx, ny, nz, obj)

        -- CALCULATE DEPTH BEFORE CLIPPING
        -- We use the Maximum Z (furthest point) of the original face.
        -- This keeps all clipped pieces grouped together in the sort
        local face_z = max(p1[4], max(p2[4], p3[4]))
        if p4 then face_z = max(face_z, p4[4]) end
        face_z += layer -- add layer offset to depth for sorting

        add_tri(all_polys, p1, p2, p3, face_col, face_z, dither_p)
        if p4 then add_tri(all_polys, p1, p3, p4, face_col, face_z, dither_p) end 
      end
    end
  end 
  return all_polys
end

-->8
--[[--| Shading |--
  Flat per-face lambert in view space. Intensity 0..1 picks both a 
  colour from the lights ramp and fillp pattern from dither, which 
  together fake more shades than the 5-entry ramp has.
]]

function shade_tri(p1,p2,p3,base_col,nx,ny,nz,self_obj)
  local n_len=sqrt(nx*nx+ny*ny+nz*nz)
  if n_len>0 then nx/=n_len ny/=n_len nz/=n_len end

  -- face centroid (view space)
  local cx=(p1[1]+p2[1]+p3[1])/3
  local cy=(p1[2]+p2[2]+p3[2])/3
  local cz=(p1[3]+p2[3]+p3[3])/3

  local lx,ly,lz=light_view_x,light_view_y,light_view_z
  local dlx,dly,dlz,tmax,intensity

  if light_type=="directional" then
    intensity=max(0,nx*lx+ny*ly+nz*lz)
    dlx,dly,dlz,tmax=lx,ly,lz,200        -- light at infinity: march far
  else
    lx,ly,lz=lx-cx,ly-cy,lz-cz           -- raw L = light - centroid
    dlx,dly,dlz,tmax=lx,ly,lz,1          -- light sits at t=1 along this vector
    local dist=sqrt(lx*lx+ly*ly+lz*lz)
    if dist>0 then lx/=dist ly/=dist lz/=dist end
    intensity=max(0,nx*lx+ny*ly+nz*lz)
  end

  -- object-on-object occlusion
  if occlusion and intensity>0 then
    local inv=1/(dlx*dlx+dly*dly+dlz*dlz)  -- ray length, once per face
    local sh=0
    for i=1,#casters do
      local c=casters[i]
      if c~=self_obj then
        local mx,my,mz=c.vcx-cx,c.vcy-cy,c.vcz-cz
        local t=(mx*dlx+my*dly+mz*dlz)*inv
        -- broad phase: caster must sit between face and light
        if t>0 and t<tmax then
          local px,py,pz=cx+t*dlx-c.vcx,cy+t*dly-c.vcy,cz+t*dlz-c.vcz
          local d2=px*px+py*py+pz*pz
          if d2<c.rr then                  -- only now do the divide
            local o=(c.rr-d2)*c.soft
            if o>sh then sh=o end
          end
        end
      end
    end
    if sh>1 then sh=1 end
    intensity*=1-sh
  end

  local lights = White_lights
  if self_obj.col == "red" then 
    lights = Red_lights
  elseif self_obj.col == "green" then 
    lights = Green_lights
  elseif self_obj.col == "blue" then 
    lights = Blue_lights 
  end

  local li=min(base_col+flr(intensity*#lights),#lights)
  return lights[li],dither[flr(intensity*#lights)+1]
end

-->8
--[[--| Raster |--
  Painter's algorithm: sort back to front on the poly's stored depth
  and overdraw. no z-buffer, so the sort key is wha tkeeps shadows 
  under geometry and layer bias is what breaks ties.
]]

function _draw()
  cls(2) 
  local polys = build_scene_polys()

  --prof_lap("build")

  qsort(polys,function(a,b) return a[5]>b[5] end)

  --prof_lap("sort")

  for q in all(polys) do
    -- Grab pre-calculated col and dither pattern
    local p1,p2,p3,col,dither_p = q[1],q[2],q[3],q[4],q[6]
    
    if mode=="wire" then
      fill_tri(p1[5],p1[6],p2[5],p2[6],p3[5],p3[6],5)
      line(p1[5],p1[6],p2[5],p2[6],8)
      line(p2[5],p2[6],p3[5],p3[6])
      line(p3[5],p3[6],p1[5],p1[6])
    elseif mode=="fill" then 
      fillp(dither_p)
      fill_tri(p1[5],p1[6],p2[5],p2[6],p3[5],p3[6],col)
      fillp()
    end
  end

  --prof_lap("raster")

  --| hud |--
  rectfill(0, 100, 65, 127, 0)
  local f = "\^o140"
  print(f .. "num objects: " .. #scene,0,102,4)
  print(f .. "total tris: " .. #polys,0,109,4)
  print(f .. "cpu: " .."%"..(stat(1)*100),0,116,4)

  --prof_draw(70, 2)
end
-->8
--| helper functions |--

--@p01
function fill_tri(x0,y0,x1,y1,x2,y2,col)
  color(col)
  if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
  if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
  if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
  if(y2<=y0)return
  local m=x0+(x2-x0)*((y1-y0)/(y2-y0))
  p01_trapeze_h(x0,x0,x1,m,y0,y1)
  p01_trapeze_h(x1,m,x2,x2,y1,y2)
end

function p01_trapeze_h(l,r,lt,rt,y0,y1)
  local ya,yb=ceil(y0),ceil(y1)-1
  if(ya<0)ya=0
  if(yb>127)yb=127
  if(ya>yb)return
  local dy=y1-y0
  lt,rt=mid(-255,(lt-l)/dy,255),mid(-255,(rt-r)/dy,255)
  local sub=ya-y0
  l+=sub*lt
  r+=sub*rt 
  for y=ya,yb do 
    rectfill(l,y,r,y)
    l+=lt 
    r+=rt 
  end
end
-->8
--| Archive |--
--  History of profile results and alternate implemenations

--[[ ---- profiler history -------------------------------------

  Pre-shadow
  INPUT:  0.3%
  XFORM:  3.1%
  BUILD:  13.6%
  SORT:   4.8%
  RASTER: 9.4%
  -------------------------------
  Post-shadow
  INPUT:  0.3%
  XFORM:  9.3%
  BUILD:  35.3%
  SORT:   20.2%
  RASTER: 23.4%
  -------------------------------
  Latest
  INPUT:  0.3%
  XFORM:  9.4%
  BUILD:  32.0%
  SORT:   20.7%
  RASTER: 25.3%
]]

--[[ ---- fast_mat_mul, compact form ----------------------------
  71 tokens cheaper than the unrolled version in tab 1, but about
  10-15% slower. swap in if you need the tokens back more than the
  frame time.

  function fast_mat_mul(a, b)
    local m = {}
    -- i tracks the 4 rows (0, 4, 8, 12)
    for i=0, 12, 4 do
      -- j tracks the 4 columns (1, 2, 3, 4)
      for j=1, 4 do
        add(m, a[i+1]*b[j] + a[i+2]*b[j+4] + a[i+3]*b[j+8] + a[i+4]*b[j+12])
      end
    end
    return m
  end
]]

--[[ ---- icosphere base faces, table form -----------------------
  the packed string in gen_icosphere is this list:

  {
    {1, 6, 2}, {1, 12, 6}, {1, 11, 12}, {1, 8, 11}, {1, 2, 8},
    {2, 6, 10}, {6, 12, 5}, {12, 11, 3}, {11, 8, 7}, {8, 2, 9},
    {10, 6, 5}, {5, 12, 3}, {3, 11, 7}, {7, 8, 9}, {9, 2, 10},
    {4, 10, 5}, {4, 5, 3}, {4, 3, 7}, {4, 7, 9}, {4, 9, 10}
  }
]]

--[[ ---- cube faces, table form --------------------------------
  the packed string next to cube_verts is this list:

  {
    {4,3,2,1}, -- front
    {5,6,7,8}, -- back
    {8,7,3,4}, -- top
    {1,2,6,5}, -- bottom
    {2,3,7,6}, -- right
    {5,8,4,1}  -- left
  }
]]

--[[ -- Soft sphere shadow occlusion --
  0 = unoccluded, 1 = fully occluded.
  currently unused by shade_tri, which inlines an equivalent test.

  function occ(cx,cy,cz,dx,dy,dz,sx,sy,sz,r,tmax)
    local mx,my,mz = sx-cx,sy-cy,sz-cz
    local t=mid(0,(mx*dx+my*dy+mz*dz)/(dx*dx+dy*dy+dz*dz),tmax)
    local px,py,pz=cx+t*dx-sx,cy+t*dy-sy,cz+t*dz-sz
    local d2=px*px+py*py+pz*pz
    local ro=r*1.4--soft edge between r and 1.4r
    return mid(0,(ro*ro-d2)/(ro*ro-r*r),1)
  end
]]

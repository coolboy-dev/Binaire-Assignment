-- rockhound
-- by lindsay baker
-- v1.05, 4 september 2026

-- changelog
-- 1.00 - initial release
-- 1.01 - added "ease" to
--        movement so player
--        goes around corners
--        better
-- 1.02 - minor tidying up
-- 1.03 - fixed dialogs bug
-- 1.04 - added high score
-- 1.05 - enlarged viewport

-- globals --------------------

version="V1.05"

maze = {
    -- max width/height is 63
    -- **must** be an odd number
    -- or map generation will fail
    width = 15,
    height = 11,

    -- how many walls to put
    -- an extra hole in
    holes = 127,

    -- gems
    gems=5,

    -- floor tile sprite number
    floortile = 17,

    -- exit tile sprite number
    -- (filled in dynamically)
    exittile = 0,
    exit_open=false,
    exittile_h = 18,
    exittile_v = 19,

    exit_flipx=false,
    exit_flipy=false,

    exitx = 0, -- the actual exit
    exity = 0,
    exitx1 = 0, -- adjacent tile
    exity1 = 0,
    exitx2 = 0, -- other adjacent tile
    exity2 = 0
}

mazeexit={
    x=0,
    y=0,
    flipx=false,
    flipy=false,
    bbox={x1=0, y1=0, x2=0, y2=0},
    current_sprite=23,
    animation_currentanimation=1,
    animation_framecount=0,
    animations={
        -- animate sprite "spr" for "f" frames
        -- horizontal exit, closed
        {sprite=18, frames=1, x1=0, y1=0, x2=7, y2=7},
        {sprite=-1},

        -- vertical exit, closed
        {sprite=19, frames=1, x1=0, y1=0, x2=7, y2=7},
        {sprite=-1},

        -- horizontal exit, open
        {sprite=52, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=53, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=54, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=55, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=-4},

        -- vertical exit, open
        {sprite=56, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=57, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=58, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=59, frames=3, x1=0, y1=0, x2=7, y2=7},
        {sprite=-4}
    }
}

viewport = {
    x = 0,
    y = 0,
    tw = 16, -- tiles wide
    th = 14, -- tiles high
    width = 0, -- pixels (calculated)
    height = 0, -- ditto
    centre_x = 0,
    centre_y = 0
}

camera_window = {
    x = 0,
    y = 0,
    max_x = 0,
    max_y = 0
}

dirs = {
    up = 1,
    right = 2,
    down = 3,
    left = 4,
    idle = 5
}

-- enemy types:
-- Nappers move slowly and will occasionally
-- stop moving entirely to take a nap
-- Wanderers move more quickly but move at random
-- seekers move faster than wanderers and try to move 
-- towards the player
-- Bezerkers will suddenly randomly speed up
-- to double their normal speed!
etypes={napper=1,wanderer=2,bezerker=3,seeker=4,reaper=5}
enames={"nappers","wanderers","bezerkers","seekers","reapers"}

gtypes={gem=1,shield=2,extralife=3}

num_enemies={0,0,0,0,0}

dirnames = { "up", "right", "down", "left", "idle" }
offsets={{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0},{x=0,y=0}}
turns={false, false, false, false}

player = {
    lives = 3,
    shields = 1,
    invincible=0,
    footsteps=0,
    x = 0,
    y = 0,
    -- the player's real position in the map
    -- taking the bounding box into consideration
    x1 = 0,
    x2 = 0,
    y1 = 0,
    y2 = 0,
    idle = true,
    sprite = 96,
    spd = 1.25,
    animspeed = 0.2,
    dir = dirs.idle,
    bbox = { x1 = 2, y1 = 0, x2 = 6, y2 = 7, mx=4, my=3.5 },
    anims = {
        -- start frame, end frame --
        { s = 64, e = 68 }, --up
        { s = 80, e = 84 }, --right
        { s = 96, e = 100 }, --down
        { s = 112, e = 116 }, --left
        { s = 96, e = 96 } --idle
    }
}

oneshots={}

dir_offsets = {
    { x = 0, y = -2 },
    { x = 0, y = 2 },
    { x = -2, y = 0 },
    { x = 2, y = 0 }
}

game={
    modes={titlescreen=1, playing=2, levelcomplete=3, playerhit=4, gameover=5 },
    mode=1,
    score_low=0,
    score_high=0,
    level=0,
    gems_collected=0,
    gems_total=0,
    nextfreelife=5,
    nextshield=3
}


-- for debugging only
-- this is used to reset debug.txt when game starts
newgame = true

function debug(msg)
    printh(msg, "debug.txt", newgame, true)
    newgame = false
end

--function tdebug(a, d)
--    if (a) debug(dirnames[d])
--end

-- note to self; the backslash is the same as flr - ie, p\8 is the same as flr(p/8)
function togrid(p)
    return p\8
end

function topixel(p)
    return flr(p*8)
end

function sqr(n)
    return n*n
end

function _sfxplaying()
    return (stat(46)+stat(47)+stat(48)+stat(49)>-1)
end



function animation_setanimation(obj,ani)
    obj.animation_current=ani
    obj.animation_framecount=0
    obj.current_sprite=obj.animations[ani].sprite

    obj.bbox.x1=obj.x+obj.bbox.x1
    obj.bbox.y1=obj.y+obj.bbox.y1
    obj.bbox.x2=obj.x+obj.bbox.x2
    obj.bbox.y2=obj.y+obj.bbox.y2
end

function animation_animate(obj)
    obj.animation_framecount+=1
    if (obj.animation_framecount < obj.animations[obj.animation_current].frames) return

    -- move to the next sprite, or loop around
    obj.animation_framecount=0
    obj.animation_current+=1
    if (obj.animations[obj.animation_current].sprite<0) then
        obj.animation_current+=obj.animations[obj.animation_current].sprite
    end

    -- set the new current sprite
    obj.current_sprite=obj.animations[obj.animation_current].sprite
end


-- dialog box functions -----

function _twidth(str)
    local tw = print(str, 0, -50)
    return tw
end

function _center(str, y, textcolor)
    local x = 64 - (_twidth(str) / 2)
    print(str, x, y, textcolor)
end

function _rprint(str, x, y, textcolor)
    local xp = x - _twidth(str)
    print(str, xp, y, textcolor)
end

-- right-justify text to "x"
function rjprint(str, x, y, c)
    local tx
    local strlen=print(str,0,-100)

    tx=x+1-strlen
    print(str,tx,y,c)
end

function dialog_bluebox(x1,y1,x2,y2)
    -- draw two overlapping black boxes to lift the 
    -- dialog off the background but with round corners
    rectfill(x1,y1-1,x2,y2+1,0)
    rectfill(x1-1,y1,x2+1,y2,0)

    -- draw the inner light blue
    rectfill(x1+1,y1+1,x2-1,y2-1,12)

    -- draw the outlines
    line(x1+2,y1,x2-2,y1,6)
    line(x2,y1+2,x2,y2-2,6)
    line(x1+2,y2,x2-2,y2,1)
    line(x1,y1+2,x1,y2-2,1)

    -- draw the corners
    pset(x1+1,y1+1,6)
    pset(x2-2,y1,7)
    pset(x2-1,y1+1,7)
    pset(x2,y1+2,7)
    pset(x1+1,y2-1,1)
    pset(x2-1,y2-1,1)   
end

function dialog_box(y, textcolor, ...)
    local args={...}
    local border = 4
    local maxw = -1
    local tw
    local th = 8
    -- text height
    local h = border * 2
    local x0, x1, y0, y1

    for n=1,#args do
        tw=_twidth(args[n])
        if (tw > maxw) maxw = tw
        h += th
    end

    x0 = 64 - (maxw / 2) - border
    x1 = x0 + maxw - 2 + (2 * border)
    y0 = y
    y1 = y + h - 4

    dialog_bluebox(x0, y0, x1, y1)

    -- draw a black border
--    rectfill(x0, y0, x1, y1, 0)

    -- then the inner rectangle
    --rectfill(x0 + 2, y0 + 2, x1 - 2, y1 - 2, 2)

    for n=1,#args do
        _center(args[n], y + border + ((n-1) * th), textcolor)
    end
end


-- maze functions -------------

function maze_make()

    -- temporary for testing
    if (game.level==64) then
        maze.width=99
        maze.height=99
    end

    if (game.level==1) then
        maze.width=15
        maze.height=13
        maze.gems=5
        maze.holes=3
    -- add up to 5 to height and width up to 63 max
    else
        maze.width+=flr(rnd(5)+1)
        if ((maze.width%2)==0) maze.width+=1
        if (maze.width>63) maze.width=63

        maze.height+=flr(rnd(5)+1)
        if ((maze.height%2)==0) maze.height+=1
        if (maze.height>63) maze.height=63

        -- higher level, more gems
        maze.gems=flr(maze.width*maze.height*0.05)+1

        -- and holes
        maze.holes=flr(maze.width*maze.height*0.05)+1
    end

    -- clear out the maze
    maze_erase()

    -- start carving from the top-left internal cell (1, 1)
    maze_carve(1, 1)

    -- punch some random holes
    maze_punch_holes()

    -- maze is made, now adjust
    -- the sprites
    maze_round_corners()

    -- create an exit somewhere
    maze_make_exit()

    -- put the exit tile in
    mset(maze.exitx, maze.exity, maze.exittile)
end

-- fill the whole map with walls
function maze_erase()
    local x, y
    for y = 0, maze.height - 1 do
        for x = 0, maze.width - 1 do
            mset(x, y, 1)
        end
    end
end

-- recursive backtracking algorithm to carve paths
function maze_carve(cx, cy)
    local i, dx, dy, nx, ny, d, dt
    local dirs_tried = {
        dirs.up,
        dirs.down,
        dirs.left,
        dirs.right
    }

    -- mark current cell as a floor
    mset(cx, cy, maze.floortile)

    -- so far we've tried 0 directions
    dt = 0

    -- define directions: 0=up, 1=right, 2=down, 3=left
    while dt < 4 do
        dt += 1

        -- find a direction not yet tried
        repeat
            d = 1 + flr(rnd(4))
        until dirs_tried[d] != 0
        dirs_tried[d] = 0

        -- where would we be next?
        nx = cx + dir_offsets[d].x
        ny = cy + dir_offsets[d].y

        -- check if the neighbor cell is within bounds and is still a wall
        if (nx > 0 and nx < maze.width - 1 and ny > 0 and ny < maze.height - 1) then
            if (maze_check(nx, ny) == 1) then
                -- carve through the intermediate wall
                mset(cx + (dir_offsets[d].x / 2), cy + (dir_offsets[d].y / 2), maze.floortile)

                -- recursively move to the next cell
                maze_carve(nx, ny)
            end
        end
    end
end

-- is this map square occupied?
function maze_check(x, y)
    local tile = mget(x, y)

    -- wall?
    if (fget(tile) == 1) then
        return 1
    else
        -- nothing we can collide with
        return 0
    end
end

-- make all corners round
-- not really necessary,
-- but prettier!
function maze_round_corners()
    for x = 0, maze.width - 1 do
        for y = 0, maze.height - 1 do
            if (maze_check(x, y) == 0) then
                mset(x, y, maze.floortile)
            else
                maze_round_corner(x, y)
            end
        end
    end
end

function maze_round_corner(x, y)
    local tu, td, tl, tr, tn

    tu, td, tl, tr = 0, 0, 0, 0
    if (y > 0) tu = maze_check(x, y - 1)
    if (y < maze.height - 1) td = maze_check(x, y + 1)
    if (x > 0) tl = maze_check(x - 1, y)
    if (x < maze.width - 1) tr = maze_check(x + 1, y)
    -- turn them into a nibble
    tn = (tu * 8) + (td * 4) + (tl * 2) + tr

    -- set map square type
    mset(x, y, tn + 1)
end

function maze_punch_holes()
    -- find "maze.holes" tiles and
    -- delete them to make gaps
    -- do this by splitting
    -- existing rules of either
    -- horizontal or vertical walls

    local punched=false
    for h = 1, maze.holes do
        repeat
            punched=false
            repeat
                x = flr(2 + rnd(maze.width - 3))
                y = flr(2 + rnd(maze.height - 3))
                tt = maze_check(x, y)
            until tt > 0

            if (maze_check(x - 1, y) == 1 and maze_check(x + 1, y) == 1 and maze_check(x, y - 1) == 0 and maze_check(x, y + 1) == 0)
                    or (maze_check(x, y - 1) == 1 and maze_check(x, y + 1) == 1 and maze_check(x - 1, y) == 0 and maze_check(x + 1, y) == 0) then
                mset(x, y, maze.floortile)
                punched = true
            end
        until punched
    end
end

-- put an exit somewhere
-- but intially, it's blocked

function maze_make_exit()
    local r = flr(rnd(4))
    local x, y

    if (r == 0) then
        -- exit on top wall
        y = 0
        repeat
            x = flr(2 + rnd(maze.width - 3))
        until maze_check(x, y + 1) == 0
    elseif (r == 1) then
        -- exit on bottom wall
        y = maze.height - 1
        repeat
            x = flr(2 + rnd(maze.width - 3))
        until maze_check(x, y - 1) == 0
    elseif (r == 2) then
        x = 0
        -- exit on left wall
        repeat
            y = flr(2 + rnd(maze.height - 3))
        until maze_check(x + 1, y) == 0
    else
        -- exit on right wall
        x = maze.width - 1
        repeat
            y = flr(2 + rnd(maze.height - 3))
        until maze_check(x - 1, y) == 0
    end

    -- determine orientation of exit tile
    if (x == 0) then
        -- exit on left
        maze.exittile=maze.exittile_v
        maze.exitx1 = x
        maze.exity1 = y - 1
        maze.exitx2 = x
        maze.exity2 = y + 1
        animation_setanimation(mazeexit,3)
        mazeexit.flipx=true
        mazeexit.flipy=false
    elseif (x == maze.width - 1) then
        -- exit on right
        maze.exittile=maze.exittile_v
        maze.exitx1 = x
        maze.exity1 = y - 1
        maze.exitx2 = x
        maze.exity2 = y + 1
        animation_setanimation(mazeexit,3)
        mazeexit.flipx=false
        mazeexit.flipy=false
    elseif (y==0) then
        -- exit on top
        maze.exittile=maze.exittile_h
        maze.exitx1 = x - 1 
        maze.exity1 = y
        maze.exitx2 = x + 1
        maze.exity2 = y
        animation_setanimation(mazeexit,1)
        mazeexit.flipx=false
        mazeexit.flipy=false
    else
        -- exit on bottom
        maze.exittile=maze.exittile_h
        maze.exitx1 = x - 1
        maze.exity1 = y
        maze.exitx2 = x + 1
        maze.exity2 = y
        animation_setanimation(mazeexit,1)
        mazeexit.flipx=false
        mazeexit.flipy=true
    end
    maze.exitx = x
    maze.exity = y
    mazeexit.x= x
    mazeexit.y= y
    maze.exit_open=false
    mset(x, y, maze.exittile)
end

-- open the exit
function maze_open_exit()
    sfx(2)
    maze.exit_open=true
    mset(maze.exitx, maze.exity,0)
    maze_round_corner(maze.exitx1, maze.exity1)
    maze_round_corner(maze.exitx2, maze.exity2)
    mset(maze.exitx, maze.exity, maze.floortile)
    if (mazeexit.x==0 or mazeexit.x==maze.width-1) then
        animation_setanimation(mazeexit,10)
    else
        animation_setanimation(mazeexit,5)
    end
end

-- animate the exit
--function maze_animate_exit()
--    if (not maze.exit_open) return
--end

function maze_exit_draw()
    spr(mazeexit.current_sprite, topixel(mazeexit.x) + viewport.x, topixel(mazeexit.y) + viewport.y, 1, 1, mazeexit.flipx, mazeexit.flipy )
    animation_animate(mazeexit)
end


-- enemy functions --

function enemy_add(etype)
    local enemy={}
    
    if (etype==etypes.napper) goto create_napper
    if (etype==etypes.wanderer) goto create_wanderer
    if (etype==etypes.seeker) goto create_seeker
    if (etype==etypes.bezerker) goto create_bezerker
    if (etype==etypes.reaper) goto create_reaper

    stop("no valid enemy type to create")
    
::create_napper::
    enemy = {
        -- actual position
        x = 0,
        y = 0,

        type=etype,
        naptime=60,
        nextnap=flr(30+rnd(30)),
        napframe=1,
        napframecount=-1,

        -- bounding box size
        bbox = { x1 = 0, y1 = 0, x2 = 7, y2 = 7 },

        -- actual position of bounding box 
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,

        -- how fast to move and animate
        dir = dirs.idle,
        max_frames = 4, -- nappers move very slowly
        frames_skipped = 0,

        -- how far enemy has moved, and
        -- the limit before it's forced to turn
        dist = 9999,
        distmax = 0,

        -- animation parameters
        sprite = 48,
        sprincr = 0.25,
        anims = {
            -- start frame, end frame --
            { s = 68, e = 70 }, --up
            { s = 84, e = 86 }, --right
            { s = 100, e = 102 }, --down
            { s = 116, e = 118 } --left
--            { s = 48, e = 52 } -- idle (napping)
            },

        napping_anims = {
            -- display "spr" for "f" frames 
            { spr=78, f=6 },
            { spr=94, f=2 },
            { spr=110, f=2 },
            { spr=126, f=2 },
            { spr=-1, f=-1 }
            }
    }
    goto create_done

::create_wanderer::
        enemy = {
        -- actual position
        x = 0,
        y = 0,

        type=etype,

        -- bounding box size
        bbox = { x1 = 0, y1 = 0, x2 = 6, y2 = 7 },

        -- actual position of bounding box 
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,

        -- how fast to move and animate
        dir = dirs.idle,
        max_frames = 3, -- move enemy every this many frames
        frames_skipped = 0,

        -- how far enemy has moved, and
        -- the limit before it's forced to turn
        dist = 9999,
        distmax = 0,

        -- animation parameters
        sprite = 70,
        sprincr = 0.5,
        anims = {
            -- start frame, end frame --
            { s = 70, e = 72 }, --up
            { s = 86, e = 88 }, --right
            { s = 102, e = 104 }, --down
            { s = 118, e = 120 } --left
--            { s = 102, e = 102 } -- idle 
        }
    }
    goto create_done

::create_seeker::
--    debug("Creating seeker")

    enemy = {
        -- actual position
        x = 0,
        y = 0,

        type=etype,

        -- bounding box size
        bbox = { x1 = 0, y1 = 0, x2 = 7, y2 = 7 },

        -- actual position of bounding box 
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,

        -- how fast to move and animate
        dir = dirs.idle,
        max_frames = 2, -- move enemy every this many frames
        frames_skipped = 0,

        -- how far enemy has moved, and
        -- the limit before it's forced to turn
        dist = 9999,
        distmax = 0,

        -- animation parameters
        sprite = 104,
        sprincr = 0.2,
        anims = {
            -- start frame, end frame --
            { s = 72, e = 74 }, --up
            { s = 88, e = 90 }, --right
            { s = 104, e = 106 }, --down
            { s = 120, e = 122 } --left
 --           { s = 104, e = 104 } -- idle 
        }
    }
    goto create_done

::create_bezerker::
--    debug("Creating Bezerker")

    enemy = {
        -- actual position
        x = 0,
        y = 0,

        type=etype,

        -- bezerkers will occasionally double their speed
        bezerk=false,
        bezerkframes=flr(100+rnd(50)),

        -- bounding box size
        bbox = { x1 = 0, y1 = 0, x2 = 7, y2 = 7 },

        -- actual position of bounding box 
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,

        -- how fast to move and animate
        dir = dirs.idle,
        max_frames = 2, -- move enemy every this many frames
        frames_skipped = 0,

        -- how far enemy has moved, and
        -- the limit before it's forced to turn
        dist = 9999,
        distmax = 0,

        -- animation parameters
        sprite = 106,
        sprincr = 0.25,
        sprincr_bezerk = 0.5,
        anims = {
            -- start frame, end frame --
            { s = 74, e = 76 }, --up
            { s = 90, e = 92 }, --right
            { s = 106, e = 108 }, --down
            { s = 122, e = 124 } --left
--            { s = 106, e = 106 } -- idle 
        }
    }
    goto create_done

::create_reaper::
--    debug("Creating reaper")

    enemy = {
        -- actual position
        x = 0,
        y = 0,

        type=etype,

        -- bounding box size
        bbox = { x1 = 0, y1 = 0, x2 = 7, y2 = 7 },

        -- actual position of bounding box 
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,

        -- how fast to move and animate
        dir = dirs.idle,
        max_frames = 2, -- move enemy every this many frames
        frames_skipped = 0,

        -- how far enemy has moved, and
        -- the limit before it's forced to turn
        dist = 9999,
        distmax = 0,

        -- animation parameters
        sprite = 110,
        sprincr = 0.25,
        anims = {
            -- start frame, end frame --
            { s = 76, e = 78 }, --up
            { s = 92, e = 94 }, --right
            { s = 108, e = 110 }, --down
            { s = 124, e = 126 } --left
 --           { s = 104, e = 104 } -- idle 
        }
    }
    goto create_done


::create_done::
    return enemy
end

-- this is how many of each type of enemy in level 1
function enemies_reset()
    -- the negative numbers delay which level they first appear
    num_enemies={2.5,1.3,-0.6,-1.4,-1.8}
end

function enemies_init()
    enemies={}

    num_enemies[etypes.napper]+=0.4  
    num_enemies[etypes.wanderer]+=0.7
    num_enemies[etypes.bezerker]+=0.6
    num_enemies[etypes.seeker]+=0.5
    num_enemies[etypes.reaper]+=0.3

    for e=1,5 do
        for n=1,num_enemies[e] do
            add(enemies,enemy_add(e))
        end
    end
end

function enemies_place()
    local en
    for en in all(enemies) do
        enemy_place(en)
    end
end

function enemies_draw()
    local en
    for en in all(enemies) do
        enemy_draw(en)
    end   
end

function enemies_move()
    local en
    for en in all(enemies) do
        enemy_move(en)
    end
end

function _between(v,p1,p2)
    if (v>p1 and v<p2) return true
end

function _betweenorequal(v,p1,p2)
    if (v>=p1 and v<=p2) return true
end

function enemies_collide()
    local e
    for e in all(enemies) do
        -- wide enemy, narrow player
        if (_between(e.x1,player.x1,player.x2)
            or _between(e.x2,player.x1,player.x2))
            and
            (_betweenorequal(e.y1,player.y1,player.y2)
                or _betweenorequal(e.y2,player.y1,player.y2))
            then
                game.mode=game.modes.playerhit
        -- narrow enemy, wide player
        elseif (_betweenorequal(player.x1,e.x1,e.x2)
            or _betweenorequal(player.x2,e.x1,e.x2))
            and
            (_between(player.y1,e.y1,e.y2)
                or _between(player.y2,e.y1,e.y2))
            then
                game.mode=game.modes.playerhit
        end
    end
end

-- individual enemy functions --

function enemy_move_to(e,x,y)
    e.x=x
    e.y=y
    e.x1=e.x+e.bbox.x1
    e.x2=e.x+e.bbox.x2
    e.y1=e.y+e.bbox.y1
    e.y2=e.y+e.bbox.y2
end

function enemy_newdistance(e)
    e.distmax = 10 + flr(rnd(10))
    e.dist = 0
end

function enemy_canmove(e, xofs, yofs)
    local nx=togrid(e.x)+xofs
    local ny=togrid(e.y)+yofs
    if (nx<0 or nx>=maze.width or ny<0 or ny>=maze.height or (mget(nx,ny)!=maze.floortile)) return false
    return true
end

function enemy_place(e)
    local px, py, dir, tile_ok=false

    -- find an empty tile
    repeat
        tile_ok=false
        px = 2 + flr(rnd(maze.width - 3))
        py = 2 + flr(rnd(maze.height - 3))

        -- not within 4 tiles of player
        if (abs(px-togrid(player.x))>=4 and abs(py-togrid(player.y))>=4) then
            tile_ok=(maze_check(px, py)==0)
        end
    until tile_ok 
    enemy_move_to(e, topixel(px), topixel(py))

    -- find an available direction
    repeat
        dir=flr(1+rnd(4))
    until enemy_canmove(e,offsets[dir].x,offsets[dir].y)
    e.dir=dir
    e.sprite=e.anims[e.dir].s
end

function enemy_draw(e)
    spr(e.sprite, e.x + viewport.x, e.y + viewport.y)
end

function enemy_check_bezerker_or_reaper(e)
    -- reapers always return true
    if (e.type == etypes.reaper) return true

    -- bezerkers return true when bezerking
    if (e.type == etypes.bezerker) then
        e.bezerkframes-=1
        -- currently bezerking?
        if (e.bezerk) then
            if (e.bezerkframes<=0) then
                e.bezerk=false
                -- time until next bezerk ... lower as game level higher
                e.bezerkframes=flr(100+rnd(50)-(game.level*2))
                e.sprite=e.anims[e.dir].s
                return false
            else
                return true
            end
        elseif (e.bezerkframes<=0) then
            e.bezerk=true
            -- how long to bezerk for ... higher as game level higher
            e.bezerkframes=flr(60+rnd(30)+(game.level*10))
            e.sprite=e.anims[e.dir].s
            return true
        end
    end
    return false
end

function enemy_animate(e)
    if (e.type==etypes.napper and e.dir==dirs.idle) then
        e.napframecount+=1
        if (e.napframecount<e.napping_anims[e.napframe].f) return
        e.napframecount=0
        e.napframe+=1
        if (e.napping_anims[e.napframe].spr==-1) e.napframe=1
        e.sprite=e.napping_anims[e.napframe].spr
        return
    elseif (e.type==etypes.bezerker and e.bezerk) then
        e.sprite += e.sprincr_bezerk
    else
        e.sprite += e.sprincr
    end
    if (e.sprite >= e.anims[e.dir].e) e.sprite = e.anims[e.dir].s
end

function enemy_move(e)
    local turns={false, false, false, false}
    local numturns, xofs, yofs
    local reversedir={dirs.down,dirs.left,dirs.up,dirs.right}
    -- specifically for seekers

    if (not enemy_check_bezerker_or_reaper(e)) then
        e.frames_skipped+=1
        if (e.frames_skipped < e.max_frames) goto move_done
    end

::move_start::
    e.frames_skipped=0

::move_again::
    -- get movement offsets for current direction
    xofs=offsets[e.dir].x
    yofs=offsets[e.dir].y
    -- if we're not on an exact tile 
    -- (ie: a multiple of 8 in both x and y
    -- then no need to check exits,
    -- just keep moving in the same direction
    -- note to self: should this apply to seekers?
    if ((e.x%8!=0) or ((e.y%8)!=0)) goto move_along

    -- special case for "Nappers"
    -- instead of moving immediately,
    -- count down (or start) their nap time
    if (e.type==etypes.napper) then
         -- currently napping?
        if (e.dir==dirs.idle) then
            e.naptime-=1
            if (e.naptime==0) then
                e.dir=e.olddir
                e.naptime=flr(30+rnd(30))
                e.nextnap=flr(30+rnd(30))
                e.sprite=e.anims[e.dir].s
                e.napframecount=-1
                goto move_again
            end
            goto move_animate
        end
        -- time for a nap?
        e.nextnap-=1
        if (e.nextnap==0) then
            e.olddir=e.dir
            e.dir=dirs.idle
            e.naptime=flr(30+rnd(30))
            e.nextnap=flr(30+rnd(30))
            e.sprite=e.napping_anims[1].spr
            e.napframecount=-1
            goto move_animate
        end
    end

    -- ok, so it's time to move
    -- what exits are available
    turns[dirs.up]=enemy_canmove(e,0,-1)
    turns[dirs.right]=enemy_canmove(e,1,0)
    turns[dirs.down]=enemy_canmove(e,0,1)
    turns[dirs.left]=enemy_canmove(e,-1,0)

    numturns=tonum(turns[dirs.up])
        +tonum(turns[dirs.right])
        +tonum(turns[dirs.down])
        +tonum(turns[dirs.left])

    -- dead end? reverse direction
    -- the "not turns[e.dir]" is needed for
    -- the very first frame of the level to stop
    -- an enemy newly placed into a dead end from
    -- turning around and walking through the wall
    if (numturns==1) then
        if (not turns[e.dir]) then
            e.dir=reversedir[e.dir]
            e.sprite=e.anims[e.dir].s
            xofs=offsets[e.dir].x
            yofs=offsets[e.dir].y
        end
        goto move_along
    end

    -- travelled too far? force a turn
    if (e.dist > e.distmax) then
        enemy_newdistance(e)
        goto must_turn
    end
    
    -- can we keep moving in the same
    -- direction we already are?
    -- (except, seekers will turn any time if it helps)
    if (e.type!=etypes.seeker and enemy_canmove(e, xofs, yofs)) goto move_along

::must_turn::
    -- for seekers and reapers, calculate the distance to the player
    -- for each available turn
    if (e.type==etypes.seeker or e.type==etypes.reaper) then
        local player_dist={9999,9999,9999,9999}
        local ex=togrid(e.x)
        local ey=togrid(e.y)
        local px=togrid(player.x)
        local py=togrid(player.y)

        if (turns[dirs.up]) player_dist[dirs.up]=sqr(ex-px)+sqr(ey-1-py)
        if (turns[dirs.right]) player_dist[dirs.right]=sqr(ex+1-px)+sqr(ey-py)
        if (turns[dirs.down]) player_dist[dirs.down]=sqr(ex-px)+sqr(ey+1-py)
        if (turns[dirs.left]) player_dist[dirs.left]=sqr(ex-1-px)+sqr(ey-py)
        
        -- don't allow the seeker to backtrack (this stops it wavering to and fro)
        player_dist[reversedir[e.dir]]=9999

        --debug("seeker distances: "..player_dist[dirs.up]..","..player_dist[dirs.right]..","..player_dist[dirs.down]..","..player_dist[dirs.left])

        -- which is lowest?
        local best_dir=e.dir
        local min_dist=9999
        for testdir = 1, 4 do
            if (player_dist[testdir] < min_dist) then
                min_dist = player_dist[testdir]
                best_dir = testdir
            end
        end

        -- if a new direction found, move in that direction!
        if (best_dir != e.dir) then
--            debug("Moving to")
--            tdebug(true,best_dir)
--            debug("")
            e.dir = best_dir
            e.sprite=e.anims[e.dir].s
            xofs=offsets[e.dir].x
            yofs=offsets[e.dir].y
        end
        goto move_along
    end

    -- corner?
    if (numturns==2) then
        if (e.dir==dirs.up) then
            if (turns[dirs.left]) goto turn_left
            goto turn_right
        end

        if (e.dir==dirs.right) then
            if (turns[dirs.up]) goto turn_left
            goto turn_right
        end

        if (e.dir==dirs.down) then
            if (turns[dirs.right]) goto turn_left
            goto turn_right
        end

        if (e.dir==dirs.left) then
            if (turns[dirs.down]) goto turn_left
            goto turn_right
        end
    end

    -- t-junction - don't reverse, turn left or right.
    -- A little tricky. if we're currently travelling
    -- along the long part, turn down the stem. If we're
    -- travelling up the stem, turn left or right
    if (numturns==3) then
        -- moving up into a |- or -|

        if (e.dir==dirs.up and turns[dirs.up]) then
            if (turns[dirs.left]) goto turn_left
            goto turn_right
        end

        -- moving down into a |- or -|
        if (e.dir==dirs.down and turns[dirs.down]) then
            if (turns[dirs.right]) goto turn_left
            goto turn_right
        end

        -- moving left into a T (either orientation)
        if (e.dir==dirs.left and turns[dirs.left]) then
            if (turns[dirs.down]) goto turn_left
            goto turn_right
        end

        -- moving right into a T (either orientation)
        if (e.dir==dirs.right and turns[dirs.right]) then
            if (turns[dirs.up]) goto turn_left
            goto turn_right
        end

        -- if we get here, we're moving into the T from
        -- the stem, so turn left or right at random
        if (rnd(1)>0.5) goto turn_left
        goto turn_right
    end

    -- if we get here, we're at a crossroads, so
    -- turn at random.
    if (rnd(1)>0.5) goto turn_right

::turn_left::
    e.dir-=1
    if (e.dir==0) then
        e.dir=4
    end
    goto turn_finish

::turn_right::
    e.dir+=1
    if (e.dir>=5) then 
        e.dir=1
    end
    --goto turn_finish
    
::turn_finish::
    e.sprite=e.anims[e.dir].s
    goto move_again

::move_along::
    enemy_move_to(e,e.x+xofs,e.y+yofs)
    e.dist += 1

::move_animate::
    -- animate
    enemy_animate(e)
    
::move_done::
-- that's it, nothing else to do

end


-- player functions -----------

function player_init()
        -- put player in map
        player_place()
        player.invincible=0
end

function player_move_to(px,py)
        player.x=px
        player.y=py

        player.x1=flr(px+player.bbox.x1)
        player.y1=flr(py+player.bbox.y1)

        player.x2=flr(px+player.bbox.x2)
        player.y2=flr(py+player.bbox.y2)
end

function player_place()
        local px, py

        -- put player on opposite
        -- side of maze exit

        if (maze.exitx == 0) then
                -- exit is left
                px = maze.width - 2
                repeat
                        py = 2 + flr(rnd(maze.height - 3))
                until maze_check(px, py) == 0
        elseif (maze.exitx == maze.width - 1) then
                -- exit is right
                px = 1
                repeat
                        py = 2 + flr(rnd(maze.height - 3))
                until maze_check(px, py) == 0
        elseif (maze.exity == 0) then
                -- exit is top
                py = maze.height - 2
                repeat
                        px = 2 + flr(rnd(maze.width - 3))
                until maze_check(px, py) == 0
        else
                -- exit is bottom
                py = 1
                repeat
                        px = 2 + flr(rnd(maze.width - 3))
                until maze_check(px, py) == 0
        end

        player_move_to(topixel(px),topixel(py))
end

function player_draw()
        local cc=flr(1+player.invincible/30)
        local cols={8,8,3,11,7}

        spr(player.sprite, player.x + viewport.x, player.y + viewport.y)

        if (player.invincible==0) return

        player.invincible-=1
        if (player.invincible>30) then
                circ(player.x + 4 + viewport.x, player.y + 4 + viewport.y, 6, cols[cc])
        else
                if (player.invincible%2==0) circ(player.x + 4 + viewport.x, player.y + 4 + viewport.y, 6, cols[cc])
        end

        if (player.invincible<=0) sfx(14,-2)
end

function player_move()
        local xofs, yofs = 0,0

        -- activating shield?
        if (btn(❘) and player.invincible==0) then
                if (player.shields > 0) then
                        player.shields-=1
                        player.invincible=150
                        sfx(14)
                end
        end

        if (btn(⬆️) and player.y >= 0) then
                player.idle = false
                yofs = -player.spd
                if (player.dir != dirs.up) then
                        player.dir = dirs.up
                        player.sprite = player.anims[player.dir].s
                end
                if (player.footsteps==0) player.footsteps=1
        elseif (btn(⬇️) and player.y <= (maze.height - 1) * 8) then
                player.idle = false
                yofs = player.spd
                if (player.dir != dirs.down) then
                        player.dir = dirs.down
                        player.sprite = player.anims[player.dir].s
                end
                if (player.footsteps==0) player.footsteps=1
        elseif (btn(⬅️) and player.x >= 0) then
                player.idle = false
                xofs = -player.spd
                if (player.dir != dirs.left) then
                        player.dir = dirs.left
                        player.sprite = player.anims[player.dir].s
                end
                if (player.footsteps==0) player.footsteps=1
        elseif (btn(➡️) and player.x <= (maze.width - 1) * 8) then
                player.idle = false
                xofs = player.spd
                if (player.dir != dirs.right) then
                        player.dir = dirs.right
                        player.sprite = player.anims[player.dir].s
                end
                if (player.footsteps==0) player.footsteps=1
        else
                if not player.idle then
                        player.idle = true
                        player.sprite = player.anims[player.dir].s
                        player.footsteps=0
                end
        end

        if not player.idle and player_canmove(xofs, yofs) then
--                player_move_to(player.x+xofs,player.y+yofs)
                
                player.footsteps+=0.125
                if (player.footsteps>=1) then
                        player.footsteps=0.125
                        sfx(5)
                end

                -- animate
                player.sprite += player.animspeed
                if (player.sprite >= player.anims[player.dir].e) then
                        player.sprite = player.anims[player.dir].s
                end
        end

        -- has played moved to
        -- very edge?
        -- (only possible when exit opem)
        if (player.x <= player.spd) or (player.x >= ((maze.width - 1) * 8)-player.spd)
                or (player.y <= player.spd) or (player.y >= ((maze.height - 1) * 8)-player.spd) then
                game.mode = game.modes.levelcomplete -- level complete
                game_add_score(100*game.level)
        end
end

-- trying something different - check from middle of player
-- if move is OK, return forced co-ordinates that put the player 
-- aligned back into the 8x8 grid.
-- if not, return false

function player_canmove(xofs,yofs)
        local dest_tx, dest_ty
        local border=2
        local min=2-(2*player.spd)
        local max=5+(2*player.spd)

        -- player's position as an offset within a tile must be 3-(2*spd)<=p<=3+(2*spd) (ie, the middle 3 pixels)
        local dx = (player.x+player.bbox.mx)%8
        local dy = (player.y+player.bbox.my)%8
        local px = togrid(player.x)
        local py = togrid(player.y)
        
--        debugmsg="px: "..px.." py: "..py.." dest: "
        
        -- where are we trying to go?
        if (xofs<0) then --left
                if (not _betweenorequal(dy,min,max)) return false
                dest_tx=togrid(player.x+xofs)
                dest_ty=togrid(player.y+player.bbox.my)
 --               debugmsg=debugmsg..dest_tx..","..dest_ty
                if (mget(dest_tx,dest_ty)!=maze.floortile) return false
                player_move_to(player.x+xofs,topixel(dest_ty))
 --               debugmsg=debugmsg.." OK"
                return true
        end

        if (xofs>0) then --right
                if (not _betweenorequal(dy,min,max)) return false
                dest_tx=togrid(player.x+8)
                dest_ty=togrid(player.y+player.bbox.my)
  --              debugmsg=debugmsg..dest_tx..","..dest_ty
                if (mget(dest_tx,dest_ty)!=maze.floortile) return false
                player_move_to(player.x+xofs,topixel(dest_ty))
  --              debugmsg=debugmsg.." OK"
                return true
        end

        if (yofs<0) then --up
                if (not _betweenorequal(dx,min,max)) return false
                dest_tx=togrid(player.x+player.bbox.mx)
                dest_ty=togrid(player.y-1)
  --              debugmsg=debugmsg..dest_tx..","..dest_ty
                if (mget(dest_tx,dest_ty)!=maze.floortile) return false
                player_move_to(topixel(dest_tx),player.y+yofs)
  --              debugmsg=debugmsg.." OK"
                return true
        end

        if (yofs>0) then --down
                if (not _betweenorequal(dx,min,max)) return false
                dest_tx=togrid(player.x+player.bbox.mx)
                dest_ty=togrid(player.y+8)
  --              debugmsg=debugmsg..dest_tx..","..dest_ty
                if (mget(dest_tx,dest_ty)!=maze.floortile) return false
                player_move_to(topixel(dest_tx),player.y+yofs)
  --              debugmsg=debugmsg.." OK"
                return true
        end

        return false
end


function gem_add(jtype)
    local px, py, c, j
    local colours={
        {12,5}, --blue
        {8,4}, --red
        {11,3}, --green
        {14,2} --pink
    }
    -- pick a color set at random
    local col=1+flr(rnd(4))
    -- body colour, shadow colour

    if (jtype==gtypes.gem) goto create_gem
    if (jtype==gtypes.shield) goto create_shield
    if (jtype==gtypes.extralife) goto create_extralife

    stop("Invalid gem type requested")

::create_gem::
    j={
        x=0,
        y=0,
        type=gtypes.gem,
        body=colours[col][1],
        shadow=colours[col][2],

        bbox={x1=2,y1=1,x2=6,y2=6},
        current_sprite=23,
        animation_currentanimation=1,
        animation_framecount=0,
        animations={
            -- animate sprite "sprite" for "frames" frames
            -- loop back "sprite" frames if sprite<0
            {sprite=20, frames=60+rnd(30)},
            {sprite=21, frames=4},
            {sprite=22, frames=4},
            {sprite=23, frames=4},
            {sprite=-4}
        }
    }
    goto find_blank_space

::create_shield::
    j={
        x=0,
        y=0,
        type=gtypes.shield,

        bbox={x1=1,y1=0,x2=6,y2=7},
        current_sprite=29,
        animation_currentanimation=1,
        animation_framecount=0,
        animations={
            -- animate sprite "sprite" for "frames" frames
            -- loop back "sprite" frames if sprite<0
            {sprite=29, frames=30},
            {sprite=30, frames=6},
            {sprite=31, frames=6},
            {sprite=30, frames=6},
            {sprite=-4}
        }
    }
    goto find_blank_space

::create_extralife::
    j={
        x=0,
        y=0,
        type=gtypes.extralife,
        bbox={x1=0,y1=0,x2=7,y2=7},
        current_sprite=24,
        animation_currentanimation=1,
        animation_framecount=0,
        animations={
            -- animate sprite "sprite" for "frames" frames
            -- loop back "sprite" frames if sprite<0
            {sprite=24, frames=60+rnd(30)},
            {sprite=25, frames=4},
            {sprite=26, frames=4},
            {sprite=27, frames=4},
            {sprite=28, frames=4},
            {sprite=-5}
        }
    }
    goto find_blank_space

::find_blank_space::
    px = 2 + flr(rnd(maze.width - 3))
    py = 2 + flr(rnd(maze.height - 3))

    -- don't place right next to player
    if (abs(px-togrid(player.x)) <4 and abs(py-togrid(player.y))<4 ) goto find_blank_space

    -- only place on a floor 
    if (maze_check(px, py)!=0) goto find_blank_space

    -- don't place two gems right next to each other (or in the same place!)
    for c=1,#gems do
        if (abs(togrid(gems[c].x)-px)<2 and abs(togrid(gems[c].y)-py)<2) goto find_blank_space
    end 

    j.x=topixel(px)
    j.y=topixel(py)

    animation_setanimation(j,1)

    return j
end

function gems_init()
    gems = {}

    for c = 1, maze.gems do
        add(gems, gem_add(gtypes.gem))
    end

    -- for testing
--    add(gems,gem_add(gtypes.extralife))
--    add(gems,gem_add(gtypes.shield))

    game.gems_total=maze.gems
    game.gems_collected=0
end

function gem_animate(j)
    animation_animate(j)
end    

function gems_draw()
    for j=1,#gems do
        if (gems[j].type==gtypes.gem) then 
            pal(6,gems[j].body)
            pal(5,gems[j].shadow)
        end
        spr(gems[j].current_sprite,gems[j].x+viewport.x,gems[j].y+viewport.y)
        gem_animate(gems[j])
        pal()
    end 
end

function gems_collect(j)
    del(gems,j)
    if (j.type==gtypes.gem) then
        game.gems_collected+=1
        game_add_score(10)
        sfx(0)
        if (game.gems_collected==game.gems_total) maze_open_exit()
    elseif (j.type==gtypes.shield) then
        player.shields+=1
        oneshots_add(23,122,true,true)
        sfx(1)
    elseif (j.type==gtypes.extralife) then
        player.lives+=1
        oneshots_add(2,122,false,true)
        sfx(1)
    end
end

function gems_collide()
    for j in all(gems) do
        -- wide enemy, narrow player
        if (_between(j.bbox.x1,player.x1,player.x2)
            or _between(j.bbox.x2,player.x1,player.x2))
            and
            (_betweenorequal(j.bbox.y1,player.y1,player.y2)
                or _betweenorequal(j.bbox.y2,player.y1,player.y2))
            then
                gems_collect(j)
        -- narrow enemy, wide player
        elseif (_betweenorequal(player.x1,j.bbox.x1,j.bbox.x2)
            or _betweenorequal(player.x2,j.bbox.x1,j.bbox.x2))
            and
            (_between(player.y1,j.bbox.y1,j.bbox.y2)
                or _between(player.y2,j.bbox.y1,j.bbox.y2))
            then
                gems_collect(j)
        end
    end
    return

end




-- viewport and camera function --

function camera_set()
    local cx, cy

    -- if on left side
    if player.x < viewport.centre_x then
        cx = 0
    else
        cx = player.x - viewport.centre_x
        if (cx > camera_window.max_x) cx = camera_window.max_x
    end

    -- if on top side
    if player.y < viewport.centre_y then
        cy = 0
    else
        cy = player.y - viewport.centre_y
        if (cy > camera_window.max_y) cy = camera_window.max_y
    end

    camera_window.x = cx
    camera_window.y = cy
    camera(cx, cy)
end

function viewport_init()
    -- trim viewport if necessary

    -- initial values
    viewport.tw=16
    viewport.th=14
    viewport.x=0
    viewport.y=0

    if (maze.width<viewport.tw) then
        viewport.x=(viewport.tw-maze.width)*4 -- pixels!
        viewport.tw=maze.width
    end
    if (maze.height<viewport.th) then
        viewport.y=(viewport.th-maze.height)*4 -- pixels!
        viewport.th=maze.height
    end

--    if (viewport.tw > maze.width) viewport.tw = maze.width
--    if (viewport.th > maze.height) viewport.th = maze.height
    
    viewport.width = topixel(viewport.tw)
    viewport.height = topixel(viewport.th)
    viewport.centre_x = (viewport.width / 2)
    viewport.centre_y = (viewport.height / 2)
    
    camera_window.max_x = topixel(maze.width) - viewport.width
    camera_window.max_y = topixel(maze.height) - viewport.height

end


function oneshots_init()
    oneshots={}
end

function oneshot_create(ox,oy,ex,ey)
    local oneshot = {
        x = ox,
        y = oy,
        xofs = tonum(ex),
        yofs = tonum(ey),
        frame = 0,
        frameincr = 0.25,
        maxframe = 3
    }
    return oneshot
end

function oneshots_add(x,y,evenx,eveny)
    add(oneshots,oneshot_create(x,y,evenx,eveny))
end
   
function oneshots_draw()
    for o in all(oneshots) do
        spr(79,o.x-4-o.frame,o.y-8-o.frame,1,1,false,false)
        spr(79,o.x+4+o.xofs+o.frame,o.y-8-o.frame,1,1,true,false)
        spr(79,o.x-4-o.frame,o.y+o.yofs+o.frame,1,1,false,true)
        spr(79,o.x+4+o.xofs+o.frame,o.y+o.yofs+o.frame,1,1,true,true)
        o.frame += o.frameincr
        if (o.frame>o.maxframe) del(oneshots,o)
    end
end


-- game functions ------------

function waitforx()
    local t = time()
    while not btnp(❘) do end
    -- de-bounce X button
    while btn(❘) do end
end

function game_titlescreen()
    local x1=24
    local x2=104
    local y1,y2
    local lh=28
    local tm=0

    local gframe=1
    local psprites={96,97,98,99}
    local gsprites={20,21,22,23}
    local esprites={25,26,27,28}
    local ssprites={29,30,31,30}
    local xsprites={52,53,54,55}
    local nsprites1a={84,85,84,85}
    local nsprites1b={68,69,68,69}
    local nsprites2a={78,94,110,126}
    local nsprites3a={102,103,102,103}
    local nsprites3b={86,87,86,87}
    local nsprites4a={106,107,106,107}
    local nsprites4b={90,91,90,91}
    local nsprites5a={104,105,104,105}
    local nsprites5b={88,89,88,89}
    local nsprites6a={108,109,108,109}
    local nsprites6b={92,93,92,93}

    local ipage=1

    music(0)

    while not btn(❘) do
        cls()

        dialog_bluebox(0,0,127,127)
        rectfill(6,24,122,116,0)

        print("\^w\^t\^x5r ckh und",21,4,10)
        sspr(24+(flr(gframe)*8),8,8,8,26,1,16,16)
        sspr(24+(flr(gframe)*8),8,8,8,66,1,16,16)
    
        _center("BY lINDSAY bAKER",17,1)

        if (ipage==1) then
            _center("mOVE   THROUGH THE MAZE",40,12)
            spr(psprites[flr(gframe)],36,38)
            _center("AND COLLECT GEMS  ",49,12)
            spr(gsprites[flr(gframe)],94,48)
            _center("tHE MAZE EXIT STARTS",63,12)
            _center("THE LEVEL CLOSED  ",72,12)
            spr(18,95,71)
            _center("cOLLECT ALL THE GEMS",88,12)
            _center("TO OPEN IT  ",96,12)
            spr(xsprites[flr(gframe)],84,95)
            print()
            -- version number
            print(version,7,111,2)
        elseif (ipage==2) then
            _center("cOLLECT    FOR",44,12)
            spr(esprites[flr(gframe)],68,42)
            _center("AN EXTRA LIFE",53,12)
            _center("cOLLECT   FOR",71,12)
            spr(ssprites[flr(gframe)],68,69)
            _center("AN INVINCIBILITY SHIELD",80,12)
            _center("(PRESS ❘ TO ACTIVATE IT)",91,12)
        elseif (ipage==3) then
            _center("nappers",54,8)
            spr(nsprites1a[flr(gframe)],37,51)
            spr(nsprites1b[flr(gframe)],80,52)
            _center("tHESE SLOW-MOVING",64,12)
            _center("CREATURES WILL OCCASIONALLY",73,12)
            _center("STOP TO TAKE A NAP!",82,12)
            spr(nsprites2a[flr(gframe)],60,90)
        elseif (ipage==4) then
            _center("wanderers",54,8)
            spr(nsprites3a[flr(gframe)],33,53)
            spr(nsprites3b[flr(gframe)],86,53)
            _center("tHESE HUNGRY GHOSTS",64,12)
            _center("OF FORMER ROCKHOUNDS",73,12)
            _center("WANDER AIMLESSLY AROUND",82,12)
            _center("THE MAZE, HOPING TO",91,12)
            _center("MAKE A NEW FRIEND!",100,12)
        elseif (ipage==5) then
            _center("bezerkers",54,8)
            spr(nsprites4a[flr(gframe)],33,53)
            spr(nsprites4b[flr(gframe)],86,53)
            _center("bE CAREFUL WHEN CLOSE",64,12)
            _center("TO THESE FIERCE WARRIORS.",73,12)
            _center("aT ANY MOMENT THEY",82,12)
            _center("CAN GO BEZERK AND START",91,12)
            _center("RUNNING INSTEAD OF WALKING!",100,12)
        elseif (ipage==6) then
            _center("seekers",54,8)
            spr(nsprites5a[flr(gframe)],37,53)
            spr(nsprites5b[flr(gframe)],81,53)
            _center("tHEY ALWAYS KEEP AN EYE OUT",64,12)
            _center("FOR YOU, AND WILL TURN",73,12)
            _center("TOWARDS YOU IF THEY CAN.",82,12)
--            _center("TURN TOWARDS YOU IF THEY CAN.",91,12)
            --_center("MAKE A NEW FRIEND!",100,12)
        elseif (ipage==7) then
            _center("reapers",54,8)
            spr(nsprites6a[flr(gframe)],37,53)
            spr(nsprites6b[flr(gframe)],81,53)
            _center("tHE DEADLIEST DENIZEN!",64,12)
            _center("nOT ONLY DO THEY ALSO TURN",73,12)
            _center("TOWARDS YOU, BUT THEY MOVE",82,12)
            _center("TWICE AS FAST AS SEEKERS!",91,12)
        elseif (ipage==8) then
            _center("thank you",28,10)
            _center("tO THE CREATORS AND",42,12)
            _center("THE COMMUNITY OF PICO-8",51,12)
            _center("FOR MAKING IT POSSIBLE",60,12)
            _center("FOR ME TO RETURN TO GAME",69,12)
            _center("PROGRAMMING AFTER 30 YEARS.",78,12)
            _center("aND TO MY WIFE, ALWAYS ♥",93,12)
        end

        if (ipage<8) _center("instructions",28,10)
        if (_betweenorequal(ipage,3,7)) _center("aVOID RUNNING INTO ...",40,12)

        if (btnp(⬅️) and ipage>1) ipage-=1
        if (btnp(➡️) and ipage<8) ipage+=1
        if (ipage>1) print("⬅️ PREV",25,110,10)
        if (ipage<8) print("NEXT ➡️",75,110,10)
        
        gframe+=0.1
        if (gframe>=5) gframe=1

        tm=tm+0.035
        if (tm>=2) tm=0
        if (tm>=1) then
            _center("press ❘ to begin",120,10)
        else
            _center("high score: "..game_formatscore(highscore_low,highscore_high),120,1)
        end

        flip()
    end
    music(-1)

    -- wait for X to lift
    while btn(❘) do end

    -- preparations for new game
    player.lives=3
    player.shields=1
    game_reset_score()
    game.level=1 -- set to 64 to test all-out mayhem
    game.nextfreelife=5 -- level, not score
    game.nextshield=3 -- level, not score
    game.gems_total=0
    game.gems_collected=0
end

function game_draw()
    cls()

    -- draw the scrolling map
    camera_set()
    clip(viewport.x, viewport.y, viewport.width, viewport.height)
    map(0, 0, viewport.x, viewport.y, maze.width, maze.height)

    -- in Z order (lowest first)
    maze_exit_draw()
    gems_draw()

    -- if the player dies, we don't draw the player here
    if (game.mode==game.modes.playing) player_draw()

    enemies_draw()

    clip()
    camera(0, 0)

    -- draw the status bar
    dialog_bluebox(0,116,127,127)

    -- lives
    spr(96,1,118)
    print(player.lives,12,119,0)

    -- shields
    spr(29,23,118)
    print(player.shields,34,119,0)

    -- gems
    spr(21,45,118)
    print(game.gems_collected.."/"..game.gems_total,55,119,0)

    -- score
    game_print_score(124,119,0)

    -- one-shot animations
    oneshots_draw()

    -- debug msg
    if (debugmsg) print(debugmsg,0,0,10)

    -- only flip if playing - death animation has more to do
    if (game.mode==game.modes.playing) flip()
end

function game_levelstartscreen()
    local x1=24
    local x2=104
    local y1,y2
    local lh=28
    local tm=0

    -- animate enemies on level info screen ---
    -- may have to cull this ------------------
    local sprites={
        {84,85},
        {86,87},
        {90,91},
        {104,105},
        {108,109}
    }
    local sprframe=1
    -------------------------------------------

    -- how many lines high do we need? this is just the inner portion
    for c=1,5 do
        if (flr(num_enemies[c])>0) lh+=10
    end
    y1=56-(lh/2)
    y2=56+(lh/2)

    dialog_bluebox(x1,y1,x2,y2)

    -- the text
    local str="level "..game.level.."   "..maze.width.." x "..maze.height
    _center(str,y1+2,10)

    
    _center("press ❘ to begin",y2-6,10)

    -- gems
    spr(21,x1+8,y1+9)
    print("gems",x1+24,y1+11,1)
    _rprint(tostr(game.gems_total),x2-8,y1+11,15)

    for c=1,5 do
        if (flr(num_enemies[c])>0) then
            print(enames[c],x1+24,y1+(c*10)+12,1)
            _rprint(tostr(flr(num_enemies[c])),x2-8,y1+(c*10)+12,15)
        end
    end

    -- may have to cull this ------------------
    repeat
        rectfill(x1+8,y1+20,x1+16,y2-8,12)
        for c=1,5 do
            if (flr(num_enemies[c])>0) then
                spr(sprites[c][flr(sprframe)],x1+8,y1+(c*10)+10)
                sprframe+=0.025
                if (sprframe>=3) sprframe=1
            end
        end
        flip()
    until btn(❘)
    -------------------------------------------

    -- wait for X to lift
    while btn(❘) do end

    -- due for shield?
    if (game.level>=game.nextshield) then
        game.nextshield+=3 -- level
        if (player.shields<3) then
            add(gems, gem_add(gtypes.shield))
        end
    end

    -- due for extra life?
    if (game.level>=game.nextfreelife) then
        game.nextfreelife+=5 -- level
        if (player.lives<9) then
            add(gems, gem_add(gtypes.extralife))
        end
    end
end

function game_levelcomplete()
    sfx(-1)
    sfx(4)
    while (_sfxplaying()) do 
        enemies_move()
        game_draw()
        dialog_box(20,10,"level complete!")
        flip()
    end

    game.level += 1
    game.mode = game.modes.playing
end

function game_playerhit()
    local sy,sh

    player.lives -= 1
    sfx(3)

    -- show death animation
    for sh=0,8 do
        -- player descends, tombstone ascends
        for fr=0,10 do 
            enemies_move()
            game_draw()
            camera_set()
            clip(viewport.x, viewport.y, viewport.width, viewport.height)
            sspr(0,40,8,8-sh,player.x+viewport.x,player.y+viewport.y+sh)
            sspr(0,16,8,sh,player.x+viewport.x+1,player.y+viewport.y+8-sh)
            flip()
        end
    end
    --camera(0,0)

    -- wait for sfx to stop playing
    -- as it's not 100% sure which channel it will be on,
    -- check them all
    while (_sfxplaying()) do
        enemies_move()
        game_draw()
        camera_set()
        clip(viewport.x, viewport.y, viewport.width, viewport.height)
        sspr(0,16,8,8,player.x+viewport.x+1,player.y+viewport.y)
        clip()
        camera()
        flip()
    end

    -- game over?
    if (player.lives == 0) then
        game.mode = game.modes.gameover
    else
        game.mode = game.modes.playing
    end
end

function game_over()
    
    local y=20

    if (game.score_high>highscore_high) or
        (game.score_high==highscore_high and game.score_low>highscore_low) then
            highscore_high=game.score_high
            highscore_low=game.score_low
            dset(0,highscore_low)
            dset(1,highscore_high)
            y=44
            sfx(1)
            dialog_box(20, 10,
                "new high score!",
                "\^w"..game_formatscore(highscore_low,highscore_high)
            )
    end

    dialog_box(y, 1,
        "yOUR ROCKHOUND DAYS ARE OVER.",
        "bUT DON'T WORRY, THE WANDERERS",
        "WELCOME YOU WITH OPEN ARMS!",
        "",
        "press ❘"
    )

    flip()
    waitforx()

    game.mode = game.modes.titlescreen
end


-- Pico 8's number range won't go above 32,767
-- use two numbers, one for thousands (MSB) 
-- and one for <1000
-- Q: do I need to account for scores above 999,999?

function game_reset_score()
    game.score_low=0
    game.score_high=0
end

function game_add_score(s)
    game.score_low+=s
    if (game.score_low>=1000) then
        game.score_high+=1
        game.score_low-=1000
    end
end

function game_formatscore(lsb,msb)
    local st="$ "
    local tmp
    if (msb>0) then
        st=st..tostr(msb)..","
        tmp="000"..tostr(lsb)
        tmp=sub(tmp,#tmp-2)
    else
        tmp=tostr(lsb)
    end
    st=st..tmp
    return st
end

function game_print_score(x,y,c)
    rjprint(game_formatscore(game.score_low,game.score_high),x,y,c)
end


-----------------------------

-- force btnp to reset
poke(0x5f5c, 255)

cartdata("verynaughtyboy42_rockhound")
highscore_low=dget(0)
highscore_high=dget(1)

::startgame::

    game.mode=game.modes.titlescreen
    game_titlescreen()
    enemies_reset()

::startlevel::

    game.mode=game.modes.playing
    maze_make()
    viewport_init()
    oneshots_init()
    player_init()
    enemies_init()
    gems_init()
    enemies_place()
    game_draw()
    game_levelstartscreen()

::mainloop::

    player_move()
    enemies_move()
    if (player.invincible==0) enemies_collide()
    gems_collide()
    game_draw()

    if (game.mode == game.modes.levelcomplete) then
        game_levelcomplete()
        goto startlevel
    end

    if (game.mode == game.modes.gameover) then
        game_over()
        goto startgame
    end

    if (game.mode == game.modes.playerhit) then
        game_playerhit()
        player_init() -- drop the player back to the beginning
        enemies_place() -- move the enemies away from the player
        goto mainloop
    end

    goto mainloop





--mandelbrot v2
--jenquey

function real (a, b)
    return a*a - b*b
end

function imag (a, b)
    return 2 * a * b
end

function mandelbrot (a, b, lim)
    local ca = a
    local cb = b
    local n = 1
    while (n < lim) do
        local new_ca = real(ca,cb) + a
        local new_cb = imag(ca,cb) + b
        ca = new_ca
        cb = new_cb
        if ca*ca + cb*cb >= 4 then
            break
        end
        n+=1
    end

    if invert then
        if n == lim then
            n = 0
        end
    end
    return n
end

function blot(x, y)
    if ((x+0.25)*(x+0.25) + y*y <= 0.25)
        or ((x+1)*(x+1) + y*y <= 0.0625) then
        return true
    end

    return false
end

function limit_menu()
    menuitem(3, "limit: "..limit, function(b)
        local increment = 8
        while increment < limit/8 do increment *= 2 end
        while increment > limit/4 do increment /= 2 end
        if (b&1>0) then
            limit -= increment
        elseif (b&2>0) then
            limit += increment
        end

        limit = ceil(limit)
        if (limit > 1024) then
            limit = 1024
        elseif (limit < 8) then
            limit = 8
        end
        lut = shade_lut(limit, exp, invert)

        frac_counter = 0
        if (lod == 4) then
            lod = 3
        end
        if (b&32>0) then
            return false
        end

        menuitem(3, "limit: "..limit)
        return true
    end)
end



function gradient_init(shade)
    -- printh("","experiment/log.txt",true)
    for i = 0, 15 do
        pal()
        pal(i, i, 1)
    end
    --sets the color palette for the given shade
    if (shade == 1) then
        --red
        colors = { 0, -16, -14, -3, -8, 8, -7, -1 }
        -- colors = { 0, 2, 8, 14, 9, 10, 7 }

    elseif (shade == 2) then
        --blue
        -- colors = {0,1,5,13,12,6,7}
        colors = {0,-15,1,-4,12,6,7}
        -- colors = { 0, -16, -14, -12, -2, -7, 9, 8}

    elseif (shade == 3) then
        --green
        -- colors = { 0, 3, 11, 10, 7 }
        colors = {0,-13,3,-5,11,-6,-9,7}
    else
        --bw
        -- colors = { 0, 5, 13, 6, 7 }
        colors =   {0,-11,5,13,-10,6,7}
    end

    for i = 1, #colors do
        pal(i, colors[i],1)
        colors[i] = i
    end

    --declaration of bayer matrix shades
    shades = {
        0x0001,0x0401,0x0405,0x0505,
        0x0525,0x8525,0x85a5,0xa5a5,
        0xa5a7,0xada7,0xadaf,0xafaf,
        0xafbf,0xefbf,0xefff,0xffff
    }
end

function set_color(n)
    --takes a value between 0 and 1 and sets the color accordingly
    if (n == nil) then
        return
    end
    dither_steps = ((#colors-1)* #shades)
	n = flr(n * dither_steps)
	if (n >= dither_steps) then
		n = dither_steps - 1
	end
	local si = n % #shades
	local ci = flr( n / #shades ) + 1

	-- printh("ci:"..ci.."\tn:"..n,"experiment/log.txt",false)
	color(colors[ci]+16*(colors[ci+1]))
	fillp(shades[si+1])

end


function shade_lut(new_limit, exp, inverted)
    local lut = {}
    for i = 0, new_limit do
        -- local n = (i/new_limit)^exp
        local n
        if inverted == false then
            n = (2/((i/new_limit)^(exp/100)+1)-1)
        else
            n = 1 - (2/((i/new_limit)^(exp/100)+1)-1)
        end
        add(lut, n)
        -- printh("i:"..i.."\tn:"..n,"experiment/log.txt",false)
    end
    return lut
end

function lut_menu()
    menuitem(4, "exp: "..exp/100,
        function(b)
            if (b&1>0) then
                exp -= 5
            elseif (b&2>0) then
                exp += 5
            end
            if (exp > 1000) then
                exp = 1000
            elseif (exp < 5) then
                exp = 5
            end
            -- exp = flr(exp*100)/100
            lut = shade_lut(limit, exp, invert)
            menuitem(4, "exp: "..exp/100)
            if (b&32) then
                frac_counter = 0
                if (lod == 4) then
                    lod = 3
                end
                return false
            end
            return true
        end)
end

function shade_menu()
    local gradients = {"b/w", "red", "blue", "green"}
    menuitem(2, "palette: "..gradients[shade+1],
        function(b)
            if (b&1>0) then
                shade -= 1
                if (shade < 0) then
                    shade = 3
                end
            elseif (b&2>0) then
                shade += 1
                if (shade > 3) then
                    shade = 0
                end
            end
            gradient_init(shade)
            frac_counter = 0
            if (lod == 4) then
                lod = 3
            end
            if (b&32>0) then
                return false
            end
            menuitem(2, "palette: "..gradients[shade+1])
            return true
        end)
end

function invert_msg(bool)
    if (bool) then
        string = "<standard>"
    else
        string = ">inverted<"
    end
    return string
end

function invert_menu()

    menuitem(5, invert_msg(invert), function(b)
            if (b&1>0) or (b&2>0) then
                invert = not invert
                frac_counter = 0
                lut = shade_lut(limit, exp, invert)
                if (lod == 4) then
                    lod = 3
                end
            end
            menuitem(5, invert_msg(invert))
            if (b&32) then
                return false
            end

            return true
        end)
end




function _init()
    --poke( 0x5f2e, 1 )
    xo = -0.45
    yo =  0.00
    z = 2

    limit = 64
    lod = 1
    frac_counter = 0

    shade = 2
    exp = 65
    invert = true
    gradient_init(shade)
    lut = shade_lut(limit, exp, invert)


    fracs = {1,8,32}
    inc = {4,2,1}

    welcome = true

end

function reset()
    lod = 1
    frac_counter = 0
end


function _update60()
    -- printh("x:"..xo.."\ty:"..yo.."\tz:"..tostr(z,0x3), "experiment/log.txt", true)

    last = time() --last frame time

    shade_menu()

    if time() > 10 then
        welcome = false
    end
    if btn(❘) then
        z += z*0.125
        if z*0.125 == 0 then z += 0x0.0001 end
        reset()
    end
    if btn(🅾️) then
        z -= z*0.125
        if z*0.125 == 0 then z -= 0x0.0001 end
        if z < 0 then z = 0 end
        reset()
    end
    if btn(⬆️) then
        yo -= z/40
        reset()
    end
    if btn(⬇️) then
        yo += z/40
        reset()
    end
    if btn(➡️) then
        xo += z/40
        reset()
    end
    if btn(⬅️) then
        xo -= z/40
        reset()
    end
end

function _draw()
    local lut = lut
    local xo = xo
    local yo = yo
    local z = z
    local limit = limit

    local screen = 127
    local fracs = fracs
    local inc = inc

    limit_menu()
    lut_menu()
    invert_menu()

    if lod < 4 then
        local upper = screen/fracs[lod]*frac_counter
        local lower = screen/fracs[lod]*(frac_counter+1)
        if (frac_counter == fracs[lod]-1) then
            lower = screen+1
        end

        for row = upper,lower,inc[lod] do
            local y = (row/screen-0.5) * z + yo

            for col = 0,screen,inc[lod] do
                local x = (col/screen-0.5) * z + xo

                local n
                if blot(x,y) then
                    n = 0
                    if not invert then
                        n = limit
                    end
                else
                    n = mandelbrot(x,y,limit)
                end

                n = lut[n+1]

                if n==0 then
                    fillp(0x0000)
                    color(0)
                else
                    set_color(n)
                end

                if lod < 3 then
                    rectfill(col,row,col+inc[lod]-1,row+inc[lod]-1)
                else
                    pset(col, row)
                end
            end
        end
        if lod == 1 then
            fillp(0x0000)
            rect(59,62,67,64,0)
            rect(62,59,64,67,0)
            line(60,63,66,63,7)
            line(63,60,63,66,7)
        end

        frac_counter += 1
        if frac_counter == fracs[lod] then
            frac_counter = 0
            lod += 1
        end
    end

    if welcome then
        rectfill(1,1,58,14,0)
        print("move: ⬆️⬇️⬅️➡️\nzoom: +🅾️ -❘",2,2,6)
    end

end





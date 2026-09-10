-- minesweeper special
--by benefitssketch
cartdata("minesweeper-special")
poke(0x5f36,0x2)
celsqr = {
		x = 31,
		y = 24,
		x1 = 31,
		y1 = 24,
		blx = 1,
		bly = 1,
		bounds = 1,
		danger = 0,
		zerosel = false
}

celsqr2 = {}
for i,j in pairs(celsqr) do
  celsqr2[i] = j
end

celsqr2.x1 = 68
celsqr2.y1 = 32

timer = {
  current = 0,
  lap = 0,
  ticks = 0,
  seconds = 0
}

b_info = {}
b_info2 = {}

board_options = {
  classic = {
    len = 8,
		  mines = 10,
		  flags = 10,
		  hints = 0,
		  x2 = 95,
		  x1 = 31,
		  y2 = 87,
		  y1 = 24, 
		  yeller_gap = 2,
		  blx = 3,
		  bly = 2,
		  mapx = 0,
    mapy = 0,
    yeller = {
      x1 = 31,
      y1 = 8,
      x2 = 46,
      y2 = 22
    }
  },
  
  intermediate = {
    len = 12,
		  mines = 20,
		  flags = 20,
		  hints = 0,
		  x2 = 111,
		  x1 = 15,
		  y2 = 119,
		  y1 = 24, 
		  yeller_gap = 2,
		  blx = 1,
		  bly = 17,
		  mapx = 0,
    mapy = 15,
    yeller = {
      x1 = 15,
      y1 = 8,
      x2 = 30,
      y2 = 23
    }
  },
  
  versus = {
    len = 7,
		  mines = 8,
		  flags = 8,
		  hints = 0,
		  x2 = 58,
		  x1 = 4,
		  y2 = 87,
		  y1 = 33, 
		  yeller_gap = 2,
		  blx = 28,
		  bly = 19,
		  mapx = 0,
    mapy = 15,
    yeller = {
      x1 = 15,
      y1 = 8,
      x2 = 30,
      y2 = 23
    }
  },
  
  bomberguy = {len = " ", mines=1},  
  selectname = {len = " ", mines=" "}
  
}

mouse = {
 y = 0,
 x = 0,
 btn = 0,
 bounds = false,
 yellbox = false,
 shortcut = true
}

easter_egg = {
  bros = false,
  tickedyeller = false,
  peppy = false,
  ooo = false
}

menu = {
  main = {
    option = {
    10,
    18,
    40,
    48,
    61,
    //64
    },
		  bly = 1,
    len = 30,
		  y = 128,
		  x = 129,
     
		  settings = false,
		  visible = false,
		  gameselect = false  
  }, 
  eog = {
    option = {
    10,
    17
    },
		  bly = 1,
		  settings = false,
		  gameselect = false 
  },
  vs_eog = {
    option = {
    19,
    26
    },
		  bly = 1,
		  settings = false,
		  gameselect = false 
  },
  nameset = {
    option = {
    10,
    22,
    },
		  bly = 1,
		  settings = false,
		  gameselect = false
  }
}

gamestate = "mainmenu"
gamemode = ""

hiscores = {
  classic = {
    address = {
      0,2,4
    },
    mem_addr = {
      0x5e04,
      0x5e0c,
      0x5e14
    }
  }, 
  intermediate = {
    address = {
      6,8,10
    },
    mem_addr = {
      0x5e1c,
      0x5e24,
      0x5e2c
    }
  },  
  versus = {
	   address = {
	     12,14,16
	   },
	   mem_addr = {
	     0x5e34,
	     0x5e3c,
	     0x5e44
	   }
  },  
  bomberguy = {
    address = {
      18,20,22
    },
    mem_addr = {
      0x5e34,
      0x5e54,
      0x5e5c
    }
  }
}

gamemodes = {
  "classic",
  "intermediate",
  "versus",
  "bomberguy",
  "selectname"
}

mouse_availability = {
  classic = " mouse:\n\-d".."enabled",
  intermediate = " mouse:\n\-d".."enabled",
  versus = " mouse:\n\-b".."disabled",
  bomberguy = " ",
  selectname = " mouse:\n\-b".."disabled"
}

setname = {
  index = 1,
  name = "___",
  chars = {
    95,
    95,
    95  
  }
}

btn_hitbox = { 
  victory = {
    color = 2,
    play_again = {
      overlap = false,
      x1 = 34,
      y1 = 40,
      x2 = 76,
      y2 = 46
    },
    main_menu = {
      overlap = false,
      x1 = 34,
      y1 = 47,
      x2 = 71,
      y2 = 53
    }
  },
  defeat = {
    color = 1,
    play_again = {
      overlap = false,
      x1 = 34,
      y1 = 43,
      x2 = 75,
      y2 = 49
    },
    main_menu = {
      overlap = false,
      x1 = 34,
      y1 = 50,
      x2 = 71,
      y2 = 56
    }
  },
  main_menu = {
    color = 2,
    classic = {
      overlap = false,
      x1 = 21,
      y1 = 62,
      x2 = 49,
      y2 = 68
    },
    intermediate = {
      overlap = false,
      x1 = 21,
      y1 = 70,
      x2 = 69,
      y2 = 76
    },
    versus = {
      overlap = false,
      x1 = 21,
      y1 = 92,
      x2 = 45,
      y2 = 98
    },
    bomberguy = {
      overlap = false,
      x1 = 21,
      y1 = 100,
      x2 = 57,
      y2 = 106
    },
    name = {
      overlap = false,
      x1 = 21,
      y1 = 113,
      x2 = 55,
      y2 = 119
    }
  }
}

board = {}
board2 = {}
board[0] = {}

visboard = {}
visboard2 = {}
zeroes = {}
zeroes2 = {}

cartdat = ""
timescore = 0

function _init()
  cartdat = "called"
  poke(0x5f2d,0x1)
  
  if peek(hiscores.classic.mem_addr[1]) == 0 then
    save_name("ylr",1,"classic")
    dset(hiscores.classic.address[1],979)
    save_name("___",2,"classic")
    dset(hiscores.classic.address[2],954)
    save_name("___",3,"classic")
    dset(hiscores.classic.address[3],910)
  end
  
  if peek(hiscores.intermediate.mem_addr[1]) == 0 then
    save_name("ben",1,"intermediate")
    dset(hiscores.intermediate.address[1],932)
    save_name("ylr",2,"intermediate")
    dset(hiscores.intermediate.address[2],925)
    save_name("___",3,"intermediate")
    dset(hiscores.intermediate.address[3],890)
  end

  //color pallete
  poke(0x5f2e,1)  
  pal(15,0)
  pal(11,15)
  custom_pal = {[0]=0,1,2,136,4,5,6,7,8,9,10,11,12,13,14,15}
  pal(custom_pal,1)
  
  if (flr(rnd(5)) == 3) easter_egg.bros = true
  if (flr(rnd(12)) == 3) easter_egg.tickedyeller = true
  if (flr(rnd(200)) == 50) easter_egg.ooo = true
  if (flr(rnd(100)) == 50) easter_egg.peppy = true; easter_egg.ooo = false
  
  text_access_funcs = {
    ["return_name"] = function()
      return return_name()
    end,
    
    //["play_again"] = highlight_word("play again",btn_hitbox[gamestate].play_again.overlap,btn_hitbox[gamestate].color),
    ["play_again"] = function()
      return highlight_word(
      "play again",
      btn_hitbox[gamestate].play_again.overlap,
      btn_hitbox[gamestate].color
    )
    end,
    
    //["main_menu"] = highlight_word("main menu",btn_hitbox[gamestate].main_menu.overlap,btn_hitbox[gamestate].color)
    ["main_menu"] = function()
      return highlight_word(
      "main menu",
      btn_hitbox[gamestate].main_menu.overlap,
      btn_hitbox[gamestate].color
    )
    end,
    
    ["classic"] = function()
      return highlight_word(
      "classic",
      btn_hitbox.main_menu.classic.overlap,
      btn_hitbox.main_menu.color
    )
    end,
    
    ["intermediate"] = function()
      return highlight_word(
      "intermediate",
      btn_hitbox.main_menu.intermediate.overlap,
      btn_hitbox.main_menu.color
    )
    end,
    
    ["versus"] = function()
      return highlight_word(
      "versus",
      btn_hitbox.main_menu.versus.overlap,
      btn_hitbox.main_menu.color
    )
    end,
    
    ["bomberguy"] = function()
      return highlight_word(
      "bomberguy",
      btn_hitbox.main_menu.bomberguy.overlap,
      btn_hitbox.main_menu.color
    )
    end,
    
    ["name"] = function()
      return highlight_word(
      "name:\-h"..return_name(),
      btn_hitbox.main_menu.name.overlap,
      btn_hitbox.main_menu.color
    )
    end,
    
    ["mouse_availability"] = function()
      return mouse_availability[gamemodes[menu.main.bly]]
    end,
    
    ["board_len"] = function()
      return board_options[gamemodes[menu.main.bly]].len
    end,
    
    ["mines"] = function()
      return board_options[gamemodes[menu.main.bly]].mines
    end
  }
  
  if peek(0x5ec8)>0 then
		  setname.name = ""
		  ..chr(peek(0x5ec8))
		  ..chr(peek(0x5ec9))
		  ..chr(peek(0x5eca))
		  
		  setname.chars = {
				  peek(0x5ec8),
				  peek(0x5ec9),
				  peek(0x5eca)
		  }
  else
    setname.name = "___"
  end
  
  mainmenu_slide = cocreate(menu_slide)
  
		menuitem(1, "main menu",set_main_menu)		
end


function _update()
		if (menu.main.settings) then
		  coresume(mainmenu_slide) 
		end
		
		mouse.y = flr(stat(33))
		mouse.x = flr(stat(32))
  mouse.bly = flr(mouse.y/8)
  mouse.blx = flr(mouse.x/8)
  mouse.btn = stat(34)
  
  btnp1_🅾️ = btnp(🅾️,0)
		btnp2_🅾️ = btnp(🅾️,1)
  
  btnp_🅾️ = btnp(🅾️)
  btnp_❘ = btnp(❘)
  if gamestate == "victory" or gamestate == "defeat" then 
    btn_hitbox[gamestate].play_again.overlap = mouse_bounds(btn_hitbox[gamestate].play_again.x1,btn_hitbox[gamestate].play_again.y1,btn_hitbox[gamestate].play_again.x2,btn_hitbox[gamestate].play_again.y2)
    btn_hitbox[gamestate].main_menu.overlap = mouse_bounds(btn_hitbox[gamestate].main_menu.x1,btn_hitbox[gamestate].main_menu.y1,btn_hitbox[gamestate].main_menu.x2,btn_hitbox[gamestate].main_menu.y2)
    
    if (btnp(⬆️)) then
			   sfx(1,nil,nil,3)
			   if (menu.eog.bly>1) menu.eog.bly -= 1
				end  
		  if (btnp(⬇️)) then
			   sfx(1,nil,nil,3)
						if (menu.eog.bly<#menu.eog.option) then
						  menu.eog.bly += 1 		  
						else	menu.eog.bly = 1 end
				end
				
				if btnp_❘ then
				  if mouse.btn == 1 then		  			    
				    if (btn_hitbox[gamestate].main_menu.overlap) then
				      sfx(1)
				      set_main_menu()		    
				    elseif (btn_hitbox[gamestate].play_again.overlap) then
				      sfx(1)
				      start_game(menu.main.bly,b_info.len)
		        print_board(visboard,b_info.blx,b_info.bly)
				    end
				    mouse.btn = 4
				    btnp_❘ = false
				  end				
				end
				
				if btnp_🅾️ then
		    if menu.eog.bly == 1 then
		      start_game(menu.main.bly,b_info.len)
		      print_board(visboard,b_info.blx,b_info.bly)
		    end
		    if menu.eog.bly == 2 then
		      set_main_menu()
		    end
		    btnp_🅾️ = false
    end		   
    
    if gamestate == "defeat" then
				  yeller.eyes = 108
						yeller.mouth = 124 // o_@
				end
				
				if gamestate == "victory" then
				  yeller.eyes = 72
						yeller.mouth = 80 // 8)
				end
  end
  
  if gamestate == "1_wins" or gamestate == "2_wins" then
    if (btnp(⬆️)) or (btnp(⬆️,2)) then
			   sfx(1,nil,nil,3)
			   if (menu.vs_eog.bly>1) menu.vs_eog.bly -= 1
				end  
		  if (btnp(⬇️)) or (btnp(⬇️,2)) then
			   sfx(1,nil,nil,3)
						if (menu.vs_eog.bly<#menu.vs_eog.option) then
						  menu.vs_eog.bly += 1 		  
						else	menu.vs_eog.bly = 1 end
				end
    
    if btnp1_🅾️ or btnp2_🅾️ then
		    if menu.vs_eog.bly == 1 then
		      start_game(menu.main.bly,b_info.len)						  						  
		      for i,j in pairs(board) do
          board2[i] = j
        end
		      for i,j in pairs(visboard) do
          visboard2[i] = j
        end		      
		      start_game(menu.main.bly,b_info.len)
		      
		      celsqr.blx,celsqr.bly,celsqr.zerosel = 1,1,false
		      celsqr2.blx,celsqr2.bly,celsqr2.zerosel = 1,1,false	      
		    end
		    if menu.vs_eog.bly == 2 then
		      poke(0x5f2d, 3)
		      set_main_menu()
		    end
		    btnp_🅾️ = false
		    btnp1_🅾️ = false
		    btnp2_🅾️ = false
    end
    
  end
  
		if (gamemode == "classic" or gamemode == "intermediate") and gamestate == "playing" then
				tick()
	 		
	 		mouse.bounds = mouse_bounds(b_info.x1,b_info.y1,b_info.x2,b_info.y2)
	 		mouse.yellbox = mouse_bounds(b_info.yeller.x1,b_info.yeller.y1,b_info.yeller.x2,b_info.yeller.y2)
	 		
	 		// btn input interaction
				if btnp_❘ then
				  // reveal space (nouse)
				  if mouse.btn == 1 then
				    if mouse.yellbox then
						    if (timer.seconds<999) yeller.blink = 1; sfx(9)
						    if not yeller.hint then
						      local yellspeech = 1+flr(rnd(8))
						      while (yellspeech == yeller.speech) do
						        yellspeech = 1+flr(rnd(8))
						      end
						      
						      yeller.speech = yellspeech				      
						      yeller.hint = true			      
						      circle_hint("rnd")
						      circle_hint(true)  							    
								  end
				    elseif mouse.bounds then
								  if celsqr.zerosel == true then
								    reveal(mouse.bly-b_info.yeller_gap,mouse.blx-flr(b_info.x1/8))		    
								  else 
									   celsqr.zerosel = true
												first_move(board,mouse.bly-b_info.yeller_gap,mouse.blx-flr(b_info.x1/8),b_info.mines)	
						    end
				    end
				  // set flag
				  else
						  toggle_flag(celsqr.bly,celsqr.blx)
						  end
						  print_board(visboard,b_info.blx,b_info.bly)
				end			
		
				if btnp_🅾️ then
				  // set flag (mouse)
				  if mouse.btn == 2 then
						  if mouse.bounds then
						    toggle_flag(mouse.bly-b_info.yeller_gap,mouse.blx-flr(b_info.x1/8))
						  		print_board(visboard,b_info.blx,b_info.bly)
				    end
				  // reveal space 
				  else			
				    if celsqr.bounds == 0 then	
				      yeller.blink = 1	      
				      if not yeller.hint then
						      local yellspeech = 1+flr(rnd(8))
						      while (yellspeech == yeller.speech) do
						        yellspeech = 1+flr(rnd(8))
						      end
						      
						      yeller.speech = yellspeech				      
						      yeller.hint = true			      
						      circle_hint("rnd")
						      circle_hint(true)  							    
								  end
				    end
				    
						  if celsqr.zerosel == true then
						    reveal(celsqr.bly, celsqr.blx)		    
						  else 
							   celsqr.zerosel = true
										first_move(board,celsqr.bly,celsqr.blx,b_info.mines)			  
						  end
						  print_board(visboard,b_info.blx,b_info.bly)	
						end    
				end
		  
				// btn input movement
				if (btnp(➡️)) then				
					celsqr.blx += 1
				end  
		  if (btnp(⬅️)) then
					celsqr.blx -= 1
				end		
				if (btnp(⬆️)) then
				 celsqr.bly -= 1
				end  
		  if (btnp(⬇️)) then
					celsqr.bly += 1
				end
						
				celsqr.bly,celsqr.blx,celsqr.bounds = check_bounds(celsqr.bly,celsqr.blx,b_info.len,true)
				celsqr.x = (celsqr.blx-1)*8+celsqr.x1
				celsqr.y = (celsqr.bly-1)*8+celsqr.y1
		
				//yeller functions
				if visboard[celsqr.bly][celsqr.blx] then
						if visboard[celsqr.bly][celsqr.blx]>0 and visboard[celsqr.bly][celsqr.blx]<10 then
				    yeller.eyes = 64  
								yeller.mouth = 82 // :o
				  else 
			     yeller.eyes = 64
								yeller.mouth = 80 // :)
						end
				end
		  			
				victory(board,visboard)
				if timer.seconds >= 999 then
				   yeller.snooze += 1
		     if yeller.limit then
				     if yeller.snooze>60 then
				     	 yeller.mouth = 94
		       else
		       	 yeller.mouth = 92
		       end
		       if (yeller.snooze>=90) yeller.snooze=1
						   yeller.eyes = 118
						 else
						 		if yeller.snooze>60 then
				     	 yeller.mouth = 116
		       else
		       	 yeller.mouth = 114
		       end
		       if (yeller.snooze>=90) yeller.snooze=1
						   yeller.eyes = 98
						 end
				end
		end
		
		if gamemode == "versus" and gamestate == "playing" then
		  tick()
		  
		  if btnp1_🅾️ then
				  if celsqr.zerosel == true then
				    vs_reveal(celsqr.bly,celsqr.blx,board,visboard,0,zeroes)
				  else 
					   celsqr.zerosel = true
								vs_first_move(board,visboard,celsqr.bly,celsqr.blx,b_info.mines,0)			  
				  end
				end
				
				if (btnp(❘,0)) then
				  // set flag
				  toggle_flag(celsqr.bly,celsqr.blx)
				end	
				
				if btnp2_🅾️ then
				  if celsqr2.zerosel == true then
				    vs_reveal(celsqr2.bly,celsqr2.blx,board2,visboard2,1,zeroes2)
				  else
					   celsqr2.zerosel = true
								vs_first_move(board2,visboard2,celsqr2.bly,celsqr2.blx,b_info2.mines,zeroes2,1) 
				  end
				end
				
				if (btnp(❘,1)) then
				  // set flag
				  toggle_flag_2(celsqr2.bly,celsqr2.blx)
				end	
		  
		  // btn input movement	  	  
				if (btnp(➡️,0)) then				
					celsqr.blx += 1
				end  
		  if (btnp(⬅️,0)) then
					celsqr.blx -= 1
				end		
				if (btnp(⬆️,0)) then
				 celsqr.bly -= 1
				end  
		  if (btnp(⬇️,0)) then
					celsqr.bly += 1
				end
				
				if (btnp(➡️,1)) then				
					celsqr2.blx += 1
				end  
		  if (btnp(⬅️,1)) then
					celsqr2.blx -= 1
				end		
				if (btnp(⬆️,1)) then
				 celsqr2.bly -= 1
				end  
		  if (btnp(⬇️,1)) then
					celsqr2.bly += 1
				end
				
				celsqr.bly,celsqr.blx,celsqr.bounds = check_bounds(celsqr.bly,celsqr.blx,b_info.len)
				celsqr2.bly,celsqr2.blx,celsqr2.bounds = check_bounds(celsqr2.bly,celsqr2.blx,b_info.len)				
				
				celsqr.x = (celsqr.blx-1)*8+celsqr.x1
				celsqr.y = (celsqr.bly-1)*8+celsqr.y1
				
				celsqr2.x = (celsqr2.blx-1)*8+celsqr2.x1
				celsqr2.y = (celsqr2.bly-1)*8+celsqr2.y1
		  
		  vs_victory(board,visboard,1)
		  vs_victory(board2,visboard2,2)
		end
		
		
		if gamestate == "mainmenu" and gamemode != "selectname" then 
		  if (cartdat == "called") hiscore=dget(1)
    if (bomberguy.start) coresume(bombingguy)
    
    btn_hitbox.main_menu.classic.overlap = mouse_bounds(btn_hitbox.main_menu.classic.x1,btn_hitbox.main_menu.classic.y1,btn_hitbox.main_menu.classic.x2,btn_hitbox.main_menu.classic.y2)
    btn_hitbox.main_menu.intermediate.overlap = mouse_bounds(btn_hitbox.main_menu.intermediate.x1,btn_hitbox.main_menu.intermediate.y1,btn_hitbox.main_menu.intermediate.x2,btn_hitbox.main_menu.intermediate.y2)
    btn_hitbox.main_menu.versus.overlap = mouse_bounds(btn_hitbox.main_menu.versus.x1,btn_hitbox.main_menu.versus.y1,btn_hitbox.main_menu.versus.x2,btn_hitbox.main_menu.versus.y2)
    btn_hitbox.main_menu.bomberguy.overlap = mouse_bounds(btn_hitbox.main_menu.bomberguy.x1,btn_hitbox.main_menu.bomberguy.y1,btn_hitbox.main_menu.bomberguy.x2,btn_hitbox.main_menu.bomberguy.y2)
    btn_hitbox.main_menu.name.overlap = mouse_bounds(btn_hitbox.main_menu.name.x1,btn_hitbox.main_menu.name.y1,btn_hitbox.main_menu.name.x2,btn_hitbox.main_menu.name.y2)
    
		  // btn input
		  if (btnp(⬆️)) then
		    if (menu.main.bly>1) menu.main.bly -= 1; sfx(1,nil,nil,3)
				end  
		  if (btnp(⬇️)) then
			   sfx(1,nil,nil,3)
						if (menu.main.bly<#menu.main.option) then
						  menu.main.bly += 1 		  
						else	menu.main.bly = 1 end
				end
		  
				if btnp(❘) then
				  if (not menu.main.visible) then
				    menu.main.visible = true
				    menu.main.settings = 1
				    poke(0x5f2d,3)
				  elseif mouse.btn == 1 then
				    true_overlaps()
				  end
				end
				 
				if btnp_🅾️ and menu.main.visible then
				  if mouse.btn == 0 then
						  if menu.main.bly <3 then
						    b_info = board_options[gamemodes[menu.main.bly]]
								  
								  start_game(menu.main.bly,b_info.len)						  						  
				
								  if gamemodes[menu.main.bly] == "classic" then
										  celsqr.x1 = 31
										elseif gamemodes[menu.main.bly] == "intermediate" then
										  celsqr.x1 = 15
										end
										celsqr.y1 = 24
										print_board(visboard,b_info.blx,b_info.bly)
						  //versus
						  elseif gamemodes[menu.main.bly] == "versus" then    
						    poke(0x5f2d,0)
						    b_info = board_options[gamemodes[menu.main.bly]]
						    for i,j in pairs(b_info) do
            b_info2[i] = j
          end
          b_info2.x1 = 68
						    
								  start_game(menu.main.bly,b_info.len)						  						  
				      for i,j in pairs(board) do
            board2[i] = j
          end
				      for i,j in pairs(visboard) do
            visboard2[i] = j
          end		      
				      start_game(menu.main.bly,b_info.len)						  						  
          
          celsqr.x1 = 4
          celsqr.y1 = 32
        
        //bomberguy
        elseif gamemodes[menu.main.bly] == "bomberguy" then
						    if not bomberguy.start then
						      bombingguy = cocreate(bomberguy_walk)
						      bomberguy.start = true
						      bomberguy.x = 129
						    end

						  //name
						  elseif gamemodes[menu.main.bly] == "selectname" then
						    gamemode = "selectname"
						    menu.nameset.bly = 1
						    setname.index = 1
						  end
				  end
				end		
							
		end
		
		if gamemode == "selectname" then
		  if (btnp(❘)) then
		   sfx(1,nil,nil,3)
		   if menu.nameset.bly == 1 then
		     menu.nameset.bly = 2
		   else
		     menu.nameset.bly = 1
		   end
				end 
				
				if menu.nameset.bly == 2 and btnp_🅾️ then
				  poke(0x5ec8,setname.chars[1])
				  poke(0x5ec9,setname.chars[2])
				  poke(0x5eca,setname.chars[3])	
				  
				  setname.name = ""
				  ..chr(setname.chars[1])
				  ..chr(setname.chars[2])
				  ..chr(setname.chars[3])
		  			  				  
				  gamemode = ""
				end
		  
		  if menu.nameset.bly == 1 then
				  if btnp(⬆️) then
		      setname.chars[setname.index] +=1
				    if (setname.chars[setname.index] == 96) setname.chars[setname.index] = 97
				  elseif btnp(⬇️) then
				    setname.chars[setname.index] -=1
				    if (setname.chars[setname.index] == 96) setname.chars[setname.index] = 95
				  end
						
						if btnp(➡️) then
		    		setname.index +=1
				  elseif btnp(⬅️) then
				    setname.index -=1
				  end
						
						if setname.index<1 then
		      setname.index = 1
				  end
				  
				  if setname.index>3 then
				    setname.index = 3
				  end
						
						if setname.chars[setname.index] > 122 then
		      setname.chars[setname.index] = 95
				  end
				  if setname.chars[setname.index] < 95 then
				    setname.chars[setname.index] = 122
				  end
				end
				
		end
		
		if timer.seconds >= 999 then
			  if gamestate == "defeat" then
			    yeller.eyes = 118
			  end
		end
		
		if yeller.speech == 2 and yeller.hint then
		  yeller.mouth = 126
		  yeller.eyes = 108		  
		end
		
		if yeller.limit then		  
		  yeller.mouth = 112
		  yeller.eyes = 96	
		  yeller.speech = 10	
		end
		
		if yeller.blink then
		  if yeller.limit then
		    yeller.eyes = 104
		  else yeller.eyes = 118 end
		  
		  yeller.blink += 1
		  if yeller.blink >= 7 then
		    yeller.blink = false
		  end
		end
		
		if easter_egg.peppy then
		  yeller.mouth = 61
		  yeller.eyes = 45
		end
  
end


function _draw()
		cls(0)
		camera(0,0)
				
		if gamestate == "mainmenu" then		  
		  map(25, 0, 0, 0, 20, 20, 0)
		  spr(192,48,34,10,2)
		  if (easter_egg.bros) spr(202,1,32,6,2)
		  cursor(0,0)
    print("PROGRAMMED BY BENEFITSSKETCH",9,10,7)

		  str = "press ❘ to continue"
		  print(str,64-(#str+.5)*2,60,8)		  
		  
		  menu_select(menu_text[gamemodes[menu.main.bly]],51,menu.main.x+71,38,86,9,3,nil,false)
		  menu_select(menu_text[1],51,menu.main.x,69,86,9,2,menu.main.option[menu.main.bly],true)
    
    if (bomberguy.drop) spr(52,bomberguy.bomb,bomberguy.y)
		  
		  if bomberguy.explode then
		    if bomberguy.kaboom<7 then
		      circfill(bomberguy.bomb+3,bomberguy.y+5,bomberguy.kaboom*3,9)
		      circfill(bomberguy.bomb+3,bomberguy.y+5,bomberguy.kaboom*2,7)
		    else
		      circ(bomberguy.bomb+3,bomberguy.y+5,bomberguy.kaboom*3.5-1,7)
		    end
		  end
		  //if bomberguy.kaboom==4 or bomberguy.kaboom==5 then
		  //  cls(7)
		  // end

    spr(bomberanim(),bomberguy.x,bomberguy.y)
    
  elseif gamemode == "classic" or gamemode == "intermediate" then
				
				map(b_info.mapx,b_info.mapy,0, 0, 20, 20, 0)
		  yeller_eyes(yeller.eyes)
			 yeller_mouth(yeller.mouth)
			 
		  local digitformat = sub("00"..timer.seconds,-3)		
				local flagformat = sub("00"..b_info.flags,-3)	
				print(digitformat,b_info.x2-28,b_info.y1-6,7)
				print(flagformat,b_info.x2-12,b_info.y1-6,7)
				
				if celsqr.bounds == 1 then
				  rect(celsqr.x,celsqr.y,celsqr.x+8,celsqr.y+8,7)
    else
				  rect(celsqr.x,celsqr.y+8,celsqr.x+17,celsqr.y-9,7)
				end
				
				rect(b_info.x1-2,b_info.y1-16-3,b_info.x2+2,b_info.y2+3,6)
				rect(b_info.x1-3,b_info.y1-16-4,b_info.x2+3,b_info.y2+4,6)
	
				rectfill(b_info.x1+19,b_info.y1-18,b_info.x2-33,b_info.y1-2,6)
				rectfill(b_info.x1+19,b_info.y1-18,b_info.x2+1,b_info.y1-11,6)
				
				print("flags:", b_info.x2-22, b_info.y1-16, 13)		
				
				if timer.seconds < 999 then
				  circle_hint(nil)
				end				
			 
		  //spr(39,60,61,2,2)
    if not easter_egg.ooo then
				  if timer.seconds >= 999 then	     
				     speech_bubble("$\-h\|czzz",b_info.x1+18,b_info.y1-23,3,-0.5,false)
				  else
						  if yeller.hint then
						    if easter_egg.peppy then
						      speech_bubble(yeller_hints[13],b_info.x1+19,b_info.y1-25,nil,nil,false)
							   elseif yeller.speech == 2 then
							     speech_bubble(yeller_hints[2],b_info.x1+18,b_info.y1-25,nil,nil,false)
							   else
							     speech_bubble(yeller_hints[yeller.speech],b_info.x1+19,b_info.y1-25,nil,nil,false)
							   end					   
							 end
					 end
				end
			 
			 if easter_egg.ooo then
			   spr(25,b_info.x1-2,b_info.y1-26,3,3)
			   line(b_info.x1-2,b_info.y1-2,b_info.x1+21,b_info.y1-2,7)
			 end
		  
		end
		
		if gamemode == "versus" then
		  map(28,16)
		  print_board_ex(visboard,b_info.x1+1,b_info.y1-1)
		  print_board_ex(visboard2,b_info2.x1+1,b_info2.y1-1)
		  
		  rect(celsqr.x,celsqr.y,celsqr.x+8,celsqr.y+8,7)
		  rect(celsqr2.x,celsqr2.y,celsqr2.x+8,celsqr2.y+8,7)		
		
				rect(b_info.x1-2,b_info.y1-12,b_info.x1+58,b_info.y1+57,6)
				rect(b_info.x1-3,b_info.y1-13,b_info.x1+59,b_info.y1+58,6)
	   
	   rect(b_info2.x1-2,b_info2.y1-12,b_info2.x1+58,b_info2.y1+57,6)
				rect(b_info2.x1-3,b_info2.y1-13,b_info2.x1+59,b_info2.y1+58,6)
	   
				rectfill(b_info.x1-1,b_info.y1-12,b_info.x1+39,b_info.y1-3,6)
				rectfill(b_info2.x1+17,b_info2.y1-12,b_info2.x1+39,b_info2.y1-3,6)
				//rectfill(b_info.x1+19,b_info.y1-18,b_info.x2+1,b_info.y1-11,6)
    
    local digitformat = sub("00"..timer.seconds,-3)	
    ? digitformat,b_info2.x1+3,b_info.y1-7,7
    
				local flagformat = sub("00"..b_info.flags,-3)	
				local flagformat2 = sub("00"..b_info2.flags,-3)				
				? flagformat,b_info.x1+44,b_info.y1-7,7
				? flagformat2,b_info2.x1+44,b_info.y1-7,7
				//print(digitformat,b_info.x2-12,b_info.y1-6,7)
    
		end
		
		if gamemode == "selectname" then
		  //rectfill(30,41,108,124,0)  
		  menu_select(menu_text[5],41,30,78,64,1,0,menu.nameset.option[menu.nameset.bly],true)
		  rect(29,41,109,105,7)
		  //rect(40,63,71,71,7)
		  
		  print(chr(setname.chars[1]),42,53) 
    print(chr(setname.chars[2]),47,53)
    print(chr(setname.chars[3]),52,53)
		  
		  spr(177,40+(5*(setname.index-1)),59)
		end
			
	 if gamestate == "victory" then
    menu_select(menu_text[3],29,28,70,75,nil,2,menu.eog.option[menu.eog.bly],true)
    spr(162,36,30,7,1)  
  end
  
  if gamestate == "defeat" then  
    menu_select(menu_text[4],32,28,70,60,nil,1,menu.eog.option[menu.eog.bly],true)
    spr(184,83,29)
    spr(178,36,33,6,1)
  end
  
  if gamestate == "1_wins" then  
    menu_select(menu_text[6],18,36,58,84,nil,2,menu.vs_eog.option[menu.vs_eog.bly],true)
    spr(231,40,19,6,1)
    spr(247,84,19)
    spr(249,49,28,4,1)
  end
  
  if gamestate == "2_wins" then  
    menu_select(menu_text[6],18,36,58,84,nil,2,menu.vs_eog.option[menu.vs_eog.bly],true)
    spr(231,40,19,6,1)
    spr(248,83,19)
    spr(249,49,28,4,1)
  end
  
  if easter_egg.peppy then
  if gamemode == "classic" or gamemode == "intermediate" then
    pset(b_info.x1,b_info.y1-15,10)
    pset(b_info.x1,b_info.y1-16,10)
  end
  end
  
  //alternative cursor; a circle
  //circfill(stat(32), stat(33), 2, 7)
  if stat(32)>0 or stat(33)>0 then
    spr(161,stat(32), stat(33))
  end
  
  if gamestate == "coverart" then
    map(60,8)
    spr(192,48,18,10,2)
		  
				rect(31-2,57-16-4,93+4,119+3,6)
				rect(31-3,57-16-5,93+5,119+4,6)
	
				rectfill(31+19,57-19,93-31,54,6)
				rectfill(31+19,57-19,93+4,45,6)
    
    spr(186,51,37,4,1)
    spr(106,52,46)
    line(55,36,78,36,7)
    line(55,45,78,45,7)
    ? "s \-ieep\-f!",55,39,0
  end
  //? stat(32).." "..stat(33).." "..stat(34)
end
-->8
-- board functions --

function preset_game(len)
  debug = len
		celsqr.blx,celsqr.bly = 1,1
		reset_arrays(len)
		board[0] = {}
		board[0][0] = 15
end

function reset_arrays(len)
  board={}
  visboard={}
  zeroes={}
  zeroes2={}
  
  for y=1, len do
		  board[y] = {}
		  for x=1, len do
		    board[y][x] = 0
		  end
		end
		
		for y=1, len do
		  visboard[y] = {}
		  for x=1, len do
		    visboard[y][x] = 10
		  end
		end
		
		for y=1, len do
		  zeroes[y] = {}
		  for x=1, len do
		    zeroes[y][x] = true
		  end
		end
		
		for y=1, len do
		  zeroes2[y] = {}
		  for x=1, len do
		    zeroes2[y][x] = true
		  end
		end
		
		visboard[0] = {}
		visboard[0][0] = 15
end

function first_move(sboard,row,col,mines,svisboard)
  svisboard = svisboard or visboard
  init_board(sboard,row,col)
  set_mines(sboard,mines) 
  complete_board(sboard)
  if gamemode != "versus" then
    reveal(row,col)
  else vs_reveal(row,col,sboard,svisboard)
  end
end

function vs_first_move(sboard,svisboard,row,col,mines,player)
  init_board(sboard,row,col)
  set_mines(sboard,mines) 
  complete_board(sboard)
  vs_reveal(row,col,sboard,svisboard,player)
end


// set the position of the starting square
function init_board(sboard,row,col)
  sboard[row][col] = 13
  if (row < #sboard) then
      if col>1 then sboard[row+1][col-1] =13 end
      sboard[row+1][col] =13
      if col<#sboard then sboard[row+1][col+1] =13 end
  end

  if col>1 then sboard[row][col-1] =13 end
  if col<#sboard then sboard[row][col+1] =13 end

  if (row > 1) then
      if col>1 then sboard[row-1][col-1] =13 end
      sboard[row-1][col] =13
      if col<#sboard then sboard[row-1][col+1] =13 end
  end
  return sboard
end


-- \_(?)_/ --
function set_mines(sboard,mines)
  local minesplaced = 0

  while minesplaced < mines do
    local minex = flr(rnd(#sboard)) + 1
    local miney = flr(rnd(#sboard)) + 1

    if sboard[miney][minex] != 9 and sboard[miney][minex] != 13  then
      sboard[miney][minex] = 9
      minesplaced += 1
      
    end
  end
  
  for y=1, #sboard do
  for x=1, #sboard do
  	 if sboard[y][x] == 13 then
  	   sboard[y][x] = 0
  	 end 		
		end
  end
  
  return sboard
end


// set all the cells to their values
// based on their proximity to mines
function complete_board(sboard)
  local celval
  for row=1,#sboard do
  for col=1,#sboard do
    celval = 0
    
    if (sboard[row][col] != 9) then      
      if (row < #sboard) then
          if col>1 and sboard[row+1][col-1] == 9 then celval+=1 end
          if sboard[row+1][col] == 9 then celval+=1 end
          if col<#sboard and sboard[row+1][col+1] == 9 then celval+=1 end
      end

      if col>1 and sboard[row][col-1] == 9 then celval+=1 end
      if col<#sboard and sboard[row][col+1] == 9 then celval+=1 end

      if (row > 1) then
          if col>1 and sboard[row-1][col-1] == 9 then celval+=1 end
          if sboard[row-1][col] == 9 then celval+=1 end
          if col<#sboard and sboard[row-1][col+1] == 9 then celval+=1 end
      end
      sboard[row][col] = celval 
    end   
  end
  end 
  
  sboard[0][0] = 15
  return sboard
end

// reveal all eight spaces surrounding a cell
function reveal_neighbors(row,col,sboard,svisboard) 
	  if (row < #sboard) then
	      if col>1 then 
	        if (svisboard[row+1][col-1] == 11) b_info.flags += 1
	        svisboard[row+1][col-1] = sboard[row+1][col-1] 
	      end
	      
	      if (svisboard[row+1][col] == 11) b_info.flags += 1
	      svisboard[row+1][col] = sboard[row+1][col]
	      
	      if col<#sboard then 
	        if (svisboard[row+1][col+1] == 11) b_info.flags += 1
	        svisboard[row+1][col+1] = sboard[row+1][col+1] 
	      end
	  end
	
	  if col>1 then 
	    if (svisboard[row][col-1] == 11) b_info.flags += 1
	    svisboard[row][col-1] = sboard[row][col-1] 
	  end
	  if col<#sboard then 
	    if (svisboard[row][col+1] == 11) b_info.flags += 1
	    svisboard[row][col+1] = sboard[row][col+1] 
	  end
	
	  if (row > 1) then
	      if col>1 then 
	        if (svisboard[row-1][col-1] == 11) b_info.flags += 1
	        svisboard[row-1][col-1] = sboard[row-1][col-1] 
	      end
	      
	      if (svisboard[row-1][col] == 11) b_info.flags += 1
	      svisboard[row-1][col] = sboard[row-1][col]
	      
	      if col<#sboard then 
	        if (svisboard[row-1][col+1] == 11) b_info.flags += 1
	        svisboard[row-1][col+1] = sboard[row-1][col+1] 
	      end
	  end
	  return svisboard
end

// if a zero cell is in direct proximity to
// another zero cell, reveal that one (and neighbors)
// as well, and so on 
function zero_cascade(row,col,sboard,svisboard,szeroes)
  reveal_neighbors(row,col,sboard,svisboard)
  local looping = true
  szeroes = szeroes or zeroes

  --[[
  this while-loop is essential.
  if a for-loop is used it may 
  sometimes exit even if you 
  set r=1.
  ]]
  while looping do
		  looping = false
		  for r=1, #sboard do
		  for c=1, #sboard do
		  debug=""..r.." "..c..""
		    if svisboard[r][c] == 0 and szeroes[r][c] != 0 then
		      reveal_neighbors(r,c,sboard,svisboard)
		      szeroes[r][c] = 0
		      looping = true
		    end
		  end
		  end
  end
end


function reveal(y,x)
  if board[y][x] != 9 then
    if visboard[y][x] == 11 then
      b_info.flags += 1
    end
		  visboard[y][x] = board[y][x]
    if visboard[y][x] == 0 then
      zero_cascade(y,x,board,visboard)
    end
  else
    gamestate = "defeat"
				circle_hint(false)
		  yeller.hint = false
		  sfx(7)
  end
end

function vs_reveal(y,x,sboard,svis,player)
  
  if sboard[y][x] != 9 then
    if svis[y][x] == 11 then
      b_info.flags += 1
    end
    
		  svis[y][x] = sboard[y][x]
    if svis[y][x] == 0 then
      if player == 1 then
        zero_cascade(y,x,sboard,svis)
      else
        zero_cascade(y,x,sboard,svis,zeroes2)        
      end
    end
  else 
		  gamestate = 1+tonum(not (player ~= 0)).."_wins"
		  if (cartdat == "called") then
		      timescore = 1000 - timer.seconds      
		      update_hiscores()  
		  end
  end
end


function toggle_flag(y,x)
  if visboard[y][x] == 10 then
		  visboard[y][x] = 11
		  b_info.flags -= 1
		elseif visboard[y][x] == 11 then
		  visboard[y][x] = 10		  
		  b_info.flags += 1
		end		
end

function toggle_flag_2(y,x)
  if visboard2[y][x] == 10 then
		  visboard2[y][x] = 11
		  b_info2.flags -= 1
		elseif visboard2[y][x] == 11 then
		  visboard2[y][x] = 10		  
		  b_info2.flags += 1
		end		
end


function print_board(sboard,blx,bly) 
  for r=1, #sboard do
    for c=1, #sboard do
      mset(blx+c,bly+r,sboard[r][c]+1)
    end
  end
end

function print_board_ex(sboard,x,y) 
  for r=1, #sboard do
    for c=1, #sboard do
      spr(sboard[r][c]+1,x+8*(c-1),y+8*(r-1))
    end
  end
end


// is our victory certain?
function victory(sboard,svisboard)
  local win = false
  for r=1, #sboard do
  for c=1, #sboard do 
  
		  if sboard[r][c] == 9 then 
		    if svisboard[r][c] == 11 then	    
		      win = true 
		    else return false
		    end 
		  elseif svisboard[r][c] == 11 then
		    return false
		  end
  end
  end
  
  if win == true then
    //hi-score operations
    if (cartdat == "called") then
      timescore = 1000 - timer.seconds
      update_hiscores()
    end
    
    circle_hint(false)
		  yeller.hint = false
    
    gamestate = "victory"
    sfx(8)
    menu.eog.bly = 1
  end
end

function vs_victory(sboard,svisboard,player)
  local win = false
  for r=1, #sboard do
  for c=1, #sboard do 
  
		  if sboard[r][c] == 9 then 
		    if svisboard[r][c] == 11 then	    
		      win = true 
		    else return false
		    end 
		  elseif svisboard[r][c] == 11 then
		    return false
		  end
  end
  end
  
  if win == true then
    //rhi-score operations
    if (cartdat == "called") then
      timescore = 1000 - timer.seconds      
      vs_update_hiscores()  
    end
  gamestate=player.."_wins"
  menu.eog.bly = 1
  end
end
-->8
-- other functions --

function start_game(y,len)
		preset_game(len)
		//print_board(visboard,b_info.blx,b_info.bly)
		
		b_info.flags = b_info.mines
		menu.eog.bly = 1
		
		yeller.eyes = yeller.default_eyes
		yeller.mouth = yeller.default_mouth
		
		timer.ticks = 0
		timer.seconds = 0
		yeller.hints = 0
		yeller.limit = false
		
		gamestate = "playing"
		gamemode = gamemodes[y]
		
		celsqr.zerosel = false
		blink_hint.counting = false
		easter_egg.peppy = false
		easter_egg.ooo = false
		
		if (flr(rnd(200)) == 50) easter_egg.ooo = true
		if (flr(rnd(100)) == 50) easter_egg.peppy = true; easter_egg.ooo = false

end


function yeller_hint(len)
  local dialogue_index = flr(rnd(8))
  if (call_time - timer.seconds < 12) then
    dialogue_index = 9
  end
  local x = flr(rnd(len))
  local y = flr(rnd(len))
  
  call_time = 1
end


function menu_select(str,y,x,width,height,text_displace,clr,bly,arrow,func)   
  width = width or 50
  height = height or 50
  text_displace = text_displace or 8
  bly = bly or 10
  clr = clr or 0
  
  local text_body = split(str,"$",false)
  
  rectfill(x,y,x+width,y+height,clr)
  rect(x-1,y,x+width+1,y+height)
  
  if (type(func)=="function") func()
  
  //black borders
  line(x,y,x, y+height,0)
  line(x+width, y, x+width, y+height)
   
  cursor(x+text_displace,y)
  color(7)
  
  for n=1,#text_body do     
    
    if text_body[n][1] == "_" then
      local y_pos = peek(0x5f27) + sub(text_body[n],2)
      line(x+2,y_pos,x+width-2,y_pos,7)    
    
    elseif text_body[n][1] == "=" then
      if hiscores[gamemodes[menu.main.bly]] then      
        ? sub(text_body[n],3)..dget(hiscores[gamemodes[menu.main.bly]].address[tonum(text_body[n][2])])
      end  
            
    elseif text_body[n][1] == "?" then
      if hiscores[gamemodes[menu.main.bly]] then
		      local name = ""
		      ..chr(peek(hiscores[gamemodes[menu.main.bly]].mem_addr[tonum(text_body[n][2])]))
		      ..chr(peek(hiscores[gamemodes[menu.main.bly]].mem_addr[tonum(text_body[n][2])]+1)) 
		      ..chr(peek(hiscores[gamemodes[menu.main.bly]].mem_addr[tonum(text_body[n][2])]+2))
		      
		      ? sub(text_body[n],3)..name 
      end
      
    elseif text_body[n][1] == "⧗" then
      ? sub(text_body[n],2)..timescore 
    
    elseif text_body[n][1] == "@" then
      local textl = split(text_body[n],":",false)
      ? textl[2]..text_access_funcs[textl[3]]()
    
    else
      ? text_body[n]
    end
  end
  
  if (arrow) spr(160,x,y+bly)
end


function speech_bubble(text,x,y,widthx,tail,flipx)
  x = x or 0
  y = y or 0
  d = d or 8
  tail = tail or 0
  proto_width = ""
  
  dialogue = split(text,"$")
  for item in all(dialogue) do
    if (#item>#proto_width) then
      proto_width = item
    end
  end
  
  width = widthx or #proto_width
  if (width>15) width = 15
  
  height = #dialogue
  rrectfill(x,y,width*5+2,height*5+2,4,7)
  print(dialogue[1],x+2,y+2,0)
  for u=2, height do
    ? dialogue[u]
  end
 
  spr(106,x+4+tail*4,y+height*5+2,1,1,flipx)
end


function tick()
  if timer.seconds < 999 then
		  timer.ticks += 1
		  if timer.ticks > 30 then
		    timer.seconds += 1
		    timer.ticks = 0
		  end
  end
end


function check_bounds(bly,blx,len,yell)		
		if yell and (bly == 0 and (blx==1 or blx==2)) then
		  return 0,1,0
		else
				if (bly<1) bly += 1
				if (bly>len) bly -= 1		
				if (blx<1) blx += 1	  
				if (blx>len) blx -= 1
		end
		
		return bly,blx,1
end


function mouse_bounds(x1,y1,x2,y2)		
		mouse_x = stat(32)
		mouse_y = stat(33)
		
		if mouse_y<y1 or mouse_y>y2 then
		  return false
		end
		if mouse_x<x1 or mouse_x>x2 then
		  return false
		end 
		
		return true
end

function set_main_menu()
  gamestate = "mainmenu"
  circle_hint(false)
  yeller.hint = false
  yeller.hints = 0
  gamemode = ""
  menu.main.y = 128
  return false
end

function print_game_hiscore()
  print(dget(hiscores[gamemode].address))
  print(chr(peek(hiscores[gamemode].mem_addr)))
  print(chr(peek(hiscores[gamemode].mem_addr+1)))
  print(chr(peek(hiscores[gamemode].mem_addr+2)))
end

function save_name(str,place,gmode)
  local gmode = gmode or gamemode
  table = split(str,"")
  poke(hiscores[gmode].mem_addr[place],ord(table[1]))
  poke(hiscores[gmode].mem_addr[place]+1,ord(table[2]))
  poke(hiscores[gmode].mem_addr[place]+2,ord(table[3]))
end

function update_hiscores()
  if (timescore>dget(hiscores[gamemode].address[3])) then
		  if (timescore>dget(hiscores[gamemode].address[2])) then
		    if (timescore>dget(hiscores[gamemode].address[1])) then       
		      //1st place
		      dset(hiscores[gamemode].address[3],dget(hiscores[gamemode].address[2]))
		      save_name(get_name(2),3)
		      dset(hiscores[gamemode].address[2],dget(hiscores[gamemode].address[1]))
		      save_name(get_name(1),2)
		      dset(hiscores[gamemode].address[1],timescore)
		      save_name(setname.name,1)  
		    else
		      //2nd place
		      dset(hiscores[gamemode].address[3],dget(hiscores[gamemode].address[2]))
		      save_name(get_name(2),3)
		      dset(hiscores[gamemode].address[2],timescore)           
		      save_name(setname.name,2)
		    end
		  else 
		    //3rd place
		    dset(hiscores[gamemode].address[3],timescore) 
		    save_name(setname.name,3)      
		  end
		end
		
end

function get_name(place,gmode)
  local gmode = gmode or gamemode
  str = ""
  ..chr(peek(hiscores[gmode].mem_addr[place]))
  ..chr(peek(hiscores[gmode].mem_addr[place]+1))
  ..chr(peek(hiscores[gmode].mem_addr[place]+2))
  return str
end

function return_name()
  return setname.name
end

function highlight_word(text,bool,col)
  if (bool) then
    return "\#7\f"..col..text
  else
    return "\f7"..text
  end
end

function true_overlaps()
   if btn_hitbox.main_menu.classic.overlap then
     menu.main.bly = 1
     btnp_🅾️ = true
     mouse.btn = 0
   elseif btn_hitbox.main_menu.intermediate.overlap then
     menu.main.bly = 2
     btnp_🅾️ = true
     mouse.btn = 0
   elseif btn_hitbox.main_menu.versus.overlap then
     menu.main.bly = 3   
     btnp_🅾️ = true
     mouse.btn = 0
   elseif btn_hitbox.main_menu.bomberguy.overlap then
     menu.main.bly = 4
     btnp_🅾️ = true
     mouse.btn = 0
   elseif btn_hitbox.main_menu.name.overlap then
     gamemode = "selectname"
     menu.nameset.bly = 1
					setname.index = 1
   end

end

-->8
-- animation --

yeller = {
	eyes = 64,
	mouth = 80,
	blink = false,
	defeault_eyes = 64,
	default_mouth = 80,
	limit = false,
	snooze = 1,
	hint = false,
	hints = 0,
	speech = 0
}

bomberguy = {
  start = false,
  anim = 0,
  x = 129,
  y = 91,
  drop = false,
  bomb = 100,
  explode = false,
  kaboom=0
}

function bomberanim()
  if flr(bomberguy.anim) % 2 == 0 then
    return 51
  else return 50 end
end

function bomberguy_walk()
  bomberguy.kaboom = 1
  for x=1,30 do
    bomberguy.x -= 1
    bomberguy.anim += 0.3
    //if (bomberanim()) sfx(4,nil,nil,1)
    yield()
  end
  
  bomberguy.drop = true
  sfx(3,nil,nil,3)
  for x=1,15 do
    yield()
  end
  
  for x=1,15 do
    bomberguy.x += 0.4
    bomberguy.anim += 0.5
    yield()
  end
  
  for x=1,70 do
    bomberguy.x -= 1.8
    bomberguy.anim += 0.8
    yield()
  end
  
  bomberguy.explode = true
  
  sfx(6)
  for x=1,5 do
    bomberguy.kaboom += 0.7
    yield()
  end
  
  bomberguy.drop = false
  
  for x=1,10 do
    bomberguy.kaboom += 0.7
    yield()
  end
  
  bomberguy.explode = false
  bomberguy.start = false
end


function menu_slide()  
   for i=1, 11 do
     menu.main.x -= 10.7
     yield()
   end
   
   sfx(0,nil,1,3)
   
   for i=1,4 do
     menu.main.x += 2
     yield()
   end
   
   for i=1,6 do
     menu.main.x -= 0.75
     yield()
   end
end


function yeller_eyes(eyes)
  --mset(1, 1, eyes)
  --mset(2, 1, eyes+1)
  spr(eyes,b_info.x1+1,b_info.y1-16,2,1)
end

function yeller_mouth(mouth)
  --mset(1, 2, mouth)
  --mset(2, 2, mouth+1)
  spr(mouth,b_info.x1+1,b_info.y1-8,2,1)
end


function circle_blinking(x,y)
  if blink_hint.circ<8 then
    blink_hint.circ += 0.25
  else
    blink_hint.circ = 0
  end
  
  if flr(blink_hint.circ)<5 then
    spr(39,x,y,2,2)
  end
end

blink_hint = {
  blx = 0,
  bly = 0,
  counting = false,
  timer = 0,
  time = 0
}
function circle_hint(x)
  if x == "rnd" then  
    while (true) do
		    blink_hint.blx = 1+flr(rnd(b_info.len-1))
		    blink_hint.bly = 1+flr(rnd(b_info.len-1))
		    if (visboard[blink_hint.bly][blink_hint.blx]>=10) then
						  return 0
			   end
				end
				
  elseif x != nil and not easter_egg.peppy then
    blink_hint.counting = x
    blink_hint.timer = 0
    blink_hint.time = timer.seconds
    yeller.hints += 1
    return 1
  end
  
  if blink_hint.counting then
    blink_hint.timer += 0.05
  end
  
  if yeller.hints>=7 then
    yeller.limit = true
  end
  
  if (timer.seconds>blink_hint.time+6) then
    blink_hint.counting = false
    blink_hint.timer = 0   
    yeller.hint = false
  end
  
  if visboard[blink_hint.bly][blink_hint.blx] != 0 and (not easter_egg.ooo) then
  if flr(blink_hint.timer)%2 == 1 and not yeller.limit then
    local x1 = (blink_hint.blx-1)*8+b_info.x1 
    local y1 = (blink_hint.bly-1)*8+b_info.y1
    spr(39,x1,y1,2,2)
  end
  end
end
-->8
-- text --

menu_text = {}
yeller_hints = {}

//main menu
menu_text[1] = ""
.."\|i\-dselect gamemode$"
.."_0$"
.."@:\n\|e:classic$"
.."@:\|i:intermediate$"
.."_3$"
.."\|m\-jremix modes$"
.."_0$"
.."@:\n\|e:versus$"
.."@:\|i:bomberguy$"
.."_3$"
//.."\n\|hname:$"
//.."@: \-y\|a:return_name"
.."@: \n\n\|h\|a:name"


//game stats
menu_text["classic"] = ""
.."\|h\-jinfo$"
.."_0$"
.."\|i\-bhi-score\f7$"
.."?1"
.."\-b\|h$" // x-14,y-8
.."=1"
.."\-t\|a$" // x+13,y-6
.."?2"
.."\-b$"
.."=2"
.."\-t\|a$"
.."?3"
.."\-b$"
.."=3"
.."\-t\|a$"
.."_0$"
.."\|j\-bmines$"
.."@:\|a    \-j:mines$"
.."_0$"
.."\|j\-bwidth$"
.."@:\|a    \-j:board_len$"
.."_0$"
//.."\nmouse:$"
.."@:\-c\|i:mouse_availability"
//.."\-t\|a\|a\|a"

menu_text["intermediate"] = menu_text["classic"]

menu_text["versus"] = ""
.."\|h\-jinfo$"
.."_0$"
.."\|i\-bhi-score\f7$"
.."=1 $" // x+13,y-6
.."=2 $"
.."=3 $"
.."_0$"
.."\|j\-bmines$"
.."@:\|a    \-j:mines$"
.."_0$"
.."\|j\-bwidth$"
.."@:\|a    \-j:board_len$"
.."_0$"
//.."\nmouse:$"
.."@:\-c\|i:mouse_availability"
//.."\-t\|a\|a\|a"

//game stats
menu_text["bomberguy"] = ""
.."\|h\-jinfo$"
.."_0$"
.."\|j\-bmines$"
.."@:\|a    \-j:mines$"
.."_0$"

//game stats
menu_text["selectname"] = ""
.."\|h\-jinfo$"
.."_0$"
.."@:\-c\|i:mouse_availability$"
.."_0$"

//victory
menu_text[3] = ""
.."_9$"
.."\n$"
//.."play again$"
.."@:\-h:play_again$"
//.."main menu$"
.."@:\|h\-h:main_menu$"
.."\n\f7game score:$"
.."⧗"
//y+1,x+1, bg white, burgundy
.."\-h\|h\#7\f2$"
//y+2, white
.."\|i\f7"
.."hi-scores:$"
.."?1"
.."\-h\|h\#7\f2$"
.."=1"
//y+1,x+1, bg white, midnight
.."\#7\-t\|a - $"
.."?2"
.."\#7\-h\|i$"
.."=2"
//y+1,x+1, bg white, midnight
.."\#7\-t\|a - $"
.."?3"
.."\#7\-h\|i$"
.."=3"
//y+1,x+1, bg white, midnight
.."\#7\-t\|a - $"

//defeat
menu_text[4] = ""
.."_9$"
.."\n$"
//.."play again$"
.."@:\-h:play_again$"
//.."main menu$"
.."@:\|h\-h:main_menu$"
.."\n\f7hi-scores:$"
.."?1"
.."\-h\|h\#7\f1$"
.."=1"
//y+1,x+1, bg white, midnight
.."\#7\-t\|a - $"
.."?2"
.."\#7\-h\|i$"
.."=2"
//y+1,x+1, bg white, midnight
.."\#7\-t\|a - $"
.."?3"
.."\#7\-h\|i$"
.."=3"
//y+1,x+1, bg white, midnight
.."\#7\-t\|a - $"

menu_text[5] = ""
.."\|i   \-jset\-iyour\-iname$"
.."_0$"
.."\|k$"
.."\n\-p\#7\f0confirm\n\f7$"
.."_9$"
.."_6$"
.."\n\n\-mcLICK\-i❘\-itO\-icHANGE"
.."\n\-ysELECTION$"
.."_1$"

//player ___ wins
menu_text[6] = "$"
.."_12$"
//.."play again$"
.."\n\|p\-hplay again$"
//.."main menu$"
.."\|h\-hmain menu$"
.."\n\f7game score:$"
//y+1,x+1, bg white, burgundy
.."⧗"
.."\-h\|h\#7\f2$"
//y+2, white
.."\|i\f7"
.."hi-scores:$"
.."\-h\|h\f2$"
.."=1"
//y+1,x+1, bg white, midnight
.."\#7\-h\|a$"
.."=2"
//y+1,x+1, bg white, midnight
.."\#7\-h\|i$"
.."=3"
//y+1,x+1, bg white, midnight
.."\#7\-h\|i$"

yeller_hints[1] = ""
.."erm,\-h"
.."i\-ican\-ifeel\-ia\-ilot$"
.."of\-ibad\-ivibes\-ithere.$"

yeller_hints[2] = ""
.."\-h"
.."do"
.."\-h\|g\#7\^w\^t"
.."not"
.."\^-w\^-t\^#\|g"
.."select$ "
.."\-z\-r\|a"
.."that\-icell!$"

yeller_hints[3] = ""
.."there's\-jlike\-ja\-j3/20$"
.."\-fchance\-jthat'\-fs\-ja\-jmine$"

yeller_hints[4] = ""
.." that couldn'\-ft$" 
.." be a mine...$"

yeller_hints[5] = ""
.."i'm gettin'\-ia good$"
.."feeling from there.$"

yeller_hints[6] = ""
.." that things'\-hgot$"
.." an evil aura.$"

yeller_hints[7] = ""
.." that's safe,$"
.." i know it.$"

yeller_hints[8] = ""
.." that's scary,$"
.." i'm sure of it.$"

yeller_hints[9] = ""
.."you better stop botherin'$"
.."me bub.$"

yeller_hints[10] = ""
.." you need a lot of$"
.." hints,\-ihuh.$"

yeller_hints[11] = ""
.."you are literally only$"
.."getting one point.$"

yeller_hints[13] = ""
.." \|ido a barrel roll$"
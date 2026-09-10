-- suikatris (game boy style)
-- tetris x suika mashup

cols=10
rows=18
cellpx=7
wallw=6 -- largeur des murs decoratifs de chaque cote du plateau
bx=4+wallw
by=2
panely=8

-- niveaux 1 et 2 : formes invariantes par rotation (case unique, carre
-- 2x2), volontairement laissees telles quelles -- tourner un carre ne
-- change rien. a partir du niveau 3, les formes sont asymetriques
-- (largeur != hauteur, look "piece de tetris") : la rotation les fait
-- vraiment passer d'une orientation "couchee" a une orientation
-- "debout", donc tourner une piece a un interet concret des le debut
-- de partie.
shapes={
 [1]={c={{0,0}},col=8},
 [2]={c={{0,0},{1,0},{0,1},{1,1}},col=14},
 [3]={c={{0,0},{1,0},{1,1},{2,1}},col=2}, -- Z
 [4]={c={{1,0},{2,0},{0,1},{1,1}},col=9}, -- S
 [5]={c={{1,0},{0,1},{1,1},{2,1}},col=4}, -- T
 [6]={c={{0,0},{0,1},{1,1},{2,1}},col=10}, -- J
 [7]={c={{2,0},{0,1},{1,1},{2,1}},col=3}, -- L
 [8]={c={{0,0},{1,0},{2,0},{3,0}},col=11}, -- I
}
maxlvl=8

-- sprite ids for each block level (1..8)
-- ces sprites vivent en ligne 3 de la feuille de sprites (sprites
-- 32-39) et sont deja dessines dans le __gfx__ de cette cartouche.
-- sprite 40 est utilise comme frame de "flash" pour les blocs maxlvl.
blocksprite={}
for i=1,maxlvl do blocksprite[i]=31+i end
flashsprite=31+maxlvl+1

board={}
blobs={}
nextid=1
cur=nil
holdlvl=nil
canhold=true
nextlvl=1
score=0
gstate="menu"
fallt=0
falldelay=20
diflvl=0
startlvl=0
menustep=1
shake=0
flash=0
musicon=false
pdrop=false
grav=true
survivalt=0
particles={}
morphanim={}
droptrail={}
landanim={}
pendingmerge={}
pendingclearrows=nil
flashframes=6 -- nb de frames (60fps) pendant lesquelles une pi??ce clignote en blanc avant d'exploser
lineflashframes=12 -- idem, mais pour le flash multicolore d'une ligne complete avant sa purge (200ms a 60fps)
lockt=0
lockdelay=18
das=0
dasinitial=5
dasrepeat=1
settling=false
settlet=0
settledelay=2
overstep=1
overanim=0
menuanim=0
controlsanim=0
transt=0
translen=20
transfrom="menu"
deathparts={}
deatht=0
deathlen=42
hiscore=0
levelbag={}
lockresets=0
maxlockresets=15
cartdata("suikatris_v1")
hiscore=dget(0)
if hiscore>1000 then
 hiscore=flr(hiscore/10)
 dset(0,hiscore)
end

-- effets "vivants" additionnels
besttier=0       -- meilleur niveau de fusion atteint cette partie (jauge evo)
evopulse=0       -- frames restantes de pulse sur la jauge evo
scorepop=0       -- frames restantes de pop sur le score (evenements notables uniquement)
combochain=0     -- longueur du combo en cours (pour le pitch du son de fusion)
menuselY=60      -- position animee du selecteur de menu (lerp)
menuselsq=0      -- frames restantes de l'anim "squash" du selecteur
prevmenustep=1
menurowy={60,70,80,90,100} -- y de chaque ligne du menu (doit matcher drawmenu)

function tonecolor(lvl)
 if lvl>=maxlvl then
  return (flr(t()*2)%2==0) and shapes[lvl].col or 3
 end
 return shapes[lvl].col
end

function copycells(c)
 local nc={}
 for p in all(c) do add(nc,{p[1],p[2]}) end
 return nc
end

function shapewh(cells)
 local mw,mh=0,0
 for c in all(cells) do
  if c[1]+1>mw then mw=c[1]+1 end
  if c[2]+1>mh then mh=c[2]+1 end
 end
 return mw,mh
end

-- tourne une liste de cellules de 90?? dans le sens horaire, ancrees en
-- (0,0). comme les formes sont asymetriques (largeur != hauteur), une
-- boite mw x mh devient une boite mh x mw : la piece change vraiment
-- d'encombrement, contrairement a une forme ronde/carree.
function rotatecells(cells)
 local mw,mh=shapewh(cells)
 local nc={}
 for c in all(cells) do
  add(nc,{mh-1-c[2],c[1]})
 end
 return nc
end

function fits(cells,ox,oy)
 for c in all(cells) do
  local x=ox+c[1]
  local y=oy+c[2]
  if x<0 or x>=cols or y>=rows then return false end
  if y>=0 and board[x][y] then return false end
 end
 return true
end

function resty(cells,ox)
 if not fits(cells,ox,0) then return nil end
 local oy=0
 while fits(cells,ox,oy+1) do oy=oy+1 end
 return oy
end

function dropfrom(cells,ox,oy)
 while fits(cells,ox,oy+1) do oy=oy+1 end
 return oy
end

-- systeme de "sac" pondere : au lieu de tirer chaque piece de facon
-- totalement independante (ce qui peut donner de longues sequences
-- malchanceuses), on remplit un sac avec un nombre fixe d'occurrences
-- de chaque niveau puis on le pioche sans remise, en le rechargeant
-- une fois vide. la ponderation depend de diflvl : plus la difficulte
-- est haute, moins il y a de petites pieces faciles (niveau 1) et
-- plus il y a de grosses formes encombrantes (niveaux 3-5).
function fillbag()
 local w1=max(2,7-diflvl)
 local w2=5
 local w3=4+flr(diflvl/3)
 local w4=2+flr(diflvl/3)
 local weights={{1,w1},{2,w2},{3,w3},{4,w4}}
 levelbag={}
 for w in all(weights) do
  for i=1,w[2] do add(levelbag,w[1]) end
 end
 -- melange (fisher-yates)
 for i=#levelbag,2,-1 do
  local j=flr(rnd(i))+1
  levelbag[i],levelbag[j]=levelbag[j],levelbag[i]
 end
end

function randlvl()
 if #levelbag==0 then fillbag() end
 return deli(levelbag,1)
end

-- forcelvl : si fourni, on fait apparaitre ce niveau precis (utilise
-- par le hold) au lieu de piocher dans le sac.
function spawn(forcelvl)
 local lvl
 if forcelvl then
  lvl=forcelvl
 else
  lvl=nextlvl
  nextlvl=randlvl()
 end
 local cells=copycells(shapes[lvl].c)
 local mw,mh=shapewh(cells)
 local ox=flr((cols-mw)/2)
 local oy=0
 -- if the top of the stack blocks the piece, let it peek in from above
 -- the visible board instead of instantly ending the game
 while oy>-mh and not fits(cells,ox,oy) do
  oy=oy-1
 end
 if not fits(cells,ox,oy) then
  triggerdeath()
  return
 end
 cur={lvl=lvl,cells=cells,x=ox,y=oy}
 das=0
 lockt=0
 lockresets=0
 -- truly topped out: the piece can't even fall from its lifted spawn spot
 if oy<0 and not fits(cur.cells,cur.x,cur.y+1) then
  cur=nil
  triggerdeath()
 end
end

-- tourne la piece courante de 90??. comme la boite englobante change
-- de dimensions (piece couchee <-> piece debout), on recentre la piece
-- sur son ancienne position puis on essaie quelques petits decalages
-- ("kicks", a la SRS) si ca ne rentre pas tel quel -- contre un mur,
-- au sol, ou contre un autre bloc.
function tryrotate()
 if not cur then return end
 local rotated=rotatecells(cur.cells)
 local mw,mh=shapewh(cur.cells)
 local nw,nh=shapewh(rotated)
 local basex=cur.x+flr((mw-nw)/2)
 local basey=cur.y+flr((mh-nh)/2)
 local kicks={{0,0},{-1,0},{1,0},{-2,0},{2,0},{0,-1},{-1,-1},{1,-1}}
 for k in all(kicks) do
  local nx,ny=basex+k[1],basey+k[2]
  if fits(rotated,nx,ny) then
   cur.cells=rotated
   cur.x=nx
   cur.y=ny
   if lockresets<maxlockresets then lockt=0 lockresets=lockresets+1 end
   sfx(0) -- reutilise le son de deplacement lateral (pas de sfx dedie a la rotation)
   return
  end
 end
end

-- garde une piece de cote pour plus tard. la premiere fois, elle
-- prend juste la place de la piece courante (qui reapparaitra a la
-- prochaine utilisation du hold) ; ensuite ca echange les deux. un
-- seul hold est autorise par piece posee (canhold), pour eviter de
-- pouvoir swapper a l'infini pour "voir a travers" le sac.
function tryhold()
 if not cur or not canhold then return end
 local curlvl=cur.lvl
 if holdlvl==nil then
  holdlvl=curlvl
  spawn()
 else
  local swaplvl=holdlvl
  holdlvl=curlvl
  spawn(swaplvl)
 end
 canhold=false
 sfx(5)
end

function triggerdeath()
 gstate="dying"
 deatht=0
 deathparts={}
 for x=0,cols-1 do
  for y=0,rows-1 do
   local c=board[x][y]
   if c then
    add(deathparts,{
     x=bx+x*cellpx,y=by+y*cellpx,
     dx=rnd(1.2)-0.6,        -- 60fps: vitesse/frame divis??e par 2 (??tait rnd(2.4)-1.2)
     dy=-rnd(1.25)-0.25,     -- 60fps: vitesse/frame divis??e par 2 (??tait -rnd(2.5)-0.5)
     col=tonecolor(c.lvl),
     spin=rnd(1)-0.5,
     life=deathlen+flr(rnd(14))
    })
   end
  end
 end
 shake=min(40,shake+40)
 flash=14
 sfx(4)
 sfx(14)
 music(-1)
 if score>hiscore then
  hiscore=score
  dset(0,hiscore)
 end
end

function removeblob(id)
 local b=blobs[id]
 if not b then return end
 for c in all(b.cells) do board[c[1]][c[2]]=nil end
 blobs[id]=nil
end

function makepop(cx,cy,col,count)
 count=count or 14
 col=col or 11
 for i=1,count do
  -- 60fps: dx/dy divis??s par 2 (??taient rnd(6)-3 et rnd(6)-3.5) car
  -- ajout??s ?? la position ?? chaque frame, deux fois plus souvent
  add(particles,{x=bx+cx*cellpx+cellpx/2,y=by+cy*cellpx+cellpx/2,dx=rnd(3)-1.5,dy=rnd(3)-1.75,life=26,col=(i%2==0) and 0 or col})
 end
end

-- suivi du meilleur niveau atteint (fait avancer la jauge evo)
function notetier(lvl)
 lvl=min(lvl,maxlvl)
 if lvl>besttier then
  besttier=lvl
  evopulse=20
 end
end

-- phase 1: detect a merge and mark the involved blobs as "exploding"
-- so they render a one-frame white flash (see drawcell) before the
-- actual merge is carried out one frame later by domerge().
function checkmerge(id)
 local b=blobs[id]
 if not b then return end
 if b.exploding then return end
 local seen={}
 local found={}
 for c in all(b.cells) do
  local nb={{c[1]+1,c[2]},{c[1]-1,c[2]},{c[1],c[2]+1},{c[1],c[2]-1}}
  for n in all(nb) do
   local nx,ny=n[1],n[2]
   if nx>=0 and nx<cols and ny>=0 and ny<rows then
    local o=board[nx][ny]
    if o and o.id!=id and not seen[o.id] then
     seen[o.id]=true
     if blobs[o.id] and blobs[o.id].lvl==b.lvl then add(found,o.id) end
    end
   end
  end
 end
 if #found==0 then return end
 for fid in all(found) do
  if blobs[fid] and blobs[fid].exploding then return end
 end
 local sx,sy,n=0,0,0
 for c in all(b.cells) do sx=sx+c[1] sy=sy+c[2] n=n+1 end
 for fid in all(found) do
  local fb=blobs[fid]
  for c in all(fb.cells) do sx=sx+c[1] sy=sy+c[2] n=n+1 end
 end
 local cx=flr(sx/n+0.5)
 local cy=flr(sy/n+0.5)
 b.exploding=true
 for fid in all(found) do blobs[fid].exploding=true end
 add(pendingmerge,{id=id,found=found,cx=cx,cy=cy,wait=flashframes})
end

-- phase 2: actually removes the exploding blobs and spawns the
-- merged/upgraded blob, then checks for cascading merges.
function domerge(e)
 local id,found,cx,cy=e.id,e.found,e.cx,e.cy
 local b=blobs[id]
 if not b then return end
 removeblob(id)
 for fid in all(found) do removeblob(fid) end
 -- retirer des blocs du plateau peut priver d'autres blocs, ailleurs,
 -- de leur support (ils reposaient peut-etre sur ceux qu'on vient de
 -- fusionner) : on force une nouvelle passe de gravite/glissement pour
 -- que tout ce qui doit retomber retombe, meme si la fusion se
 -- resout apres la fin de la phase de "settling" initiale.
 settling=true
 settlet=0
 local newlvl=b.lvl+1
 if newlvl>maxlvl then
  -- deux pasteques entrent en collision : effet ultime
  score=score+50
  combochain=combochain+1
  sfx(11)
  makepop(cx,cy,7,24)
  makepop(cx,cy,10,44)
  shake=min(40,shake+35)
  flash=10
  notetier(maxlvl)
  scorepop=18
  return
 end
 local cells=shapes[newlvl].c
 local mw,mh=shapewh(cells)
 local ox=mid(0,cx-flr(mw/2),cols-mw)
 local oy0=mid(0,cy-flr(mh/2),rows-mh)
 local oy=nil
 if fits(cells,ox,oy0) then
  oy=dropfrom(cells,ox,oy0)
 else
  for d=1,rows do
   if oy==nil and oy0+d<=rows-mh and fits(cells,ox,oy0+d) then oy=oy0+d end
   if oy==nil and oy0-d>=0 and fits(cells,ox,oy0-d) then oy=oy0-d end
   if oy then break end
  end
  if oy then oy=dropfrom(cells,ox,oy) end
 end
 if not oy then
  score=score+20
  sfx(3)
  combochain=combochain+1
  makepop(cx,cy,shapes[newlvl].col,18)
  notetier(newlvl)
  return
 end
 local newid=nextid
 nextid=nextid+1
 local ncells={}
 for c in all(cells) do
  local x=ox+c[1]
  local y=oy+c[2]
  board[x][y]={id=newid,lvl=newlvl}
  add(ncells,{x,y})
 end
 blobs[newid]={lvl=newlvl,cells=ncells}
 morphanim[newid]={t=0,maxt=6}
 score=score+10*newlvl
 combochain=combochain+1
 notetier(newlvl)
 if newlvl==maxlvl then
  -- pasteque obtenue : son et effet speciaux
  sfx(10)
  makepop(cx,cy,shapes[newlvl].col,10)
  makepop(cx,cy,7,20)
  shake=min(28,shake+16)
  flash=5
  scorepop=18
 else
  local mergesfx={2,15,16}
  sfx(mergesfx[min(combochain,3)])
  makepop(cx,cy,shapes[newlvl].col,8+newlvl*3)
  if newlvl>=maxlvl-2 then
   shake=min(24,shake+8)
  end
 end
 checkmerge(newid)
end

-- runs the merges that finished their white flash countdown.
-- entries whose flash isn't done yet stay queued (and keep drawing
-- white, since their blobs are still marked "exploding").
function processpendingmerges()
 if #pendingmerge==0 then return end
 local todo=pendingmerge
 pendingmerge={}
 for e in all(todo) do
  e.wait=e.wait-1
  if e.wait<=0 then
   domerge(e)
  else
   add(pendingmerge,e)
  end
 end
end

function spawndroptrail(piece,oldy)
 local dy=piece.y-oldy
 if dy<=0 then return end
 local len=min(dy,2)
 for c in all(piece.cells) do
  for s=1,len do
   add(droptrail,{x=piece.x+c[1],y=piece.y+c[2]-s,t=0,maxt=5})
  end
 end
end

function applygravity()
 if not grav then return false,{} end
 local movedany=false
 local movedids={}
 for id,b in pairs(blobs) do
  local can=true
  for c in all(b.cells) do
   local ny=c[2]+1
   if ny>=rows then can=false break end
   local o=board[c[1]][ny]
   if o and o.id!=id then can=false break end
  end
  if can then
   for c in all(b.cells) do board[c[1]][c[2]]=nil end
   for c in all(b.cells) do c[2]=c[2]+1 end
   for c in all(b.cells) do board[c[1]][c[2]]={id=id,lvl=b.lvl} end
   movedany=true
   movedids[id]=true
  end
 end
 return movedany,movedids
end

function applyslide()
 -- regle maison : plus de glissement lateral automatique fa??on
 -- suika (une piece bloquee reste exactement ou elle s'est posee,
 -- meme si un trou plus bas existe ailleurs sur le plateau). ca
 -- rendait le jeu trop facile, donc on desactive completement le
 -- mecanisme en retournant tout de suite "rien n'a glisse".
 return false,{}
end

-- soupape de securite : contrairement au suika pur, ce jeu n'avait
-- aucun moyen de vider le plateau autrement que par une fusion. si
-- une ligne entiere est occupee (peu importe les niveaux en presence),
-- on la retire et on fait descendre tout ce qui est au-dessus, comme
-- un vrai "line clear" de tetris, avec un bonus de score. le clear se
-- fait en deux temps (comme les fusions) : detection -> flash
-- multicolore de lineflashframes frames (100ms a 60fps) -> suppression
-- reelle, pour bien signaler ce qui se passe sans utiliser le flash
-- plein ecran deja utilise ailleurs.
function findfullrow()
 -- regle maison : les lignes completes ne sont plus purgees (sinon
 -- ce serait trop facile). on desactive la detection en retournant
 -- systematiquement nil ; le reste du pipeline de clear (flash,
 -- docleared, score) reste en place mais n'est simplement jamais
 -- declenche.
 return nil
end

-- les listes de cellules des blobs sont reconstruites a partir du
-- plateau compacte (elles ne sont que des listes de coordonnees, donc
-- rien d'autre ne depend de leur continuite).
function docleared(e)
 local full,n=e.rows,e.n
 for x=0,cols-1 do
  local col=board[x]
  local newcol={}
  local wp=rows-1
  for y=rows-1,0,-1 do
   if not full[y] then
    newcol[wp]=col[y]
    wp=wp-1
   end
  end
  board[x]=newcol
 end
 for id,b in pairs(blobs) do b.cells={} end
 for x=0,cols-1 do
  for y=0,rows-1 do
   local c=board[x][y]
   if c and blobs[c.id] then add(blobs[c.id].cells,{x,y}) end
  end
 end
 for id,b in pairs(blobs) do
  if #b.cells==0 then blobs[id]=nil end
 end
 score=score+40*n*n
 combochain=combochain+1
 shake=min(30,shake+10*n)
 scorepop=18
end

-- decompte le flash multicolore d'une ligne en attente, puis declenche
-- sa suppression reelle une fois le delai ecoule.
function processpendingclear()
 if not pendingclearrows then return end
 pendingclearrows.wait=pendingclearrows.wait-1
 if pendingclearrows.wait<=0 then
  docleared(pendingclearrows)
  pendingclearrows=nil
  local ids={}
  for bid,_ in pairs(blobs) do add(ids,bid) end
  for bid in all(ids) do
   if blobs[bid] then checkmerge(bid) end
  end
 end
end

function settletick()
 local m,movedids=applygravity()
 local s,slidids=applyslide()
 local bounced={}
 for mid,_ in pairs(movedids) do bounced[mid]=true end
 for mid,_ in pairs(slidids) do bounced[mid]=true end
 local ids={}
 for bid,_ in pairs(blobs) do add(ids,bid) end
 for bid in all(ids) do
  if blobs[bid] then checkmerge(bid) end
 end
 for bid,_ in pairs(bounced) do
  if blobs[bid] then landanim[bid]={t=0,maxt=10} end
 end
 return m or s
end

function lockpiece()
 for c in all(cur.cells) do
  if cur.y+c[2]<0 then
   cur=nil
   triggerdeath()
   return
  end
 end
 local id=nextid
 nextid=nextid+1
 local cells={}
 for c in all(cur.cells) do
  local x=cur.x+c[1]
  local y=cur.y+c[2]
  board[x][y]={id=id,lvl=cur.lvl}
  add(cells,{x,y})
 end
 blobs[id]={lvl=cur.lvl,cells=cells}
 landanim[id]={t=0,maxt=10}
 sfx(1)
 cur=nil
 canhold=true
 combochain=0
 checkmerge(id)
 settling=true
 settlet=0
end

function spawnifneeded()
 if gstate=="play" and cur==nil then spawn() end
end

function prefill()
 if startlvl<=0 then return end
 local rowstofill=min(startlvl,rows-4)
 local fillchance=0.5+0.06*startlvl
 for ry=rows-rowstofill,rows-1 do
  for cx=0,cols-1 do
   if rnd(1)<fillchance then
    local lvl=1+flr(rnd(3))
    local id=nextid
    nextid=nextid+1
    board[cx][ry]={id=id,lvl=lvl}
    blobs[id]={lvl=lvl,cells={{cx,ry}}}
   end
  end
 end
end

function _init()
 board={}
 for x=0,cols-1 do board[x]={} end
 blobs={}
 particles={}
 morphanim={}
 droptrail={}
 landanim={}
 pendingmerge={}
 pendingclearrows=nil
 nextid=1
 score=0
 fallt=0
 lockt=0
 lockresets=0
 nextlvl=1
 fillbag()
 prefill()
 cur=nil
 holdlvl=nil
 canhold=true
 settling=false
 settlet=0
 besttier=0
 evopulse=0
 scorepop=0
 combochain=0
 falldelay=max(6,20-diflvl*2)
 survivalt=0
 if gstate=="menu" then sfx(12) end
end

function gotomenu()
 gstate="menu"
 menuanim=0
 menuselsq=0
 prevmenustep=menustep
 sfx(21) -- retour au menu
 sfx(12)
end

function golaunch()
 transfrom=gstate
 gstate="starting"
 transt=0
 sfx(20) -- confirmation/lancement
 sfx(13)
end

-- _update60 : pico-8 appelle cette fonction 60 fois/seconde au lieu
-- de 30 (au lieu de _update()). Pour que le jeu se comporte
-- EXACTEMENT comme avant (m??me vitesse, juste plus fluide), tous
-- les compteurs qui ??taient incr??ment??s/d??cr??ment??s de 1 par frame
-- (et compar??s ?? un seuil : >, >=, ==, %) passent ?? un pas de 0.5,
-- puisqu'il y a maintenant 2x plus d'appels par seconde -- les
-- seuils eux-m??mes ne changent pas. Les vitesses/acc??l??rations de
-- particules (ajout??es directement ?? une position chaque frame)
-- sont, elles, divis??es par deux ?? la source.
function _update60()
 if shake>0 then shake=shake-0.5 end
 if flash>0 then flash=flash-0.5 end
 if scorepop>0 then scorepop=scorepop-1 end
 if evopulse>0 then evopulse=evopulse-1 end
 if gstate=="menu" then
  menuanim=min(30,menuanim+0.5)
  if btnp(2) then
   menustep=menustep-1
   if menustep<1 then menustep=5 end
   sfx(18) -- navigation curseur menu
  end
  if btnp(3) then
   menustep=menustep+1
   if menustep>5 then menustep=1 end
   sfx(18) -- navigation curseur menu
  end
  if menustep!=prevmenustep then
   menuselsq=8
   prevmenustep=menustep
  end
  if menuselsq>0 then menuselsq=menuselsq-1 end
  menuselY=menuselY+(menurowy[menustep]-menuselY)*0.35
  if menustep==1 then
   if btnp(0) then diflvl=max(0,diflvl-1) sfx(19) end
   if btnp(1) then diflvl=min(9,diflvl+1) sfx(19) end
  elseif menustep==2 then
   if btnp(0) then startlvl=max(0,startlvl-1) sfx(19) end
   if btnp(1) then startlvl=min(5,startlvl+1) sfx(19) end
  elseif menustep==3 then
   if btnp(0) or btnp(1) then pdrop=not pdrop sfx(19) end
  elseif menustep==4 then
   if btnp(0) or btnp(1) then musicon=not musicon sfx(19) end
  end
  -- menustep 5 = controls (handled below)
  if btnp(4) or btnp(5) then
   if menustep==5 then
    gstate="controls"
    controlsanim=0
    sfx(20) -- confirmation/s??lection
   else
    golaunch()
   end
  end
  return
 end
 if gstate=="controls" then
  controlsanim=min(10,controlsanim+0.5)
  if btnp(4) or btnp(5) then gotomenu() end
  return
 end
 if gstate=="starting" then
  transt=transt+0.5
  if transt==flr(translen/2) then
   _init()
   if musicon then music(0) end
   spawn()
  end
  if transt>=translen then gstate="play" end
  return
 end
 if gstate=="dying" then
  deatht=deatht+0.5
  for p in all(deathparts) do
   p.dy=p.dy+0.11   -- 60fps: acc??l??ration divis??e par 2 (??tait 0.22)
   p.x=p.x+p.dx
   p.y=p.y+p.dy
   p.life=p.life-0.5
  end
  if deatht>=deathlen then
   gstate="over"
   overstep=1
   overanim=0
  end
  return
 end
 if gstate=="over" then
  overanim=min(14,overanim+0.5)
  if btnp(2) then
   overstep=overstep-1
   if overstep<1 then overstep=2 end
   sfx(18) -- navigation curseur menu
  end
  if btnp(3) then
   overstep=overstep+1
   if overstep>2 then overstep=1 end
   sfx(18) -- navigation curseur menu
  end
  if btnp(4) or btnp(5) then
   if overstep==1 then
    golaunch()
   else
    gotomenu()
   end
  end
  return
 end
 if pdrop then
  survivalt=survivalt+0.5
  if survivalt%450==0 then
   falldelay=max(4,falldelay-1)
  end
 end
 for p in all(particles) do
  p.x=p.x+p.dx p.y=p.y+p.dy p.dy=p.dy+0.075 p.life=p.life-0.5
  if p.life<=0 then del(particles,p) end
 end
 for id,m in pairs(morphanim) do
  m.t=m.t+0.5
  if m.t>m.maxt then morphanim[id]=nil end
 end
 for id,m in pairs(landanim) do
  m.t=m.t+0.5
  if m.t>m.maxt then landanim[id]=nil end
 end
 for d in all(droptrail) do
  d.t=d.t+0.5
  if d.t>=d.maxt then del(droptrail,d) end
 end
 -- resolve merges detected last frame (they've had their one white
 -- flash frame drawn already) before checkmerge can mark new ones
 processpendingmerges()
 -- decompte independamment le flash multicolore d'une ligne en
 -- attente de purge (meme logique de "phase 2 differee" que les
 -- fusions, mais pas soumis au delai de settledelay ci-dessous : le
 -- plateau reste juste gele pendant que la ligne flashe)
 processpendingclear()
 if settling then
  settlet=settlet+0.5
  if settlet>=settledelay then
   settlet=0
   if pendingclearrows then
    -- plateau gele : on attend juste la fin du flash de la ligne
   elseif #pendingmerge>0 then
    -- une fusion est encore en plein flash blanc : on ne declare pas
    -- le plateau stable tant qu'elle n'est pas resolue, sinon la
    -- piece suivante pourrait spawner avant que domerge() ait eu la
    -- chance de forcer la retombee de ce qui perd son support.
   elseif not settletick() then
    local found=findfullrow()
    if found then
     pendingclearrows={rows=found.rows,n=found.n,wait=lineflashframes}
     sfx(17)
    else
     settling=false
     spawnifneeded()
    end
   end
  end
  return
 end
 if not cur then return end
 local moved=false
 local dl,dr=btn(0),btn(1)
 if dl and not dr then
  if btnp(0) then
   if fits(cur.cells,cur.x-1,cur.y) then cur.x=cur.x-1 sfx(0) moved=true end
   das=0
  else
   das=das+0.5
   if das>=dasinitial and (das-dasinitial)%dasrepeat==0 then
    if fits(cur.cells,cur.x-1,cur.y) then cur.x=cur.x-1 sfx(0) moved=true end
   end
  end
 elseif dr and not dl then
  if btnp(1) then
   if fits(cur.cells,cur.x+1,cur.y) then cur.x=cur.x+1 sfx(0) moved=true end
   das=0
  else
   das=das+0.5
   if das>=dasinitial and (das-dasinitial)%dasrepeat==0 then
    if fits(cur.cells,cur.x+1,cur.y) then cur.x=cur.x+1 sfx(0) moved=true end
   end
  end
 else
  das=0
 end
 if btnp(5) then
  tryhold()
  return
 end
 if btnp(4) then
  tryrotate()
 end
 if btnp(2) then
  local oldy=cur.y
  cur.y=dropfrom(cur.cells,cur.x,cur.y)
  local dist=cur.y-oldy
  if dist>0 then score=score+dist*2 end
  spawndroptrail(cur,oldy)
  lockpiece()
  return
 end
 local grounded=not fits(cur.cells,cur.x,cur.y+1)
 if grounded then
  if moved and lockresets<maxlockresets then
   lockt=0
   lockresets=lockresets+1
  end
  lockt=lockt+0.5
  if lockt>=lockdelay then
   lockpiece()
  end
 else
  lockt=0
  lockresets=0
  fallt=fallt+0.5
  local softdrop=btn(3)
  local d=softdrop and 3 or falldelay
  if fallt>=d then
   fallt=0
   cur.y=cur.y+1
   if softdrop then score=score+1 end
  end
 end
end

-- draws the block sprite for level "lvl" at px,py, scaled to size x size.
-- swaps to the flash sprite for maxlvl blocks, same timing as before.
function drawblock(px,py,lvl,size)
 local sid=blocksprite[lvl]
 if lvl>=maxlvl and flr(t()*2)%2==1 then sid=flashsprite end
 local sx=(sid%16)*8
 local sy=flr(sid/16)*8
 sspr(sx,sy,8,8,px,py,size,size)
end

function drawcell(x,y,lvl,id)
 local px=bx+x*cellpx
 local py=by+y*cellpx
 local lm=id and landanim[id]
 if lm then
  local bp=lm.t/lm.maxt
  py=py-flr(sin(bp*0.5)*2*(1-bp)+0.5)
 end
 local b=id and blobs[id]
 if b and b.exploding then
  -- one-frame white flash right before the piece explodes/merges away
  rectfill(px+1,py+1,px+cellpx-2,py+cellpx-2,7)
  rect(px,py,px+cellpx-1,py+cellpx-1,0)
  return
 end
 local m=id and morphanim[id]
 if m and m.t<=1 then
  -- one-frame white flash when the merge/morph starts
  rectfill(px+1,py+1,px+cellpx-2,py+cellpx-2,7)
  rect(px,py,px+cellpx-1,py+cellpx-1,0)
 elseif m then
  local p=m.t/m.maxt
  local inset=flr((1-p)*3)
  local size=cellpx-2-inset*2
  drawblock(px+1+inset,py+1+inset,lvl,size)
  rect(px,py,px+cellpx-1,py+cellpx-1,0)
 else
  drawblock(px,py,lvl,cellpx)
  rect(px,py,px+cellpx-1,py+cellpx-1,0)
 end
end

-- flash multicolore "arc-en-ciel" pour signaler une ligne pleine sur
-- le point d'etre purgee : chaque case cycle rapidement a travers une
-- petite palette, avec un decalage de phase selon x pour un effet de
-- vague qui traverse la ligne plutot qu'un flash plat uniforme.
local clearpalette={8,9,10,11,12,14}
function drawclearcell(x,px,py)
 local idx=(flr(t()*24)+x)%#clearpalette+1
 local col=clearpalette[idx]
 rectfill(px+1,py+1,px+cellpx-2,py+cellpx-2,col)
 rect(px,py,px+cellpx-1,py+cellpx-1,7)
end

function drawwalls()
 -- mur uni, une seule couleur (bleu marine, couleur 1), des deux
 -- cotes du plateau.
 local xl=bx-wallw
 local xr=bx+cols*cellpx
 rectfill(xl,0,xl+wallw-1,127,1)
 rectfill(xr,0,xr+wallw-1,127,1)
end

function drawboard()
 for x=0,cols-1 do
  for y=0,rows-1 do
   local c=board[x][y]
   if c then
    if pendingclearrows and pendingclearrows.rows[y] then
     drawclearcell(x,bx+x*cellpx,by+y*cellpx)
    else
     drawcell(x,y,c.lvl,c.id)
    end
   end
  end
 end
end

function drawcur()
 if not cur then return end
 for c in all(cur.cells) do
  drawcell(cur.x+c[1],cur.y+c[2],cur.lvl)
 end
end

function drawdroptrail()
 for d in all(droptrail) do
  local px=bx+d.x*cellpx
  local py=by+d.y*cellpx
  rectfill(px+1,py+1,px+cellpx-2,py+cellpx-2,7)
 end
end

function drawbox(x0,y0,x1,y1,title)
 rectfill(x0+2,y0+2,x1+1,y1+1,1)
 rectfill(x0+1,y0+1,x1-1,y1-1,15)
 rect(x0,y0,x1,y1,7)
 print(title,x0+2,y0-7,7)
end

function drawshapebox(px0,py0,boxw,boxh,title,lvl)
 drawbox(px0,py0,px0+boxw,py0+boxh,title)
 if not lvl then return end
 local cells=shapes[lvl].c
 local mw,mh=shapewh(cells)
 local maxdim=max(mw,mh)
 -- largeur et hauteur interieures de la case peuvent differer (la
 -- case n'est pas forcement carree), donc on les traite separement
 -- pour que le centrage marche dans les deux sens
 local innerw=boxw-6
 local innerh=boxh-6
 local csize=min(6,flr(innerw/maxdim),flr(innerh/maxdim))
 local offx=flr((innerw-mw*csize)/2)
 local offy=flr((innerh-mh*csize)/2)
 for c in all(cells) do
  local px=px0+3+offx+c[1]*csize
  local py=py0+3+offy+c[2]*csize
  drawblock(px,py,lvl,csize)
  rect(px,py,px+csize-1,py+csize-1,0)
 end
end

function drawnext()
 local px0=bx+cols*cellpx+wallw+3
 drawshapebox(px0,panely,28,22,"next",nextlvl)
end

function drawhold()
 local px0=bx+cols*cellpx+wallw+3
 drawshapebox(px0,panely+33,28,22,"hold",holdlvl)
end

function drawui()
 local px0=bx+cols*cellpx+wallw+3
 local boxw=28
 local py0=panely+33+33
 if scorepop>0 then
  local grow=flr(scorepop/5)
  local blink=flr(scorepop/2)%2==0
  drawbox(px0-grow,py0-grow,px0+boxw+grow,py0+14+grow,"score")
  print(score,px0+2,py0+4,blink and 10 or 8)
 else
  drawbox(px0,py0,px0+boxw,py0+14,"score")
  print(score,px0+2,py0+4,2)
 end
 local py1=py0+14+6
 print("evo",px0,py1,7)
 local barx,bary=px0,py1+7
 local barw,barh=boxw,6
 local pulse=evopulse>0
 local bcol=pulse and (flr(evopulse/2)%2==0 and 10 or 7) or 6
 rectfill(barx+1,bary+1,barx+barw,bary+barh-1,1)
 rect(barx,bary,barx+barw,bary+barh,bcol)
 local fillw=flr((barw-1)*(besttier/maxlvl))
 if fillw>0 then
  rectfill(barx+1,bary+1,barx+fillw,bary+barh-1,shapes[max(1,besttier)].col)
 end
 local iy0=bary+barh+4
 for i=1,maxlvl do
  local px=px0+((i-1)%4)*7
  local py=iy0+flr((i-1)/4)*8
  drawblock(px,py,i,6)
  rect(px,py,px+5,py+5,0)
 end
end

function bigchar(ch,x,y,col,scale)
 print(ch,x,y,0)
 local on={}
 for j=0,5 do
  for i=0,3 do
   on[j*4+i]=(pget(x+i,y+j)==0)
  end
 end
 rectfill(x,y,x+3,y+5,15)
 for j=0,5 do
  for i=0,3 do
   if on[j*4+i] then
    rectfill(x+i*scale,y+j*scale,x+i*scale+scale-1,y+j*scale+scale-1,col)
   end
  end
 end
end

function drawmenurow(y,label,valstr,focused,compact)
 rectfill(11,y+2,118,y+10,1)
 if focused then
  local blink=flr(t()*4)%2==0
  rectfill(10,y,117,y+8,0)
  rect(10,y,117,y+8,7)
  local tcol=blink and 7 or 6
  print(label,14,y+2,tcol)
  if compact then
   print(valstr,14+#label*4+2,y+2,tcol)
  else
   print("< "..valstr.." >",84,y+2,tcol)
  end
 else
  rectfill(10,y,117,y+8,7)
  rect(10,y,117,y+8,5)
  print(label,14,y+2,0)
  if compact then
   print(valstr,14+#label*4+2,y+2,0)
  else
   print(valstr,90,y+2,0)
  end
 end
end

function drawmenu()
 rectfill(2,2,125,125,15)

 local a=menuanim
 local logow,logoh=61,7
 local breathe=0
 local bobY=0
 if a>=10 then
  breathe=sin(t()*0.8)*0.035
  bobY=sin(t()*0.6)*1
 end
 local scale=2*(1+breathe)
 local tx=64-flr(logow*scale/2)
 local ty=24+bobY
 local logooff=max(0,10-a)*5

 -- drop shadow (offset 1px down-right)
 for c=0,15 do pal(c,0) end
 sspr(2,2,logow,logoh,tx+1,ty-logooff+1,logow*scale,logoh*scale)
 pal()

 sspr(2,2,logow,logoh,tx,ty-logooff,logow*scale,logoh*scale)

 if a>=8 then
  local hs="high score "..hiscore
  local hsx=64-flr(#hs*4/2)+1
  local hsy=ty+24
  local hsw=#hs*4-1
  rectfill(hsx-2,hsy-1,hsx+hsw+3,hsy+8,1)
  rectfill(hsx-3,hsy-2,hsx+hsw+2,hsy+7,7)
  rect(hsx-3,hsy-2,hsx+hsw+2,hsy+7,5)
  print(hs,hsx,hsy,4)
 end

 local rows={
  {60,"level",tostr(diflvl),1},
  {70,"blocks",tostr(startlvl),2},
  {80,"progressive speed",pdrop and "on" or "off",3},
  {90,"music",musicon and "on" or "off",4},
  {100,"controls",menustep==5 and "go" or "view",5},
 }
 for r in all(rows) do
  local delay=10+r[4]*3
  local off=max(0,delay-a)*16
  camera(off,0)
  drawmenurow(r[1],r[2],r[3],menustep==r[4])
  camera(0,0)
 end

 -- selecteur anime (glisse et "squash" vers la ligne selectionnee)
 if a>=26 then
  local squash=menuselsq*0.4
  local sy0=flr(menuselY-squash)
  local sy1=flr(menuselY+8+squash)
  local blink=flr(t()*6)%2==0
  local scol=blink and 10 or 9
  rect(8,sy0-1,119,sy1+1,scol)
  local trix=5+flr(sin(t()*4)*1)
  local triy=flr(menuselY)
  local w={1,2,3,4,3,2,1}
  for i=0,6 do
   rectfill(trix,triy+1+i,trix+w[i+1]-1,triy+1+i,scol)
  end
 end
end

function drawcontrols()
 local a=min(10,controlsanim)
 local yoff=(10-a)*9
 camera(0,yoff)
 rectfill(2,2,125,125,7)
 print("controls",44,6,0)

 -- dpad icon
 local dx,dy=14,20
 rectfill(dx+8,dy,dx+15,dy+7,0)
 rectfill(dx+8,dy+16,dx+15,dy+23,0)
 rectfill(dx,dy+8,dx+7,dy+15,0)
 rectfill(dx+16,dy+8,dx+23,dy+15,0)
 rectfill(dx+8,dy+8,dx+15,dy+15,5)

 print("up : hard drop",44,25,0)
 print("down : soft drop",44,33,0)
 print("l/r : move",44,41,0)

 -- z button
 circfill(30,58,7,0)
 print("z",28,55,7)
 local t1="rotate"
 print(t1,32-flr(#t1*4/2),70,0)

 -- x button
 circfill(96,58,7,0)
 print("x",94,55,7)
 local t3="hold"
 print(t3,96-flr(#t3*4/2),70,0)

 local t5="z or x : back"
 print(t5,64-flr(#t5*4/2),100,6)
 camera(0,0)
end

function _draw()
 local shx,shy=0,0
 if shake>0 then
  shx=flr(rnd(5))-2
  shy=flr(rnd(5))-2
 end
 camera(shx,shy)
 cls(0)
 -- rose gradient (dark rose -> red -> pink)
 local gx0,gy0,gx1,gy1=0,0,127,127
 local gh=gy1-gy0
 local colA,colB,colC=2,8,14
 local trans=15
 local half=flr(trans/2)
 local b1=gy0+flr(2*gh/8)
 local b2=gy0+flr(6*gh/8)
 for yy=gy0,gy1 do
  if yy<b1-half then
   fillp(0)
   rectfill(gx0,yy,gx1,yy,colA)
  elseif yy<=b1+half then
   fillp(0b0101101001011010)
   rectfill(gx0,yy,gx1,yy,colA+colB*16)
  elseif yy<b2-half then
   fillp(0)
   rectfill(gx0,yy,gx1,yy,colB)
  elseif yy<=b2+half then
   fillp(0b0101101001011010)
   rectfill(gx0,yy,gx1,yy,colB+colC*16)
  else
   fillp(0)
   rectfill(gx0,yy,gx1,yy,colC)
  end
 end
 fillp(0)
 if gstate=="menu" then
  drawmenu()
  return
 end
 if gstate=="controls" then
  drawcontrols()
  return
 end
 if gstate=="starting" then
  drawstarting()
  return
 end
 if gstate=="dying" then
  drawdying()
  return
 end
 rectfill(bx,0,bx+cols*cellpx-1,127,15)
 drawplayscreen()
 if gstate=="over" then
  local a=overanim
  local h=min(29,flr(a*29/9))
  local y0=69-h
  local y1=69+h
  rectfill(14,y0,114,y1,0)
  rect(14,y0,114,y1,6)
  if a>=9 then
   print("game over",40,46,6)
   print("score "..score,30,56,7)
   print("best "..hiscore,30,64,7)
   local blink=flr(t()*4)%2==0
   local rc=(overstep==1) and (blink and 7 or 10) or 5
   local mc=(overstep==2) and (blink and 7 or 10) or 5
   print((overstep==1 and "> " or "  ").."retry",30,76,rc)
   print((overstep==2 and "> " or "  ").."menu",30,84,mc)
  end
 end
 if flash>0 then
  camera(0,0)
  fillp(flash>5 and 0b1010010110100101 or 0b0101101001011010)
  rectfill(0,0,127,127,7)
  fillp(0)
 end
end

function drawplayscreen()
 drawwalls()
 drawboard()
 drawdroptrail()
 drawcur()
 for p in all(particles) do pset(p.x,p.y,p.col) end
 drawnext()
 drawhold()
 drawui()
end

function drawstarting()
 local half=flr(translen/2)
 if transt<half then
  if transfrom=="menu" then
   drawmenu()
  else
   rectfill(bx,0,bx+cols*cellpx-1,127,15)
   drawplayscreen()
  end
  local h=flr(64*(transt/half))
  rectfill(0,0,127,h-1,0)
  rectfill(0,128-h,127,127,0)
 else
  rectfill(bx,0,bx+cols*cellpx-1,127,15)
  drawplayscreen()
  local h=flr(64*(1-((transt-half)/half)))
  rectfill(0,0,127,h-1,0)
  rectfill(0,128-h,127,127,0)
 end
end

function drawdying()
 rectfill(bx,0,bx+cols*cellpx-1,127,15)
 drawwalls()
 for p in all(deathparts) do
  if p.life>0 then
   rectfill(p.x,p.y+1,p.x+cellpx-2,p.y+cellpx-2,p.col)
   rect(p.x,p.y,p.x+cellpx-1,p.y+cellpx-1,0)
  end
 end
 drawnext()
 drawhold()
 drawui()
 if deatht>deathlen-10 then
  fillp(0b0101101001011010)
  rectfill(bx,0,bx+cols*cellpx-1,127,0)
  fillp(0)
 end
end
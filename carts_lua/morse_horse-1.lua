-- morse horse
-- by lyrdl
function _init()
 dead = false
 frame = 0 
	path_y = 80
	horse_x = 8
	horse_y = (path_y-8)
	horse_dy = 0
	grounded = true
	level_x = 0
	doctor_x = 128
	doctor_jump = false
	regenerate_level()
	tree_x = 0
	tree_x_2 = 0
	mountain_x = 0
	music(0)
end

function _update()
 -- apply vert accel if jump
	if(btn(❘) and grounded) then
		horse_dy = -11
		grounded = false
	-- stop vertical accel for short press
	elseif(not btn(❘) and horse_y < path_y-32 and horse_dy < 0) then
  horse_dy = 0	 
	end
	
	if(btn(❘)) then sfx(1) end
	
	if(btn(❘) and dead) then _init() end
		
	-- apply gravity
	if grounded == false then
	 horse_dy += 1
	else horse_dy = 0
	end
	
 -- update horse pos 
	horse_y += horse_dy
	
 grounded
  = horse_y >= (path_y-8)
	
	-- clamp horse_y
	if(horse_y > (path_y-8)) then
	 horse_y = path_y-8
 end
 
 -- advance through the level
 if (not dead) then
  level_x += 2
	 level_x = level_x % (#level*8)
  mountain_x += 0.25
  mountain_x = mountain_x % (#mountain_level*8)
  tree_x += 2.5
	 tree_x = tree_x % (#tree_level*8)
		tree_x_2 += 3
		tree_x_2 = tree_x_2 % (#tree_level_2*8)
	end
	
	if (level_x >= (#level*8)-16) then
		regenerate_level()
	end 
	
	-- the parts of the level currently on screen
	screen = sub(
		level..level..level,
	 flr(level_x/8)-3+#level, -- couple tiles before the screen so we can draw shapes offscreen to the left
	 flr(level_x/8)+16+#level
	)
	
	tree_screen = sub(
		tree_level..tree_level..tree_level,
	 flr(tree_x/8)-3+#tree_level, -- couple tiles before the screen so we can draw shapes offscreen to the left
	 flr(tree_x/8)+16+#tree_level
	)
	
	tree_screen_2 = sub(
		tree_level_2..tree_level_2..tree_level_2,
	 flr(tree_x_2/8)-12+#tree_level_2, -- couple tiles before the screen so we can draw shapes offscreen to the left
	 flr(tree_x_2/8)+16+12+#tree_level_2
	)
	
	mountain_screen = sub(
		mountain_level..mountain_level..mountain_level,
	 flr(mountain_x/8)-12+#mountain_level, -- couple tiles before the screen so we can draw shapes offscreen to the left
	 flr(mountain_x/8)+16+12+#mountain_level
	)
	
	-- the number of pixel every tile of the level is offset by
	-- this essentially restores what gets rounded by the flr() calls above
	pixel_offset = level_x%8
	tree_offset = tree_x%8
	tree_offset_2 = tree_x_2%8
	mountain_offset = mountain_x%8
	
	-- check for collision
	-- is low enough to count as crashed
	local y_col = horse_y >= path_y-12
	local x_col = false
	doctor_jump = false
	for x = 1,#screen do
	 local i = x -3
	 local thing = screen[x]
	 if (thing == "." or thing == "<" or thing == ">")
	  and abs((i*8-pixel_offset) - horse_x) < 8 then 
	 	x_col = true
	 end
	 if (thing == "." or thing == "<" or thing == ">")
	  and abs((i*8-pixel_offset) - doctor_x) < 8 then 
	 	doctor_jump = true
	 end
	end
	
	-- you lose
 if (x_col and y_col and not dead) then
 	sfx(03)
 	music(1)
 	dead = true
 end
 
 -- move the doctor
 if(dead) then doctor_x -= 2 end
	
	if(not dead) then	frame += 1 end
end

function _draw()
 cls()
 -- draw sky
 color(12) rectfill(0,0,128,128)
 
 -- draw mountains
	for x = 1,#mountain_screen do
	 local i = x - 12
	 local thing = mountain_screen[x]
	 -- height based triangle
	 if(thing != " ") do
	  color(13)
	  --color(thing)
	 	triangle((i*8)-mountain_offset, path_y-thing*8)
	 end
	end
	
	-- draw ground
 for x = 0,128,8 do
	 spr(19,x,path_y)
	end
	
 for y = path_y+8,128,8 do
	 for x = 0,128,8 do
		 spr(20,x,y)
		end
	end

 -- draw horse
 local horse_spr = 1
 if((flr(frame/5))%2 == 0) then
 	horse_spr = 2 end
 if(not grounded) then
  horse_spr = 3 end
 if(dead) then
  horse_spr = 4 end
 
 spr(horse_spr, horse_x, horse_y)

 -- draw doctor
 if(dead) then
  local doctor_y = horse_y-8
  if doctor_jump then doctor_y = horse_y-16 end
  spr(5, max(doctor_x,horse_x+24),doctor_y ,2,2)
 end

 -- draw obstacles
	for x = 1,#screen do
	 local i = x - 3
	 local thing = screen[x]
	 if thing == "." then
	 	spr(33,(i*8)-pixel_offset, path_y-8)
	 elseif thing == "<" then
	  spr(34,(i*8)-pixel_offset, path_y-8,3,1)
	 elseif thing == ">" then
			-- nothing
	 elseif thing != " " then
	  color(8)
	 	print(thing,(i*8)-(flr(pixel_offset/2)*2), path_y-16)
	 end
	end
	
	-- draw paralax trees
	for x = 1,#tree_screen do
	 local i = x - 3
	 local thing = tree_screen[x]
	 if thing == "t" then
	 	spr(7,(i*8)-tree_offset, path_y,1,2)
	 elseif thing == "b" then
	  spr(8,(i*8)-tree_offset, path_y,1,2)
	 end
	end
	
	for x = 1,#tree_screen_2 do
	 local i = x - 12
	 local thing = tree_screen_2[x]
	 -- circles
	 if(thing != " ") do
	  color(3)
	  --color(thing)
	 	foreground_tree((i*8)-tree_offset_2, thing*8)
	 end
	end
	
	color(10)
	print("score: "..flr(frame/10), 4,4)

	-- debug
	color(12)
	--print("horse_y: "..horse_y, 80,16)
	--print("horse_dy: "..horse_dy, 80,24)
	if grounded then 
	 --print("grounded", 80,32)
	end
end

function regenerate_level()
	local words = split(dict,'|')
 level = "                "
 for w = 1,10 do
  local word = words[flr(rnd(count(words)))]
	 for i = 1,#word do
	  local letter = word[i]
	 	level = level..letter
	 	local code = morse[letter]
	 	if(code == nil) then
	 	  cls()
	 	  color(12)
	    print("letter: "..letter, 80,16)
	  end
	 	for j = 1,#code do
	 	 if(code[j] == ".") then
	 	  level = level..".    "
	 	 elseif(code[j] == "-") then
	 	  level = level.."<>>    "
	 	 end
	 	end
	 end
	 level = level.."        "
	end
	level = level.."                "
end

function triangle(left_x, top_y)
	for y = path_y, top_y,-1 do
	 for x = left_x, left_x+24 do
	 	if (y > -2*(x-left_x-24)+top_y) then
	 		pset(x,y)
	 	end
	 end
	 for x = left_x+24, left_x+48 do
	  if(y > 2*(x-left_x-24)+top_y) then
	 		pset(x,y)
	 	end
	 end
	end
end

function foreground_tree(x, radius)
	circfill(x, 128, radius)
	color(11)
	circ(x,128,radius)
end

dict = [[the|i|to|and|a|of|was|he|you|it|in|her|she|that|my|his|me|on|with|at|as|had|for|but|him|said|be|up|out|look|so|have|what|not|just|like|go|they|is|this|from|all|we|were|back|do|one|about|know|if|when|get|then|into|would|no|there|could|ask|down|time|want|eye|them|over|your|are|or|been|now|an|by|think|see|hand|say|how|around|head|did|well|before|off|who|more|even|turn|come|smile|way|really|can|face|other|some|right|their|only|walk|make|got|try|something|room|again|thing|after|still|thought|door|here|too|little|because|why|away|let|take|two|start|good|where|never|through|day|much|tell|girl|feel|oh|call|talk|will|long|than|us|made|friend|knew|open|need|first|which|people|went|sure|seem|stop|voice|very|felt|took|our|pull|laugh|man|okay|close|any|came|told|love|watch|arm|anything|though|put|left|work|guy|hair|next|yeah|while|mean|home|few|saw|place|school|help|wait|late|year|house|happen|last|always|move|old|night|nod|life|give|sit|stare|sat|should|moment|another|behind|side|sound|once|find|toward|boy|ever|nothing|front|mother|name|am|since|reply|myself|leave|bed|new|car|use|mind|maybe|has|heard|answer|minute|yes|until|both|found|end|small|word|someone|same|enough|began|run|bit|sigh|each|those|almost|against|everything|most|thank|mom|better|play|own|every|hard|remember|three|stood|live|stand|second|sorry|keep|finally|point|gave|already|actually|probably|himself|big|everyone|guess|lot|step|hey|hear|light|quickly|dad|kiss|black|pick|else|soon|shoulder|table|best|without|notice|stay|care|phone|reach|realize|follow|decide|kind|grab|show|inside|suddenly|father|rest|herself|grin|hour|hope|also|body|might|floor|its|continue|ran|across|hold|cry|half|pretty|great|course|mouth|class|kid|miss|wonder|morning|least|nice|dark|slowly|done|change|together|yet|question|anyway|bad|blue|believe|week|god|lip|fine|family|many|worry|roll|parent|under|surprise|water|onto|glance|wall|between|seen|read|window|idea|white|push|feet|must|such|seat|set|please|red|brother|these|whole|lean|part|person|slightly|pass|shook|fact|wrong|gone|far|hit|finger|quite|hate|meet|finish|heart|book|past|kill|reason|anyone|figure|top|along|world|high|shirt|does|today|young|held|outside|listen|whisper|happy|ground|deep|drop|shrug|dress|fell|yell|breath|air|tear|sister|chair|kitchen|matter|hurt|fall|wear|woman|eat|lie|hell|suppose|cover|couple|large|either|five|leg|jump|die|return|able|bag|alone|shut|stuff|short|ready|understand|kept|plan|raise|street|different|problem|break|line|early|cut|cold|paper|scream|instead|stupid|silence|tree|caught|ear|food|full|four|cause|fuck|explain|expect|fight|exactly|sort|completely|men|dance|met|story|whatever|build|speak|glass|pain|check|glare|chest|hot|rather|month|real|touch|park|bring|drink|ago|force|fast|lost|attention|wish|mark|wave|shout|fill|begin|baby|interest|money|fun|green|however|cheek|mine|clear|brown|forward|near|picture|may|cool|drive|hug|shake|sense|alright|dream|hang|clothes|act|become|manage|meant|game|ignore|stair|taken|party|add|sometimes|job|ten|shot|date|quiet|gaze|group|loud|straight|dead|neck|beside|pause|number|conversation|chance|rose|quietly|town|blood|color|desk|dinner|hall|horse|music|brought|piece|anymore|beautiful|order|fire|office|true|although|warm|easy|enter|perfect|mutter|softly|cross|shock|smirk|damn|soft|stomach|snap|spoke|tire|box|catch|skin|teacher|middle|note|yourself|lunch|tomorrow|breathe|clean|except|appear|lock|knock|bathroom|movie|agree|offer|kick|form|confuse|lay|less|calm|slip|sign|dog|lift|immediately|arrive|deal|tonight|usually|case|frown|shop|scare|promise|mum|couch|pay|state|shit|wrap|pocket|hello|free|huge|ride|bother|land|known|especially|expression|carry|ring|spot|allow|several|during|empty|lady|eyebrow|strange|coffee|road|threw|wide|bus|forget|gotten|smell|fear|press|boyfriend|blonde|throw|round|sun|tall|glad|age|write|upon|hide|became|crowd|rain|save|trouble|annoy|nose|weird|death|beat|tone|trip|six|control|nearly|consider|gonna|join|learn|above|hi|obviously|entire|direction|foot|angry|power|strong|quick|doctor|edge|song|asleep|twenty|barely|remain|child|enjoy|gun|slow|city|broke|key|lead|throat|normal|somewhere|wake|pair|sky|funny|business|student|giggle|bright|admit|jeans|given|children|store|sweet|low|climb|rub|apartment|knee|shoe|attack|bedroom|joke|spent|situation|stuck|gently|possible|cell|mention|silent|definitely|rush|hung|brush|perhaps|groan|ass|rock|card|lose|blush|besides|crazy|type|bore|afraid|chase|respond|marry|remind|pack|daughter|serious|girlfriend|mad|somehow|buy|sent|tight|simply|trust|imagine|wind|chuckle|bar|pink|shove|ball|sight|drag|human|truth|share|area|concern|team|escape|mumble|often|search|apparently|attempt|son|within|band|cute|led|memory|anger|fly|paint|bottle|busy|comment|exclaim|avoid|grow|grey|mirror|gasp|hallway|dear|star|sick|cat|counter|interrupt|none|blink|spend|usual|worse|locker|important|favorite|grip|tv|ice|pretend|settle|amaze|pop|disappear|carefully|train|stick|guard|teeth|flash|uncle|send|doubt|visit|nervous|excite|approach|excuse|fit|noise|study|letter|police|eventually|burn|field|hospital|tie|summer|huh|shift|self|hurry|greet|wife|position|wipe|heavy|slam|broken|complete|space|brain|tiny|pants|ah|punch|shower|tongue|afternoon|seriously|cup|further|race|recognize|computer|rang|safe|jacket|bottom|hundred|relax|sudden|wow|college|flip|mood|track|crack|block|handle|themselves|drove|seven|struggle|whether|ahead|sad|dry|women|focus|repeat|thick|relationship|jerk|present|suck|bell|surround|evening|bite|single|fault|shadow|wood|easily|woke|smoke|draw|suggest|wet|accept|third|totally|wore|breakfast|trail|animal|warn|aunt|sir|piss|burst|match|fix|practically|odd|wash|sing|inch|size|secret|clock|company|view|suit|forever|familiar|forehead|shoot|grew|stretch|pound|despite|response|center|curl|slight|toss|beneath|fist|welcome|laughter|angel|christmas|main|simple|neither|distance|comfort|upset|assume|eight|gather|lucky|fade|coat|special|awkward|certain|plate|darkness|practice|obvious|grade|cream|choice|hardly|pale|thin|button|chocolate|refuse|slid|pillow|thirty|count|honestly|poor|motion|storm|lightly|nobody|experience|path|period|dare|demand|comfortable|clearly|silver|peer|birthday|disgust|embarrass|bought|test|lap|bet|loudly|driver|murmur|taste|perfectly|squeeze|board|worth|fold|spread|crap|emotion|subject|pour|laid|lower|mile|yea|page|pile|snow|message|english|scene|sink|fail|forgot|hole|silently|heat|weekend|drew|guitar|sweat|unless|cloud|waist|slap|argue|grass|idiot|screen|yesterday|swear|twin|instantly|apart|narrow|opposite|blow|wrist|earth|action|circle|forgotten|list|closet|drunk|shape|yellow|twist|weight|smart|treat|pool|prepare|awake|certainly|tease|contact|slide|wonderful|bitch|reveal|swing|truck|anywhere|flower|upstairs|hers|itself|wander|downstairs|football|possibly|rip|forest|mostly|bloody|church|gay|stone|husband|sex|trick|yours|growl|club|friday|stage|include|sip|invite|sharp|convince|sheet|absolutely|orange|relief|apologize|art|remove|crash|van|curse|alive|blanket|receive|tip|rise|tightly|waste|bowl|fallen|river|mama|pace|honey|swallow|king|camera|deserve|dirty|chin|doorway|image|cookie|homework|hat|luck|aside|information|fifteen|fair|player|monster|gate|win|below|ceiling|click|cook|travel|fish|lit|nervously|towel|shiver|final|horrible|station|camp|hungry|thousand|evil|rich|war|involve|jaw|uncomfortable|directly|level|double|nine|creature|glow|somewhat|blame|entrance|hip|fresh|hiss|normally|tap|machine|ruin|bear|rule|till|cock|stumble|complain|everybody|truly|nurse|speed|hmm|panic|smooth|weak|goodbye|extra|gesture|scowl|beer|release|country|officer|careful|create|hill|snort|flew|heel|brow|charge|flat|plus|switch|whenever|drift|metal|discover|wheel|skirt|pat|ate|tea|hotel|sob|future|record|boot|likely|cheer|gold|prove|ha|twice|aware|lack|princess|bench|cousin|detail|amount|bird|backward|crush|cigarette|faint|belong|stranger|beach|load|everywhere|scratch|history|restaurant|event|extremely|widen|clutch|due|tug|beyond|happily|mistake|palm|amuse|guest|saturday|wooden|worst|exit|plastic|reality|wince|announce|gotta|slept|member|choose|swim|alarm|crawl|dollar|knife|magic|paid|pizza|purse|gift|chicken|plane|choke|screw|protest|base|drug|introduce|sleeve|movement|loose|bare|wanna|difficult|frame|spin|fake|pen|understood|nor|unfortunately|written|decision|beg|heavily|insist|soul|random|sport|male|urge|million|yawn|backpack|judge|startle|bunch|stream|muscle|yard|accident|dragon|sentence|fool|torn|bow|echo|mix|bury|system|dirt|spirit|leaf|protect|row|forth|purple|bang|curious|nearby|nowhere|collapse|hop|proud|wing|destroy|sea|separate|silly|wound|honest|battle|born|cough|mountain|split|square|underneath|bike|process|somebody|classroom|presence|whose|grown|hidden|serve|female|garden|meal|unable|elbow|support|bridge|reaction|skip|wild|angrily|effect|threaten|basically|smack|stroke|flow|moan|plant|impossible|bruise|disappoint|energy|relieve|confusion|wedding|fat|bill|dude|address|cast|naked|toy|math|personal|ship|spun|chat|pray|whip|grasp|float|fully|gorgeous|indeed|nail|vision|innocent|friendly|jealous|swung|flame|dorm|driveway|spill|gang|murder|respect|bent|tail|inform|lesson|whine|clench|excitement|library|lord|surface|dust|dump|feature|object|weapon|calmly|hesitate|hint|law|magazine|among|boss|file|leather|result|thrown|toe|terrible|local|project|won|radio|regret|grumble|otherwise|ridiculous|cd|lovely|mock|effort|fan|nerve|report|stall|elevator|mate|bastard|grunt|rope|entirely|frighten|shade|strength|bone|exchange|flight|monday|partner|plain|shine|cafeteria|beam|exist|porch|queen|squeal|faith|pierce|remark|content|ease|flick|mall|cannot|carpet|length|replace|duck|bump|common|style|tan|cake|court|previous|balance|bank|blind|dangerous|particular|sell|wrote|distract|melt|popular|social|teach|appearance|correct|lake|public|sarcastically|guilty|kinda|shall|television|boat|firmly|tent|thumb|manner|flush|roof|schedule|dine|weather|casually|moon|difference|butt|charm|feed|frustration|gentle|hook|bounce|particularly|pleasure|sneak|leader|rage|shriek|suffer|sunday|argument|pregnant|discuss|statement|ticket|dig|doll|chill|fence|horror|built|cop|security|sidewalk|breast|curtain|whom|fifty|giant|milk|recall|term|footstep|stun|tuck|clothing|lick|joy|ugly|hopefully|soldier|plead|struck|trap|opinion|plenty|tank|breeze|awesome|desire|roommate|halfway|opportunity|outfit|rough|beauty|chose|snake|tape|badly|cheat|daddy|roar|describe|desperately|height|thigh|tilt|deeply|friendship|winter|witch|worn|condition|enemy|golden|sofa|master|rude|throughout|assure|damage|natural|steal|belt|cage|claim|nightmare|prefer|purpose|merely|pin|french|sadly|uniform|branch|direct|hunter|juice|character|pure|stain|various|gain|soak|lately|pitch|accent|tremble|cabin|chew|physical|puzzle|explode|steady|pet|sake|compare|principal|scan|forty|impress|mentally|react|sandwich|shy|twelve|whilst|bullet|challenge|command|examine|film|appreciate|tense|blank|blew|fought|gym|passenger|teenager|dish|drawn|scary|unlike|straighten|strain|tune|constantly|famous|marriage|bound|fancy|issue|warmth|awhile|collect|concentrate|copy|disbelief|tighten|determine|favor|mental|bush|forgive|aim|embrace|fairly|froze|insult|option|post|resist|spoken|apple|general|instant|jeep|emerge|neighbor|pressure|service|shuffle|briefly|notebook|peace|string|wine|dash|gut|stress|connect|language|private|spring|chip|puppy|ache|desperate|habit|necessary|nope|pencil|satisfy|deny|mommy|attitude|dial|painful|display|frustrate|tend|exact|powerful|nature|photo|total|video|egg|occur|anybody|corridor|gulp|trace|whoever|brief|exhaust|pout|terrify|chapter|insane|spell|surely|tray|alcohol|chain|fashion|garage|inquire|candy|similar|bark|flirt|pathetic|supply|tower|engine|frozen|map|toilet|background|shudder|spider|adult|cheap|clue|hazel|irritate|sand|quarter|spare|american|rid|spat|pot|awful|bleed|fate|jog|strike|grimace|holiday|whistle|agreement|dull|expensive|snatch|sometime|ability|campus|collar|disturb|flicker|proceed|recently|risk|skill|topic|defense|fry|luckily|retort|captain|eaten|glove|mid|owner|cheese|yank|afterward|closely|coach|feather|handsome|new york|pity|signal|sniff|strap|contain|survive|sweater|west|drawer|leap|major|peek|suspect|tour|freeze|heaven|mask|surprisingly|abruptly|begun|customer|pad|design|flop|pride|yep|interview|makeup|blast|prince|rode|bubble|rent|teen]]

tree_level = "tbbbttbbtt"
tree_level_2 = "1    3    2     7    4     6     5    7"
mountain_level = "3   8  4      6            "

morse = {
	["a"] = ".-",
	["b"] = "-...",
	["c"] = "-.-.",
	["d"] = "-..",
	["e"] = ".",
	["f"] = "..-.",
	["g"] = "--.",
	["h"] = "....",
	["i"] = "..",
	["j"] = ".---",
	["k"] = "-.-",
	["l"] = ".-..",
	["m"] = "--",
	["n"] = "-.",
	["o"] = "---",
	["p"] = ".--.",
	["q"] = "--.-",
	["r"] = ".-.",
	["s"] = "...",
	["t"] = "-",
	["u"] = "..-",
	["v"] = "...-",
	["w"] = ".--",
	["x"] = "-..-",
	["y"] = "-.--",
	["z"] = "--..",
}
pico-8 cartridge // http://www.pico-8.com
version 15
__lua__

local game_objects = nil
local part
-- shake var 
local shake_power_save = 0
local shake_power = 0
local speed_shake_power = 0
local do_once = false
local game_over = false
local mode = 'start'
local _player
local shkx=0
local shky=0
local test=0
local enemies

local main_camera
local camx=64
local camy=64

local whiteframe = false
local start_time = 6

-- ##init
function _init()
 -- cls(15)
 poke(0x5f2d, 1)
  init_all_list()

 sfx(12)

end

-- ##draw
function _draw()

 if mode == 'start' then
  draw_start()
 elseif mode == 'game' then
  draw_game()
 elseif mode == 'gameover' then
  draw_gameover()
 end

 local spawner = search_gameobject('spawner')

 -- spe_print('fps:'..stat(7),camx+ 0, 11+camy, 11, 3)
 -- spe_print('object:'..#game_objects,camx+ 0, 20+camy, 8, 2)
 -- spe_print('object:'..#enemies,camx+ 0, 20+camy, 8, 2)
 -- spe_print('time:'..flr(time()),camx-64, camy-64, 8, 2)
 -- if spawner != nil then
 -- spe_print('e:'..search_gameobject('spawner').alivee,camx+ 0, 30 +camy, 8, 2)
 -- end
  -- spe_print('mem_use:'..stat(0),camx+ 0, 20+camy, 8, 2)
 -- spe_print('all_cpu:'..stat(1),camx+ 0, 30+camy, 9, 4)
 -- spe_print('sys_cpu:'..stat(2),camx+ 0, 40+camy, 8, 2)

 -- spe_print(camx, camx, camy, 8, 2)
 -- spe_print(camy, camx, camy, 8, 2)

end

function tuto()
 local offsetx, offsety = 23, -30

 spe_print('controls', 35 - offsetx, 70-offsety, 9, 2)
 spe_print('⬆️', 87  - offsetx,  60-offsety, 9, 2)
 spe_print('⬅️ ⬇️ ➡️ ',  75 - offsetx, 70-offsety, 9, 2)
 spe_print('+ ❎', 112  - offsetx,  70-offsety, 9, 2)

 -- spe_print('❎ to roll', 48 , 58, 9, 2)
 -- spe_print('survive !', 44 , 68, 9, 2)
end

-- ##update
function _update60()
 if mode == 'start' then
  update_start()
 elseif mode == 'game' then
  update_game()
-- make_turret(x, y, tag, duration, range, attack_speed, sprite, sound, bullet_infos)
  -- if btn(4) and time()%2 <= 1 then
  --  make_turret(player.x, player.y, 'turret', 15, 60, 1, 21, 0, 
  --    {damage=1, bullet_speed=200,  backoff=300, attack_timer=0, bullet_sprite=41})  end
 elseif mode == 'gameover' then
  update_gameover()
 end

end

function init_pool_object()
 for i=0, 15 do
      show_message('+'..flr(points), self.x, self.y, 8, 1, 5, 2, 'score', true)

 end
end

function start_game()
 sfx(-1, 0)
 init_all_list()

 init_all_gameobject()
 mode = 'game'
 draw_map()
 player = search_gameobject('player')
 main_camera = search_gameobject('camera')

 sfx(8)
 -- make_enemy(rnd(4)+67, 0, flr(rnd(15))+(time()/4) + 8, rnd(20)+10, 33, {50, 51},'mage')
 start_time = 6+time()
 music(0, 0, 8)

end

function draw_start()
 cls(15)
 draw_part()

 -- sspr(0, 64, 96, 55, 6, 0, 96*1.2, 55*1.2)
 sspr(0, 64, 96, 55, 15, 2*cos(time()/4))

 if time() < 0.1 then  draw_map() end
 -- spe_print("tiny coliseum", 35, 32, 9, 4)
 if time()*1%2 > 0.5 then spe_print('press ❎ to brawl ', 30, 60, 9, 4) end
 spe_print("by wombart", 2, 120, 9, 4, true)
 -- draw_all_gameobjects()
 tuto()
end



function whiteframe_update()
 if whiteframe == true then
  rectfill(-100,-100, 200, 200,15)
  whiteframe = false

 end
end

function draw_game()
 if not stop_cls() then
  cls(15)
 end


 camera_follow()

 draw_part()
 draw_all_gameobjects()
 
 map(2, 0, -48+shkx, -55+shky, 33, 38)

 whiteframe_update()

end

function camera_update()
 camx = main_camera.x
 camy = main_camera.y

end

function draw_gameover()
 cls(15)
 -- camx, camy = 64, 64
 -- local modx, mody= camx + shkx, camy+shky
 -- camx, camy = player.x, player.y
 if do_once == false then 
  do_once=true

 show_message('you died !!!', camx-20, camy-30-4*(cos(time())), 8, 2, 15, 2, 'gameover1', true)
 show_message('your score is '..flr(player.score), camx -32, camy+15, 10, 9, 10, 2, 'gameover2', true)
 show_message('press ❎ button to restart', camx - 51, camy + 40, 11, 3, 2, 2, 'gameover3', true)
 
 end
 
 draw_part()


 rectfill(camx-16 ,camy-50,camx-12+27 ,camy-50+40, 15)
 sspr(101, 83, 125-101, 122-82,camx-12 ,camy-50)
 sspr(sx,sy,sw,sh,dx,dy,dw,dh,flip_x,flip_y)
 for obj in all(game_objects) do
  if(obj:is_active() == true and sub(obj:get_tag(),1,8)=='gameover') then
   obj:draw()
  end
 end
end

function update_start()
  if btn(5) then start_game() end

end

function update_game()
 update_all_gameobjects()
 update_part()
 do_camera_shake()
 screen_border_blocker()
 camera_update()
 if time() >= start_time then
  random_item_spawning()
  random_enemy_spawning()
 end
end

function update_gameover()
 if btn(5) then run() end
 if game_over == false then sfx(15) end
 game_over = true
 mode='gameover'
 camera_update()

end

function draw_all_gameobjects()
 for obj in all(game_objects) do
  if(obj:is_active() == true) then
   obj:draw()
   -- print(obj:get_tag(), obj.x, obj.y-4)
  end
 end
end
function update_all_gameobjects()
 for obj in all(game_objects) do
  if(obj:is_active() == true) then
   obj:update()
  end
 end
end

-- ##init
function init_all_gameobject()
 make_player()
 -- spawn_some_dudes(5)

 cam = make_game_object(64, 64, 'camera', {newposition = {x=0, y=0}})

 make_game_object(0, 0, 'spawner', {
  timer=0,
  time_between_spawn=3,
  alivee=0
  })
  make_game_object(0, 0, 'item_spawner', {
  timer=0,
  time_between_spawn=3
  })
end

function init_all_list()
 game_objects={}
 enemies={}
 part={}
end


function draw_map()
 
 for i=5, 30 do
  local x, y = rnd(140)+8,rnd(140)+8
  add_decors(7+flr(rnd(5)),x, y) 
 end
 
 if mode == 'game' then
  -- spawner arrow sprite 
  add_decors(16,72, 9) 
  add_decors(32,69, 135)
 end 

end

-- ##random_enemy_spawning
function random_enemy_spawning()
 local spawner = search_gameobject('spawner')
 if(spawner == nil) then return end
 if spawner.timer <= time() and spawner.alivee < 25 then
  sfx(11)
  if spawner.time_between_spawn > 1 then spawner.time_between_spawn *= 0.98 end

  spawner.timer = time() + spawner.time_between_spawn


  local rand, randmax= 0, 3
  if time() > 15 then randmax = 4 else randmax = 3 end

  for i=0, 1 do
  rand=flr(rnd(randmax))
   local rand_pos_y = flr(rnd(3))
   if rand_pos_y <= 1 then rand_pos_y = -8 else rand_pos_y = 140 end
   if rand <= 1 then
    make_enemy(rnd(4)+67, rand_pos_y, flr(rnd(2))+(time()/10) + 2, rnd(40)+5, 17, {18, 19},'melee')
   elseif rand <= 2 then
    make_enemy(rnd(4)+67, rand_pos_y, flr(rnd(7))+(time()/8) + 2, rnd(50)+10, 33, {34, 35},'melee')
   elseif rand <= 3 then
    make_enemy(rnd(4)+67, rand_pos_y, flr(rnd(15))+(time()/6) + 3, rnd(20)+10, 33, {50, 51},'mage')
 -- make_enemy(x, y, health, move_speed, idle_spr, walk_spr)
   end
  end
 end

end


-- ##item
function random_item_spawning()
 local item_spawner = search_gameobject('item_spawner')
 if(item_spawner == nil) then stop() end
 if item_spawner.timer <= time() then
  item_spawner.timer = time() + item_spawner.time_between_spawn
  local random= flr(rnd(13))
  sfx(10)
  local x, y = rnd(120)+8, rnd(120)+8
  hit_part(x+4,y+4, {2})



  if random >= 0 and random <= 1 then
   make_item(x, y, 250,'item_heart', {24})
  elseif random >= 2 and random <= 4 then
   make_item(x, y, 250,'item_gun', {24})
  elseif random >=5 and random <=6 then
   make_item(x, y, 250,'item_speedboot', {24})
  elseif random >=7 and random <=8 then
   if time() > 60 then
    make_item(x, y, 250,'item_superbow', {24})
   else
     make_item(x, y, 450,'item_gun', {24})
   end

  elseif random >= 9 and random <= 10 then
   if time() > 120 then
    make_item(x, y, 450,'item_turret', {24})
   else
     make_item(x, y, 450,'item_gun', {24})
   end
  elseif random >= 11 and random <= 12 and time() > 60 then
   if time() > 160 then
    make_item(x, y, 450,'item_star', {24})
   else
    make_item(x, y, 450,'item_gun', {24})
   end
  end 
  -- if rnd(3) > 1 then make_item(rnd(120)+8, rnd(120)+8, 150,'item_gun', {24}) end

 end

end

function make_item(x, y, mage,tag, spritearr)
 make_game_object(x, y, tag, {
  spritearr=spritearr,
  spriteindex=1,
  current_spr=0,
  age=0,
  mage=mage,
  animtimer=0,
  animate=function(self)
   if self.animtimer <= time() then 
    self.spriteindex +=1 
    self.animtimer = time()+0.125 
   end
   
   if self.spriteindex > #self.spritearr then
    self.spriteindex = 1 
   end

   draw_outline_spr(spritearr[self.spriteindex], self.x, self.y)
   if time()*2%2 >= 1 then
    pal(2, 15)
    pal(4, 15)
    pal(9, 15)
   end
   
   spr(spritearr[self.spriteindex], self.x, self.y)
   pal()
  end,
  update=function(self)
   self.age += 1
   
   if self.mage > 0 and self.age >= self.mage then self:disable() end

  end,
  reset=function(self)
   self.age = 0

   self:enable()
  end,
  draw=function(self)
   self:animate()
   -- print(self.tag, self.x, self.y)
  end
  })
end

function draw_circle(x, y, in_col, out_col, radius)
   local in_col, out_col = in_col, out_col
   circ(x+shkx,y+shky,radius, 8)
   circ(x+shkx,y+shky, radius,in_col)
   circ(x+1+shkx,y+shky, radius,in_col)
   circ(x-1+shkx,y+shky, radius,in_col)
   circ(x+shkx,y+shky, radius-1,out_col)
   circ(x+shkx,y+shky, radius+1,out_col)
end

function stop_cls()
 local player = player
 if player.inventory.mushroom.timer > time() then return true
 else return false
 end
end

-- ##player
function make_player()

 make_game_object(rnd(64)+20,rnd(64)+20, 'player', {
  move_speed=1,
  idle_spr=1,
  current_spr=idle_spr,
  anim_index=0,
  anim_timer=0,
  walk_spr={2,3},
  inventory = {mushroom={timer=0, duration=2}, speedboot={timer=0, duration =4, speed = 1.5}, 
  superbow={timer=0, duration=10, damage=4, attack_speed=1, bullet_speed=230, attack_timer=0, range=65, bullet_sprite=56, backoff=500}},
  gun={active=false, duration=15, timer=0, backoff=150, move_speed=350,
   sprite=41, attack_speed=0.5,  first_attack_speed= 0.5, attack_timer=0, range=50, damage=2},
  health=3,
  target,
  moving=false,
  press_once=0,
  score=0,
  stopped=false,
  invicible={state=false, timer=0, duration = 3, blink_speed=4},
  rolling={state=false, x=60, y=60, timer=0, sprite=4, reload_time=1, distance=30, speed=250},
  exp=0,
  sprite=1,

  find_target=function(self)
   self.target = closest_obj(self, {'enemy'})
   -- self.move_point.target = 
  end,
  update_pet=function(self)
   rotate(self.x, self.y, self.pet.radius, self.pet.degrees, self.pet)
  end,
  roll=function(self)
 
   
   screen_border_blocker_check(self.rolling)
   if self.rolling.state==false  then
    if self.rolling.state == true then self.current_spr=self.rolling.sprite return end
    
    local dist = self.rolling.distance

    if btn(0) and btn(2) then self.rolling.x, self.rolling.y = self:center('x') - dist, self:center('y') - dist  
    elseif btn(0) and btn(3) then self.rolling.x, self.rolling.y = self:center('x') - dist, self:center('y') + dist  
    elseif btn(1) and btn(2) then self.rolling.x, self.rolling.y = self:center('x') + dist, self:center('y') - dist  
    elseif btn(1) and btn(3) then self.rolling.x, self.rolling.y = self:center('x') + dist, self:center('y') + dist  
    elseif btn(0) then self.rolling.x, self.rolling.y = self:center('x') - dist*1.7, self:center('y')  
    elseif btn(1) then self.rolling.x, self.rolling.y = self:center('x') + dist*1.7, self:center('y')  
    elseif btn(2) then self.rolling.x, self.rolling.y = self:center('x'), self:center('y') - dist*1.7 
    elseif btn(3) then self.rolling.x, self.rolling.y = self:center('x'), self:center('y') + dist*1.7  
    -- else self.rolling.x, self.rolling.y = self:center('x'), self:center('y')
    end
     return
    else
     self.invicible.state = true
     self.invicible.timer=time() + self.rolling.distance/200 * 2
     self.rolling.timer = time() + self.rolling.reload_time

   end
   sfx(0)
   move_toward(self, self.rolling, self.rolling.speed)
   if(distance(self, self.rolling) <= 4) then self.rolling.state = false end

  end,
  take_item=function(self)
   for obj in all(game_objects) do
    local tag = obj:get_tag()
    if obj:is_active() and distance(self, obj) < 10 then
     -- make_item(x, y, 300,'item_heart', {54, 55})
     if sub(tag, 6,12) == 'heart' then  sfx(8)
      obj:disable()  
      if self.health <= 7 then 
       show_message('potion', self.x, self.y, 8, 2, 10, 2, 'item_msg', true)
       self.health += 3
      else
       show_message('max health', self.x, self.y, 8, 2, 10, 2, 'item_msg', true)
     end
     elseif sub(tag, 6,14) =='gun' then sfx(8)
      self.gun.active = true self.gun.timer = time() + self.gun.duration
      obj:disable() obj:disable()  show_message('bow', self.x, self.y, 12, 2, 10, 1, 'item_msg', true) 
     elseif sub(tag, 6,22) =='speedboot' then sfx(8)
      self.move_speed = self.inventory.speedboot.speed
      self.inventory.speedboot.timer = time() + self.inventory.speedboot.duration 
      obj:disable()  show_message('speedboot', self.x, self.y, 12, 2, 10, 1, 'item_msg', true) 
     elseif sub(tag, 6,22) =='superbow' then sfx(8)
      self.inventory.superbow.timer = time() + self.inventory.superbow.duration 
      obj:disable() obj:disable()  show_message('superbow', self.x, self.y, 12, 2, 10, 1, 'item_msg', true) 
     elseif sub(tag, 6,22) =='mushroom' then sfx(8)
      self.inventory.mushroom.timer = time() + self.inventory.mushroom.duration
      obj:disable()  show_message('toxic mushroom', self.x, self.y, 12, 2, 10, 1, 'item_msg', true) 
     elseif sub(tag, 6,22) =='turret' then sfx(8)
      obj:disable()  show_message('turret', self.x, self.y, 12, 2, 10, 1, 'item_msg', true) 
      local turret = make_turret(self.x, self.y, 'turret', 15, 55, 0.5, 21, 0, 
     {damage=4*(time()/6), bullet_speed=400,  backoff=300, attack_timer=0, bullet_sprite=41})
     elseif sub(tag, 6,22) =='star' then sfx(16)
      self.invicible.timer = time() + 10
      self.invicible.state = true
      obj:disable()  show_message('invincibility !', self.x, self.y, 12, 2, 10, 5, 'item_msg', true) 

     end
    end
   end
  end,
  is_alive=function(self)
   if self.health <= 0 then
     mode='gameover'
     sfx(5)
     return false
   else
    -- self.score += 1/60
   end

   return true
  end,
  item_manager=function(self)

   if self.inventory.speedboot.timer <= time() then self.move_speed = 1 end
   if self.inventory.superbow.timer > time() and self.inventory.superbow.attack_timer <= time()  then

    for obj in all(game_objects) do
      if obj:get_tag()== 'enemy' and obj:is_active() 
      and distance(self, obj) <= self.inventory.superbow.range then
       -- shake_camera(1)
       local new_bullet = make_bullet(self:center('x'), self:center('y'), self.inventory.superbow.damage,
        self.inventory.superbow.backoff, true, self.inventory.superbow.bullet_speed,
        self.inventory.superbow.bullet_sprite, obj, 'superbullet', true) 
       
       if new_bullet != nil then  
        new_bullet:set_target(obj)       
       end

      end     
    end
    self.inventory.superbow.attack_timer = time() + self.inventory.superbow.attack_speed
   end

   if self.gun.active == true then
    if(self.target != nil and self.target:is_active() == true and distance(self, self.target) <= self.gun.range) then
     if self.gun.attack_speed > 0.05 then self.gun.attack_speed *= 0.998 end
     if self.gun.attack_timer <= time() then 
      self.gun.attack_timer = time() + self.gun.attack_speed
      
      -- shake_camera(1)
      local new_bullet = make_bullet(self:center('x'), self:center('y'), self.gun.damage,self.gun.backoff, true, 
       self.gun.move_speed,self.gun.sprite, self.target, 'bullet', true) 
      if new_bullet != nil then  
       new_bullet:set_target(self.target)
      end
     end
    end
  else
   self.gun.attack_speed=self.gun.first_attack_speed
   end
   if self.gun.timer <= time() then self.gun.active = false end

  end,
  update_invicible=function(self)
   if time() >= self.invicible.timer then self.invicible.state = false end
  end,
  take_damage=function(self, damage)
   
   if self.invicible.state == true then return false end
   sfx(3)
   whiteframe=true
   self.health-= damage
   self.invicible.state = true
   self.invicible.timer=time() + self.invicible.duration
   shake_camera(1)
   return true
  end,
  is_moving=function(self)
   if btn(0) or btn(1) or btn(2) or btn(3) then self.moving = true return true
   else self.moving = false return false end
  end,
  is_key_pressed=function(self, _key)
   self.press_once +=1
   if not btn(_key) then self.press_once = 0 end 
   if self.press_once <= 2 and self.press_once > 0 then return true else return false end
   
  end,
  display_score=function(self)
   -- sspr(112, 16, 16, 16, 70, 70)
   
   rectfill(45,71, 129, 82, 2)
   rectfill(46,72, 128, 81, 4)
   spe_print('score '..flr(self.score), 68, 74, 9,4, 1, 2, 'score')
  end,
  move_input=function(self)
   if(self.rolling.state == true) then 
    if (rnd(6) >= 1) then end return 
   end

   if btn(0) then self.x -= self.move_speed end
   if btn(1) then self.x += self.move_speed end
   if btn(2) then self.y -= self.move_speed end
   if btn(3) then self.y += self.move_speed end
   

   if (self:is_moving() and btn(5) and self.rolling.timer <= time()) then  self.current_spr=self.rolling.sprite self.rolling.state=true
    end
 
   self:animation()
  end,
  animation=function(self)
   
   if self.invicible.state == true and self.rolling.state == true then
    
    self.current_spr = 5
    return
   end
   if(time() < self.anim_timer) then 
    return
   else
    -- self.inv_frame=false
   end

   if btn(0) or btn(1) or btn(2) or btn(3) then

    if(self.anim_index < #self.walk_spr) then
     self.anim_index +=1
     self.current_spr = self.walk_spr[self.anim_index]
    else
     self.current_spr = self.walk_spr[1]
     self.anim_index = 1
    end

   else
    self.current_spr=self.idle_spr
   end
   self.anim_timer = time()+0.125
  end,
  update=function(self)
   if self.stopped then return end
   self:find_target()
   self:is_alive()
   self:update_invicible()
   self:item_manager()
   self:take_item()
   self:move_input()
   self:roll()
   self:is_moving()
  end,
  draw=function(self)
   if self.stopped then return end
   -- draw cursor on player.
   draw_outline_spr(23, self.x+shkx, self.y-12+shky)
   spr(23, self.x+shkx, self.y-12+shky)
   self:display_score()

   if self.moving then smoke_part_custom(self:center('x'),self:center('y')+6, rnd(2)+3, rnd(25)+10, 0.125,{9, 4}) end
   if self.gun.active == true then spe_print('bow',self.x-1, self.y-8, 9, 4) 
   draw_circle(self:center('x'), self:center('y'), 9, 4, self.gun.range) end
   if self.inventory.superbow.timer > time() then spe_print('! superbow !',self.x-16, self.y-8, 9, 4)
     draw_circle(self:center('x'), self:center('y'), 9, 2, self.inventory.superbow.range) end
   -- pset(self.rolling.x, self.rolling.y)
   -- make blinking
   if self.invicible.state then
    draw_outline_spr(self.current_spr, self.x+shkx, self.y+shky)
    if time()*6%2 >= 1 then
     pal(9, 15) 
     pal(4, 15)
    else
     pal()
    end
    spr(self.current_spr,self.x+shkx, self.y+shky) 
    pal()
   else
    pal()
    draw_outline_spr(self.current_spr, self.x+shkx, self.y+shky)
    spr(self.current_spr,self.x+shkx, self.y+shky) 
   end

   spe_print('hp '..self.health, self.x+shkx, self.y+10+shky, 9,2)

  end
  })

end

-- ##turret
function make_turret(x, y, tag, duration, range, attack_speed, sprite, sound, bullet_infos)
 return make_game_object(x, y, tag, {
  timer=duration+time(),
  duration=duration,
  first_attack_speed=attack_speed,
  attack_speed=attack_speed,
  range=range,
  sprite=sprite,
  sound=sound,
  -- damage, move_speed, bullet_sprite, attack_timer, backoff, 
  bullet_infos=bullet_infos,
  attack_update=function(self)
   if self.bullet_infos.attack_timer <= time()  then
   sfx(sound)
   local target = closest_obj(self, {'enemy'})
   if target ==nil then return end
      if target:get_tag()== 'enemy' and target:is_active() 
      and distance(self, target) <= self.range then
       -- shake_camera(2)
       local new_bullet = make_bullet(self:center('x'), self:center('y'), self.bullet_infos.damage,
        self.bullet_infos.backoff, true, self.bullet_infos.bullet_speed,
        41, target, 'turretbullet', true) 
       if new_bullet != nil then  
        new_bullet:set_target(target)       
       end
      end     
     self.bullet_infos.attack_timer = time() + self.attack_speed
   end
   end,
   reset=function(self)
    self.active = true
    self.timer = self.duration+time()

   end,
   is_still_active=function(self)
    if time() >= self.timer then 
     self:disable()

     sfx(5)
    end
   end,
   update=function(self)
    self:attack_update()
    self:is_still_active()
   end,
   draw=function(self)
    draw_outline_spr(time()*4%2+self.sprite, self.x+shkx, self.y+shky)
    spr(time()*4%2+self.sprite, self.x+shkx, self.y+shky)
    spe_print(flr(self.timer-time()), self.x+shkx+3, self.y+shky+8)
    spe_print('turret', self.x+shkx-6 , self.y+shky-8)

    circ(self:center('x'), self:center('y'),self.range, 2)
   end

  })
end
-- ##blocker
function screen_border_blocker_check(obj)
 if obj==nil then return end

 if obj.x < 8 then obj.x = 8 end
 if obj.x > 145 then obj.x = 145 end
 if obj.y < 8 then obj.y = 8 end
 if obj.y > 140 then obj.y = 140 end
end
function screen_border_blocker()
 for obj in all(game_objects) do
  local _tag = obj:get_tag()
  if(obj:is_active() and _tag =='enemy' or _tag=='player') then
   if obj.x < 8 then obj.x = 8 end
   if obj.x > 145 then obj.x = 145 end
   if obj.y < 8 then obj.y = 8 end
   if obj.y > 140 then obj.y = 140 end
  end
 end
end


-- ##bullet
function make_bullet(x, y, damage, backoff, follow, move_speed, sprite, target, tag, rotate)
 return make_game_object (x, y, tag, {
  damage=damage,
  follow=follow,
  move_speed=move_speed,
  sprite=sprite,
  target=target,
  rotate_state=rotate,
  direction={x=target.x, y=target.y},
  rotate=function(self)
   
   local radian=atan2(self.x - self.target.x, self.y - self.target.y )
   local degrees=360*radian/(2*3.14)
   local num=0
    
   if (degrees < 4 and degrees > 0)  or (degrees > 55 and degrees < 61) then
    spr(self.sprite, self:center('x'), self:center('y'), 1, 1, true)

   elseif degrees > 2 and degrees < 12 then
    spr(self.sprite+2, self:center('x'), self:center('y'), 1, 1, true, true)   
   
   elseif degrees > 10 and degrees < 18 then
    spr(self.sprite+1, self:center('x'), self:center('y'), 1, 1, false, true)   
   
   elseif degrees > 16 and degrees < 27 then
    spr(self.sprite+2, self:center('x'), self:center('y'), 1, 1, false, true)   
   
   elseif degrees > 25 and degrees < 33 then
    spr(self.sprite, self:center('x'), self:center('y'))   
   
   elseif degrees > 31 and degrees < 41 then
    spr(self.sprite+2, self:center('x'), self:center('y'))   
   
   elseif degrees > 39 and degrees < 47 then
    spr(self.sprite+1, self:center('x'), self:center('y'))   
   
   elseif degrees > 45 and degrees < 57 then
    spr(self.sprite+2, self:center('x'), self:center('y'), 1, 1, true)   

   end

  end,
  update=function(self)
   if self.target:is_active() == false then self:disable() end
   -- self.move_speed *= 0.98
   if(follow) then self:move_follow() else self:move_straight() end
   if(distance(self, self.target) <= 5 and self.target:is_active() == true and self.target:is_alive()) then
    -- backoff the target
    self.target:take_damage(damage)

    -- smoke_part(self:center('x'),self:center('y'))   
    -- dust_part(x, y, size, mage, speed, move_speed, colarr)
    self:explode()
    self:disable()
   elseif self.target:is_active() == false then
    self:disable()
   end
   
  end,
  explode=function(self)
    smoke_part_custom(self:center('x'),self:center(' y'), rnd(10)+5, rnd(100)+100, 0.5,{9, 4}) -- orange and brown circle.
    smoke_part_custom(self:center('x'),self:center('y'), rnd(15)+9, 20, 3,{2, 9, 15}) -- purple circle
     if self.target:get_tag()!='player' then sfx(1) end
  end,
  set_target=function(self, target)
   self.target = target
   self.direction={x=target.x, y=target.y}
  end,
  move_straight=function(self)
   move_toward(self.direction, self, -self.move_speed)
   move_toward(self, self.direction, self.move_speed)
   if(distance(self, self.target) >= 80) then self:explode() self:disable() end
  end,
  move_follow=function(self)
    move_toward(self, self.target, self.move_speed)
  end,
  draw=function(self)
   -- if self.rotate_state then
   --  self:rotate()
   -- else
    if time()*6%2 >= 1 then
     pal(9, 2)
    end
    draw_outline_spr(self.sprite, self:center('x')+shkx, self:center('y')+shky)
    spr(self.sprite, self:center('x')+shkx, self:center('y')+shky)
    pal()
   -- end
-- 
   -- line(self.x,self.y,target.x,target.y, 8)
   -- spr(self.sprite, self:center('x'), self:center('y'))
   -- print(self.tag,self.x, self.y)
   -- pset(self.direction.x, self.direction.y,8)
  end,
  reset=function(self)
   -- self.target= nil
   self:enable()
   
  end
  })
end

function set_pal(c1, c2)
 for i=1, #c1 do
  pal(c1[i], c2[i])
 end
end

function camera_follow()
 local _player= player 

 local cam = main_camera
 local dist = distance(_player, cam)
 local shx, shy= 0, 0


 if _player.target != nil then
  if dist < 20 then 
   move_toward(cam, {x=_player.x+(_player.target.x - _player.x)/2, y=_player.y+(_player.target.y - _player.y)/2}, 50) 

  elseif dist < 40 then
   move_toward(cam, {x=_player.x+(_player.target.x - _player.x)/2, y=_player.y+(_player.target.y - _player.y)/2}, 60)

  elseif dist < 60 then
   move_toward(cam, {x=_player.x+(_player.target.x - _player.x)/2, y=_player.y+(_player.target.y - _player.y)/2}, 70)
  else
   move_toward(cam, {x=_player.x+(_player.target.x - _player.x)/2, y=_player.y+(_player.target.y - _player.y)/2},  110)
  end
 else
   if dist < 20 then 
   move_toward(cam, _player, 40) 

  elseif dist < 40 then
   move_toward(cam, _player, 40)

  elseif dist < 60 then
   move_toward(cam, _player, 50)
  else
   move_toward(cam, _player,  100)
  end
 end
 camera(cam.x-64 ,cam.y-64)
end

-- ##enemy
function make_enemy(x, y, health, move_speed, idle_spr, walk_spr, class)

 
 local spawner = search_gameobject('spawner')
 spawner.alivee += 1

 make_game_object(x, y, 'enemy', {
  first_move_speed=move_speed,
  move_speed=move_speed,
  class=class,
  idle_spr=idle_spr,
  current_spr=33,
  anim_timer=0,
  anim_index=0,
  attack_info={damage=1, attack_speed=1, timer=0},
  walk_spr=walk_spr,
  max_health=health,
  health=health,
  moving=false,
  inv_frame=false,
  danger=false,
  speak_info={timer=0, duration=5, randdisplay=rnd(4)+2, randdisplaytimer=rnd(8)+4, text_arr={'come here !',
   'i saw him first !', 'you better run !', 'prize is mine !', 'mine mine mine',
   'you are dead !', 'fus-ro-dah !!!', 'show me your moves!','omae wa mou shindeiru',
   'ora ora ora','you wanna taste my axe ?', 'you are a dead man !','aaargh !',
    'huh !', 'aaaaaaahhh',  randtext=flr(rnd(5))}},
  move_point={state=false, x=40, y=40, timer=0, move_rand=5, target=nil},
  exp=0,
  sprite=1,
  target,
  gun={active=false, duration=5, timer=0, backoff=150, move_speed=100,
   sprite=55, attack_speed=6,  first_attack_speed= 6, attack_timer=0, range=50, damage=1},
  rolling={state=false, x=60, y=60, timer=0, sprite=4},

  find_target=function(self)
   -- self.move_point.target = closest_obj(self, {'player'})
   self.move_point.target = player
   -- self.move_point.target = 
  end,
  mage_attack=function(self)

  if(self:get_target() != nil and self:get_target():is_active() == true and distance(self, self:get_target()) <= self.gun.range) then
   if self.gun.attack_timer <= time() then 
    self.gun.attack_timer = time() + self.gun.attack_speed
    -- shake_camera(2)
    local new_bullet = make_bullet(self:center('x'), self:center('y'), self.gun.damage,self.gun.backoff, false, 
     self.gun.move_speed,self.gun.sprite, self:get_target(), 'bullete', false) 
    if new_bullet != nil then  
     new_bullet:set_target(self:get_target())
    end
   end
   
  else
   self.gun.attack_speed=self.gun.first_attack_speed
   end
   if self.gun.timer <= time() then self.gun.active = false end
  end,
  melee_attack=function(self)
   local dist = distance(self, self:get_target())
   if dist != nil and dist < 3 and time() >= self.attack_info.timer and self:get_target().health > 0 then 

    -- sfx(2)
    if  self:get_target():take_damage(self.attack_info.damage) == true then

     -- shake_camera(1,2)
     self.attack_info.timer = time() + self.attack_info.attack_speed
     move_toward(self:get_target(), self, -900)
    end
    -- blood_part(self:get_target().x, self:get_target().y, 1, {8, 2})
    -- explosion_part(self:get_target():center('x'), self:get_target():center('y'), 5, {8, 2})
   end
  end,

   is_alive=function(self)
   if self.health <= 0 then
     return false
   else
    return true
   end
  end,
  speak=function(self)
   if spawner.alivee > 4 then return end
    if time()%self.speak_info.randdisplaytimer < self.speak_info.randdisplay then 
     -- self.speak_info.timer = self.speak_info.duration + time()

     spe_print(self.speak_info.text_arr[self.speak_info.randtext], self.x-8, self.y-8, 15, 2)
     -- print(self.speak_info.text_arr[self.speak_info.randtext], self.x-8, self.y-8, 2)
    else 
      self.speak_info.randtext= flr(rnd(#self.speak_info.text_arr)+1)
    end
    -- end
   -- end
  end,

  kill=function(self)
    self.health = 0
    spawner.alivee -=1
    
    blood_part(self:center('x'), self:center('y'), 1, {2})
    local player = player
    local points = self.max_health + rnd(5)
    if player!=nil then player.score += points end
    show_message('+'..flr(points), self.x, self.y, 8, 1, 5, 2, 'score', true)
-- show_message(_text, _x, _y, _in_color, _out_color, _speed, _display_time, tag, moving, ui_state)
    -- local spawner = search_gameobject('spawner')
     -- smoke_part_custom(self:center('x'),self:center('y'), rnd(5)+7, rnd(25)+10, 0.25,{4, 2})    -- move_toward(self, target, move_speed)
     -- smoke_part_custom(self:center('x'),self:center('y'), rnd(8)+10, rnd(25)+10, 2,{8})    -- move_toward(self, target, move_speed)
     sfx(9)
     shake_camera(0.5)
     -- ennemy does damage around him on other enemies
     local rand = flr(rnd(11))
     if rand >= 8 then
      sfx(6)
      -- show_message('boom !', self:center('x'),self:center(' y'), 8, 1, 100, 3, 'score', true)
      shake_camera(10)
      for obj in all(enemies) do
       if obj:is_active() and obj:is_alive() and distance(self, obj) < 30 then

        smoke_part_custom(self:center('x'),self:center(' y'), 30, rnd(100)+100, 0.5,{9, 4}) -- orange and brown circle.
        obj:take_damage(obj.max_health)
       end
      end
     end

     self.x, self.y = 130, 130
     self:disable()
  end,
  take_damage=function(self, dmg)
   sfx(3)
   self.health -= dmg
   return true
  end,
  move=function(self)
   self:find_target()
   

   if(self:get_target() == nil) then self.moving = false return end
   if distance(self, self:get_target()) > 2 then
    move_toward(self, self:get_target(), self.move_speed)
    self.moving = true
   end
  end,
  get_target=function(self)
   return self.move_point.target
  end,
  animation=function(self)
   if self.danger then spr(23, self.x+shkx,self.y-8+shky) end

   if(time() < self.anim_timer) then 
    return
   else
    -- self.inv_frame=false
   end
    
    if(self.moving) then
     -- smoke_part_custom(self:center('x'),self:center('y'), rnd(2)+2, rnd(15)+60, 0.05,{9, 4})

     if(self.anim_index < #self.walk_spr) then
      self.anim_index +=1
      self.current_spr = self.walk_spr[self.anim_index]
     else
      self.current_spr = self.walk_spr[1]
      self.anim_index = 1
     end
    else
     self.current_spr=self.idle_spr
    end

    self.anim_timer = time()+0.25
  end,
  reset=function(self)
   self.health = self.max_health
   self:enable()
  end,
  update=function(self)
   if self:is_alive() == false then self:kill() end
   self:move()
   self:animation()
   if self.class == 'melee' then
    self:melee_attack()
   elseif self.class =='mage' then

    self:mage_attack()
   end
  end,
  draw=function(self)
  draw_outline_spr(self.current_spr, self.x, self.y)
  spr(self.current_spr, self.x+shky, self.y+shkx)
  self:speak()

  -- spe_print('hp '..self.health, self.x, self.y+10, 9, 4)
  -- spe_print(flr(time())..'/'..self.attack_info.timer, self.x, self.y+10, 9, 4)
  end

  })


end

function closest_obj(target, tags)
 local dist=0
 local shortest_dist=1000
 local closest=nil
 for obj in all(game_objects) do

  dist = distance(target, obj) 
  if obj:is_active() == true and dist <= shortest_dist and dist > 1 then
   if(tags != nil) then   
    for tag in all(tags) do 
     if(obj:get_tag() == tag) then
      closest = obj 
      shortest_dist = dist
     end
    end
   else
    closest = obj 
    shortest_dist = dist
   end
  end
 end
 return closest
end

-- ##make gameobject
function make_game_object(x, y, tag, properties)
 
 for obj in all(game_objects) do
  if(obj:is_active() == false and obj:get_tag() == tag) then
   obj:set_value(x,y,tag)
   obj:reset()
   return obj
  end
 end

 local obj={
  x=x,
  y=y,
  tag=tag,
  active=true,

  update=function()
  end,
  draw=function()
  end,

  is_active=function(self)
   return self.active
  end,
  disable=function(self)
   self.active = false
   -- self.x, self.y = 150, 150
  end,
  enable=function(self)
   self.active = true
  end,
  reset=function(self)
   self:enable()
  end,
  center=function(self, value)
   if value == 'x' then return self.x+4
   else return self.y + 4
   end
  end,
  get_tag=function(self)
   return self.tag
  end,
  set_value=function(self, x, y, tag)
   self.x=x
   self.y=y
   self.tag=tag
  end
 }

 if(properties != nil or properties != 0) then
  local key, value
  for key, value in pairs(properties) do
   obj[key] = value   
  end
 end

 if(get_pool_object(tag)==nil) then
  add(game_objects, obj)
  if obj:get_tag() == 'enemy' then add(enemies, obj) end
 end

end

function get_pool_object(tag)
 for obj in all(game_objects) do
  if(obj:is_active() == false and obj:get_tag() == tag) then
   return obj
  end
 end
end

function move_toward(current, target, move_speed)
 if(move_speed == 0) then move_speed = 1 end
 
 local dist= distance(current, target)
 if dist < 1 then return end
 local direction_x = (target.x - current.x) / 60 * move_speed
 local direction_y = (target.y - current.y) / 60 * move_speed
 
 -- if direction_x > 500 or direction_y > 500 then return end
 if dist < 1 then dist = 0.25 end
 current.x += direction_x / dist
 current.y += direction_y / dist
 return current.x, current.y
end

function distance(current, target)
 if target == nil then return nil end
 local dist = sqrt((target.x - current.x)^2 + (target.y - current.y)^2)
 -- if dist > 178 then return 1 else return dist end 
 return sqrt((target.x - current.x)^2 + (target.y - current.y)^2)
end

function do_camera_shake()
 if abs(shkx)<0.1 or abs(shky)<0.1 then
  shkx=0
  shky=0
 else
  shkx*=-0.7-rnd(0.2)
  shky*=-0.7-rnd(0.2)
 end
end

function shake_camera(power)
 local shka=rnd(1)
 shkx+=power*cos(shka)
 shky+=power*sin(shka)
end

-- ##particles
function add_part(x, y ,tpe, size, mage, dx, dy, colarr)

 for obj in all(game_objects) do
  if(obj:is_active() == false and obj:get_tag() == tag) then
   obj:set_value(x,y,tag)
   obj:reset()
   return obj
  end
 end


 local p = {
  x=x,
  y=y,
  tpe=tpe,
  dx=dx,
  dy=dy,
  move_speed=0,
  size=size,
  age=0,
  mage=mage,
  col=col,
  colarr=colarr,
  active=true

 }

 add(part, p)
 return p
end

function update_part()
 for p in all(part) do
  p.age+=1
  if p.mage != 0 and p.age >= p.mage or p.size <= 0 then
   del(part, p)
  end
  
  -- if p.colarr == nil then return end
  if #p.colarr==1 then
   p.col=p.colarr[1]
  else
   local ci=p.age/p.mage
   ci=1+flr(ci*#p.colarr)
   p.col=p.colarr[ci]
  end
  p.x+=p.dx
  p.y+=p.dy
 end
end
function hit_part(x,y,colarr)
  for i=0, rnd(6)+4 do
  local p = add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 1, rnd(4)+3, rnd(5)+35, (rnd(10)-rnd(10))/30, (rnd(10)-rnd(10))/30, colarr)
 end
end
function add_decors(n,x,y)
 local p = add_part(x, y, 6, n, 0, 0, 0, {0})
end

function draw_part()
 for p in all(part) do
  if p.tpe==0 then
   pset(p.x+shkx, p.y+shky, p.col)
  elseif p.tpe==1 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
   p.size -= 0.1

  elseif p.tpe==2 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
   p.size += 0.025
  elseif p.tpe==3 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
   p.size -= p.speed
  elseif p.tpe==5 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
  elseif p.tpe==6 then
   spr(p.size,p.x+shkx, p.y+shky)
  elseif p.tpe==7 then
   spr(p.size,p.x+shkx, p.y+shky)
   p.dx, p.dy *= 0.25, 0.25
  elseif p.tpe==8 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
   p.size -= 0.1
   p.dx, p.dy *= 0.25, 0.25
  elseif p.tpe==9 then
   circfill(p.x+shkx,p.y+shky,p.size,p.col)
   p.size -= p.age/200
   p.dx *= 0.8
   p.dy *= 0.8
   if p.size < 0 then del(part,p) end
  end
 end
end

function smoke_part(x, y)
 for i=0, 10 do
  local p = add_part(x, y, 9, 10, rnd(10)+100, (rnd(30)-rnd(30))/100, (rnd(30)-rnd(30))/100,{6, 5, 0})
  p.size=rnd(2)+2
  p.col = 5 + rnd(2)
 end
end

function smoke_part_custom(x, y, size, mage, speed, colarr)
  local move_speed = speed
    local p = add_part(x+rnd(4)-rnd(4), y+rnd(4)-rnd(4), 3, size, mage, rnd(move_speed)-rnd(move_speed),rnd(move_speed)-rnd(move_speed),colarr)
    p.speed = move_speed
end

function dust_part(x, y, size, mage, speed, move_speed, colarr)
 local p = add_part(x+rnd(2)-rnd(2), y+rnd(2)-rnd(2), 3, size, mage, rnd(move_speed)-rnd(move_speed),rnd(move_speed)-rnd(move_speed),colarr)
 p.speed = speed
 p.move_speed = move_speed
end

function blood_part(x, y, quantity, colarr)
 for i=0, quantity do
  add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 5, rnd(6)+3, 500, 0, 0,colarr)
  -- add_part(x, y ,tpe, size, mage, dx, dy, colarr)

 end
end

function draw_outline_spr(n, x, y)
 local outline_col = 2
 for i=0, 15 do
  pal(i, outline_col)
 end
 spr(n,x+1+shkx, y+shky)
 spr(n,x-1+shkx, y+shky)
 spr(n,x+shkx, y+1+shky)
 spr(n,x+shkx, y-1+shky)
 -- spr(n,x+1, y)
 -- spr(n,x-1, y)
 -- spr(n,x, y+1)
 -- spr(n,x, y-1)
 pal()

end

-- ##spe_print
function spe_print(text, x, y, in_col, out_col, ui_state)
 if(text == nil or text =='') then return end
 if ui_state == false then
  if(x <= 8) then x = 9 elseif x >=140 then x=140 end
  if(y <= 8) then y = 9 elseif y>=140 then y=140 end
 end
 if in_col == 0 and out_col == 0 or in_col==nil or out_col==nil then
  in_col = 10
  out_col = 9
 end

 local outlinecol = 2
 -- black outline
 print(text, x-1+shkx, y+shky, outlinecol)
 print(text, x+1+shkx, y+shky, outlinecol)
 print(text, x+1+shkx, y-1+shky, outlinecol)
 print(text, x-1+shkx, y-1+shky, outlinecol)
 print(text, x+shkx, y-1+shky, outlinecol)
 print(text, x+1+shkx, y+1+shky, outlinecol)
 print(text, x-1+shkx, y+1+shky, outlinecol)
 print(text, x+1+shkx, y+2+shky, outlinecol)
 print(text, x-1+shkx, y+2+shky, outlinecol)
 print(text, x+shkx, y+2+shky, outlinecol)
 -- in and out color text.
 print(text, x+shkx, y+1+shky, out_col)
 print(text, x+shkx, y+shky, in_col)
end

function search_gameobject(tag)
 for obj in all(game_objects) do
  if obj:get_tag() == tag then return obj end
 end
 return nil
end

-- ##show_message
function show_message(_text, _x, _y, _in_color, _out_color, _speed, _display_time, tag, moving, ui_state)
 local col1, col2 = 9, 4
 -- local obj = search_gameobject(tag) 
 -- if(obj != nil and obj:is_active() == false) then 
 --  obj:set_properties(_text, _x, _y, _in_color, _out_color, _speed, _display_time)
 --  obj:enable()
 --  return obj  
 -- end
 local msg = make_game_object(_x, _y, tag, {
  text=_text, 
  in_color = _in_color,
  out_color = _out_color, 
  speed = _speed,
  moving_speed=3,
  display_time = time()+_display_time,
  reset=function(self)
   self:enable()
   self.timer = 0
   self.moving_speed=4
  end,
  set_properties=function(self, text, x, y, in_color, out_color, speed, display_time)
   self.text=text
   self.x=x
   self.y=y
   self.in_color=in_color
   self.out_color=out_color
   self.speed=speed
   self.display_time=time()+display_time
   self:reset()
  end,
  update=function(self)

   if moving then self.y -= self.moving_speed 
    if(self.moving_speed>=0.1) then self.moving_speed*=0.8 
    end
   end
   if(time()>= self.display_time) then 
    self:reset()
    self:disable()
   end
  end,
  blink_color=function(self)
   if(time()*self.speed%4 >= 2) then return true else return false end
  end,
  draw=function(self)
   if ui_state then 
    if(self:blink_color()) then
    spe_print(self.text, self.x, self.y, 15, 4, true)
    else
    spe_print(self.text, self.x, self.y, col1, col2, true)
    end

   else
    if(self:blink_color()) then
    spe_print(self.text, self.x, self.y, 15, 4)
    else
    spe_print(self.text, self.x, self.y, col1, col2)
    end
   end
  end
  })
 if msg != nil then
  msg:set_properties(_text, _x, _y, _in_color, _out_color, _speed, _display_time)
  return msg
 end

 end

__gfx__
22ff9944000000000000000000000000000000000009900000000000000000000000000000000000900900090000000022222444444422222222222200000000
22ff9944000990000009900000099000000000000009900000000000000000000000000000000000900909090099990022222499994422222299992200000000
22ff99440009900000099000000990000009900040044004000000000000000000000000000900004009090909499490222999ff999922222292292200000000
22ff994400044000000440000004400000444400040440400000000000000000000000000009090009040904099949902299fffffff999222222292200000000
22ff99440044440044444440044444440044440000044000000000000099940000000000090990000900090009999990999ffffffffff9922229922200000000
22ff994404044040400440000004400400099000000000000000000009944440000994000099400004900990004949002fffffffffffff992229222200000000
22ff994400000000000000900900000000000000090000900000000004444440009444400094400000900490009494009ffffffff99999f92222222200000000
22ff994400900900000900000000900000000000000000000000000000000000000000000000000000400040000000009ffffff9999999992229222200000000
00099000000440000004400000044000000000000009900099000099000000000099990000000000000000000000000099ffff92999999990000000000000000
00099000004994000049940000499400000000000044440094444449000000000090090000000400000002000000000099ffff99999992990000000000000000
00099000004444000044440000444400000000000444444004444440000000000000090000000420000002900000000092ffff99999999990000000000000000
000990000009900000044000000440000000000094422449044224400000000000099900224444209922229000000000999ff999999999990000000000000000
00099000000990004449944004499444000000009442244904422440099999000009000022444422992222990000000099999999992999920000000000000000
09999990049999404004400000044004000000000444444004444440049994000000000022444420992222900000000022999929999999220000000000000000
00999900400990040090000000000900000000000044440094444449004940000009000000000420000002900000000022229999999922220000000000000000
00099000004004000000090000900000000000000009900099000099000400000000000000000400000002000000000022222444444222220000000000000000
00099000000440000004400000044000000000000000000000000000000000000000000000000000000200000004420200000000000000009000000000000000
00999900004224000049240000492400000000002200000000999990099000000990092000000000022222000000442000000099990000009990000000000099
099999900044440000444400004444000000000002220900009244900099900009999920004224004444444000044442000999ff999900009949900000009990
0009900000022000000440000004400000000000920029900094449002900940099992200029920000444000004444420099fffffff999000944499999994900
000990000002200044422440044224440000000099999999999244900244444409999220002992000044400004444404999ffffffffff9900944444444444900
0009900004222240400440000004400400000000920029909444449002900940009922000042240000444000244440009fffffffffffff990094444444444900
0009900040022004002000000000020000000000022209009444449000999000000220000000000000222000224400009ffffffff99999f90094444444449000
0009900000400400000002000020000000000000220000009999999009900000000000000000000000222000022000009ffffff9999999990094444444449000
00000000000220000002200000022000444224444442244400000000000000000000000000090000000229090000000099ffff99999999990094444444449000
0000000000944900009449000094490004222240042222400000000000ffff000000000009999900000022900000000000000000000000000094444444449000
000000000044440000444400004444000492294004922940009222000f9229f00049940022222220000222290000000000000000000000000094444444449000
000000000099990000999904409999000022220220222200022292200f2992f00099990000222000002222290000000000000000000000000094444444449000
000000000444444004444400004444400222220000222220029222900f2992f00099990000222000022222020000000000000000000000000094444444449900
000000000009900000099000000990000002200000022000022292200f9229f00049940000222000922220000000000000000000000000000094499999944490
0000000000099000040990000009904002022000000220200004400000ffff000000000000999000992200000000000000000000000000000944990000099490
00000000004004000000040000400000000002000020000000044000000000000000000000999000099000000000000000000000000000000999000000000999
000000004999999422222222f22224244242222f222222220000000049999444444999940000000094f2f2499999999999999999000000000000000000000000
0000000049999994999242f22ff2442442442ff22f24299900000000929929444492992900000000942f2f499994444444444999000000000000000000000000
9999999949999994992f242ff2f294f44f492f2ff242f2990000000099929944449992990000000094f2f249994ffffffffff499000000000000000000000000
2444444249999994299222f22ff2442222442ff22f22299200000000999999444499999900000000942f2f4994f2ffffffff2f49000000000000000000000000
2999999249999994f22ff229422f22ffff22f224922ff22f0000000042929244444292920000000094f2f24994ff2ffffff2ff49000000000000000000000000
24444442499999942ff2f2999492ff2ff2ff2949992f2ff200000000492924444449292400000000942f2f4994fff2ffff2fff49000000000000000000000000
2949949249999994f22ff299442f22ffff22f244992ff22f0000000044444444444444440000000094f2f24994ffff2442ffff49000000000000000000000000
29499492499999942222222922922422224229229222222200000000444444444444444400000000942f2f4994ffff4994ffff49000000000000000000000000
294994924444444422292292222924244242922229229222000000004999944444499994000000009999999994ffff4994ffff49000000000000000000000000
294994929999999929922499449944244244994499422992000000009299294444929929000000004444444494ffff2442ffff49000000000000000000000000
2949949299999999f22ff2999499942442499949992ff22f00000000999299444499929900000000f2f2f2f294fff2ffff2fff49000000000000000000000000
29499492999999992ff2f2994429422442249244992f2ff2000000009999994444999999000000002f2f2f2f94ff2ffffff2ff49000000000000000000000000
2949949299999999f22ff29942f22ff22ff22f24992ff22f00000000429292444442929200000000f2f2f2f294f2ffffffff2f49000000000000000000000000
294994929999999929922499942ff2f22f2ff24999422992000000004929244444492924000000002f2f2f2f994ffffffffff499000000000000000000000000
29499492999999999999449942f22ff22ff22f249944999900000000444444444444444400000000444444449994444444444999000000000000000000000000
2949949244444444222222222222f224422f22222222222200000000999999999999999900000000999999999999999999999999000000000000000000000000
29499492444444442222222222222424424222222222222200000000422922922922922429229222000000000000000000000000000000000000000000000000
29499492499999949999449944994424424499449944999900000000422922922922922429229222000000000000000000000000000000000000000000000000
29499492499999949999949994999424424999499949999900000000422922922922922429229222000000000000000000000000000000000000000000000000
29499492499999949999449944994424424499449944999900000000422922922922922429229222000000000000000000000000000000000000000000000000
29499492499999949999449944994424424499449944999900000000499999999999999499999999000000000000000000000000000000000000000000000000
29999992499999949999949994999424424999499949999900000000422222222222222422222222000000000000000000000000000000000000000000000000
99999999499999949999449944994424424499449944999900000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999942292222922922424424229229222292200000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999942229229222292424424292222922922200000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999949999449944994424424499449944999900000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999949999949994999424424999499949999900000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999949999449944994424424499449944999900000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999949999449944994424424499449944999900000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999949999949994999424424999499949999900000000422222222222222422222222000000000000000000000000000000000000000000000000
00000000499999949999449944994424424499449944999900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444442222222222222424424222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000f0000000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000ff000000044440000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000ff000000044440000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000f99f00000044440000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000f999f000002222000000f99f0000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000f9999fff00244400000f949f0000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f99994449ff422400fff9994f0000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f99499999992444ff99999999f000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f949999999922229999999999f000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f449994999944449999999999f000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f999999999922229999944949f000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f999999ffff24429999994994f000000000000000000000000000000000000000000000000000000000000000000000000000000
000999900000000000000000f9949ff00002222ffff999994f000000000000000000000000000000000000000009999000000000000000000000000000000000
0099999900000000000000000f99f00000044440000ff9999f000000000000000000000000000000000000000099999900000022000000022000000000000000
0099999990000000000000000f99f0000002222000000f44f0000000000000000000000000000000000000000099999900000022000000022200000000000000
0099999990000000000000000fff00000004442000000f49f0000000000000000000000000000000000000000099999900000299200000022220000000000000
00999999900000000000000000ff000000044240000000fff0000000000000000000000000000000000000000099999900000299220000022220000000000000
00999999900000000000000000ff000000044420000000ff00000000000000000000000000000000000000000099999900000099922220022220000029490000
009999999000000000000000000f000000022220000000ff00000000000000000000000000000000000000000099999900000099944222222220022292242000
0099999990000000000000000000000000044440000000f000000000000000000000000000000000000000000099999900000002949999922222299299999000
00999999999999999999999999999999999222299999999999999999999999999999999999999999999999999999999900000000999999922229299229900000
00999999944444444444444444444444444242444444444444444444444444444444444444444444444444444499999900000229994999922229229999900000
00999999922222222222222222222222222224422222222222222222222222222222222222222222222222222299999900002999999299924229992944940000
00999999922222222222222222222222222444422222222222222222222222222222222222222222222222222299999900002999999222424229999992924000
00999999999999992999299229929222922222422229999229999229992229992299922999922922922922229299999900002994922000044222222929994200
00999999994494492494299229429229422424222299444294444924942224942944422944422922922992299299999900000009200000024220000229999200
00999999942292242292294929224994222222422299222292222922922222922922222922222922922949949299999900000009200000044220000002002000
00999999922292222292292929222492222444422294222292222922922222922499222999222922922924429299999900000022000000044220000002000000
00999999922292222292292499222292222222222292222292222922922222922244922944222922922922229299999900000022000000044420000000200000
00999999922292222292292299222292222424222299222292222922922222922222922922222922922922229299999900000022000000044420000000220000
00999999922999222999299249922999222242222249999249999422999929992999422999922999922922229299999900000002000000044420000000220000
00999999922444222444244224422444222444422224444224444222444424442444222444422444422422224299999900000000000000044420000000200000
00999999922222222222222222222222222444222222222222222222222222222222222222222222222222222299999900000000000000044440000000000000
00999999999999999999999999999999999222299999999999999999999999999999999999999999999999999999999900000000000000044440000000000000
00999999944444444444444444444444444444244444444444444444444444444444444444444444444444444499999900000000000000044420000000000000
00999999900000000000000000000000000444400000000000000000000000000000000000000000000000000099999900000000000000044400000000000000
00999999900000000000000000000000000444400000000000000000000000000000000000000000000000000099999900000000000000042200000000000000
00999999900000000000000000000000000422400000000000000000000000000000000000000000000000000099999900000000000000044000000000000000
00944449900000000000000000000000000222200000000000000000000000000000000000000000000000000094444900000000000000044400000000000000
00444444900000000000000000000000000022000000000000000000000000000000000000000000000000000044444400000000000000044440000000000000
00444444400000000000000000000000000000000000000000000000000000000000000000000000000000000044444400000000000000044440000000000000
00044444400000000000000000000000000000000000000000000000000000000000000000000000000000000004444000000000000000044440000000000000
00004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042240000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022220000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200000000000000
__map__
2c2d2c2d2c2d2c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1c1d1c1d1c1d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0d0c0d0c0d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1c1d1c1d1c1d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0d0c0d0c0d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1c1d1c1d1c1d4b5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a4a0c0d0c0d0c0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d61646544454a5050505050505067696850505050505050504a42436263410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41747554554a6060606060606077797860606060606060604a42437273412c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a42437273411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41646544454a0000000000000000000000000000000000004a42437273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a42437273411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0c0d41747554554a0000000000000000000000000000000000004a42437273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1c1d41646544454a0000000000000000000000000000000000004a52537273411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41747554554a0000000000000000000000000000000000004a42436263410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a52537273411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41747554554a0000000000000000000000000000000000004a42437273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a42436263411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41747554554a0000000000000000000000000000000000004a52537273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a42436263411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41747554554a0000000000000000000000000000000000004a52537273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a42436263411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41747554554a0000000000000000000000000000000000004a52537273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41646544454a0000000000000000000000000000000000004a42436263411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41646544454a0000000000000000000000000000000000004a42436263410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d41646544454a0000000000000000000000000000000000004a52537273411c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d41747554555b5a5a5a5a5a5a4b5a5a4c5a5a5a5a5a5a5a5a5c52537273410c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d7151515151515151515151515b5a5a5c51515151515151515151515151711c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d6060606060606060606060606060606060606060606060606060606060600c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d1c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d0c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d0c0d1c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d1c1d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001171311713117131270313703137031470314703157031670317703197031a7031b7031d7031e7031f7032e70327703147032d7032e70324703137032470324703247032470324703247032470324703
010200001b3230f033276131c61018610006100761007610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000c0130c0130c0130c0130c0130c013000002b1002c1002e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000336102e610126100b6100a1130111301113011130111301113011130111307203062030620002200012001f0001e0001d0001c0001b0000d0000c0000b0000b0000a0000010000100001000010000100
000000002f010230101b010150100f010080100201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000036153321532f1532d1532a15327153241532315322153211531e1531e1531c1531b1531a1531a15318153171531615314153101530f1530d1530c1530e1530c1530b1530915307153071530515304153
010300003963339623396133961301013010130101308003070030600304003040030300303003020030200302003020030200301003000030000300003000030000300003000030000300003000030000300003
010200003c6113061124611186110e611026110461104611000011d6011d601000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000100000211005110071100b1100d1100e1101011012110150101601018010190101a0101d0101f01022010230102601027010290102b0102e01030010310103301036010380103a0103c0103f0103f01000000
000200000f6200b620086100561003610016101d6000260024600216001a60017600156000f6000c6000860004600026000c6000a6000a600126000a60007600076000f600076000760007600076000a60037600
000400000102402024060140f0141801412004010040100401004040041e0041b0041600413004110040e0040b004080040400401004000040000400004000040000400004000040000400004000040000400004
000200000d04009040080400604004040020400100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400200f5131d711115121d0101151122713165201d022187211b5120f7230f5131b0220f5101b7222252116012137111d520110111b5201b7111b5230f7120f0211b5100f7211b5221b02316710135231d711
000300003f61034610306101861013610136100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003a51030510275101b5100c510055100351013500115000f5000a5000a50007500055000f0000f0000f0000f0000b6000b6000b600120000f00014000110000f0001000013000180001e0000f00037000
0102000021653216532165321653216532165336153321532f1532d1532a15327153241532315322153211531e1531e1531c1531b1531a1531a15318153171531615314153101530f1530d1530c1530e1530c153
01030000030230502306023070230a1230a1230c1230c1230f12311123111231312313123161231612316123165231852318523185231b5231b5231d5231f5232252324523275232e52330523355233a5233f523
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900200e023000000e033000000e023000000e023000000e023000000e0330000000000000000e033000000e023000000e033000000e023000000e023000000e023000000e0330000000000000000e03300000
010600202501224002240022400227012240022400224002250122400224002240022701224002270122400224002240022501224002270122400227012240022501224002240022400227012240022400224002
010a00200e023000000e033000000e023000000e023000000e023000000e033000000e023000000e023000000e023000000e033000000e023000000e023000000e023000000e033000000e023000000e02300000
010c00201a1030c1030310518105031050c1030c103031050c103031050c1033f1053f1050c1030c103031050c1030c10303105181050c1030c1030c103031050c1030c10303105181050c105031050310500000
010c0020000001a1030c1030310518105031050c1030c103031050c103031050c1033f1053f1050c1030c103031050c1030c10303105181050c1030c1030c103031050c1030c10303105181050c1050310503105
010c0020191041910519105191051b3031b3031b3031b3031e1041e1051e1051e10522105221052210500006191041910519105191051b1051b1061b1061b1061e1041e1051e1051e10522105221052210500006
010c0000040030e003100030e0030c0030c0030f1030d1030c0030e0030e0030c0030e1040e1040c0030c003101030e003101030e0030c0030c0030c0030c0030e0030e0030c0030e1030c1030c0030c0030c003
000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 14555740
02 14154040
00 15144040
00 16154040
00 16154040
00 16175740
00 16175840
00 16175858
02 16175859
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000


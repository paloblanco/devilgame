-- pokes and weirdness

-- twist devil
-- by palo blanco
-- 2021 jan 30

poke(0x5f5c, 255) -- no key repeat


-- thing class

thing = {}

function thing:init()
end

function thing:new(o)
 local o=o or {}
 local t={}
 for k,v in pairs(self) do
 	if type(v) == "table" then
 		newt = {}
 		for kk,vv in pairs(v) do
 			newt[kk]=vv
 		end
 		t[k]=newt
 	else
 		t[k] = v
 	end
 end
 for k,v in pairs(o) do
 	t[k] = v
 end
 setmetatable(t,self)
 self.__index=self
 t:init()
 return t
end



-- actor class

actor_props={
x=0,
y=0,
z=0,
dx=0,
dy=0,
dz=0,
px=0, -- pixel location
py=0,
pw=0,
xpadd=0,
ypadd=0,
zup=0, -- zdraw offset
yup=-0.2,-- ydraw offset
vel=0,
sp=2,
pix=16,
size=1,
sizex=1, -- collisions
sizey=1,
sizez=1,
speed=0.05,
fast=1,
grav=0.01,
ground=false,
jump=0.2,
angle=0.75,
flipme=false, -- mirror sprite
flipmey=false,
shadow=false,
cycle=0, --hold animation stuff
myzone=nil, --needs to be assigned
killme=false, --remove this actor?
children={}, -- limbs
parent=nil,
timer=0, -- some objects will have a timer
bumpwall=nil, -- direction of wall impact
canspin=0, -- needs to be under 0
spinning=false, -- spinning?
drawme=true, -- make invisible?
ball=false, -- jump spin?
hurt=0,
blink=0,
airjump=false,
hcount=1, -- repeated horizontal texture
vcount=1 -- repeated vertical texture
}

actor=thing:new(actor_props)

function actor:update_early()
end

function actor:update()
end

function actor:update_late()
end

function actor:make_actor_on_me(otherclass)
end

function actor:make_explosion(xoff,yoff,zoff,ss)
	xoff=xoff or 0
	yoff=yoff or 0
	zoff=zoff or 0
	ss=ss or 1
	local e = explosion:new({x=self.x+xoff,y=self.y+yoff,z=self.z+zoff,size=ss})
	e:assign_zone(self.myzone)
end

function actor:kill_me()
	del(self.myzone.actors,self)
	if (self.parent)	del(self.parent.children,self)
	for c in all(self.children) do
		c:kill_me()
	end
end

function actor:bump_me(other)
end

function actor:hurt_me()
end

function actor:bounce_off_head(other)
	self.dz=0.5*self.jump
	self.airjump=true
	self.z = max(self.z,other.z)
end

function actor:bump_check()
	for a in all(self.myzone.actors) do
		if (a==self) goto continue
		if (a==self.parent) goto continue
		if (abs(self.x-a.x) > a.sizex+self.sizex) goto continue
		if (abs(self.y-a.y) > a.sizey+self.sizey) goto continue
		if (abs(self.z-a.z) > a.sizez+self.sizez) goto continue
		a:bump_me(self)
		::continue::
	end
end

function actor:zone_check()
	-- use for entities who don't _move
	if (self.y > self.myzone.y1) self:assign_zone(self.myzone:get_far())
	if (self.y < self.myzone.y0) self:assign_zone(self.myzone:get_near())
end

function actor:bounceoffwalls()
	if (self.bumpwall == 0) self.dx = self.speed
	if (self.bumpwall == 1) self.dx = -self.speed
	if (self.bumpwall == 2) self.dy = -self.speed
	if (self.bumpwall == 3) self.dy = self.speed
end

function actor:_move()
	if abs(self.dx)+abs(self.dy)>0 then
	 if (not self.spinning) self.angle =atan2(self.dx,-self.dy)
		self.vel = self.speed*self.fast
	end
	
	if (self.spinning) self.angle = (self.angle+0.1)%1
		
	self.x += self.dx
	self.y += self.dy
	self.z += self.dz
		
	--walls
	self.bumpwall=nil
	z0=self.myzone
	if self.x < z0.x0+0.2 then
		self.dx=0
		self.x=z0.x0+0.2
		self.bumpwall=0
	end
	if self.x > z0.x1-0.2 then
		self.dx=0
		self.x=z0.x1-0.2
		self.bumpwall=1
	end
	
	if self.dy>0 then
		z2 = self.myzone:get_far()
		if self.y > z0.y1-0.2 then
			if z2 then	
				if (self.x<z2.x0+0.2 or
				self.x>z2.x1-0.2 or
				self.z<z2.z0-0.2 or
				self.z>z2.z1-0.5 or
				z0.lock) then
					self.dy=0
					self.y=z2.y0-0.2
					self.bumpwall=2
				elseif self.y > z2.y0 then
					self:assign_zone(z2) 
					if (self==player) add_to_visited_zones(z2)
				end
			else
				self.dy=0
				self.y=z0.y1-0.2
				self.bumpwall=2
			end
		end
	end
	
	if self.dy<0 then
		z2 = self.myzone:get_near()
		if self.y < z0.y0+0.2 then
			if z2 then
				if (self.x<z2.x0+0.2 or
				self.x>z2.x1-0.2 or
				self.z<z2.z0-0.2 or
				self.z>z2.z1-0.5) then
					self.dy=0
					self.y=z2.y1+0.2
					self.bumpwall=3
				elseif self.y < z2.y1 then
					self:assign_zone(z2) 
				end
			else
				self.dy=0
				self.y=z0.y0+0.2
				self.bumpwall=3
			end
		end
	end
	
	-- z movement
	self.dz += -self.grav
	
	-- ceiling
	if self.dz > 0 then
		if self.z+1>self.myzone.z1 then
			self.dz = 0
			self.z = self.myzone.z1 - 1
		end 
	end
	
	--floors
	if self.z < self.myzone.z0 then
		self.dz = 0
		self.z = self.myzone.z0
		self.ground = true
	end
	if not self.ground then
		self.cycle=7
	elseif self.vel > 0 then
		self.cycle += 1.5*self.fast
	else 
		self.cycle = 0
	end
end

function add_to_visited_zones(z2)
	add(zones_visited,z2)
end

function actor:assign_zone(z)
	oldz=self.myzone
	if oldz then
		del(oldz.actors,self)
	end
	self.myzone=z
	add(z.actors,self)
	for c in all(self.children) do
		c:assign_zone(z)
	end
	self:zone_special(z)
end

function actor:zone_special(z)
	-- used at end of assign zone
end

function actor:draw()
	--self:drawshadow()
	self:_drawself()
end

ball1={40,42,46}
ball2={38,44,46}
ballspin=1

function actor:draw_humanoid(sp_lookup)
	ix_a = flr(self.angle*8.01)+1
	ix_a = min(ix_a,8)
	sprite = sp_lookup[ix_a]
	self.flipmey=false
	
	if self.spinning then
		self.sp = sprite[1]
		if (rnd()>.5) self.sp=14
	elseif self.ball then
		if (self.angle*8)%4 > 1 and (self.angle*8)%4 < 3 then
			self.sp=ball1[1+flr(ballspin)]
			if (self.angle < 0.5) self.flipmey=true
		else
			self.sp=ball2[1+flr(ballspin)]
		end		
	else
		self.sp = sprite[1]	
	end
	self.flipme = sprite[2]
	zupt = 0.2+0.15*abs(sin(self.cycle/30))
	self.zup += (zupt-self.zup)/2
	self:_drawself()
end

function actor:drawshadow()
	zs = self.myzone.z0
	local xs1,ys1,s01 = point2pix(self.x,self.y-0.3*self.size,zs)
	local xs2,ys2,s02 = point2pix(self.x,self.y+0.3*self.size,zs)
	ovalfill(xs1-s02*0.4*self.size,
	         ys1,
	         xs1+s02*0.4*self.size,
	         ys2,
	         0)	
end

function actor:_drawself()
	if self.hurt>0 then
		if self.hurt%4<2 then
			self.xpadd = (flr(rnd(3))-1)*3
			self.ypadd = (flr(rnd(3))-1)*3
			pal(8,7)
		end
		self.hurt += -1
	else
		self.xpadd,self.ypadd=0,0
		pal(8,8)
	end
	
	local xp0,yp0,s0 = point2pix(self.x,self.y+self.yup,self.z+self.zup)
	local xpix=xp0-s0*0.5*self.size+0.5+self.xpadd
	local ypix=yp0-s0*self.size+self.ypadd
	
	sspr((self.sp%16)*8,
	     flr(self.sp/16)*8,
	     self.pix,self.pix,
	     xpix,ypix,
	     s0*self.size,s0*self.size,
	     self.flipme,self.flipmey)
	self.px = xpix
	self.py = ypix
	self.pw = s0*self.size*0.5
end

function actor:draw_span()
    --spikes
    local xp0,yp0,s0 = point2pix(self.x,self.y+self.yup,self.z+self.zup)
	local xpix=xp0-s0*0.5*self.size+0.5+self.xpadd
	local ypix=yp0-s0*self.size+self.ypadd
	
	for xoff=1,self.hcount,1 do
        for yoff=1,self.vcount,1 do
            sspr((self.sp%16)*8,
            flr(self.sp/16)*8,
            self.pix,self.pix,
            xpix+(s0*(xoff-1)),
            ypix-(s0*(yoff-1))-1,
            s0*self.size+1,s0*self.size+1,
            self.flipme)
        end
	end
	self.px = xpix
	self.py = ypix
	self.pw = s0*self.size*0.5
    
end


-->8
-- game loop and logic

-- states:
-- title, levels, level-transition
-- finale

-- globals
function init_globals()
	level_max=6
	level_now=1
	level_address_list = return_level_start_addresses()
end

-- level mode

function init_level(levelnum)
	lev = 0
	lev = level:new()
	address_load = level_address_list[levelnum]
	level_mem = level_from_mem(address_load)
	lev:init_arg(level_mem)
	function level_update()
		lev:update()
	end
	_update60 = level_update
	function level_draw()
		lev:draw()
		-- hud
		draw_hud()
	end
	_draw = level_draw
	cam3dx = 4
	cam3dy = -6
	cam3dz = 5.5
	set_colors(levelnum)
end

function _init()
	init_globals()
	init_title()
end

-- extra things

function draw_hud()
	color(7)
	print("cpu: "..flr(100*stat(1)),1,1)
	print(player.bumpwall,1,7)
	print("mem: "..flr(100*stat(2)),1,13)
	print("lev: "..level_now,1,19)
	color()
end

-->8
-- player character
p_props={
x=4,
y=-2,
z=0,
zup=0.2,
shadow=true,
sizex=0,
sizey=0,
sizez=0}

p1 = actor:new(p_props)

function p1:init()
	rleg = rightleg:new({parent=self})
	add(self.children,rleg)
	lleg = leftleg:new({parent=self})
	add(self.children,lleg)
	rarm = rightarm:new({parent=self})
	add(self.children,rarm)
	larm = leftarm:new({parent=self})
	add(self.children,larm)
	-- declare to global scope
	player = self
end

function p1:update()
	self.dx=0
	self.dy=0
	self.vel=0
		
	-- running and spinning
	self.fast=1.5 --1
	self.canspin = max(self.canspin-1,0)
	if (self.canspin < 10) self.spinning=false	
	if (btn(5)) self.fast = 1.5
	--if (self.spinning) self.fast = 1
	
	if btnp(5) and self.canspin <=0 then
		self:make_spinner() 
		self.canspin=40
		self.spinning=true
	end

	if (btn(0)) self.dx = -self.speed*self.fast
	if (btn(1)) self.dx = self.speed*self.fast
	if (btn(2)) self.dy = self.speed*self.fast
	if (btn(3)) self.dy = -self.speed*self.fast
	if (btnp(4) and self.ground) then
		self.dz = self.jump
		self.ground = false
		self.ball = true
	elseif btn(4) and self.airjump then
		self.dz = self.jump
		self.airjump=false
	end
	
	if (btn(0) or btn(1)) and (btn(2) or btn(3)) then
		self.dx *= 0.707
		self.dy *= 0.707
	end
	
	if self.blink > 0 then
		if (self.blink%6 < 4) self.drawme = not self.drawme
		self.blink += -1
		if (self.blink <= 0) self.drawme=true
	end
	
	self:_move()	
	if self.ground then
		self.ball = false
		self.airjump = false
	end
	ballspin = (ballspin+0.5)%3
end

function p1:make_spinner()
	spin = spinner:new({x=self.x,y=self.y,z=self.z,parent=self})
	add(self.children,spin)
	spin:assign_zone(self.myzone)
end

function p1:update_late()
	self:bump_check()
end

function p1:send_to_flag()
	self.x = current_flag.x
	self.y = current_flag.y-0.5
	self.z = current_flag.z
	self:assign_zone(current_flag.myzone)
	cam_snap(self)
end

function p1:hurt_me()
	if self.blink <= 0 then
		self.blink=60
		self.hurt=30
		freeze=30
	end
end


p1_sprites = {
{4,true},
{6,true},
{8,false},
{6,false},
{4,false},
{4,false},
{2,false},
{4,true},
}

function p1:draw()
	self:draw_humanoid(p1_sprites)
end

limb = actor:new({sp=1})
limb.myx=0.25
limb.myy=0.05
limb.myz=0.0
limb.pix=8
limb.size=0.5
limb.sp=1
limb.parent={}

function limb:init()
	self.y = self.parent.y
	self.x = self.parent.x
	self.z = self.parent.z
end

function limb:update_early()
	self.drawme=true
 if (self.parent.spinning or self.parent.ball) self.drawme=false
end

function limb:update_late()
	local a = self.parent.angle
 local xx =  self.parent.x
 local yy =  self.parent.y
 local zz =  self.parent.z
 self.x = xx+sin(a)*self.myx + cos(a)*self.myy
 self.y = yy+cos(a-0.5)*self.myx + sin(a)*self.myy
 self.z = self.myz+zz
end

function limb:draw()
	self:_drawself()
end

rightleg=limb:new()
function rightleg:update()
 myyt = 0.05+0.5*sin(self.parent.cycle/30)
 self.myy = (myyt-self.myy)/2
 myzt = 0.5*abs(sin(self.parent.cycle/30))
 self.myz = (myzt-self.myz)/2
end

leftleg=limb:new()
leftleg.myx=-0.25
function leftleg:update()
 myyt = 0.05-0.5*sin(self.parent.cycle/30)
 self.myy = (myyt-self.myy)/2
 myzt = 0.5*abs(sin(self.parent.cycle/30))
 self.myz = (myzt-self.myz)/2
end


arm=limb:new()
arm.sp=17
arm.myz=0.05

function arm:update()
	self.myz = 0.10+self.parent.zup
	myyt = .1-self.myx*sin(self.parent.cycle/30)
	self.myy = (myyt-self.myy)/2
end

rightarm=arm:new()
leftarm=arm:new()
leftarm.myx=-0.25
-->8
-- 3d environment setup

-- convenience
function tand(ang)
 if (ang == 90 or ang == 270) return 0
 angn = ang/360
 return (sin(angn)/cos(angn))
end

sin1 = sin 
function sin(angle) 
	return -sin1(angle) 
end

function acos(xx)
	local yy = sqrt(1-xx*xx)
	return atan2(xx,yy)
end

-- drawing constants
fov=60
shrink = tand(fov/2)
nearplane=2
farplane=20
widthplane=8 -- in blocks
draw_table={}
cam3dx = 4
cam3dy = -6
cam3dz = 5.5
camfar = farplane + cam3dy
camnear=nearplane + cam3dy
cam3dxmid = 64
cam3dymid = 8 --where the horizon is
mid_target_0 = 4
mid_target = mid_target_0

-- return screen pix from point
function point2pix(x,y,z)
	camx = x-cam3dx
	camy = y-cam3dy
	camz = z-cam3dz
	scale = 64/(shrink*camy)
	local xpix = camx*scale + cam3dxmid
	local ypix = cam3dymid - camz*scale
	return xpix, ypix, scale
end

function cam_update(target)
	damp=16
	z = target.myzone

	cam_targetx = target.x + 25*target.dx
	cam_targetx = max(cam_targetx,z.x0+2)
	cam_targetx = min(cam_targetx,z.x1-2)
	if (z.dx<=4) cam_targetx = (z.x0+z.x1)/2
	dcamx = (cam_targetx-cam3dx)/damp

	cam_targetz0 = max((target.z) + 4.0, (z.z0) + 5.0)
	-- cam_targetz = (z.z0) + 5.0
	cam_targetz = min(cam_targetz0,z.z1-.75)
	zscale = (cam_targetz0 - cam_targetz)/5.0
	-- zscale = (z.z0 + 5.0 - cam_targetz)/5.0
	--mid_target = mid_target_0+56*zscale
	mid_target = mid_target_0+56*zscale
	dcamz = (cam_targetz-cam3dz)/(12)
	dmid = (mid_target - cam3dymid)/12

	yscale = (5-min(5,z.dz))/4--(2.5)/5.0
	ty=target.y
	cam_targety = ty-6*(1-.5*yscale) + 20*target.dy
	dcamy = (cam_targety-cam3dy)/damp

	cam3dx += dcamx
	cam3dy += dcamy
	cam3dz += dcamz
	cam3dymid += dmid

	camfar = farplane + cam3dy
	camnear=nearplane + cam3dy
end

function cam_snap(target)
	cam_update(target)
	cam3dx = cam_targetx
	cam3dy = cam_targety
	cam3dz = cam_targetz
	cam3dymid = mid_target
	camfar = farplane + cam3dy
	camnear=nearplane + cam3dy
end

-- drawing utility functions
function sort_by_y(tab)
	local newtab = {}
	done=false
	while not done do
  done=true
		for k,v in pairs(tab) do
	  if k > 1 then
	  	if v.y > tab[k-1].y then
	  		local temp = tab[k-1]
	  		tab[k-1] = v
	  		tab[k] = temp
	  		done = false
	  	end
	  end
		end
	end
	return tab
end
-->8
-- zone code
-- zones = {}

zone = thing:new()
zone.x0=0
zone.y0=0
zone.z0=0
zone.x1=8
zone.y1=8
zone.z1=8
zone.coins=0
zone.baddies=0
zone.keys=0
zone.lock=false

lockp=0b0111101111011110.1

function zone:init()
	self.dx=self.x1-self.x0
	self.dy=self.y1-self.y0
	self.dz=self.z1-self.z0
	self.nearneighbors={}
	self.farneighbors={}
	self.neighbors={}
	self.actors={}
	-- self.actor_template={}
	self.actors_original={}
	self.wall={{0,0,
	self.dx,self.dz}}
	self.window={0,0,0,0}
end

function zone:reset_actors()
	for aa in all(self.actors_original) do
		aa:kill_me()
		del(self.actors_original,aa)
	end
	self.actors={}
	self.coins=0
	self.baddies=0
	self.keys=0
	self.lock=false
	for act_table in all(self.actor_template) do
		inst = self:make_actor(act_table)
		add(self.actors_original,inst)
	end
end

function zone:make_actor(al)
	myact=acreator[al[1]]
	myinst=myact:new({x=al[2]+0.5+self.x0,
		y=al[3]+0.5+self.y0,
		z=al[4]+self.z0})
	myinst:assign_zone(self)
	return myinst
end

function zone:add_farneighbor(z)
	add(self.farneighbors,z)
	add(self.neighbors,z)
	add(z.nearneighbors,self)
	add(z.neighbors,self)
	self:make_wall()
end

function zone:make_wall()
	-- only supports 1 wall
	-- walls need to be deltas
	-- from x0,z0
	-- also makes a window
	self.wall={}
	f=self.farneighbors[1]
	if f then
		if self.x0<f.x0 then
			delx=f.x0-self.x0
			add(self.wall,{0,0,delx,self.dz})
		end
		if self.x1>f.x1 then
			--delx = self.x1-f.x1
			add(self.wall,{f.x1-self.x0,0,self.dx,self.dz})
		end
		if self.z0<f.z0 then
			delz = f.z0-self.z0
			xx0=max(0,f.x0-self.x0)
			xx1=min(self.dx,f.x1-self.x0)
		--add(self.wall,{xx0,self.z0,xx1,delz})
		add(self.wall,{xx0,0,xx1,delz})
		end
		if self.z1>f.z1 then
			delz = self.z1-f.z1
			xx0=max(0,f.x0-self.x0)
			xx1=min(self.dx,f.x1-self.x0)
			add(self.wall,{xx0,f.z1-self.z0,xx1,self.dz})
		end
		x0win=max(f.x0-self.x0,0)
		y0win=max(f.z0-self.z0,0)
		x1win=min(f.x1-self.x0,self.dx)
		y1win=min(f.z1-self.z0,self.dz)
		self.window={x0win,y0win,x1win,y1win}
	end
end

function zone:draw()
--	c1,c2,c3=2,0,13	
	iy = flr(camfar)
	if (self.y0>iy or self.y1<flr(cam3dy+nearplane)) return
	yfar = min(iy+1,self.y1)
	ynear= max(self.y0,flr(camnear))
	x0,y0,s0 = point2pix(self.x0,yfar,self.z0)
	x1,y1,s1 = point2pix(self.x0,ynear,self.z0)
	dx = self.dx
	dz = self.dz
	dy = yfar-ynear
	--window coords
	wx0=x0+s0*self.window[1]
	wy0=y0-s0*self.window[2]
	wx1=x0+s0*self.window[3]
	wy1=y0-s0*self.window[4] -- smaller than wy0
	--user facing walls
	if player.y > self.y1 then
		if player.px+player.pw < wx0 or
					player.px+player.pw > wx1 or
					player.py+player.pw > wy0 or
					player.py+player.pw < wy1 then
			dwalls=false
			dfloors=false
		end
	end
	if yfar == self.y1 then
		if dwalls then
			for w in all(self.wall) do
				xw0=x0+s0*w[1]
				yw0=y0-s0*w[2]
				xw1=x0+s0*w[3]
				yw1=y0-s0*w[4]
				rectfill(xw0,yw0,xw1,yw1,c3)
			end
		end
		if self.lock then
			fillp(lockp)
			palt(1,true)
			rectfill(wx0,wy0,wx1,wy1,c2)
			palt()
			fillp()
		end
		rect(wx0,wy0,wx1,wy1,c2)
	end
	-- walls and ceilings
	if dfloors then
		if (y1>y0)rectfill(x1,y1,x1+dx*s1,y0,c1)
		if (x1 < x0) rectfill(x1,y0,x0,y1-dz*s1,c1)
		if (x1+dx*s1 > x0+dx*s0 ) rectfill(x1+dx*s1,y0,x0+dx*s0,y1-dz*s1,c1)
		if (y0-dz*s0>y1-dz*s1) rectfill(x0,y0-dz*s0,x0+dx*s0,y1-dz*s1,c1)
	end
	--lines running along y									
	for xstep=0,dx,1 do
		line(x0+xstep*s0,y0,
		x1+xstep*s1,y1,c2)
	end
	--lines running along x
	for ystep=0,dy,1 do
		xh,yh,sh = point2pix(self.x0,yfar-ystep,self.z0)
		--floor
		line(xh,yh,xh+dx*sh,yh,c2)
		--ceiling
		line(xh,yh-dz*sh,xh+dx*sh,yh-dz*sh,c2)
		--up walls
		line(xh,yh,xh,yh-dz*sh,c2)
		line(xh+dx*sh,yh,xh+dx*sh,
						yh-dz*sh,c2)
	end
	line(x0+dx*s0,y0-dz*s0,x1+dx*s1,y1-dz*s1,c2)
	line(x0,y0-dz*s0,x1,y1-dz*s1,c2)
end


function zone:update()
	for a in all(self.actors) do
		a:update_early()
	end
	for a in all(self.actors) do
		a:update()
	end
	for a in all(self.actors) do
		a:update_late()
	end
end

function zone:lock_me()
	self.lock=true
	zf = self:get_far()
	xx = zf.x0+0.5*zf.dx
	zz = zf.z0+0.5*zf.dz
	yy = zf.y0-.1
	local l = lock:new({x=xx,y=yy,z=zz})
	l:assign_zone(self)
end

function zone:get_far()
	return self.farneighbors[1]
end

function zone:get_near()
	return self.nearneighbors[1]
end
-->8
-- objects
coin = actor:new()
coin.sp=10
coin.pix=8
coin.size=0.8
coin.shadow=true

function coin:init()
	self.cycle = flr(15*rnd())
end

function coin:bump_me(other)
	self:kill_me()
end

coin_sprites = {10,11,26,
27,26,11}

function coin:update()
	self.cycle = (self.cycle+1)%15
	ix = flr((self.cycle/15)*6)+1
	self.sp = coin_sprites[ix]
end

function coin:zone_special(z)
	z.coins += 1
end

portal = actor:new()
portal.sp=12
portal.shadow=true

function portal:bump_me(other)
	level_now += 1
	if level_now == level_max+1 then
	    init_ending()
	else
		init_transition()
	end
end

flag = actor:new()
flag.sp=91
flag.pix=8
flag.shadow=true

function flag:bump_me(other)
	if current_flag != self then
		current_flag = self
		zones_visited={}
		self.sp = 74
		self:make_explosion()
	end
end



spikes = actor:new()
spikes.sp=75
spikes.pix=8
spikes.shadow=false
spikes.hcount=1
spikes.sizex = 100 -- super wide so it spans the level
spikes.sizez = 0.25 -- super wide so it spans the level

function spikes:bump_me(other)
	other:hurt_me()
end

function spikes:zone_special(z)
	self.hcount=z.x1+0.5-self.x
	if self.y+1 < z.y1 then
		ss = spikes:new({x=self.x,y=self.y+1,z=self.z})
		ss:assign_zone(z)
	end
end

function spikes:draw()
	self:draw_span()
end

balloon = actor:new()
balloon.sp=90
balloon.pix=8
balloon.shadow=true
balloon.timer2=0

function balloon:update()
	self.drawme=true
	if (self.timer2 > 0) self.drawme=false
	self.timer = (self.timer+1)%60
	self.zup = 0.2*sin(self.timer/60)
	self.timer2 = max(self.timer2-1,0)
end

function balloon:bump_me(other)
	if self.timer2 <= 0 and (other.spinning or other.ball) then
		local e = explosion:new({x=self.x,y=self.y,z=self.z})
		e:assign_zone(self.myzone)
		self.timer2=60
		if other.ball then
			other:bounce_off_head(self)
		end
	end
end

badguy = actor:new()
badguy.sp=32
badguy.shadow=true
badguy.zup=0.2
badguy.speed = 0.025
badguy.sp1=32
badguy.sp2=34

function badguy:make_legs()
 self.children={}
 rleg = rightleg:new({parent=self})
 add(self.children,rleg)
 lleg = leftleg:new({parent=self})
 add(self.children,lleg)
end

function badguy:make_s_list()
    self.sprites = {
        {self.sp1,true},
        {self.sp2,true},
        {self.sp2,true},
        {self.sp2,false},
        {self.sp1,false},
        {self.sp1,false},
        {self.sp1,false},
        {self.sp1,true},
    }
end

function badguy:init()
	self:make_legs()
    self:make_s_list()
end

function badguy:update()
	self.vel=0
	if self.timer <= 0 then
		self.dx = (flr(rnd(3))-1)*self.speed
		self.dy = (flr(rnd(3))-1)*self.speed
		if abs(self.dx)+abs(self.dy)>self.speed then
			self.dx *= .707
			self.dy *= .707
		end
  self.timer = 90 + flr(rnd(31)-15)
	elseif self.timer <= 30 then
		self.dx=0
		self.dy=0
	end
	if (self.y-0.6+self.dy < self.myzone.y0) self.bumpwall=3
	if (self.y+0.6+self.dy > self.myzone.y1) self.bumpwall=2
	self:bounceoffwalls()
	self.timer += -1
	self:_move()
end

function badguy:draw()
	self:draw_humanoid(self.sprites)
end

function badguy:bump_me(other)
	if other.spinning or other.ball then
		self:make_explosion()
		self:kill_me()
		if other.ball then
			other:bounce_off_head(self)
		end
	else
		other:hurt_me()
	end
end

function badguy:zone_special(z)
	z.baddies+=1
end

sentrylr = badguy:new()
sentrylr.speed*=1.5
sentrylr.dx = sentrylr.speed

function sentrylr:update()
	if (self.y-0.6+self.dy < self.myzone.y0) self.bumpwall=3
	if (self.y+0.6+self.dy > self.myzone.y1) self.bumpwall=2
	self:bounceoffwalls()
	self:_move()
end

sentryud = sentrylr:new()
sentryud.dy=sentryud.speed
sentryud.dx=0

sentrydr = sentryud:new()
sentrydr.dy=sentryud.speed*.707
sentrydr.dx=sentryud.speed*.707

laserv = sentrylr:new()
laserv.sp=96
laserv.pix=8
laserv.sizez=100
laserv.shadow=false

function laserv:init()
end

function laserv:zone_special(z)
	self.vcount=z.z1+0.5-self.z
end

function laserv:bump_me(other)
	other:hurt_me()
end

function laserv:update_late()
	self.timer = (self.timer+1)%60
	self.sp=96
	if (self.timer%6>2) self.sp=97
	if (self.timer%4==0) self:make_explosion(rnd()-.5,rnd()-0.5,0,0.75)
end

function laserv:draw()
	self:draw_span()
end

laserh = laserv:new()
laserh.sp = 112
laserh.sizez = 0.25
laserh.sizex = 100

function laserh:zone_special(z)
	self.hcount=z.x1+0.5-self.x
end

function laserh:update()
	if (self.z > self.myzone.z1 and self.speed > 0) or
	(self.z < self.myzone.z0 and self.speed < 0)  then
		self.speed = -self.speed
	end
	
	self.z += self.speed
end

function laserh:update_late()
	self.timer = (self.timer+1)%60
	self.sp=112
	if (self.timer%6>2) self.sp=113
	if self.timer%4==0 then
		self:make_explosion(-.5,rnd()-0.5,rnd()-.5,0.75)
		self:make_explosion(self.myzone.dx-.5,rnd()-0.5,rnd()-.5,0.75)
	end
end

function laserh:draw()
	self:draw_span()
end

macer = badguy:new()
macer.dx=0
macer.dy=0
macer.spinspeed=1/90
macer.sp=70
macer.sp1=70
macer.sp2=72

-- mc_sprites = {
-- {70,true},
-- {72,true},
-- {72,true},
-- {72,false},
-- {70,false},
-- {70,false},
-- {70,false},
-- {70,true},
-- }

function macer:init()
	self:make_legs()
	self:make_mace(3)
    self:make_s_list()
end

function macer:make_mace(mace_count)
	-- self.children={}
	for i=1,mace_count,1 do
		mm = mace:new({radius=i,parent=self,x=self.x,y=self.y,z=self.z})
		add(self.children,mm)
	end
end

function macer:update()
	self.angle = (self.angle + self.spinspeed) % 1
	self.cycle+=0.5
end

function macer:draw()
	self:draw_humanoid(self.sprites)
end

mace = actor:new()
mace.sp = 68
mace.radius = 1
mace.shadow=true

function mace:update()
	if self.parent then
		self.x = self.parent.x + self.radius*cos(self.parent.angle)
		self.y = self.parent.y + self.radius*sin(self.parent.angle)
		self:zone_check()
	end
end

function mace:bump_me(other)
	other:hurt_me()
end

spinner = actor:new()
spinner.zup=0.5
spinner.timer=30
spinner.size = 1.5
spinner.spinning=true
spinner.sizex=0.5
spinner.sizey=0.5
spinner.sizez=0.5

function spinner:init()
	self.y = self.parent.y
	self.x = self.parent.x
	self.z = self.parent.z
end

function spinner:update()
	self.y = self.parent.y
	self.x = self.parent.x
	self.z = self.parent.z
	self.timer+=-1
	self.angle = (self.angle+0.05)%1
	
	xpar=cos(self.angle)*0.75
	ypar=sin(self.angle)*0.75
	par1 = particle:new({x=self.x+xpar,y=self.y+ypar,z=self.z+self.zup})
	par1:assign_zone(self.myzone)
	par2 = particle:new({x=self.x-xpar,y=self.y-ypar,z=self.z+self.zup})
	par2:assign_zone(self.myzone)
	
	if self.timer < 0 then
		self:kill_me()
	end
end

function spinner:update_late()
	self:bump_check()
end

function spinner:draw()
end

gunnerud = sentryud:new()
gunnerud.sp = 76
gunnerud.sp1 = 76
gunnerud.sp2 = 78
gunnerud.guntime=0

function gunnerud:update_late()
	self.guntime=max(0,self.guntime-1)
	if self.guntime==0 then
		if abs(player.y-self.y)<.5 then
			local bullx = .05
			if (player.x<self.x) bullx *= -1
			local bull = bullet:new({x=self.x,y=self.y,z=self.z,dx=bullx})
			bull:assign_zone(self.myzone)
			self.guntime=60
		end
	end
end

gunnerlr = sentrylr:new()
gunnerlr.sp = 76
gunnerlr.sp1 = 76
gunnerlr.sp2 = 78
gunnerlr.guntime=0

function gunnerlr:update_late()
	self.guntime=max(0,self.guntime-1)
	if self.guntime==0 then
		if abs(player.x-self.x)<.5 then
			local bully = .05
			if (player.y<self.y) bully *= -1
			local bull = bullet:new({x=self.x,y=self.y,z=self.z,dy=bully})
			bull:assign_zone(self.myzone)
			self.guntime=60
		end
	end
end

bullet = actor:new()
bullet.sp = 68
bullet.shadow=true

function bullet:update()
	-- self.bumpwall=nil
	self:_move()
	self:bounceoffwalls()
	self:zone_check()
	if self.bumpwall then 
		self:make_explosion()
		self:kill_me()
	end
end

function bullet:bump_me(other)
	other:hurt_me()
end

particle = actor:new()
particle.timer=5

function particle:init()
end

function particle:update()
	self.size = self.timer / 20
	self.timer += -1
	if (self.timer < 0) self:kill_me()
	self.x+=self.dx
	self.y+=self.dy
	self.z+=self.dz
end

function particle:draw()
	local xp0,yp0,s0 = point2pix(self.x,self.y,self.z)
	circfill(xp0,yp0,s0*self.size,7)
end


explosion = actor:new()
explosion.sp=36
explosion.pix=8
explosion.size=1.8
explosion.shadow=false

function explosion:init()
	self.timer = 8
end

explosion_sprites = {53,52,37,36}

function explosion:update()
	self.timer += -1
	ix = 1+flr(self.timer/2)
	self.sp = explosion_sprites[ix]
	if (self.timer <= 0) self:kill_me()
end

lock = actor:new()
lock.sp=64
lock.pix=8
lock.size=1

function lock:update()
	if self.myzone.keys <=0 then
		self:kill_me()
		self.myzone.lock=false
	end
end


key = actor:new()
key.sp=66
key.pix=8
key.size=0.8
key.shadow=true

function key:init()
	self.cycle = flr(15*rnd())
end

function key:bump_me(other)
	self:kill_me()
	self.myzone.keys += -1
end

key_sprites = {66,67,82,
83}

function key:update()
	self.cycle = (self.cycle+1)%15
	ix = flr((self.cycle/15)*4)+1
	self.sp = key_sprites[ix]
end

function key:zone_special(z)
	z:lock_me()
	z.keys+=1
end
-->8
-- globals for levels
dwalls=true --are we drawing walls?
dfloors=true -- drawing perp surfaces?
freeze=0 -- screenfreeze?
current_flag=0

-- level object
c1,c2,c3=2,0,13 --l1
level_colors = {{2,0,13},{13,1,14},{2,0,13},{2,0,13},{2,0,13},{2,0,13}}
level = actor:new()
level.c1=2
level.c2=0
level.c3=13
level.zonelist={}
level.zones={}

function set_colors(ix)
	c1,c2,c3 = level_colors[ix][1],level_colors[ix][2],level_colors[ix][3]
end

-- make level from table
function level:init_arg(ll)
	self.zones={}
	current_flag=0 -- for respawn
	zones_visited={}
	for zl in all(ll) do
		self:add_to_zones(zl)
	end
	self:make_zonelist()
	for z in all(self.zonelist) do
		z:reset_actors()
	end
end

function level:add_to_zones(zl_all)
	lenzones = #self.zones
	if lenzones > 0 then
		last = self.zones[lenzones]
		xold = last.x0
		yold = last.y1
		zold = last.z0
	else
		xold = 0
		yold = 0
		zold = 0
	end
	zl = zl_all[1]
	za = zl_all[2]
	newzone = {x0=xold+zl[1],
		y0=yold,
		z0=zold+zl[2],
		x1=xold+zl[1]+zl[3],
		y1=yold+zl[4],
		z1=zold+zl[2]+zl[5],
		actor_template = za}
	add(self.zones,newzone)
end


function level:make_zonelist()
	self.zonelist={}
	for z in all(self.zones) do
		add(self.zonelist,zone:new(z))
	end
	for ix,z in pairs(self.zonelist) do
		if ix < #self.zonelist then
			z2=self.zonelist[ix+1]
			z:add_farneighbor(z2)
		end
	end
end


function level:update()
	if freeze > 0 then
		freeze += -1
		if (freeze == 10) self:respawn()
		return
	end
	for z in all(self.zonelist) do
		if (z.y0<=camfar and z.y1>=camnear) z:update()
	end
	cam_update(player)
	level.cycle += 1
	level.timer += level.cycle\60
	level.cycle = level.cycle%60
end

function level:respawn()
	if current_flag != 0 then
		for z in all(zones_visited) do
			z:reset_actors()
		end
		player:send_to_flag()
	else
		init_level(level_now)
		cam_snap(player)
	end
end

function level:draw()
	dwalls=true 
	dfloors=true
	cls(1)
	for iz=#self.zonelist,1,-1 do
		z=self.zonelist[iz]
		if (z.y0>camfar or z.y1<camnear) goto continue2
		z:draw()
		aa=sort_by_y(z.actors)
		palt(0,false)
		palt(1,true)
		for act in all(aa) do
			if (act.y>camfar or act.y<camnear) goto continue
			if (act.shadow) act:drawshadow()
			::continue::
		end
		for act in all(aa) do
			if (act.y>camfar or act.y<camnear or (not act.drawme)) goto continue
			act:draw()
			::continue::
		end
		palt()	
		::continue2::
	end
end
-->8
-- transitions
title = actor:new()

function title:update()
	if (btnp(4)) init_level(level_now)
	if (btnp(5)) init_level(level_now)
end

function title:draw()
	cls(0)
	color(8)
	print("devil game 3d")
	print("by palo blanco games")
	print("")
	print("press x or c to start")
end

function init_title()
	t = title:new()
	function t_update()
		t:update()
	end
	function t_draw()
		t:draw()
	end
	_update60 = t_update
	_draw = t_draw
end

transition = actor:new()
transition.ready=false

function transition:update()
	self.cycle+=1
	if (self.cycle>30) self.ready=true 
	if (btnp(4) and self.ready) init_level(level_now)
	if (btnp(5) and self.ready) init_level(level_now)
end

function transition:draw()
	--cls(0)
	rectfill(1,1,127,32,6)
	color(8)
	print("you beat level "..level_now-1,1,1)
	print("going to level"..level_now,1,7)
	print("press x or c to start",1,17)
end

function init_transition()
	t = transition:new()
	function t_update()
		t:update()
	end
	function t_draw()
		t:draw()
	end
	_update60 = t_update
	_draw = t_draw
end

ending = actor:new()
ending.ready=false

function ending:update()
	self.cycle+=1
	if (self.cycle>30) self.ready=true 
	if (btnp(4) and self.ready) init_level(level_now)
	if (btnp(5) and self.ready) init_level(level_now)
end

function ending:draw()
	--cls(0)
	rectfill(1,1,127,32,6)
	color(8)
	print("you won! "..level_now-1,1,1)
	print("score"..level_now,1,7)
	print("press x or c to keep going",1,17)
end

function init_ending()
	t = ending:new()
	function t_update()
		t:update()
	end
	function t_draw()
		t:draw()
	end
	_update60 = t_update
	_draw = t_draw
end
-->8
-- levels

-- key
nhero = 1
ncoin = 2
nkey = 3
nsentrylr = 4
nsentryud = 5
nportal = 6
nflag = 7
nspikes = 8
nballoon = 9
nsentrydr = 10
nmacer = 11
nlaserv=12
nlaserh=13
ngunnerud=14
ngunnerlr=15

acreator={}
acreator[nhero]=p1
acreator[ncoin]=coin
acreator[nkey]=key
acreator[nsentrylr] = sentrylr
acreator[nsentryud] = sentryud
acreator[nportal] = portal
acreator[nflag] = flag
acreator[nspikes] = spikes
acreator[nballoon] = balloon
acreator[nsentrydr] = sentrydr
acreator[nmacer] = macer
acreator[nlaserv] = laserv
acreator[nlaserh] = laserh
acreator[ngunnerud] = gunnerud
acreator[ngunnerlr] = gunnerlr

mstart=0x2000

function level_from_mem(addr)
	address=addr
	local lev = {}
	newzone=true
	leveldone=false
	while not leveldone do
		if newzone then
			nzone = {}
			add_layout_from_mem(nzone,address)
			alist = {}
			newzone=false
			address+=5
		end
		local val = peek(address)
		if (val==255) leveldone=true
		if val==254 then
		 newzone=true
		 address+=1
		 val = peek(address)
		 if (val==255) leveldone=true
		end
		if not (leveldone or newzone) then
			add_act_from_mem(alist,address)
			address+=4
		else
			add(nzone,alist)
			add(lev,nzone)
			print(val)
		end
	end
	return lev
end

function add_layout_from_mem(nzone,address)
	local layout = {}
	for imem=0,4,1 do
		local val=peek(address+imem)-100
		add(layout,val)
	end
	add(nzone,layout)
end

function add_act_from_mem(alist,address)
	local actt={}
	for imem=0,3,1 do
		local val=peek(address+imem)-100
		add(actt,val)
	end
	add(alist,actt)
end

function return_level_start_addresses()
	level_addresses = {}
	add(level_addresses,mstart)
	current_address = mstart + 1
	while current_address < 0x3000 do
		if peek(current_address) == 255 then
			current_address += 1
			add(level_addresses,current_address)
		else
			current_address += 1
		end
	end
	del(level_addresses,level_addresses[#level_addresses])
	return level_addresses
end

-->8
-- debug

function skip_level()
	level_now +=1
    if level_now == level_max+1 then
	    init_ending()
    else
	    init_transition()
    end
end

menuitem(1, "skip level", function() skip_level() end)
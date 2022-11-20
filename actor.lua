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
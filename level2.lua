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
ngunnerh=16
ngunnerv=17

function make_level2()
level1 = {}

zone1 = {}
layout1 = {-3,2,11,8,11} --x0,z0,dx,dy,dz
a1 = {
    {nhero,0,2,0}, -- nactor,dx,dy,dz
    -- {ncoin,3,3,1},
    -- {ncoin,4,3,1},
    -- {ncoin,5,3,1},
    -- {ncoin,3,4,1},
    {nmacer,4,4,0},
    {nlaserv,5,6,0},
    {nlaserh,0,6,2},
    -- {ngunnerud,4,2,0},
    -- {ngunnerlr,7,6,0},
    {ngunnerv,2,6,0},
    {ngunnerv,10,6,0}
}
add(zone1,layout1)
add(zone1,a1)
add(level1,zone1)

zone2 = {}
layout2 = {5,1,3,7,3}
a2 = {
    {ncoin,1,3,1},
    {ncoin,1,4,1},
    {ncoin,1,5,1},
}
add(zone2,layout2)
add(zone2,a2)
add(level1,zone2)

zone3 = {}
layout3 = {-3,-2,9,7,7}
a3 = {
    {nkey,4,3,2},
    {nkey,5,3,2},
}
add(zone3,layout3)
add(zone3,a3)
add(level1,zone3)

add(level1,zone2)

zone5 = {}
layout5 = {-2,-1,7,6,6}
a5 = {
    {nportal,3,3,0}
}
add(zone5,layout5)
add(zone5,a5)
add(level1,zone5)

return level1
end
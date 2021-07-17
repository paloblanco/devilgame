nhero = 1
ncoin = 2
nkey = 3
nsentrylr = 4
nsentryud = 5
nportal = 6

function make_level4()
level1 = {}

zone1 = {}
layout1 = {-3,2,11,6,11} --x0,z0,dx,dy,dz
a1 = {
    {nhero,2,2,0}, -- nactor,dx,dy,dz
    {ncoin,3,3,1},
    {ncoin,4,3,1},
    {ncoin,5,3,1},
    {ncoin,3,4,1},
    {ncoin,4,4,1},
    {ncoin,5,4,1},
    {nsentrylr,3,5,0}
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
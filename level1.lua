-- level 1
-- theme : hell
-- July 17 2021

nhero = 1
ncoin = 2
nkey = 3
nsentrylr = 4
nsentryud = 5
nportal = 6
nflag = 7


function add_zone(layout,actorinfo,destination)
    local zz = {}
    local ll = {}
    for each in all(layout) do
        add(ll,each)
    end
    local aa = {}
    for eacha in all(actorinfo) do
        add(aa,eacha)
    end
    add(zz,ll)
    add(zz,aa)
    add(destination,zz)
end

function make_level1()

level1 = {}

layout1 = {0,0,5,5,5} --x0,z0,dx,dy,dz
a1 = {
    {nhero,3,1,0} -- nactor,dx,dy,dz
}
add_zone(layout1,a1,level1)


layout2 = {1,0,3,7,3}
a2 = {}
add_zone(layout2,a2,level1)

layout3 = {-2,-1,7,4,7}
a3 = {}
add_zone(layout3,a3,level1)

layout4 = {1,1,5,2,6}
a4 = {}
add_zone(layout4,a4,level1)

l5 = {0,1,5,1,5}
add_zone(l5,{},level1)

l6 = {0,2,5,2,3}
add_zone(l6,{},level1)

l7 = {1,0,3,4,3}
add_zone(l7,{},level1)

l8 = {0,0,9,3,3}
add_zone(l8,{},level1)

l9 = {6,-10,3,2,13}
add_zone(l9,{},level1)

l10 = {0,0,3,4,3}
a10 = {
    {nflag,1,2,0} -- nactor,dx,dy,dz
}
add_zone(l10,a10,level1)

return level1
end
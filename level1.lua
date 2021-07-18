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
nspikes = 8
nballoon = 9
nsentrydr = 10

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

l11 = {-1,-2,5,9,6}
a11 = {
    {nsentrylr,0,5,0},
    {nsentrylr,4,6,0},
    {nsentrylr,0,7,0},
    {nkey,2,6,2}
}
add_zone(l11,a11,level1)

l12 = {1,1,3,4,3}
add_zone(l12,{},level1)

l13 = {0,0,4,3,6}
add_zone(l13,{},level1)

l14 = {0,-1,4,2,7}
a14 = {
    {nspikes,0,0,0}
}
add_zone(l14,a14,level1)

l15 = {0,1,4,2,6}
add_zone(l15,{},level1)

--16 is same as 14
add_zone(l14,a14,level1)

l17 = {0,1,4,3,6}
add_zone(l17,{},level1)

--l18
add_zone({0,0,3,3,3},{},level1)
add_zone({-4,0,7,3,3},{},level1)
add_zone({0,0,3,2,3},{},level1)
add_zone({0,0,7,3,3},{},level1)
add_zone({4,0,3,3,3},{{nflag,1,1,0}},level1) -- flag before balloon climb
add_zone({-2,0,6,3,20},{{nballoon,3,2,2}},level1) -- first balloon

l30 = {2,3,4,3,17}
a30 = {
    {nballoon,1,2,2},
    {nballoon,2,2,4},
    {nballoon,3,2,5}
}
add_zone(l30,a30,level1)

l31 = {0,6,4,3,11}
a31 = {
    {nballoon,1,2,2},
    {nballoon,3,2,4},
    {nkey,2,2,5},
    {nballoon,1,2,5},
    {nflag,2,1,0}
}
add_zone(l31,a31,level1)

l32 = {0,6,8,3,5}
a32 = {
    {nsentryud,3,2,0},
    {nsentryud,4,0,0},
    {nsentryud,5,2,0},
    {nkey,7,0,0}
}
add_zone(l32,a32,level1)

add_zone({4,1,3,4,3},{{nflag,1,2,0}},level1)
add_zone({-5,0,8,3,3},{},level1)
add_zone({-1,0,5,3,5},{},level1)
add_zone({0,-1,5,2,6},{{nspikes,0,0,0}},level1)
add_zone({0,1,5,2,5},{},level1)
add_zone({1,-10,3,2,15},{},level1)
add_zone({0,0,3,4,3},{{nflag,1,2,0}},level1)

l40={-2,-1,7,5,8}
a40 = {
    {nsentrylr,0,3,0},
    {nsentrylr,6,4,0}
}
add_zone(l40,a40,level1)

l41={0,-1,7,4,9}
a41 = {
    {nspikes,0,0,0},
    {nballoon,2,3,2},
    {nballoon,3,3,2},
    {nballoon,4,3,2},
}
add_zone(l41,a41,level1)

l42 = {0,1,7,7,8}
a42 = {
    {nsentrydr,1,5,0},
    {nsentrydr,2,4,0},
    {nsentrydr,3,3,0},
    {nsentrydr,4,2,0},
    {nsentrydr,5,1,0},
    {nballoon,0,2,2},
    {nkey,0,4,4},
    {nkey,6,5,0}
}

add_zone(l42,a42,level1)

add_zone({2,1,3,7,3},{},level1)
add_zone({-1,-1,5,5,10},{},level1)
add_zone({0,1,5,1,9},{},level1)
add_zone({0,1,5,1,8},{},level1)
add_zone({0,1,5,5,7},{{nportal,2,3,0}},level1)

return level1
end
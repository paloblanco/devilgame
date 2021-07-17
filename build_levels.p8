pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

-- Level Loader, devilgame
-- Rocco Panella, July 2021

-- This cart is meant to be run in headless mode.
-- It will execute the following:

-- 1. Read in all levels listed
-- 2. Convert them to hex format and push them to cart rom
-- 3. Copy this rom into devilgame.p8

#include level1.lua
#include level2.lua
#include level3.lua
#include level4.lua
#include level5.lua
#include level6.lua
#include build_levels.lua

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
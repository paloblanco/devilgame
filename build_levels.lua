-- key
nhero = 1
ncoin = 2
nkey = 3
nsentrylr = 4
nsentryud = 5
nportal = 6

mem_start = 0x2000 -- start of map memory
mem_length_to_copy = 0x1000

function to_mem(level_table, address_start)
	vals = to_bytes(level_table)
	address = address_start
	for val in all(vals) do
		poke(address,val)
		address += 1
	end
	return address
end

function to_bytes(level_table)
    values={}
    for zz in all(level_table) do
        for each in all(zz[1]) do
            add(values,each+100)
        end
        for eacha in all(zz[2]) do
            for aa in all(eacha) do
                add(values,aa+100)
            end
        end
        add(values,254)
    end
    add(values,255)
    return values
end

function export_to_devil_cart()
    cstore(mem_start, mem_start, mem_length_to_copy, 'devilgame.p8')
end

function put_all_levels_into_mem()
    current_write_address = mem_start
    level_function_list = {make_level1,make_level2,make_level3,make_level4,make_level5,make_level6}
    for level_func in all(level_function_list) do
        current_level_table  = level_func()
        current_write_address = to_mem(current_level_table,current_write_address)
    end
    export_to_devil_cart()
end

-- main function:
put_all_levels_into_mem()
used_mem = 0x3000 - current_write_address
print("map used: "..(1 - used_mem/0x1000))
printh("map used: "..(1 - used_mem/0x1000))
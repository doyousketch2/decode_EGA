#! /usr/bin/env lua
print( 'Lua version:', _VERSION )

-----------------------------------------------------------
--     @Doyousketch2           AGPL-3          Oct 25, 2019
--            https://www.gnu.org/licenses/agpl-3.0.en.html
--=========================================================

local filename  = 'tom.data'

local image_width  = 320
local image_height  = 200

local CLUT  = {   '0 0 0',  '0 0 2',  '0 2 0',  '0 2 2',  '2 0 0',  '2 0 2',  '2 2 0',  '2 2 2',
                   '1 1 1',  '1 1 3',  '1 3 1',  '1 3 3',  '3 1 1',  '3 1 3',  '3 3 1',  '3 3 3'   }

local hex2bin  = {   ['0'] = '0000',  ['1'] = '0001',  ['2'] = '0010',  ['3'] = '0011',
                      ['4'] = '0100',  ['5'] = '0101',  ['6'] = '0110',  ['7'] = '0111',
                      ['8'] = '1000',  ['9'] = '1001',  ['A'] = '1010',  ['B'] = '1011',
                      ['C'] = '1100',  ['D'] = '1101',  ['E'] = '1110',  ['F'] = '1111'   }

local bitmap  = {}

--=============================================================================

for i =1,  image_width *image_height do
    bitmap[i]  = 0
end


local function read_file( file )
    local magic_number = {}
    local header = {}
    local contents  ={}

    local input  = io.open( filename, 'rb' )

    for m = 1, 4 do   magic_number[ m ]  = input :read( 1 )   end
    for h = 1, 4 do   header[ h ]  = string .byte(  input :read( 1 )  )   end

    while true do
        byte  = input :read( 1 )
        if byte == nil then input :close() break end

        local hex_pair  = string .format( '%02X',  string .byte(  byte ))    --  0F

        local first_hex_digit  = hex_pair :sub( 1, 1 )                        --  0
        local second_hex_digit  = hex_pair :sub( 2 )                          --  F

        contents[ #contents +1 ]  = hex2bin[  first_hex_digit  ] :sub( 1, 1 )  --  0
        contents[ #contents +1 ]  = hex2bin[  first_hex_digit  ] :sub( 2, 2 )  --  0
        contents[ #contents +1 ]  = hex2bin[  first_hex_digit  ] :sub( 3, 3 )  --  0
        contents[ #contents +1 ]  = hex2bin[  first_hex_digit  ] :sub( 4 )     --  0

        contents[ #contents +1 ]  = hex2bin[  second_hex_digit  ] :sub( 1, 1 )  --  1
        contents[ #contents +1 ]  = hex2bin[  second_hex_digit  ] :sub( 2, 2 )  --  1
        contents[ #contents +1 ]  = hex2bin[  second_hex_digit  ] :sub( 3, 3 )  --  1
        contents[ #contents +1 ]  = hex2bin[  second_hex_digit  ] :sub( 4 )     --  1
    end
    return magic_number, header, contents
end

local mage, head, data  = read_file( 'tom.data' )

local quarter  = #data /4
local half    =  #data /2
local three  = #data /4 *3

local plane_r  = {   table.unpack(  data,  1,           quarter   )   }
local plane_g  = {   table.unpack(  data,  quarter +1,  half      )   }
local plane_b  = {   table.unpack(  data,  half +1,     three     )   }
local plane_i  = {   table.unpack(  data,  three +1,    #data     )   }

local image  = {}

for i = 1, #plane_r do
    --  print( i, plane_r[i], plane_g[i], plane_b[i], plane_i[i] )
    local a = plane_r[ i ]
    local b = plane_g[ i ] *2
    local c = plane_b[ i ] *4
    local d = plane_i[ i ] *8

    local bitfields_combined  = a +b +c +d
    image[ i ]  = CLUT[ bitfields_combined +1 ]
end

--=============================================================================

--  print(   string.format(  'header: %s%s%s%s  %s %s %s %s',  mage[1],  mage[2],  mage[3],  mage[4],  
--                                                           head[1],  head[2],  head[3],  head[4]  )   )

--  print(   string.format(  'first 8: %s %s %s %s  %s %s %s %s',  data[1],  data[2],  data[3],  data[4],
--                                                               data[5],  data[6],  data[7],  data[8]  )   )

--=============================================================================

local file  = io.open( 'image.ppm', 'w+' )

local function write_line( line )   file :write( line, '\n' )   end

write_line( 'P3' )
write_line( '320 200' )
write_line( '3' )

for i = 1, #image do
    --  print( i, image[ i ] )
    write_line(  image[ i ]  )
end

file :close()

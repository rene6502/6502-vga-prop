OBJ
  const: "const"

'' params[0]: cog_index
'' params[1]: scanline buffer
'' params[2]: frame indicator/sync lock
'' params[3]: vram buffer
'' params[4]: system charset
'' params[5]: copy buffer
'' params[6]: render status
'' params[7]: debug_ptr

PUB start(params) 
  cognew(@entry, params)
  
DAT             org     0

entry           mov     temp_ptr, par
                rdlong  cog_index, temp_ptr
                add     temp_ptr, #4
                rdlong  buf, temp_ptr
                add     temp_ptr, #4
                rdlong  fi_ptr, temp_ptr
                add     temp_ptr, #4
                rdlong  vram_buffer, temp_ptr
                add     temp_ptr, #4
                rdlong  system_charset, temp_ptr
                add     temp_ptr, #4
                rdlong  copy_buffer, temp_ptr
                add     temp_ptr, #4
                rdlong  render_status, temp_ptr
                add     temp_ptr, #4
                rdlong  debug_ptr0, temp_ptr
                mov     debug_ptr1, debug_ptr0
                add     debug_ptr1, #4
                mov     debug_ptr2, debug_ptr0
                add     debug_ptr2, #8

                mov     hub_start, vram_buffer
                add     hub_start, vram_start
                mov     hub_tilemap, vram_buffer
                add     hub_tilemap, vram_tilemap
                mov     hub_palette, vram_buffer
                add     hub_palette, vram_palettes
                mov     hub_charset, vram_buffer
                add     hub_charset, vram_charset
                
                mov     copy_start, copy_buffer
                add     copy_start, vram_start
                mov     copy_charset, copy_buffer
                add     copy_charset, vram_charset
                
loop            mov     scanline, cog_index ' cog0 renders scanline 0, cog1 renders scanline 1, ..
                
                '' cog 0/1 wait for copy status
                cmp     cog_index, #1 wc, wz
         if_a   jmp     #:wait_for_start
                call    #copy_vram ' after copy cog1 sets status to start
                jmp     #next_line
                     
                '' other cogs must wait for start status
:wait_for_start rdlong  temp, render_status
                cmp     temp, status_start wz
         if_ne  jmp     #:wait_for_start        
                
next_line       call    #debug_start

                mov     pos_y, scanline
                mov     char_offset, pos_y
                shr     pos_y, #3           ' pos_y       := scanline / 8
                and     char_offset, #%111  ' char_offset := scanline // 8

                mov     tile_count, render_count
                movd    write_long, #scanline_buffer
                mov     byte_count, #4
                
                mov     tile_index, pos_y
                shl     tile_index, #5 ' *32
                mov     temp, pos_y
                shl     temp, #3 '*8
                add     tile_index, temp ' tile_index := pos_y * 40
                shl     tile_index, #1 ' tile_index := pos_y * 40 * 2
                
                mov     tile_ptr, hub_tilemap
                add     tile_ptr, tile_index ' tile_ptr point to first tile in row 

                mov     color_long, #0

next_x          rdword  tile, tile_ptr
                call    #render_tile
                add     tile_ptr, #2
                djnz    tile_count, #next_x


:wait_buffer    rdlong  temp, fi_ptr
                cmps    temp, scanline wc, wz
         if_b   jmp     #:wait_buffer ' wait until driver has released buffer of previous line
                         
:copy           call    #copy_scan

                call    #debug_end
                wrlong  debug_duration, debug_ptr0 ' save render duration in debug_ptr0

                cmp     cog_index, cog_last wz
         if_z   wrlong  status_frame, render_status ' all cogs are rendering frame

                add     scanline, cog_count
                cmp     scanline, #239 wc, wz
         if_be  jmp     #next_line ' next scanline 0..239

                cmp     cog_index, cog_last wz
         if_z   wrlong  status_copy, render_status ' last cog finished frame -> start copy

                jmp     #loop ' next scanline > 239


' tile          tile to render
' write 8 pixel tile to scanline buffer
' char_offset   y-offset within character (0..7)
render_tile     mov     char_index, tile
                and     char_index, #$ff ' lower byte of tile is character index
                mov     palette_index, tile
                shr     palette_index, #8 ' high byte of tile is palette index

                test    palette_index, #$10 wz 
        if_z    call    #read_system ' bit3=0 -> system charset
                test    palette_index, #$10 wz 
        if_nz   call    #read_user   ' bit3=1 -> user-defined charset
                and     palette_index, #$0f

                mov     palette_ptr, hub_palette
                shl     palette_index, #4 ' *16
                add     palette_ptr, palette_index

                mov     pixel_count, #8
next_pixel      mov     color_index, char_line
                shr     char_line, colorbits
                
                and     color_index, colormask
                mov     temp_ptr, palette_ptr
                add     temp_ptr, color_index
                rdbyte  color_byte, temp_ptr
                ror     color_long, #8
                or      color_long, color_byte
                djnz    byte_count, #next_byte
                ror     color_long, #8
write_long      mov     0-0, color_long
                add     write_long, inc_dest1
                mov     color_long, #0 
                mov     byte_count, #4
next_byte       djnz    pixel_count, #next_pixel

render_tile_ret ret

' read 4 byte user-defined character, 8 pixels each 4-bit color index
read_user       shl     char_index, #3 ' *8
                add     char_index, char_offset
                shl     char_index, #2 ' *4

                mov     temp_ptr, hub_charset
                add     temp_ptr, char_index ' temp_ptr := (char_index * 8 + char_offset) * 4

                rdlong  char_line, temp_ptr ' read 8 pixels each 4 bit palette index
                                            ' left most pixel on screen is pixel 0000
                                            ' long 77776666-55554444-33332222-11110000
                
                mov     colorbits, #4
                mov     colormask, #$0f
                
read_user_ret   ret


' read 1 byte system character, 8 pixels each 1-bit color index
read_system     shl     char_index, #3 ' *8
                add     char_index, char_offset

                mov     temp_ptr, system_charset
                add     temp_ptr, char_index ' temp_ptr := (char_index * 8 + char_offset) * 4

                rdbyte  char_line, temp_ptr ' read 8 pixels each 4 bit palette index
                                            ' left most pixel on screen is pixel 0000
                                            ' long 77776666-55554444-33332222-11110000
                
                mov     colorbits, #1
                mov     colormask, #$01
                
read_system_ret ret



' copy longs from cog scanline buffer to hub scanline buffer
copy_scan       mov     count_i, #80
                movs    :next_copy, #scanline_buffer
                mov     temp_ptr, buf
:next_copy      mov     temp, 0-0
                add     :next_copy, #1
                wrlong  temp, temp_ptr
                add     temp_ptr, #4
                djnz    count_i, #:next_copy
copy_scan_ret   ret

copy_vram       rdlong  temp, render_status
                cmp     temp, status_copy wz ' on startup render_status is 0 (tatus_copy)
         if_nz  jmp     #copy_vram

call    #debug_start
                cmp     cog_index, #0 wz
         if_z   jmp     #:cog_0
                cmp     cog_index, #1 wz
         if_z   jmp     #:cog_1
                jmp     #:end

:cog_0          mov     count_i, size_screen
                mov     src_ptr, copy_start
                mov     dest_ptr, hub_start
                jmp     #:next_long
              
:cog_1          mov     count_i, size_charset
                mov     src_ptr, copy_charset
                mov     dest_ptr, hub_charset
                jmp     #:next_long
                
:next_long      rdlong  temp, src_ptr
                add     src_ptr, #4
                wrlong  temp, dest_ptr
                add     dest_ptr, #4
                djnz    count_i, #:next_long
                
:end            cmp     cog_index, #1 wz
         if_z   wrlong  status_start, render_status ' signal other cogs to start
                call    #debug_end               
                wrlong  debug_duration, debug_ptr1 ' save copy duration in debug_ptr1
copy_vram_ret   ret 


debug_start     mov     debug_cnt, cnt
debug_start_ret ret

debug_end       mov     temp, cnt
                sub     temp, debug_cnt
                mov     debug_duration, temp
debug_end_ret   ret


cog_index       long    0 ' par[0]: 0..(cog_count-1)
buf             long    0 ' par[1]: hub scanline buffer address
fi_ptr          long    0 ' par[2]: frame indicator address
vram_buffer     long    0 ' par[3]: hub vram buffer address
system_charset  long    0 ' par[4]: system charset
copy_buffer     long    0 ' par[5]: hub copy buffer address
render_status   long    0 ' par[6]: render status
debug_ptr0      long    0 ' par[7]: hub debug buffer address
debug_ptr1      long    0 ' 2nd long of debug buffer
debug_ptr2      long    0 ' 3rd long of debug buffer
cog_count       long    const#cog_count ' total number of cogs
cog_last        long    const#cog_count - 1 ' index of last cog
render_count    long    const#render_count ' number of tiles to render per line

hub_start       long    0 ' base address
hub_tilemap     long    0 ' tilemap address
hub_palette     long    0 ' base address of palettes
hub_charset     long    0 ' character set address
copy_start      long    0 ' base address in copy buffer
copy_charset    long    0 ' character set address in copy buffer

status_copy     long    0
status_start    long    1
status_frame    long    2
                          
scanline        long    0 ' scanline to render

temp            long    0 ' temporary register
temp_ptr        long    0 ' temporary register address
src_ptr         long    0 ' temporary pointer for copying
dest_ptr        long    0 ' temporary pointer for copying
count_i         long    0 ' counter
inc_dest1       long    1 << 9 ' increment destination address by one long
inc_dest2       long    2 << 9 ' increment destination address by two longs
debug_cnt       long    0 ' start clock count for time measurement
debug_duration  long    0 ' duration of time measurement

tile_count      long    0 ' number of tiles left to render in line
pos_y           long    0 ' y tile position (0..24)
char_offset     long    0 ' y-offset within character (0..7)
tile_ptr        long    0 ' address of current tile
tile_index      long    0 ' index to tile
tile            long    0 ' tile content
char_index      long    0 ' character index part of tile
palette_index   long    0 ' palette index part of tile
colorbits       long    0 ' number of bits per color (1 or 4)
colormask       long    0 ' color bits mask ($0f or $01)

char_line       long    0 ' current 8 pixel line from character set
pixel_count     long    0
byte_count      long    0


palette_ptr     long    0 ' current palette address

color_index     long    0 ' color index of pixel           
color_byte      long    0 ' color byte read from palette
color_long      long    0 ' color bytes to be written to scanline buffer

vram_start      long    const#addr_start
vram_ctl_cmd    long    const#addr_ctl_cmd
vram_tilemap    long    const#addr_tilemap
vram_palettes   long    const#addr_palettes
vram_charset    long    const#addr_charset

size_screen     long    (const#addr_charset - const#addr_start) / 4 ' vram size in quads of screen block (control/tile/palettes)
size_charset    long    (const#addr_free - const#addr_charset) / 4 ' vram size in quads of charset block
                
scanline_buffer res     40 ' buffer for one scanline (320 pixels)

                fit     $1f0
                
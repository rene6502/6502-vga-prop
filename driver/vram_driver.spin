CON
  BLACK = %00000000
  RED   = %11000000
  GREEN = %00110000
  BLUE  = %00001100
  WHITE = %11111100

OBJ
  const:    "const"
  renderer: "renderer_driver"
  
'' params[0]: frame indicator/sync lock
'' params[1]: vram_buffer
'' params[2]: copy_buffer
'' params[3]: debug_buffer
PUB start(id, params)
  if id => 0 and id < 8
    coginit(id, @entry, params)
  else
    cognew(@entry, params)
  
DAT             org     0

entry           mov     temp_ptr, par
                rdlong  fi_ptr, temp_ptr
                add     temp_ptr, #4
                rdlong  vram_buffer, temp_ptr
                add     temp_ptr, #4
                rdlong  copy_buffer, temp_ptr
                add     temp_ptr, #4
                rdlong  debug_buffer, temp_ptr

                mov     hub_start, vram_buffer
                add     hub_start, vram_start
                mov     hub_tilemap, vram_buffer
                add     hub_tilemap, vram_tilemap
                mov     hub_charset, vram_buffer
                add     hub_charset, vram_charset
                
                mov     copy_start, copy_buffer
                add     copy_start, vram_start
                mov     copy_tilemap, copy_buffer
                add     copy_tilemap, vram_tilemap
                mov     copy_palette, copy_buffer
                add     copy_palette, vram_palettes
                mov     copy_charset, copy_buffer
                add     copy_charset, vram_charset
                
                call    #init_ports
                call    #init_screen
                call    #init_palettes
                call    #init_version
                mov     frame, #0

loop            rdlong  temp, fi_ptr
                cmp     temp, #1 wz
         if_ne  jmp     #loop ' wait for scanline 1 (renderers have copied transfer buffer)

                call    #debug_start
                call    #copy_vram
                call    #debug_end
                cmp     debug_enable, #1 wz
         if_z   call    #debug_show
         
                jmp     #loop

copy_vram       mov     clock_count, vram_start ' set counter to start address (control section)
                call    #set_counter
                call    #read_byte
                mov     ctrl_cmd, byte_val ' save screen copy flag
                cmp     ctrl_cmd, #0 wz
         if_nz  mov     copy_started, #1
                
                '' copy control section (if enabled)
                mov     clock_count, size_control
                mov     copy_count, size_control
                test    ctrl_cmd, #%001 wz ' check control copy flag bit0
         if_z   jmp     #:skip_control                
                mov     hub_addr, copy_start
                call    #read_block ' copy control block from vram to copy buffer
                jmp     #:check_tiles
:skip_control   call    #inc_counter ' control copy is disabled -> just increment counter
                
                '' copy tiles and palettes (if enabled)
:check_tiles    mov     clock_count, size_tiles
                mov     copy_count, size_tiles
                test    ctrl_cmd, #%010 wz ' check tilemap copy flag bit1
         if_z   jmp     #:skip_tiles
                mov     hub_addr, copy_tilemap
                call    #read_block ' copy tilemap and palettes from vram to copy buffer
                jmp     #:inc_frame
:skip_tiles     call    #inc_counter ' tilemap copy is disabled -> just increment counter

                '' increment frame (always)
:inc_frame      add     frame, #1 ' increment frame counter signals end of copy
                mov     byte_val, frame
                call    #write_byte
                mov     outa, out_clock ' increment counter by 1
                mov     outa, out_idle
               
                mov     byte_val, frame
                shr     byte_val, #8
                call    #write_byte
                mov     outa, out_clock ' increment counter by 1
                mov     outa, out_idle

                '' copy charset (if enabled)
                test    ctrl_cmd, #%100 wz ' check charset copy flag bit2
         if_z   jmp     #copy_vram_ret ' skip charset copy
                mov     clock_count, count_unused
                call    #inc_counter ' point counter to addr_charset
    
                mov     copy_count, size_charset
                mov     hub_addr, copy_charset
                call    #read_block ' copy charset block from vram to copy buffer
                                     
copy_vram_ret   ret


init_ports      mov     dira, dir_read '' initialize i/o ports
                mov     outa, out_idle
init_ports_ret  ret


'' set counter to specified count
'' clock_count
set_counter     mov     outa, out_reset ' reset address counter
                mov     outa, out_idle
                cmp     clock_count, 0 wz
         if_z   jmp     #set_counter_ret ' leave address counter at 0
:clock          mov     outa, out_clock
                mov     outa, out_idle
                djnz    clock_count, #:clock
set_counter_ret ret

'' increment counter by specified specified count
'' clock_count
inc_counter     mov     outa, out_idle
:clock          mov     outa, out_clock
                mov     outa, out_idle
                djnz    clock_count, #:clock
inc_counter_ret ret


'' read single byte from vram at current counter
'' byte_val   read byte (output)
read_byte       mov     outa, out_read
                mov     byte_val, ina ' read byte 0
                mov     outa, out_idle
                shr     byte_val, #8 ' move P8-P15 to low byte
                and     byte_val, #$ff ' clear other bits
read_byte_ret   ret


'' copy byte block from vram at current counter to hub
'' hub_addr    start address in hub 
'' copy_count  number of bytes to copy (must be multiple of 4)
read_block      mov     count_i, copy_count
                shr     count_i, #2 ' /4 = number of longs
                mov     temp_ptr, hub_addr
                                
:read           mov     long_val, #0
                mov     outa, out_read
                mov     temp, ina ' read byte 0
                mov     outa, out_idle
                shr     temp, #8 ' move P8-P15 to byte 0
                and     temp, mask_byte0
                or      long_val, temp     
                mov     outa, out_clock ' advance counter to next address
                mov     outa, out_idle
                
                mov     outa, out_read
                mov     temp, ina ' read byte 1
                mov     outa, out_idle
                and     temp, mask_byte1 ' already in byte 1
                or      long_val, temp     
                mov     outa, out_clock ' advance counter to next address
                mov     outa, out_idle
                
                mov     outa, out_read
                mov     temp, ina ' read byte 2
                mov     outa, out_idle
                shl     temp, #8 ' move P8-P15 to byte 2
                and     temp, mask_byte2
                or      long_val, temp     
                mov     outa, out_clock ' advance counter to next address
                mov     outa, out_idle
                
                mov     outa, out_read
                mov     temp, ina ' read byte 3
                mov     outa, out_idle
                shl     temp, #16 ' move P8-P15 to byte 3
                and     temp, mask_byte3
                or      long_val, temp     
                mov     outa, out_clock ' advance counter to next address
                mov     outa, out_idle
                
                wrlong  long_val, temp_ptr                                              
                add     temp_ptr, #4
                djnz    count_i, #:read
                
read_block_ret  ret


'' write single byte to vram at current counter, advance counter to next address
'' byte_val   byte to write
write_byte      mov     dira, dir_write ' switch databus to write
                mov     outa, out_write
                mov     temp, byte_val
                and     temp, #$ff
                shl     temp, #8 ' move byte to P8-P15
                or      temp, out_write ' combine with write mask
                mov     outa, temp
                xor     outa, out_rw   ' set R/W=1 -> end write cycle
                mov     dira, dir_read  ' switch databus to read
                mov     outa, out_idle
write_byte_ret  ret


debug_start     mov     debug_cnt, cnt
debug_start_ret ret


debug_end       mov     temp, cnt
                sub     temp, debug_cnt
                mov     debug_duration, temp
debug_end_ret   ret
                

debug_show      mov     cog_index, #0
:next_cog       mov     debug_ptr0, cog_index
                shl     debug_ptr0, #4 
                add     debug_ptr0, debug_buffer  ' debug_ptr0 = debug_buffer + 16*cog_index + 0
                mov     debug_ptr1, debug_ptr0
                add     debug_ptr1, #4            ' debug_ptr0 = debug_buffer + 16*cog_index + 4
                mov     debug_ptr2, debug_ptr0
                add     debug_ptr2, #8            ' debug_ptr0 = debug_buffer + 16*cog_index + 8

                mov     debug_y, #17
                add     debug_y, cog_index
    
                '' render 1st long as duration in us at x=2, y=15 
                rdlong  x, debug_ptr0
                mov     y, #80 ' divide cycles by 80 to get us
                call    #divide
                mov     debug_value, x
                and     debug_value, mask_ffff
                mov     debug_x, #2
                mov     debug_count, #4
                call    #debug_dec

                '' render 2nd long as duration in us at x=8, y=15 
                rdlong  x, debug_ptr1
                mov     y, #80 ' divide cycles by 80 to get us
                call    #divide
                mov     debug_value, x
                and     debug_value, mask_ffff
                mov     debug_x, #8
                mov     debug_count, #4
                call    #debug_dec

                '' render 3nd long as hex at x=14, y=15 
                rdlong  debug_value, debug_ptr2
                mov     debug_x, #14
                mov     debug_count, #8
                call    #debug_hex
                
                add     cog_index, #1
                cmp     cog_index, cog_count wz
         if_ne  jmp     #:next_cog
         
                '' render frame counter at x=2, y=25 
                mov     debug_value, frame
                mov     debug_x, #2
                mov     debug_y, #25
                mov     debug_count, #4
                call    #debug_dec

                '' render debug_duration at x=2, y=26
                mov     x, debug_duration
                mov     y, #80 ' divide cycles by 80 to get us
                call    #divide
                mov     debug_value, x
                and     debug_value, mask_ffff
                mov     debug_x, #2
                mov     debug_y, #26
                mov     debug_count, #4
                call    #debug_dec
                
                '' render debug_temp at x=2, y=27
                mov     debug_value, debug_temp 
                and     debug_value, mask_ffff
                mov     debug_x, #2
                mov     debug_y, #27
                mov     debug_count, #8
                call    #debug_hex

debug_show_ret  ret

' write text to screen
' debug_str_addr
debug_str       movs    :next_copy, debug_str_addr
                mov     x, debug_y
                mov     y, #40
                call    #multiply
                mov     tile_ptr, y
                add     tile_ptr, debug_x
                shl     tile_ptr, #1 
                add     tile_ptr, copy_tilemap ' tile_ptr := tilemap + 2*(y*40 + x)
                mov     debug_str_pal, #0
                
:next_copy      mov     temp, 0-0
                add     :next_copy, #1
                cmp     temp, #$ff wz
         if_z   jmp     #debug_str_ret
                cmp     temp, #3 wz, wc
         if_be  mov     debug_str_pal, temp
         if_be  jmp     #:next_copy
                wrbyte  temp, tile_ptr
                add     tile_ptr, #1
                mov     temp, debug_str_pal
                wrbyte  temp, tile_ptr
                add     tile_ptr, #1
                jmp     #:next_copy
                
debug_str_ret   ret


' write palette to tile
' debug_str_pal
debug_pal       mov     x, debug_y
                mov     y, #40
                call    #multiply
                mov     tile_ptr, y
                add     tile_ptr, debug_x
                shl     tile_ptr, #1 
                add     tile_ptr, copy_tilemap ' tile_ptr := tilemap + 2*(y*40 + x)
                add     tile_ptr, #1 ' point to palette
                wrbyte  debug_str_pal, tile_ptr
                add     tile_ptr, #1
debug_pal_ret   ret

                
' write value as hex to screen
' debug_value
' debug_count
debug_hex       mov     count_i, debug_count
                mov     x, debug_y
                mov     y, #40
                call    #multiply
                mov     tile_ptr, y
                add     tile_ptr, debug_x
                add     tile_ptr, debug_count
                sub     tile_ptr, #1
                shl     tile_ptr, #1 
                add     tile_ptr, copy_tilemap ' tile_ptr := tilemap + 2*(y*40 + x + debug_count - 1)
:next_digit     mov     debug_nibble, debug_value
                and     debug_nibble, #%1111
                cmp     debug_nibble, #10 wc, wz
         if_ae  jmp     #:alpha     
                add     debug_nibble, #$30 '0
                jmp     #:write
:alpha          add     debug_nibble, #$37 'A - 10                 
:write          or      debug_nibble, debug_palette
                wrword  debug_nibble, tile_ptr
                sub     tile_ptr, #2
                shr     debug_value, #4
                djnz    count_i, #:next_digit
debug_hex_ret   ret

' write value as decimal to screen
' debug_value
' debug_count
debug_dec       mov     count_i, debug_count
                mov     x, debug_y
                mov     y, #40  
                call    #multiply
                mov     tile_ptr, y
                add     tile_ptr, debug_x
                add     tile_ptr, debug_count
                sub     tile_ptr, #1
                shl     tile_ptr, #1 
                add     tile_ptr, copy_tilemap ' tile_ptr := tilemap + 2*(y*40 + x + debug_count - 1)
:next_digit     mov     x, debug_value
                mov     y, #10
                call    #divide
                mov     debug_nibble, x
                shr     debug_nibble, #16 
                add     debug_nibble, #$30 '0
:write          or      debug_nibble, debug_palette
                wrword  debug_nibble, tile_ptr
                sub     tile_ptr, #2
                mov     debug_value, x
                and     debug_value, mask_ffff
                djnz    count_i, #:next_digit
debug_dec_ret   ret

init_screen     mov     clock_count, vram_start ' set counter to start address (control section)
                call    #set_counter
                mov     byte_val, #0
                call    #write_byte ' clear ctrl_cmd on startup

                mov     count_i, max_tiles
                mov     tile_ptr, copy_tilemap
:next_tile      wrword  blank, tile_ptr 
                add     tile_ptr, #2
                djnz    count_i, #:next_tile
init_screen_ret ret


init_version    mov     debug_x, #15
                mov     debug_y, #14
                mov     debug_str_addr, #version_str0
                call    #debug_str

                mov     debug_x, #15
                mov     debug_y, #15
                mov     debug_str_addr, #version_str1
                call    #debug_str
                        
init_version_ret ret


init_palettes   mov     count_i, #4*16/4
                movs    :next_copy, #palettes
                mov     temp_ptr, copy_palette
:next_copy      mov     temp, 0-0
                add     :next_copy, #1
                wrlong  temp, temp_ptr
                add     temp_ptr, #4
                djnz    count_i, #:next_copy
init_palettes_ret ret



' Divide x[31..0] by y[15..0] (y[16] must be 0)
' on exit, quotient is in x[15..0] and remainder is in x[31..16]
divide          shl     y, #15    'get divisor into y[30..15]
                mov     t, #16    'ready for 16 quotient bits
:loop           cmpsub  x, y wc   'y =< x? Subtract it, quotient bit in c
                rcl     x, #1     'rotate c into quotient, shift dividend
                djnz    t, #:loop 'loop until done
divide_ret      ret               'quotient in x[15..0], remainder in x[31..16]


'' Multiply x[15..0] by y[15..0] (y[31..16] must be 0)
' on exit, product in y[31..0]
multiply        shl     x, #16 'get multiplicand into x[31..16]
                mov     t, #16 'ready for 16 multiplier bits
                shr     y, #1 wc 'get initial multiplier bit into c
:loop    if_c   add     y, x wc 'if c set, add multiplicand to product
                rcr     y, #1 wc 'put next multiplier in c, shift prod.
                djnz    t, #:loop 'loop until done
multiply_ret    ret     'return with product in y[31..0]



fi_ptr          long    0 ' par[0]: frame indicator/sync lock
vram_buffer     long    0 ' par[1]: hub vram buffer address
copy_buffer     long    0 ' par[2]: hub copy buffer address
debug_buffer    long    0 ' par[3]: debug_buffer

hub_start       long    0 ' base address
hub_tilemap     long    0 ' tilemap address
hub_charset     long    0 ' character set address
copy_start      long    0 ' base address in copy buffer
copy_tilemap    long    0 ' tilemap address in copy buffer
copy_palette    long    0 ' palette base address in copy buffer
copy_charset    long    0 ' character set address in copy buffer
                           
render_count    long    0 ' number of tiles to render per line

cog_index       long    0
cog_count       long    const#cog_count ' par: total number of cogs


temp            long    0 ' temporary register
temp_ptr        long    0 ' temporary register address
count_i         long    0 ' counter


clock_count     long    0 ' increment address counter
byte_val        long    0 ' single byte read/write
long_val        long    0 ' accumulate bytes
vram_addr       long    0 ' start address in vram
hub_addr        long    0 ' start address in hub
copy_count      long    0 ' number of bytes to copy
mask_byte0      long    $000000ff
mask_byte1      long    $0000ff00
mask_byte2      long    $00ff0000
mask_byte3      long    $ff000000

frame           long    0 ' frame counter

ctrl_cmd          long  0
copy_started      long  0 ' will be set to 1 after first vram copy was requested
vram_start        long  const#addr_start
vram_ctl_cmd      long  const#addr_ctl_cmd
vram_tilemap      long  const#addr_tilemap
vram_palettes     long  const#addr_palettes
vram_charset      long  const#addr_charset

size_control    long    const#addr_tilemap - const#addr_start ' vram size of control block
size_tiles      long    const#addr_frame - const#addr_tilemap ' vram size of tilemap and palettes block, exclusive frame
size_charset    long    const#addr_free - const#addr_charset ' vram size of charset block
count_unused    long    const#addr_charset - const#addr_frame - 2 ' vram size between frame and charset
count_all       long    const#addr_free - const#addr_start ' vram size of all occupied memory
max_tiles       long    30*40
version_palette long    2*(13*40 + 20) + 1

x               long    0
y               long    0
t               long    0

count_1024      long    1024
debug_enable    long    0 ' set 1 to show debug information
debug_ptr0      long    0
debug_ptr1      long    0
debug_ptr2      long    0
debug_cnt       long    0
debug_duration  long    0
debug_temp      long    0       
debug_value     long    0
debug_x         long    0
debug_y         long    0
debug_nibble    long    0
debug_shift     long    0
debug_count     long    0
debug_palette   long    $0100 ' green
debug_str_addr  long    0
debug_str_pal   long    0
mask_ffff       long    $0000ffff
color_index     long    1
tile_ptr        long    0 ' address of current tile
blank           long    $0020 ' palette index = 00, character = $20 (SPACE)

dir_read        long    %00000000_00011111_00000000_00000000 ' CLK(P16)=1 RESET(P17)=1 /CE(P18)=1 /OE(P19)=1 R/W(P20)=1 P8-15=input
dir_write       long    %00000000_00011111_11111111_00000000 ' CLK(P16)=1 RESET(P17)=1 /CE(P18)=1 /OE(P19)=1 R/W(P20)=1 P8-15=output
out_idle        long    %00000000_00011100_00000000_00000000 ' CLK(P16)=0 RESET(P17)=0 /CE(P18)=1 /OE(P19)=1 R/W(P20)=1
out_clock       long    %00000000_00011101_00000000_00000000 ' CLK(P16)=0 RESET(P17)=1 /CE(P18)=1 /OE(P19)=1 R/W(P20)=1
out_reset       long    %00000000_00011110_00000000_00000000 ' CLK(P16)=0 RESET(P17)=1 /CE(P18)=1 /OE(P19)=1 R/W(P20)=1
out_write       long    %00000000_00000000_00000000_00000000 ' CLK(P16)=0 RESET(P17)=0 /CE(P18)=0 /OE(P19)=0 R/W(P20)=0
out_read        long    %00000000_00010000_00000000_00000000 ' CLK(P16)=0 RESET(P17)=0 /CE(P18)=0 /OE(P19)=0 R/W(P20)=1
out_rw          long    %00000000_00010000_00000000_00000000 ' CLK(P16)=0 RESET(P17)=0 /CE(P18)=0 /OE(P19)=0 R/W(P20)=1

' sample palettes       0      1      2      3      4      5      6      7      8      9      10     11     12     13     14     15
palettes        byte    BLACK, WHITE, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK ' 0: white
                byte    BLACK, RED,   BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK ' 1: red 
                byte    BLACK, GREEN, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK ' 2: green
                byte    BLACK, BLUE,  BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK ' 3: blue
                  
' version strings, 0=white 1=red 2=green 3=blue $ff=end-of-string                 
version_str0    long    2, "6502-", 1, "v", 2 , "g", 3 , "a", $ff
version_str1    long    0, "  v1.0  ", $ff
                                                                                                                                       
                fit     $1f0
                
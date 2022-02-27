
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000
  EOS = $ff ' end of string
  
OBJ
  const:    "const"
  font:     "funscii-8-parallax"
  scanline: "waitvid.320x240.driver.2048"
  renderer: "renderer_driver"
  vram:     "vram_driver"
    
VAR
  long scanline_params[scanline#res_m] ' parameters for scanline driver
  long scanline_buffer[scanline#res_x/4] ' the scanline buffer (single buffer mode)
  long renderer_params[8] ' parameters for renderer driver
  long vram_params[4] ' parameters for vram driver
  long vram_buffer[const#addr_free/4]
  long copy_buffer[const#addr_free/4]
  long render_status
  long debug_buffer[const#cog_count*4]

            
PUB main | cog_index

  '' start renderer cogs
  renderer_params[1] := @scanline_buffer
  renderer_params[2] := @scanline_params
  renderer_params[3] := @vram_buffer
  renderer_params[4] := font.addr
  renderer_params[5] := @copy_buffer
  renderer_params[6] := @render_status

  repeat cog_index from 0 to const#cog_count - 1
    renderer_params[0] := cog_index
    renderer_params[7] := @debug_buffer + cog_index*4*4
    renderer.start(@renderer_params)
    waitcnt(clkfreq / 10 + cnt)

  '' start scanline cog
  scanline_params[0] := @scanline_buffer << 16 | @scanline_buffer ' single buffer
  scanline.init(-1, @scanline_params)

  '' replace main cog with vram driver
  vram_params[0] := @scanline_params
  vram_params[1] := @vram_buffer
  vram_params[2] := @copy_buffer
  vram_params[3] := @debug_buffer
  vram.start(cogid, @vram_params)

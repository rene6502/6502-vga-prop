CON
  cog_count = 6 ' numbre of renderer cogs
  render_count = 40 ' number of tiles to render per line
                    ' 
  addr_start        = $0200 ' vram address start
  addr_ctl_cmd      = $0200 ' vram address of control screen
  addr_tilemap      = $0210 ' vram address of tilemap
  addr_palettes     = $0b70 ' vram address of palettes
  addr_frame        = $0c70 ' vram address of frame counter
  addr_charset      = $0c80 ' vram address of charset
  addr_free         = $2c80 ' vram address of free memory

PUB null


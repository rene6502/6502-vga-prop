* = $2d00

VIDEO_START = $0200
VIDEO_END   = $2c7f
CTL_SCREEN  = $0200
TILEMAP     = $0210
PALETTES    = $0b70
FRAME       = $0c70
CHARSET     = $0c80
SCREEN_NONE = %0000
SCREEN_CTRL = %0001
SCREEN_TILE = %0010
SCREEN_CHAR = %0100

BLACK       = $00
WHITE       = $fc
DARK_GREEN  = $10
GREEN       = $30
BLUE        = $0c
RED         = $c0
DARK_YELLOW = $50
YELLOW      = $f0
CYAN        = $3c
MAGENTA     = $cc


; zero page
            .virtual $00
TEMP        .byte ? ; general purpose byte, always assume that subroutines will change this
            .endvirtual

start:
        jsr clear_memory
        
        lda #BLACK
        sta PALETTES+16+0 ; set color #0 (background) of palette #1 to black
        lda #GREEN
        sta PALETTES+16+1 ; set color #1 (foreground) of palette #1 to green

        ldx #$0
        ldy #$0
_loop:
        lda MSG,x
        sta TILEMAP+(14*40+14)*2,y
        iny
        lda #1
        sta TILEMAP+(14*40+14)*2,y
        iny
        inx
        lda MSG,x
        bne _loop
        
        
        lda #SCREEN_CTRL | SCREEN_TILE
        jsr copy_vram
        rts


; IN A copy bits
copy_vram:        
        sta CTL_SCREEN  ; enable copy
        lda FRAME
_wait:        
        cmp FRAME
        beq _wait

        lda #SCREEN_NONE ; disable copy
        sta CTL_SCREEN
        rts


; clear complete video ram
clear_memory:
        lda #<VIDEO_START
        sta DEST_ADDRL
        lda #>VIDEO_START
        sta DEST_ADDRH
        ldy #0
_next:          
        lda #$00
        sta (DEST_ADDRL), y
        lda DEST_ADDRL
        cmp #<VIDEO_END
        bne _incr
        lda DEST_ADDRH
        cmp #>VIDEO_END
        bne _incr
        rts
_incr:
        inc DEST_ADDRL ; increment start address
        bne _cont
        inc DEST_ADDRH
_cont:        
        jmp _next
        rts

MSG     .text "Hello, world!",0


; zero page
            .virtual $00
DEST_ADDRL  .byte ? ; copy destination address
DEST_ADDRH  .byte ? ; copy destination address
            .endvirtual              

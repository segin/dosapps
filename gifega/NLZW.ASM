;**************************************************************************
;Written 1/27/88-2/6/88 by Jim Griebel
;Built as a Turbo external OBJ file, this routine replaces READCODE,
;ADDTOPIXEL and all the high-level LZW decoding done by GIFSLOW.
;**************************************************************************

data        segment word public
            assume ds:data

;definitions for Turbo variables used in this module

            extrn clear:byte,interlace:byte,pass:byte
            extrn freecode:word,clearcode:word,bitmask:word
            extrn width:word,maxcode:word,codesize:word
            extrn readmask:word,eofcode:word,height:word
            extrn bitsperpixel:byte
            extrn linestart:word
            extrn nextraster:byte
            extrn raster:dword
            extrn palette:byte

;And for variables declared locally

            bitoffset  dw 0
            bitoffset2 dw 0
            yc      dw ?
            oldcolor db ?
            yoffset dw ?
            xoffset dw ?
            curcode dw ?
            incode  dw ?
            oldcode dw ?
            finchar db ?
            rasterseg dw ?
            rasterofs dw ?
            prefix  dw 4096 dup (?)
            suffix  db 4096 dup (?)
            outcode db 1024 dup (?)
            scanline db 640 dup (?)

data        ends

cseg        segment byte public

            assume cs:cseg

;We retain some Turbo calls just to keep things simple

            extrn doclear:near
            extrn moveup:near

            public nlzw

nlzw        proc   near

;Here's where the fun starts. Do the necessary preliminaries, including
;setting constants and variable starting points since Turbo won't let
;us declare them

            mov    byte ptr oldcolor,255 ;Set oldcolor to a null value
            xor    ax,ax            ;Set bitoffset to start of file
            mov    bitoffset,ax
            mov    bitoffset2,ax
            mov    yoffset,ax       ;YOFFSET to origin of screen RAM
            mov    xoffset,ax       ;Ditto for XOFFSET
            mov    yc,ax            ;Zero out Y-coord

;Here's the main loop where the file is decompressed and displayed

top:        call   readcode         ;Extract GIF compression code
            push   ds
            pop    es
            lea    di,outcode       ;Aim DI at the output queue
            mov    bx,bitmask       ;Get the bitmask in BX
            xor    dx,dx            ;Zero out DX, used as output counter
            cmp    ax,eofcode       ;Are we at the end of image?
            jnz    ckclear          ;Nope, press on
            jmp    finis            ;Yes, done, exit
ckclear:    cmp    ax,clearcode     ;Did we read a CLEAR code?
            jnz    noclear          ;Nope
            inc    byte ptr clear   ;Yes, turn on the CLEAR flag
            push   es
            push   di
            push   dx
            push   bx
            call   doclear          ;Reset values to initial
            call   readcode         ;Read raw data
            pop    bx
            pop    dx
            pop    di
            pop    es
            mov    oldcode,ax       ;Set OLDCODE to value just read
            jmp    done             ;and go put that out
noclear:    mov    curcode,ax       ;Otherwise, check for new data
            mov    incode,ax
            cmp    ax,freecode      ;See if >= freecode, if so
            jl     notnew           ;Not new, already in table
            mov    ax,oldcode       ;Otherwise curcode=oldcode
            mov    curcode,ax
            mov    al,finchar       ;stack last char decoded for output
            stosb
            inc    dx               ;increment the count
notnew:     mov    ax,curcode       ;Run the hash table for this value
            cmp    ax,bx            ;Current code less than BITMASK?
            jle    done             ;Yes, bail out
loop:       mov    si,ax
            mov    al,[si+suffix]   ;otherwise stack suffix [curcode]
            stosb                   ;for output
            inc    dx
            shl    si,1
            mov    ax,[si+prefix]   ;and set curcode=prefix [curcode]
            mov    curcode,ax
            cmp    ax,bx            ;If not done, continue
            jg     loop
done:       and    ax,bx            ;Mask off actual data
            mov    finchar,al       ;Save as FINCHAR
            stosb                   ;And put it on output queue
            mov    si,di            ;Outqueue pointer to SI
            dec    si               ;Back up to valid data
            mov    cx,dx            ;Output count to CX
            inc    cx               ;Make good count for LOOP
            push   es
            std
            push   ds               ;Point ES:DI to SCANLINE
            pop    es
            lea    di,scanline
            add    di,xoffset       ;Point into current pos in SCANLINE
            mov    dx,xoffset       ;DX now serves as pos counter
scanloop:   lodsb                   ;get byte from output queue. Stacked
            stosb                   ;LIFO, so deal with it that way
            inc    di               ;overcome auto-decrement
            inc    di
            inc    dx               ;At end of current scan line?
            cmp    dx,width
            jnz    scanloop1        ;Nope, press on
            call   putout           ;Yup, put out the scan line
scanloop1:  loop   scanloop         ;Continue for length of outqueue
            mov    xoffset,dx       ;Save new pos
            cld                     ;Dir flag back to normal
            pop    es               ;ES back to DS
noout:      cmp    byte ptr clear,0 ;Are we doing a CLEAR?
            jz     goon             ;No, proceed
            dec    byte ptr clear   ;Yes, turn off CLEAR flag
            jmp    top              ;and take the short way out
goon:       mov    di,freecode      ;suffix[freecode]=finchar
            mov    al,finchar
            mov    [di+suffix],al
            shl    di,1             ;Adjust for word-sized array
            mov    ax,oldcode       ;Prefix [freecode]=oldcode
            mov    [di+prefix],ax
            mov    ax,incode        ;Set Oldcode=Incode
            mov    oldcode,ax
            mov    ax,freecode      ;Kick to next free code
            inc    ax
            mov    freecode,ax
            cmp    ax,maxcode       ;Increase code size if necessary
            jge    incmax           ;(and possible, 12 is limit)
            jmp    top
incmax:     mov    ax,maxcode       ;maxcode = maxcode * 2
            shl    ax,1
            mov    maxcode,ax
            mov    ax,codesize      ;If codesize < 12, increment it
            cmp    ax,12
            jnz    inccode
            jmp    top
inccode:    inc    ax
            mov    codesize,ax
            mov    cl,al            ;Compute new READMASK value
            xor    ch,ch
            mov    ax,1
            shl    ax,cl
            dec    ax
            mov    readmask,ax
            jmp    top
finis:      ret                      ;Whole image done, exit

nlzw        ENDP

;Put out the array of pixels stored in SCANLINE

putout      proc   near
            push   es                ;Push sensitive regs
            push   cx
            push   ds
            push   si
            cld                      ;Because caller does STD
            mov    ax,0a000h         ;EGA video segment address
            mov    es,ax
            mov    bl,80h            ;Current pos in byte
            mov    bh,oldcolor
            mov    di,yoffset        ;Current Y pos in screen RAM
            lea    si,scanline
            mov    dx,3CEH           ;DX gets EGA register address
            mov    cx,width
outloop:    lodsb                    ;Get byte from output queue
            cmp    al,15
            jle    outgo
            push   si
            xor    ah,ah
            mov    si,ax
            mov    al,[si+palette]
            pop    si
outgo:      cmp    al,bh             ;Same as old color?
            jz     skipit            ;Yes, no need to tell EGA new one
            mov    bh,al             ;Set new color as old color
            xchg   ah,al
            xor    al,al             ;Index 0
            out    dx,ax             ;Put out both values at once
skipit:     mov    al,8              ;Now point to mask reg
            mov    ah,bl
            out    dx,ax
            mov    al,es:[di]        ;Latch data by read/write memory
            stosb
            dec    di                ;compensate for auto-increment
            shr    bl,1              ;Shift mask to next bit pos
            or     bl,bl             ;Out of mask?
            jnz    loop1             ;No, skip
            mov    bl,80H            ;Yes, reset mask to top bit
            inc    di                ;DI to next screen byte
loop1:      loop   outloop           ;And keep on
            call   incyc             ;Kick YC and Yoffset to next line
            call   computey
            lea    di,scanline       ;Point DI back to start of scanline
            xor    dx,dx             ;Pos pointer back to 0
            std                      ;set this back the right (wrong) way
            mov    oldcolor,bh       ;save oldcolor for next time
            pop    si
            pop    ds
            pop    cx
            pop    es
            ret

putout      endp

;Compute starting position of this screen line in EGA memory. Just gets
;appropriate value from LINESTART

computey    proc   near
            push   ax
            push   si
            mov    ax,yc
            shl    ax,1
            lea    si,linestart
            add    si,ax
            lodsw
            mov    yoffset,ax
            pop    si
            pop    ax
            ret
computey    endp

;Increment YC if the picture is non-interlaced, otherwise cope with
;interlace

incyc       proc   near
            mov    ax,yc
            cmp    ax,479     ;Quit if we'll overflow EGA bounds
            jnz    incit      ;otherwise increment
            ret
incit:      cmp    byte ptr interlace,0
            jz     simple
            cmp    byte ptr pass,0
            jnz    in2
            add    ax,8
            mov    yc,ax
            cmp    ax,word ptr height
            jl     fin
            inc    byte ptr pass
            mov    word ptr yc,4
            ret
in2:        cmp    byte ptr pass,1
            jnz    in3
            add    ax,8
            mov    yc,ax
            cmp    ax,word ptr height
            jl     fin
            inc    byte ptr pass
            mov    word ptr yc,2
            ret
in3:        cmp    byte ptr pass,2
            jnz    in4
            add    ax,4
            mov    yc,ax
            cmp    ax,word ptr height
            jl     fin
            inc    byte ptr pass
            mov    word ptr yc,1
            ret
in4:        add    ax,2
            mov    yc,ax
            ret
simple:     inc    ax
            mov    yc,ax
fin:        ret
incyc       endp

;This code replaces READCODE. Pick up a 24-bit chunk from the RASTER
;array and make a code of the necessary size out of it. Cope with files
;larger than 64000 bytes here also

readcode    proc   near
            mov    ax,bitoffset
            mov    dx,bitoffset2
            add    ax,codesize
            adc    dx,0
            xchg   ax,bitoffset
            xchg   dx,bitoffset2
            mov    cx,8
            div    cx
            push   ax
            push   ds
            lds    si,raster
            add    si,ax
            les    bx,[si]
            mov    ax,es
            pop    ds
            mov    cx,dx
            jcxz   noshift
shift:      shr    al,1
            rcr    bx,1
            loop   shift
noshift:    and    bx,readmask
            pop    ax
            cmp    byte ptr nextraster,1
            jnz    rdone
            cmp    ah,0f6h
            jnz    rdone
            push   bx
            mov    ax,ds
            push   ax
            lea    ax,bitoffset
            push   ax
            call   moveup
            pop    bx
rdone:      mov    ax,bx
            ret
readcode    endp

nlzw        endp
            cseg   ends
            end    nlzw
            end
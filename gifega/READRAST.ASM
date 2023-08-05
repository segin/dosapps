;****************************************************************************
;Written 1/28-1/29/88 by Jim Griebel.
;This Turbo object external replaces READRASTER, for a considerable gain
;in speed.
;****************************************************************************

data          segment word public
              assume ds:data
              extrn raster:dword,raster2:dword,gifstuff:dword
              extrn nextraster:byte
              extrn gifptr:word

data          ends

cseg          segment byte public
              assume cs:cseg
              extrn allocmem:near
              extrn readmore:near

              public  readrast

;Convert the blocked GIF data stream into an unblocked one. We can do
;this now, or do it later; doing it now saves a good deal of complication
;later on.

readrast      proc near

              push    ds
              mov     ax,gifptr          ;GIFPtr points past header
              les     di,raster          ;to start of blocked data.
              lds     si,gifstuff        ;ES:DI points to RASTER where
              add     si,ax              ;we'll put it.
top:          lodsb                      ;OK. Get block size
              and     al,al              ;If it's 0, we're done
              jz      finis
              mov     cl,al              ;Otherwise use it as loop counter
              xor     ch,ch
bloop:        lodsb                      ;Simple loop: GIFSTUFF>RASTER
              stosb
              cmp     si,64000           ;See if we overran the first
              jnz     ckdi               ;RASTER array. If we did,
              pop     ds
              push    di
              push    es
              push    cx
              call    readmore           ;Call a Turbo routine to get more
              pop     cx                 ;from the GIF file
              pop     es
              pop     di
              push    ds                 ;And repoint to the start of
              lds     si,gifstuff        ;GIFSTUFF
ckdi:         cmp     di,64000           ;See if we ran out of RASTER
              jnz     proceed            ;Nope
              mov     ax,ds              ;If we did, get address of
              pop     ds                 ;RASTER2's pointer
              lea     di,raster2
              inc     byte ptr nextraster
              push    ax                 ;Push sensitive regs
              push    cx
              push    si
              push    ds                 ;And the variable for Turbo
              push    di
              call    allocmem           ;Go get memory for RASTER2
              pop     si
              pop     cx
              pop     ax
              push    ds
              les     di,raster2         ;Repoint DI to actual array
              mov     ds,ax
proceed:      loop    bloop              ;And continue until done.
              jmp     top
finis:        pop     ds
              ret

readrast      endp
              cseg ends
              end  readrast
              end
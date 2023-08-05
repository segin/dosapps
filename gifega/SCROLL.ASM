;****************************************************************************
;Written 1/29-2/4/88 by Jim Griebel.
;Scroll the EGA picture if it is larger than the screen. Scrolling is
;accomplished by mapping the 4 bitplane arrays maintained on the Turbo
;heap back into EGA memory in Write Mode 0. We add an offset value to
;the starting addresses of these arrays in order to move the picture up
;or down on the screen. This value is the Turbo variable ROLL, adjusted
;by the Pascal program in response to user inputs.
;2/3/88 switched from moving the whole bitplane at once to moving bitplanes
;a scan line at a time. Former produced a 'rainbow' effect during scrolling
;with some pictures
;****************************************************************************

data          segment public byte
              assume ds: data

;Turbo variables defined for access by this program

              extrn plane0:dword,plane1:dword,plane2:dword,plane3:dword
              extrn roll:word

data          ends

code          segment
              assume cs:code

              public scroll
              lroll  dw   ?

scroll        proc near

;set up the EGA for new mode; write it a plane at a time

              mov   dx,3CEH
              mov   ax,5               ;Register 5=0, write mode 0
              out   dx,ax              ;Trick I learned from Turbo:
                                       ;this puts 5 out 3CE, 0 out 3CF!
              mov   ax,3
              out   dx,ax              ;Register 3=0, no rotate, no mod
              mov   ax,1               ;Register 1=0, turn off S/R
              out   dx,ax
              mov   ax,0FF08H          ;Register 8=255, all bits enabled
              out   dx,ax
              push  ds                 ;Save DS to keep Turbo happy
              mov   ax,0a000h          ;ES gets EGA video RAM segment
              mov   es,ax
              mov   bx,roll            ;BX offset from start of arrays
              mov   lroll,bx
top:          mov   dx,3C4H            ;3C4=2, 3C5=n, where n=plane no.
              mov   ax,0102H           ;data will go to
              out   dx,ax
              pop   ds
              push  ds
              lds   si,plane0          ;Point DS:SI to bitplane on heap
              add   si,bx              ;Add scroll offset if any
              call  putout             ;Rip it out there
              mov   ax,0202H           ;Same code for remaining bitplanes
              out   dx,ax
              pop   ds                 ;Get DS back to fetch next plane
              push  ds
              lds   si,plane1
              add   si,bx
              call  putout
              mov   ax,0402h
              out   dx,ax
              pop   ds
              push  ds
              lds   si,plane2
              add   si,bx
              call  putout
              mov   ax,0802h
              out   dx,ax
              pop   ds
              push  ds
              lds   si,plane3
              add   si,bx
              call  putout
              add   bx,80
              cmp   bx,38400
              jnz   top
              pop   ds
              ret
scroll        endp

putout        proc  near
              cld
              mov   cx,80              ;Size of scan line
              mov   di,bx              ;Point to start of EGA RAM
              sub   di,lroll
              repz  movsb              ;and crank in the bitplane
              ret                      ;Done
putout        endp

              code  ends
              end   scroll
              end
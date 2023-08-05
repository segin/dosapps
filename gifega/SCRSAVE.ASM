;**************************************************************************
;Written 1/30/88-2/3/88 by Jim Griebel.
;An SCR/SCP save routine written in assembly to avoid Turbo's pickiness
;about file sizes and definitions. The format of the files is simple
;enough: just a 16-bit palette, followed by 4 bitplanes which are either
;28,000 (for a 640x350 pic) or 38,400 (for a 640x480 byte pic) big. For
;some weird reason the bitplanes are written in 0, 2, 1, 3 order.
;As it turns out EGA Paint will not display .SCP files on a 640x350 EGA;
;so the global variable EGAHeight is set to 350 in the main program,
;forcing FSIZE to 28000.
;**************************************************************************



data       segment word public
           assume ds:data

;Turbo's file definition for this file; the first word of the definition
;is, fortunately, the file handle, so we can let Turbo open it

           extrn scrfile:word

;The data that will be written to the file, as defined in Turbo

           extrn palette:word,plane0:dword,plane2:dword,plane1:dword
           extrn plane3:dword

;And the size value for writing out

           extrn fsize: word
           data ends

code       segment word public
           assume cs:code

           public scrsave
scrsave    proc near
           push ds
           lea  dx,palette
           mov  cx,16
           mov  bx,scrfile
           mov  ax,4000h
           int  21h
           mov  bx,scrfile
           mov  cx,fsize
           lds  dx,plane0
           mov  ax,4000h
           int  21h
           pop  ds
           push ds
           mov  bx,scrfile
           mov  cx,fsize
           lds  dx,plane2
           mov  ax,4000h
           int  21h
           pop  ds
           push ds
           mov  bx,scrfile
           mov  cx,fsize
           lds  dx,plane1
           mov  ax,4000h
           int  21h
           pop  ds
           push ds
           mov  bx,scrfile
           mov  cx,fsize
           lds  dx,plane3
           mov  ax,4000h
           int  21h
           pop  ds
           ret
scrsave    endp
           code  ends
           end   scrsave
           end
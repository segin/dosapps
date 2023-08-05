	Page	58,132
	Title	EGA.ASM 	Apple EGA Video Routines
;******************************************************************************
;
;   Name:	EGA.ASM 	Apple EGA Video Routines
;
;   Group:	Emulator
;
;   Revision:	1.00
;
;   Date:	January 30, 1988
;
;   Author:	Randy W. Spurlock
;
;******************************************************************************
;
;  Module Functional Description:
;
;		This module contains all the code for the Apple
;	EGA video routines.
;
;******************************************************************************
;
;  Changes:
;
;    DATE     REVISION				DESCRIPTION
;  --------   --------	-------------------------------------------------------
;   1/30/88	1.00	Original
;
;******************************************************************************
	Page
;
;  Public Declarations
;
	Public	EGA_Text_1		; Low resolution/text page 1 write
	Public	EGA_Text_2		; Low resolution/text page 2 write
	Public	EGA_Graph_1		; High resolution page 1 write
	Public	EGA_Graph_2		; High resolution page 2 write
	Public	EGA_Text_Off		; Text mode off (Graphics)
	Public	EGA_Text_On		; Text mode on (Text)
	Public	EGA_Mixed_Off		; Mixed off (Text / Graphics)
	Public	EGA_Mixed_On		; Mixed on (Text & Graphics)
	Public	EGA_Page_1		; Select video page 1 (Text & Graphics)
	Public	EGA_Page_2		; Select video page 2 (Text & Graphics)
	Public	EGA_Low_Res		; Select low resolution (Graphics)
	Public	EGA_High_Res		; Select high resolution (Graphics)
	Public	EGA_Restore		; EGA restore screen routine
	Public	EGA_Setup		; EGA graphics setup routine
	Public	Update_Toggle		; Update mode toggle routine
;
;  External Declarations
;
	Extrn	Cursor_Off:Near 	; Turn cursor off routine	(VIDEO)
	Extrn	Cursor_On:Near		; Turn cursor on routine	(VIDEO)
	Extrn	Blink_Off:Near		; Turn blink off routine	(VIDEO)
	Extrn	Blink_On:Near		; Turn blink on routine 	(VIDEO)
	Extrn	Set_Address:Near	; Set video address routine	(VIDEO)
	Extrn	Set_LED:Near		; Set LED status routine     (KEYBOARD)
	Extrn	Text_Address:Word	; Text address mapping table	(VIDEO)
	Extrn	Macro_Table:Word	; Text macro table		(VIDEO)
	Extrn	Char_Table:Word 	; Text character mapping table	(VIDEO)
	Extrn	EGA_Address:Word	; EGA graphics address table	(VIDEO)
	Extrn	EGA_Slice:Word		; EGA graphics macro/slice table(VIDEO)
	Extrn	Reverse_Table:Byte	; Bit reversal table		(VIDEO)
	Extrn	EGA_Shift:Byte		; EGA bit shift table		(VIDEO)
	Extrn	Text_CGA:Byte		; CGA display text color table	(VIDEO)
	Extrn	Text_EGA:Byte		; EGA display text color table	(VIDEO)
	Extrn	Low_CGA:Byte		; CGA display low res. table	(VIDEO)
	Extrn	Low_EGA:Byte		; EGA display low res. table	(VIDEO)
	Extrn	High_CGA:Byte		; CGA display high res. table	(VIDEO)
	Extrn	High_EGA:Byte		; EGA display high res. table	(VIDEO)
	Extrn	Key_Status:Byte 	; Keyboard status byte	     (KEYBOARD)
	Extrn	Last_Key:Byte		; Last keyboard scan code    (KEYBOARD)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
	Extrn	Video_Flag:Byte 	; Video system flag byte	 (DATA)
;
;  LOCAL Equates
;
TEXT_PAGE_1	Equ	04h		; Starting text page 1 page value
TEXT_PAGE_2	Equ	08h		; Starting text page 2 page value
GRAPH_PAGE_1	Equ	20h		; Starting graphics page 1 page value
GRAPH_PAGE_2	Equ	40h		; Starting graphics page 2 page value
TEXT_ADDRESS_1	Equ	0400h		; Starting text page 1 address value
TEXT_ADDRESS_2	Equ	0800h		; Starting text page 2 address value
GRAPH_ADDRESS_1 Equ	2000h		; Starting graphics page 1 address value
GRAPH_ADDRESS_2 Equ	4000h		; Starting graphics page 2 address value
BASE_TEXT	Equ	0000h		; Base text video memory address
BASE_GRAPHIC	Equ	4000h		; Base graphics video memory address
BASE_GRAPHIC_1	Equ	4000h		; Base high res. page 1 memory address
BASE_GRAPHIC_2	Equ	6000h		; Base high res. page 2 memory address
BLOCK_CHAR	Equ	0DFh		; Low resolution block character value
SLICE_COUNT	Equ	08h		; Slice count value (8 = 192 Lines)
MACRO_COUNT	Equ	08h		; Macro count value (8 = 24 Rows)
ROW_COUNT	Equ	03h		; Row count value (3 = 3 Rows)
CHAR_COUNT	Equ	28h		; Character column count (40 Bytes)
BYTE_COUNT	Equ	05h		; Graphics byte count (5 = 40 Bytes)
MACRO_OFFSET	Equ	08h		; Macro offset value (Screen holes [8])
NEXT_OFFSET	Equ	50h		; Next row offset value (80)
ROW_OFFSET	Equ	0230h		; Row offset value (7 * 40 * 2)
NEXT_SLICE	Equ	28h		; Next slice offset value (40)
NEXT_MACRO	Equ	0140h		; Next macro set offset value (Graphics)
NEXT_ROW	Equ	09DDh		; Next row offset value (Graphics)
TEXT_MASK	Equ	07FFh		; Text destination mask value
TEXT_MODE	Equ	00h		; Text mode value (40 x 25)
GRAPH_MODE	Equ	0Dh		; Graphics mode value (320 x 200)
COLOR_MASK	Equ	007Fh		; Color bit mask value
DATA_MASK	Equ	0FE00h		; Data mask initial value
ADDRESS_MASK	Equ	07h		; Address bits mask value (Mod 8)
ODD_COLUMN	Equ	0001h		; Odd column test mask value
BYTE_OFFSET	Equ	02h		; Byte offset value
SEQ_INDEX	Equ	3C4h		; Sequencer index port address
CRT_INDEX	Equ	3D4h		; CRT ctrl. index port address
GRA_INDEX	Equ	3CEh		; Graphics ctrl. index port address
ATR_INDEX	Equ	3C0h		; Attribute ctrl. index port address
TEXT_MAP	Equ	0606h		; Text map at 0A000h value
NO_CLEAR	Equ	80h		; Don't clear regen buffer flag bit
FILL_PATTERN	Equ	55h		; Video memory fill pattern byte
FILL_SIZE	Equ	4000h		; Video memory fill size (16384 Bytes)
CLEAR		Equ	0000h		; Page counter clear value (0)
LIMIT		Equ	0AAAh		; Page count limit value (.333 Screen)
SEQ_INDEX	Equ	3C4h		; Sequencer index port address
MAP_MASK	Equ	02h		; Map mask register index value
PLANE_0 	Equ	01h		; Plane 0 map mask value
PLANE_1 	Equ	02h		; Plane 1 map mask value
PLANE_2 	Equ	04h		; Plane 2 map mask value
PLANE_3 	Equ	08h		; Plane 3 map mask value
GRA_INDEX	Equ	3CEh		; Graphics controller index port address
READ_MAP	Equ	04h		; Read map select register index value
READ_0		Equ	00h		; Plane 0 read value
READ_1		Equ	01h		; Plane 1 read value
READ_2		Equ	02h		; Plane 2 read value
READ_3		Equ	03h		; Plane 3 read value
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
	.286c				; Include 80286 instructions
	Page
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	EGA_Text_1	Low Resolution/Text Page 1 Write
	Page	+
;******************************************************************************
;
;	EGA_Text_1(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a text mode and page 1
;			Save the required registers
;			Save the character table index value
;			Calculate macro line and offset values
;			Load offset value from offset table
;			If this is NOT a screen hole
;				Load macro line value from macro table
;				Compute the actual screen address
;				Lookup the character/attribute values
;				Store the character to the screen
;			Endif this is a screen hole
;			Restore the required registers
;		Else this is a graphics mode
;			If this is low resolution graphics mode page 1
;				Save the required registers
;				Save the graphics byte index value
;				Calculate macro line and offset values
;				Load offset value from offset table
;				If this is NOT a screen hole
;					Load macro line value from macro table
;					Compute the actual screen address
;					Lookup the graphics mapping value
;					Force character code to a half block
;					Store the character to the screen
;				Endif this is a screen hole
;				Restore the required registers
;		Endif for mode value
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		DI    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Text_1	Proc	Near		; Low res/text page 1 write procedure
	mov	ds:[di],al		; Write the memory location
	test	cs:[Video_Flag],VIDEO_MODE+PAGE_NUMBER
	jnz	Low_Check_1		; Jump if NOT text mode page 1
	Save	bx			; Save the required registers
	xor	ah,ah			; Convert character to full word
	shl	ax,1			; Convert character to table index
	mov	bp,ax			; Save character table index in BP
	mov	ax,di			; Get the effective memory address
	sub	ah,TEXT_PAGE_1		; Subtract off the starting value
	shl	ax,1			; Move macro number into AH register
	xor	bh,bh			; Setup to index through video tables
	mov	bl,al			; Convert offset into table index
	mov	di,cs:[bx+Text_Address] ; Get the text offset table value
	inc	di			; Increment for screen hole check
	js	Text_1_Hole		; Jump if this is a screen hole
	mov	bl,ah			; Get macro number into BL register
	shl	bx,1			; Convert macro number into table index
	add	di,cs:[bx+Macro_Table]	; Compute the actual screen address
	mov	ax,cs:[bp+Char_Table]	; Lookup the correct character value
	stosw				; Store character value onto screen
Text_1_Hole:
	Restore bx			; Restore the required registers
Text_Done_1:
	ret				; Return to the caller
Low_Check_1:
	test	cs:[Video_Flag],RESOLUTION+PAGE_NUMBER
	jnz	Low_Done_1		; Jump if NOT low resolution page 1
	Save	bx			; Save the required registers
	mov	ah,al			; Move graphics byte to AH register
	mov	bp,ax			; Save graphices byte value in BP
	mov	ax,di			; Get the effective memory address
	sub	ah,TEXT_PAGE_1		; Subtract off the starting value
	shl	ax,1			; Move macro number in AH register
	xor	bh,bh			; Setup to index through video tables
	mov	bl,al			; Convert offset into table index
	mov	di,cs:[bx+Text_Address] ; Get the text offset table value
	inc	di			; Increment for screen hole check
	js	Low_1_Hole		; Jump if this is a screen hole
	mov	bl,ah			; Get macro number into BL register
	shl	bx,1			; Convert macro number into table index
	add	di,cs:[bx+Macro_Table]	; Compute the actual screen offset
	mov	ax,bp			; Restore the graphics byte value
	mov	al,BLOCK_CHAR		; Force character to block character
	stosw				; Store graphics value onto screen
Low_1_Hole:
	Restore bx			; Restore the required registers
Low_Done_1:
	ret				; Return to the caller
EGA_Text_1	Endp			; End of the EGA_Text_1 procedure
	Subttl	EGA_Text_2	Low Resolution/Text Page 2 Write
	Page	+
;******************************************************************************
;
;	EGA_Text_2(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a text mode and page 2
;			Save the required registers
;			Save the character table index value
;			Calculate macro line and offset values
;			Load offset value from offset table
;			If this is NOT a screen hole
;				Load macro line value from macro table
;				Compute the actual screen address
;				Lookup the character/attribute values
;				Store the character to the screen
;			Endif this is a screen hole
;			Restore the required registers
;		Else this is a graphics mode
;			If this is low resolution graphics mode page 2
;				Save the required registers
;				Save the graphics byte index value
;				Calculate macro line and offset values
;				Load offset value from offset table
;				If this is NOT a screen hole
;					Load macro line value from macro table
;					Compute the actual screen address
;					Lookup the graphics mapping value
;					Force character code to a half block
;					Store the character to the screen
;				Endif this is a screen hole
;				Restore the required registers
;		Endif for mode value
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		DI    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Text_2	Proc	Near		; Low res/text page 2 write procedure
	mov	ds:[di],al		; Write the memory location
	test	cs:[Video_Flag],VIDEO_MODE+PAGE_INV
	jnz	Low_Check_2		; Jump if NOT text mode page 2
	Save	bx			; Save the required registers
	xor	ah,ah			; Convert character to full word
	shl	ax,1			; Convert character to table index
	mov	bp,ax			; Save character table index in BP
	mov	ax,di			; Get the effective memory address
	sub	ah,TEXT_PAGE_2		; Subtract off the starting value
	shl	ax,1			; Move macro number into AH register
	xor	bh,bh			; Setup to index through video tables
	mov	bl,al			; Convert offset into table index
	mov	di,cs:[bx+Text_Address] ; Get the text offset table value
	inc	di			; Increment for screen hole check
	js	Text_2_Hole		; Jump if this is a screen hole
	mov	bl,ah			; Get macro number into BL register
	shl	bx,1			; Convert macro number into table index
	add	di,cs:[bx+Macro_Table]	; Compute the actual screen address
	mov	ax,cs:[bp+Char_Table]	; Lookup the correct character value
	stosw				; Store character value onto screen
Text_2_Hole:
	Restore bx			; Restore the required registers
Text_Done_2:
	ret				; Return to the caller
Low_Check_2:
	test	cs:[Video_Flag],RESOLUTION+PAGE_INV
	jnz	Low_Done_2		; Jump if NOT low resolution page 2
	Save	bx			; Save the required registers
	mov	ah,al			; Move graphics byte to AH register
	mov	bp,ax			; Save graphices byte value in BP
	mov	ax,di			; Get the effective memory address
	sub	ah,TEXT_PAGE_2		; Subtract off the starting value
	shl	ax,1			; Move macro number in AH register
	xor	bh,bh			; Setup to index through video tables
	mov	bl,al			; Convert offset into table index
	mov	di,cs:[bx+Text_Address] ; Get the text offset table value
	inc	di			; Increment for screen hole check
	js	Low_2_Hole		; Jump if this is a screen hole
	mov	bl,ah			; Get macro number into BL register
	shl	bx,1			; Convert macro number into table index
	add	di,cs:[bx+Macro_Table]	; Compute the actual screen offset
	mov	ax,bp			; Restore the graphics byte value
	mov	al,BLOCK_CHAR		; Force character to block character
	stosw				; Store graphics value onto screen
Low_2_Hole:
	Restore bx			; Restore the required registers
Low_Done_2:
	ret				; Return to the caller
EGA_Text_2	Endp			; End of the EGA_Text_2 procedure
	Subttl	EGA_Graph_1	High Resolution Graphics Page 1 Write
	Page	+
;******************************************************************************
;
;	EGA_Graph_1(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a graphics mode and update required
;			Save the required registers
;			Get the base video memory address
;			Save the bit value table index value
;			Calculate macro/slice and offset values
;			Load offset value from offset table
;			If this is NOT a screen hole
;				Load macro/slice value from macro/slice table
;				Compute the actual screen address
;				If data value is non-zero
;					Lookup the reverse bit value
;					Lookup the shift value
;					Setup to read/write to plane 0
;					Get the data mask value
;					Shift the data mask into position
;					Update the screen data bytes
;					Setup to read/write to plane 2
;					Get the data mask value
;					Update the screen data bytes
;				Else data is zero (Clear request)
;					Setup to read/write to plane 0
;					Get the data mask value
;					Shift the data mask into position
;					Update the screen data bytes (Mask bits)
;				Endif for special data values
;			Endif this is a screen hole
;			Restore the required registers
;		Endif this is NOT a graphics mode
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		DI    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Graph_1	Proc	Near		; High res page 1 write procedure
	mov	ds:[di],al		; Write the memory location
	mov	ah,VIDEO_INV+RES_INV	; Default to special type update
	mov	bp,BASE_GRAPHIC_1	; Get high res. page 1 memory address
	test	cs:[Key_Status],TYPE_SPECIAL
	jnz	EGA_Check_1		; Jump if this is special update type
	or	ah,PAGE_NUMBER		; Setup for standard update check
	mov	bp,BASE_GRAPHIC 	; Get graphics base memory address
EGA_Check_1:
	test	cs:[Video_Flag],ah	; Check for a video update needed
	jnz	Low_Done_2		; Jump if an update is NOT needed
	Save	bx,cx,dx,si		; Save the required registers
	mov	si,bp			; Get correct graphics base memory
	mov	dl,al			; Get copy of memory value into DL
	sar	dl,7			; Convert DL into plane 2 value
	and	ax,COLOR_MASK		; Mask off all but the color bits
	mov	bp,ax			; Save bit value table index in BP
	mov	ax,di			; Get the effective memory address
	and	di,ADDRESS_MASK 	; Mask all but required address bits
	sub	ah,GRAPH_PAGE_1 	; Subtract off the starting value
	shl	ax,1			; Move macro/slice number to AH register
	xor	bx,bx			; Setup to index through video tables
	xchg	al,bl			; Convert offset into table index
	mov	bx,cs:[bx+EGA_Address]	; Get the graphics offset table value
	inc	bx			; Increment for screen hole check
	js	Graph_Exit_1		; Jump if this is a screen hole
	xchg	ax,bx			; Save offset value in AX register
	xchg	bl,bh			; Get macro/slice number to BL register
	shl	bx,1			; Convert macro/slice into table index
	add	ax,cs:[bx+EGA_Slice]	; Compute the actual screen offset
	add	si,ax			; Compute the actual screen address
	or	bp,bp			; Check for zero data bits
	jz	Graph_1_Clear		; Jump if this is a clear request
	mov	bl,cs:[bp+Reverse_Table]; Lookup the reverse bit value
	mov	bh,dl			; Move plane 2 value into BH register
	mov	cl,cs:[di+EGA_Shift]	; Get the shift count value
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_0 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 0
	mov	dx,GRA_INDEX		; Get graphics ctrl. index port address
	mov	ax,READ_0 Shl 8 + READ_MAP
	out	dx,ax			; Setup to read from plane 0
	mov	ax,DATA_MASK		; Get the initial data mask value
	shr	ax,cl			; Shift data mask into position
	not	ax			; Invert the mask polarity
	mov	di,ax			; Save a copy of the mask value
	and	ah,es:[si]		; Mask off first 8 data bits to replace
	and	al,es:[si+1]		; Mask off second 8 data bits to replace
	mov	dh,bl			; Get the new plane 0 data bits value
	xor	dl,dl			; Convert data bits to full word
	shr	dx,cl			; Shift data bits into position
	or	ax,dx			; Logically OR in the new data bits
	mov	es:[si],ah		; Update first 8 screen data bits
	mov	es:[si+1],al		; Update second 8 screen data bits
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_2 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 2
	mov	dx,GRA_INDEX		; Get graphics ctrl. index port address
	mov	ax,READ_2 Shl 8 + READ_MAP
	out	dx,ax			; Setup to read from plane 2
	mov	ax,di			; Restore the shifted mask value
	and	ah,es:[si]		; Mask off first 8 data bits to replace
	and	al,es:[si+1]		; Mask off second 8 data bits to replace
	mov	dh,bh			; Get the new plane 3 data bits value
	xor	dl,dl			; Convert data bits to full word
	shr	dx,cl			; Shift data bits into position
	or	ax,dx			; Logically OR in the new data bits
	mov	es:[si],ah		; Update first 8 screen data bits
	mov	es:[si+1],al		; Update second 8 screen data bits
Graph_Exit_1:
	Restore bx,cx,dx,si		; Restore the required registers
Graph_Done_1:
	ret				; Return to the caller
Graph_1_Clear:
	mov	cl,cs:[di+EGA_Shift]	; Get the shift count value
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_0 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 0
	mov	dx,GRA_INDEX		; Get graphics ctrl. index port address
	mov	ax,READ_0 Shl 8 + READ_MAP
	out	dx,ax			; Setup to read from plane 0
	mov	ax,DATA_MASK		; Get the initial data mask value
	shr	ax,cl			; Shift data mask into position
	not	ax			; Invert the mask polarity
	mov	di,ax			; Save a copy of the mask value
	and	es:[si],ah		; Mask off first 8 data bits
	and	es:[si+1],al		; Mask off second 8 data bits
	Restore bx,cx,dx,si		; Restore the required registers
	ret				; Return to the caller
EGA_Graph_1	Endp			; End of the EGA_Graph_1 procedure
	Subttl	EGA_Graph_2	High Resolution Graphics Page 2 Write
	Page	+
;******************************************************************************
;
;	EGA_Graph_2(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a graphics mode and update required
;			Save the required registers
;			Get the base video memory address
;			Save the bit value table index value
;			Calculate macro/slice and offset values
;			Load offset value from offset table
;			If this is NOT a screen hole
;				Load macro/slice value from macro/slice table
;				Compute the actual screen address
;				If data value is non-zero
;					Lookup the reverse bit value
;					Lookup the shift value
;					Setup to read/write to plane 0
;					Get the data mask value
;					Shift the data mask into position
;					Update the screen data bytes
;					Setup to read/write to plane 2
;					Get the data mask value
;					Update the screen data bytes
;				Else data is zero (Clear request)
;					Setup to read/write to plane 0
;					Get the data mask value
;					Shift the data mask into position
;					Update the screen data bytes (Mask bits)
;				Endif for special data values
;			Endif this is a screen hole
;			Restore the required registers
;		Endif this is NOT a graphics mode
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		DI    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Graph_2	Proc	Near		; High res page 2 write procedure
	mov	ds:[di],al		; Write the memory location
	mov	ah,VIDEO_INV+RES_INV	; Default to special type update
	mov	bp,BASE_GRAPHIC_2	; Get high res. page 2 memory address
	test	cs:[Key_Status],TYPE_SPECIAL
	jnz	EGA_Check_2		; Jump if this is special update type
	or	ah,PAGE_INV		; Setup for standard update check
	mov	bp,BASE_GRAPHIC 	; Get graphics base memory address
EGA_Check_2:
	test	cs:[Video_Flag],ah	; Check for a video update needed
	jnz	Graph_Done_1		; Jump if NOT high res. mode page 2
	Save	bx,cx,dx,si		; Save the required registers
	mov	si,bp			; Get correct graphics base memory
	mov	dl,al			; Get copy of memory value into DL
	sar	dl,7			; Convert DL into plane 2 value
	and	ax,COLOR_MASK		; Mask off all but the color bits
	mov	bp,ax			; Save bit value table index in BP
	mov	ax,di			; Get the effective memory address
	and	di,ADDRESS_MASK 	; Mask all but required address bits
	sub	ah,GRAPH_PAGE_2 	; Subtract off the starting value
	shl	ax,1			; Move macro/slice number to AH register
	xor	bx,bx			; Setup to index through video tables
	xchg	al,bl			; Convert offset into table index
	mov	bx,cs:[bx+EGA_Address]	; Get the graphics offset table value
	inc	bx			; Increment for screen hole check
	js	Graph_Exit_2		; Jump if this is a screen hole
	xchg	ax,bx			; Save offset value in AX register
	xchg	bl,bh			; Get macro/slice number to BL register
	shl	bx,1			; Convert macro/slice into table index
	add	ax,cs:[bx+EGA_Slice]	; Compute the actual screen offset
	add	si,ax			; Compute the actual screen address
	or	bp,bp			; Check for zero data bits
	jz	Graph_2_Clear		; Jump if this is a clear request
	mov	bl,cs:[bp+Reverse_Table]; Lookup the reverse bit value
	mov	bh,dl			; Move plane 2 value into BH register
	mov	cl,cs:[di+EGA_Shift]	; Get the shift count value
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_0 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 0
	mov	dx,GRA_INDEX		; Get graphics ctrl. index port address
	mov	ax,READ_0 Shl 8 + READ_MAP
	out	dx,ax			; Setup to read from plane 0
	mov	ax,DATA_MASK		; Get the initial data mask value
	shr	ax,cl			; Shift data mask into position
	not	ax			; Invert the mask polarity
	mov	di,ax			; Save a copy of the mask value
	and	ah,es:[si]		; Mask off first 8 data bits to replace
	and	al,es:[si+1]		; Mask off second 8 data bits to replace
	mov	dh,bl			; Get the new plane 0 data bits value
	xor	dl,dl			; Convert data bits to full word
	shr	dx,cl			; Shift data bits into position
	or	ax,dx			; Logically OR in the new data bits
	mov	es:[si],ah		; Update first 8 screen data bits
	mov	es:[si+1],al		; Update second 8 screen data bits
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_2 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 2
	mov	dx,GRA_INDEX		; Get graphics ctrl. index port address
	mov	ax,READ_2 Shl 8 + READ_MAP
	out	dx,ax			; Setup to read from plane 2
	mov	ax,di			; Restore the shifted mask value
	and	ah,es:[si]		; Mask off first 8 data bits to replace
	and	al,es:[si+1]		; Mask off second 8 data bits to replace
	mov	dh,bh			; Get the new plane 3 data bits value
	xor	dl,dl			; Convert data bits to full word
	shr	dx,cl			; Shift data bits into position
	or	ax,dx			; Logically OR in the new data bits
	mov	es:[si],ah		; Update first 8 screen data bits
	mov	es:[si+1],al		; Update second 8 screen data bits
Graph_Exit_2:
	Restore bx,cx,dx,si		; Restore the required registers
Graph_Done_2:
	ret				; Return to the caller
Graph_2_Clear:
	mov	cl,cs:[di+EGA_Shift]	; Get the shift count value
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_0 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 0
	mov	dx,GRA_INDEX		; Get graphics ctrl. index port address
	mov	ax,READ_0 Shl 8 + READ_MAP
	out	dx,ax			; Setup to read from plane 0
	mov	ax,DATA_MASK		; Get the initial data mask value
	shr	ax,cl			; Shift data mask into position
	not	ax			; Invert the mask polarity
	mov	di,ax			; Save a copy of the mask value
	and	es:[si],ah		; Mask off first 8 data bits
	and	es:[si+1],al		; Mask off second 8 data bits
	Restore bx,cx,dx,si		; Restore the required registers
	ret				; Return to the caller
EGA_Graph_2	Endp			; End of the EGA_Graph_2 procedure
	Subttl	EGA_Text_Off	Text Off Routine (Graphics)
	Page	+
;******************************************************************************
;
;	EGA_Text_Off(RAM_Space, Video_Segment)
;
;		If currently in a text mode
;			Reset the text mode flag bit (Graphics)
;			If in high resolution graphics mode
;				Set graphics mode D (320 x 200)
;			Endif for high resolution graphics mode
;			Call routine to program the colors
;			Call routine to enable intensity (No blink)
;			Call routine to restore graphics screen
;		Endif for text mode
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Text_Off	Proc	Near		; Text off (Graphics) procedure
	test	cs:[Video_Flag],VIDEO_MODE
	jnz	Text_Off_Done		; Jump if this is NOT a text mode
	or	cs:[Video_Flag],VIDEO_MODE
	and	cs:[Video_Flag],Not VIDEO_INV
	test	cs:[Video_Flag],RESOLUTION
	jz	Do_Graphic		; Jump if low resolution graphics
Do_EGA_High:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE + NO_CLEAR; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
Do_Graphic:
	call	Color_Program		; Call routine to program the colors
	call	Blink_Off		; Call routine to turn blink off
	call	Graphic_Restore 	; Call routine to restore graphics
Text_Off_Done:
	ret				; Return to the caller
EGA_Text_Off	Endp			; End of the EGA_Text_Off procedure
	Subttl	EGA_Text_On	Text On Routine (Text)
	Page	+
;******************************************************************************
;
;	EGA_Text_On(RAM_Space, Video_Segment)
;
;		If currently in a graphics mode
;			Reset the graphics mode flag bit (Text)
;			If in high resolution graphics mode
;				Set text mode 0 (40x25)
;				Set video memory address to 0A000h
;				Call routine to turn off cursor
;			Endif
;			Call routine to program the colors
;			Call routine to enable blink (No intensity)
;			Call routine to restore text screen
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Text_On	Proc	Near		; Text on (Text) procedure
	test	cs:[Video_Flag],VIDEO_MODE
	jz	Text_On_Done		; Jump if this is a text mode
	and	cs:[Video_Flag],Not VIDEO_MODE
	or	cs:[Video_Flag],VIDEO_INV
	test	cs:[Video_Flag],RESOLUTION
	jz	Do_Text 		; Jump if low resolution graphics
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE + NO_CLEAR ; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	Save	dx			; Save the required registers
	mov	dx,GRA_INDEX		; Get graphics controller index port
	mov	ax,TEXT_MAP		; Get the text memory mapping value
	out	dx,ax			; Set text memory to 0A000h
	Restore dx			; Restore the required registers
	call	Cursor_Off		; Call routine to turn cursor off
Do_Text:
	call	Color_Program		; Call routine to program the colors
	call	Blink_On		; Call routine to turn blink on
	call	Text_Restore		; Call routine to restore text
Text_On_Done:
	ret				; Return to the caller
EGA_Text_On	Endp			; End of the EGA_Text_On procedure
	Subttl	EGA_Mixed_Off	Mixed Off Routine (Text/Graphics)
	Page	+
;******************************************************************************
;
;	EGA_Mixed_Off()
;
;		If this is mixed mode
;			Reset mixed mode flag bit
;			If this is a graphics mode
;				Call routine to restore graphics screen
;			Endif
;		Endif this is mixed mode
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Mixed_Off	Proc	Near		; Mixed off (Text/Graphics) procedure
	mov	al,cs:[Video_Flag]	; Get the video flag word
	test	al,MIXED_MODE		; Check for mixed mode already selected
	jz	Mixed_On_Done		; Jump if this IS mixed mode already
	and	cs:[Video_Flag],Not MIXED_MODE
	or	cs:[Video_Flag],MIXED_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jz	Mixed_Off_Done		; Jump if this is NOT a graphics mode
	call	Graphic_Restore 	; Call routine to restore graphics
Mixed_Off_Done:
	ret				; Return to the caller
EGA_Mixed_Off	Endp			; End of the EGA_Mixed_Off procedure
	Subttl	EGA_Mixed_On	Mixed On Routine (Text & Graphics)
	Page	+
;******************************************************************************
;
;	EGA_Mixed_On()
;
;		If this is NOT mixed mode
;			Set mixed mode flag bit
;			If this is a graphics mode
;				Call routine to update mixed screen
;			Endif
;		Endif this is NOT mixed mode
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Mixed_On	Proc	Near		; Mixed on (Text & Graphics) procedure
	mov	al,cs:[Video_Flag]	; Get the video flag word
	test	al,MIXED_MODE		; Check for mixed mode already selected
	jnz	Mixed_On_Done		; Jump if this IS mixed mode already
	or	cs:[Video_Flag],MIXED_MODE
	and	cs:[Video_Flag],Not MIXED_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jz	Mixed_On_Done		; Jump if this is NOT a graphics mode
	call	Mixed_Update		; Call routine to update mixed screen
Mixed_On_Done:
	ret				; Return to the caller
EGA_Mixed_On	Endp			; End of the EGA_Mixed_On procedure
	Subttl	EGA_Page_1	Select Page 1 Routine
	Page	+
;******************************************************************************
;
;	EGA_Page_1(RAM_Space, Video_Segment)
;
;		If this is NOT page 1
;			Reset page number flag bit (Page 1)
;			If this is a text mode
;				Call routine to restore text screen
;			Else this is a graphics mode
;				If in high resolution graphics mode
;					If special update type in effect
;						Get high res. page 1 address
;						Call routine to set address
;					Else standard update type
;						Call restore graphics screen
;					Endif for update type
;				Else in low resolution graphics mode
;					Call routine to restore graphics screen
;				Endif for graphics mode
;			Endif for mode type
;		Endif this is NOT page 1
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Page_1	Proc	Near		; Select video page 1 procedure
	mov	al,cs:[Video_Flag]	; Get the video flag word
	test	al,PAGE_NUMBER		; Check for page 1 already selected
	jz	Page_1_Done		; Jump if this IS page 1 already
	and	cs:[Video_Flag],Not PAGE_NUMBER
	or	cs:[Video_Flag],PAGE_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jnz	Graphics_1		; Jump if this is a graphics mode
	call	Text_Restore		; Call routine to restore text screen
	jmp	Short Page_1_Done	; Go return to the caller
Graphics_1:
	test	cs:[Video_Flag],RESOLUTION
	jz	Do_Standard_1		; Jump if low resolution graphics
	test	cs:[Key_Status],TYPE_SPECIAL
	jz	Do_Standard_1		; Jump if standard update type
Do_Special_1:
	mov	bp,BASE_GRAPHIC_1	; Get high resolution page 1 address
	call	Set_Address		; Call routine to set video address
	jmp	Short Page_1_Done	; Go return to the caller
Do_Standard_1:
	call	Graphic_Restore 	; Call routine to restore graphics
Page_1_Done:
	ret				; Return to the caller
EGA_Page_1	Endp			; End of the EGA_Page_1 procedure
	Subttl	EGA_Page_2	Select Page 2 Routine
	Page	+
;******************************************************************************
;
;	EGA_Page_2(RAM_Space, Video_Segment)
;
;		If this is NOT page 2
;			Set page number flag bit (Page 2)
;			If this is a text mode
;				Call routine to restore text screen
;			Else this is a graphics mode
;				If in high resolution graphics mode
;					If special update type in effect
;						Get high res. page 2 address
;						Call routine to set address
;					Else standard update type
;						Call restore graphics screen
;					Endif for update type
;				Else in low resolution graphics mode
;					Call routine to restore graphics screen
;				Endif for graphics mode
;			Endif for mode type
;		Endif this is NOT page 2
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Page_2	Proc	Near		; Select video page 2 procedure
	mov	al,cs:[Video_Flag]	; Get the video flag word
	test	al,PAGE_NUMBER		; Check for page 2 already selected
	jnz	Page_2_Done		; Jump if this IS page 2 already
	or	cs:[Video_Flag],PAGE_NUMBER
	and	cs:[Video_Flag],Not PAGE_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jnz	Graphics_2		; Jump if this is a graphics mode
	call	Text_Restore		; Call routine to restore text screen
	jmp	Short Page_2_Done	; Go return to the caller
Graphics_2:
	test	cs:[Video_Flag],RESOLUTION
	jz	Do_Standard_2		; Jump if low resolution graphics
	test	cs:[Key_Status],TYPE_SPECIAL
	jz	Do_Standard_2		; Jump if standard update type
Do_Special_2:
	mov	bp,BASE_GRAPHIC_2	; Get high resolution page 1 address
	call	Set_Address		; Call routine to set video address
	jmp	Short Page_2_Done	; Go return to the caller
Do_Standard_2:
	call	Graphic_Restore 	; Call routine to restore graphics
Page_2_Done:
	ret				; Return to the caller
EGA_Page_2	Endp			; End of the EGA_Page_2 procedure
	Subttl	EGA_Low_Res	Select Low Resolution Routine
	Page	+
;******************************************************************************
;
;	EGA_Low_Res()
;
;		If this is NOT low resolution mode
;			Set low resolution mode flag bit
;			If this is a graphics mode
;				Set text mode 0 (40x25)
;				Set video memory address to 0A000h
;				Call routine to program the colors
;				Call routine to turn off cursor
;				Call routine to enable intensity (No blink)
;				Call routine to restore graphics
;			Endif
;		Endif this is NOT low resolution mode
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Low_Res	Proc	Near		; Select low resolution procedure
	mov	al,cs:[Video_Flag]	; Get the video flag byte
	test	al,RESOLUTION		; Check for low resolution mode
	jz	Low_Res_Done		; Jump if this IS low resolution
	and	cs:[Video_Flag],Not RESOLUTION
	or	cs:[Video_Flag],RES_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jz	Low_Res_Done		; Jump if this is NOT a graphics mode
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE + NO_CLEAR ; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	Save	dx			; Save the required registers
	mov	dx,GRA_INDEX		; Get graphics controller index port
	mov	ax,TEXT_MAP		; Get the text memory mapping value
	out	dx,ax			; Set text memory to 0A000h
	Restore dx			; Restore the required registers
	call	Color_Program		; Call routine to program the colors
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_Off		; Call routine to turn blink off
	call	Graphic_Restore 	; Call routine to restore graphics
Low_Res_Done:
	ret				; Return to the caller
EGA_Low_Res	Endp			; End of the EGA_Low_Res procedure
	Subttl	EGA_High_Res	Select High Resolution Routine
	Page	+
;******************************************************************************
;
;	EGA_High_Res()
;
;		If this is NOT high resolution mode
;			Set high resolution mode flag bit
;			If this is a graphics mode
;				Set graphics mode D (320 x 200)
;				Call routine to program the colors
;				Call routine to restore graphics
;			Endif
;		Endif this is NOT high resolution mode
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_High_Res	Proc	Near		; Select high resolution procedure
	mov	al,cs:[Video_Flag]	; Get the video flag byte
	test	al,RESOLUTION		; Check for high resolution mode
	jnz	High_Res_Done		; Jump if this IS high resolution
	or	cs:[Video_Flag],RESOLUTION
	and	cs:[Video_Flag],Not RES_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jz	High_Res_Done		; Jump if this is NOT a graphics mode
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE + NO_CLEAR; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
	call	Color_Program		; Call routine to program the colors
	call	Graphic_Restore 	; Call routine to restore graphics
High_Res_Done:
	ret				; Return to the caller
EGA_High_Res	Endp			; End of the EGA_High_Res procedure
	Subttl	Text_Restore	Restore Text Screen Routine
	Page	+
;******************************************************************************
;
;	Text_Restore(RAM_Space, Video_Segment)
;
;		Save the required registers
;		Set source index to page 1 memory (0400h)
;		If page 2 is selected
;			Set source index to page 2 memory (0800h)
;		Endif
;		Set destination index to text video memory (BASE_TEXT)
;		Call routine to restore the text memory
;		Setup base address to text video memory (BASE_TEXT)
;		Call routine to set base video address
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Text_Restore	Proc	Near		; Restore text screen procedure
	Save	bx,cx,dx,si,di		; Save the required registers
	mov	si,TEXT_ADDRESS_1	; Setup source index for page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Do_Restore		; Jump if this really is page 1
	mov	si,TEXT_ADDRESS_2	; Setup base address for page 2
Do_Restore:
	mov	di,BASE_TEXT		; Setup destination index
	mov	bp,TEXT_MASK		; Setup destination mask value
	call	Restore_Text		; Call routine to restore text page 1
Text_Set:
	mov	bp,BASE_TEXT Shr 1	; Setup base text video address
	call	Set_Address		; Call routine to set base address
	Restore bx,cx,dx,si,di		; Restore the required registers
	ret				; Return to the caller
Text_Restore	Endp			; End of the Text_Restore procedure
	Subttl	Restore_Text	Restore Text Memory Routine
	Page	+
;******************************************************************************
;
;	Restore_Text(RAM_Space, Video_Segment, Source, Destination, Mask)
;
;		Set Macro_Counter to 8 (Restore 8 macro lines [24 rows])
;		While Macro_Counter > 0
;			Set Row_Counter to 3 (Restore 3 rows)
;			While Row_Counter > 0
;				Set Character_Counter to 40 (Restore 40 columns)
;				While Character_Counter > 0
;					Load a character code from memory
;					Lookup the character/attribute value
;					Store character/attribute to memory
;					Decrement the Character_Counter
;				Endwhile for Character_Count
;				Increment destination index by ROW_OFFSET (8)
;				Mask off all but valid destination address bits
;			Endwhile for Row_Counter
;			Increment source index by MACRO_OFFSET (8)
;		Endwhile for Macro_Counter
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - 65C02 RAM space source index
;		ES:DI - Video memory segment destination index
;		BP    - Destination index address mask
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Restore_Text	Proc	Near		; Restore text memory procedure
	mov	dh,MACRO_COUNT		; Setup the macro count (8 = 24 Rows)
Macro_Loop:
	mov	dl,ROW_COUNT		; Setup the row count (3 Rows)
	Save	di			; Save the destination index value
Row_Loop:
	mov	cx,CHAR_COUNT		; Setup the character count (40 Columns)
Char_Loop:
	lodsb				; Load the character code from memory
	xor	ah,ah			; Convert character code to full word
	shl	ax,1			; Convert character code to table index
	mov	bx,ax			; Setup to translate the character
	mov	ax,cs:[bx + Char_Table] ; Lookup the correct character value
	stosw				; Store the character code to memory
	loop	Char_Loop		; Loop till all columns are moved
	add	di,ROW_OFFSET		; Increment destination address value
	and	di,bp			; Mask off all but valid address bits
	dec	dl			; Decrement the row counter value
	jnz	Row_Loop		; Jump if more rows to move
	add	si,MACRO_OFFSET 	; Increment source address value
	Restore di			; Restore the destination index value
	add	di,NEXT_OFFSET		; Increment destination address value
	dec	dh			; Decrement the macro counter value
	jnz	Macro_Loop		; Jump if more macro lines to moves
	ret				; Return to the caller
Restore_Text	Endp			; End of the Restore_Text procedure
	Subttl	Graphic_Restore Restore Graphic Screen Routine
	Page	+
;******************************************************************************
;
;	Graphic_Restore(RAM_Space, Video_Segment)
;
;		Save the required registers
;		If in low resolution graphics mode
;			Set source index to page 1 memory (0400h)
;			If page 2 is selected
;				Set source index to page 2 memory (0800h)
;			Endif
;			Call routine to restore low resolution memory
;			Setup base address to text memory (BASE_TEXT)
;		Else in high resolution graphics mode
;			If special update type selected
;				Set source index to page 1 (2000h)
;				Set destination to high res. page 1
;				Call routine to restore graphics screen
;				Set source index to page 2 (4000h)
;				Set destination to high res. page 2
;				Call routine to restore graphics screen
;				Set address to graphics page 1
;				If page 2 is selected
;					Set address to graphics page 2
;				Endif
;			Else standard update type selected
;				Set source index to page 1 (2000h)
;				If page 2 is selected
;					Set source index to page 2 (4000h)
;				Endif
;				Set destination to graphics video memory
;				Call routine to restore graphics screen
;				Setup address to graphics memory (BASE_GRAPHIC)
;			Endif for special update
;		Endif for type of graphics mode
;		Call routine to set base video address
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Video memory segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Graphic_Restore Proc	Near		; Restore graphic screen procedure
	Save	bx,cx,dx,si,di		; Save the required registers
	test	cs:[Video_Flag],RESOLUTION
	jz	Low_Restore		; Jump if this is low resolution
High_Restore:
	test	cs:[Key_Status],TYPE_SPECIAL
	jz	Do_Standard		; Jump if standard update type
Do_Special:
	mov	si,GRAPH_ADDRESS_1	; Setup base address for page 1
	mov	di,BASE_GRAPHIC_1	; Setup for page 1 video restore
	call	Restore_High		; Call routine to restore page 1
	mov	si,GRAPH_ADDRESS_2	; Setup base address for page 2
	mov	di,BASE_GRAPHIC_2	; Setup for page 2 video restore
	call	Restore_High		; Call routine to restore page 2
	mov	bp,BASE_GRAPHIC_1	; Default to high resolution page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Graphic_Set		; Jump if this really is page 1
	mov	bp,BASE_GRAPHIC_2	; Setup base address for page 2
	jmp	Short Graphic_Set	; Go set the video address
Do_Standard:
	mov	si,GRAPH_ADDRESS_1	; Setup source index for page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Do_High 		; Jump if this really is page 1
	mov	si,GRAPH_ADDRESS_2	; Setup base address for page 2
Do_High:
	mov	di,BASE_GRAPHIC 	; Default to page 1 video restore
	call	Restore_High		; Call routine to restore high res.
	mov	bp,BASE_GRAPHIC 	; Default to page 1 video address
	jmp	Short Graphic_Set	; Go setup the base address value
Low_Restore:
	mov	si,TEXT_ADDRESS_1	; Setup source index for page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Do_Low			; Jump if this really is page 1
	mov	si,TEXT_ADDRESS_2	; Setup base address for page 2
Do_Low:
	mov	di,BASE_TEXT		; Setup destination index
	mov	bp,TEXT_MASK		; Setup destination mask value
	call	Restore_Low		; Call routine to restore low page 1
	mov	bp,BASE_TEXT Shr 1	; Get base text video address
Graphic_Set:
	call	Set_Address		; Call routine to set base address
Graphic_Done:
	Restore bx,cx,dx,si,di		; Restore the required registers
	ret				; Return to the caller
Graphic_Restore Endp			; End of the Graphic_Restore procedure
	Subttl	Restore_Low	Restore Low Resolution Memory Routine
	Page	+
;******************************************************************************
;
;	Restore_Low(RAM_Space, Video_Segment, Source, Destination, Mask)
;
;		Set Macro_Counter to 8 (Restore 8 macro lines [24 rows])
;		While Macro_Counter > 0
;			Set Row_Counter to 3 (Restore 3 rows)
;			While Row_Counter > 0
;				Set Character_Counter to 40 (Restore 40 columns)
;				While Character_Counter > 0
;					Load a graphics byte from memory
;					Force character code to half block value
;					Store character/attribute to memory
;					Decrement the Character_Counter
;				Endwhile for Character_Count
;				Increment destination index by ROW_OFFSET (8)
;				Mask off all but valid destination address bits
;			Endwhile for Row_Counter
;			Increment source index by MACRO_OFFSET (8)
;		Endwhile for Macro_Counter
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - 65C02 RAM space source index
;		ES:DI - Video memory segment destination index
;		BP    - Destination index address mask
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Restore_Low	Proc	Near		; Restore low res. memory procedure
	mov	dh,MACRO_COUNT		; Setup the macro count (8 = 24 Rows)
Loop_Macro:
	mov	dl,ROW_COUNT		; Setup the row count (3 Rows)
	Save	di			; Save the destination index value
Loop_Row:
	mov	cx,CHAR_COUNT		; Setup the character count (40 Columns)
Loop_Byte:
	lodsb				; Load the graphics byte from memory
	mov	ah,al			; Move graphics byte to AH register
	mov	al,BLOCK_CHAR		; Force block character code value
	stosw				; Store the character code to memory
	loop	Loop_Byte		; Loop till all columns are moved
	add	di,ROW_OFFSET		; Increment destination address value
	and	di,bp			; Mask off all but valid address bits
	dec	dl			; Decrement the row counter value
	jnz	Loop_Row		; Jump if more rows to move
	add	si,MACRO_OFFSET 	; Increment source address value
	Restore di			; Restore the destination index value
	add	di,NEXT_OFFSET		; Increment destination address value
	dec	dh			; Decrement the macro counter value
	jnz	Loop_Macro		; Jump if more macro lines to moves
	ret				; Return to the caller
Restore_Low	Endp			; End of the Restore_Low procedure
	Subttl	Restore_High	Restore High Resolution Memory Routine
	Page	+
;******************************************************************************
;
;	Restore_High(RAM_Space, Video_Segment, Source, Destination)
;
;		Setup to write to plane 0
;		Set Slice_Counter to 8 (Restore 8 slices [192 lines])
;		While Slice_Counter > 0
;			Set Macro_Counter to 8 (Restore 8 macro lines [24 rows])
;			While Macro_Counter > 0
;				Set Row_Counter to 3 (Restore 3 rows)
;				While Row_Counter > 0
;					Set Byte_Counter to 5 (40 Bytes)
;					While Byte_Counter > 0
;						Set Repeat_Count to 8
;						Setup to plane 0
;						While Repeat_Count > 0
;							Get next graphics byte
;							Lookup reverse bit value
;							Lookup the shift value
;							Get data mask value
;							Combine previous bits
;							Shift mask into position
;							Update screen data bytes
;						Endwhile for Repeat_Count
;						Set Repeat_Count to 8
;						Setup to plane 2
;						While Repeat_Count > 0
;							Get next graphics byte
;							Lookup reverse bit value
;							Lookup the shift value
;							Get data mask value
;							Combine previous bits
;							Shift mask into position
;							Update screen data bytes
;						Endwhile for Repeat_Count
;					Endwhile for Byte_Count
;				Increment destination index by NEXT_ROW (2525)
;				Endwhile for Row_Counter
;				Increment source index by NEXT_MACRO (320)
;			Endwhile for Macro_Counter
;			Increment destination index by NEXT_SLICE (40)
;		Endwhile for Slice_Counter
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - 65C02 RAM space source index
;		ES:DI - Video memory segment destination index
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Restore_High	Proc	Near		; Restore high res. memory procedure
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_0 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 0
	Save	si,di			; Save source and destination
	mov	ch,SLICE_COUNT		; Setup the slice count (8 = 192 Lines)
Slice_0_Next:
	mov	dh,MACRO_COUNT		; Setup the macro count (8 = 24 Rows)
	Save	di			; Save the destination index value
Macro_0_Next:
	mov	dl,ROW_COUNT		; Setup the row count (3 Rows)
	Save	di			; Save the destination index value
Row_0_Next:
	mov	cl,BYTE_COUNT		; Setup graphics count (10 = 40 Bytes)
Byte_0_Next:
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	ah,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shr	ah,1			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,1			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,2			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,2			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,3			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,3			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,4			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,4			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,5			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,5			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,6			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,6			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,7			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	al,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	shl	ax,7			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	dec	cl			; Decrement the graphics byte counter
	jz	Byte_0_Done		; Jump if all bytes have been moved
	jmp	Byte_0_Next		; Go process more graphics bytes
Byte_0_Done:
	add	di,NEXT_ROW		; Increment to the next graphics row
	dec	dl			; Decrement the row counter
	jz	Row_0_Done		; Jump if all rows have been moved
	jmp	Row_0_Next		; Go process more graphics rows
Row_0_Done:
	add	si,MACRO_OFFSET 	; Increment source address value
	Restore di			; Restore the destination index value
	add	di,NEXT_MACRO		; Increment to the next macro line
	dec	dh			; Decrement the macro counter value
	jz	Macro_0_Done		; Jump if all macro lines are moved
	jmp	Macro_0_Next		; Go process more macro lines
Macro_0_Done:
	Restore di			; Restore the destination index value
	add	di,NEXT_SLICE		; Increment to the next slice line
	dec	ch			; Decrement the slice counter value
	jz	Restore_2		; Jump if restore of plane 0 is complete
	jmp	Slice_0_Next		; Go process more slice sets
Restore_2:
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_2 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 2
	Restore si,di			; Restore source and destination
	mov	ch,SLICE_COUNT		; Setup the slice count (8 = 192 Lines)
Slice_2_Next:
	mov	dh,MACRO_COUNT		; Setup the macro count (8 = 24 Rows)
	Save	di			; Save the destination index value
Macro_2_Next:
	mov	dl,ROW_COUNT		; Setup the row count (3 Rows)
	Save	di			; Save the destination index value
Row_2_Next:
	mov	cl,BYTE_COUNT		; Setup graphics count (10 = 40 Bytes)
Byte_2_Next:
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	mov	ah,al			; Move data byte into AH register
	shr	ah,1			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,1			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,2			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,2			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,3			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,3			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,4			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,4			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,5			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,5			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,6			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,6			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	shr	ah,7			; Shift data bits into position
	lodsb				; Get the next graphics data byte
	sar	al,7			; Convert data byte into plane 2 value
	shl	ax,7			; Shift data bits into position
	xchg	al,ah			; Put bytes into correct order
	stosb				; Store data bytes to screen memory
	dec	cl			; Decrement the graphics byte counter
	jz	Byte_2_Done		; Jump if all bytes have been moved
	jmp	Byte_2_Next		; Go process more graphics bytes
Byte_2_Done:
	add	di,NEXT_ROW		; Increment to the next graphics row
	dec	dl			; Decrement the row counter
	jz	Row_2_Done		; Jump if all rows have been moved
	jmp	Row_2_Next		; Go process more graphics rows
Row_2_Done:
	add	si,MACRO_OFFSET 	; Increment source address value
	Restore di			; Restore the destination index value
	add	di,NEXT_MACRO		; Increment to the next macro line
	dec	dh			; Decrement the macro counter value
	jz	Macro_2_Done		; Jump if all macro lines are moved
	jmp	Macro_2_Next		; Go process more macro lines
Macro_2_Done:
	Restore di			; Restore the destination index value
	add	di,NEXT_SLICE		; Increment to the next slice line
	dec	ch			; Decrement the slice counter value
	jz	Restore_Done		; Jump if restore is complete
	jmp	Slice_2_Next		; Go process more slice sets
Restore_Done:
	ret				; Return to the caller
Restore_High	Endp			; End of the Restore_High procedure
	Subttl	Mixed_Update	Mixed Mode Update Routine
	Page	+
;******************************************************************************
;
;	Mixed_Update()
;
;
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Mixed_Update	Proc	Near		; Mixed screen update procedure

	ret				; Return to the caller
Mixed_Update	Endp			; End of the Mixed_Update procedure
	Subttl	Color_Program	Program the Colors Routine
	Page	+
;******************************************************************************
;
;	Color_Program()
;
;		Save the required registers
;		If this is a text mode
;			Setup to program colors for text (High res. display)
;			If a low resolution display attached
;				Setup colors for text (Low res. display)
;			Endif
;		Else this is a graphics mode
;			If this is low resolution graphics
;				Setup colors for low res. (High res. display)
;				If a low resolution display attached
;					Setup for low res. (Low res. display)
;				Endif
;			Else this is high resolution graphics
;				Setup colors for high res. (High res. display)
;				If a low resolution display attached
;					Setup for high res. (Low res. display)
;				Endif
;			Endif for graphics mode
;		Endif for video mode
;		Program the color palette with new colors
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Color_Program	Proc	Near		; Program the colors procedure
	Save	ax,dx,es		; Save the required registers
	mov	al,cs:[Video_Flag]	; Get the video system flag byte
	mov	ah,cs:[System_Flag]	; Get the Apple system flag byte
	test	al,VIDEO_MODE		; Check for a text or graphics mode
	jnz	Color_Graphics		; Jump if this is a graphics mode
Color_Text:
	lea	dx,cs:[Text_EGA]	; Setup for EGA display text colors
	test	ah,EGA_DISPLAY		; Check for an EGA type display
	jnz	Color_Set		; Jump if this is an EGA type display
	lea	dx,cs:[Text_CGA]	; Setup for CGA display text colors
	jmp	Short Color_Set 	; Go set all of the color values
Color_Graphics:
	test	al,RESOLUTION		; Check for low or high resolution
	jnz	Color_High		; Jump if this is high resolution
Color_Low:
	lea	dx,cs:[Low_EGA] 	; Setup for EGA display low res. colors
	test	ah,EGA_DISPLAY		; Check for an EGA type display
	jnz	Color_Set		; Jump if this is an EGA type display
	lea	dx,cs:[Low_CGA] 	; Setup for CGA display low res. colors
	jmp	Short Color_Set 	; Go set all of the color values
Color_High:
	lea	dx,cs:[High_EGA]	; Setup for EGA display high res. colors
	test	ah,EGA_DISPLAY		; Check for an EGA type display
	jnz	Color_Set		; Jump if this is an EGA type display
	lea	dx,cs:[High_CGA]	; Setup for CGA display high res. colors
Color_Set:
	mov	ax,cs			; Get the current CS register value
	mov	es,ax			; Setup ES to the current CS value
	mov	ah,SET_PALETTE		; Get the set palette function code
	mov	al,SET_ALL		; Get set all sub-function code
	int	VIDEO			; Program all of the color values
Color_Done:
	Restore ax,dx,es		; Restore the required registers
	ret				; Return to the caller
Color_Program	Endp			; End of the Color_Program procedure
	Subttl	EGA_Restore	Restore Screen Routine
	Page	+
;******************************************************************************
;
;	EGA_Restore(Video_Segment)
;
;		If this is text mode
;			Set text mode 0 (40x25)
;			Set video memory address to 0A000h
;			Call routine to turn off cursor
;			Call routine to enable blink (No intensity)
;			Call the text restore routine
;		Else this is a graphics mode
;			If this is high resolution graphics
;				Set graphics mode D (320 x 200)
;					If special update type in effect
;						If page 1 is selected
;							Get page 1 address
;						Else page 2 is selected
;							Get page 2 address
;						Endif for page number
;						Call routine to set address
;					Else standard update type
;						Call routine to restore graphics
;					Endif for update type
;			Else this is low resolution graphics
;				Set text mode 0 (40x25)
;				Set video memory address to 0A000h
;				Call routine to turn off cursor
;				Call routine to enable intensity (No blink)
;				Call the graphics restore routine
;			Endif for graphics resolution
;		Endif for video mode
;		Call routine to program the colors
;		Return to the caller
;
;	Registers on Entry:
;
;		ES    - Video segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Restore	Proc	Near		; Restore screen procedure
	test	cs:[Video_Flag],VIDEO_MODE
	jnz	Mode_Graphics		; Jump if this is a graphics mode
Mode_Text:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE + NO_CLEAR ; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	Save	dx			; Save the required registers
	mov	dx,GRA_INDEX		; Get graphics controller index port
	mov	ax,TEXT_MAP		; Get the text memory mapping value
	out	dx,ax			; Set text memory to 0A000h
	Restore dx			; Restore the required registers
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_On		; Call routine to turn blink on
	call	Text_Restore		; Call routine to restore text screen
	jmp	Short EGA_Done		; Go return to the caller
Mode_Graphics:
	test	cs:[Video_Flag],RESOLUTION
	jnz	EGA_High
EGA_Low:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE + NO_CLEAR ; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	Save	dx			; Save the required registers
	mov	dx,GRA_INDEX		; Get graphics controller index port
	mov	ax,TEXT_MAP		; Get the text memory mapping value
	out	dx,ax			; Set text memory to 0A000h
	Restore dx			; Restore the required registers
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_Off		; Call routine to turn blink off
	jmp	Short Do_EGA_Std	; Go finish the EGA restore
EGA_High:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE + NO_CLEAR; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
	test	cs:[Key_Status],TYPE_SPECIAL
	jz	Do_EGA_Std		; Jump if standard update type
Do_EGA_Spc:
	mov	bp,BASE_GRAPHIC_1	; Default to high resolution page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Do_EGA_Set		; Jump if this is page 1
	mov	bp,BASE_GRAPHIC_2	; Setup for high resolution page 2
Do_EGA_Set:
	call	Set_Address		; Call routine to set video address
	jmp	Short EGA_Done		; Go return to the caller
Do_EGA_Std:
	call	Graphic_Restore 	; Call graphics screen restore routine
EGA_Done:
	call	Color_Program		; Call routine to program the colors
	ret				; Return to the caller
EGA_Restore	Endp			; End of the EGA_Restore procedure
	Subttl	EGA_Setup	EGA Graphics Setup Routine
	Page	+
;******************************************************************************
;
;	EGA_Setup(Video_Segment)
;
;		Save the required registers
;		Set graphics mode D (320 x 200)
;		Get graphics video memory base address
;		Setup to write to plane 1
;		Get the fill pattern byte value (55h)
;		Get the fill size (16384 Bytes)
;		Fill video memory with the fill pattern
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		ES    - Video segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
EGA_Setup	Proc	Near		; EGA graphics setup procedure
	Save	ax,cx,dx,di		; Save the required registers
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE		; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
	mov	di,BASE_GRAPHIC 	; Get graphics base memory address
	mov	dx,SEQ_INDEX		; Get sequencer index port address
	mov	ax,PLANE_1 Shl 8 + MAP_MASK
	out	dx,ax			; Setup to write to plane 1
	mov	al,FILL_PATTERN 	; Get the fill pattern byte value (55h)
	mov	cx,FILL_SIZE		; Get the fill size (16384 Bytes)
	rep	stosb			; Move fill pattern to video memory
Setup_Done:
	Restore ax,cx,dx,di		; Restore the required registers
	ret				; Return to the caller
EGA_Setup	Endp			; End of the EGA_Setup procedure
	Subttl	Update_Toggle	Graphics Update Mode Toggle Routine
	Page	+
;******************************************************************************
;
;	Update_Toggle()
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				If this is an EGA style adapter
;					Toggle the update mode bit
;					If this is a high-res. graphics mode
;						Call routine to update graphics
;					Endif for graphics mode
;				Endif this is a CGA style adapter
;			Endif this is a break code
;		Endif this key is repeating
;		Call routine to update the LED status
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Update_Toggle	Proc	Near		; Graphics update mode toggle procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Update_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Update_Done		; Jump if this is a break code
	test	cs:[System_Flag],EGA_TYPE
	jz	Update_Done		; Jump if NOT an EGA style adapter
	xor	cs:[Key_Status],TYPE_SPECIAL
	test	cs:[Video_Flag],VIDEO_INV+RES_INV
	jnz	Update_Done		; Jump if NOT high-res. graphics mode
	call	Graphic_Restore 	; Call routine to restore graphics
Update_Done:
	call	Set_LED 		; Call routine to update LED status
	ret				; Return to the caller
Update_Toggle	Endp			; End of the Update_Toggle procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the EGA module

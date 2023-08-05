	Page	58,132
	Title	CGA.ASM 	Apple CGA Video Routines
;******************************************************************************
;
;   Name:	CGA.ASM 	Apple CGA Video Routines
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
;	CGA video routines.
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
	Public	CGA_Text_1		; Low resolution/text page 1 write
	Public	CGA_Text_2		; Low resolution/text page 2 write
	Public	CGA_Graph_1		; High resolution page 1 write
	Public	CGA_Graph_2		; High resolution page 2 write
	Public	CGA_Text_Off		; Text mode off (Graphics)
	Public	CGA_Text_On		; Text mode on (Text)
	Public	CGA_Mixed_Off		; Mixed off (Text / Graphics)
	Public	CGA_Mixed_On		; Mixed on (Text & Graphics)
	Public	CGA_Page_1		; Select video page 1 (Text & Graphics)
	Public	CGA_Page_2		; Select video page 2 (Text & Graphics)
	Public	CGA_Low_Res		; Select low resolution (Graphics)
	Public	CGA_High_Res		; Select high resolution (Graphics)
	Public	CGA_Restore		; CGA restore screen routine
;
;  External Declarations
;
	Extrn	Cursor_Off:Near 	; Turn cursor off routine	(VIDEO)
	Extrn	Cursor_On:Near		; Turn cursor on routine	(VIDEO)
	Extrn	Blink_Off:Near		; Turn blink off routine	(VIDEO)
	Extrn	Blink_On:Near		; Turn blink on routine 	(VIDEO)
	Extrn	Set_Address:Near	; Set video address routine	(VIDEO)
	Extrn	Text_Address:Word	; Text address mapping table	(VIDEO)
	Extrn	Macro_Table:Word	; Text macro table		(VIDEO)
	Extrn	Char_Table:Word 	; Text character mapping table	(VIDEO)
	Extrn	CGA_Address:Word	; CGA graphics address table	(VIDEO)
	Extrn	CGA_Slice:Word		; CGA graphics macro/slice table(VIDEO)
	Extrn	Reverse_Table:Byte	; Bit reversal table		(VIDEO)
	Extrn	Even_Table:Word 	; Even column bit exp. table	(VIDEO)
	Extrn	Odd_Table:Word		; Odd column bit exp. table	(VIDEO)
	Extrn	Column_Table:Word	; Column exp. selection table	(VIDEO)
	Extrn	CGA_Shift:Byte		; CGA bit shift table		(VIDEO)
	Extrn	Map_Table:Byte		; Low res. color mapping table	(VIDEO)
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
BASE_ADDRESS	Equ	0000h		; Base video memory address
BLOCK_CHAR	Equ	0DFh		; Low resolution block character value
SLICE_COUNT	Equ	08h		; Slice count value (8 = 192 Lines)
MACRO_COUNT	Equ	08h		; Macro count value (8 = 24 Rows)
ROW_COUNT	Equ	03h		; Row count value (3 = 3 Rows)
CHAR_COUNT	Equ	28h		; Character column count (40 Bytes)
BYTE_COUNT	Equ	0Ah		; Graphics byte count (10 = 40 Bytes)
MACRO_OFFSET	Equ	08h		; Macro offset value (Screen holes [8])
NEXT_OFFSET	Equ	50h		; Next row offset value (80)
ROW_OFFSET	Equ	0230h		; Row offset value (7 * 40 * 2)
NEXT_MACRO	Equ	0140h		; Next macro set offset value (Graphics)
NEXT_ROW	Equ	09BAh		; Next row offset value (Graphics)
LINE_MASK	Equ	2000h		; Next line XOR mask value
TEXT_MASK	Equ	07FFh		; Text destination mask value
TEXT_MODE	Equ	00h		; Text mode value (40 x 25)
GRAPH_MODE	Equ	04h		; Graphics mode value (320 x 200)
COLOR_MASK	Equ	007Fh		; Color bit mask value
WORD_MASK	Equ	0FFFCh		; Word mask initial value
BYTE_MASK	Equ	0FCh		; Byte mask initial value
ADDRESS_MASK	Equ	03h		; Address bits mask value (Mod 4)
ODD_COLUMN	Equ	0001h		; Odd column test mask value
BYTE_OFFSET	Equ	02h		; Byte offset value
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
	Subttl	CGA_Text_1	Low Resolution/Text Page 1 Write
	Page	+
;******************************************************************************
;
;	CGA_Text_1(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a text mode and page 1
;			Save the required registers
;			Save the character table index value
;			Set base text video address
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
;				Set base text video address
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
CGA_Text_1	Proc	Near		; Low res/text page 1 write procedure
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
CGA_Text_1	Endp			; End of the CGA_Text_1 procedure
	Subttl	CGA_Text_2	Low Resolution/Text Page 2 Write
	Page	+
;******************************************************************************
;
;	CGA_Text_2(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a text mode and page 2
;			Save the required registers
;			Save the character table index value
;			Set base text video address
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
;				Set base text video address
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
CGA_Text_2	Proc	Near		; Low res/text page 2 write procedure
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
CGA_Text_2	Endp			; End of the CGA_Text_2 procedure
	Subttl	CGA_Graph_1	High Resolution Graphics Page 1 Write
	Page	+
;******************************************************************************
;
;	CGA_Graph_1(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a graphics mode and page 1
;			Save the required registers
;			Save the bit value table index value
;			Calculate macro/slice and offset values
;			Load offset value from offset table
;			If this is NOT a screen hole
;				Load macro/slice value from macro/slice table
;				Compute the actual screen address
;				Lookup the reverse bit value
;				Lookup the expanded bit value
;				Get the word/byte shift count values
;				Get the word mask value
;				Shift the word mask into position
;				Shift the expanded bits into position
;				Update the screen word value
;				If the byte shift count is NOT zero
;					Get the byte mask value
;					Shift byte mask into position
;					Shift expanded bits into position
;					Update the screen byte value
;				Endif
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
CGA_Graph_1	Proc	Near		; High res page 1 write procedure
	mov	ds:[di],al		; Write the memory location
	test	cs:[Video_Flag],VIDEO_INV+PAGE_NUMBER+RES_INV
	jnz	Graph_Done_1		; Jump if NOT high res. mode page 1
	Save	bx,cx,dx,si		; Save the required registers
	and	ax,COLOR_MASK		; Mask off all but the color bits
	mov	bp,ax			; Save bit value table index in BP
	mov	ax,di			; Get the effective memory address
	and	di,ADDRESS_MASK 	; Mask all but required address bits
	sub	ah,GRAPH_PAGE_1 	; Subtract off the starting value
	shl	ax,1			; Move macro/slice number to AH register
	xor	bh,bh			; Setup to index through video tables
	mov	bl,al			; Convert offset into table index
	mov	si,cs:[bx+CGA_Address]	; Get the graphics offset table value
	inc	si			; Increment for screen hole check
	js	Graph_Exit_1		; Jump if this is a screen hole
	mov	bl,ah			; Get macro/slice number to BL register
	shl	bx,1			; Convert macro/slice into table index
	add	si,cs:[bx+CGA_Slice]	; Compute the actual screen address
	mov	ch,cs:[di+CGA_Shift]	; Get the word/byte shift values
	mov	bl,cs:[bp+Reverse_Table]; Lookup the reverse bit value
	shl	di,1			; Convert address into table index
	add	bx,cs:[di+Column_Table] ; Compute the actual table entry address
	mov	dx,Word Ptr cs:[bx]	; Get the expanded bit value (14 Bits)
	mov	bx,dx			; Get a copy of expanded bit value
	mov	ax,WORD_MASK		; Get the word mask value
	xor	cl,cl			; Setup for word shift count
	rol	cx,4			; Shift word shift count into CL
	shr	ax,cl			; Shift mask value into position
	shr	bx,cl			; Shift data value into position
	not	ax			; Invert the mask polarity
	xchg	al,ah			; Put mask bytes into the correct order
	xchg	bl,bh			; Put data bytes into the correct order
	and	ax,Word Ptr es:[si]	; Mask off all but desired bits
	or	ax,bx			; Logically OR in the new data bits
	mov	Word Ptr es:[si],ax	; Update the screen data word value
	xor	cl,cl			; Setup for byte shift count
	rol	cx,4			; Shift byte shift count into CL
	or	cl,cl			; Check for byte value required
	jz	Graph_Exit_1		; Jump if byte value NOT required
	mov	al,BYTE_MASK		; Get the byte mask value
	shl	al,cl			; Shift mask value into position
	shl	dl,cl			; Shift data value into position
	not	al			; Invert the mask polarity
	and	al,Byte Ptr es:[si+BYTE_OFFSET]
	or	al,dl			; Logically OR in the new data bits
	mov	Byte Ptr es:[si+BYTE_OFFSET],al
Graph_Exit_1:
	Restore bx,cx,dx,si		; Restore the required registers
Graph_Done_1:
	ret				; Return to the caller
CGA_Graph_1	Endp			; End of the CGA_Graph_1 procedure
	Subttl	CGA_Graph_2	High Resolution Graphics Page 2 Write
	Page	+
;******************************************************************************
;
;	CGA_Graph_2(Effective_Address, Value)
;
;		Write the memory location value (Byte)
;		If this is a graphics mode and page 2
;			Save the required registers
;			Save the bit value table index value
;			Calculate macro/slice and offset values
;			Load offset value from offset table
;			If this is NOT a screen hole
;				Load macro/slice value from macro/slice table
;				Compute the actual screen address
;				Lookup the reverse bit value
;				Lookup the expanded bit value
;				Get the word/byte shift count values
;				Get the word mask value
;				Shift the word mask into position
;				Shift the expanded bits into position
;				Update the screen word value
;				If the byte shift count is NOT zero
;					Get the byte mask value
;					Shift byte mask into position
;					Shift expanded bits into position
;					Update the screen byte value
;				Endif
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
CGA_Graph_2	Proc	Near		; High res page 2 write procedure
	mov	ds:[di],al		; Write the memory location
	test	cs:[Video_Flag],VIDEO_INV+PAGE_INV+RES_INV
	jnz	Graph_Done_2		; Jump if NOT high res. mode page 2
	Save	bx,cx,dx,si		; Save the required registers
	and	ax,COLOR_MASK		; Mask off all but the color bits
	mov	bp,ax			; Save bit value table index in BP
	mov	ax,di			; Get the effective memory address
	and	di,ADDRESS_MASK 	; Mask all but required address bits
	sub	ah,GRAPH_PAGE_2 	; Subtract off the starting value
	shl	ax,1			; Move macro/slice number to AH register
	xor	bh,bh			; Setup to index through video tables
	mov	bl,al			; Convert offset into table index
	mov	si,cs:[bx+CGA_Address]	; Get the graphics offset table value
	inc	si			; Increment for screen hole check
	js	Graph_Exit_2		; Jump if this is a screen hole
	mov	bl,ah			; Get macro/slice number to BL register
	shl	bx,1			; Convert macro/slice into table index
	add	si,cs:[bx+CGA_Slice]	; Compute the actual screen address
	mov	ch,cs:[di+CGA_Shift]	; Get the word/byte shift values
	mov	bl,cs:[bp+Reverse_Table]; Lookup the reverse bit value
	shl	di,1			; Convert address into table index
	add	bx,cs:[di+Column_Table] ; Compute the actual table entry address
	mov	dx,Word Ptr cs:[bx]	; Get the expanded bit value (14 Bits)
	mov	bx,dx			; Get a copy of expanded bit value
	mov	ax,WORD_MASK		; Get the word mask value
	xor	cl,cl			; Setup for word shift count
	rol	cx,4			; Shift word shift count into CL
	shr	ax,cl			; Shift mask value into position
	shr	bx,cl			; Shift data value into position
	not	ax			; Invert the mask polarity
	xchg	al,ah			; Put mask bytes into the correct order
	xchg	bl,bh			; Put data bytes into the correct order
	and	ax,Word Ptr es:[si]	; Mask off all but desired bits
	or	ax,bx			; Logically OR in the new data bits
	mov	Word Ptr es:[si],ax	; Update the screen data word value
	xor	cl,cl			; Setup for byte shift count
	rol	cx,4			; Shift byte shift count into CL
	or	cl,cl			; Check for byte value required
	jz	Graph_Exit_2		; Jump if byte value NOT required
	mov	al,BYTE_MASK		; Get the byte mask value
	shl	al,cl			; Shift mask value into position
	shl	dl,cl			; Shift data value into position
	not	al			; Invert the mask polarity
	and	al,Byte Ptr es:[si+BYTE_OFFSET]
	or	al,dl			; Logically OR in the new data bits
	mov	Byte Ptr es:[si+BYTE_OFFSET],al
Graph_Exit_2:
	Restore bx,cx,dx,si		; Restore the required registers
Graph_Done_2:
	ret				; Return to the caller
CGA_Graph_2	Endp			; End of the CGA_Graph_2 procedure
	Subttl	CGA_Text_Off	Text Off Routine (Graphics)
	Page	+
;******************************************************************************
;
;	CGA_Text_Off(RAM_Space, Video_Segment)
;
;		If currently in a text mode
;			Reset the text mode flag bit (Graphics)
;			If in high resolution graphics mode
;				Set graphics mode 4 (320 x 200)
;			Endif
;			Call routine to enable intensity (No blink)
;			Call routine to restore graphics screen
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
CGA_Text_Off	Proc	Near		; Text off (Graphics) procedure
	test	cs:[Video_Flag],VIDEO_MODE
	jnz	Text_Off_Done		; Jump if this is NOT a text mode
	or	cs:[Video_Flag],VIDEO_MODE
	and	cs:[Video_Flag],Not VIDEO_INV
	test	cs:[Video_Flag],RESOLUTION
	jz	Do_Graphic		; Jump if low resolution graphics
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE		; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
Do_Graphic:
	call	Blink_Off		; Call routine to turn blink off
	call	Graphic_Restore 	; Call routine to restore graphics
Text_Off_Done:
	ret				; Return to the caller
CGA_Text_Off	Endp			; End of the CGA_Text_Off procedure
	Subttl	CGA_Text_On	Text On Routine (Text)
	Page	+
;******************************************************************************
;
;	CGA_Text_On(RAM_Space, Video_Segment)
;
;		If currently in a graphics mode
;			Reset the graphics mode flag bit (Text)
;			If in high resolution graphics mode
;				Set text mode 0 (40x25)
;				Call routine to turn off cursor
;			Endif
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
CGA_Text_On	Proc	Near		; Text on (Text) procedure
	test	cs:[Video_Flag],VIDEO_MODE
	jz	Text_On_Done		; Jump if this is a text mode
	and	cs:[Video_Flag],Not VIDEO_MODE
	or	cs:[Video_Flag],VIDEO_INV
	test	cs:[Video_Flag],RESOLUTION
	jz	Do_Text 		; Jump if low resolution graphics
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE		; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	call	Cursor_Off		; Call routine to turn cursor off
Do_Text:
	call	Blink_On		; Call routine to turn blink on
	call	Text_Restore		; Call routine to restore text
Text_On_Done:
	ret				; Return to the caller
CGA_Text_On	Endp			; End of the CGA_Text_On procedure
	Subttl	CGA_Mixed_Off	Mixed Off Routine (Text/Graphics)
	Page	+
;******************************************************************************
;
;	CGA_Mixed_Off()
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
CGA_Mixed_Off	Proc	Near		; Mixed off (Text/Graphics) procedure
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
CGA_Mixed_Off	Endp			; End of the CGA_Mixed_Off procedure
	Subttl	CGA_Mixed_On	Mixed On Routine (Text & Graphics)
	Page	+
;******************************************************************************
;
;	CGA_Mixed_On()
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
CGA_Mixed_On	Proc	Near		; Mixed on (Text & Graphics) procedure
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
CGA_Mixed_On	Endp			; End of the CGA_Mixed_On procedure
	Subttl	CGA_Page_1	Select Page 1 Routine
	Page	+
;******************************************************************************
;
;	CGA_Page_1(RAM_Space, Video_Segment)
;
;		If this is NOT page 1
;			Reset page number flag bit (Page 1)
;			If this is a text mode
;				Call routine to restore text screen
;			Else this is a graphics mode
;				Call routine to restore graphics screen
;			Endif
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
CGA_Page_1	Proc	Near		; Select video page 1 procedure
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
	call	Graphic_Restore 	; Call routine to restore graphics
Page_1_Done:
	ret				; Return to the caller
CGA_Page_1	Endp			; End of the CGA_Page_1 procedure
	Subttl	CGA_Page_2	Select Page 2 Routine
	Page	+
;******************************************************************************
;
;	CGA_Page_2(RAM_Space, Video_Segment)
;
;		If this is NOT page 2
;			Set page number flag bit (Page 2)
;			If this is a text mode
;				Call routine to restore text screen
;			Else this is a graphics mode
;				Call routine to restore graphics screen
;			Endif
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
CGA_Page_2	Proc	Near		; Select video page 2 procedure
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
	call	Graphic_Restore 	; Call routine to restore graphics
Page_2_Done:
	ret				; Return to the caller
CGA_Page_2	Endp			; End of the CGA_Page_2 procedure
	Subttl	CGA_Low_Res	Select Low Resolution Routine
	Page	+
;******************************************************************************
;
;	CGA_Low_Res()
;
;		If this is NOT low resolution mode
;			Set low resolution mode flag bit
;			If this is a graphics mode
;				Set text mode 0 (40x25)
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
CGA_Low_Res	Proc	Near		; Select low resolution procedure
	mov	al,cs:[Video_Flag]	; Get the video flag byte
	test	al,RESOLUTION		; Check for low resolution mode
	jz	Low_Res_Done		; Jump if this IS low resolution
	and	cs:[Video_Flag],Not RESOLUTION
	or	cs:[Video_Flag],RES_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jz	Low_Res_Done		; Jump if this is NOT a graphics mode
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE		; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_Off		; Call routine to turn blink off
	call	Graphic_Restore 	; Call routine to restore graphics
Low_Res_Done:
	ret				; Return to the caller
CGA_Low_Res	Endp			; End of the CGA_Low_Res procedure
	Subttl	CGA_High_Res	Select High Resolution Routine
	Page	+
;******************************************************************************
;
;	CGA_High_Res()
;
;		If this is NOT high resolution mode
;			Set high resolution mode flag bit
;			If this is a graphics mode
;				Set graphics mode 4 (320 x 200)
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
CGA_High_Res	Proc	Near		; Select high resolution procedure
	mov	al,cs:[Video_Flag]	; Get the video flag byte
	test	al,RESOLUTION		; Check for high resolution mode
	jnz	High_Res_Done		; Jump if this IS high resolution
	or	cs:[Video_Flag],RESOLUTION
	and	cs:[Video_Flag],Not RES_INV
	test	al,VIDEO_MODE		; Check the video mode flag bit
	jz	High_Res_Done		; Jump if this is NOT a graphics mode
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE		; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
	call	Graphic_Restore 	; Call routine to restore graphics
High_Res_Done:
	ret				; Return to the caller
CGA_High_Res	Endp			; End of the CGA_High_Res procedure
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
;		Set destination index to video memory (BASE_ADDRESS)
;		Call routine to restore the text memory
;		Setup base address to video memory (BASE_ADDRESS)
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
	mov	di,BASE_ADDRESS 	; Setup destination index
	mov	bp,TEXT_MASK		; Setup destination mask value
	call	Restore_Text		; Call routine to restore text page 1
Text_Set:
	mov	bp,BASE_ADDRESS Shr 1	; Setup base video address
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
;		Else in high resolution graphics mode
;			Set source index to page 1 memory (2000h)
;			If page 2 is selected
;				Set source index to page 2 memory (4000h)
;			Endif
;			Set destination index to video memory (BASE_ADDRESS)
;			Call routine to restore high resolution memory
;		Endif for type of graphics mode
;		Setup base address to video memory (BASE_ADDRESS)
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
	mov	si,GRAPH_ADDRESS_1	; Setup source index for page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Do_High 		; Jump if this really is page 1
	mov	si,GRAPH_ADDRESS_2	; Setup base address for page 2
Do_High:
	mov	di,BASE_ADDRESS 	; Setup destination index
	call	Restore_High		; Call routine to restore high res.
	jmp	Short Graphic_Set	; Go setup the base address value
Low_Restore:
	mov	si,TEXT_ADDRESS_1	; Setup source index for page 1
	test	cs:[Video_Flag],PAGE_NUMBER
	jz	Do_Low			; Jump if this really is page 1
	mov	si,TEXT_ADDRESS_2	; Setup base address for page 2
Do_Low:
	mov	di,BASE_ADDRESS 	; Setup destination index
	mov	bp,TEXT_MASK		; Setup destination mask value
	call	Restore_Low		; Call routine to restore low page 1
Graphic_Set:
	mov	bp,BASE_ADDRESS 	; Get base video address
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
	xor	ah,ah			; Convert graphics byte to table index
	mov	bx,ax			; Setup to translate the color
	mov	ah,cs:[bx + Map_Table]	; Lookup the correct color value
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
;		Set Slice_Counter to 8 (Restore 8 slices [192 lines])
;		While Slice_Counter > 0
;			Set Macro_Counter to 8 (Restore 8 macro lines [24 rows])
;			While Macro_Counter > 0
;				Set Row_Counter to 3 (Restore 3 rows)
;				While Row_Counter > 0
;					Set Byte_Counter to 10 (40 Bytes)
;					While Byte_Counter > 0
;						Get next graphics byte
;						Reverse the data bits
;						Expand data bits for even column
;						Save the first 8 expanded bits
;						Get next graphics byte
;						Reverse the data bits
;						Expand data bits for odd column
;						Combine last 6 bits with next 2
;						Save the next 16 expanded bits
;						Get next graphics byte
;						Reverse the data bits
;						Expand data bits for even column
;						Combine last 4 bits with next 4
;						Save the next 16 expanded bits
;						Get next graphics byte
;						Reverse the data bits
;						Expand data bits for odd column
;						Combine last 2 bits with next 14
;						Save the last 16 expanded bits
;					Endwhile for Byte_Count
;				Increment destination index by NEXT_ROW (2490)
;				Endwhile for Row_Counter
;				Increment source index by NEXT_MACRO (320)
;			Endwhile for Macro_Counter
;			Toggle destination for odd/even scan line
;			If moving to an even scan line
;				Increment destination index by NEXT_OFFSET (80)
;			Endif
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
	mov	ch,SLICE_COUNT		; Setup the slice count (8 = 192 Lines)
Slice_Next:
	mov	dh,MACRO_COUNT		; Setup the macro count (8 = 24 Rows)
	Save	di			; Save the destination index value
Macro_Next:
	mov	dl,ROW_COUNT		; Setup the row count (3 Rows)
	Save	di			; Save the destination index value
Row_Next:
	mov	cl,BYTE_COUNT		; Setup graphics count (10 = 40 Bytes)
Byte_Next:
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	bl,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	mov	bx,cs:[bx+Even_Table]	; Expand data bits for an even column
	mov	al,bh			; Get the first 8 expanded bits
	stosb				; Store data bits to screen memory
	mov	ah,bl			; Save the last 6 expanded bits
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	bl,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	mov	bx,cs:[bx+Odd_Table]	; Expand data bits for an odd column
	mov	al,bh			; Get the first 8 expanded bits
	shr	al,6			; Save only the first 2 expanded bits
	or	al,ah			; Logically OR with other 6 bits
	shl	bx,2			; Shift out first 2 expanded bits
	mov	ah,bh			; Move next 8 expanded bits into AH
	stosw				; Store data bits to screen memory
	mov	ah,bl			; Save the last 4 expanded bits
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	bl,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	mov	bx,cs:[bx+Even_Table]	; Expand data bits for an even column
	mov	al,bh			; Get the first 8 expanded bits
	shr	al,4			; Save only the first 4 expanded bits
	or	al,ah			; Logically OR with other 4 bits
	shl	bx,4			; Shift out first 4 expanded bits
	mov	ah,bh			; Move next 8 expanded bits into AH
	stosw				; Store data bits to screen memory
	mov	ah,bl			; Save the last 2 expanded bits
	lodsb				; Get the next graphics data byte
	mov	bl,al			; Move data byte into BL register
	and	bx,COLOR_MASK		; Mask off all but the color bits
	mov	bl,cs:[bx+Reverse_Table]; Reverse the graphics data bits
	mov	bx,cs:[bx+Odd_Table]	; Expand data bits for an odd column
	shr	bx,2			; Shift data bits into position
	mov	al,bh			; Move first 6 expanded bits into AL
	or	al,ah			; Logically OR with other 2 bits
	mov	ah,bl			; Move next 8 expanded bits into AH
	stosw				; Store data bits to screen memory
	dec	cl			; Decrement the graphics byte count
	jnz	Byte_Next		; Jump if more bytes to move
	add	di,NEXT_ROW		; Increment to the next graphics row
	dec	dl			; Decrement the row counter
	jnz	Row_Next		; Jump if more rows to move
	add	si,MACRO_OFFSET 	; Increment source address value
	Restore di			; Restore the destination index value
	add	di,NEXT_MACRO		; Increment to the next macro line
	dec	dh			; Decrement the macro counter value
	jz	Macro_Done		; Jump if all macro lines are moved
	jmp	Macro_Next		; Go process more macro lines
Macro_Done:
	Restore di			; Restore the destination index value
	xor	di,LINE_MASK		; Adjust for the odd scan line offset
	test	di,LINE_MASK		; Check for moving to an even scan line
	jnz	Skip_Inc		; Jump if NOT moving to an even line
	add	di,NEXT_OFFSET		; Adjust for moving to an even scan line
Skip_Inc:
	dec	ch			; Decrement the slice counter value
	jz	Restore_Done		; Jump if restore is complete
	jmp	Slice_Next		; Go process more slice sets
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
	Subttl	CGA_Restore	Restore Screen Routine
	Page	+
;******************************************************************************
;
;	CGA_Restore(Video_Segment)
;
;		If this is text mode
;			Set text mode 0 (40x25)
;			Call routine to turn off cursor
;			Call routine to enable blink (No intensity)
;			Call the text restore routine
;		Else this is a graphics mode
;			If this is high resolution graphics
;				Set graphics mode 4 (320 x 200)
;			Else this is low resolution graphics
;				Set text mode 0 (40x25)
;				Call routine to turn off cursor
;				Call routine to enable intensity (No blink)
;			Endif for graphics resolution
;			Call the graphics restore routine
;		Endif for video mode
;		Return to the caller
;
;	Registers on Entry:
;
;		ES    - Video segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
CGA_Restore	Proc	Near		; Restore screen procedure
	test	cs:[Video_Flag],VIDEO_MODE
	jnz	Mode_Graphics		; Jump if this is a graphics mode
Mode_Text:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE		; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_On		; Call routine to turn blink on
	call	Text_Restore		; Call routine to restore text screen
	jmp	Short CGA_Done		; Go return to the caller
Mode_Graphics:
	test	cs:[Video_Flag],RESOLUTION
	jnz	CGA_High
CGA_Low:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE		; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_Off		; Call routine to turn blink off
	jmp	Short Do_CGA		; Go continue the CGA restore
CGA_High:
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,GRAPH_MODE		; Get the 320x200 graphics mode value
	int	VIDEO			; Set video mode to 320x200 graphics
Do_CGA:
	call	Graphic_Restore 	; Call graphics screen restore routine
CGA_Done:
	ret				; Return to the caller
CGA_Restore	Endp			; End of the CGA_Restore procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the CGA module

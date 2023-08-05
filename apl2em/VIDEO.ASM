	Page	58,132
	Title	VIDEO.ASM	Apple Video Routines
;******************************************************************************
;
;   Name:	VIDEO.ASM	Apple Video Routines
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
;	video routines.
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
	Public	Video_Init		; Video initialization routine
	Public	Video_Reset		; Video reset routine
	Public	Text_Read_1		; Low resolution/text page 1 read
	Public	Text_Read_2		; Low resolution/text page 2 read
	Public	Graph_Read_1		; High resolution page 1 read
	Public	Graph_Read_2		; High resolution page 2 read
	Public	Cursor_Off		; Turn cursor off routine
	Public	Cursor_On		; Turn cursor on routine
	Public	Blink_Off		; Turn blink off routine
	Public	Blink_On		; Turn blink on routine
	Public	Set_Address		; Set video address routine
	Public	Text_Address		; Text address mapping table
	Public	Macro_Table		; Text macro address mapping table
	Public	Char_Table		; Text character mapping table
	Public	CGA_Address		; CGA graphics address mapping table
	Public	EGA_Address		; EGA graphics address mapping table
	Public	CGA_Slice		; CGA graphics macro/slice address table
	Public	EGA_Slice		; EGA graphics macro/slice address table
	Public	Reverse_Table		; Bit reversal table
	Public	Even_Table		; Even column bit expansion table
	Public	Odd_Table		; Odd column bit expansion table
	Public	Column_Table		; CGA column expansion selection table
	Public	CGA_Shift		; CGA bit shift table
	Public	EGA_Shift		; EGA bit shift table
	Public	Map_Table		; Low resolution color mapping table
	Public	Text_CGA		; CGA display text color table
	Public	Text_EGA		; EGA display text color table
	Public	Low_CGA 		; CGA display low res. color table
	Public	Low_EGA 		; EGA display low res. color table
	Public	High_CGA		; CGA display high res. color table
	Public	High_EGA		; EGA display high res. color table
;
;  External Declarations
;
	Extrn	CGA_Restore:Near	; CGA restore screen routine	  (CGA)
	Extrn	EGA_Restore:Near	; EGA restore screen routine	  (EGA)
	Extrn	EGA_Setup:Near		; EGA graphics setup routine	  (EGA)
	Extrn	CGA_Table:Word		; CGA I/O address table 	 (DATA)
	Extrn	EGA_Table:Word		; EGA I/O address table 	 (DATA)
	Extrn	Write_Table:Word	; Write memory page table	 (DATA)
	Extrn	IO_Read_Table:Word	; I/O read table		 (DATA)
	Extrn	IO_Write_Table:Word	; I/O write table		 (DATA)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
	Extrn	Video_Flag:Byte 	; Video system flag byte	 (DATA)
;
;  LOCAL Equates
;
OFF_CURSOR	Equ	2000h		; Cursor off start/end line values
ON_CURSOR	Equ	0607h		; Cursor on start/end line values
CRTC_BASE	Equ	03D4h		; CRT controller base port address
START_HIGH	Equ	0Ch		; Start address MSB index value
START_LOW	Equ	0Dh		; Start address LSB index value
RESET_MODE	Equ	03h		; Reset mode value (80 x 25)
BIOS_SEG	Equ	40h		; BIOS data segment address (400h)
MODE_PORT	Equ	03D8h		; Mode port address
Mode_Reg	Equ	65h		; Current mode register offset
BLINK_BIT	Equ	20h		; Blink bit (Bit 5)
TEXT_OFFSET	Equ	008h		; Text page offset (Page 04h)
TEXT_COUNT	Equ	004h		; Text page count (4h)
GRAPH_OFFSET	Equ	040h		; Graphics page offset (Page 20h)
GRAPH_COUNT	Equ	020h		; Graphics page count (20h)
IO_OFFSET	Equ	00A0h		; I/O byte offset (50h)
IO_COUNT	Equ	008h		; I/O count (8h)
TEST_VALUE	Equ	0FFh		; EGA information call test value
PRIMARY_HIGH	Equ	09h		; Primary high res. display attached
SECONDARY_HIGH	Equ	03h		; Secondary high res. display attached
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
	Subttl	Video_Init	Video Initialization Routine
	Page	+
;******************************************************************************
;
;	Video_Init(RAM_Space)
;
;		Save the required registers
;		Determine the video type
;		If this is a CGA type video
;			Setup the CGA video RAM segment value
;			Setup the CGA I/O routine addresses
;			Call routine to restore CGA screen
;		Else this is an EGA type video
;			Setup the EGA video RAM segment value
;			Setup the EGA I/O routine addresses
;			Call routine to setup EGA graphics
;			Call routine to restore EGA screen
;		Endif for video type
;		Set video initialized flag
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		ES    - Video segment
;
;******************************************************************************
		Even			; Force procedure to even address
Video_Init	Proc	Near		; Video initialization procedure
	Save	si			; Save the required registers
	call	Video_Type		; Call routine to get video type
	test	cs:[System_Flag],EGA_TYPE
	jnz	Setup_Ega		; Jump if this is an EGA type video
Setup_CGA:
	mov	ax,CGA_SEGMENT		; Get the CGA video RAM segment value
	mov	es,ax			; Setup video RAM segment address
	lea	si,cs:[CGA_Table]	; Get the CGA I/O routine table
	call	Video_Setup		; Call routine to setup I/O addresses
	call	CGA_Restore		; Call routine to restore CGA (Text)
	jmp	Short Init_Done 	; Go return to the caller
Setup_EGA:
	mov	ax,EGA_SEGMENT		; Get the EGA video RAM segment value
	mov	es,ax			; Setup video RAM segment address
	lea	si,cs:[EGA_Table]	; Get the EGA I/O routine table
	call	Video_Setup		; Call routine to setup I/O addresses
	call	EGA_Setup		; Call routine to setup EGA (Graphics)
	call	EGA_Restore		; Call routine to restore EGA (Text)
Init_Done:
	or	cs:[System_Flag],INITIALIZED
	Restore si			; Restore the required registers
	ret				; Return to the caller
Video_Init	Endp			; End of the Video_Init procedure
	Subttl	Video_Reset	Video Reset Routine
	Page	+
;******************************************************************************
;
;	Video_Reset()
;
;		If video has been initialized
;			Reset the video mode
;			Call routine to turn cursor on
;		Endif video has not been initialized
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
Video_Reset	Proc	Near		; Video reset procedure
	test	cs:[System_Flag],INITIALIZED
	jz	Reset_Done		; Jump if video not initialized
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,RESET_MODE		; Get the 80x25 text mode value
	int	VIDEO			; Set video mode to 80x25 text mode
	call	Cursor_On		; Call routine to turn cursor on
Reset_Done:
	ret				; Return to the caller
Video_Reset	Endp			; End of the Video_Reset procedure
	Subttl	Text_Read_1	Low Resolution/Text Page 1 Read
	Page	+
;******************************************************************************
;
;	Text_Read_1(Effective_Address)
;
;		Read the memory location value (Byte)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;
;******************************************************************************
		Even			; Force procedure to even address
Text_Read_1	Proc	Near		; Low res/text page 1 read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Text_Read_1	Endp			; End of the Text_Read_1 procedure
	Subttl	Text_Read_2	Low Resolution/Text Page 2 Read
	Page	+
;******************************************************************************
;
;	Text_Read_2(Effective_Address)
;
;		Read the memory location value (Byte)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;
;******************************************************************************
		Even			; Force procedure to even address
Text_Read_2	Proc	Near		; Low res/text page 2 read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Text_Read_2	Endp			; End of the Text_Read_2 procedure
	Subttl	Graph_Read_1	High Resolution Graphics Page 1 Read
	Page	+
;******************************************************************************
;
;	Graph_Read_1(Effective_Address)
;
;		Read the memory location value (Byte)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;
;******************************************************************************
		Even			; Force procedure to even address
Graph_Read_1	Proc	Near		; High res page 1 read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Graph_Read_1	Endp			; End of the Graph_Read_1 procedure
	Subttl	Graph_Read_2	High Resolution Graphics Page 2 Read
	Page	+
;******************************************************************************
;
;	Graph_Read_2(Effective_Address)
;
;		Read the memory location value (Byte)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;
;******************************************************************************
		Even			; Force procedure to even address
Graph_Read_2	Proc	Near		; High res page 2 read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Graph_Read_2	Endp			; End of the Graph_Read_2 procedure
	Subttl	Cursor_Off	Turn Cursor Off Routine
	Page	+
;******************************************************************************
;
;	Cursor_Off()
;
;		Save the required registers
;		Get set cursor type function code
;		Get cursor off start and end values
;		Do BIOS video function to set cursor type (Cursor Off)
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
Cursor_Off	Proc	Near		; Turn cursor off procedure
	Save	ax,cx			; Save the required registers
	mov	ah,CURSOR_TYPE		; Get set cursor type function code
	mov	cx,OFF_CURSOR		; Get the cursor off type value
	int	VIDEO			; Turn the cursor off
	Restore ax,cx			; Restore the required registers
	ret				; Return to the caller
Cursor_Off	Endp			; End of the Cursor_Off procedure
	Subttl	Cursor_On	Turn Cursor On Routine
	Page	+
;******************************************************************************
;
;	Cursor_On()
;
;		Save the required registers
;		Get set cursor type function code
;		Get cursor on start and end values
;		Do BIOS video function to set cursor type (Cursor On)
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
Cursor_On	Proc	Near		; Turn cursor on procedure
	Save	ax,cx			; Save the required registers
	mov	ah,CURSOR_TYPE		; Get set cursor type sub-function code
	mov	cx,ON_CURSOR		; Get the cursor on type value
	int	VIDEO			; Turn the cursor on
	Restore ax,cx			; Restore the required registers
	ret				; Return to the caller
Cursor_On	Endp			; End of the Cursor_On procedure
	Subttl	Blink_Off	Turn Background Blink Off Routine
	Page	+
;******************************************************************************
;
;	Blink_Off()
;
;		Save the required registers
;		If the video type is EGA
;			Get program blink/intensity function code
;			Get blink off value
;			Do BIOS video function to set blink type (Blink Off)
;		Else the video type is CGA
;			Get current mode register value
;			Clear bit 5 (Intensity)
;			Output new mode register value
;		Endif for the video mode
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
Blink_Off	Proc	Near		; Turn blink off procedure
	Save	ax,bx,dx,ds		; Save the required registers
	test	cs:[System_Flag],EGA_TYPE
	jz	Off_CGA 		; Jump if not an EGA type video
Off_EGA:
	mov	ah,SET_PALETTE		; Get set palette function code
	mov	al,PROGRAM_BLINK	; Get program blink sub-function code
	mov	bl,INTENSITY		; Get the blink off value (Intensity)
	int	VIDEO			; Turn the blink off (Intensity)
	jmp	Short Off_Done		; Go return to the caller
Off_CGA:
	mov	ax,BIOS_SEG		; Get the BIOS data segment address
	mov	ds,ax			; Setup to access BIOS data segment
	mov	dx,MODE_PORT		; Get the mode register port address
	mov	al,ds:[Mode_Reg]	; Get the current mode register value
	and	al,Not BLINK_BIT	; Clear the blink bit (Bit 5)
	out	dx,al			; Output the new mode register value
Off_Done:
	Restore ax,bx,dx,ds		; Restore the required registers
	ret				; Return to the caller
Blink_Off	Endp			; End of the Blink_Off procedure
	Subttl	Blink_On	Turn Background Blink On Routine
	Page	+
;******************************************************************************
;
;	Blink_On()
;
;		Save the required registers
;		If the video type is EGA
;			Get program blink/intensity function code
;			Get blink on value
;			Do BIOS video function to set blink type (Blink On)
;		Else the video type is CGA
;			Get current mode register value
;			Set bit 5 (Blink)
;			Output new mode register value
;		Endif for the video mode
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
Blink_On	Proc	Near		; Turn blink on procedure
	Save	ax,bx,dx,ds		; Save the required registers
	test	cs:[System_Flag],EGA_TYPE
	jz	On_CGA			; Jump if not an EGA type video
On_EGA:
	mov	ah,SET_PALETTE		; Get set palette function code
	mov	al,PROGRAM_BLINK	; Get program blink sub-function code
	mov	bl,BLINK		; Get the blink on value
	int	VIDEO			; Turn the blink on (Blink)
	jmp	Short On_Done		; Go return to the caller
On_CGA:
	mov	ax,BIOS_SEG		; Get the BIOS data segment address
	mov	ds,ax			; Setup to access BIOS data segment
	mov	dx,MODE_PORT		; Get the mode register port address
	mov	al,ds:[Mode_Reg]	; Get the current mode register value
	or	al,BLINK_BIT		; Set the blink bit (Bit 5)
	out	dx,al			; Output the new mode register value
On_Done:
	Restore ax,bx,dx,ds		; Restore the required registers
	ret				; Return to the caller
Blink_On	Endp			; End of the Blink_On procedure
	Subttl	Set_Address	Set Video Memory Base Address
	Page	+
;******************************************************************************
;
;	Set_Address(Base_Address)
;
;		Save the required registers
;		Get the CRT controller base port address
;		Output the new video memory start address
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		BP    - Base address
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Address	Proc	Near		; Set video memory address procedure
	Save	ax,dx			; Save the required registers
	mov	dx,CRTC_BASE		; Get CRT controller base port address
	mov	ax,bp			; Get new start address value
	mov	ah,al			; Move low byte into AH register
	mov	al,START_LOW		; Get start address LSB index value
	out	dx,ax			; Output LSB of new start address
	mov	ax,bp			; Get new start address value
	mov	al,START_HIGH		; Get start address MSB index value
	out	dx,ax			; Output MSB of new start address
	Restore ax,dx			; Restore the required registers
	ret				; Return to the caller
Set_Address	Endp			; End of the Set_Address procedure
	Subttl	Video_Type	Determine Video Type Routine
	Page	+
;******************************************************************************
;
;	Video_Type()
;
;		Save the required registers
;		Setup registers for EGA information call
;		Do the EGA information call
;		If the EGA information call returned data
;			Set video type as EGA
;			If enhanced monitor is present
;				Set display type as EGA
;			Endif
;		Endif
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
Video_Type	Proc	Near		; Set video type procedure
	Save	ax,bx,cx		; Save the required registers
	mov	ah,ALT_SELECT		; Get alternate select function code
	xor	al,al			; Setup for EGA information call
	mov	bl,EGA_INFO		; Get EGA information sub-function code
	mov	bh,TEST_VALUE		; Setup BH with special test value (FFh)
	int	VIDEO			; Do the video BIOS call
	inc	bh			; Test for an EGA style video controller
	jz	Type_Done		; Jump if this is a CGA type controller
	or	cs:[System_Flag],EGA_TYPE
	cmp	cl,PRIMARY_HIGH 	; Check for primary high res. display
	je	Set_EGA 		; Jump if high resolution display
	cmp	cl,SECONDARY_HIGH	; Check secondary high res. display
	jne	Type_Done		; Jump if NOT high resolution display
Set_EGA:
	or	cs:[System_Flag],EGA_DISPLAY
Type_Done:
	Restore ax,bx,cx		; Restore the required registers
	ret				; Return to the caller
Video_Type	Endp			; End of the Video_Type procedure
	Subttl	Video_Setup	Setup Video I/O Routine Addresses
	Page	+
;******************************************************************************
;
;	Video_Setup(IO_Table)
;
;		Save the required registers
;		Get the write memory page table offset to update (Text)
;		Get the actual text page 1 routine address
;		Get text page count value (4)
;		Update the text page 1 routine address in table
;		Get the actual text page 2 routine address
;		Get text page count value (4)
;		Update the text page 2 routine address in table
;		Get the write memory page table offset to update (Graphics)
;		Get the actual graphics page 1 routine address
;		Get graphics page count value (32)
;		Update the graphics page 1 routine address in table
;		Get the actual graphics page 2 routine address
;		Get graphics page count value (32)
;		Update the graphics page 2 routine address in table
;		Get the I/O read table offset to update
;		Get the number of I/O bytes (8)
;		Move new I/O read addresses into table
;		Get the I/O write table offset to update
;		Get the number of I/O bytes (8)
;		Move new I/O write addresses into table
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		SI    - Pointer to I/O address table
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Video_Setup	Proc	Near		; Set video I/O addresses procedure
	Save	ax,cx,si,di,ds,es	; Save the required registers
	mov	ax,cs			; Get the current CS register value
	mov	ds,ax			; Setup DS to the current CS value
	mov	es,ax			; Setup ES to the current CS value
	lea	di,cs:[Write_Table]	; Get write memory page table offset
	add	di,TEXT_OFFSET		; Calculate starting text page offset
	mov	cx,TEXT_COUNT		; Get the number of text pages (4)
	lodsw				; Get the actual text page 1 address
	rep	stosw			; Store routine address in write table
	mov	cx,TEXT_COUNT		; Get the number of text pages (4)
	lodsw				; Get the actual text page 2 address
	rep	stosw			; Store routine address in write table
	lea	di,cs:[Write_Table]	; Get write memory page table offset
	add	di,GRAPH_OFFSET 	; Calculate starting graphics offset
	mov	cx,GRAPH_COUNT		; Get the number of graphics pages (32)
	lodsw				; Get actual graphics page 1 address
	rep	stosw			; Store routine address in write table
	mov	cx,GRAPH_COUNT		; Get the number of graphics pages (32)
	lodsw				; Get actual graphics page 2 address
	rep	stosw			; Store routine address in write table
	lea	di,cs:[IO_Read_Table]	; Get the I/O read table offset
	add	di,IO_OFFSET		; Calculate starting read I/O offset
	mov	cx,IO_COUNT		; Get the number of I/O bytes (8)
	Save	si			; Save the address table pointer
	rep	movsw			; Move new addresses into the table
	Restore si			; Restore the address table pointer
	lea	di,cs:[IO_Write_Table]	; Get the I/O write table offset
	add	di,IO_OFFSET		; Calculate starting write I/O offset
	mov	cx,IO_COUNT		; Get the number of I/O bytes (8)
	rep	movsw			; Move new addresses into the table
	Restore ax,cx,si,di,ds,es	; Restore the required registers
	ret				; Return to the caller
Video_Setup	Endp			; End of the Video_Setup procedure
	Subttl	Video_Tables	Define the Video Lookup Tables
	Page	+
;******************************************************************************
;
;	Define the video lookup tables
;
;******************************************************************************
		Even			; Force table to even address
Text_Address	Equ	This Word	; Text video offset lookup table
		Dw	0FFFFh		; Offset 00h - Row 00h Column 00h
		Dw	00001h		; Offset 01h - Row 00h Column 01h
		Dw	00003h		; Offset 02h - Row 00h Column 02h
		Dw	00005h		; Offset 03h - Row 00h Column 03h
		Dw	00007h		; Offset 04h - Row 00h Column 04h
		Dw	00009h		; Offset 05h - Row 00h Column 05h
		Dw	0000Bh		; Offset 06h - Row 00h Column 06h
		Dw	0000Dh		; Offset 07h - Row 00h Column 07h
		Dw	0000Fh		; Offset 08h - Row 00h Column 08h
		Dw	00011h		; Offset 09h - Row 00h Column 09h
		Dw	00013h		; Offset 0Ah - Row 00h Column 0Ah
		Dw	00015h		; Offset 0Bh - Row 00h Column 0Bh
		Dw	00017h		; Offset 0Ch - Row 00h Column 0Ch
		Dw	00019h		; Offset 0Dh - Row 00h Column 0Dh
		Dw	0001Bh		; Offset 0Eh - Row 00h Column 0Eh
		Dw	0001Dh		; Offset 0Fh - Row 00h Column 0Fh
		Dw	0001Fh		; Offset 10h - Row 00h Column 10h
		Dw	00021h		; Offset 11h - Row 00h Column 11h
		Dw	00023h		; Offset 12h - Row 00h Column 12h
		Dw	00025h		; Offset 13h - Row 00h Column 13h
		Dw	00027h		; Offset 14h - Row 00h Column 14h
		Dw	00029h		; Offset 15h - Row 00h Column 15h
		Dw	0002Bh		; Offset 16h - Row 00h Column 16h
		Dw	0002Dh		; Offset 17h - Row 00h Column 17h
		Dw	0002Fh		; Offset 18h - Row 00h Column 18h
		Dw	00031h		; Offset 19h - Row 00h Column 19h
		Dw	00033h		; Offset 1Ah - Row 00h Column 1Ah
		Dw	00035h		; Offset 1Bh - Row 00h Column 1Bh
		Dw	00037h		; Offset 1Ch - Row 00h Column 1Ch
		Dw	00039h		; Offset 1Dh - Row 00h Column 1Dh
		Dw	0003Bh		; Offset 1Eh - Row 00h Column 1Eh
		Dw	0003Dh		; Offset 1Fh - Row 00h Column 1Fh
		Dw	0003Fh		; Offset 20h - Row 00h Column 20h
		Dw	00041h		; Offset 21h - Row 00h Column 21h
		Dw	00043h		; Offset 22h - Row 00h Column 22h
		Dw	00045h		; Offset 23h - Row 00h Column 23h
		Dw	00047h		; Offset 24h - Row 00h Column 24h
		Dw	00049h		; Offset 25h - Row 00h Column 25h
		Dw	0004Bh		; Offset 26h - Row 00h Column 26h
		Dw	0004Dh		; Offset 27h - Row 00h Column 27h
		Dw	0027Fh		; Offset 28h - Row 08h Column 00h
		Dw	00281h		; Offset 29h - Row 08h Column 01h
		Dw	00283h		; Offset 2Ah - Row 08h Column 02h
		Dw	00285h		; Offset 2Bh - Row 08h Column 03h
		Dw	00287h		; Offset 2Ch - Row 08h Column 04h
		Dw	00289h		; Offset 2Dh - Row 08h Column 05h
		Dw	0028Bh		; Offset 2Eh - Row 08h Column 06h
		Dw	0028Dh		; Offset 2Fh - Row 08h Column 07h
		Dw	0028Fh		; Offset 30h - Row 08h Column 08h
		Dw	00291h		; Offset 31h - Row 08h Column 09h
		Dw	00293h		; Offset 32h - Row 08h Column 0Ah
		Dw	00295h		; Offset 33h - Row 08h Column 0Bh
		Dw	00297h		; Offset 34h - Row 08h Column 0Ch
		Dw	00299h		; Offset 35h - Row 08h Column 0Dh
		Dw	0029Bh		; Offset 36h - Row 08h Column 0Eh
		Dw	0029Dh		; Offset 37h - Row 08h Column 0Fh
		Dw	0029Fh		; Offset 38h - Row 08h Column 10h
		Dw	002A1h		; Offset 39h - Row 08h Column 11h
		Dw	002A3h		; Offset 3Ah - Row 08h Column 12h
		Dw	002A5h		; Offset 3Bh - Row 08h Column 13h
		Dw	002A7h		; Offset 3Ch - Row 08h Column 14h
		Dw	002A9h		; Offset 3Dh - Row 08h Column 15h
		Dw	002ABh		; Offset 3Eh - Row 08h Column 16h
		Dw	002ADh		; Offset 3Fh - Row 08h Column 17h
		Dw	002AFh		; Offset 40h - Row 08h Column 18h
		Dw	002B1h		; Offset 41h - Row 08h Column 19h
		Dw	002B3h		; Offset 42h - Row 08h Column 1Ah
		Dw	002B5h		; Offset 43h - Row 08h Column 1Bh
		Dw	002B7h		; Offset 44h - Row 08h Column 1Ch
		Dw	002B9h		; Offset 45h - Row 08h Column 1Dh
		Dw	002BBh		; Offset 46h - Row 08h Column 1Eh
		Dw	002BDh		; Offset 47h - Row 08h Column 1Fh
		Dw	002BFh		; Offset 48h - Row 08h Column 20h
		Dw	002C1h		; Offset 49h - Row 08h Column 21h
		Dw	002C3h		; Offset 4Ah - Row 08h Column 22h
		Dw	002C5h		; Offset 4Bh - Row 08h Column 23h
		Dw	002C7h		; Offset 4Ch - Row 08h Column 24h
		Dw	002C9h		; Offset 4Dh - Row 08h Column 25h
		Dw	002CBh		; Offset 4Eh - Row 08h Column 26h
		Dw	002CDh		; Offset 4Fh - Row 08h Column 27h
		Dw	004FFh		; Offset 50h - Row 10h Column 00h
		Dw	00501h		; Offset 51h - Row 10h Column 01h
		Dw	00503h		; Offset 52h - Row 10h Column 02h
		Dw	00505h		; Offset 53h - Row 10h Column 03h
		Dw	00507h		; Offset 54h - Row 10h Column 04h
		Dw	00509h		; Offset 55h - Row 10h Column 05h
		Dw	0050Bh		; Offset 56h - Row 10h Column 06h
		Dw	0050Dh		; Offset 57h - Row 10h Column 07h
		Dw	0050Fh		; Offset 58h - Row 10h Column 08h
		Dw	00511h		; Offset 59h - Row 10h Column 09h
		Dw	00513h		; Offset 5Ah - Row 10h Column 0Ah
		Dw	00515h		; Offset 5Bh - Row 10h Column 0Bh
		Dw	00517h		; Offset 5Ch - Row 10h Column 0Ch
		Dw	00519h		; Offset 5Dh - Row 10h Column 0Dh
		Dw	0051Bh		; Offset 5Eh - Row 10h Column 0Eh
		Dw	0051Dh		; Offset 5Fh - Row 10h Column 0Fh
		Dw	0051Fh		; Offset 60h - Row 10h Column 10h
		Dw	00521h		; Offset 61h - Row 10h Column 11h
		Dw	00523h		; Offset 62h - Row 10h Column 12h
		Dw	00525h		; Offset 63h - Row 10h Column 13h
		Dw	00527h		; Offset 64h - Row 10h Column 14h
		Dw	00529h		; Offset 65h - Row 10h Column 15h
		Dw	0052Bh		; Offset 66h - Row 10h Column 16h
		Dw	0052Dh		; Offset 67h - Row 10h Column 17h
		Dw	0052Fh		; Offset 68h - Row 10h Column 18h
		Dw	00531h		; Offset 69h - Row 10h Column 19h
		Dw	00533h		; Offset 6Ah - Row 10h Column 1Ah
		Dw	00535h		; Offset 6Bh - Row 10h Column 1Bh
		Dw	00537h		; Offset 6Ch - Row 10h Column 1Ch
		Dw	00539h		; Offset 6Dh - Row 10h Column 1Dh
		Dw	0053Bh		; Offset 6Eh - Row 10h Column 1Eh
		Dw	0053Dh		; Offset 6Fh - Row 10h Column 1Fh
		Dw	0053Fh		; Offset 70h - Row 10h Column 20h
		Dw	00541h		; Offset 71h - Row 10h Column 21h
		Dw	00543h		; Offset 72h - Row 10h Column 22h
		Dw	00545h		; Offset 73h - Row 10h Column 23h
		Dw	00547h		; Offset 74h - Row 10h Column 24h
		Dw	00549h		; Offset 75h - Row 10h Column 25h
		Dw	0054Bh		; Offset 76h - Row 10h Column 26h
		Dw	0054Dh		; Offset 77h - Row 10h Column 27h
		Dw	07FFFh		; Offset 78h - Screen hole 00h
		Dw	07FFFh		; Offset 79h - Screen hole 01h
		Dw	07FFFh		; Offset 7Ah - Screen hole 02h
		Dw	07FFFh		; Offset 7Bh - Screen hole 03h
		Dw	07FFFh		; Offset 7Ch - Screen hole 04h
		Dw	07FFFh		; Offset 7Dh - Screen hole 05h
		Dw	07FFFh		; Offset 7Eh - Screen hole 06h
		Dw	07FFFh		; Offset 7Fh - Screen hole 07h
		Even			; Force table to even address
Macro_Table	Equ	This Word	; Macro line offset lookup table
		Dw	0000h		; Macro line 0 - Row 0
		Dw	0050h		; Macro line 1 - Row 1
		Dw	00A0h		; Macro line 2 - Row 2
		Dw	00F0h		; Macro line 3 - Row 3
		Dw	0140h		; Macro line 4 - Row 4
		Dw	0190h		; Macro line 5 - Row 5
		Dw	01E0h		; Macro line 6 - Row 6
		Dw	0230h		; Macro line 7 - Row 7
		Even			; Force table to even address
Char_Table	Equ	This Word	; Character lookup table
		Db	040h,70h	; Character 00h - Inverse @ Sign
		Db	041h,70h	; Character 01h - Inverse Letter A
		Db	042h,70h	; Character 02h - Inverse Letter B
		Db	043h,70h	; Character 03h - Inverse Letter C
		Db	044h,70h	; Character 04h - Inverse Letter D
		Db	045h,70h	; Character 05h - Inverse Letter E
		Db	046h,70h	; Character 06h - Inverse Letter F
		Db	047h,70h	; Character 07h - Inverse Letter G
		Db	048h,70h	; Character 08h - Inverse Letter H
		Db	049h,70h	; Character 09h - Inverse Letter I
		Db	04Ah,70h	; Character 0Ah - Inverse Letter J
		Db	04Bh,70h	; Character 0Bh - Inverse Letter K
		Db	04Ch,70h	; Character 0Ch - Inverse Letter L
		Db	04Dh,70h	; Character 0Dh - Inverse Letter M
		Db	04Eh,70h	; Character 0Eh - Inverse Letter N
		Db	04Fh,70h	; Character 0Fh - Inverse Letter O
		Db	050h,70h	; Character 10h - Inverse Letter P
		Db	051h,70h	; Character 11h - Inverse Letter Q
		Db	052h,70h	; Character 12h - Inverse Letter R
		Db	053h,70h	; Character 13h - Inverse Letter S
		Db	054h,70h	; Character 14h - Inverse Letter T
		Db	055h,70h	; Character 15h - Inverse Letter U
		Db	056h,70h	; Character 16h - Inverse Letter V
		Db	057h,70h	; Character 17h - Inverse Letter W
		Db	058h,70h	; Character 18h - Inverse Letter X
		Db	059h,70h	; Character 19h - Inverse Letter Y
		Db	05Ah,70h	; Character 1Ah - Inverse Letter Z
		Db	05Bh,70h	; Character 1Bh - Inverse Left Bracket
		Db	05Ch,70h	; Character 1Ch - Inverse Back Slash
		Db	05Dh,70h	; Character 1Dh - Inverse Right Bracket
		Db	05Eh,70h	; Character 1Eh - Inverse Carrot
		Db	05Fh,70h	; Character 1Fh - Inverse Minus
		Db	020h,70h	; Character 20h - Inverse Space
		Db	021h,70h	; Character 21h - Inverse Exclamation
		Db	022h,70h	; Character 22h - Inverse Double Quote
		Db	023h,70h	; Character 23h - Inverse Pound Sign
		Db	024h,70h	; Character 24h - Inverse Dollar Sign
		Db	025h,70h	; Character 25h - Inverse Percent Sign
		Db	026h,70h	; Character 26h - Inverse Ampersand
		Db	027h,70h	; Character 27h - Inverse Single Quote
		Db	028h,70h	; Character 28h - Inverse Left Paren.
		Db	029h,70h	; Character 29h - Inverse Right Paren.
		Db	02Ah,70h	; Character 2Ah - Inverse Asterick
		Db	02Bh,70h	; Character 2Bh - Inverse Plus Sign
		Db	02Ch,70h	; Character 2Ch - Inverse Accent Mark
		Db	02Dh,70h	; Character 2Dh - Inverse Minus Sign
		Db	02Eh,70h	; Character 2Eh - Inverse Period
		Db	02Fh,70h	; Character 2Fh - Inverse Forward Slash
		Db	030h,70h	; Character 30h - Inverse Number 0
		Db	031h,70h	; Character 31h - Inverse Number 1
		Db	032h,70h	; Character 32h - Inverse Number 2
		Db	033h,70h	; Character 33h - Inverse Number 3
		Db	034h,70h	; Character 34h - Inverse Number 4
		Db	035h,70h	; Character 35h - Inverse Number 5
		Db	036h,70h	; Character 36h - Inverse Number 6
		Db	037h,70h	; Character 37h - Inverse Number 7
		Db	038h,70h	; Character 38h - Inverse Number 8
		Db	039h,70h	; Character 39h - Inverse Number 9
		Db	03Ah,70h	; Character 3Ah - Inverse Colon
		Db	03Bh,70h	; Character 3Bh - Inverse Semi-Colon
		Db	03Ch,70h	; Character 3Ch - Inverse Less Than
		Db	03Dh,70h	; Character 3Dh - Inverse Equal Sign
		Db	03Eh,70h	; Character 3Eh - Inverse Greater Than
		Db	03Fh,70h	; Character 3Fh - Inverse Question Mark
		Db	040h,87h	; Character 40h - Flashing @ Sign
		Db	041h,87h	; Character 41h - Flashing Letter A
		Db	042h,87h	; Character 42h - Flashing Letter B
		Db	043h,87h	; Character 43h - Flashing Letter C
		Db	044h,87h	; Character 44h - Flashing Letter D
		Db	045h,87h	; Character 45h - Flashing Letter E
		Db	046h,87h	; Character 46h - Flashing Letter F
		Db	047h,87h	; Character 47h - Flashing Letter G
		Db	048h,87h	; Character 48h - Flashing Letter H
		Db	049h,87h	; Character 49h - Flashing Letter I
		Db	04Ah,87h	; Character 4Ah - Flashing Letter J
		Db	04Bh,87h	; Character 4Bh - Flashing Letter K
		Db	04Ch,87h	; Character 4Ch - Flashing Letter L
		Db	04Dh,87h	; Character 4Dh - Flashing Letter M
		Db	04Eh,87h	; Character 4Eh - Flashing Letter N
		Db	04Fh,87h	; Character 4Fh - Flashing Letter O
		Db	050h,87h	; Character 50h - Flashing Letter P
		Db	051h,87h	; Character 51h - Flashing Letter Q
		Db	052h,87h	; Character 52h - Flashing Letter R
		Db	053h,87h	; Character 53h - Flashing Letter S
		Db	054h,87h	; Character 54h - Flashing Letter T
		Db	055h,87h	; Character 55h - Flashing Letter U
		Db	056h,87h	; Character 56h - Flashing Letter V
		Db	057h,87h	; Character 57h - Flashing Letter W
		Db	058h,87h	; Character 58h - Flashing Letter X
		Db	059h,87h	; Character 59h - Flashing Letter Y
		Db	05Ah,87h	; Character 5Ah - Flashing Letter Z
		Db	05Bh,87h	; Character 5Bh - Flashing Left Bracket
		Db	05Ch,87h	; Character 5Ch - Flashing Back Slash
		Db	05Dh,87h	; Character 5Dh - Flashing Right Bracket
		Db	05Eh,87h	; Character 5Eh - Flashing Carrot
		Db	05Fh,87h	; Character 5Fh - Flashing Minus
		Db	0DBh,87h	; Character 60h - Flashing Space(Cursor)
		Db	021h,87h	; Character 61h - Flashing Exclamation
		Db	022h,87h	; Character 62h - Flashing Double Quote
		Db	023h,87h	; Character 63h - Flashing Pound Sign
		Db	024h,87h	; Character 64h - Flashing Dollar Sign
		Db	025h,87h	; Character 65h - Flashing Percent Sign
		Db	026h,87h	; Character 66h - Flashing Ampersand
		Db	027h,87h	; Character 67h - Flashing Single Quote
		Db	028h,87h	; Character 68h - Flashing Left Paren.
		Db	029h,87h	; Character 69h - Flashing Right Paren.
		Db	02Ah,87h	; Character 6Ah - Flashing Asterick
		Db	02Bh,87h	; Character 6Bh - Flashing Plus Sign
		Db	02Ch,87h	; Character 6Ch - Flashing Accent mark
		Db	02Dh,87h	; Character 6Dh - Flashing Minus Sign
		Db	02Eh,87h	; Character 6Eh - Flashing Period
		Db	02Fh,87h	; Character 6Fh - Flashing Forward Slash
		Db	030h,87h	; Character 70h - Flashing Number 0
		Db	031h,87h	; Character 71h - Flashing Number 1
		Db	032h,87h	; Character 72h - Flashing Number 2
		Db	033h,87h	; Character 73h - Flashing Number 3
		Db	034h,87h	; Character 74h - Flashing Number 4
		Db	035h,87h	; Character 75h - Flashing Number 5
		Db	036h,87h	; Character 76h - Flashing Number 6
		Db	037h,87h	; Character 77h - Flashing Number 7
		Db	038h,87h	; Character 78h - Flashing Number 8
		Db	039h,87h	; Character 79h - Flashing Number 9
		Db	03Ah,87h	; Character 7Ah - Flashing Colon
		Db	03Bh,87h	; Character 7Bh - Flashing Semi-Colon
		Db	03Ch,87h	; Character 7Ch - Flashing Less Than
		Db	03Dh,87h	; Character 7Dh - Flashing Equal Sign
		Db	03Eh,87h	; Character 7Eh - Flashing Greater Than
		Db	03Fh,87h	; Character 7Fh - Flashing Question Mark
		Db	040h,07h	; Character 80h - Normal @ Sign
		Db	041h,07h	; Character 81h - Normal Letter A
		Db	042h,07h	; Character 82h - Normal Letter B
		Db	043h,07h	; Character 83h - Normal Letter C
		Db	044h,07h	; Character 84h - Normal Letter D
		Db	045h,07h	; Character 85h - Normal Letter E
		Db	046h,07h	; Character 86h - Normal Letter F
		Db	047h,07h	; Character 87h - Normal Letter G
		Db	048h,07h	; Character 88h - Normal Letter H
		Db	049h,07h	; Character 89h - Normal Letter I
		Db	04Ah,07h	; Character 8Ah - Normal Letter J
		Db	04Bh,07h	; Character 8Bh - Normal Letter K
		Db	04Ch,07h	; Character 8Ch - Normal Letter L
		Db	04Dh,07h	; Character 8Dh - Normal Letter M
		Db	04Eh,07h	; Character 8Eh - Normal Letter N
		Db	04Fh,07h	; Character 8Fh - Normal Letter O
		Db	050h,07h	; Character 90h - Normal Letter P
		Db	051h,07h	; Character 91h - Normal Letter Q
		Db	052h,07h	; Character 92h - Normal Letter R
		Db	053h,07h	; Character 93h - Normal Letter S
		Db	054h,07h	; Character 94h - Normal Letter T
		Db	055h,07h	; Character 95h - Normal Letter U
		Db	056h,07h	; Character 96h - Normal Letter V
		Db	057h,07h	; Character 97h - Normal Letter W
		Db	058h,07h	; Character 98h - Normal Letter X
		Db	059h,07h	; Character 99h - Normal Letter Y
		Db	05Ah,07h	; Character 9Ah - Normal Letter Z
		Db	05Bh,07h	; Character 9Bh - Normal Left Bracket
		Db	05Ch,07h	; Character 9Ch - Normal Back Slash
		Db	05Dh,07h	; Character 9Dh - Normal Right Bracket
		Db	05Eh,07h	; Character 9Eh - Normal Carrot
		Db	05Fh,07h	; Character 9Fh - Normal Minus
		Db	020h,07h	; Character A0h - Normal Space
		Db	021h,07h	; Character A1h - Normal Exclamation
		Db	022h,07h	; Character A2h - Normal Double Quote
		Db	023h,07h	; Character A3h - Normal Pound Sign
		Db	024h,07h	; Character A4h - Normal Dollar Sign
		Db	025h,07h	; Character A5h - Normal Percent Sign
		Db	026h,07h	; Character A6h - Normal Ampersand
		Db	027h,07h	; Character A7h - Normal Single Quote
		Db	028h,07h	; Character A8h - Normal Left Paren.
		Db	029h,07h	; Character A9h - Normal Right Paren.
		Db	02Ah,07h	; Character AAh - Normal Asterick
		Db	02Bh,07h	; Character ABh - Normal Plus Sign
		Db	02Ch,07h	; Character ACh - Normal Accent Mark
		Db	02Dh,07h	; Character ADh - Normal Minus Sign
		Db	02Eh,07h	; Character AEh - Normal Period
		Db	02Fh,07h	; Character AFh - Normal Forward Slash
		Db	030h,07h	; Character B0h - Normal Number 0
		Db	031h,07h	; Character B1h - Normal Number 1
		Db	032h,07h	; Character B2h - Normal Number 2
		Db	033h,07h	; Character B3h - Normal Number 3
		Db	034h,07h	; Character B4h - Normal Number 4
		Db	035h,07h	; Character B5h - Normal Number 5
		Db	036h,07h	; Character B6h - Normal Number 6
		Db	037h,07h	; Character B7h - Normal Number 7
		Db	038h,07h	; Character B8h - Normal Number 8
		Db	039h,07h	; Character B9h - Normal Number 9
		Db	03Ah,07h	; Character BAh - Normal Colon
		Db	03Bh,07h	; Character BBh - Normal Semi-Colon
		Db	03Ch,07h	; Character BCh - Normal Less Than
		Db	03Dh,07h	; Character BDh - Normal Equal Sign
		Db	03Eh,07h	; Character BEh - Normal Greater Than
		Db	03Fh,07h	; Character BFh - Normal Question Mark
		Db	040h,07h	; Character C0h - Normal @ Sign
		Db	041h,07h	; Character C1h - Normal Letter A
		Db	042h,07h	; Character C2h - Normal Letter B
		Db	043h,07h	; Character C3h - Normal Letter C
		Db	044h,07h	; Character C4h - Normal Letter D
		Db	045h,07h	; Character C5h - Normal Letter E
		Db	046h,07h	; Character C6h - Normal Letter F
		Db	047h,07h	; Character C7h - Normal Letter G
		Db	048h,07h	; Character C8h - Normal Letter H
		Db	049h,07h	; Character C9h - Normal Letter I
		Db	04Ah,07h	; Character CAh - Normal Letter J
		Db	04Bh,07h	; Character CBh - Normal Letter K
		Db	04Ch,07h	; Character CCh - Normal Letter L
		Db	04Dh,07h	; Character CDh - Normal Letter M
		Db	04Eh,07h	; Character CEh - Normal Letter N
		Db	04Fh,07h	; Character CFh - Normal Letter O
		Db	050h,07h	; Character D0h - Normal Letter P
		Db	051h,07h	; Character D1h - Normal Letter Q
		Db	052h,07h	; Character D2h - Normal Letter R
		Db	053h,07h	; Character D3h - Normal Letter S
		Db	054h,07h	; Character D4h - Normal Letter T
		Db	055h,07h	; Character D5h - Normal Letter U
		Db	056h,07h	; Character D6h - Normal Letter V
		Db	057h,07h	; Character D7h - Normal Letter W
		Db	058h,07h	; Character D8h - Normal Letter X
		Db	059h,07h	; Character D9h - Normal Letter Y
		Db	05Ah,07h	; Character DAh - Normal Letter Z
		Db	05Bh,07h	; Character DBh - Normal Left Bracket
		Db	05Ch,07h	; Character DCh - Normal Back Slash
		Db	05Dh,07h	; Character DDh - Normal Right Bracket
		Db	05Eh,07h	; Character DEh - Normal Carrot
		Db	05Fh,07h	; Character DFh - Normal Minus
		Db	020h,07h	; Character E0h - Normal @ Sign
		Db	061h,07h	; Character E1h - Normal Letter a
		Db	062h,07h	; Character E2h - Normal Letter b
		Db	063h,07h	; Character E3h - Normal Letter c
		Db	064h,07h	; Character E4h - Normal Letter d
		Db	065h,07h	; Character E5h - Normal Letter e
		Db	066h,07h	; Character E6h - Normal Letter f
		Db	067h,07h	; Character E7h - Normal Letter g
		Db	068h,07h	; Character E8h - Normal Letter h
		Db	069h,07h	; Character E9h - Normal Letter i
		Db	06Ah,07h	; Character EAh - Normal Letter j
		Db	06Bh,07h	; Character EBh - Normal Letter k
		Db	06Ch,07h	; Character ECh - Normal Letter l
		Db	06Dh,07h	; Character EDh - Normal Letter m
		Db	06Eh,07h	; Character EEh - Normal Letter n
		Db	06Fh,07h	; Character EFh - Normal Letter o
		Db	070h,07h	; Character F0h - Normal Letter p
		Db	071h,07h	; Character F1h - Normal Letter q
		Db	072h,07h	; Character F2h - Normal Letter r
		Db	073h,07h	; Character F3h - Normal Letter s
		Db	074h,07h	; Character F4h - Normal Letter t
		Db	075h,07h	; Character F5h - Normal Letter u
		Db	076h,07h	; Character F6h - Normal Letter v
		Db	077h,07h	; Character F7h - Normal Letter w
		Db	078h,07h	; Character F8h - Normal Letter x
		Db	079h,07h	; Character F9h - Normal Letter y
		Db	07Ah,07h	; Character FAh - Normal Letter z
		Db	03Bh,07h	; Character FBh - Normal Left Bracket
		Db	03Ch,07h	; Character FCh - Normal Back Slash
		Db	03Dh,07h	; Character FDh - Normal Right Bracket
		Db	03Eh,07h	; Character FEh - Normal Carrot
		Db	03Fh,07h	; Character FFh - Normal Minus
		Even			; Force table to even address
CGA_Address	Equ	This Word	; CGA graphics video offset lookup table
		Dw	0FFFFh		; Offset 00h - Row 00h Column 000h
		Dw	00000h		; Offset 01h - Row 00h Column 007h
		Dw	00002h		; Offset 02h - Row 00h Column 00Eh
		Dw	00004h		; Offset 03h - Row 00h Column 015h
		Dw	00006h		; Offset 04h - Row 00h Column 01Ch
		Dw	00007h		; Offset 05h - Row 00h Column 023h
		Dw	00009h		; Offset 06h - Row 00h Column 02Ah
		Dw	0000Bh		; Offset 07h - Row 00h Column 031h
		Dw	0000Dh		; Offset 08h - Row 00h Column 038h
		Dw	0000Eh		; Offset 09h - Row 00h Column 03Fh
		Dw	00010h		; Offset 0Ah - Row 00h Column 046h
		Dw	00012h		; Offset 0Bh - Row 00h Column 04Dh
		Dw	00014h		; Offset 0Ch - Row 00h Column 054h
		Dw	00015h		; Offset 0Dh - Row 00h Column 05Bh
		Dw	00017h		; Offset 0Eh - Row 00h Column 062h
		Dw	00019h		; Offset 0Fh - Row 00h Column 069h
		Dw	0001Bh		; Offset 10h - Row 00h Column 070h
		Dw	0001Ch		; Offset 11h - Row 00h Column 077h
		Dw	0001Eh		; Offset 12h - Row 00h Column 07Eh
		Dw	00020h		; Offset 13h - Row 00h Column 085h
		Dw	00022h		; Offset 14h - Row 00h Column 08Ch
		Dw	00023h		; Offset 15h - Row 00h Column 093h
		Dw	00025h		; Offset 16h - Row 00h Column 09Ah
		Dw	00027h		; Offset 17h - Row 00h Column 0A1h
		Dw	00029h		; Offset 18h - Row 00h Column 0A8h
		Dw	0002Ah		; Offset 19h - Row 00h Column 0AFh
		Dw	0002Ch		; Offset 1Ah - Row 00h Column 0B6h
		Dw	0002Eh		; Offset 1Bh - Row 00h Column 0BDh
		Dw	00030h		; Offset 1Ch - Row 00h Column 0C4h
		Dw	00031h		; Offset 1Dh - Row 00h Column 0CBh
		Dw	00033h		; Offset 1Eh - Row 00h Column 0D2h
		Dw	00035h		; Offset 1Fh - Row 00h Column 0D9h
		Dw	00037h		; Offset 20h - Row 00h Column 0E0h
		Dw	00038h		; Offset 21h - Row 00h Column 0E7h
		Dw	0003Ah		; Offset 22h - Row 00h Column 0EEh
		Dw	0003Ch		; Offset 23h - Row 00h Column 0F5h
		Dw	0003Eh		; Offset 24h - Row 00h Column 0FCh
		Dw	0003Fh		; Offset 25h - Row 00h Column 103h
		Dw	00041h		; Offset 26h - Row 00h Column 10Ah
		Dw	00043h		; Offset 27h - Row 00h Column 111h
		Dw	009FFh		; Offset 28h - Row 40h Column 000h
		Dw	00A00h		; Offset 29h - Row 40h Column 007h
		Dw	00A02h		; Offset 2Ah - Row 40h Column 00Eh
		Dw	00A04h		; Offset 2Bh - Row 40h Column 015h
		Dw	00A06h		; Offset 2Ch - Row 40h Column 01Ch
		Dw	00A07h		; Offset 2Dh - Row 40h Column 023h
		Dw	00A09h		; Offset 2Eh - Row 40h Column 02Ah
		Dw	00A0Bh		; Offset 2Fh - Row 40h Column 031h
		Dw	00A0Dh		; Offset 30h - Row 40h Column 038h
		Dw	00A0Eh		; Offset 31h - Row 40h Column 03Fh
		Dw	00A10h		; Offset 32h - Row 40h Column 046h
		Dw	00A12h		; Offset 33h - Row 40h Column 04Dh
		Dw	00A14h		; Offset 34h - Row 40h Column 054h
		Dw	00A15h		; Offset 35h - Row 40h Column 05Bh
		Dw	00A17h		; Offset 36h - Row 40h Column 062h
		Dw	00A19h		; Offset 37h - Row 40h Column 069h
		Dw	00A1Bh		; Offset 38h - Row 40h Column 070h
		Dw	00A1Ch		; Offset 39h - Row 40h Column 077h
		Dw	00A1Eh		; Offset 3Ah - Row 40h Column 07Eh
		Dw	00A20h		; Offset 3Bh - Row 40h Column 085h
		Dw	00A22h		; Offset 3Ch - Row 40h Column 08Ch
		Dw	00A23h		; Offset 3Dh - Row 40h Column 093h
		Dw	00A25h		; Offset 3Eh - Row 40h Column 09Ah
		Dw	00A27h		; Offset 3Fh - Row 40h Column 0A1h
		Dw	00A29h		; Offset 40h - Row 40h Column 0A8h
		Dw	00A2Ah		; Offset 41h - Row 40h Column 0AFh
		Dw	00A2Ch		; Offset 42h - Row 40h Column 0B6h
		Dw	00A2Eh		; Offset 43h - Row 40h Column 0BDh
		Dw	00A30h		; Offset 44h - Row 40h Column 0C4h
		Dw	00A31h		; Offset 45h - Row 40h Column 0CBh
		Dw	00A33h		; Offset 46h - Row 40h Column 0D2h
		Dw	00A35h		; Offset 47h - Row 40h Column 0D9h
		Dw	00A37h		; Offset 48h - Row 40h Column 0E0h
		Dw	00A38h		; Offset 49h - Row 40h Column 0E7h
		Dw	00A3Ah		; Offset 4Ah - Row 40h Column 0EEh
		Dw	00A3Ch		; Offset 4Bh - Row 40h Column 0F5h
		Dw	00A3Eh		; Offset 4Ch - Row 40h Column 0FCh
		Dw	00A3Fh		; Offset 4Dh - Row 40h Column 103h
		Dw	00A41h		; Offset 4Eh - Row 40h Column 10Ah
		Dw	00A43h		; Offset 4Fh - Row 40h Column 111h
		Dw	013FFh		; Offset 50h - Row 80h Column 000h
		Dw	01400h		; Offset 51h - Row 80h Column 007h
		Dw	01402h		; Offset 52h - Row 80h Column 00Eh
		Dw	01404h		; Offset 53h - Row 80h Column 015h
		Dw	01406h		; Offset 54h - Row 80h Column 01Ch
		Dw	01407h		; Offset 55h - Row 80h Column 023h
		Dw	01409h		; Offset 56h - Row 80h Column 02Ah
		Dw	0140Bh		; Offset 57h - Row 80h Column 031h
		Dw	0140Dh		; Offset 58h - Row 80h Column 038h
		Dw	0140Eh		; Offset 59h - Row 80h Column 03Fh
		Dw	01410h		; Offset 5Ah - Row 80h Column 046h
		Dw	01412h		; Offset 5Bh - Row 80h Column 04Dh
		Dw	01414h		; Offset 5Ch - Row 80h Column 054h
		Dw	01415h		; Offset 5Dh - Row 80h Column 05Bh
		Dw	01417h		; Offset 5Eh - Row 80h Column 062h
		Dw	01419h		; Offset 5Fh - Row 80h Column 069h
		Dw	0141Bh		; Offset 60h - Row 80h Column 070h
		Dw	0141Ch		; Offset 61h - Row 80h Column 077h
		Dw	0141Eh		; Offset 62h - Row 80h Column 07Eh
		Dw	01420h		; Offset 63h - Row 80h Column 085h
		Dw	01422h		; Offset 64h - Row 80h Column 08Ch
		Dw	01423h		; Offset 65h - Row 80h Column 093h
		Dw	01425h		; Offset 66h - Row 80h Column 09Ah
		Dw	01427h		; Offset 67h - Row 80h Column 0A1h
		Dw	01429h		; Offset 68h - Row 80h Column 0A8h
		Dw	0142Ah		; Offset 69h - Row 80h Column 0AFh
		Dw	0142Ch		; Offset 6Ah - Row 80h Column 0B6h
		Dw	0142Eh		; Offset 6Bh - Row 80h Column 0BDh
		Dw	01430h		; Offset 6Ch - Row 80h Column 0C4h
		Dw	01431h		; Offset 6Dh - Row 80h Column 0CBh
		Dw	01433h		; Offset 6Eh - Row 80h Column 0D2h
		Dw	01435h		; Offset 6Fh - Row 80h Column 0D9h
		Dw	01437h		; Offset 70h - Row 80h Column 0E0h
		Dw	01438h		; Offset 71h - Row 80h Column 0E7h
		Dw	0143Ah		; Offset 72h - Row 80h Column 0EEh
		Dw	0143Ch		; Offset 73h - Row 80h Column 0F5h
		Dw	0143Eh		; Offset 74h - Row 80h Column 0FCh
		Dw	0143Fh		; Offset 75h - Row 80h Column 103h
		Dw	01441h		; Offset 76h - Row 80h Column 10Ah
		Dw	01443h		; Offset 77h - Row 80h Column 111h
		Dw	07FFFh		; Offset 78h - Screen hole 00h
		Dw	07FFFh		; Offset 79h - Screen hole 01h
		Dw	07FFFh		; Offset 7Ah - Screen hole 02h
		Dw	07FFFh		; Offset 7Bh - Screen hole 03h
		Dw	07FFFh		; Offset 7Ch - Screen hole 04h
		Dw	07FFFh		; Offset 7Dh - Screen hole 05h
		Dw	07FFFh		; Offset 7Eh - Screen hole 06h
		Dw	07FFFh		; Offset 7Fh - Screen hole 07h
EGA_Address	Equ	This Word	; EGA graphics video offset lookup table
		Dw	0FFFFh		; Offset 00h - Row 00h Column 000h
		Dw	0FFFFh		; Offset 01h - Row 00h Column 007h
		Dw	00000h		; Offset 02h - Row 00h Column 00Eh
		Dw	00001h		; Offset 03h - Row 00h Column 015h
		Dw	00002h		; Offset 04h - Row 00h Column 01Ch
		Dw	00003h		; Offset 05h - Row 00h Column 023h
		Dw	00004h		; Offset 06h - Row 00h Column 02Ah
		Dw	00005h		; Offset 07h - Row 00h Column 031h
		Dw	00006h		; Offset 08h - Row 00h Column 038h
		Dw	00006h		; Offset 09h - Row 00h Column 03Fh
		Dw	00007h		; Offset 0Ah - Row 00h Column 046h
		Dw	00008h		; Offset 0Bh - Row 00h Column 04Dh
		Dw	00009h		; Offset 0Ch - Row 00h Column 054h
		Dw	0000Ah		; Offset 0Dh - Row 00h Column 05Bh
		Dw	0000Bh		; Offset 0Eh - Row 00h Column 062h
		Dw	0000Ch		; Offset 0Fh - Row 00h Column 069h
		Dw	0000Dh		; Offset 10h - Row 00h Column 070h
		Dw	0000Dh		; Offset 11h - Row 00h Column 077h
		Dw	0000Eh		; Offset 12h - Row 00h Column 07Eh
		Dw	0000Fh		; Offset 13h - Row 00h Column 085h
		Dw	00010h		; Offset 14h - Row 00h Column 08Ch
		Dw	00011h		; Offset 15h - Row 00h Column 093h
		Dw	00012h		; Offset 16h - Row 00h Column 09Ah
		Dw	00013h		; Offset 17h - Row 00h Column 0A1h
		Dw	00014h		; Offset 18h - Row 00h Column 0A8h
		Dw	00014h		; Offset 19h - Row 00h Column 0AFh
		Dw	00015h		; Offset 1Ah - Row 00h Column 0B6h
		Dw	00016h		; Offset 1Bh - Row 00h Column 0BDh
		Dw	00017h		; Offset 1Ch - Row 00h Column 0C4h
		Dw	00018h		; Offset 1Dh - Row 00h Column 0CBh
		Dw	00019h		; Offset 1Eh - Row 00h Column 0D2h
		Dw	0001Ah		; Offset 1Fh - Row 00h Column 0D9h
		Dw	0001Bh		; Offset 20h - Row 00h Column 0E0h
		Dw	0001Bh		; Offset 21h - Row 00h Column 0E7h
		Dw	0001Ch		; Offset 22h - Row 00h Column 0EEh
		Dw	0001Dh		; Offset 23h - Row 00h Column 0F5h
		Dw	0001Eh		; Offset 24h - Row 00h Column 0FCh
		Dw	0001Fh		; Offset 25h - Row 00h Column 103h
		Dw	00020h		; Offset 26h - Row 00h Column 10Ah
		Dw	00021h		; Offset 27h - Row 00h Column 111h
		Dw	009FFh		; Offset 28h - Row 40h Column 000h
		Dw	009FFh		; Offset 29h - Row 40h Column 007h
		Dw	00A00h		; Offset 2Ah - Row 40h Column 00Eh
		Dw	00A01h		; Offset 2Bh - Row 40h Column 015h
		Dw	00A02h		; Offset 2Ch - Row 40h Column 01Ch
		Dw	00A03h		; Offset 2Dh - Row 40h Column 023h
		Dw	00A04h		; Offset 2Eh - Row 40h Column 02Ah
		Dw	00A05h		; Offset 2Fh - Row 40h Column 031h
		Dw	00A06h		; Offset 30h - Row 40h Column 038h
		Dw	00A06h		; Offset 31h - Row 40h Column 03Fh
		Dw	00A07h		; Offset 32h - Row 40h Column 046h
		Dw	00A08h		; Offset 33h - Row 40h Column 04Dh
		Dw	00A09h		; Offset 34h - Row 40h Column 054h
		Dw	00A0Ah		; Offset 35h - Row 40h Column 05Bh
		Dw	00A0Bh		; Offset 36h - Row 40h Column 062h
		Dw	00A0Ch		; Offset 37h - Row 40h Column 069h
		Dw	00A0Dh		; Offset 38h - Row 40h Column 070h
		Dw	00A0Dh		; Offset 39h - Row 40h Column 077h
		Dw	00A0Eh		; Offset 3Ah - Row 40h Column 07Eh
		Dw	00A0Fh		; Offset 3Bh - Row 40h Column 085h
		Dw	00A10h		; Offset 3Ch - Row 40h Column 08Ch
		Dw	00A11h		; Offset 3Dh - Row 40h Column 093h
		Dw	00A12h		; Offset 3Eh - Row 40h Column 09Ah
		Dw	00A13h		; Offset 3Fh - Row 40h Column 0A1h
		Dw	00A14h		; Offset 40h - Row 40h Column 0A8h
		Dw	00A14h		; Offset 41h - Row 40h Column 0AFh
		Dw	00A15h		; Offset 42h - Row 40h Column 0B6h
		Dw	00A16h		; Offset 43h - Row 40h Column 0BDh
		Dw	00A17h		; Offset 44h - Row 40h Column 0C4h
		Dw	00A18h		; Offset 45h - Row 40h Column 0CBh
		Dw	00A19h		; Offset 46h - Row 40h Column 0D2h
		Dw	00A1Ah		; Offset 47h - Row 40h Column 0D9h
		Dw	00A1Bh		; Offset 48h - Row 40h Column 0E0h
		Dw	00A1Bh		; Offset 49h - Row 40h Column 0E7h
		Dw	00A1Ch		; Offset 4Ah - Row 40h Column 0EEh
		Dw	00A1Dh		; Offset 4Bh - Row 40h Column 0F5h
		Dw	00A1Eh		; Offset 4Ch - Row 40h Column 0FCh
		Dw	00A1Fh		; Offset 4Dh - Row 40h Column 103h
		Dw	00A20h		; Offset 4Eh - Row 40h Column 10Ah
		Dw	00A21h		; Offset 4Fh - Row 40h Column 111h
		Dw	013FFh		; Offset 50h - Row 80h Column 000h
		Dw	013FFh		; Offset 51h - Row 80h Column 007h
		Dw	01400h		; Offset 52h - Row 80h Column 00Eh
		Dw	01401h		; Offset 53h - Row 80h Column 015h
		Dw	01402h		; Offset 54h - Row 80h Column 01Ch
		Dw	01403h		; Offset 55h - Row 80h Column 023h
		Dw	01404h		; Offset 56h - Row 80h Column 02Ah
		Dw	01405h		; Offset 57h - Row 80h Column 031h
		Dw	01406h		; Offset 58h - Row 80h Column 038h
		Dw	01406h		; Offset 59h - Row 80h Column 03Fh
		Dw	01407h		; Offset 5Ah - Row 80h Column 046h
		Dw	01408h		; Offset 5Bh - Row 80h Column 04Dh
		Dw	01409h		; Offset 5Ch - Row 80h Column 054h
		Dw	0140Ah		; Offset 5Dh - Row 80h Column 05Bh
		Dw	0140Bh		; Offset 5Eh - Row 80h Column 062h
		Dw	0140Ch		; Offset 5Fh - Row 80h Column 069h
		Dw	0140Dh		; Offset 60h - Row 80h Column 070h
		Dw	0140Dh		; Offset 61h - Row 80h Column 077h
		Dw	0140Eh		; Offset 62h - Row 80h Column 07Eh
		Dw	0140Fh		; Offset 63h - Row 80h Column 085h
		Dw	01410h		; Offset 64h - Row 80h Column 08Ch
		Dw	01411h		; Offset 65h - Row 80h Column 093h
		Dw	01412h		; Offset 66h - Row 80h Column 09Ah
		Dw	01413h		; Offset 67h - Row 80h Column 0A1h
		Dw	01414h		; Offset 68h - Row 80h Column 0A8h
		Dw	01414h		; Offset 69h - Row 80h Column 0AFh
		Dw	01415h		; Offset 6Ah - Row 80h Column 0B6h
		Dw	01416h		; Offset 6Bh - Row 80h Column 0BDh
		Dw	01417h		; Offset 6Ch - Row 80h Column 0C4h
		Dw	01418h		; Offset 6Dh - Row 80h Column 0CBh
		Dw	01419h		; Offset 6Eh - Row 80h Column 0D2h
		Dw	0141Ah		; Offset 6Fh - Row 80h Column 0D9h
		Dw	0141Bh		; Offset 70h - Row 80h Column 0E0h
		Dw	0141Bh		; Offset 71h - Row 80h Column 0E7h
		Dw	0141Ch		; Offset 72h - Row 80h Column 0EEh
		Dw	0141Dh		; Offset 73h - Row 80h Column 0F5h
		Dw	0141Eh		; Offset 74h - Row 80h Column 0FCh
		Dw	0141Fh		; Offset 75h - Row 80h Column 103h
		Dw	01420h		; Offset 76h - Row 80h Column 10Ah
		Dw	01421h		; Offset 77h - Row 80h Column 111h
		Dw	07FFFh		; Offset 78h - Screen hole 00h
		Dw	07FFFh		; Offset 79h - Screen hole 01h
		Dw	07FFFh		; Offset 7Ah - Screen hole 02h
		Dw	07FFFh		; Offset 7Bh - Screen hole 03h
		Dw	07FFFh		; Offset 7Ch - Screen hole 04h
		Dw	07FFFh		; Offset 7Dh - Screen hole 05h
		Dw	07FFFh		; Offset 7Eh - Screen hole 06h
		Dw	07FFFh		; Offset 7Fh - Screen hole 07h
CGA_Slice	Equ	This Word	; CGA Slice/Macro line lookup table
		Dw	00000h		; Slice 000 - Macro 000 - Row 00h
		Dw	00140h		; Slice 000 - Macro 001 - Row 08h
		Dw	00280h		; Slice 000 - Macro 010 - Row 10h
		Dw	003C0h		; Slice 000 - Macro 011 - Row 18h
		Dw	00500h		; Slice 000 - Macro 100 - Row 20h
		Dw	00640h		; Slice 000 - Macro 101 - Row 28h
		Dw	00780h		; Slice 000 - Macro 110 - Row 30h
		Dw	008C0h		; Slice 000 - Macro 111 - Row 38h
		Dw	02000h		; Slice 001 - Macro 000 - Row 01h
		Dw	02140h		; Slice 001 - Macro 001 - Row 09h
		Dw	02280h		; Slice 001 - Macro 010 - Row 11h
		Dw	023C0h		; Slice 001 - Macro 011 - Row 19h
		Dw	02500h		; Slice 001 - Macro 100 - Row 21h
		Dw	02640h		; Slice 001 - Macro 101 - Row 29h
		Dw	02780h		; Slice 001 - Macro 110 - Row 31h
		Dw	028C0h		; Slice 001 - Macro 111 - Row 39h
		Dw	00050h		; Slice 010 - Macro 000 - Row 02h
		Dw	00190h		; Slice 010 - Macro 001 - Row 0Ah
		Dw	002D0h		; Slice 010 - Macro 010 - Row 12h
		Dw	00410h		; Slice 010 - Macro 011 - Row 1Ah
		Dw	00550h		; Slice 010 - Macro 100 - Row 22h
		Dw	00690h		; Slice 010 - Macro 101 - Row 2Ah
		Dw	007D0h		; Slice 010 - Macro 110 - Row 32h
		Dw	00910h		; Slice 010 - Macro 111 - Row 3Ah
		Dw	02050h		; Slice 011 - Macro 000 - Row 03h
		Dw	02190h		; Slice 011 - Macro 001 - Row 0Bh
		Dw	022D0h		; Slice 011 - Macro 010 - Row 13h
		Dw	02410h		; Slice 011 - Macro 011 - Row 1Bh
		Dw	02550h		; Slice 011 - Macro 100 - Row 23h
		Dw	02690h		; Slice 011 - Macro 101 - Row 2Bh
		Dw	027D0h		; Slice 011 - Macro 110 - Row 33h
		Dw	02910h		; Slice 011 - Macro 111 - Row 3Bh
		Dw	000A0h		; Slice 100 - Macro 000 - Row 04h
		Dw	001E0h		; Slice 100 - Macro 001 - Row 0Ch
		Dw	00320h		; Slice 100 - Macro 010 - Row 14h
		Dw	00460h		; Slice 100 - Macro 011 - Row 1Ch
		Dw	005A0h		; Slice 100 - Macro 100 - Row 24h
		Dw	006E0h		; Slice 100 - Macro 101 - Row 2Ch
		Dw	00820h		; Slice 100 - Macro 110 - Row 34h
		Dw	00960h		; Slice 100 - Macro 111 - Row 3Ch
		Dw	020A0h		; Slice 101 - Macro 000 - Row 05h
		Dw	021E0h		; Slice 101 - Macro 001 - Row 0Dh
		Dw	02320h		; Slice 101 - Macro 010 - Row 15h
		Dw	02460h		; Slice 101 - Macro 011 - Row 1Dh
		Dw	025A0h		; Slice 101 - Macro 100 - Row 25h
		Dw	026E0h		; Slice 101 - Macro 101 - Row 2Dh
		Dw	02820h		; Slice 101 - Macro 110 - Row 35h
		Dw	02960h		; Slice 101 - Macro 111 - Row 3Dh
		Dw	000F0h		; Slice 110 - Macro 000 - Row 06h
		Dw	00230h		; Slice 110 - Macro 001 - Row 0Eh
		Dw	00370h		; Slice 110 - Macro 010 - Row 16h
		Dw	004B0h		; Slice 110 - Macro 011 - Row 1Eh
		Dw	005F0h		; Slice 110 - Macro 100 - Row 26h
		Dw	00730h		; Slice 110 - Macro 101 - Row 2Eh
		Dw	00870h		; Slice 110 - Macro 110 - Row 36h
		Dw	009B0h		; Slice 110 - Macro 111 - Row 3Eh
		Dw	020F0h		; Slice 111 - Macro 000 - Row 07h
		Dw	02230h		; Slice 111 - Macro 001 - Row 0Fh
		Dw	02370h		; Slice 111 - Macro 010 - Row 17h
		Dw	024B0h		; Slice 111 - Macro 011 - Row 1Fh
		Dw	025F0h		; Slice 111 - Macro 100 - Row 27h
		Dw	02730h		; Slice 111 - Macro 101 - Row 2Fh
		Dw	02870h		; Slice 111 - Macro 110 - Row 37h
		Dw	029B0h		; Slice 111 - Macro 111 - Row 3Fh
EGA_Slice	Equ	This Word	; EGA Slice/Macro line lookup table
		Dw	00000h		; Slice 000 - Macro 000 - Row 00h
		Dw	00140h		; Slice 000 - Macro 001 - Row 08h
		Dw	00280h		; Slice 000 - Macro 010 - Row 10h
		Dw	003C0h		; Slice 000 - Macro 011 - Row 18h
		Dw	00500h		; Slice 000 - Macro 100 - Row 20h
		Dw	00640h		; Slice 000 - Macro 101 - Row 28h
		Dw	00780h		; Slice 000 - Macro 110 - Row 30h
		Dw	008C0h		; Slice 000 - Macro 111 - Row 38h
		Dw	00028h		; Slice 001 - Macro 000 - Row 01h
		Dw	00168h		; Slice 001 - Macro 001 - Row 09h
		Dw	002A8h		; Slice 001 - Macro 010 - Row 11h
		Dw	003E8h		; Slice 001 - Macro 011 - Row 19h
		Dw	00528h		; Slice 001 - Macro 100 - Row 21h
		Dw	00668h		; Slice 001 - Macro 101 - Row 29h
		Dw	007A8h		; Slice 001 - Macro 110 - Row 31h
		Dw	008E8h		; Slice 001 - Macro 111 - Row 39h
		Dw	00050h		; Slice 010 - Macro 000 - Row 02h
		Dw	00190h		; Slice 010 - Macro 001 - Row 0Ah
		Dw	002D0h		; Slice 010 - Macro 010 - Row 12h
		Dw	00410h		; Slice 010 - Macro 011 - Row 1Ah
		Dw	00550h		; Slice 010 - Macro 100 - Row 22h
		Dw	00690h		; Slice 010 - Macro 101 - Row 2Ah
		Dw	007D0h		; Slice 010 - Macro 110 - Row 32h
		Dw	00910h		; Slice 010 - Macro 111 - Row 3Ah
		Dw	00078h		; Slice 011 - Macro 000 - Row 03h
		Dw	001B8h		; Slice 011 - Macro 001 - Row 0Bh
		Dw	002F8h		; Slice 011 - Macro 010 - Row 13h
		Dw	00438h		; Slice 011 - Macro 011 - Row 1Bh
		Dw	00578h		; Slice 011 - Macro 100 - Row 23h
		Dw	006B8h		; Slice 011 - Macro 101 - Row 2Bh
		Dw	007F8h		; Slice 011 - Macro 110 - Row 33h
		Dw	00938h		; Slice 011 - Macro 111 - Row 3Bh
		Dw	000A0h		; Slice 100 - Macro 000 - Row 04h
		Dw	001E0h		; Slice 100 - Macro 001 - Row 0Ch
		Dw	00320h		; Slice 100 - Macro 010 - Row 14h
		Dw	00460h		; Slice 100 - Macro 011 - Row 1Ch
		Dw	005A0h		; Slice 100 - Macro 100 - Row 24h
		Dw	006E0h		; Slice 100 - Macro 101 - Row 2Ch
		Dw	00820h		; Slice 100 - Macro 110 - Row 34h
		Dw	00960h		; Slice 100 - Macro 111 - Row 3Ch
		Dw	000C8h		; Slice 101 - Macro 000 - Row 05h
		Dw	00208h		; Slice 101 - Macro 001 - Row 0Dh
		Dw	00348h		; Slice 101 - Macro 010 - Row 15h
		Dw	00488h		; Slice 101 - Macro 011 - Row 1Dh
		Dw	005C8h		; Slice 101 - Macro 100 - Row 25h
		Dw	00708h		; Slice 101 - Macro 101 - Row 2Dh
		Dw	00848h		; Slice 101 - Macro 110 - Row 35h
		Dw	00988h		; Slice 101 - Macro 111 - Row 3Dh
		Dw	000F0h		; Slice 110 - Macro 000 - Row 06h
		Dw	00230h		; Slice 110 - Macro 001 - Row 0Eh
		Dw	00370h		; Slice 110 - Macro 010 - Row 16h
		Dw	004B0h		; Slice 110 - Macro 011 - Row 1Eh
		Dw	005F0h		; Slice 110 - Macro 100 - Row 26h
		Dw	00730h		; Slice 110 - Macro 101 - Row 2Eh
		Dw	00870h		; Slice 110 - Macro 110 - Row 36h
		Dw	009B0h		; Slice 110 - Macro 111 - Row 3Eh
		Dw	00118h		; Slice 111 - Macro 000 - Row 07h
		Dw	00258h		; Slice 111 - Macro 001 - Row 0Fh
		Dw	00398h		; Slice 111 - Macro 010 - Row 17h
		Dw	004D8h		; Slice 111 - Macro 011 - Row 1Fh
		Dw	00618h		; Slice 111 - Macro 100 - Row 27h
		Dw	00758h		; Slice 111 - Macro 101 - Row 2Fh
		Dw	00898h		; Slice 111 - Macro 110 - Row 37h
		Dw	009D8h		; Slice 111 - Macro 111 - Row 3Fh
		Even			; Force table to even address
Reverse_Table	Equ	This Byte	; Graphics video bit reversal table
		Reverse <00000000>	; Binary 00000000b reversed - 00000000b
		Reverse <00000001>	; Binary 00000001b reversed - 10000000b
		Reverse <00000010>	; Binary 00000010b reversed - 01000000b
		Reverse <00000011>	; Binary 00000011b reversed - 11000000b
		Reverse <00000100>	; Binary 00000100b reversed - 00100000b
		Reverse <00000101>	; Binary 00000101b reversed - 10100000b
		Reverse <00000110>	; Binary 00000110b reversed - 01100000b
		Reverse <00000111>	; Binary 00000111b reversed - 11100000b
		Reverse <00001000>	; Binary 00001000b reversed - 00010000b
		Reverse <00001001>	; Binary 00001001b reversed - 10010000b
		Reverse <00001010>	; Binary 00001010b reversed - 01010000b
		Reverse <00001011>	; Binary 00001011b reversed - 11010000b
		Reverse <00001100>	; Binary 00001100b reversed - 00110000b
		Reverse <00001101>	; Binary 00001101b reversed - 10110000b
		Reverse <00001110>	; Binary 00001110b reversed - 01110000b
		Reverse <00001111>	; Binary 00001111b reversed - 11110000b
		Reverse <00010000>	; Binary 00010000b reversed - 00001000b
		Reverse <00010001>	; Binary 00010001b reversed - 10001000b
		Reverse <00010010>	; Binary 00010010b reversed - 01001000b
		Reverse <00010011>	; Binary 00010011b reversed - 11001000b
		Reverse <00010100>	; Binary 00010100b reversed - 00101000b
		Reverse <00010101>	; Binary 00010101b reversed - 10101000b
		Reverse <00010110>	; Binary 00010110b reversed - 01101000b
		Reverse <00010111>	; Binary 00010111b reversed - 11101000b
		Reverse <00011000>	; Binary 00011000b reversed - 00011000b
		Reverse <00011001>	; Binary 00011001b reversed - 10011000b
		Reverse <00011010>	; Binary 00011010b reversed - 01011000b
		Reverse <00011011>	; Binary 00011011b reversed - 11011000b
		Reverse <00011100>	; Binary 00011100b reversed - 00111000b
		Reverse <00011101>	; Binary 00011101b reversed - 10111000b
		Reverse <00011110>	; Binary 00011110b reversed - 01111000b
		Reverse <00011111>	; Binary 00011111b reversed - 11111000b
		Reverse <00100000>	; Binary 00100000b reversed - 00000100b
		Reverse <00100001>	; Binary 00100001b reversed - 10000100b
		Reverse <00100010>	; Binary 00100010b reversed - 01000100b
		Reverse <00100011>	; Binary 00100011b reversed - 11000100b
		Reverse <00100100>	; Binary 00100100b reversed - 00100100b
		Reverse <00100101>	; Binary 00100101b reversed - 10100100b
		Reverse <00100110>	; Binary 00100110b reversed - 01100100b
		Reverse <00100111>	; Binary 00100111b reversed - 11100100b
		Reverse <00101000>	; Binary 00101000b reversed - 00010100b
		Reverse <00101001>	; Binary 00101001b reversed - 10010100b
		Reverse <00101010>	; Binary 00101010b reversed - 01010100b
		Reverse <00101011>	; Binary 00101011b reversed - 11010100b
		Reverse <00101100>	; Binary 00101100b reversed - 00110100b
		Reverse <00101101>	; Binary 00101101b reversed - 10110100b
		Reverse <00101110>	; Binary 00101110b reversed - 01110100b
		Reverse <00101111>	; Binary 00101111b reversed - 11110100b
		Reverse <00110000>	; Binary 00110000b reversed - 00001100b
		Reverse <00110001>	; Binary 00110001b reversed - 10001100b
		Reverse <00110010>	; Binary 00110010b reversed - 01001100b
		Reverse <00110011>	; Binary 00110011b reversed - 11001100b
		Reverse <00110100>	; Binary 00110100b reversed - 00101100b
		Reverse <00110101>	; Binary 00110101b reversed - 10101100b
		Reverse <00110110>	; Binary 00110110b reversed - 01101100b
		Reverse <00110111>	; Binary 00110111b reversed - 11101100b
		Reverse <00111000>	; Binary 00111000b reversed - 00011100b
		Reverse <00111001>	; Binary 00111001b reversed - 10011100b
		Reverse <00111010>	; Binary 00111010b reversed - 01011100b
		Reverse <00111011>	; Binary 00111011b reversed - 11011100b
		Reverse <00111100>	; Binary 00111100b reversed - 00111100b
		Reverse <00111101>	; Binary 00111101b reversed - 10111100b
		Reverse <00111110>	; Binary 00111110b reversed - 01111100b
		Reverse <00111111>	; Binary 00111111b reversed - 11111100b
		Reverse <01000000>	; Binary 01000000b reversed - 00000010b
		Reverse <01000001>	; Binary 01000001b reversed - 10000010b
		Reverse <01000010>	; Binary 01000010b reversed - 01000010b
		Reverse <01000011>	; Binary 01000011b reversed - 11000010b
		Reverse <01000100>	; Binary 01000100b reversed - 00100010b
		Reverse <01000101>	; Binary 01000101b reversed - 10100010b
		Reverse <01000110>	; Binary 01000110b reversed - 01100010b
		Reverse <01000111>	; Binary 01000111b reversed - 11100010b
		Reverse <01001000>	; Binary 01001000b reversed - 00010010b
		Reverse <01001001>	; Binary 01001001b reversed - 10010010b
		Reverse <01001010>	; Binary 01001010b reversed - 01010010b
		Reverse <01001011>	; Binary 01001011b reversed - 11010010b
		Reverse <01001100>	; Binary 01001100b reversed - 00110010b
		Reverse <01001101>	; Binary 01001101b reversed - 10110010b
		Reverse <01001110>	; Binary 01001110b reversed - 01110010b
		Reverse <01001111>	; Binary 01001111b reversed - 11110010b
		Reverse <01010000>	; Binary 01010000b reversed - 00001010b
		Reverse <01010001>	; Binary 01010001b reversed - 10001010b
		Reverse <01010010>	; Binary 01010010b reversed - 01001010b
		Reverse <01010011>	; Binary 01010011b reversed - 11001010b
		Reverse <01010100>	; Binary 01010100b reversed - 00101010b
		Reverse <01010101>	; Binary 01010101b reversed - 10101010b
		Reverse <01010110>	; Binary 01010110b reversed - 01101010b
		Reverse <01010111>	; Binary 01010111b reversed - 11101010b
		Reverse <01011000>	; Binary 01011000b reversed - 00011010b
		Reverse <01011001>	; Binary 01011001b reversed - 10011010b
		Reverse <01011010>	; Binary 01011010b reversed - 01011010b
		Reverse <01011011>	; Binary 01011011b reversed - 11011010b
		Reverse <01011100>	; Binary 01011100b reversed - 00111010b
		Reverse <01011101>	; Binary 01011101b reversed - 10111010b
		Reverse <01011110>	; Binary 01011110b reversed - 01111010b
		Reverse <01011111>	; Binary 01011111b reversed - 11111010b
		Reverse <01100000>	; Binary 01100000b reversed - 00000110b
		Reverse <01100001>	; Binary 01100001b reversed - 10000110b
		Reverse <01100010>	; Binary 01100010b reversed - 01000110b
		Reverse <01100011>	; Binary 01100011b reversed - 11000110b
		Reverse <01100100>	; Binary 01100100b reversed - 00100110b
		Reverse <01100101>	; Binary 01100101b reversed - 10100110b
		Reverse <01100110>	; Binary 01100110b reversed - 01100110b
		Reverse <01100111>	; Binary 01100111b reversed - 11100110b
		Reverse <01101000>	; Binary 01101000b reversed - 00010110b
		Reverse <01101001>	; Binary 01101001b reversed - 10010110b
		Reverse <01101010>	; Binary 01101010b reversed - 01010110b
		Reverse <01101011>	; Binary 01101011b reversed - 11010110b
		Reverse <01101100>	; Binary 01101100b reversed - 00110110b
		Reverse <01101101>	; Binary 01101101b reversed - 10110110b
		Reverse <01101110>	; Binary 01101110b reversed - 01110110b
		Reverse <01101111>	; Binary 01101111b reversed - 11110110b
		Reverse <01110000>	; Binary 01110000b reversed - 00001110b
		Reverse <01110001>	; Binary 01110001b reversed - 10001110b
		Reverse <01110010>	; Binary 01110010b reversed - 01001110b
		Reverse <01110011>	; Binary 01110011b reversed - 11001110b
		Reverse <01110100>	; Binary 01110100b reversed - 00101110b
		Reverse <01110101>	; Binary 01110101b reversed - 10101110b
		Reverse <01110110>	; Binary 01110110b reversed - 01101110b
		Reverse <01110111>	; Binary 01110111b reversed - 11101110b
		Reverse <01111000>	; Binary 01111000b reversed - 00011110b
		Reverse <01111001>	; Binary 01111001b reversed - 10011110b
		Reverse <01111010>	; Binary 01111010b reversed - 01011110b
		Reverse <01111011>	; Binary 01111011b reversed - 11011110b
		Reverse <01111100>	; Binary 01111100b reversed - 00111110b
		Reverse <01111101>	; Binary 01111101b reversed - 10111110b
		Reverse <01111110>	; Binary 01111110b reversed - 01111110b
		Reverse <01111111>	; Binary 01111111b reversed - 11111110b
Even_Table	Equ	This Word	; Graphics even col. color exp. table
		Color	<BBBBBBB>	; Value 00000000b = BBBBBBBx
		Color	<BBBBBBP>	; Value 00000010b = BBBBBBPx
		Color	<BBBBBGB>	; Value 00000100b = BBBBBGBx
		Color	<BBBBBGP>	; Value 00000110b = BBBBBGPx
		Color	<BBBBPBB>	; Value 00001000b = BBBBPBBx
		Color	<BBBBPBP>	; Value 00001010b = BBBBPBPx
		Color	<BBBBPGB>	; Value 00001100b = BBBBPGBx
		Color	<BBBBPGP>	; Value 00001110b = BBBBPGPx
		Color	<BBBGBBB>	; Value 00010000b = BBBGBBBx
		Color	<BBBGBBP>	; Value 00010010b = BBBGBBPx
		Color	<BBBGBGB>	; Value 00010100b = BBBGBGBx
		Color	<BBBGBGP>	; Value 00010110b = BBBGBGPx
		Color	<BBBGPBB>	; Value 00011000b = BBBGPBBx
		Color	<BBBGPBP>	; Value 00011010b = BBBGPBPx
		Color	<BBBGPGB>	; Value 00011100b = BBBGPGBx
		Color	<BBBGPGP>	; Value 00011110b = BBBGPGPx
		Color	<BBPBBBB>	; Value 00100000b = BBPBBBBx
		Color	<BBPBBBP>	; Value 00100010b = BBPBBBPx
		Color	<BBPBBGB>	; Value 00100100b = BBPBBGBx
		Color	<BBPBBGP>	; Value 00100110b = BBPBBGPx
		Color	<BBPBPBB>	; Value 00101000b = BBPBPBBx
		Color	<BBPBPBP>	; Value 00101010b = BBPBPBPx
		Color	<BBPBPGB>	; Value 00101100b = BBPBPGBx
		Color	<BBPBPGP>	; Value 00101110b = BBPBPGPx
		Color	<BBPGBBB>	; Value 00110000b = BBPGBBBx
		Color	<BBPGBBP>	; Value 00110010b = BBPGBBPx
		Color	<BBPGBGB>	; Value 00110100b = BBPGBGBx
		Color	<BBPGBGP>	; Value 00110110b = BBPGBGPx
		Color	<BBPGPBB>	; Value 00111000b = BBPGPBBx
		Color	<BBPGPBP>	; Value 00111010b = BBPGPBPx
		Color	<BBPGPGB>	; Value 00111100b = BBPGPGBx
		Color	<BBPGPGP>	; Value 00111110b = BBPGPGPx
		Color	<BGBBBBB>	; Value 01000000b = BGBBBBBx
		Color	<BGBBBBP>	; Value 01000010b = BGBBBBPx
		Color	<BGBBBGB>	; Value 01000100b = BGBBBGBx
		Color	<BGBBBGP>	; Value 01000110b = BGBBBGPx
		Color	<BGBBPBB>	; Value 01001000b = BGBBPBBx
		Color	<BGBBPBP>	; Value 01001010b = BGBBPBPx
		Color	<BGBBPGB>	; Value 01001100b = BGBBPGBx
		Color	<BGBBPGP>	; Value 01001110b = BGBBPGPx
		Color	<BGBGBBB>	; Value 01010000b = BGBGBBBx
		Color	<BGBGBBP>	; Value 01010010b = BGBGBBPx
		Color	<BGBGBGB>	; Value 01010100b = BGBGBGBx
		Color	<BGBGBGP>	; Value 01010110b = BGBGBGPx
		Color	<BGBGPBB>	; Value 01011000b = BGBGPBBx
		Color	<BGBGPBP>	; Value 01011010b = BGBGPBPx
		Color	<BGBGPGB>	; Value 01011100b = BGBGPGBx
		Color	<BGBGPGP>	; Value 01011110b = BGBGPGPx
		Color	<BGPBBBB>	; Value 01100000b = BGPBBBBx
		Color	<BGPBBBP>	; Value 01100010b = BGPBBBPx
		Color	<BGPBBGB>	; Value 01100100b = BGPBBGBx
		Color	<BGPBBGP>	; Value 01100110b = BGPBBGPx
		Color	<BGPBPBB>	; Value 01101000b = BGPBPBBx
		Color	<BGPBPBP>	; Value 01101010b = BGPBPBPx
		Color	<BGPBPGB>	; Value 01101100b = BGPBPGBx
		Color	<BGPBPGP>	; Value 01101110b = BGPBPGPx
		Color	<BGPGBBB>	; Value 01110000b = BGPGBBBx
		Color	<BGPGBBP>	; Value 01110010b = BGPGBBPx
		Color	<BGPGBGB>	; Value 01110100b = BGPGBGBx
		Color	<BGPGBGP>	; Value 01110110b = BGPGBGPx
		Color	<BGPGPBB>	; Value 01111000b = BGPGPBBx
		Color	<BGPGPBP>	; Value 01111010b = BGPGPBPx
		Color	<BGPGPGB>	; Value 01111100b = BGPGPGBx
		Color	<BGPGPGP>	; Value 01111110b = BGPGPGPx
		Color	<PBBBBBB>	; Value 10000000b = PBBBBBBx
		Color	<PBBBBBP>	; Value 10000010b = PBBBBBPx
		Color	<PBBBBGB>	; Value 10000100b = PBBBBGBx
		Color	<PBBBBGP>	; Value 10000110b = PBBBBGPx
		Color	<PBBBPBB>	; Value 10001000b = PBBBPBBx
		Color	<PBBBPBP>	; Value 10001010b = PBBBPBPx
		Color	<PBBBPGB>	; Value 10001100b = PBBBPGBx
		Color	<PBBBPGP>	; Value 10001110b = PBBBPGPx
		Color	<PBBGBBB>	; Value 10010000b = PBBGBBBx
		Color	<PBBGBBP>	; Value 10010010b = PBBGBBPx
		Color	<PBBGBGB>	; Value 10010100b = PBBGBGBx
		Color	<PBBGBGP>	; Value 10010110b = PBBGBGPx
		Color	<PBBGPBB>	; Value 10011000b = PBBGPBBx
		Color	<PBBGPBP>	; Value 10011010b = PBBGPBPx
		Color	<PBBGPGB>	; Value 10011100b = PBBGPGBx
		Color	<PBBGPGP>	; Value 10011110b = PBBGPGPx
		Color	<PBPBBBB>	; Value 10100000b = PBPBBBBx
		Color	<PBPBBBP>	; Value 10100010b = PBPBBBPx
		Color	<PBPBBGB>	; Value 10100100b = PBPBBGBx
		Color	<PBPBBGP>	; Value 10100110b = PBPBBGPx
		Color	<PBPBPBB>	; Value 10101000b = PBPBPBBx
		Color	<PBPBPBP>	; Value 10101010b = PBPBPBPx
		Color	<PBPBPGB>	; Value 10101100b = PBPBPGBx
		Color	<PBPBPGP>	; Value 10101110b = PBPBPGPx
		Color	<PBPGBBB>	; Value 10110000b = PBPGBBBx
		Color	<PBPGBBP>	; Value 10110010b = PBPGBBPx
		Color	<PBPGBGB>	; Value 10110100b = PBPGBGBx
		Color	<PBPGBGP>	; Value 10110110b = PBPGBGPx
		Color	<PBPGPBB>	; Value 10111000b = PBPGPBBx
		Color	<PBPGPBP>	; Value 10111010b = PBPGPBPx
		Color	<PBPGPGB>	; Value 10111100b = PBPGPGBx
		Color	<PBPGPGP>	; Value 10111110b = PBPGPGPx
		Color	<PGBBBBB>	; Value 11000000b = PGBBBBBx
		Color	<PGBBBBP>	; Value 11000010b = PGBBBBPx
		Color	<PGBBBGB>	; Value 11000100b = PGBBBGBx
		Color	<PGBBBGP>	; Value 11000110b = PGBBBGPx
		Color	<PGBBPBB>	; Value 11001000b = PGBBPBBx
		Color	<PGBBPBP>	; Value 11001010b = PGBBPBPx
		Color	<PGBBPGB>	; Value 11001100b = PGBBPGBx
		Color	<PGBBPGP>	; Value 11001110b = PGBBPGPx
		Color	<PGBGBBB>	; Value 11010000b = PGBGBBBx
		Color	<PGBGBBP>	; Value 11010010b = PGBGBBPx
		Color	<PGBGBGB>	; Value 11010100b = PGBGBGBx
		Color	<PGBGBGP>	; Value 11010110b = PGBGBGPx
		Color	<PGBGPBB>	; Value 11011000b = PGBGPBBx
		Color	<PGBGPBP>	; Value 11011010b = PGBGPBPx
		Color	<PGBGPGB>	; Value 11011100b = PGBGPGBx
		Color	<PGBGPGP>	; Value 11011110b = PGBGPGPx
		Color	<PGPBBBB>	; Value 11100000b = PGPBBBBx
		Color	<PGPBBBP>	; Value 11100010b = PGPBBBPx
		Color	<PGPBBGB>	; Value 11100100b = PGPBBGBx
		Color	<PGPBBGP>	; Value 11100110b = PGPBBGPx
		Color	<PGPBPBB>	; Value 11101000b = PGPBPBBx
		Color	<PGPBPBP>	; Value 11101010b = PGPBPBPx
		Color	<PGPBPGB>	; Value 11101100b = PGPBPGBx
		Color	<PGPBPGP>	; Value 11101110b = PGPBPGPx
		Color	<PGPGBBB>	; Value 11110000b = PGPGBBBx
		Color	<PGPGBBP>	; Value 11110010b = PGPGBBPx
		Color	<PGPGBGB>	; Value 11110100b = PGPGBGBx
		Color	<PGPGBGP>	; Value 11110110b = PGPGBGPx
		Color	<PGPGPBB>	; Value 11111000b = PGPGPBBx
		Color	<PGPGPBP>	; Value 11111010b = PGPGPBPx
		Color	<PGPGPGB>	; Value 11111100b = PGPGPGBx
		Color	<PGPGPGP>	; Value 11111110b = PGPGPGPx
Odd_Table	Equ	This Word	; Graphics odd col. color exp. table
		Color	<BBBBBBB>	; Value 00000000b = BBBBBBBx
		Color	<BBBBBBG>	; Value 00000010b = BBBBBBGx
		Color	<BBBBBPB>	; Value 00000100b = BBBBBPBx
		Color	<BBBBBPG>	; Value 00000110b = BBBBBPGx
		Color	<BBBBGBB>	; Value 00001000b = BBBBGBBx
		Color	<BBBBGBG>	; Value 00001010b = BBBBGBGx
		Color	<BBBBGPB>	; Value 00001100b = BBBBGPBx
		Color	<BBBBGPG>	; Value 00001110b = BBBBGPGx
		Color	<BBBPBBB>	; Value 00010000b = BBBPBBBx
		Color	<BBBPBBG>	; Value 00010010b = BBBPBBGx
		Color	<BBBPBPB>	; Value 00010100b = BBBPBPBx
		Color	<BBBPBPG>	; Value 00010110b = BBBPBPGx
		Color	<BBBPGBB>	; Value 00011000b = BBBPGBBx
		Color	<BBBPGBG>	; Value 00011010b = BBBPGBGx
		Color	<BBBPGPB>	; Value 00011100b = BBBPGPBx
		Color	<BBBPGPG>	; Value 00011110b = BBBPGPGx
		Color	<BBGBBBB>	; Value 00100000b = BBGBBBBx
		Color	<BBGBBBG>	; Value 00100010b = BBGBBBGx
		Color	<BBGBBPB>	; Value 00100100b = BBGBBPBx
		Color	<BBGBBPG>	; Value 00100110b = BBGBBPGx
		Color	<BBGBGBB>	; Value 00101000b = BBGBGBBx
		Color	<BBGBGBG>	; Value 00101010b = BBGBGBGx
		Color	<BBGBGPB>	; Value 00101100b = BBGBGPBx
		Color	<BBGBGPG>	; Value 00101110b = BBGBGPGx
		Color	<BBGPBBB>	; Value 00110000b = BBGPBBBx
		Color	<BBGPBBG>	; Value 00110010b = BBGPBBGx
		Color	<BBGPBPB>	; Value 00110100b = BBGPBPBx
		Color	<BBGPBPG>	; Value 00110110b = BBGPBPGx
		Color	<BBGPGBB>	; Value 00111000b = BBGPGBBx
		Color	<BBGPGBG>	; Value 00111010b = BBGPGBGx
		Color	<BBGPGPB>	; Value 00111100b = BBGPGPBx
		Color	<BBGPGPG>	; Value 00111110b = BBGPGPGx
		Color	<BPBBBBB>	; Value 01000000b = BPBBBBBx
		Color	<BPBBBBG>	; Value 01000010b = BPBBBBGx
		Color	<BPBBBPB>	; Value 01000100b = BPBBBPBx
		Color	<BPBBBPG>	; Value 01000110b = BPBBBPGx
		Color	<BPBBGBB>	; Value 01001000b = BPBBGBBx
		Color	<BPBBGBG>	; Value 01001010b = BPBBGBGx
		Color	<BPBBGPB>	; Value 01001100b = BPBBGPBx
		Color	<BPBBGPG>	; Value 01001110b = BPBBGPGx
		Color	<BPBPBBB>	; Value 01010000b = BPBPBBBx
		Color	<BPBPBBG>	; Value 01010010b = BPBPBBGx
		Color	<BPBPBPB>	; Value 01010100b = BPBPBPBx
		Color	<BPBPBPG>	; Value 01010110b = BPBPBPGx
		Color	<BPBPGBB>	; Value 01011000b = BPBPGBBx
		Color	<BPBPGBG>	; Value 01011010b = BPBPGBGx
		Color	<BPBPGPB>	; Value 01011100b = BPBPGPBx
		Color	<BPBPGPG>	; Value 01011110b = BPBPGPGx
		Color	<BPGBBBB>	; Value 01100000b = BPGBBBBx
		Color	<BPGBBBG>	; Value 01100010b = BPGBBBGx
		Color	<BPGBBPB>	; Value 01100100b = BPGBBPBx
		Color	<BPGBBPG>	; Value 01100110b = BPGBBPGx
		Color	<BPGBGBB>	; Value 01101000b = BPGBGBBx
		Color	<BPGBGBG>	; Value 01101010b = BPGBGBGx
		Color	<BPGBGPB>	; Value 01101100b = BPGBGPBx
		Color	<BPGBGPG>	; Value 01101110b = BPGBGPGx
		Color	<BPGPBBB>	; Value 01110000b = BPGPBBBx
		Color	<BPGPBBG>	; Value 01110010b = BPGPBBGx
		Color	<BPGPBPB>	; Value 01110100b = BPGPBPBx
		Color	<BPGPBPG>	; Value 01110110b = BPGPBPGx
		Color	<BPGPGBB>	; Value 01111000b = BPGPGBBx
		Color	<BPGPGBG>	; Value 01111010b = BPGPGBGx
		Color	<BPGPGPB>	; Value 01111100b = BPGPGPBx
		Color	<BPGPGPG>	; Value 01111110b = BPGPGPGx
		Color	<GBBBBBB>	; Value 10000000b = GBBBBBBx
		Color	<GBBBBBG>	; Value 10000010b = GBBBBBGx
		Color	<GBBBBPB>	; Value 10000100b = GBBBBPBx
		Color	<GBBBBPG>	; Value 10000110b = GBBBBPGx
		Color	<GBBBGBB>	; Value 10001000b = GBBBGBBx
		Color	<GBBBGBG>	; Value 10001010b = GBBBGBGx
		Color	<GBBBGPB>	; Value 10001100b = GBBBGPBx
		Color	<GBBBGPG>	; Value 10001110b = GBBBGPGx
		Color	<GBBPBBB>	; Value 10010000b = GBBPBBBx
		Color	<GBBPBBG>	; Value 10010010b = GBBPBBGx
		Color	<GBBPBPB>	; Value 10010100b = GBBPBPBx
		Color	<GBBPBPG>	; Value 10010110b = GBBPBPGx
		Color	<GBBPGBB>	; Value 10011000b = GBBPGBBx
		Color	<GBBPGBG>	; Value 10011010b = GBBPGBGx
		Color	<GBBPGPB>	; Value 10011100b = GBBPGPBx
		Color	<GBBPGPG>	; Value 10011110b = GBBPGPGx
		Color	<GBGBBBB>	; Value 10100000b = GBGBBBBx
		Color	<GBGBBBG>	; Value 10100010b = GBGBBBGx
		Color	<GBGBBPB>	; Value 10100100b = GBGBBPBx
		Color	<GBGBBPG>	; Value 10100110b = GBGBBPGx
		Color	<GBGBGBB>	; Value 10101000b = GBGBGBBx
		Color	<GBGBGBG>	; Value 10101010b = GBGBGBGx
		Color	<GBGBGPB>	; Value 10101100b = GBGBGPBx
		Color	<GBGBGPG>	; Value 10101110b = GBGBGPGx
		Color	<GBGPBBB>	; Value 10110000b = GBGPBBBx
		Color	<GBGPBBG>	; Value 10110010b = GBGPBBGx
		Color	<GBGPBPB>	; Value 10110100b = GBGPBPBx
		Color	<GBGPBPG>	; Value 10110110b = GBGPBPGx
		Color	<GBGPGBB>	; Value 10111000b = GBGPGBBx
		Color	<GBGPGBG>	; Value 10111010b = GBGPGBGx
		Color	<GBGPGPB>	; Value 10111100b = GBGPGPBx
		Color	<GBGPGPG>	; Value 10111110b = GBGPGPGx
		Color	<GPBBBBB>	; Value 11000000b = GPBBBBBx
		Color	<GPBBBBG>	; Value 11000010b = GPBBBBGx
		Color	<GPBBBPB>	; Value 11000100b = GPBBBPBx
		Color	<GPBBBPG>	; Value 11000110b = GPBBBPGx
		Color	<GPBBGBB>	; Value 11001000b = GPBBGBBx
		Color	<GPBBGBG>	; Value 11001010b = GPBBGBGx
		Color	<GPBBGPB>	; Value 11001100b = GPBBGPBx
		Color	<GPBBGPG>	; Value 11001110b = GPBBGPGx
		Color	<GPBPBBB>	; Value 11010000b = GPBPBBBx
		Color	<GPBPBBG>	; Value 11010010b = GPBPBBGx
		Color	<GPBPBPB>	; Value 11010100b = GPBPBPBx
		Color	<GPBPBPG>	; Value 11010110b = GPBPBPGx
		Color	<GPBPGBB>	; Value 11011000b = GPBPGBBx
		Color	<GPBPGBG>	; Value 11011010b = GPBPGBGx
		Color	<GPBPGPB>	; Value 11011100b = GPBPGPBx
		Color	<GPBPGPG>	; Value 11011110b = GPBPGPGx
		Color	<GPGBBBB>	; Value 11100000b = GPGBBBBx
		Color	<GPGBBBG>	; Value 11100010b = GPGBBBGx
		Color	<GPGBBPB>	; Value 11100100b = GPGBBPBx
		Color	<GPGBBPG>	; Value 11100110b = GPGBBPGx
		Color	<GPGBGBB>	; Value 11101000b = GPGBGBBx
		Color	<GPGBGBG>	; Value 11101010b = GPGBGBGx
		Color	<GPGBGPB>	; Value 11101100b = GPGBGPBx
		Color	<GPGBGPG>	; Value 11101110b = GPGBGPGx
		Color	<GPGPBBB>	; Value 11110000b = GPGPBBBx
		Color	<GPGPBBG>	; Value 11110010b = GPGPBBGx
		Color	<GPGPBPB>	; Value 11110100b = GPGPBPBx
		Color	<GPGPBPG>	; Value 11110110b = GPGPBPGx
		Color	<GPGPGBB>	; Value 11111000b = GPGPGBBx
		Color	<GPGPGBG>	; Value 11111010b = GPGPGBGx
		Color	<GPGPGPB>	; Value 11111100b = GPGPGPBx
		Color	<GPGPGPG>	; Value 11111110b = GPGPGPGx
Column_Table	Equ	This Word	; CGA graphics video column table
		Dw	Even_Table	; Address Mod 4 = 0 (Even column)
		Dw	Odd_Table	; Address Mod 4 = 1 (Odd column)
		Dw	Even_Table	; Address Mod 4 = 2 (Even column)
		Dw	Odd_Table	; Address Mod 4 = 3 (Odd column)
CGA_Shift	Equ	This Byte	; CGA graphics video shift table
		Shift	<00,00> 	; Offset Mod 4 = 0 Word/Byte Shifts
		Shift	<06,02> 	; Offset Mod 4 = 1 Word/Byte Shifts
		Shift	<04,04> 	; Offset Mod 4 = 2 Word/Byte Shifts
		Shift	<02,00> 	; Offset Mod 4 = 3 Word/Byte Shifts
EGA_Shift	Equ	This Byte	; EGA graphics video shift table
		Db	0		; Offset Mod 8 = 0 Data Shift
		Db	7		; Offset Mod 8 = 1 Data Shift
		Db	6		; Offset Mod 8 = 2 Data Shift
		Db	5		; Offset Mod 8 = 3 Data Shift
		Db	4		; Offset Mod 8 = 0 Data Shift
		Db	3		; Offset Mod 8 = 1 Data Shift
		Db	2		; Offset Mod 8 = 2 Data Shift
		Db	1		; Offset Mod 8 = 3 Data Shift
;******************************************************************************
;
;	Define the color mapping values and mapping table
;
;******************************************************************************
		Map	0,BLACK 	; Map color  0 to  0 (Black)
		Map	1,LIGHT_MAGENTA ; Map color  1 to 13 (Light magenta)
		Map	2,BLUE		; Map color  2 to  1 (Blue)
		Map	3,MAGENTA	; Map color  3 to  5 (Magenta)
		Map	4,GREEN 	; Map color  4 to  2 (Green)
		Map	5,GRAY		; Map color  5 to  8 (Gray)
		Map	6,LIGHT_BLUE	; Map color  6 to  9 (Light Blue)
		Map	7,LIGHT_CYAN	; Map color  7 to 11 (Light Cyan)
		Map	8,BROWN 	; Map color  8 to  6 (Brown)
		Map	9,RED		; Map color  9 to  4 (Red)
		Map	10,WHITE	; Map color 10 to  7 (White)
		Map	11,LIGHT_RED	; Map color 11 to 12 (Light Red)
		Map	12,LIGHT_GREEN	; Map color 12 to 10 (Light Green)
		Map	13,YELLOW	; Map color 13 to 14 (Yellow)
		Map	14,CYAN 	; Map color 14 to  3 (Cyan)
		Map	15,INTENSE_WHITE; Map color 15 to 15 (Intense White)
Map_Table	Equ	This Byte	; Graphics color mapping table
		Convert 0,0		; Background - 00	Foreground - 00
		Convert 0,1		; Background - 00	Foreground - 01
		Convert 0,2		; Background - 00	Foreground - 02
		Convert 0,3		; Background - 00	Foreground - 03
		Convert 0,4		; Background - 00	Foreground - 04
		Convert 0,5		; Background - 00	Foreground - 05
		Convert 0,6		; Background - 00	Foreground - 06
		Convert 0,7		; Background - 00	Foreground - 07
		Convert 0,8		; Background - 00	Foreground - 08
		Convert 0,9		; Background - 00	Foreground - 09
		Convert 0,10		; Background - 00	Foreground - 10
		Convert 0,11		; Background - 00	Foreground - 11
		Convert 0,12		; Background - 00	Foreground - 12
		Convert 0,13		; Background - 00	Foreground - 13
		Convert 0,14		; Background - 00	Foreground - 14
		Convert 0,15		; Background - 00	Foreground - 15
		Convert 1,0		; Background - 01	Foreground - 00
		Convert 1,1		; Background - 01	Foreground - 01
		Convert 1,2		; Background - 01	Foreground - 02
		Convert 1,3		; Background - 01	Foreground - 03
		Convert 1,4		; Background - 01	Foreground - 04
		Convert 1,5		; Background - 01	Foreground - 05
		Convert 1,6		; Background - 01	Foreground - 06
		Convert 1,7		; Background - 01	Foreground - 07
		Convert 1,8		; Background - 01	Foreground - 08
		Convert 1,9		; Background - 01	Foreground - 09
		Convert 1,10		; Background - 01	Foreground - 10
		Convert 1,11		; Background - 01	Foreground - 11
		Convert 1,12		; Background - 01	Foreground - 12
		Convert 1,13		; Background - 01	Foreground - 13
		Convert 1,14		; Background - 01	Foreground - 14
		Convert 1,15		; Background - 01	Foreground - 15
		Convert 2,0		; Background - 02	Foreground - 00
		Convert 2,1		; Background - 02	Foreground - 01
		Convert 2,2		; Background - 02	Foreground - 02
		Convert 2,3		; Background - 02	Foreground - 03
		Convert 2,4		; Background - 02	Foreground - 04
		Convert 2,5		; Background - 02	Foreground - 05
		Convert 2,6		; Background - 02	Foreground - 06
		Convert 2,7		; Background - 02	Foreground - 07
		Convert 2,8		; Background - 02	Foreground - 08
		Convert 2,9		; Background - 02	Foreground - 09
		Convert 2,10		; Background - 02	Foreground - 10
		Convert 2,11		; Background - 02	Foreground - 11
		Convert 2,12		; Background - 02	Foreground - 12
		Convert 2,13		; Background - 02	Foreground - 13
		Convert 2,14		; Background - 02	Foreground - 14
		Convert 2,15		; Background - 02	Foreground - 15
		Convert 3,0		; Background - 03	Foreground - 00
		Convert 3,1		; Background - 03	Foreground - 01
		Convert 3,2		; Background - 03	Foreground - 02
		Convert 3,3		; Background - 03	Foreground - 03
		Convert 3,4		; Background - 03	Foreground - 04
		Convert 3,5		; Background - 03	Foreground - 05
		Convert 3,6		; Background - 03	Foreground - 06
		Convert 3,7		; Background - 03	Foreground - 07
		Convert 3,8		; Background - 03	Foreground - 08
		Convert 3,9		; Background - 03	Foreground - 09
		Convert 3,10		; Background - 03	Foreground - 10
		Convert 3,11		; Background - 03	Foreground - 11
		Convert 3,12		; Background - 03	Foreground - 12
		Convert 3,13		; Background - 03	Foreground - 13
		Convert 3,14		; Background - 03	Foreground - 14
		Convert 3,15		; Background - 03	Foreground - 15
		Convert 4,0		; Background - 04	Foreground - 00
		Convert 4,1		; Background - 04	Foreground - 01
		Convert 4,2		; Background - 04	Foreground - 02
		Convert 4,3		; Background - 04	Foreground - 03
		Convert 4,4		; Background - 04	Foreground - 04
		Convert 4,5		; Background - 04	Foreground - 05
		Convert 4,6		; Background - 04	Foreground - 06
		Convert 4,7		; Background - 04	Foreground - 07
		Convert 4,8		; Background - 04	Foreground - 08
		Convert 4,9		; Background - 04	Foreground - 09
		Convert 4,10		; Background - 04	Foreground - 10
		Convert 4,11		; Background - 04	Foreground - 11
		Convert 4,12		; Background - 04	Foreground - 12
		Convert 4,13		; Background - 04	Foreground - 13
		Convert 4,14		; Background - 04	Foreground - 14
		Convert 4,15		; Background - 04	Foreground - 15
		Convert 5,0		; Background - 05	Foreground - 00
		Convert 5,1		; Background - 05	Foreground - 01
		Convert 5,2		; Background - 05	Foreground - 02
		Convert 5,3		; Background - 05	Foreground - 03
		Convert 5,4		; Background - 05	Foreground - 04
		Convert 5,5		; Background - 05	Foreground - 05
		Convert 5,6		; Background - 05	Foreground - 06
		Convert 5,7		; Background - 05	Foreground - 07
		Convert 5,8		; Background - 05	Foreground - 08
		Convert 5,9		; Background - 05	Foreground - 09
		Convert 5,10		; Background - 05	Foreground - 10
		Convert 5,11		; Background - 05	Foreground - 11
		Convert 5,12		; Background - 05	Foreground - 12
		Convert 5,13		; Background - 05	Foreground - 13
		Convert 5,14		; Background - 05	Foreground - 14
		Convert 5,15		; Background - 05	Foreground - 15
		Convert 6,0		; Background - 06	Foreground - 00
		Convert 6,1		; Background - 06	Foreground - 01
		Convert 6,2		; Background - 06	Foreground - 02
		Convert 6,3		; Background - 06	Foreground - 03
		Convert 6,4		; Background - 06	Foreground - 04
		Convert 6,5		; Background - 06	Foreground - 05
		Convert 6,6		; Background - 06	Foreground - 06
		Convert 6,7		; Background - 06	Foreground - 07
		Convert 6,8		; Background - 06	Foreground - 08
		Convert 6,9		; Background - 06	Foreground - 09
		Convert 6,10		; Background - 06	Foreground - 10
		Convert 6,11		; Background - 06	Foreground - 11
		Convert 6,12		; Background - 06	Foreground - 12
		Convert 6,13		; Background - 06	Foreground - 13
		Convert 6,14		; Background - 06	Foreground - 14
		Convert 6,15		; Background - 06	Foreground - 15
		Convert 7,0		; Background - 07	Foreground - 00
		Convert 7,1		; Background - 07	Foreground - 01
		Convert 7,2		; Background - 07	Foreground - 02
		Convert 7,3		; Background - 07	Foreground - 03
		Convert 7,4		; Background - 07	Foreground - 04
		Convert 7,5		; Background - 07	Foreground - 05
		Convert 7,6		; Background - 07	Foreground - 06
		Convert 7,7		; Background - 07	Foreground - 07
		Convert 7,8		; Background - 07	Foreground - 08
		Convert 7,9		; Background - 07	Foreground - 09
		Convert 7,10		; Background - 07	Foreground - 10
		Convert 7,11		; Background - 07	Foreground - 11
		Convert 7,12		; Background - 07	Foreground - 12
		Convert 7,13		; Background - 07	Foreground - 13
		Convert 7,14		; Background - 07	Foreground - 14
		Convert 7,15		; Background - 07	Foreground - 15
		Convert 8,0		; Background - 08	Foreground - 00
		Convert 8,1		; Background - 08	Foreground - 01
		Convert 8,2		; Background - 08	Foreground - 02
		Convert 8,3		; Background - 08	Foreground - 03
		Convert 8,4		; Background - 08	Foreground - 04
		Convert 8,5		; Background - 08	Foreground - 05
		Convert 8,6		; Background - 08	Foreground - 06
		Convert 8,7		; Background - 08	Foreground - 07
		Convert 8,8		; Background - 08	Foreground - 08
		Convert 8,9		; Background - 08	Foreground - 09
		Convert 8,10		; Background - 08	Foreground - 10
		Convert 8,11		; Background - 08	Foreground - 11
		Convert 8,12		; Background - 08	Foreground - 12
		Convert 8,13		; Background - 08	Foreground - 13
		Convert 8,14		; Background - 08	Foreground - 14
		Convert 8,15		; Background - 08	Foreground - 15
		Convert 9,0		; Background - 09	Foreground - 00
		Convert 9,1		; Background - 09	Foreground - 01
		Convert 9,2		; Background - 09	Foreground - 02
		Convert 9,3		; Background - 09	Foreground - 03
		Convert 9,4		; Background - 09	Foreground - 04
		Convert 9,5		; Background - 09	Foreground - 05
		Convert 9,6		; Background - 09	Foreground - 06
		Convert 9,7		; Background - 09	Foreground - 07
		Convert 9,8		; Background - 09	Foreground - 08
		Convert 9,9		; Background - 09	Foreground - 09
		Convert 9,10		; Background - 09	Foreground - 10
		Convert 9,11		; Background - 09	Foreground - 11
		Convert 9,12		; Background - 09	Foreground - 12
		Convert 9,13		; Background - 09	Foreground - 13
		Convert 9,14		; Background - 09	Foreground - 14
		Convert 9,15		; Background - 09	Foreground - 15
		Convert 10,0		; Background - 10	Foreground - 00
		Convert 10,1		; Background - 10	Foreground - 01
		Convert 10,2		; Background - 10	Foreground - 02
		Convert 10,3		; Background - 10	Foreground - 03
		Convert 10,4		; Background - 10	Foreground - 04
		Convert 10,5		; Background - 10	Foreground - 05
		Convert 10,6		; Background - 10	Foreground - 06
		Convert 10,7		; Background - 10	Foreground - 07
		Convert 10,8		; Background - 10	Foreground - 08
		Convert 10,9		; Background - 10	Foreground - 09
		Convert 10,10		; Background - 10	Foreground - 10
		Convert 10,11		; Background - 10	Foreground - 11
		Convert 10,12		; Background - 10	Foreground - 12
		Convert 10,13		; Background - 10	Foreground - 13
		Convert 10,14		; Background - 10	Foreground - 14
		Convert 10,15		; Background - 10	Foreground - 15
		Convert 11,0		; Background - 11	Foreground - 00
		Convert 11,1		; Background - 11	Foreground - 01
		Convert 11,2		; Background - 11	Foreground - 02
		Convert 11,3		; Background - 11	Foreground - 03
		Convert 11,4		; Background - 11	Foreground - 04
		Convert 11,5		; Background - 11	Foreground - 05
		Convert 11,6		; Background - 11	Foreground - 06
		Convert 11,7		; Background - 11	Foreground - 07
		Convert 11,8		; Background - 11	Foreground - 08
		Convert 11,9		; Background - 11	Foreground - 09
		Convert 11,10		; Background - 11	Foreground - 10
		Convert 11,11		; Background - 11	Foreground - 11
		Convert 11,12		; Background - 11	Foreground - 12
		Convert 11,13		; Background - 11	Foreground - 13
		Convert 11,14		; Background - 11	Foreground - 14
		Convert 11,15		; Background - 11	Foreground - 15
		Convert 12,0		; Background - 12	Foreground - 00
		Convert 12,1		; Background - 12	Foreground - 01
		Convert 12,2		; Background - 12	Foreground - 02
		Convert 12,3		; Background - 12	Foreground - 03
		Convert 12,4		; Background - 12	Foreground - 04
		Convert 12,5		; Background - 12	Foreground - 05
		Convert 12,6		; Background - 12	Foreground - 06
		Convert 12,7		; Background - 12	Foreground - 07
		Convert 12,8		; Background - 12	Foreground - 08
		Convert 12,9		; Background - 12	Foreground - 09
		Convert 12,10		; Background - 12	Foreground - 10
		Convert 12,11		; Background - 12	Foreground - 11
		Convert 12,12		; Background - 12	Foreground - 12
		Convert 12,13		; Background - 12	Foreground - 13
		Convert 12,14		; Background - 12	Foreground - 14
		Convert 12,15		; Background - 12	Foreground - 15
		Convert 13,0		; Background - 13	Foreground - 00
		Convert 13,1		; Background - 13	Foreground - 01
		Convert 13,2		; Background - 13	Foreground - 02
		Convert 13,3		; Background - 13	Foreground - 03
		Convert 13,4		; Background - 13	Foreground - 04
		Convert 13,5		; Background - 13	Foreground - 05
		Convert 13,6		; Background - 13	Foreground - 06
		Convert 13,7		; Background - 13	Foreground - 07
		Convert 13,8		; Background - 13	Foreground - 08
		Convert 13,9		; Background - 13	Foreground - 09
		Convert 13,10		; Background - 13	Foreground - 10
		Convert 13,11		; Background - 13	Foreground - 11
		Convert 13,12		; Background - 13	Foreground - 12
		Convert 13,13		; Background - 13	Foreground - 13
		Convert 13,14		; Background - 13	Foreground - 14
		Convert 13,15		; Background - 13	Foreground - 15
		Convert 14,0		; Background - 14	Foreground - 00
		Convert 14,1		; Background - 14	Foreground - 01
		Convert 14,2		; Background - 14	Foreground - 02
		Convert 14,3		; Background - 14	Foreground - 03
		Convert 14,4		; Background - 14	Foreground - 04
		Convert 14,5		; Background - 14	Foreground - 05
		Convert 14,6		; Background - 14	Foreground - 06
		Convert 14,7		; Background - 14	Foreground - 07
		Convert 14,8		; Background - 14	Foreground - 08
		Convert 14,9		; Background - 14	Foreground - 09
		Convert 14,10		; Background - 14	Foreground - 10
		Convert 14,11		; Background - 14	Foreground - 11
		Convert 14,12		; Background - 14	Foreground - 12
		Convert 14,13		; Background - 14	Foreground - 13
		Convert 14,14		; Background - 14	Foreground - 14
		Convert 14,15		; Background - 14	Foreground - 15
		Convert 15,0		; Background - 15	Foreground - 00
		Convert 15,1		; Background - 15	Foreground - 01
		Convert 15,2		; Background - 15	Foreground - 02
		Convert 15,3		; Background - 15	Foreground - 03
		Convert 15,4		; Background - 15	Foreground - 04
		Convert 15,5		; Background - 15	Foreground - 05
		Convert 15,6		; Background - 15	Foreground - 06
		Convert 15,7		; Background - 15	Foreground - 07
		Convert 15,8		; Background - 15	Foreground - 08
		Convert 15,9		; Background - 15	Foreground - 09
		Convert 15,10		; Background - 15	Foreground - 10
		Convert 15,11		; Background - 15	Foreground - 11
		Convert 15,12		; Background - 15	Foreground - 12
		Convert 15,13		; Background - 15	Foreground - 13
		Convert 15,14		; Background - 15	Foreground - 14
		Convert 15,15		; Background - 15	Foreground - 15
;******************************************************************************
;
;	Define the text color palette table for CGA display
;
;	 0 0 0 I 0 r g b
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 ----- | | | | -------> Primary Blue Gun
;	   |   | | | ---------> Primary Green Gun
;	   |   | | -----------> Primary Red Gun
;	   |   | -------------> ***** Not Used *****
;	   |   ---------------> Intensity
;	   -------------------> ***** Not Used *****
;
;******************************************************************************
Text_CGA	Equ	This Byte	; Text CGA color palette table
		CGA	<>		; Color 0 - Black		[]
		CGA	<b>		; Color 1 - Blue		[b]
		CGA	<g>		; Color 2 - Green		[g]
		CGA	<gb>		; Color 3 - Cyan		[gb]
		CGA	<r>		; Color 4 - Red 		[r]
		CGA	<rb>		; Color 5 - Magenta		[rb]
		CGA	<rg>		; Color 6 - Brown		[rg]
		CGA	<rgb>		; Color 7 - White		[rgb]
		CGA	<I>		; Color 8 - Gray		[I]
		CGA	<Ib>		; Color 9 - Light Blue		[Ib]
		CGA	<Ig>		; Color A - Light Green 	[Ig]
		CGA	<Igb>		; Color B - Light Cyan		[Igb]
		CGA	<Ir>		; Color C - Light Red		[Ir]
		CGA	<Irb>		; Color D - Light Magenta	[Irb]
		CGA	<Irg>		; Color E - Yellow		[Irg]
		CGA	<Irgb>		; Color F - Intense White	[Irgb]
		CGA	<>		; Background - Black		[]
;******************************************************************************
;
;	Define the text color palette table for EGA display
;
;	 0 0 R G B r g b
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 --- | | | | | -------> Primary Blue Gun
;	  |  | | | | ---------> Primary Green Gun
;	  |  | | | -----------> Primary Red Gun
;	  |  | | -------------> Secondary Blue Gun
;	  |  | ---------------> Secondary Green Gun
;	  |  -----------------> Secondary Red Gun
;	  --------------------> ***** Not Used *****
;
;******************************************************************************
Text_EGA	Equ	This Byte	; Text EGA color palette table
		EGA	<>		; Color 0 - Black		[]
		EGA	<b>		; Color 1 - Blue		[b]
		EGA	<g>		; Color 2 - Green		[g]
		EGA	<gb>		; Color 3 - Cyan		[gb]
		EGA	<r>		; Color 4 - Red 		[r]
		EGA	<rb>		; Color 5 - Magenta		[rb]
		EGA	<Gr>		; Color 6 - Brown		[Gr]
		EGA	<rgb>		; Color 7 - White		[rgb]
		EGA	<RGB>		; Color 8 - Gray		[RGB]
		EGA	<RGBb>		; Color 9 - Light Blue		[RGBb]
		EGA	<RGBg>		; Color A - Light Green 	[RGBg]
		EGA	<RGBgb> 	; Color B - Light Cyan		[RGBgb]
		EGA	<RGBr>		; Color C - Light Red		[RGBr]
		EGA	<RGBrb> 	; Color D - Light Magenta	[RGBrb]
		EGA	<RGBrg> 	; Color E - Yellow		[RGBrg]
		EGA	<RGBrgb>	; Color F - Intense White	[RGBrgb]
		EGA	<>		; Background - Black	[]
;******************************************************************************
;
;	Define the low resolution color palette table for CGA display
;
;	 0 0 0 I 0 r g b
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 ----- | | | | -------> Primary Blue Gun
;	   |   | | | ---------> Primary Green Gun
;	   |   | | -----------> Primary Red Gun
;	   |   | -------------> ***** Not Used *****
;	   |   ---------------> Intensity
;	   -------------------> ***** Not Used *****
;
;******************************************************************************
Low_CGA 	Equ	This Byte	; Low res. CGA color palette table
		CGA	<>		; Color 0 - Black	[]
		CGA	<Irb>		; Color 1 - Magenta	[Irb]
		CGA	<b>		; Color 2 - Dark Blue	[b]
		CGA	<rb>		; Color 3 - Purple	[rb]
		CGA	<g>		; Color 4 - Dark Green	[g]
		CGA	<I>		; Color 5 - Gray 1	[I]
		CGA	<Ib>		; Color 6 - Medium Blue [Ib]
		CGA	<Igb>		; Color 7 - Light Blue	[Igb]
		CGA	<rg>		; Color 8 - Brown	[rg]
		CGA	<r>		; Color 9 - Orange	[r]
		CGA	<rgb>		; Color A - Gray 2	[rgb]
		CGA	<Ir>		; Color B - Pink	[Ir]
		CGA	<Ig>		; Color C - Light Green [Ig]
		CGA	<Irg>		; Color D - Yellow	[Irg]
		CGA	<gb>		; Color E - Aquamarine	[gb]
		CGA	<Irgb>		; Color F - White	[Irgb]
		CGA	<>		; Background - Black	[]
;******************************************************************************
;
;	Define the low resolution color palette table for EGA display
;
;	 0 0 R G B r g b
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 --- | | | | | -------> Primary Blue Gun
;	  |  | | | | ---------> Primary Green Gun
;	  |  | | | -----------> Primary Red Gun
;	  |  | | -------------> Secondary Blue Gun
;	  |  | ---------------> Secondary Green Gun
;	  |  -----------------> Secondary Red Gun
;	  --------------------> ***** Not Used *****
;
;******************************************************************************
Low_EGA 	Equ	This Byte	; Low res. EGA color palette table
		EGA	<>		; Color 0 - Black	[]
		EGA	<RBrb>		; Color 1 - Magenta	[RBrb]
		EGA	<B>		; Color 2 - Dark Blue	[B]
		EGA	<RB>		; Color 3 - Purple	[RB]
		EGA	<G>		; Color 4 - Dark Green	[G]
		EGA	<RGB>		; Color 5 - Gray 1	[RGB]
		EGA	<b>		; Color 6 - Medium Blue [b]
		EGA	<Bb>		; Color 7 - Light Blue	[Bb]
		EGA	<Gr>		; Color 8 - Brown	[Gr]
		EGA	<Rrg>		; Color 9 - Orange	[Rrg]
		EGA	<rgb>		; Color A - Gray 2	[rgb]
		EGA	<RGBr>		; Color B - Pink	[RGBr]
		EGA	<Gg>		; Color C - Light Green [Gg]
		EGA	<RGrg>		; Color D - Yellow	[RGrg]
		EGA	<Bg>		; Color E - Aquamarine	[Bg]
		EGA	<RGBrgb>	; Color F - White	[RGBrgb]
		EGA	<>		; Background - Black	[]
;******************************************************************************
;
;	Define the high resolution color palette table for CGA display
;
;	 0 0 0 I 0 r g b
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 ----- | | | | -------> Primary Blue Gun
;	   |   | | | ---------> Primary Green Gun
;	   |   | | -----------> Primary Red Gun
;	   |   | -------------> ***** Not Used *****
;	   |   ---------------> Intensity
;	   -------------------> ***** Not Used *****
;
;******************************************************************************
High_CGA	Equ	This Byte	; High res. CGA color palette table
		CGA	<>		; Color 0 - Black	[]
		CGA	<Irb>		; Color 1 - Purple	[Irb]
		CGA	<>		; Color 2 - Black	[]
		CGA	<Ig>		; Color 3 - Green	[Ig]
		CGA	<>		; Color 4 - Black	[]
		CGA	<Ib>		; Color 5 - Blue	[Ib]
		CGA	<>		; Color 6 - Black	[]
		CGA	<Irg>		; Color 7 - Orange	[Irg]
		CGA	<>		; Color 8 - Black	[]
		CGA	<Irb>		; Color 9 - Purple	[Irb]
		CGA	<>		; Color A - Black	[]
		CGA	<Ig>		; Color B - Green	[Ig]
		CGA	<>		; Color C - Black	[]
		CGA	<Ib>		; Color D - Blue	[Ib]
		CGA	<>		; Color E - Black	[]
		CGA	<Irg>		; Color F - Orange	[Irg]
		CGA	<>		; Background - Black	[]
;******************************************************************************
;
;	Define the high resolution color palette table for EGA display
;
;	 0 0 0 I 0 r g b
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 ----- | | | | -------> Primary Blue Gun
;	   |   | | | ---------> Primary Green Gun
;	   |   | | -----------> Primary Red Gun
;	   |   | -------------> ***** Not Used *****
;	   |   ---------------> Intensity
;	   -------------------> ***** Not Used *****
;
;******************************************************************************
High_EGA	Equ	This Byte	; High res. EGA color palette table
		CGA	<>		; Color 0 - Black	[]
		CGA	<Irb>		; Color 1 - Purple	[Irb]
		CGA	<>		; Color 2 - Black	[]
		CGA	<Ig>		; Color 3 - Green	[Ig]
		CGA	<>		; Color 4 - Black	[]
		CGA	<Ib>		; Color 5 - Blue	[Ib]
		CGA	<>		; Color 6 - Black	[]
		CGA	<Irg>		; Color 7 - Orange	[Irg]
		CGA	<>		; Color 8 - Black	[]
		CGA	<Irb>		; Color 9 - Purple	[Irb]
		CGA	<>		; Color A - Black	[]
		CGA	<Ig>		; Color B - Green	[Ig]
		CGA	<>		; Color C - Black	[]
		CGA	<Ib>		; Color D - Blue	[Ib]
		CGA	<>		; Color E - Black	[]
		CGA	<Irg>		; Color F - Orange	[Irg]
		CGA	<>		; Background - Black	[]
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Video module

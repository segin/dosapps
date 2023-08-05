	Page	58,132
	Title	LANGUAGE.ASM	Language Card Routines
;******************************************************************************
;
;   Name:	LANGUAGE.ASM	Language Card Routines
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
;	language card.
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
	Public	Lang_ID 		; Langauge card ID string
	Public	Lang_Init		; Language card initialization routine
	Public	Lang_Ctrl		; Language card control routine
	Public	Lang_Rd 		; Language card read routine
	Public	Lang_Wrt		; Language card write routine
	Public	Lang_Mem_Rd		; Language card memory read routine
	Public	Lang_Mem_Wrt		; Language card memory write routine
	Public	Lang_Exp_Rd		; Language card expansion read routine
	Public	Lang_Exp_Wrt		; Language card expansion write routine
	Public	Lang_Data		; Language card data segment pointers
;
;  External Declarations
;
	Extrn	Slot_Address:Near	; Get expansion slot address   (DEVICE)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
	Extrn	Read_Table:Word 	; Read memory page table	 (DATA)
	Extrn	Write_Table:Word	; Write memory page table	 (DATA)
	Extrn	ERR_NO_MEMORY:Abs	; Not enough memory error code	 (DATA)
;
;  LOCAL Equates
;
LANG_SIZE	Equ	0801h		; Langauge card memory size (32K)
ROM_SIZE	Equ	0300h		; Size of ROM area (12K)
START_PAGE	Equ	0D0h		; Starting bank switch page address
START_BANK	Equ	0D0h		; Starting bank page address
START_SEG	Equ	0E0h		; Starting segment page address
BANK_COUNT	Equ	10h		; Number of bank switched pages (4K)
MAIN_COUNT	Equ	20h		; Number of main switched pages (8K)
BANK_SIZE	Equ	1000h		; Size of bank pages (4096 Bytes)  [4K]
MAIN_SIZE	Equ	2000h		; Size of main pages (8192 Bytes)  [8K]
TOTAL_SIZE	Equ	3000h		; Total memory size (12288 Bytes) [12K]
CONTROL_MASK	Equ	0Fh		; Language card control bits mask
SHIFT_COUNT	Equ	03h		; Paragraphs to words shift count
CTRL_INIT	equ	00h		; Language card control initialization
FLAG_INIT	Equ	00h		; Language card flag initialization
WRITE_SELECT	Equ	01h		; Language card write select ctrl. bit
READ_SELECT	Equ	02h		; Language card read select ctrl. bit
SEGMENT_SELECT	Equ	04h		; Language card segment select ctrl. bit
BANK_SELECT	Equ	08h		; Language card bank select ctrl. bit
SEG_CHANGE	Equ	04h		; Language card segment change bit
BANK_CHANGE	Equ	08h		; Language card bank change bit
ROM_SLOT	Equ	8000h		; ROM read/write slot index value
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
	Include 	Strucs.inc	; Include the structure definitions
	.286c				; Include 80286 instructions
	Page
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	Lang_Init	Language Card Initialization
	Page	+
;******************************************************************************
;
;	Lang_Init(RAM_Space, Slot_Number)
;
;		If ROM save area has not been allocated
;			Try to allocate memory for the ROM save area
;			If errors allocating memory
;				Set error code to not enough memory
;				Call the error routine
;				Call routine to exit the emulator
;			Endif
;			Save ROM save area segment
;			Copy ROM data to save area
;			Copy language card bank write to write table
;			Copy language card segment write to write table
;		Endif for ROM save area
;		Try to allocate memory for the language card
;		If no errors allocating memory
;			Save address of language card data area
;			Initialize the language card control byte
;			Initialize the language card flags
;		Else not enough memory available
;			Set error code to not enough memory
;			Call the error routine
;			Call routine to exit the emulator
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Slot number (0 - 7)
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Init	Proc	Near		; Language card initialization procedure
	mov	di,ax			; Get the language card slot number
	shl	di,1			; Convert slot number to table index
	mov	ax,cs:[ROM_Save]	; Get the ROM save area segment pointer
	or	ax,ax			; Check for ROM save area allocated
	jnz	Lang_Allocate		; Jump if area already allocated
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,ROM_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate the ROM save area
	jnc	ROM_Copy		; Jump if no errors allocating space
Memory_Error:
	mov	al,ERR_NO_MEMORY	; Get not enough memory error code
	call	Error			; Call routine to print the error
	call	Exit			; Call routine to exit the emulator
ROM_Copy:
	push	di			; Save the slot index value
	mov	cs:[ROM_Save],ax	; Save the ROM save area segment
	mov	dx,es			; Save the ES segment value
	mov	es,ax			; Setup ES to the ROM save area segment
	mov	ah,START_PAGE		; Get the starting ROM page number
	xor	al,al			; Convert page number to actual address
	mov	si,ax			; Move ROM address to SI register
	xor	di,di			; Zero the DI register value
	mov	cx,ROM_SIZE		; Get the ROM area size (Paragraphs)
	shl	cx,SHIFT_COUNT		; Convert paragraphs to words
	rep	movsw			; Save the ROM data area (12K)
Table_Update:
	mov	ax,cs			; Get the current CS register value
	mov	es,ax			; Setup ES to current CS register value
	lea	di,cs:[Write_Table]	; Get the write memory table offset
	add	di,START_BANK Shl 1	; Compute bank switched starting offset
	lea	ax,cs:[Lang_Bank]	; Get address of bank switched routine
	mov	cx,BANK_COUNT		; Get number of bank switched pages
	rep	stosw			; Update the write memory address
	lea	di,cs:[Write_Table]	; Get the write memory table offset
	add	di,START_SEG Shl 1	; Compute main switched starting offset
	lea	ax,cs:[Lang_Segment]	; Get address of main switched routine
	mov	cx,MAIN_COUNT		; Get number of main switched pages
	rep	stosw			; Update the write memory address
	mov	es,dx			; Restore the ES register value
	pop	di			; Restore the slot index value
Lang_Allocate:
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,LANG_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate language card space
	jc	Memory_Error		; Jump if errors allocating space
	mov	dx,ds			; Save 65C02 RAM space segment value
	mov	ds,ax			; Setup language segment address
	mov	cs:[di + Lang_Data],ax	; Save language card segment address
	mov	ds:[Lang_Byte],CTRL_INIT; Initialize the language control byte
	mov	ds:[Lang_Flag],FLAG_INIT; Initialize the language card flags
	mov	ds,dx			; Restore 65C02 RAM space segment value
	ret				; Return to the caller
Lang_Init	Endp			; End of the Lang_Init procedure
	Subttl	Lang_Ctrl	Language Card Control
	Page	+
;******************************************************************************
;
;	Lang_Ctrl(RAM_Space, Slot_Number)
;
;
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Slot number (0 - 7)
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Ctrl	Proc	Near		; Language card control procedure

	ret				; Return to the caller
Lang_Ctrl	Endp			; End of the Lang_Ctrl procedure
	Subttl	Lang_Rd 	Language Card Read
	Page	+
;******************************************************************************
;
;	Lang_Rd(Effective_Address, Slot_Index)
;
;		Save the required registers
;		Setup the language card data segment
;		Get the language card control bits (From effective address)
;		Get the current control bits value
;		Update the control bits value
;		Call the correct routine to handle the update
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		BP    - Slot index (Slot number * 2)
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;		AH    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Rd 	Proc	Near		; Language card read procedure
	Save	bx,es			; Save the required registers
	mov	es,cs:[bp + Lang_Data]	; Setup the language card data segment
	mov	ax,di			; Get the effective address
	and	ax,CONTROL_MASK 	; Mask off all but the control bits
	mov	bx,ax			; Move control bits to BX register
	shl	bx,1			; Convert control bits to table index
	mov	ah,es:[Lang_Byte]	; Get the current control bit values
	mov	es:[Lang_Byte],al	; Update the control bits value
	call	cs:[bx + Lang_Table]	; Call correct routine to handle update
Lang_Rd_Exit:
	Restore bx,es			; Restore the required registers
	ret				; Return to the caller
Lang_Rd 	Endp			; End of the Lang_Rd procedure
	Subttl	Lang_Wrt	Language Card Write
	Page	+
;******************************************************************************
;
;	Lang_Wrt(Effective_Address, Slot_Index, Memory_Value)
;
;		Save the required registers
;		Setup the language card data segment
;		Get the language card control bits (From effective address)
;		Get the current control bits value
;		Update the control bits value
;		Call the correct routine to handle the update
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		BP    - Slot index (Slot number * 2)
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Wrt	Proc	Near		; Language card write procedure
	Save	ax,bx,es		; Save the required registers
	mov	es,cs:[bp + Lang_Data]	; Setup the language card data segment
	mov	ax,di			; Get the effective address
	and	ax,CONTROL_MASK 	; Mask off all but the control bits
	mov	bx,ax			; Move control bits to BX register
	shl	bx,1			; Convert control bits to table index
	mov	ah,es:[Lang_Byte]	; Get the current control bit values
	mov	es:[Lang_Byte],al	; Update the control bits value
	call	cs:[bx + Lang_Table]	; Call correct routine to handle update
Lang_Wrt_Exit:
	Restore ax,bx,es		; Restore the required registers
	ret				; Return to the caller
Lang_Wrt	Endp			; End of the Lang_Wrt procedure
	Subttl	Lang_Mem_Rd	Language Card Memory Read
	Page	+
;******************************************************************************
;
;	Lang_Mem_Rd(Effective_Address)
;
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
Lang_Mem_Rd	Proc	Near		; Language card memory read procedure
	ret				; Return to the caller
Lang_Mem_Rd	Endp			; End of the Lang_Mem_Rd procedure
	Subttl	Lang_Mem_Wrt	Language Card Memory Write
	Page	+
;******************************************************************************
;
;	Lang_Mem_Wrt(Effective_Address)
;
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Mem_Wrt	Proc	Near		; Language card memory write procedure
	ret				; Return to the caller
Lang_Mem_Wrt	Endp			; End of the Lang_Mem_Wrt procedure
	Subttl	Lang_Exp_Rd	Language Card Expansion Read
	Page	+
;******************************************************************************
;
;	Lang_Exp_Rd(Effective_Address)
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
Lang_Exp_Rd	Proc	Near		; Language card expansion read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Lang_Exp_Rd	Endp			; End of the Lang_Exp_Rd procedure
	Subttl	Lang_Exp_Wrt	Language Card Expansion Write
	Page	+
;******************************************************************************
;
;	Lang_Exp_Wrt(Effective_Address)
;
;		Return to the caller (Area is NOT writable)
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Exp_Wrt	Proc	Near		; Language card exp. write procedure
	ret				; Return to the caller
Lang_Exp_Wrt	Endp			; End of the Lang_Exp_Wrt procedure
	Subttl	Lang_Bank	Language Card Bank Write Routine
	Page	+
;******************************************************************************
;
;	Lang_Bank(Effective_Address, Value)
;
;		Save the required registers
;		Get the current write slot value
;		Get the language card segment for this slot
;		If this card is currently write enabled
;			If read slot matches this write slot
;				Move value into RAM space (Effective address)
;			Endif
;			Get the current write bank offset
;			Compute the actual write address
;			Move value into language card space
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Bank	Proc	Near		; Language card bank write procedure
	Save	es			; Save the required registers
	mov	bp,cs:[Write_Slot]	; Get the current write slot index
	mov	es,cs:[Lang_Data + bp]	; Get language card segment for slot
	test	es:[Lang_Flag],WRITE_ENABLE
	jz	Bank_Exit		; Jump if card is NOT write enabled
	cmp	bp,cs:[Read_Slot]	; Compare to current read slot index
	jne	Update_Bank		; Jump if slots are not the same
	mov	ds:[di],al		; Update the value in RAM space
Update_Bank:
	mov	bp,di			; Get the effective address offset
	sub	bp,START_BANK Shl 8	; Compute zero-based offset value
	add	bp,cs:[Write_Bank]	; Compute the actual lang. card offset
	mov	es:[bp],al		; Update the value in language card
Bank_Exit:
	Restore es			; Restore the required registers
	ret				; Return to the caller
Lang_Bank	Endp			; End of the Lang_Bank procedure
	Subttl	Lang_Segment	Language Card Segment Write Routine
	Page	+
;******************************************************************************
;
;	Lang_Segment(Effective_Address, Value)
;
;		Save the required registers
;		Get the current write slot value
;		Get the language card segment for this slot
;		If this card is currently write enabled
;			If read slot matches this write slot
;				Move value into RAM space (Effective address)
;			Endif
;			Get the current write segment offset
;			Compute the actual write address
;			Move value into language card space
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_Segment	Proc	Near		; Language card segment write procedure
	Save	es			; Save the required registers
	mov	bp,cs:[Write_Slot]	; Get the current write slot index
	mov	es,cs:[Lang_Data + bp]	; Get language card segment for slot
	test	es:[Lang_Flag],WRITE_ENABLE
	jz	Segment_Exit		; Jump if card is NOT write enabled
	cmp	bp,cs:[Read_Slot]	; Compare to current read slot index
	jne	Update_Segment		; Jump if slots are not the same
	mov	ds:[di],al		; Update the value in RAM space
Update_Segment:
	mov	bp,di			; Get the effective address offset
	sub	bp,START_SEG Shl 8	; Compute zero-based offset value
	add	bp,cs:[Write_Seg]	; Compute the actual lang. card offset
	mov	es:[bp],al		; Update the value in language card
Segment_Exit:
	Restore es			; Restore the required registers
	ret				; Return to the caller
Lang_Segment	Endp			; End of the Lang_Segment procedure
	Subttl	Lang_0		Location C0x0h Routine
	Page	+
;******************************************************************************
;
;	Lang_0(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		AX-BX - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_0		Proc	Near		; Language card C0x0h procedure
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	and	es:[Lang_Flag],Not WRITE_ENABLE
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_0		; Jump if this is a read change
	jz	Lang_0_Exit		; Jump if no changes have been made
Continue_0:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_0:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_0		; Jump if this is a read change
	jz	Check_Seg_0		; Jump if no bank change is required
Copy_Bank_0:
	lea	si,es:[Seg_1_Bank_2]	; Get pointer to seg. 1 bank 2 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 1 bank 2 to the RAM space
Check_Seg_0:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_0		; Jump if this is a read change
	jz	Lang_0_Done		; Jump if no segment change made
Copy_RAM_0:
	lea	si,es:[Seg_1_RAM]	; Get pointer to segment 1 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 1 to the RAM space
Lang_0_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_0_Exit:
	ret				; Return to the caller
Lang_0		Endp			; End of the Lang_0 procedure
	Subttl	Lang_1		Location C0x1h Routine
	Page	+
;******************************************************************************
;
;	Lang_1(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 1
;			Set write bank to bank 2
;		Endif
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_1		Proc	Near		; Language card C0x1h procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_1			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_1_RAM
	mov	cs:[Write_Bank],Seg_1_Bank_2
Skip_1:
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_1_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_1_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_1_Exit:
	ret				; Return to the caller
Lang_1		Endp			; End of the Lang_1 procedure
	Subttl	Lang_2		Location C0x2h Routine
	Page	+
;******************************************************************************
;
;	Lang_2(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_2		Proc	Near		; Language card C0x2h procedure
	and	es:[Lang_Flag],Not WRITE_ENABLE
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_2_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_2_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_2_Exit:
	ret				; Retuen to the caller
Lang_2		Endp			; End of the Lang_2 procedure
	Subttl	Lang_3		Location C0x3h Routine
	Page	+
;******************************************************************************
;
;	Lang_3(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 1
;			Set write bank to bank 2
;		Endif
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_3		Proc	Near		; Language card C0x3h procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_3			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_1_RAM
	mov	cs:[Write_Bank],Seg_1_Bank_2
Skip_3:
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_3		; Jump if this is a read change
	jz	Lang_3_Exit		; Jump if no changes have been made
Continue_3:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_3:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_3		; Jump if this is a read change
	jz	Check_Seg_3		; Jump if no bank change is required
Copy_Bank_3:
	lea	si,es:[Seg_1_Bank_2]	; Get pointer to seg. 1 bank 2 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 1 bank 2 to the RAM space
Check_Seg_3:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_3		; Jump if this is a read change
	jz	Lang_3_Done		; Jump if no segment change made
Copy_RAM_3:
	lea	si,es:[Seg_1_RAM]	; Get pointer to segment 1 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 1 to the RAM space
Lang_3_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_3_Exit:
	ret				; Return to the caller
Lang_3		Endp			; End of the Lang_3 procedure
	Subttl	Lang_4		Location C0x4h Routine
	Page	+
;******************************************************************************
;
;	Lang_4(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_4		Proc	Near		; Language card C0x4h procedure
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	and	es:[Lang_Flag],Not WRITE_ENABLE
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_4		; Jump if this is a read change
	jz	Lang_4_Exit		; Jump if no changes have been made
Continue_4:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_4:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_4		; Jump if this is a read change
	jz	Check_Seg_4		; Jump if no bank change is required
Copy_Bank_4:
	lea	si,es:[Seg_2_Bank_2]	; Get pointer to seg. 2 bank 2 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 2 bank 2 to the RAM space
Check_Seg_4:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_4		; Jump if this is a read change
	jz	Lang_4_Done		; Jump if no segment change made
Copy_RAM_4:
	lea	si,es:[Seg_2_RAM]	; Get pointer to segment 2 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 2 to the RAM space
Lang_4_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_4_Exit:
	ret				; Return to the caller
Lang_4		Endp			; End of the Lang_4 procedure
	Subttl	Lang_5		Location C0x5h Routine
	Page	+
;******************************************************************************
;
;	Lang_5(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 2
;			Set write bank to bank 2
;		Endif
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_5		Proc	Near		; Language card C0x5h procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_5			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_2_RAM
	mov	cs:[Write_Bank],Seg_2_Bank_2
Skip_5:
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_5_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_5_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_5_Exit:
	ret				; Return to the caller
Lang_5		Endp			; End of the Lang_5 procedure
	Subttl	Lang_6		Location C0x6h Routine
	Page	+
;******************************************************************************
;
;	Lang_6(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_6		Proc	Near		; Language card C0x6h procedure
	and	es:[Lang_Flag],Not WRITE_ENABLE
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_6_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_6_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_6_Exit:
	ret				; Retuen to the caller
Lang_6		Endp			; End of the Lang_6 procedure
	Subttl	Lang_7		Location C0x7h Routine
	Page	+
;******************************************************************************
;
;	Lang_7(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 2
;			Set write bank to bank 2
;		Endif
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_7		Proc	Near		; Language card C0x7h procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_7			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_2_RAM
	mov	cs:[Write_Bank],Seg_2_Bank_2
Skip_7:
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_7		; Jump if this is a read change
	jz	Lang_7_Exit		; Jump if no changes have been made
Continue_7:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_7:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_7		; Jump if this is a read change
	jz	Check_Seg_7		; Jump if no bank change is required
Copy_Bank_7:
	lea	si,es:[Seg_2_Bank_2]	; Get pointer to seg. 2 bank 2 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 2 bank 2 to the RAM space
Check_Seg_7:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_7		; Jump if this is a read change
	jz	Lang_7_Done		; Jump if no segment change made
Copy_RAM_7:
	lea	si,es:[Seg_2_RAM]	; Get pointer to segment 2 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 2 to the RAM space
Lang_7_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_7_Exit:
	ret				; Return to the caller
Lang_7		Endp			; End of the Lang_7 procedure
	Subttl	Lang_8		Location C0x8h Routine
	Page	+
;******************************************************************************
;
;	Lang_8(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_8		Proc	Near		; Language card C0x8h procedure
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	and	es:[Lang_Flag],Not WRITE_ENABLE
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_8		; Jump if this is a read change
	jz	Lang_8_Exit		; Jump if no changes have been made
Continue_8:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_8:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_8		; Jump if this is a read change
	jz	Check_Seg_8		; Jump if no bank change is required
Copy_Bank_8:
	lea	si,es:[Seg_1_Bank_1]	; Get pointer to seg. 1 bank 1 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 1 bank 1 to the RAM space
Check_Seg_8:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_8		; Jump if this is a read change
	jz	Lang_8_Done		; Jump if no segment change made
Copy_RAM_8:
	lea	si,es:[Seg_1_RAM]	; Get pointer to segment 1 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 1 to the RAM space
Lang_8_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_8_Exit:
	ret				; Return to the caller
Lang_8		Endp			; End of the Lang_8 procedure
	Subttl	Lang_9		Location C0x9h Routine
	Page	+
;******************************************************************************
;
;	Lang_9(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 1
;			Set write bank to bank 1
;		Endif
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_9		Proc	Near		; Language card C0x9h procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_9			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_1_RAM
	mov	cs:[Write_Bank],Seg_1_Bank_1
Skip_9:
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_9_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_9_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_9_Exit:
	ret				; Return to the caller
Lang_9		Endp			; End of the Lang_9 procedure
	Subttl	Lang_A		Location C0xAh Routine
	Page	+
;******************************************************************************
;
;	Lang_A(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_A		Proc	Near		; Language card C0xAh procedure
	and	es:[Lang_Flag],Not WRITE_ENABLE
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_A_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_A_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_A_Exit:
	ret				; Retuen to the caller
Lang_A		Endp			; End of the Lang_A procedure
	Subttl	Lang_B		Location C0xBh Routine
	Page	+
;******************************************************************************
;
;	Lang_B(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 1
;			Set write bank to bank 1
;		Endif
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_B		Proc	Near		; Language card C0xBh procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_B			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_1_RAM
	mov	cs:[Write_Bank],Seg_1_Bank_1
Skip_B:
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_B		; Jump if this is a read change
	jz	Lang_B_Exit		; Jump if no changes have been made
Continue_B:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_B:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_B		; Jump if this is a read change
	jz	Check_Seg_B		; Jump if no bank change is required
Copy_Bank_B:
	lea	si,es:[Seg_1_Bank_1]	; Get pointer to seg. 1 bank 1 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 1 bank 1 to the RAM space
Check_Seg_B:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_B		; Jump if this is a read change
	jz	Lang_B_Done		; Jump if no segment change made
Copy_RAM_B:
	lea	si,es:[Seg_1_RAM]	; Get pointer to segment 1 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 1 to the RAM space
Lang_B_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_B_Exit:
	ret				; Return to the caller
Lang_B		Endp			; End of the Lang_B procedure
	Subttl	Lang_C		Location C0xCh Routine
	Page	+
;******************************************************************************
;
;	Lang_C(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_C		Proc	Near		; Language card C0xCh procedure
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	and	es:[Lang_Flag],Not WRITE_ENABLE
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_C		; Jump if this is a read change
	jz	Lang_C_Exit		; Jump if no changes have been made
Continue_C:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_C:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_C		; Jump if this is a read change
	jz	Check_Seg_C		; Jump if no bank change is required
Copy_Bank_C:
	lea	si,es:[Seg_2_Bank_1]	; Get pointer to seg. 2 bank 1 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 2 bank 1 to the RAM space
Check_Seg_C:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_C		; Jump if this is a read change
	jz	Lang_C_Done		; Jump if no segment change made
Copy_RAM_C:
	lea	si,es:[Seg_2_RAM]	; Get pointer to segment 2 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 2 to the RAM space
Lang_C_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_C_Exit:
	ret				; Return to the caller
Lang_C		Endp			; End of the Lang_C procedure
	Subttl	Lang_D		Location C0xDh Routine
	Page	+
;******************************************************************************
;
;	Lang_D(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 2
;			Set write bank to bank 1
;		Endif
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_D		Proc	Near		; Language card C0xDh procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_D			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_2_RAM
	mov	cs:[Write_Bank],Seg_2_Bank_1
Skip_D:
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_D_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_D_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_D_Exit:
	ret				; Return to the caller
Lang_D		Endp			; End of the Lang_D procedure
	Subttl	Lang_E		Location C0xEh Routine
	Page	+
;******************************************************************************
;
;	Lang_E(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		Clear the write enable flag
;		If read enable flag is set
;			Clear the read enable flag
;			Set read slot value to ROM
;			Restore the ROM image from save area
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_E		Proc	Near		; Language card C0xEh procedure
	and	es:[Lang_Flag],Not WRITE_ENABLE
	test	es:[Lang_Flag],READ_ENABLE
	jz	Lang_E_Exit		; Jump if not currently read enabled
	Save	cx,si,di,ds,es		; Save the required registers
	and	es:[Lang_Flag],Not READ_ENABLE
	mov	cs:[Read_Slot],ROM_SLOT ; Set read slot to ROM slot value
	mov	si,ds			; Get RAM space segment value
	mov	es,si			; Set ES to RAM space segment
	mov	ds,cs:[ROM_Save]	; Get ROM save area segment value
	xor	si,si			; Zero the source index value
	mov	di,START_PAGE Shl 8	; Set DI to the starting page offset
	mov	cx,TOTAL_SIZE Shr 1	; Set CX to the number of words to move
	rep	movsw			; Restore the ROM to the RAM space
Lang_E_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_E_Exit:
	ret				; Retuen to the caller
Lang_E		Endp			; End of the Lang_E procedure
	Subttl	Lang_F		Location C0xFh Routine
	Page	+
;******************************************************************************
;
;	Lang_F(Old_Control, New_Control, RAM_Space, Lang_Segment, Slot_Index)
;
;		Save the required registers
;		If previous control was write enable
;			Set the write enable flag
;			Set write slot value to slot index
;			Set write segment to segment 2
;			Set write bank to bank 1
;		Endif
;		Set the read enable flag
;		Set read slot value to slot index
;		Compute the changed control bits
;		If bank select has changed
;			Update the bank area in RAM space
;		Endif for bank select
;		If segment select has changed
;			Update the segment area in RAM space
;		Endif for segment select
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Language card segment
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Lang_F		Proc	Near		; Language card C0xFh procedure
	test	ah,WRITE_SELECT 	; Check for second write enable request
	jz	Skip_F			; Jump if NOT the second write enable
	or	es:[Lang_Flag],WRITE_ENABLE
	mov	cs:[Write_Slot],bp	; Set write slot to slot index
	mov	cs:[Write_Seg],Seg_2_RAM
	mov	cs:[Write_Bank],Seg_2_Bank_1
Skip_F:
	mov	bh,es:[Lang_Flag]	; Get the current language card flags
	and	bh,READ_ENABLE		; Mask off all but the read enable bit
	mov	bl,READ_ENABLE		; Get new read enable bit state
	or	ax,bx			; Logically OR in read enable state
	or	es:[Lang_Flag],READ_ENABLE
	mov	cs:[Read_Slot],bp	; Set read slot to slot index value
	xor	ah,al			; Compute the changed control bits
	js	Continue_F		; Jump if this is a read change
	jz	Lang_F_Exit		; Jump if no changes have been made
Continue_F:
	Save	cx,si,di,ds,es		; Save the required registers
	mov	si,ds			; Get RAM space segment value
	mov	di,es			; Get language card segment value
	mov	ds,di			; Set DS to language card segment
	mov	es,si			; Set ES to RAM space segment
Check_Bank_F:
	test	ah,READ_ENABLE+SEG_CHANGE+BANK_CHANGE
	js	Copy_Bank_F		; Jump if this is a read change
	jz	Check_Seg_F		; Jump if no bank change is required
Copy_Bank_F:
	lea	si,es:[Seg_2_Bank_1]	; Get pointer to seg. 2 bank 1 area
	mov	di,START_BANK Shl 8	; Set DI to starting bank page offset
	mov	cx,BANK_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move seg. 2 bank 1 to the RAM space
Check_Seg_F:
	test	ah,READ_ENABLE+SEG_CHANGE
	js	Copy_RAM_F		; Jump if this is a read change
	jz	Lang_F_Done		; Jump if no segment change made
Copy_RAM_F:
	lea	si,es:[Seg_2_RAM]	; Get pointer to segment 2 RAM area
	mov	di,START_SEG Shl 8	; Set DI to starting segment page offset
	mov	cx,MAIN_SIZE Shr 1	; Set CX to number of words to move
	rep	movsw			; Move segment 2 to the RAM space
Lang_F_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Lang_F_Exit:
	ret				; Return to the caller
Lang_F		Endp			; End of the Lang_F procedure
;******************************************************************************
;
;	Define the language card data areas
;
;******************************************************************************
Lang_Data	Equ	This Word	; Define the langauge card pointers
		Slot_Data	<>	; Pointers to the language data areas
ROM_Save	Equ	This Word	; Define the ROM save area pointer
		Dw	0000h		; Pointer to ROM save segment
Read_Slot	Equ	This Word	; Define the read slot pointer
		Dw	ROM_SLOT	; Default read pointer to ROM area
Write_Slot	Equ	This Word	; Define the write slot pointer
		Dw	0000h		; Default write pointer to slot 0
Write_Seg	Equ	This Word	; Define the write segment offset value
		Dw	Seg_1_RAM	; Default offset to segment 1
Write_Bank	Equ	This Word	; Define the write bank offset value
		Dw	Seg_1_Bank_1	; Default offset to segment 1 bank 1
Lang_Table	Equ	This Word	; Define the language card jump table
		Dw	Lang_0		; Location C0x0h routine address
		Dw	Lang_1		; Location C0x1h routine address
		Dw	Lang_2		; Location C0x2h routine address
		Dw	Lang_3		; Location C0x3h routine address
		Dw	Lang_4		; Location C0x4h routine address
		Dw	Lang_5		; Location C0x5h routine address
		Dw	Lang_6		; Location C0x6h routine address
		Dw	Lang_7		; Location C0x7h routine address
		Dw	Lang_8		; Location C0x8h routine address
		Dw	Lang_9		; Location C0x9h routine address
		Dw	Lang_A		; Location C0xAh routine address
		Dw	Lang_B		; Location C0xBh routine address
		Dw	Lang_C		; Location C0xCh routine address
		Dw	Lang_D		; Location C0xDh routine address
		Dw	Lang_E		; Location C0xEh routine address
		Dw	Lang_F		; Location C0xFh routine address
Lang_ID 	Equ	This Byte	; Langauge card ID string
		Db	"Langauge Card",0
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Language module

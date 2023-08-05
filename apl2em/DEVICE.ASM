	Page	58,132
	Title	DEVICE.ASM	Apple Expansion Slot Devices
;******************************************************************************
;
;   Name:	DEVICE.ASM	Apple Expansion Slot Devices
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
;	expansion slot devices.
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
	Public	Device_Init		; Expansion slot device initialization
	Public	Slot_Address		; Expansion slot address routine
	Public	Exp_Slot_Read		; Expansion slot read routine
	Public	Exp_Slot_Write		; Expansion slot write routine
	Public	Exp_Mem_Read		; Expansion memory read routine
	Public	Exp_Mem_Write		; Expansion memory write routine
;
;  External Declarations
;
	Extrn	Slot_Init:Word		; Expansion slot init. table	 (DATA)
	extrn	Slot_Ctrl:Word		; Expansion slot control table	 (DATA)
	Extrn	Mem_Read:Word		; Exp. slot memory read table	 (DATA)
	Extrn	Mem_Write:Word		; Exp. slot memory write table	 (DATA)
	Extrn	Exp_Read:Word		; Expansion memory read table	 (DATA)
	Extrn	Exp_Write:Word		; Expansion memory write table	 (DATA)
	Extrn	Current_Slot:Byte	; Current active expansion slot  (DATA)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
;
;  LOCAL Equates
;
SLOT_MASK	Equ	0Fh		; Expansion slot mask value
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
	Subttl	Device_Init	Expansion Slot Device Initialization
	Page	+
;******************************************************************************
;
;	Device_Init(RAM_Space)
;
;		Set Slot_Counter to Zero
;		While Slot_Counter < Slot_Max (8)
;			Call current slot initialization routine
;			Increment Slot_Counter
;		EndWhile
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Device_Init	Proc	Near		; Expansion slot device init. procedure
	xor	ax,ax			; Zero the slot counter value
Slot_Loop:
	mov	bx,ax			; Get the current slot number
	shl	bx,1			; Convert slot number to table index
	Save	ax			; Save the current slot number
	call	cs:[bx + Slot_Init]	; Call device initialization routine
	Restore ax			; Restore the current slot number
	inc	ax			; Increment the current slot number
	cmp	ax,SLOT_MAX		; Check current slot number against max.
	jne	Slot_Loop		; Jump if more slots to initialize
	ret				; Return to the caller
Device_Init	Endp			; End of the Device_Init procedure
	Subttl	Slot_Address	Expansion Slot Address
	Page	+
;******************************************************************************
;
;	Slot_Address(Slot_Number)
;
;		Logically OR in the hardware page number
;		Calculate the actual slot address
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Slot number
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		SI    - Slot address
;
;******************************************************************************
		Even			; Force procedure to even address
Slot_Address	Proc	Near		; Expansion slot address procedure
	or	al,HARDWARE_PAGE	; Logically OR in the hardware page
	xchg	al,ah			; Calculate the actual page address
	mov	si,ax			; Move actual page address to SI
	ret				; Return to the caller
Slot_Address	Endp			; End of the Slot_Address procedure
	Subttl	Exp_Slot_Read	Expansion Slot Read
	Page	+
;******************************************************************************
;
;	Exp_Slot_Read(Effective_Address)
;
;		Isolate the slot number being read
;		Jump to correct routine to handle read
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
Exp_Slot_Read	Proc	Near		; Expansion slot read procedure
	mov	ax,di			; Get the effective address
	mov	al,ah			; Move MSB of address into AL register
	and	al,SLOT_MASK		; Mask off all but the slot number
	xor	ah,ah			; Convert slot number to full word
	shl	ax,1			; Convert slot number to table index
	mov	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + Mem_Read]	; Jump to correct routine to read
	ret				; Return to the caller (Never Executed)
Exp_Slot_Read	Endp			; End of the Exp_Slot_Read procedure
	Subttl	Exp_Slot_Write	Expansion Slot Write
	Page	+
;******************************************************************************
;
;	Exp_Slot_Write(Effective_Address, Value)
;
;		Isolate the slot number being written
;		Jump to correct routine to handle write
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
Exp_Slot_Write	Proc	Near		; Expansion slot write procedure
	mov	bp,ax			; Save the memory value in BP register
	mov	ax,di			; Get the effective address
	mov	al,ah			; Move MSB of address into AL register
	and	al,SLOT_MASK		; Mask off all but the slot number
	xor	ah,ah			; Convert slot number to full word
	shl	ax,1			; Convert slot number to table index
	xchg	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + Mem_Write]	; Jump to correct routine to read
	ret				; Return to the caller
Exp_Slot_Write	Endp			; End of the Exp_Slot_Write procedure
	Subttl	Exp_Mem_Read	Expansion Memory Read
	Page	+
;******************************************************************************
;
;	Exp_Mem_Read(Effective_Address)
;
;		Get the current slot number
;		Jump to correct routine to handle read
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
Exp_Mem_Read	Proc	Near		; Expansion memory read procedure
	mov	al,cs:[Current_Slot]	; Get the current active slot number
	xor	ah,ah			; Convert slot number to full word
	shl	ax,1			; Convert slot number to table index
	mov	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + Exp_Read]	; Jump to correct routine to read
	ret				; Return to the caller (Never Executed)
Exp_Mem_Read	Endp			; End of the Exp_Mem_Read procedure
	Subttl	Exp_Mem_Write	Expansion Memory Write
	Page	+
;******************************************************************************
;
;	Exp_Mem_Write(Effective_Address, Value)
;
;		Get the current slot number
;		Jump to correct routine to handle write
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
Exp_Mem_Write	Proc	Near		; Expansion memory write procedure
	mov	bp,ax			; Save memory value in BP register
	mov	al,cs:[Current_Slot]	; Get the current active slot number
	xor	ah,ah			; Convert slot number to full word
	shl	ax,1			; Convert slot number to table index
	xchg	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + Exp_Write]	; Jump to correct routine to read
	ret				; Return to the caller (Never Executed)
Exp_Mem_Write	Endp			; End of the Exp_Mem_Write procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Device module

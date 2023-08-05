	Page	58,132
	Title	HARDWARE.ASM	Hardware Page Access Routines
;******************************************************************************
;
;   Name:	HARDWARE.ASM	Hardware Page Access Routines
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
;		This module contains all the code for the Apple hardware
;	page access routines.
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
	Public	Hardware_Read		; Hardware page read routine
	Public	Hardware_Write		; Hardware page write routine
	Public	Utility_Strobe		; Apple utility strobe routine
	Public	Output_0_Off		; Annunciator output 0 off routine
	Public	Output_0_On		; Annunciator output 0 on routine
	Public	Output_1_Off		; Annunciator output 1 off routine
	Public	Output_1_On		; Annunciator output 1 on routine
	Public	Output_2_Off		; Annunciator output 2 off routine
	Public	Output_2_On		; Annunciator output 2 on routine
	Public	Output_3_Off		; Annunciator output 3 off routine
	Public	Output_3_On		; Annunciator output 3 on routine
	Public	Do_Nothing		; Do nothing routine
;
;  External Declarations
;
	Extrn	Slot_Read:Word		; Expansion slot read table	 (DATA)
	Extrn	Slot_Write:Word 	; Expansion slot write table	 (DATA)
	Extrn	IO_Read_Table:Word	; I/O read table		 (DATA)
	Extrn	IO_Write_Table:Word	; I/O write table		 (DATA)
	Extrn	Current_Slot:Byte	; Current active slot number	 (DATA)
;
;  LOCAL Equates
;
CARD_MASK	Equ	07h		; Card slot mask value
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
	Subttl	Hardware_Read	Hardware Page Read
	Page	+
;******************************************************************************
;
;	Hardware_Read(Effective_Address)
;
;		If this is a card slot I/O access
;			Isolate the card slot number
;			Update the current active slot number
;			Jump to correct routine to process
;		Else this is NOT card slot I/O
;			Isolate the memory location address
;			Jump to correct routine to process
;		Endif
;		Return to the caller (Never executed)
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Hardware_Read	Proc	Near		; Hardware page read procedure
	mov	ax,di			; Get the effective address
	or	al,al			; Check for card slot I/O
	js	Card_Read		; Jump if this is card slot I/O
	xor	ah,ah			; Convert address to full word
	shl	ax,1			; Convert address to table index
	mov	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + IO_Read_Table] ; Jump to correct routine to process
Card_Read:
	shr	al,4			; Right justify the card slot value
	and	al,CARD_MASK		; Mask off all but card slot value
	mov	cs:[Current_Slot],al	; Update the current active slot
	xor	ah,ah			; Convert slot number to full word
	shl	ax,1			; Convert slot number to table index
	mov	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + Slot_Read]	; Jump to correct routine to process
	ret				; Return to the caller (Never Executed)
Hardware_Read	Endp			; End of the Hardware_Read procedure
	Subttl	Hardware_Write	Hardware Page Write
	Page	+
;******************************************************************************
;
;	Hardware_Write(Effective_Address, Value)
;
;		Save the required registers
;		If this is a card slot I/O access
;			Isolate the card slot number
;			Update the current active slot number
;			Restore the required registers
;			Jump to correct routine to process
;		Else this is NOT card slot I/O
;			Isolate the memory location address
;			Restore the required registers
;			Jump to correct routine to process
;		Endif
;		Return to the caller (Never executed)
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
Hardware_Write	Proc	Near		; Hardware page write procedure
	Save	ax			; Save the required registers
	mov	ax,di			; Get the effective address
	or	al,al			; Check for card slot I/O
	js	Card_Write		; Jump if this is card slot I/O
	xor	ah,ah			; Convert address to full word
	shl	ax,1			; Convert address to table index
	mov	bp,ax			; Setup to jump to correct routine
	Restore ax			; Restore the required registers
	jmp	cs:[bp + IO_Write_Table]; Jump to correct routine to process
Card_Write:
	shr	al,4			; Right justify the card slot value
	and	al,CARD_MASK		; Mask off all but card slot value
	mov	cs:[Current_Slot],al	; Update the current active slot
	xor	ah,ah			; Convert slot number to full word
	shl	ax,1			; Convert slot number to table index
	mov	bp,ax			; Setup to jump to correct routine
	Restore ax			; Restore the required registers
	jmp	cs:[bp + Slot_Write]	; Jump to correct routine to process
	ret				; Return to the caller (Never Executed)
Hardware_Write	Endp			; End of the Hardware_Write procedure
	Subttl	Utility_Strobe	Apple Utility Strobe Routine
	Page	+
;******************************************************************************
;
;	Utility_Strobe()
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
Utility_Strobe	Proc	Near		; Utility strobe procedure

	ret				; Return to the caller
Utility_Strobe	Endp			; End of the Utility_Strobe procedure
	Subttl	Output_0_Off	Annunciator Output 0 Off Routine
	Page	+
;******************************************************************************
;
;	Output_0_Off()
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
Output_0_Off	Proc	Near		; Annunciator output 0 off procedure

	ret				; Return to the caller
Output_0_Off	Endp			; End of the Output_0_Off procedure
	Subttl	Output_0_On	Annunciator Output 0 On Routine
	Page	+
;******************************************************************************
;
;	Output_0_On()
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
Output_0_On	Proc	Near		; Annunciator output 0 on procedure

	ret				; Return to the caller
Output_0_On	Endp			; End of the Output_0_On procedure
	Subttl	Output_1_Off	Annunciator Output 1 Off Routine
	Page	+
;******************************************************************************
;
;	Output_1_Off()
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
Output_1_Off	Proc	Near		; Annunciator output 1 off procedure

	ret				; Return to the caller
Output_1_Off	Endp			; End of the Output_1_Off procedure
	Subttl	Output_1_On	Annunciator Output 1 On Routine
	Page	+
;******************************************************************************
;
;	Output_1_On()
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
Output_1_On	Proc	Near		; Annunciator output 1 on procedure

	ret				; Return to the caller
Output_1_On	Endp			; End of the Output_1_On procedure
	Subttl	Output_2_Off	Annunciator Output 2 Off Routine
	Page	+
;******************************************************************************
;
;	Output_2_Off()
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
Output_2_Off	Proc	Near		; Annunciator output 2 off procedure

	ret				; Return to the caller
Output_2_Off	Endp			; End of the Output_2_Off procedure
	Subttl	Output_2_On	Annunciator Output 2 On Routine
	Page	+
;******************************************************************************
;
;	Output_2_On()
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
Output_2_On	Proc	Near		; Annunciator output 2 on procedure

	ret				; Return to the caller
Output_2_On	Endp			; End of the Output_2_On procedure
	Subttl	Output_3_Off	Annunciator Output 3 Off Routine
	Page	+
;******************************************************************************
;
;	Output_3_Off()
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
Output_3_Off	Proc	Near		; Annunciator output 3 off procedure

	ret				; Return to the caller
Output_3_Off	Endp			; End of the Output_3_Off procedure
	Subttl	Output_3_On	Annunciator Output 3 On Routine
	Page	+
;******************************************************************************
;
;	Output_3_On()
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
Output_3_On	Proc	Near		; Annunciator output 3 on procedure

	ret				; Return to the caller
Output_3_On	Endp			; End of the Output_3_On procedure
	Subttl	Do_Nothing	Do nothing Routine
	Page	+
;******************************************************************************
;
;	Do_Nothing()
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
Do_Nothing	Proc	Near		; Do nothing procedure
	ret				; Return to the caller
Do_Nothing	Endp			; End of the Do_Nothing procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Hardware module

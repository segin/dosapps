	Page	58,132
	Title	EMPTY.ASM	Empty Slot Routines
;******************************************************************************
;
;   Name:	EMPTY.ASM	Empty Slot Routines
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
;	empty slots.
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
	Public	Empty_ID		; Empty slot ID string
	Public	Empty_Init		; Empty slot initialization routine
	Public	Empty_Ctrl		; Empty slot control routine
	Public	Empty_Rd		; Empty slot read routine
	Public	Empty_Wrt		; Empty slot write routine
	Public	Empty_Mem_Rd		; Empty slot memory read routine
	Public	Empty_Mem_Wrt		; Empty slot memory write routine
	Public	Empty_Exp_Rd		; Empty slot expansion read routine
	Public	Empty_Exp_Wrt		; Empty slot expansion write routine
;
;  External Declarations
;
	Extrn	Slot_Address:Near	; Get expansion slot address   (DEVICE)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
;
;  LOCAL Equates
;
;		equ	  h		;
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
Emulate Segment Word public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	Empty_Init	Empty Slot Initialization
	Page	+
;******************************************************************************
;
;	Empty_Init(RAM_Space, Slot_Number)
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
Empty_Init	Proc	Near		; Empty slot initialization procedure
	ret				; Return to the caller
Empty_Init	Endp			; End of the Empty_Init procedure
	Subttl	Empty_Ctrl	Empty Slot Control
	Page	+
;******************************************************************************
;
;	Empty_Ctrl(RAM_Space, Slot_Number)
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
Empty_Ctrl	Proc	Near		; Empty slot control procedure
	ret				; Return to the caller
Empty_Ctrl	Endp			; End of the Empty_Ctrl procedure
	Subttl	Empty_Rd	Empty Slot Read
	Page	+
;******************************************************************************
;
;	Empty_Rd(Effective_Address)
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
Empty_Rd	Proc	Near		; Empty slot read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Empty_Rd	Endp			; End of the Empty_Rd procedure
	Subttl	Empty_Wrt	Empty Slot Write
	Page	+
;******************************************************************************
;
;	Empty_Wrt(Effective_Address)
;
;		Write value to memory location value (Byte)
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
Empty_Wrt	Proc	Near		; Empty slot write procedure
	mov	ds:[di],al		; Write the memory location
	ret				; Return to the caller
Empty_Wrt	Endp			; End of the Empty_Wrt procedure
	Subttl	Empty_Mem_Rd	Empty Slot Memory Read
	Page	+
;******************************************************************************
;
;	Empty_Mem_Rd(Effective_Address)
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
Empty_Mem_Rd	Proc	Near		; Empty slot memory read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Empty_Mem_Rd	Endp			; End of the Empty_Mem_Rd procedure
	Subttl	Empty_Mem_Wrt	Empty Slot Memory Write
	Page	+
;******************************************************************************
;
;	Empty_Mem_Wrt(Effective_Address)
;
;		Write value to memory location value (Byte)
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
Empty_Mem_Wrt	Proc	Near		; Empty slot memory write procedure
	mov	ds:[di],al		; Write the memory location
	ret				; Return to the caller
Empty_Mem_Wrt	Endp			; End of the Empty_Mem_Wrt procedure
	Subttl	Empty_Exp_Rd	Empty Slot Expansion Read
	Page	+
;******************************************************************************
;
;	Empty_Exp_Rd(Effective_Address)
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
Empty_Exp_Rd	Proc	Near		; Empty slot expansion read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Empty_Exp_Rd	Endp			; End of the Empty_Exp_Rd procedure
	Subttl	Empty_Exp_Wrt	Empty Slot Expansion Write
	Page	+
;******************************************************************************
;
;	Empty_Exp_Wrt(Effective_Address)
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
Empty_Exp_Wrt	Proc	Near		; Empty slot expansion write procedure
	ret				; Return to the caller
Empty_Exp_Wrt	Endp			; End of the Empty_Exp_Wrt procedure
	Page
;******************************************************************************
;
;	Define the empty slot data structures
;
;******************************************************************************
Empty_ID	Equ	This Byte	; Empty slot ID string
		Db	"Empty Slot",0
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Empty module

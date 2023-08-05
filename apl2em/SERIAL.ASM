	Page	58,132
	Title	SERIAL.ASM	Serial Port Controller
;******************************************************************************
;
;   Name:	SERIAL.ASM	Serial Port Controller
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
;	serial port controller.
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
	Public	Serial_ID		; Serial port ID string
	Public	Serial_Init		; Serial port initialize routine
	Public	Serial_Ctrl		; Serial port control routine
	Public	Serial_Rd		; Serial port read routine
	Public	Serial_Wrt		; Serial port write routine
	Public	Serial_Mem_Rd		; Serial port memory read routine
	Public	Serial_Mem_Wrt		; Serial port memory write routine
	Public	Serial_Exp_Rd		; Serial port expansion read routine
	Public	Serial_Exp_Wrt		; Serial port expansion write routine
	Public	Serial_Data		; Serial port data segment pointers
;
;  External Declarations
;
	Extrn	Slot_Address:Near	; Get expansion slot address   (DEVICE)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
;
;  LOCAL Equates
;
;		Equ	    h		;
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
	Subttl	Serial_Init	Serial Port Initialization
	Page	+
;******************************************************************************
;
;	Serial_Init(RAM_Space, Slot_Number)
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
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Serial_Init	Proc	Near		; Serial port initialization procedure

	ret				; Return to the caller
Serial_Init	Endp			; End of the Serial_Init procedure
	Subttl	Serial_Ctrl	Serial Port Control
	Page	+
;******************************************************************************
;
;	Serial_Ctrl(RAM_Space, Slot_Number)
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
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Serial_Ctrl	Proc	Near		; Serial port control procedure

	ret				; Return to the caller
Serial_Ctrl	Endp			; End of the Serial_Ctrl procedure
	Subttl	Serial_Rd	Serial Port Read
	Page	+
;******************************************************************************
;
;	Serial_Rd(Effective_Address, Slot_Index)
;
;
;		Return to the caller
;
;	Registers on Entry:
;
;		BP    - Slot index (Slot number * 2)
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Serial_Rd	Proc	Near		; Serial port read procedure

	ret				; Return to the caller
Serial_Rd	Endp			; End of the Serial_Rd procedure
	Subttl	Serial_Wrt	Serial Port Write
	Page	+
;******************************************************************************
;
;	Serial_Wrt(Effective_Address, Slot_Index)
;
;
;		Return to the caller
;
;	Registers on Entry:
;
;		BP    - Slot index (Slot number * 2)
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Serial_Wrt	Proc	Near		; Serial port write procedure

	ret				; Return to the caller
Serial_Wrt	Endp			; End of the Serial_Wrt procedure
	Subttl	Serial_Mem_Rd	Serial Port Memory Read
	Page	+
;******************************************************************************
;
;	Serial_Mem_Rd(Effective_Address)
;
;
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Serial_Mem_Rd	Proc	Near		; Serial port memory read procedure

	ret				; Return to the caller
Serial_Mem_Rd	Endp			; End of the Serial_Mem_Rd procedure
	Subttl	Serial_Mem_Wrt	Serial Port Memory Write
	Page	+
;******************************************************************************
;
;	Serial_Port_Wrt(Effective_Address)
;
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
Serial_Mem_Wrt	Proc	Near		; Serial port memory write procedure

	ret				; Return to the caller
Serial_Mem_Wrt	Endp			; End of the Serial_Mem_Wrt procedure
	Subttl	Serial_Exp_Rd	Serial Port Expansion Read
	Page	+
;******************************************************************************
;
;	Serial_Exp_Rd(Effective_Address)
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
Serial_Exp_Rd	Proc	Near		; Serial port expansion read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Serial_Exp_Rd	Endp			; End of the Serial_Exp_Rd procedure
	Subttl	Serial_Exp_Wrt	Serial Port Expansion Write
	Page	+
;******************************************************************************
;
;	Serial_Exp_Wrt(Effective_Address)
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
Serial_Exp_Wrt	Proc	Near		; Serial port expansion write procedure
	ret				; Return to the caller
Serial_Exp_Wrt	Endp			; End of the Serial_Exp_Wrt procedure
	Page
;******************************************************************************
;
;	Define the serial port data structures
;
;******************************************************************************
Serial_Data	Equ	This Word	; Define the serial port data pointers
		Slot_Data	<>	; Pointers to serial port data areas
Serial_ID	Equ	This Byte	; Serial port ID string
		Db	"Serial Port",0
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Serial module

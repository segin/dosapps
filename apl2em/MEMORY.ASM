	Page	58,132
	Title	MEMORY.ASM	Memory Access Routines
;******************************************************************************
;
;   Name:	MEMORY.ASM	Memory Access Routines
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
;		This module contains all the code for the standard
;	type memory accesses.
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
	Public	Memory_Init		; Memory initialization routine
	Public	STD_Mem_Read		; Standard memory read routine
	Public	STD_Mem_Write		; Standard memory write routine
	Public	ROM_Mem_Read		; ROM memory read routine
	Public	ROM_Mem_Write		; ROM memory write routine
	Public	Special_Read		; Special none selected read routine
	Public	Special_Write		; Special none selected write routine
;
;  LOCAL Equates
;
MEMORY_SIZE	Equ	8000h		; 65C02 RAM memory size (Words)
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
	Subttl	Memory_Init	Memory Initialization
	Page	+
;******************************************************************************
;
;	Memory_Init(RAM_Space)
;
;		Save the required registers
;		Zero all memory locations
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - RAM space
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Memory_Init	Proc	Near		; Memory initialization procedure
	Save	ax,cx,di,es		; Save the required registers
	mov	ax,ds			; Get the RAM space segment value
	mov	es,ax			; Setup ES to the RAM segment
	xor	ax,ax			; Setup to zero the memory locations
	mov	cx,MEMORY_SIZE		; Setup to zero all of memory
	xor	di,di			; Setup pointer to start of memory
	rep	stosw			; Store all zeros to the memory
	Restore ax,cx,di,es		; Restore the required registers
	ret				; Return to the caller
Memory_Init	Endp			; End of the Memory_Init procedure
	Subttl	STD_Mem_Read	Standard Memory Read
	Page	+
;******************************************************************************
;
;	STD_Mem_Read(Effective_Address)
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
STD_Mem_Read	Proc	Near		; Standard memory read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
STD_Mem_Read	Endp			; End of the STD_Mem_Read procedure
	Subttl	STD_Mem_Write	Standard Memory Write
	Page	+
;******************************************************************************
;
;	STD_Mem_Write(Effective_Address, Value)
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
;		None (Memory location updated)
;
;******************************************************************************
		Even			; Force procedure to even address
STD_Mem_Write	Proc	Near		; Standard memory write procedure
	mov	ds:[di],al		; Write the memory location
	ret				; Return to the caller
STD_Mem_Write	Endp			; End of the STD_Mem_Write procedure
	Subttl	ROM_Mem_Read	ROM Memory Read
	Page	+
;******************************************************************************
;
;	ROM_Mem_Read(Effective_Address)
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
ROM_Mem_Read	Proc	Near		; ROM memory read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
ROM_Mem_Read	Endp			; End of the ROM_Mem_Read procedure
	Subttl	ROM_Mem_Write	ROM Memory Write
	Page	+
;******************************************************************************
;
;	ROM_Mem_Write(Effective_Address, Value)
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
ROM_Mem_Write	Proc	Near		; ROM memory write procedure
	ret				; Return to the caller
ROM_Mem_Write	Endp			; End of the ROM_Mem_Write procedure
	Subttl	Special_Read	Special None Selected Read
	Page	+
;******************************************************************************
;
;	Special_Read(Effective_Address)
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
Special_Read	Proc	Near		; Special none selected read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Special_Read	Endp			; End of the Special_Read procedure
	Subttl	Special_Write	Special None Selected Write
	Page	+
;******************************************************************************
;
;	Special_Write(Effective_Address, Value)
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
;		None (Memory location updated)
;
;******************************************************************************
		Even			; Force procedure to even address
Special_Write	Proc	Near		; Special none selected write procedure
	mov	ds:[di],al		; Write the memory location
	ret				; Return to the caller
Special_Write	Endp			; End of the Special_Write procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Memory module

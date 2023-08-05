	Page	58,132
	Title	DEBUG.ASM	Apple Emulator Debugger
;******************************************************************************
;
;   Name:	DEBUG.ASM	Apple Emulator Debugger
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
;	emulator resident debugger.
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
	Public	Debug			; Apple emulator resident debugger
;
;  External Declarations
;
;	extrn				;				(     )
;
;  LOCAL Equates
;
;		Equ	  h		;
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
	Include 	StrucS.inc	; Include the structure definitions
	.286c				; Include 80286 instructions
	Page
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	Debug		Apple Emulator Debugger
	Page	+
;******************************************************************************
;
;	Debug(RAM_Space, Registers)
;
;		Save the required registers
;
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DL    - 65C02 Accumulator
;		DH    - 65C02 processor flags
;		CL    - 65C02 Y index register
;		CH    - 65C02 X index register
;		BX    - 65C02 Stack pointer
;		SI    - 65C02 Program counter
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Debug		Proc	Near		; Apple emulator debugger procedure

	ret				; Return to the caller
Debug		Endp			; End of the Debug procedure
	Subttl	Do_BAD		Bad Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_BAD()
;
;		Save the required registers
;
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
Do_BAD		Proc	Near		; Bad addressing mode procedure

	ret				; Return to the caller
Do_BAD		Endp			; End of the Do_BAD procedure
	Subttl	Do_NONE 	No Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_NONE()
;
;		Save the required registers
;
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
Do_NONE 	Proc	Near		; No addressing mode procedure

	ret				; Return to the caller
Do_NONE 	Endp			; End of the Do_NONE procedure
	Subttl	Do_IMM		Immediate Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_IMM()
;
;		Save the required registers
;
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
Do_IMM		Proc	Near		; Immediate addressing mode procedure

	ret				; Return to the caller
Do_IMM		Endp			; End of the Do_IMM procedure
	Subttl	Do_ABS		Absolute Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_ABS()
;
;		Save the required registers
;
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
Do_ABS		Proc	Near		; Absolute addressing mode procedure

	ret				; Return to the caller
Do_ABS		Endp			; End of the Do_ABS procedure
	Subttl	Do_DP		Direct Page Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_DP()
;
;		Save the required registers
;
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
Do_DP		Proc	Near		; Direct page addressing mode procedure

	ret				; Return to the caller
Do_DP		Endp			; End of the Do_DP procedure
	Subttl	Do_DIX		Direct Page Indexed X Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_DIX()
;
;		Save the required registers
;
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
Do_DIX		Proc	Near		; Direct page indexed X procedure

	ret				; Return to the caller
Do_DIX		Endp			; End of the Do_DIX procedure
	Subttl	Do_DIY		Direct Page Indexed Y Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_DIY()
;
;		Save the required registers
;
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
Do_DIY		Proc	Near		; Direct page indexed Y procedure

	ret				; Return to the caller
Do_DIY		Endp			; End of the Do_DIY procedure
	Subttl	Do_AIX		Absolute Indexed X Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_AIX()
;
;		Save the required registers
;
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
Do_AIX		Proc	Near		; Absolute indexed X procedure

	ret				; Return to the caller
Do_AIX		Endp			; End of the Do_AIX procedure
	Subttl	Do_AIY		Absolute Indexed Y Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_AIY()
;
;		Save the required registers
;
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
Do_AIY		Proc	Near		; Absolute indexed Y procedure

	ret				; Return to the caller
Do_AIY		Endp			; End of the Do_AIY procedure
	Subttl	Do_AI		Absolute Indirect Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_AI()
;
;		Save the required registers
;
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
Do_AI		Proc	Near		; Absolute indirect procedure

	ret				; Return to the caller
Do_AI		Endp			; End of the Do_AI procedure
	Subttl	Do_DI		Direct Page Indirect Addressing Mode Routine
	Page	+
;******************************************************************************
;
;	Do_DI()
;
;		Save the required registers
;
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
Do_DI		Proc	Near		; Direct page indirect procedure

	ret				; Return to the caller
Do_DI		Endp			; End of the Do_DI procedure
	Subttl	Do_AIIX 	Absolute Indexed Indirect X Addressing Routine
	Page	+
;******************************************************************************
;
;	Do_AIIX()
;
;		Save the required registers
;
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
Do_AIIX 	Proc	Near		; Absolute indexed indirect X procedure

	ret				; Return to the caller
Do_AIIX 	Endp			; End of the Do_AIIX procedure
	Subttl	Do_DIIX 	Direct Page Indexed Indirect X Mode Routine
	Page	+
;******************************************************************************
;
;	Do_DIIX()
;
;		Save the required registers
;
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
Do_DIIX 	Proc	Near		; Direct indexed indirect X procedure

	ret				; Return to the caller
Do_DIIX 	Endp			; End of the Do_DIIX procedure
	Subttl	Do_DIIY 	Direct Page Indexed Indirect Y Mode Routine
	Page	+
;******************************************************************************
;
;	Do_DIIY()
;
;		Save the required registers
;
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
Do_DIIY 	Proc	Near		; Direct indexed indirect Y procedure

	ret				; Return to the caller
Do_DIIY 	Endp			; End of the Do_DIIY procedure
	Subttl	Do_PCR		Program Counter Relative Addressing Routine
	Page	+
;******************************************************************************
;
;	Do_PCR()
;
;		Save the required registers
;
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
Do_PCR		Proc	Near		; PC relative addressing procedure

	ret				; Return to the caller
Do_PCR		Endp			; End of the Do_PCR procedure
;******************************************************************************
;
;	Define the 65C02 debugger addressing table
;
;******************************************************************************
	Even				; Force table to an even address
Address_Table	Equ	This Word	; 65C02 Opcode addressing table
	Address BAD,Do_BAD		; Illegal opcode addressing type
	Address NONE,Do_None		; No addressing type
	Address IMM,Do_IMM		; Immediate addressing type
	Address ABS,Do_ABS		; Absolute addressing type
	Address DP,Do_DP		; Direct page addressing type
	Address DIX,Do_DIX		; Direct page indexed with X type
	Address DIY,Do_DIY		; Direct page indexed with Y type
	Address AIX,Do_AIX		; Absolute indexed with X type
	Address AIY,Do_AIY		; Absolute indexed with Y type
	Address AI,Do_AI		; Absolute indirect addressing type
	Address DI,Do_DI		; Direct page indirect addressing type
	Address AIIX,Do_AIIX		; Absolute indexed indirect X type
	Address DIIX,Do_DIIX		; Direct page indexed indirect X type
	Address DIIY,Do_DIIY		; Direct page indexed indirect Y type
	Address PCR,Do_PCR		; Program counter relative
;******************************************************************************
;
;	Define the 65C02 debugger mnemonic table
;
;******************************************************************************
	Even				; Force table to an even address
Mnemonic_Table	Equ	This Byte	; 65C02 Opcode mnemonic table
	Mnemonic	ADC,<"ADC">     ; Add with carry mnemonic
	Mnemonic	AND,<"AND">     ; AND accumulator mnemonic
	Mnemonic	ASL,<"ASL">     ; Arithmetic shift left mnemonic
	Mnemonic	BAD,<"DB ">     ; Illegal opcode mnemonic
	Mnemonic	BCC,<"BCC">     ; Branch if carry clear mnemonic
	Mnemonic	BCS,<"BCS">     ; Branch if carry set mnemonic
	Mnemonic	BEQ,<"BEQ">     ; Branch if equal mnemonic
	Mnemonic	BIT,<"BIT">     ; Test bits mnemonic
	Mnemonic	BMI,<"BMI">     ; Branch if minus mnemonic
	Mnemonic	BNE,<"BNE">     ; Branch if not equal mnemonic
	Mnemonic	BPL,<"BPL">     ; Branch if plus mnemonic
	Mnemonic	BRA,<"BRA">     ; Branch always mnemonic
	Mnemonic	BRK,<"BRK">     ; Software break mnemonic
	Mnemonic	BVC,<"BVC">     ; Branch if overflow clear mnemonic
	Mnemonic	BVS,<"BVS">     ; Branch if overflow set mnemonic
	Mnemonic	CLC,<"CLC">     ; Branch if carry clear mnemonic
	Mnemonic	CLD,<"CLD">     ; Clear decimal mode mnemonic
	Mnemonic	CLI,<"CLI">     ; Clear interrupt disable mnemonic
	Mnemonic	CLV,<"CLV">     ; Clear overflow mnemonic
	Mnemonic	CMP,<"CMP">     ; Compare accumulator mnemonic
	Mnemonic	CPX,<"CPX">     ; Compare X register mnemonic
	Mnemonic	CPY,<"CPY">     ; Compare Y register mnemonic
	Mnemonic	DEC,<"DEC">     ; Decrement mnemonic
	Mnemonic	DEX,<"DEX">     ; Decrement X register mnemonic
	Mnemonic	DEY,<"DEY">     ; Decrement Y register mnemonic
	Mnemonic	EOR,<"EOR">     ; XOR with accumulator mnemonic
	Mnemonic	INC,<"INC">     ; Increment mnemonic
	Mnemonic	INX,<"INX">     ; Increment X register mnemonic
	Mnemonic	INY,<"INY">     ; Increment Y register mnemonic
	Mnemonic	JMP,<"JMP">     ; Jump mnemonic
	Mnemonic	JSR,<"JSR">     ; Jump to subroutine mnemonic
	Mnemonic	LDA,<"LDA">     ; Load accumulator mnemonic
	Mnemonic	LDX,<"LDX">     ; Load X register mnemonic
	Mnemonic	LDY,<"LDY">     ; Load Y register mnemonic
	Mnemonic	LSR,<"LSR">     ; Logical shift right mnemonic
	Mnemonic	NOP,<"NOP">     ; No operation mnemonic
	Mnemonic	ORA,<"ORA">     ; OR with accumulator mnemonic
	Mnemonic	PHA,<"PHA">     ; Push accumulator mnemonic
	Mnemonic	PHP,<"PHP">     ; Push processor status mnemonic
	Mnemonic	PHX,<"PHX">     ; Push X register mnemonic
	Mnemonic	PHY,<"PHY">     ; Push Y register mnemonic
	Mnemonic	PLA,<"PLA">     ; Pull accumulator mnemonic
	Mnemonic	PLP,<"PLP">     ; Pull processor status mnemonic
	Mnemonic	PLX,<"PLX">     ; Pull X register mnemonic
	Mnemonic	PLY,<"PLY">     ; Pull Y register mnemonic
	Mnemonic	ROL,<"ROL">     ; Rotate left mnemonic
	Mnemonic	ROR,<"ROR">     ; Rotate right mnemonic
	Mnemonic	RTI,<"RTI">     ; Return from interrupt mnemonic
	Mnemonic	RTS,<"RTS">     ; Return from subroutine mnemonic
	Mnemonic	SBC,<"SBC">     ; Subtract with borrow mnemonic
	Mnemonic	SEC,<"SEC">     ; Set carry mnemonic
	Mnemonic	SED,<"SED">     ; Set decimal mode mnemonic
	Mnemonic	SEI,<"SEI">     ; Set interrupt disable mnemonic
	Mnemonic	STA,<"STA">     ; Store accumulator mnemonic
	Mnemonic	STX,<"STX">     ; Store X register mnemonic
	Mnemonic	STY,<"STY">     ; Store Y register mnemonic
	Mnemonic	STZ,<"STZ">     ; Store zero mnemonic
	Mnemonic	TAX,<"TAX">     ; Transfer acc. to X mnemonic
	Mnemonic	TAY,<"TAY">     ; Transfer acc. to Y mnemonic
	Mnemonic	TRB,<"TRB">     ; Test/reset bits mnemonic
	Mnemonic	TSB,<"TSB">     ; Test/set bits mnemonic
	Mnemonic	TSX,<"TSX">     ; Transfer stack to X mnemonic
	Mnemonic	TXA,<"TXA">     ; Transfer X to acc. mnemonic
	Mnemonic	TXS,<"TXS">     ; Transfer X to stack mnemonic
	Mnemonic	TYA,<"TYA">     ; Transfer Y to acc. mnemonic
;******************************************************************************
;
;	Define the 65C02 debugger opcode data table
;
;******************************************************************************
	Even				; Force table to an even address
Opcode_Table	Equ	This Byte	; 65C02 Opcode data table
	Opcode	<OP_BRK,TYPE_NONE>	; Opcode 00h - Software break
	Opcode	<OP_ORA,TYPE_DIIX>	; Opcode 01h - OR accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 02h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 03h - Illegal opcode
	Opcode	<OP_TSB,TYPE_DP>	; Opcode 04h - Test/set bits w/acc.
	Opcode	<OP_ORA,TYPE_DP>	; Opcode 05h - OR accumulator w/memory
	Opcode	<OP_ASL,TYPE_DP>	; Opcode 06h - Shift memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 07h - Illegal opcode
	Opcode	<OP_PHP,TYPE_NONE>	; Opcode 08h - Push processor status
	Opcode	<OP_ORA,TYPE_IMM>	; Opcode 09h - OR accumulator w/memory
	Opcode	<OP_ASL,TYPE_NONE>	; Opcode 0Ah - Shift memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 0Bh - Illegal opcode
	Opcode	<OP_TSB,TYPE_ABS>	; Opcode 0Ch - Test/set bits w/acc.
	Opcode	<OP_ORA,TYPE_ABS>	; Opcode 0Dh - OR accumulator w/memory
	Opcode	<OP_ASL,TYPE_ABS>	; Opcode 0Eh - Shift memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 0Fh - Illegal opcode
	Opcode	<OP_BPL,TYPE_PCR>	; Opcode 10h - Branch if plus
	Opcode	<OP_ORA,TYPE_DIIY>	; Opcode 11h - OR accumulator w/memory
	Opcode	<OP_ORA,TYPE_DI>	; Opcode 12h - OR accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 13h - Illegal opcode
	Opcode	<OP_TRB,TYPE_DP>	; Opcode 14h - Test/reset bits w/acc.
	Opcode	<OP_ORA,TYPE_DIX>	; Opcode 15h - OR accumulator w/memory
	Opcode	<OP_ASL,TYPE_DIX>	; Opcode 16h - Shift memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 17h - Illegal opcode
	Opcode	<OP_CLC,TYPE_NONE>	; Opcode 18h - Clear carry
	Opcode	<OP_ORA,TYPE_AIY>	; Opcode 19h - OR accumulator w/memory
	Opcode	<OP_INC,TYPE_NONE>	; Opcode 1Ah - Increment
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 1Bh - Illegal opcode
	Opcode	<OP_TRB,TYPE_ABS>	; Opcode 1Ch - Test/reset bits w/acc.
	Opcode	<OP_ORA,TYPE_AIX>	; Opcode 1Dh - OR accumulator w/memory
	Opcode	<OP_ASL,TYPE_AIX>	; Opcode 1Eh - Shift memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 1Fh - Illegal opcode
	Opcode	<OP_JSR,TYPE_ABS>	; Opcode 20h - Jump to subroutine
	Opcode	<OP_AND,TYPE_DIIX>	; Opcode 21h - AND accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 22h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 23h - Illegal opcode
	Opcode	<OP_BIT,TYPE_DP>	; Opcode 24h - Test bits w/accumulator
	Opcode	<OP_AND,TYPE_DP>	; Opcode 25h - AND accumulator w/memory
	Opcode	<OP_ROL,TYPE_DP>	; Opcode 26h - Rotate memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 27h - Illegal opcode
	Opcode	<OP_PLP,TYPE_NONE>	; Opcode 28h - Pull processor status
	Opcode	<OP_AND,TYPE_IMM>	; Opcode 29h - AND accumulator w/memory
	Opcode	<OP_ROL,TYPE_NONE>	; Opcode 2Ah - Rotate memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 2Bh - Illegal opcode
	Opcode	<OP_BIT,TYPE_ABS>	; Opcode 2Ch - Test bits w/accumulator
	Opcode	<OP_AND,TYPE_ABS>	; Opcode 2Dh - AND accumulator w/memory
	Opcode	<OP_ROL,TYPE_ABS>	; Opcode 2Eh - Rotate memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 2Fh - Illegal opcode
	Opcode	<OP_BMI,TYPE_PCR>	; Opcode 30h - Branch if minus
	Opcode	<OP_AND,TYPE_DIIY>	; Opcode 31h - AND accumulator w/memory
	Opcode	<OP_AND,TYPE_DI>	; Opcode 32h - AND accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 33h - Illegal opcode
	Opcode	<OP_BIT,TYPE_DIX>	; Opcode 34h - Test bits w/accumulator
	Opcode	<OP_AND,TYPE_DIX>	; Opcode 35h - AND accumulator w/memory
	Opcode	<OP_ROL,TYPE_DIX>	; Opcode 36h - Rotate memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 37h - Illegal opcode
	Opcode	<OP_SEC,TYPE_NONE>	; Opcode 38h - Set carry
	Opcode	<OP_AND,TYPE_AIY>	; Opcode 39h - AND accumulator w/memory
	Opcode	<OP_DEC,TYPE_NONE>	; Opcode 3Ah - Decrement
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 3Bh - Illegal opcode
	Opcode	<OP_BIT,TYPE_AIX>	; Opcode 3Ch - Test bits w/accumulator
	Opcode	<OP_AND,TYPE_AIX>	; Opcode 3Dh - AND accumulator w/memory
	Opcode	<OP_ROL,TYPE_AIX>	; Opcode 3Eh - Rotate memory/acc. left
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 3Fh - Illegal opcode
	Opcode	<OP_RTI,TYPE_NONE>	; Opcode 40h - Return from interrupt
	Opcode	<OP_EOR,TYPE_DIIX>	; Opcode 41h - XOR accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 42h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 43h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 44h - Illegal opcode
	Opcode	<OP_EOR,TYPE_DP>	; Opcode 45h - XOR accumulator w/memory
	Opcode	<OP_LSR,TYPE_DP>	; Opcode 46h - Logical shift right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 47h - Illegal opcode
	Opcode	<OP_PHA,TYPE_NONE>	; Opcode 48h - Push accumulator
	Opcode	<OP_EOR,TYPE_IMM>	; Opcode 49h - XOR accumulator w/memory
	Opcode	<OP_LSR,TYPE_NONE>	; Opcode 4Ah - Logical shift right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 4Bh - Illegal opcode
	Opcode	<OP_JMP,TYPE_ABS>	; Opcode 4Ch - Jump
	Opcode	<OP_EOR,TYPE_ABS>	; Opcode 4Dh - XOR accumulator w/memory
	Opcode	<OP_LSR,TYPE_ABS>	; Opcode 4Eh - Logical shift right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 4Fh - Illegal opcode
	Opcode	<OP_BVC,TYPE_PCR>	; Opcode 50h - Branch if overflow clear
	Opcode	<OP_EOR,TYPE_DIIY>	; Opcode 51h - XOR accumulator w/memory
	Opcode	<OP_EOR,TYPE_DI>	; Opcode 52h - XOR accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 53h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 54h - Illegal opcode
	Opcode	<OP_EOR,TYPE_DIX>	; Opcode 55h - XOR accumulator w/memory
	Opcode	<OP_LSR,TYPE_DIX>	; Opcode 56h - Logical shift right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 57h - Illegal opcode
	Opcode	<OP_CLI,TYPE_NONE>	; Opcode 58h - Clear interrupt disable
	Opcode	<OP_EOR,TYPE_AIY>	; Opcode 59h - XOR accumulator w/memory
	Opcode	<OP_PHY,TYPE_NONE>	; Opcode 5Ah - Push Y index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 5Bh - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 5Ch - Illegal opcode
	Opcode	<OP_EOR,TYPE_AIX>	; Opcode 5Dh - XOR accumulator w/memory
	Opcode	<OP_LSR,TYPE_AIX>	; Opcode 5Eh - Logical shift right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 5Fh - Illegal opcode
	Opcode	<OP_RTS,TYPE_NONE>	; Opcode 60h - Return from subroutine
	Opcode	<OP_ADC,TYPE_DIIX>	; Opcode 61h - Add with carry
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 62h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 63h - Illegal opcode
	Opcode	<OP_STZ,TYPE_DP>	; Opcode 64h - Store zero to memory
	Opcode	<OP_ADC,TYPE_DP>	; Opcode 65h - Add with carry
	Opcode	<OP_ROR,TYPE_DP>	; Opcode 66h - Rotate memory/acc. right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 67h - Illegal opcode
	Opcode	<OP_PLA,TYPE_NONE>	; Opcode 68h - Pull accumulator
	Opcode	<OP_ADC,TYPE_IMM>	; Opcode 69h - Add with carry
	Opcode	<OP_ROR,TYPE_NONE>	; Opcode 6Ah - Rotate memory/acc. right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 6Bh - Illegal opcode
	Opcode	<OP_JMP,TYPE_AI>	; Opcode 6Ch - Jump
	Opcode	<OP_ADC,TYPE_ABS>	; Opcode 6Dh - Add with carry
	Opcode	<OP_ROR,TYPE_ABS>	; Opcode 6Eh - Rotate memory/acc. right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 6Fh - Illegal opcode
	Opcode	<OP_BVS,TYPE_PCR>	; Opcode 70h - Branch if overflow set
	Opcode	<OP_ADC,TYPE_DIIY>	; Opcode 71h - Add with carry
	Opcode	<OP_ADC,TYPE_DI>	; Opcode 72h - Add with carry
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 73h - Illegal opcode
	Opcode	<OP_STZ,TYPE_DIX>	; Opcode 74h - Store zero to memory
	Opcode	<OP_ADC,TYPE_DIX>	; Opcode 75h - Add with carry
	Opcode	<OP_ROR,TYPE_DIX>	; Opcode 76h - Rotate memory/acc. right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 77h - Illegal opcode
	Opcode	<OP_SEI,TYPE_NONE>	; Opcode 78h - Set interrupt disable
	Opcode	<OP_ADC,TYPE_AIY>	; Opcode 79h - Add with carry
	Opcode	<OP_PLY,TYPE_NONE>	; Opcode 7Ah - Pull Y index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 7Bh - Illegal opcode
	Opcode	<OP_JMP,TYPE_AIIX>	; Opcode 7Ch - Jump
	Opcode	<OP_ADC,TYPE_AIX>	; Opcode 7Dh - Add with carry
	Opcode	<OP_ROR,TYPE_AIX>	; Opcode 7Eh - Rotate memory/acc. right
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 7Fh - Illegal opcode
	Opcode	<OP_BRA,TYPE_PCR>	; Opcode 80h - Branch always
	Opcode	<OP_STA,TYPE_DIIX>	; Opcode 81h - Store accumulator
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 82h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 83h - Illegal opcode
	Opcode	<OP_STY,TYPE_DP>	; Opcode 84h - Store Y index register
	Opcode	<OP_STA,TYPE_DP>	; Opcode 85h - Store accumulator
	Opcode	<OP_STX,TYPE_DP>	; Opcode 86h - Store X index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 87h - Illegal opcode
	Opcode	<OP_DEY,TYPE_NONE>	; Opcode 88h - Decrement Y register
	Opcode	<OP_BIT,TYPE_IMM>	; Opcode 89h - Test bits w/accumulator
	Opcode	<OP_TXA,TYPE_NONE>	; Opcode 8Ah - Transfer X reg. to acc.
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 8Bh - Illegal opcode
	Opcode	<OP_STY,TYPE_ABS>	; Opcode 8Ch - Store Y index register
	Opcode	<OP_STA,TYPE_ABS>	; Opcode 8Dh - Store accumulator
	Opcode	<OP_STX,TYPE_ABS>	; Opcode 8Eh - Store X index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 8Fh - Illegal opcode
	Opcode	<OP_BCC,TYPE_PCR>	; Opcode 90h - Branch if carry clear
	Opcode	<OP_STA,TYPE_DIIY>	; Opcode 91h - Store accumulator
	Opcode	<OP_STA,TYPE_DI>	; Opcode 92h - Store accumulator
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 93h - Illegal opcode
	Opcode	<OP_STY,TYPE_DIX>	; Opcode 94h - Store Y index register
	Opcode	<OP_STA,TYPE_DIX>	; Opcode 95h - Store accumulator
	Opcode	<OP_STX,TYPE_DIX>	; Opcode 96h - Store X index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 97h - Illegal opcode
	Opcode	<OP_TYA,TYPE_NONE>	; Opcode 98h - Transfer Y reg. to acc.
	Opcode	<OP_STA,TYPE_AIY>	; Opcode 99h - Store accumulator
	Opcode	<OP_TXS,TYPE_NONE>	; Opcode 9Ah - Transfer X reg. to stack
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 9Bh - Illegal opcode
	Opcode	<OP_STZ,TYPE_ABS>	; Opcode 9Ch - Store zero to memory
	Opcode	<OP_STA,TYPE_AIX>	; Opcode 9Dh - Store accumulator
	Opcode	<OP_STZ,TYPE_AIX>	; Opcode 9Eh - Store zero to memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode 9Fh - Illegal opcode
	Opcode	<OP_LDY,TYPE_IMM>	; Opcode A0h - Load Y register w/memory
	Opcode	<OP_LDA,TYPE_DIIX>	; Opcode A1h - Load accumulator w/memory
	Opcode	<OP_LDX,TYPE_IMM>	; Opcode A2h - Load X register w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode A3h - Illegal opcode
	Opcode	<OP_LDY,TYPE_DP>	; Opcode A4h - Load Y register w/memory
	Opcode	<OP_LDA,TYPE_DP>	; Opcode A5h - Load accumulator w/memory
	Opcode	<OP_LDX,TYPE_DP>	; Opcode A6h - Load X register w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode A7h - Illegal opcode
	Opcode	<OP_TAY,TYPE_NONE>	; Opcode A8h - Transfer acc. to Y reg.
	Opcode	<OP_LDA,TYPE_IMM>	; Opcode A9h - Load accumulator w/memory
	Opcode	<OP_TAX,TYPE_NONE>	; Opcode AAh - Transfer acc. to X reg.
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode ABh - Illegal opcode
	Opcode	<OP_LDY,TYPE_ABS>	; Opcode ACh - Load Y register w/memory
	Opcode	<OP_LDA,TYPE_ABS>	; Opcode ADh - Load accumulator w/memory
	Opcode	<OP_LDX,TYPE_ABS>	; Opcode AEh - Load X register w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode AFh - Illegal opcode
	Opcode	<OP_BCS,TYPE_PCR>	; Opcode B0h - Branch if carry set
	Opcode	<OP_LDA,TYPE_DIIY>	; Opcode B1h - Load accumulator w/memory
	Opcode	<OP_LDA,TYPE_DI>	; Opcode B2h - Load accumulator w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode B3h - Illegal opcode
	Opcode	<OP_LDY,TYPE_DIX>	; Opcode B4h - Load Y register w/memory
	Opcode	<OP_LDA,TYPE_DIX>	; Opcode B5h - Load accumulator w/memory
	Opcode	<OP_LDX,TYPE_DIY>	; Opcode B6h - Load X register w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode B7h - Illegal opcode
	Opcode	<OP_CLV,TYPE_NONE>	; Opcode B8h - Clear overflow
	Opcode	<OP_LDA,TYPE_AIY>	; Opcode B9h - Load accumulator w/memory
	Opcode	<OP_TSX,TYPE_NONE>	; Opcode BAh - Transfer stack to X reg.
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode BBh - Illegal opcode
	Opcode	<OP_LDY,TYPE_AIX>	; Opcode BCh - Load Y register w/memory
	Opcode	<OP_LDA,TYPE_AIX>	; Opcode BDh - Load accumulator w/memory
	Opcode	<OP_LDX,TYPE_AIY>	; Opcode BEh - Load X register w/memory
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode BFh - Illegal opcode
	Opcode	<OP_CPY,TYPE_IMM>	; Opcode C0h - Compare Y reg. w/memory
	Opcode	<OP_CMP,TYPE_DIIX>	; Opcode C1h - Compare memory w/acc.
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode C2h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode C3h - Illegal opcode
	Opcode	<OP_CPY,TYPE_DP>	; Opcode C4h - Compare Y reg. w/memory
	Opcode	<OP_CMP,TYPE_DP>	; Opcode C5h - Compare memory w/acc.
	Opcode	<OP_DEC,TYPE_DP>	; Opcode C6h - Decrement
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode C7h - Illegal opcode
	Opcode	<OP_INY,TYPE_NONE>	; Opcode C8h - Increment Y register
	Opcode	<OP_CMP,TYPE_IMM>	; Opcode C9h - Compare memory w/acc.
	Opcode	<OP_DEX,TYPE_NONE>	; Opcode CAh - Decrement X register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode CBh - Illegal opcode
	Opcode	<OP_CPY,TYPE_ABS>	; Opcode CCh - Compare Y reg. w/memory
	Opcode	<OP_CMP,TYPE_ABS>	; Opcode CDh - Compare memory w/acc.
	Opcode	<OP_DEC,TYPE_ABS>	; Opcode CEh - Decrement
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode CFh - Illegal opcode
	Opcode	<OP_BNE,TYPE_PCR>	; Opcode D0h - Branch if not equal
	Opcode	<OP_CMP,TYPE_DIIY>	; Opcode D1h - Compare memory w/acc.
	Opcode	<OP_CMP,TYPE_DI>	; Opcode D2h - Compare memory w/acc.
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode D3h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode D4h - Illegal opcode
	Opcode	<OP_CMP,TYPE_DIX>	; Opcode D5h - Compare memory w/acc.
	Opcode	<OP_DEC,TYPE_DIX>	; Opcode D6h - Decrement
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode D7h - Illegal opcode
	Opcode	<OP_CLD,TYPE_NONE>	; Opcode D8h - Clear decimal mode
	Opcode	<OP_CMP,TYPE_AIY>	; Opcode D9h - Compare memory w/acc.
	Opcode	<OP_PHX,TYPE_NONE>	; Opcode DAh - Push X index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode DBh - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode DCh - Illegal opcode
	Opcode	<OP_CMP,TYPE_AIX>	; Opcode DDh - Compare memory w/acc.
	Opcode	<OP_DEC,TYPE_AIX>	; Opcode DEh - Decrement
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode DFh - Illegal opcode
	Opcode	<OP_CPX,TYPE_IMM>	; Opcode E0h - Compare X reg. w/memory
	Opcode	<OP_SBC,TYPE_DIIX>	; Opcode E1h - Subtract from accumulator
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode E2h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode E3h - Illegal opcode
	Opcode	<OP_CPX,TYPE_DP>	; Opcode E4h - Compare X reg. w/memory
	Opcode	<OP_SBC,TYPE_DP>	; Opcode E5h - Subtract from accumulator
	Opcode	<OP_INC,TYPE_DP>	; Opcode E6h - Increment
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode E7h - Illegal opcode
	Opcode	<OP_INX,TYPE_NONE>	; Opcode E8h - Increment X register
	Opcode	<OP_SBC,TYPE_IMM>	; Opcode E9h - Subtract from accumulator
	Opcode	<OP_NOP,TYPE_NONE>	; Opcode EAh - No operation
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode EBh - Illegal opcode
	Opcode	<OP_CPX,TYPE_ABS>	; Opcode ECh - Compare X reg. w/memory
	Opcode	<OP_SBC,TYPE_ABS>	; Opcode EDh - Subtract from accumulator
	Opcode	<OP_INC,TYPE_ABS>	; Opcode EEh - Increment
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode EFh - Illegal opcode
	Opcode	<OP_BEQ,TYPE_PCR>	; Opcode F0h - Branch if equal
	Opcode	<OP_SBC,TYPE_DIIY>	; Opcode F1h - Subtract from accumulator
	Opcode	<OP_SBC,TYPE_DI>	; Opcode F2h - Subtract from accumulator
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode F3h - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode F4h - Illegal opcode
	Opcode	<OP_SBC,TYPE_DIX>	; Opcode F5h - Subtract from accumulator
	Opcode	<OP_INC,TYPE_DIX>	; Opcode F6h - Increment
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode F7h - Illegal opcode
	Opcode	<OP_SED,TYPE_NONE>	; Opcode F8h - Set decimal mode
	Opcode	<OP_SBC,TYPE_AIY>	; Opcode F9h - Subtract from accumulator
	Opcode	<OP_PLX,TYPE_NONE>	; Opcode FAh - Pull X index register
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode FBh - Illegal opcode
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode FCh - Illegal opcode
	Opcode	<OP_SBC,TYPE_AIX>	; Opcode FDh - Subtract from accumulator
	Opcode	<OP_INC,TYPE_AIX>	; Opcode FEh - Increment
	Opcode	<OP_BAD,TYPE_BAD>	; Opcode FFh - Illegal opcode
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Debug module

	Page	58,132
	Title	EMULATE.ASM	65C02 Emulator (65C02 Processor)
;******************************************************************************
;
;   Name:	EMULATE.ASM	65C02 Emulator (65C02 Processor)
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
;		This module contains all the code for the 65C02 CPU
;	emulation. This module MUST be linked first as the placement
;	of the opcode routines is instrumental in execution.
;
;	The following register convention holds true for all opcode routines:
;
;	Registers on Entry:
;
;		BX    - 65C02 Stack pointer register (BH = 01)
;		CH    - 65C02 X index register
;		CL    - 65C02 Y index register
;		DH    - 65C02 processor flags register
;		DL    - 65C02 Accumulator register
;		SI    - 65C02 Program counter register
;		DI    - 65C02 Effective address
;		DS    - Apple RAM segment
;		ES    - Video memory segment
;		FL    - Direction flag is cleared (Move forward)
;
;	Registers on Exit:
;
;		DH    - 65C02 processor flags updated
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
	Public	Emulator		; Emulator entry point
	Public	Op_Fetch		; Fetch next opcode entry point
;
;  External Declarations
;
	Extrn	Initialize:Near 	; Emulator initialization	(APPLE)
	Extrn	Read_Memory:Near	; Read 65C02 memory routine	(APPLE)
	Extrn	Write_Memory:Near	; Write 65C02 memory routine	(APPLE)
	Extrn	Interrupt:Near		; Interrupt processing routine	  (INT)
	Extrn	Flag_Encode:Byte	; CPU flag encoding table	 (DATA)
	Extrn	Flag_Decode:Byte	; CPU flag decoding table	 (DATA)
;
;  LOCAL Equates
;
OP_SIZE 	Equ	80h		; Op-code work area size (128 Bytes)
OP_BASE 	Equ	07h		; Op-code work area base (Op_Size Log 2)
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
	Subttl	Opcode 00 - BRK Stack/Interrupt
	Page	+
;******************************************************************************
;
;	Op_BRK ()	Software Break
;
;		Increment program counter past the signature byte
;		Push the program counter onto stack
;		Set the b (Software break) and r (Reserved) flag bits
;		Encode flag bits from 80x86 to 65C02
;		Push the processor flags onto stack
;		Set the i (Interrupt disable) flag bit
;		Load program counter with interrupt vector (FFFEh)
;		Fetch the next instruction
;
;******************************************************************************
Op_BRK		Proc	Near		; Software break procedure
	inc	si			; Increment past signature byte
	mov	ax,si			; Get the program counter
	Push_16 			; Push program counter onto stack
	mov	al,dh			; Get the 65C02 status flags
	or	al,CPU_R + CPU_B	; Set the b and r flag bits
	xor	ah,ah			; Convert flag value to full word
	mov	bp,ax			; Setup to encode the flag value
	mov	al,cs:[bp + Flag_Encode]; Get the encoded flag value
	Push_8				; Push the 65C02 flags onto stack
	or	dh,CPU_I		; Set the i flag bit
	mov	si,ds:[BRK_VECTOR]	; Load PC with interrupt vector
	Fetch				; Fetch and execute next instruction
Op_BRK		Endp			; End of software break procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 01 - ORA DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_ORA_DIIX ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DIIX	Proc	Near		; OR accumulator with memory procedure
	DoDIIX				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_DIIX	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 02 - COP Stack/Interrupt 		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_COP ()	Co-processor Enable
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_COP		Proc	Near		; Co-processor enable procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_COP		Endp			; End of co-processor enable procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 03 - ORA Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ORA_S ()	OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_S	Proc	Near		; OR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ORA_S	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 04 - TSB Direct Page			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_TSB_DP ()	Test and Set Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the TSB operation (Update flag bit z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TSB_DP	Proc	Near		; Test and set memory bits procedure
	DoDP				; Setup the effective address
	OpTSB				; Do the TSB operation (Update z)
	Fetch				; Fetch and execute next instruction
Op_TSB_DP	Endp			; End of test and set bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 05 - ORA Direct Page
	Page	+
;******************************************************************************
;
;	Op_ORA_DP ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DP	Proc	Near		; OR accumulator with memory procedure
	DoDP				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_DP	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 06 - ASL Direct Page
	Page	+
;******************************************************************************
;
;	Op_ASL_DP ()	Shift Memory Left
;
;		Setup the effective address
;		Do the ASL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ASL_DP	Proc	Near		; Shift memory left procedure
	DoDP				; Setup the effective address
	OpASL				; Do the ASL operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ASL_DP	Endp			; End of shift memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 07 - ORA DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ORA_DIL ()	OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DIL	Proc	Near		; OR Accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ORA_DIL	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 08 - PHP Stack/Push
	Page	+
;******************************************************************************
;
;	Op_PHP ()	Push Processor Status Register
;
;		Set the r (Reserved) flag bit
;		Encode flag bits from 80x86 to 65C02
;		Push 65C02 status flags onto stack
;		Fetch the next instruction
;
;******************************************************************************
Op_PHP		Proc	Near		; Push processor status procedure
	mov	al,dh			; Get the 65C02 processor flags
	or	al,CPU_R		; Make sure reserved bit is set
	xor	ah,ah			; Convert flag value to full word
	mov	bp,ax			; Setup to encode the flag value
	mov	al,cs:[bp + Flag_Encode]; Get the encoded flag value
	Push_8				; Push 65C02 status flags onto stack
	Fetch				; Fetch and execute next instruction
Op_PHP		Endp			; End of push processor status procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 09 - ORA Immediate
	Page	+
;******************************************************************************
;
;	Op_ORA_I ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_I	Proc	Near		; OR accumulator with memory procedure
	DoImm				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_I	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 0A - ASL Accumulator
	Page	+
;******************************************************************************
;
;	Op_ASL ()	Shift Accumulator Left
;
;		Shift the accumulator left
;		Update the 65C02 processor flags (n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ASL		Proc	Near		; Shift accumulator left procedure
	shl	dl,1			; Shift the accumulator left
	Flgnzc				; Update the n, z, and c flags
	Fetch				; Fetch and execute next instruction
Op_ASL		Endp			; End shift accumulator left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 0B - PHD Stack/Push			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PHD ()	Push Direct Page Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_PHD		Proc	Near		; Push direct page register procedure
	Fetch				; Fetch and execute next instruction
Op_PHD		Endp			; End of push direct page procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 0C - TSB Absolute			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_TSB_A ()	Test and Set Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the TSB operation (Update flag bit z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TSB_A	Proc	Near		; Test and set memory bits procedure
	DoAbs				; Setup the effective address
	OpTSB				; Do the TSB operation (Update z)
	Fetch				; Fetch and execute next instruction
Op_TSB_A	Endp			; End of test and set bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 0D - ORA Absolute
	Page	+
;******************************************************************************
;
;	Op_ORA_A ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_A	Proc	Near		; OR accumulator with memory procedure
	DoAbs				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_A	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 0E - ASL Absolute
	Page	+
;******************************************************************************
;
;	Op_ASL_A ()	Shift Memory Left
;
;		Setup the effective address
;		Do the ASL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ASL_A	Proc	Near		; Shift memory left procedure
	DoAbs				; Setup the effective address
	OpASL				; Do the ASL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ASL_A	Endp			; End of shift memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 0F - ORA Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ORA_AL ()	OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_AL	Proc	Near		; OR accumulator with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ORA_AL	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 10 - BPL Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BPL ()	Branch if Plus
;
;		Get the program counter offset byte
;		If the n flag is clear
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BPL		Proc	Near		; Branch if plus procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_N		; Check the 65C02 n (Negative) flag
	jnz	_BPL			; Jump if the n flag is set (Negative)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BPL:
	Fetch				; Fetch and execute next instruction
Op_BPL		Endp			; End of branch if plus procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 11 - ORA DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_ORA_DIIY ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DIIY	Proc	Near		; OR accumulator with memory procedure
	DoDIIY				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_DIIY	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 12 - ORA DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_ORA_DI ()	OR Acumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DI	Proc	Near		; OR accumulator with memory procedure
	DoDI				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_DI	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 13 - ORA SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ORA_SIIY ()	OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_SIIY	Proc	Near		; OR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ORA_SIIY	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 14 - TRB Direct Page			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_TRB_DP ()	Test and Reset Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the TRB operation (Update flag bit z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TRB_DP	Proc	Near		; Test and reset memory bits procedure
	DoDP				; Setup the effective address
	OpTRB				; Do the TRB operation (Update z)
	Fetch				; Fetch and execute next instruction
Op_TRB_DP	Endp			; End of test and reset procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 15 - ORA DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ORA_DIX ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DIX	Proc	Near		; OR accumulator with memory procedure
	DoDIX				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_DIX	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 16 - ASL DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ASL_DIX ()	Shift Memory Left
;
;		Setup the effective address
;		Do the ASL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ASL_DIX	Proc	Near		; Shift memory left procedure
	DoDIX				; Setup the effective address
	OpASL				; Do the ASL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ASL_DIX	Endp			; End of shift memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 17 - ORA DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ORA_DILIY () OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_DILIY	Proc	Near		; OR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ORA_DILIY	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 18 - CLC Implied
	Page	+
;******************************************************************************
;
;	Op_CLC ()	Clear Carry Flag
;
;		Clear the 65C02 carry flag
;		Fetch the next instruction
;
;******************************************************************************
Op_CLC		Proc	Near		; Clear carry flag procedure
	and	dh,Not CPU_C		; Clear the 65C02 carry flag
	Fetch				; Fetch and execute next instruction
Op_CLC		Endp			; End of clear carry flag procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 19 - ORA Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_ORA_AIY ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_AIY	Proc	Near		; OR accumulator with memory procedure
	DoAIY				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_AIY	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 1A - INC Accumulator			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_INC ()	Increment the Accumulator
;
;		Increment the accumulator
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INC		Proc	Near		; Increment the accumulator procedure
	inc	dl			; Increment the accumulator
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_INC		Endp			; End of increment accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 1B - TCS Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_TCS ()	Transfer Accumulator to Stack Pointer
;
;		Fetch the next instruction
;
;******************************************************************************
Op_TCS		Proc	Near		; Transfer accumulator/stack procedure
	Fetch				; Fetch and execute next instruction
Op_TCS		Endp			; End of transfer accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 1C - TRB Absolute			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_TRB_A ()	Test and Reset Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the TRB operation (Update flag bit z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TRB_A	Proc	Near		; Test and reset memory bits procedure
	DoAbs				; Setup the effective address
	OpTRB				; Do the TRB operation (Update z)
	Fetch				; Fetch and execute next instruction
Op_TRB_A	Endp			; End of test and reset bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 1D - ORA Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ORA_AIX ()	OR Accumulator with Memory
;
;		Setup the effective address
;		Do the ORA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_AIX	Proc	Near		; OR accumulator with memory procedure
	DoAIX				; Setup the effective address
	OpORA				; Do the ORA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_ORA_AIX	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 1E - ASL Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ASL_AIX ()	Shift Memory Left
;
;		Setup the effective address
;		Do the ASL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ASL_AIX	Proc	Near		; Shift memory left procedure
	DoAIX				; Setup the effective address
	OpASL				; Do the ASL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ASL_AIX	Endp			; End of shift memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 1F - ORA Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ORA_ALIX ()	OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ORA_ALIX	Proc	Near		; OR accumulator with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ORA_ALIX	Endp			; End of OR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 20 - JSR Absolute
	Page	+
;******************************************************************************
;
;	Op_JSR_A ()	Jump to Subroutine
;
;		Setup the effective address
;		Do the JMP operation
;		Fetch the next instruction
;
;******************************************************************************
Op_JSR_A	Proc	Near		; Jump to subroutine procedure
	DoAbs				; Setup the effective address
	OpJSR				; Do the JSR operation
	Fetch				; Fetch and execute next instruction
Op_JSR_A	Endp			; End of jump to subroutine procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 21 - AND DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_AND_DIIX ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DIIX	Proc	Near		; AND accumulator with memory procedure
	DoDIIX				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_DIIX	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 22 - JSR Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_JSL_AL ()	Jump to Subroutine
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_JSL_AL	Proc	Near		; Jump to subroutine procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_JSL_AL	Endp			; End of jump to subroutine procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 23 - AND Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_AND_S ()	AND Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_S	Proc	Near		; AND accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_AND_S	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 24 - BIT Direct Page
	Page	+
;******************************************************************************
;
;	Op_BIT_DP ()	Test Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the BIT operation (Update flag bits n, v, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_BIT_DP	Proc	Near		; Test memory bits procedure
	DoDP				; Setup the effective address
	OpBIT				; Do the BIT operation (Update n,v,z)
	Fetch				; Fetch and execute next instruction
Op_BIT_DP	Endp			; End of test memory bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 25 - AND Direct Page
	Page	+
;******************************************************************************
;
;	Op_AND_DP ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DP	Proc	Near		; AND accumulator with memory procedure
	DoDP				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_DP	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 26 - ROL Direct Page
	Page	+
;******************************************************************************
;
;	Op_ROL_DP ()	Rotate Memory Left
;
;		Setup the effective address
;		Do the ROL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROL_DP	Proc	Near		; Rotate memory left procedure
	DoDP				; Setup the effective address
	OpROL				; Do the ROL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROL_DP	Endp			; End of rotate memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 27 - AND DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_AND_DIL ()	AND Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DIL	Proc	Near		; AND accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_AND_DIL	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 28 - PLP Stack/Pull
	Page	+
;******************************************************************************
;
;	Op_PLP ()	Pull Processor Status Register
;
;		Pop the 65C02 status flags from stack
;		Clear the r (Reserved) flag bit
;		Decode flag bits from 65c02 to 80x86
;		Fetch the next instruction
;
;******************************************************************************
Op_PLP		Proc	Near		; Pull processor status procedure
	Pop_8				; Pop 65C02 status flags from stack
	and	al,Not CPU_R		; Make sure reserved bit is clear
	xor	ah,ah			; Convert flag value to full word
	mov	bp,ax			; Setup to decode the flag value
	mov	al,cs:[bp + Flag_Decode]; Get the decoded flag value
	mov	dh,al			; Update 65C02 processor status flags
	Fetch				; Fetch and execute next instruction
Op_PLP		Endp			; End of pull processor status procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 29 - AND Immediate
	Page	+
;******************************************************************************
;
;	Op_AND_I ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_I	Proc	Near		; AND accumulator with memory procedure
	DoImm				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_I	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 2A - ROL Accumulator
	Page	+
;******************************************************************************
;
;	Op_ROL ()	Rotate Accumulator Left
;
;		Move 65C02 carry flag into real carry
;		Rotate the accumulator left
;		Update the 65C02 processor flags (n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROL		Proc	Near		; Rotate accumulator left procedure
	mov	al,dh			; Get 65C02 processor status flags
	shr	al,1			; Move 65C02 carry flag into real carry
	rcl	dl,1			; Rotate the accumulator left
	rcr	al,1			; Save carry result in AL register
	or	dl,dl			; Set the n and z flags correctly
	rcl	al,1			; Restore the carry result
	Flgnzc				; Update the n, z, and c flags
	Fetch				; Fetch and execute next instruction
Op_ROL		Endp			; End of rotate accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 2B - PLD Stack/Pull			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PLD ()	Pull Direct Page Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_PLD		Proc	Near		; Pull direct page register procedure
	Fetch				; Fetch and execute next instruction
Op_PLD		Endp			; End of pull direct page procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 2C - BIT Absolute
	Page	+
;******************************************************************************
;
;	Op_BIT_A ()	Test Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the BIT operation (Update flag bits n, v, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_BIT_A	Proc	Near		; Test memory bits procedure
	DoAbs				; Setup the effective address
	OpBIT				; Do the BIT operation (Update n,v,z)
	Fetch				; Fetch and execute next instruction
Op_BIT_A	Endp			; End of test memory bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 2D - AND Absolute
	Page	+
;******************************************************************************
;
;	Op_AND_A ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_A	Proc	Near		; AND accumulator with memory procedure
	DoAbs				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_A	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 2E - ROL Absolute
	Page	+
;******************************************************************************
;
;	Op_ROL_A ()	Rotate Memory Left
;
;		Setup the effective address
;		Do the ROL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROL_A	Proc	Near		; Rotate memory left procedure
	DoAbs				; Setup the effective address
	OpROL				; Do the ROL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROL_A	Endp			; End of rotate memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 2F - AND Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_AND_AL ()	AND Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_AL	Proc	Near		; AND accumulator with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_AND_AL	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 30 - BMI Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BMI ()	Branch if Minus
;
;		Get the program counter offset byte
;		If the n flag is set
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BMI		Proc	Near		; Branch if minus procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_N		; Check the 65C02 n (Negative) flag
	jz	_BMI			; Jump if n flag is clear (Positive)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BMI:
	Fetch				; Fetch and execute next instruction
Op_BMI		Endp			; End of branch if minus procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 31 - AND DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_AND_DIIY ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DIIY	Proc	Near		; AND accumulator with memory procedure
	DoDIIY				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_DIIY	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 32 - AND DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_AND_DI ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DI	Proc	Near		; AND accumulator with memory procedure
	DoDI				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_DI	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 33 - AND SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_AND_SIIY ()	AND Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_SIIY	Proc	Near		; AND accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_AND_SIIY	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 34 - BIT DP Indexed, X			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_BIT_DIX ()	Test Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the BIT operation (Update flag bits n, v, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_BIT_DIX	Proc	Near		; Test memory bits procedure
	DoDIX				; Setup the effective address
	OpBIT				; Do the BIT operation (Update n,v,z)
	Fetch				; Fetch and execute next instruction
Op_BIT_DIX	Endp			; End of test memory bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 35 - AND DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_AND_DIX ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DIX	Proc	Near		; AND accumulator with memory procedure
	DoDIX				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_DIX	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 36 - ROL DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ROL_DIX ()	Rotate Memory Left
;
;		Setup the effective address
;		Do the ROL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROL_DIX	Proc	Near		; Rotate memory left procedure
	DoDIX				; Setup the effective address
	OpROL				; Do the ROL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROL_DIX	Endp			; End of rotate memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 37 - AND DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_AND_DILIY () AND Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_DILIY	Proc	Near		; AND accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_AND_DILIY	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 38 - SEC Implied
	Page	+
;******************************************************************************
;
;	Op_SEC ()	Set Carry Flag
;
;		Set the 65C02 carry flag
;		Fetch the next instruction
;
;******************************************************************************
Op_SEC		Proc	Near		; Set carry flag procedure
	or	dh,CPU_C		; Set the 65C02 carry flag
	Fetch				; Fetch and execute next instruction
Op_SEC		Endp			; End of set carry flag procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 39 - AND Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_AND_AIY ()	AND Accumulator with Memroy
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_AIY	Proc	Near		; AND accumulator with memory procedure
	DoAIY				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_AIY	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 3A - DEC Accumulator			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_DEC ()	Decrement the Accumulator
;
;		Decrement the accumulator
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEC		Proc	Near		; Decrement the accumulator procedure
	dec	dl			; Decrement the accumulator
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_DEC		Endp			; End of decrement accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 3B - TSC Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_TSC ()	Transfer Stack Pointer to Accumulator (16-Bit)
;
;		Fetch the next instruction
;
;******************************************************************************
Op_TSC		Proc	Near		; Transfer stack > accumulator procedure
	Fetch				; Fetch and execute next instruction
Op_TSC		Endp			; End of transfer stack procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 3C - BIT Absolute Indexed, X		(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_BIT_AIX ()	Test Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the BIT operation (Update flag bits n, v, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_BIT_AIX	Proc	Near		; Test memory bits procedure
	DoAIX				; Setup the effective address
	OpBIT				; Do the BIT operation (Update n,v,z)
	Fetch				; Fetch and execute next instruction
Op_BIT_AIX	Endp			; End of test memory bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 3D - AND Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_AND_AIX ()	AND Accumulator with Memory
;
;		Setup the effective address
;		Do the AND operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_AIX	Proc	Near		; AND accumulator with memory procedure
	DoAIX				; Setup the effective address
	OpAND				; Do the AND operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_AND_AIX	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 3E - ROL Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ROL_AIX ()	Rotate Memory Left
;
;		Setup the effective address
;		Do the ROL operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROL_AIX	Proc	Near		; Rotate memory left procedure
	DoAIX				; Setup the effective address
	OpROL				; Do the ROL operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROL_AIX	Endp			; End of rotate memory left procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 3F - AND Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_AND_ALIX ()	AND Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_AND_ALIX	Proc	Near		; AND accumulator with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_AND_ALIX	Endp			; End of AND accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 40 - RTI Stack/RTI
	Page	+
;******************************************************************************
;
;	Op_RTI ()	Return from Interrupt
;
;		Pop the 65C02 processor flags from stack
;		Clear the r (Reserved) flag bit
;		Decode flag bits from 65c02 to 80x86
;		Pop the return address from the stack
;		Fetch the next instruction
;
;******************************************************************************
Op_RTI		Proc	Near		; Return from interrupt procedure
	Pop_8				; Pop 65C02 processor flags from stack
	and	al,Not CPU_R		; Make sure reserved bit is clear
	xor	ah,ah			; Convert flag value to full word
	mov	bp,ax			; Setup to decode the flag value
	mov	al,cs:[bp + Flag_Decode]; Get the decoded flag value
	mov	dh,al			; Update 65C02 processor status flags
	Pop_16				; Pop the return address from the stack
	mov	si,ax			; Update the program counter
	Fetch				; Fetch and execute next instruction
Op_RTI		Endp			; End of interrupt return procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 41 - EOR DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_EOR_DIIX ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_DIIX	Proc	Near		; XOR accumulator with memory procedure
	DoDIIX				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_DIIX	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 42 - WDM Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_WDM ()	Reserved for Future Expansion
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_WDM		Proc	Near		; Future expansion procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_WDM		Endp			; End of future expansion procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 43 - EOR Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_EOR_S ()	Exclusive-OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_S	Proc	Near		; XOR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_EOR_S	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 44 - MVP Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_MVP ()	Block Move Previous
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_MVP		Proc	Near		; Block move previous procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_MVP		Endp			; End of block move previous procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 45 - EOR Direct Page
	Page	+
;******************************************************************************
;
;	Op_EOR_D ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_D	Proc	Near		; XOR accumulator with memory procedure
	DoDP				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_D	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 46 - LSR Direct Page
	Page	+
;******************************************************************************
;
;	Op_LSR_D ()	Logical Shift Memory Right
;
;		Setup the effective address
;		Do the LSR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_LSR_D	Proc	Near		; Logical shift memory right procedure
	DoDP				; Setup the effective address
	OpLSR				; Do the LSR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_LSR_D	Endp			; End of shift memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 47 - EOR DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_EOR_DIL ()	Exclusive-OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_DIL	Proc	Near		; XOR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_EOR_DIL	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 48 - PHA Stack/Push
	Page	+
;******************************************************************************
;
;	Op_PHA ()	Push Accumulator
;
;		Push accumulator onto the stack
;		Fetch the next instruction
;
;******************************************************************************
Op_PHA		Proc	Near		; Push accumulator procedure
	mov	al,dl			; Get the accumulator value
	Push_8				; Push accumulator onto the stack
	Fetch				; Fetch and execute next instruction
Op_PHA		Endp			; End of push accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 49 - EOR Immediate
	Page	+
;******************************************************************************
;
;	Op_EOR_I ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_I	Proc	Near		; XOR accumulator with memory procedure
	DoImm				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_I	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 4A - LSR Accumulator
	Page	+
;******************************************************************************
;
;	Op_LSR ()	Logical Shift Accumulator Right
;
;		Shift the accumulator right
;		Update the 65C02 processor flags (n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_LSR		Proc	Near		; Shift accumulator right procedure
	shr	dl,1			; Shift the accumulator right
	Flgnzc				; Update the n, z, and c flags
	Fetch				; Fetch and execute next instruction
Op_LSR		Endp			; End of accumulator shift procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 4B - PHK Stack/Push			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PHK ()	Push Program Bank Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_PHK		Proc	Near		; Push bank register procedure
	Fetch				; Fetch and execute next instruction
Op_PHK		Endp			; End of push bank register procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 4C - JMP Absolute
	Page	+
;******************************************************************************
;
;	Op_JMP_A ()	Jump
;
;		Setup the effective address
;		Do the JMP operation
;		Fetch the next instruction
;
;******************************************************************************
Op_JMP_A	Proc	Near		; Jump procedure
	DoAbs				; Setup the effective address
	OpJMP				; Do the JMP operation
	Fetch				; Fetch and execute next instruction
Op_JMP_A	Endp			; End of jump procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 4D - EOR Absolute
	Page	+
;******************************************************************************
;
;	Op_EOR_A ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_A	Proc	Near		; XOR accumulator with memory procedure
	DoAbs				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_A	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 4E - LSR Absolute
	Page	+
;******************************************************************************
;
;	Op_LSR_A ()	Logical Shift Memory Right
;
;		Setup the effective address
;		Do the LSR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_LSR_A	Proc	Near		; Logical shift memory right  procedure
	DoAbs				; Setup the effective address
	OpLSR				; Do the LSR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_LSR_A	Endp			; End of shift memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 4F - EOR Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_EOR_AL ()	Exclusive-OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_AL	Proc	Near		; XOR accumulator with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_EOR_AL	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 50 - BVC Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BVC ()	Branch if Overflow Clear
;
;		Get the program counter offset byte
;		If the v flag is clear
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BVC		Proc	Near		; Branch if overflow clear procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_V		; Check the 65C02 v (Overflow) flag
	jnz	_BVC			; Jump if v flag is set (Overflow)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BVC:
	Fetch				; Fetch and execute next instruction
Op_BVC		Endp			; End of overflow branch procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 51 - EOR DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_EOR_DIIY ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_DIIY	Proc	Near		; XOR accumulator with memory procedure
	DoDIIY				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_DIIY	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 52 - EOR DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_EOR_D ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_DI	Proc	Near		; XOR accumulatoe with memory procedure
	DoDI				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_DI	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 53 - EOR SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_EOR_SIIY ()	Exclusive-OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_SIIY	Proc	Near		; XOR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_EOR_SIIY	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 54 - MVN Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_MVN ()	Block Move Next
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_MVN		Proc	Near		; Block move next procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_MVN		Endp			; End of block move next procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 55 - EOR DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_EOR_DIX ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_DIX	Proc	Near		; XOR accumulator with memory procedure
	DoDIX				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_DIX	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 56 - LSR DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_LSR_DIX ()	Logical Shift Memory Right
;
;		Setup the effective address
;		Do the LSR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_LSR_DIX	Proc	Near		; Logical shift memory right procedure
	DoDIX				; Setup the effective address
	OpLSR				; Do the LSR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_LSR_DIX	Endp			; End of shift memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 57 - EOR DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_EOR_DILIY () Exclusive-OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_DILIY	Proc	Near		; XOR accumulator with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_EOR_DILIY	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 58 - CLI Implied
	Page	+
;******************************************************************************
;
;	Op_CLI ()	Clear Interrupt Disable Flag
;
;		Clear the interrupt disable flag
;		Fetch the next instruction
;
;******************************************************************************
Op_CLI		Proc	Near		; Clear interrupt disable procedure
	and	dh,Not CPU_I		; Clear the interrupt disable flag
	Fetch				; Fetch and execute next instruction
Op_CLI		Endp			; End of clear interrupt procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 59 - EOR Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_EOR_AIY ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_AIY	Proc	Near		; XOR accumulator with memory procedure
	DoAIY				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_AIY	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 5A - PHY Stack/Push			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_PHY ()	Push Y Index Register
;
;		Push Y index register onto stack
;		Fetch the next instruction
;
;******************************************************************************
Op_PHY		Proc	Near		; Push Y index register procedure
	mov	al,cl			; Get the Y index register value
	Push_8				; Push Y index register onto stack
	Fetch				; Fetch and execute next instruction
Op_PHY		Endp			; End of push Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 5B - TCD Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_TCD ()	Transfer Accumulator (16-Bit) to Direct Page Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_TCD		Proc	Near		; Transfer acc. to direct page procedure
	Fetch				; Fetch and execute next instruction
Op_TCD		Endp			; End of transfer accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 5C - JMP Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_JMP_AL ()	Jump
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_JMP_AL	Proc	Near		; Jump procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_JMP_AL	Endp			; End of jump procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 5D - EOR Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_EOR_AIX ()	Exclusive-OR Accumulator with Memory
;
;		Setup the effective address
;		Do the EOR operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_AIX	Proc	Near		; XOR accumulator with memory procedure
	DoAIX				; Setup the effective address
	OpEOR				; Do the EOR operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_EOR_AIX	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 5E - LSR Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_LSR_AIX ()	Logical Shift Memory Right
;
;		Setup the effective address
;		Do the LSR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_LSR_AIX	Proc	Near		; Logical shift memory right procedure
	DoAIX				; Setup the effective address
	OpLSR				; Do the LSR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_LSR_AIX	Endp			; End of shift memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 5F - EOR Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_EOR_ALIX ()	Exclusive-OR Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_EOR_ALIX	Proc	Near		; XOR accumulator with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_EOR_ALIX	Endp			; End of XOR accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 60 - RTS Stack/RTS
	Page	+
;******************************************************************************
;
;	Op_RTS ()	Return from Subroutine
;
;		Pop the return address from the stack
;		Increment the return address
;		Update the program counter
;		Fetch the next instruction
;
;******************************************************************************
Op_RTS		Proc	Near		; Return from subroutine procedure
	Pop_16				; Pop return address from the stack
	inc	ax			; Increment the return address value
	mov	si,ax			; Update the program counter
	Fetch				; Fetch and execute next instruction
Op_RTS		Endp			; End of subroutine return procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 61 - ADC DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_ADC_DIIX ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_DIIX	Proc	Near		; Add with carry procedure
	DoDIIX				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_DIIX_DEC		; Jump if in decimal (BCD) mode
ADC_DIIX_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_DIIX_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_DIIX	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 62 - PER Stack/PC Relative Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PER ()	Push Effective PC Relative Indirect Address
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_PER		Proc	Near		; Push relative address procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_PER		Endp			; End of push relative address procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 63 - ADC Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ADC_S ()	Add to Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_S	Proc	Near		; Add with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ADC_S	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 64 - STZ Direct Page			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_STZ_D ()	Store Zero to Memory
;
;		Setup the effective address
;		Do the STZ operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STZ_D	Proc	Near		; Store zero to memory procedure
	DoDP				; Setup the effective address
	OpSTZ				; Do the STZ operation
	Fetch				; Fetch and execute next instruction
Op_STZ_D	Endp			; End of store zero procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 65 - ADC Direct Page
	Page	+
;******************************************************************************
;
;	Op_ADC_D ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_D	Proc	Near		; Add with carry procedure
	DoDP				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_D_DEC		; Jump if in decimal (BCD) mode
ADC_D_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_D_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_D	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 66 - ROR Direct Page
	Page	+
;******************************************************************************
;
;	Op_ROR_D ()	Rotate Memory Right
;
;		Setup the effective address
;		Do the ROR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROR_D	Proc	Near		; Rotate memory right procedure
	DoDP				; Setup the effective address
	OpROR				; Do the ROR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROR_D	Endp			; End of rotate memory right  procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 67 - ADC DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ADC_DIL ()	Add to Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_DIL	Proc	Near		; Add with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ADC_DIL	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 68 - PLA Stack/Pull
	Page	+
;******************************************************************************
;
;	Op_PLA ()	Pull Accumulator from Stack
;
;		Pop accumulator from stack
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_PLA		Proc	Near		; Pull accumulator from stack procedure
	Pop_8				; Pop accumulator from the stack
	mov	dl,al			; Update the accumulator value
	or	dl,dl			; Set the status flags correctly
	Flgnz				; Update the 65C02 processor flags
	Fetch				; Fetch and execute next instruction
Op_PLA		Endp			; End of pull accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 69 - ADC Immediate
	Page	+
;******************************************************************************
;
;	Op_ADC_I ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_I	Proc	Near		; Add with carry procedure
	DoImm				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_I_DEC		; Jump if in decimal (BCD) mode
ADC_I_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_I_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_I	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 6A - ROR Accumulator
	Page	+
;******************************************************************************
;
;	Op_ROR ()	Rotate Accumulator Right
;
;		Move 65C02 carry flag into real carry
;		Rotate the accumulator right
;		Update the 65C02 processor flags (n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROR		Proc	Near		; Rotate accumulator right procedure
	mov	al,dh			; Get 65C02 processor status flags
	shr	al,1			; Move 65C02 carry flag into real carry
	rcr	dl,1			; Rotate the accumulator right
	rcr	al,1			; Save carry result in AL register
	or	dl,dl			; Set the n and z flags correctly
	rcl	al,1			; Restore the carry result
	Flgnzc				; Update the n, z, and c flags
	Fetch				; Fetch and execute next instruction
Op_ROR		Endp			; End of rotate accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 6B - RTL Stack/RTL			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_RTL ()	Return from Subroutine
;
;		Fetch the next instruction
;
;******************************************************************************
Op_RTL		Proc	Near		; Return from subroutine procedure
	Fetch				; Fetch and execute next instruction
Op_RTL		Endp			; End of subroutine return procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 6C - JMP Absolute Indirect
	Page	+
;******************************************************************************
;
;	Op_JMP_AI ()	Jump
;
;		Setup the effective address
;		Do the JMP operation
;		Fetch the next instruction
;
;******************************************************************************
Op_JMP_AI	Proc	Near		; Jump procedure
	DoAI				; Setup the effective address
	OpJMP				; Do the JMP operation
	Fetch				; Fetch and execute next instruction
Op_JMP_AI	Endp			; End of jump procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 6D - ADC Absolute
	Page	+
;******************************************************************************
;
;	Op_ADC_A ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_A	Proc	Near		; Add with carry procedure
	DoAbs				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_A_DEC		; Jump if in decimal (BCD) mode
ADC_A_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_A_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_A	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 6E - ROR Absolute
	Page	+
;******************************************************************************
;
;	Op_ROR_A ()	Rotate Memory Right
;
;		Setup the effective address
;		Do the ROR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROR_A	Proc	Near		; Rotate memory right procedure
	DoAbs				; Setup the effective address
	OpROR				; Do the ROR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROR_A	Endp			; End of rotate memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 6F - ADC Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ADC_AL ()	Add to Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_AL	Proc	Near		; Add with carry procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ADC_AL	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 70 - BVS Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BVS ()	Branch if Overflow Set
;
;		Get the program counter offset byte
;		If the v flag is set
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BVS		Proc	Near		; Branch if overflow is set procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_V		; Check the 65C02 v (Overflow) flag
	jz	_BVS			; Jump if v flag is clear (No overflow)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BVS:
	Fetch				; Fetch and execute next instruction
Op_BVS		Endp			; End of overflow branch procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 71 - ADC DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_ADC_DIIY ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_DIIY	Proc	Near		; Add with carry procedure
	DoDIIY				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_DIIY_DEC		; Jump if in decimal (BCD) mode
ADC_DIIY_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_DIIY_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_DIIY	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 72 - ADC DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_ADC_DI ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_DI	Proc	Near		; Add with carry procedure
	DoDI				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_DI_DEC		; Jump if in decimal (BCD) mode
ADC_DI_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_DI_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_DI	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 73 - ADC SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ADC_SIIY ()	Add to Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_SIIY	Proc	Near		; Add with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ADC_SIIY	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 74 - STZ Direct Page Indexed, X		(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_STZ_DIX ()	Store Zero to Memory
;
;		Setup the effective address
;		Do the STZ operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STZ_DIX	Proc	Near		; Store zero to memory procedure
	DoDIX				; Setup the effective address
	OpSTZ				; Do the STZ operation
	Fetch				; Fetch and execute next instruction
Op_STZ_DIX	Endp			; End of store zero procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 75 - ADC DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ADC_DIX ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_DIX	Proc	Near		; Add with carry procedure
	DoDIX				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_DIX_DEC		; Jump if in decimal (BCD) mode
ADC_DIX_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_DIX_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_DIX	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 76 - ROR DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ROR_DIX ()	Rotate Memory Right
;
;		Setup the effective address
;		Do the ROR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROR_DIX	Proc	Near		; Rotate memory right procedure
	DoDIX				; Setup the effective address
	OpROR				; Do the ROR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROR_DIX	Endp			; End of rotate memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 77 - ADC DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ADC_DILIY () Add to Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_DILIY	Proc	Near		; Add with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ADC_DILIY	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 78 - SEI Implied
	Page	+
;******************************************************************************
;
;	Op_SEI ()	Set Interrupt Disable Flag
;
;		Set the interrupt disable flag
;		Fetch the next instruction
;
;******************************************************************************
Op_SEI		Proc	Near		; Set interrupt disable flag procedure
	or	dh,CPU_I		; Set the interrupt disable flag
	Fetch				; Fetch and execute next instruction
Op_SEI		Endp			; End of set interrupt flag procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 79 - ADC Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_ADC_AIY ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_AIY	Proc	Near		; Add with carry procedure
	DoAIY				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_AIY_DEC		; Jump if in decimal (BCD) mode
ADC_AIY_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_AIY_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_AIY	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 7A - PLY Stack/Pull			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_PLY ()	Pull Y Index Register from Stack
;
;		Pop Y index register from the stack
;		Fetch the next instruction
;
;******************************************************************************
Op_PLY		Proc	Near		; Pull Y index from stack procedure
	Pop_8				; Pop Y index register from the stack
	mov	cl,al			; Update the Y index register value
	Fetch				; Fetch and execute next instruction
Op_PLY		Endp			; End of pull Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 7B - TDC Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_TDC ()	Transfer Direct Page Register to Accumulator (16-Bit)
;
;		Fetch the next instruction
;
;******************************************************************************
Op_TDC		Proc	Near		; Transfer direct page to acc. procedure
	Fetch				; Fetch and execute next instruction
Op_TDC		Endp			; End of transfer direct page procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 7C - JMP Absolute Indexed Indirect, X	(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_JMP_AIIX ()	Jump
;
;		Setup the effective address
;		Do the JMP operation
;		Fetch the next instruction
;
;******************************************************************************
Op_JMP_AIIX	Proc	Near		; Jump procedure
	DoAIIX				; Setup the effective address
	OpJMP				; Do the JMP operation
	Fetch				; Fetch and execute next instruction
Op_JMP_AIIX	Endp			; End of jump procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 7D - ADC Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ADC_AIX ()	Add to Accumulator with Carry
;
;		Setup the effective address
;		If in decimal (BCD) mode
;			Do the ADC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the ADC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_AIX	Proc	Near		; Add with carry procedure
	DoAIX				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	ADC_AIX_DEC		; Jump if in decimal (BCD) mode
ADC_AIX_BIN:
	OpADCb				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
ADC_AIX_DEC:
	OpADCd				; Do the ADC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_ADC_AIX	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 7E - ROR Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_ROR_AIX ()	Rotate Memory Right
;
;		Setup the effective address
;		Do the ROR operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_ROR_AIX	Proc	Near		; Rotate memory right procedure
	DoAIX				; Setup the effective address
	OpROR				; Do the ROR operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_ROR_AIX	Endp			; End of rotate memory right procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 7F - ADC Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_ADC_ALIX ()	Add to Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_ADC_ALIX	Proc	Near		; Add with carry procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_ADC_ALIX	Endp			; End of add with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 80 - BRA Program Counter Relative	(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_BRA ()	Branch Always
;
;		Get the program counter offset byte
;		Update the program counter
;		Fetch the next instruction
;
;******************************************************************************
Op_BRA		Proc	Near		; Branch always procedure
	lodsb				; Get the program counter offset
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
	Fetch				; Fetch and execute next instruction
Op_BRA		Endp			; End of branch always procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 81 - STA DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_STA_DIIX ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_DIIX	Proc	Near		; Store accumulator procedure
	DoDIIX				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_DIIX	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 82 - BRL Program Counter Relative Long	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_BRL ()	Branch Always Long
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_BRL		Proc	Near		; Branch always procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_BRL		Endp			; End of branch always procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 83 - STA Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STA_S ()	Store Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_S	Proc	Near		; Store accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_STA_S	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 84 - STY Direct Page
	Page	+
;******************************************************************************
;
;	Op_STY_D ()	Store Y Index Register
;
;		Setup the effective address
;		Do the STY operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STY_D	Proc	Near		; Store Y index register procedure
	DoDP				; Setup the effective address
	OpSTY				; Do the STY operation
	Fetch				; Fetch and execute next instruction
Op_STY_D	Endp			; End of store Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 85 - STA Direct Page
	Page	+
;******************************************************************************
;
;	Op_STA_D ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_D	Proc	Near		; Store accumulator procedure
	DoDP				; Setup the effective address
	OPSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_D	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 86 - STX Direct Page
	Page	+
;******************************************************************************
;
;	Op_STX_D ()	Store X Index Register
;
;		Setup the effective address
;		Do the STX operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STX_D	Proc	Near		; Store X index register procedure
	DoDP				; Setup the effective address
	OpSTX				; Do the STX operation
	Fetch				; Fetch and execute next instruction
Op_STX_D	Endp			; End of store X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 87 - STA DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STA_DIL ()	Store Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_DIL	Proc	Near		; Store accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_STA_DIL	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 88 - DEY Implied
	Page	+
;******************************************************************************
;
;	Op_DEY ()	Decrement Y Index Register
;
;		Decrement the Y index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEY		Proc	Near		; Decrement Y index register procedure
	dec	cl			; Decrement the I index register
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_DEY		Endp			; End of decrement Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 89 - BIT Immediate			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_BIT_I ()	Test Memory Bits Against Accumulator
;
;		Setup the effective address
;		Do the BIT operation (Update flag bit z)
;		Fetch the next instruction
;
;******************************************************************************
Op_BIT_I	Proc	Near		; Test memory bits procedure
	DoImm				; Setup the effective address
	OpBITz				; Do the BIT operation (Update z)
	Fetch				; Fetch and execute next instruction
Op_BIT_I	Endp			; End of test memory bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 8A - TXA Implied
	Page	+
;******************************************************************************
;
;	Op_TXA ()	Transfer X Index Register to Accumulator
;
;		Transfer X index register to accumulator
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TXA		Proc	Near		; Transfer X index to acc. procedure
	mov	dl,ch			; Transfer X index to accumulator
	or	dl,dl			; Set the n and z flags correctly
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_TXA		Endp			; End of transfer X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 8B - PHB Stack/Push			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PHB ()	Push Data Bank Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_PHB		Proc	Near		; Push data bank procedure
	Fetch				; Fetch and execute next instruction
Op_PHB		Endp			; End of push data bank procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 8C - STY Absolute
	Page	+
;******************************************************************************
;
;	Op_STY_A ()	Store Y Index Register
;
;		Setup the effective address
;		Do the STY operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STY_A	Proc	Near		; Store Y index register procedure
	DoAbs				; Setup the effective address
	OpSTY				; Do the STY operation
	Fetch				; Fetch and execute next instruction
Op_STY_A	Endp			; End of store Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 8D - STA Absolute
	Page	+
;******************************************************************************
;
;	Op_STA_A ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_A	Proc	Near		; Store accumulator procedure
	DoAbs				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_A	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 8E - STX Absolute
	Page	+
;******************************************************************************
;
;	Op_STX_A ()	Store X Index Register
;
;		Setup the effective address
;		Do the STX operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STX_A	Proc	Near		; Store X index register procedure
	DoAbs				; Setup the effective address
	OpSTX				; Do the STX operation
	Fetch				; Fetch and execute next instruction
Op_STX_A	Endp			; End of store X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 8F - STA Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STA_AL ()	Store Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_AL	Proc	Near		; Store accumulator procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_STA_AL	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 90 - BCC Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BCC ()	Branch if Carry Clear
;
;		Get the program counter offset byte
;		If the c flag is clear
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BCC		Proc	Near		; Branch if carry clear procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_C		; Check the 65C02 c (Carry) flag
	jnz	_BCC			; Jump if c flag is set (Carry)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BCC:
	Fetch				; Fetch and execute next instruction
Op_BCC		Endp			; End of branch if carry clear procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 91 - STA DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_STA_DIIY ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_DIIY	Proc	Near		; Store accumulator procedure
	DoDIIY				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_DIIY	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 92 - STA DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_STA_DI ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_DI	Proc	Near		; Store accumulator procedure
	DoDI				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_DI	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 93 - STA SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STA_SIIY ()	Store Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_SIIY	Proc	Near		; Store accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_STA_SIIY	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 94 - STY Direct Page Indexed, X
	Page	+
;******************************************************************************
;
;	Op_STY_DIX ()	Store Y Index Register
;
;		Setup the effective address
;		Do the STY operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STY_DIX	Proc	Near		; Store Y index register procedure
	DoDIX				; Setup the effective address
	OpSTY				; Do the STY operation
	Fetch				; Fetch and execute next instruction
Op_STY_DIX	Endp			; End of store Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 95 - STA Direct Page Indexed, X
	Page	+
;******************************************************************************
;
;	Op_STA_DIX ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_DIX	Proc	Near		; Store accumulator procedure
	DoDIX				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_DIX	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 96 - STX Direct Page Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_STX_DIY ()	Store X Index Register
;
;		Setup the effective address
;		Do the STX operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STX_DIY	Proc	Near		; Store X index register procedure
	DoDIY				; Setup the effective address
	OpSTX				; Do the STX operation
	Fetch				; Fetch and execute next instruction
Op_STX_DIY	Endp			; End of store X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 97 - STA DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STA_DILIY () Store Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_DILIY	Proc	Near		; Store accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_STA_DILIY	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 98 - TYA Implied
	Page	+
;******************************************************************************
;
;	Op_TYA ()	Transfer Y Index Register to Accumulator
;
;		Transfer Y index register to accumulator
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TYA		Proc	Near		; Transfer Y index to acc. procedure
	mov	dl,cl			; Transfer Y index to accumulator
	or	dl,dl			; Set the n and z flags correctly
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_TYA		Endp			; End of transfer Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 99 - STA Absolute Index, Y
	Page	+
;******************************************************************************
;
;	Op_STA_AIY ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_AIY	Proc	Near		; Store accumulator procedure
	DoAIY				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_AIY	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 9A - TXS Implied
	Page	+
;******************************************************************************
;
;	Op_TXS ()	Transfer X Index Register to Stack Pointer
;
;		Transfer X index register to stack pointer
;		Fetch the next instruction
;
;******************************************************************************
Op_TXS		Proc	Near		; Transfer X index to stack procedure
	mov	bl,ch			; Transfer X index to stack pointer
	Fetch				; Fetch and execute next instruction
Op_TXS		Endp			; End of transfer X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 9B - TXY Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_TXY ()	Transfer X Index Register to Y Index Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_TXY		Proc	Near		; Transfer X index to Y index procedure
	Fetch				; Fetch and execute next instruction
Op_TXY		Endp			; End of transfer X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 9C - STZ Absolute			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_STZ_A ()	Store Zero
;
;		Setup the effective address
;		Do the STZ operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STZ_A	Proc	Near		; Store zero procedure
	DoAbs				; Setup the effective address
	OpSTZ				; Do the STZ operation
	Fetch				; Fetch and execute next instruction
Op_STZ_A	Endp			; End of store zero procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 9D - STA Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_STA_AIX ()	Store Accumulator
;
;		Setup the effective address
;		Do the STA operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_AIX	Proc	Near		; Store accumulator procedure
	DoAIX				; Setup the effective address
	OpSTA				; Do the STA operation
	Fetch				; Fetch and execute next instruction
Op_STA_AIX	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 9E - STZ Absolute Indexed, X		(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_STZ_AIX ()	Store Zero
;
;		Setup the effective address
;		Do the STZ operation
;		Fetch the next instruction
;
;******************************************************************************
Op_STZ_AIX	Proc	Near		; Store zero procedure
	DoAIX				; Setup the effective address
	OpSTZ				; Do the STZ operation
	Fetch				; Fetch and execute next instruction
Op_STZ_AIX	Endp			; End of store zero procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode 9F - STA Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STA_ALIX ()	Store Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_STA_ALIX	Proc	Near		; Store accumulator procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_STA_ALIX	Endp			; End of store accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A0 - LDY Immediate
	Page	+
;******************************************************************************
;
;	Op_LDY_I ()	Load Y Index Register
;
;		Setup the effective address
;		Do the LDY operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDY_I	Proc	Near		; Load Y index register procedure
	DoImm				; Setup the effective address
	OpLDY				; Do the LDY operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDY_I	Endp			; End of load Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A1 - LDA DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_LDA_DIIX ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_DIIX	Proc	Near		; Load accumulator procedure
	DoDIIX				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_DIIX	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A2 - LDX Immediate
	Page	+
;******************************************************************************
;
;	Op_LDX_I ()	Load X Index Register
;
;		Setup the effective address
;		Do the LDX operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDX_I	Proc	Near		; Load X index register procedure
	DoImm				; Setup the effective address
	OpLDX				; Do the LDX operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDX_I	Endp			; End of load X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A3 - LDA Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_LDA_S ()	Load Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_S	Proc	Near		; Load accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_LDA_S	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A4 - LDY Direct Page
	Page	+
;******************************************************************************
;
;	Op_LDY_D ()	Load Y Index Register
;
;		Setup the effective address
;		Do the LDY operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDY_D	Proc	Near		; Load Y index register procedure
	DoDP				; Setup the effective address
	OpLDY				; Do the LDY operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDY_D	Endp			; End of load Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A5 - LDA Direct Page
	Page	+
;******************************************************************************
;
;	Op_LDA_D ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_D	Proc	Near		; Load accumulator procedure
	DoDP				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_D	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A6 - LDX Direct Page
	Page	+
;******************************************************************************
;
;	Op_LDX_D ()	Load X Index Register
;
;		Setup the effective address
;		Do the LDX operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDX_D	Proc	Near		; Load X index register procedure
	DoDP				; Setup the effective address
	OpLDX				; Do the LDX operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDX_D	Endp			; End of load X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A7 - LDA DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_LDA_DIL ()	Load Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_DIL	Proc	Near		; Load accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_LDA_DIL	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A8 - TAY Implied
	Page	+
;******************************************************************************
;
;	Op_TAY ()	Transfer Accumulator to Y Index Register
;
;		Transfer accumulator to Y index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TAY		Proc	Near		; Transfer acc. to Y index procedure
	mov	cl,dl			; Transfer accumulator to Y index
	or	cl,cl			; Set the n and z flags correctly
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_TAY		Endp			; End of transfer accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode A9 - LDA Immediate
	Page	+
;******************************************************************************
;
;	Op_LDA_I ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_I	Proc	Near		; Load accumulator procedure
	DoImm				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_I	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode AA - TAX Implied
	Page	+
;******************************************************************************
;
;	Op_TAX ()	Transfer Accumulator to X Index Register
;
;		Transfer accumulator to X index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TAX		Proc	Near		; Transfer acc. to X index procedure
	mov	ch,dl			; Transfer accumulator to X index
	or	ch,ch			; Set the n and z flags correctly
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_TAX		Endp			; End of transfer accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode AB - PLB Stack/Pull			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PLB ()	Pull Data Bank Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_PLB		Proc	Near		; Pull data bank register procedure
	Fetch				; Fetch and execute next instruction
Op_PLB		Endp			; End of pull data bank procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode AC - LDY Absolute
	Page	+
;******************************************************************************
;
;	Op_LDY_A ()	Load Y Index Register
;
;		Setup the effective address
;		Do the LDY operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDY_A	Proc	Near		; Load Y index register procedure
	DoAbs				; Setup the effective address
	OpLDY				; Do the LDY operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDY_A	Endp			; End of load Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode AD - LDA Absolute
	Page	+
;******************************************************************************
;
;	Op_LDA_A ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_A	Proc	Near		; Load accumulator procedure
	DoAbs				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_A	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode AE - LDX Absolute
	Page	+
;******************************************************************************
;
;	Op_LDX_A ()	Load X Index Register
;
;		Setup the effective address
;		Do the LDX operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDX_A	Proc	Near		; Load X index register procedure
	DoAbs				; Setup the effective address
	OpLDX				; Do the LDX operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDX_A	Endp			; End of load X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode AF - LDA Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_LDA_AL ()	Load Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_AL	Proc	Near		; Load accumulator procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_LDA_AL	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B0 - BCS Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BCS ()	Branch if Carry Set
;
;		Get the program counter offset byte
;		If the c flag is set
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BCS		Proc	Near		; Branch if carry flag set procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_C		; Check the 65C02 c (Carry) flag
	jz	_BCS			; Jump if c flag is clear (No carry)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BCS:
	Fetch				; Fetch and execute next instruction
Op_BCS		Endp			; End of branch if carry set procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B1 - LDA DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_LDA_DIIY ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_DIIY	Proc	Near		; Load Accumulator procedure
	DoDIIY				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_DIIY	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B2 - LDA DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_LDA_DI ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_DI	Proc	Near		; Load accumulator procedure
	DoDI				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_DI	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B3 - LDA SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_LDA_SIIY ()	Load Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_SIIY	Proc	Near		; Load accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_LDA_SIIY	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B4 - LDY DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_LDY_DIX ()	Load Y Index Register
;
;		Setup the effective address
;		Do the LDY operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDY_DIX	Proc	Near		; Load Y index register procedure
	DoDIX				; Setup the effective address
	OpLDY				; Do the LDY operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDY_DIX	Endp			; End of load Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B5 - LDA DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_LDA_DIX ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_DIX	Proc	Near		; Load accumulator procedure
	DoDIX				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_DIX	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B6 - LDX DP Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_LDX_DIY ()	Load X Index Register
;
;		Setup the effective address
;		Do the LDX operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDX_DIY	Proc	Near		; Load X index register procedure
	DoDIY				; Setup the effective address
	OpLDX				; Do the LDX operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDX_DIY	Endp			; End of load X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B7 - LDA DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_LDA_DILIY () Load Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_DILIY	Proc	Near		; Load accumulator procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_LDA_DILIY	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B8 - CLV Implied
	Page	+
;******************************************************************************
;
;	Op_CLV ()	Clear Overflow Flag
;
;		Clear the overflow flag
;		Fetch the next instruction
;
;******************************************************************************
Op_CLV		Proc	Near		; Clear overflow flag procedure
	and	dh,Not CPU_V		; Clear the overflow flag bit
	Fetch				; Fetch and execute next instruction
Op_CLV		Endp			; End of clear overflow procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode B9 - LDA Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_LDA_AIY ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_AIY	Proc	Near		; Load accumulator procedure
	DoAIY				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_AIY	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode BA - TSX Implied
	Page	+
;******************************************************************************
;
;	Op_TSX ()	Transfer Stack Pointer to X Index Register
;
;		Transfer stack pointer to X index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_TSX		Proc	Near		; Transfer stack to X index procedure
	mov	ch,bl			; Transfer stack pointer to X index
	or	ch,ch			; Set the n and z flags correctly
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_TSX		Endp			; End of transfer stack procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode BB - TYX Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_TYX ()	Transfer Y Index Register to X Index Register
;
;		Fetch the next instruction
;
;******************************************************************************
Op_TYX		Proc	Near		; Transfer Y index to X index procedure
	Fetch				; Fetch and execute next instruction
Op_TYX		Endp			; End of transfer Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode BC - LDY Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_LDY_AIX ()	Load Y Index Register
;
;		Setup the effective address
;		Do the LDY operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDY_AIX	Proc	Near		; Load Y index register procedure
	DoAIX				; Setup the effective address
	OpLDY				; Do the LDY operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDY_AIX	Endp			; End of load Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode BD - LDA Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_LDA_AIX ()	Load Accumulator
;
;		Setup the effective address
;		Do the LDA operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_AIX	Proc	Near		; Load accumulator procedure
	DoAIX				; Setup the effective address
	OpLDA				; Do the LDA operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDA_AIX	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode BE - LDX Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_LDX_AIY ()	Load X Index Register
;
;		Setup the effective address
;		Do the LDX operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_LDX_AIY	Proc	Near		; Load X index register procedure
	DoAIY				; Setup the effective address
	OpLDX				; Do the LDX operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_LDX_AIY	Endp			; End of load X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode BF - LDA Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_LDA_ALIX ()	Load Accumulator
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_LDA_ALIX	Proc	Near		; Load accumulator procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_LDA_ALIX	Endp			; End of load accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C0 - CPY Immediate
	Page	+
;******************************************************************************
;
;	Op_CPY_I ()	Compare Y Index Register with Memory
;
;		Setup the effective address
;		Do the CPY operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CPY_I	Proc	Near		; Compare Y index with memory procedure
	DoImm				; Setup the effective address
	OpCPY				; Do the CPY operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CPY_I	Endp			; End of compare Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C1 - CMP DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_CMP_DIIX ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_DIIX	Proc	Near		; Compare acc. with memory procedure
	DoDIIX				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_DIIX	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C2 - REP Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_REP ()	Reset Status Bits
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_REP		Proc	Near		; Reset status bits procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_REP		Endp			; End of reset status bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C3 - CMP Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_CMP_S ()	Compare Accumulator to Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_S	Proc	Near		; Compare acc. with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_CMP_S	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C4 - CPY Direct Page
	Page	+
;******************************************************************************
;
;	Op_CPY_D ()	Compare Y Index Register with Memory
;
;		Setup the effective address
;		Do the CPY operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CPY_D	Proc	Near		; Compare Y index with memory procedure
	DoDP				; Setup the effective address
	OpCPY				; Do the CPY operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CPY_D	Endp			; End of compare Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C5 - CMP Direct Page
	Page	+
;******************************************************************************
;
;	Op_CMP_D ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_D	Proc	Near		; Compare acc. with memory procedure
	DoDP				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_D	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C6 - DEC Direct Page
	Page	+
;******************************************************************************
;
;	Op_DEC_D ()	Decrement Memory
;
;		Setup the effective address
;		Do the DEC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEC_D	Proc	Near		; Decrement memory procedure
	DoDP				; Setup the effective address
	OpDEC				; Do the DEC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_DEC_D	Endp			; End of decrement memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C7 - CMP DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_CMP_DIL ()	Compare Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_DIL	Proc	Near		; Compare acc. with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_CMP_DIL	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C8 - INY Implied
	Page	+
;******************************************************************************
;
;	Op_INY ()	Increment Y Index Register
;
;		Increment the Y index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INY		Proc	Near		; Increment Y index register procedure
	inc	cl			; Increment the Y index register
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_INY		Endp			; End of increment Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode C9 - CMP Immediate
	Page	+
;******************************************************************************
;
;	Op_CMP_I ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_I	Proc	Near		; Compare acc. with memory procedure
	DoImm				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_I	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode CA - DEX Implied
	Page	+
;******************************************************************************
;
;	Op_DEX ()	Decrement X Index Register
;
;		Decrement the X index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEX		Proc	Near		; Decrement X index register procedure
	dec	ch			; Decrement the X index register
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_DEX		Endp			; End of decrement X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode CB - WAI Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_WAI ()	Wait for Interrupt
;
;		Fetch the next instruction
;
;******************************************************************************
Op_WAI		Proc	Near		; Wait for interrupt procedure
	Fetch				; Fetch and execute next instruction
Op_WAI		Endp			; End of wait for interrupt procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode CC - CPY Absolute
	Page	+
;******************************************************************************
;
;	Op_CPY_A ()	Compare Y Index with Memory
;
;		Setup the effective address
;		Do the CPY operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CPY_A	Proc	Near		; Compare Y index with memory procedure
	DoAbs				; Setup the effective address
	OpCPY				; Do the CPY operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CPY_A	Endp			; End of compare Y index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode CD - CMP Absolute
	Page	+
;******************************************************************************
;
;	Op_CMP_A ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_A	Proc	Near		; Compare acc. with memory procedure
	DoAbs				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_A	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode CE - DEC Absolute
	Page	+
;******************************************************************************
;
;	Op_DEC_A ()	Decrement Memory
;
;		Setup the effective address
;		Do the DEC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEC_A	Proc	Near		; Decrement memory procedure
	DoAbs				; Setup the effective address
	OpDEC				; Do the DEC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_DEC_A	Endp			; End of decrement memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode CF - CMP Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_CMP_AL ()	Compare Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_AL	Proc	Near		; Compare acc. with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_CMP_AL	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D0 - BNE Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BNE ()	Branch if Not Equal
;
;		Get the program counter offset byte
;		If the z flag is clear
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BNE		Proc	Near		; Branch if not equal procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_Z		; Check the 65C02 z (Zero) flag
	jnz	_BNE			; Jump if z flag is set (Equal)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BNE:
	Fetch				; Fetch and execute next instruction
Op_BNE		Endp			; End of branch if not equal procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D1 - CMP DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_CMP_DIIY ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_DIIY	Proc	Near		; Compare acc. with memory procedure
	DoDIIY				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_DIIY	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D2 - CMP DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_CMP_DI ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_DI	Proc	Near		; Compare acc. with memory procedure
	DoDI				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_DI	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D3 - CMP SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_CMP_SIIY ()	Compare Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_SIIY	Proc	Near		; Compare acc. with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_CMP_SIIY	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D4 - PEI Stack				(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PEI ()	Push Effective Indirect Address
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_PEI		Proc	Near		; Push indirect address procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_PEI		Endp			; End of push indirect address procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D5 - CMP DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_CMP_DIX ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_DIX	Proc	Near		; Compare acc. with memory procedure
	DoDIX				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_DIX	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D6 - DEC DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_DEC_DIX ()	Decrement Memory
;
;		Setup the effective address
;		Do the DEC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEC_DIX	Proc	Near		; Decrement memory procedure
	DoDIX				; Setup the effective address
	OpDEC				; Do the DEC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_DEC_DIX	Endp			; End of decrement memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D7 - CMP DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_CMP_DILIY () Compare Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_DILIY	Proc	Near		; Compare acc. with memory procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_CMP_DILIY	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D8 - CLD Implied
	Page	+
;******************************************************************************
;
;	Op_CLD ()	Clear Decimal Mode Flag
;
;		Clear the decimal mode flag
;		Fetch the next instruction
;
;******************************************************************************
Op_CLD		Proc	Near		; Clear decimal mode flag procedure
	and	dh,Not CPU_M		; Clear the decimal mode flag bit
	Fetch				; Fetch and execute next instruction
Op_CLD		Endp			; End of clear decimal mode procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode D9 - CMP Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_CMP_AIY ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_AIY	Proc	Near		; Compare acc. with memory procedure
	DoAIY				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_AIY	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode DA - PHX Stack/Push			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_PHX ()	Push X Index Register
;
;		Push the X index register onto stack
;		Fetch the next instruction
;
;******************************************************************************
Op_PHX		Proc	Near		; Push X index register procedure
	mov	al,ch			; Get the X index register value
	Push_8				; Push X index register onto the stack
	Fetch				; Fetch and execute next instruction
Op_PHX		Endp			; End of push X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode DB - STP Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_STP ()	Stop the Processor
;
;		Fetch the next instruction
;
;******************************************************************************
Op_STP		Proc	Near		; Stop the processor procedure
	Fetch				; Fetch and execute next instruction
Op_STP		Endp			; End of stop processor procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode DC - JMP Absolute Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_JMP_AIL ()	Jump
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_JMP_AIL	Proc	Near		; Jump procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_JMP_AIL	Endp			; End of jump procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode DD - CMP Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_CMP_AIX ()	Compare Accumulator with Memory
;
;		Setup the effective address
;		Do the CMP operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_AIX	Proc	Near		; Compare acc. with memory procedure
	DoAIX				; Setup the effective address
	OpCMP				; Do the CMP operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CMP_AIX	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode DE - DEC Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_DEC_AIX ()	Decrement Memory
;
;		Setup the effective address
;		Do the DEC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_DEC_AIX	Proc	Near		; Decrement memory procedure
	DoAIX				; Setup the effective address
	OpDEC				; Do the DEC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_DEC_AIX	Endp			; End of decrement memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode DF - CMP Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_CMP_ALIX ()	Compare Accumulator with Memory
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_CMP_ALIX	Proc	Near		; Compare acc. with memory procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_CMP_ALIX	Endp			; End of compare accumulator procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E0 - CPX Immediate
	Page	+
;******************************************************************************
;
;	Op_CPX_I ()	Compare X Index Register with Memory
;
;		Setup the effective address
;		Do the CPX operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CPX_I	Proc	Near		; Compare X index with memory procedure
	DoImm				; Setup the effective address
	OpCPX				; Do the CPX operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CPX_I	Endp			; End of compare X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E1 - SBC DP Indexed Indirect, X
	Page	+
;******************************************************************************
;
;	Op_SBC_DIIX ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_DIIX	Proc	Near		; Subtract with carry procedure
	DoDIIX				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_DIIX_DEC		; Jump if in decimal (BCD) mode
SBC_DIIX_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_DIIX_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_DIIX	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E2 - SEP Immediate			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SEP ()	Set Status Bits
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SEP		Proc	Near		; Set status bits procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SEP		Endp			; End of set status bits procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E3 - SBC Stack Relative			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SBC_S ()	Subtract from Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_S	Proc	Near		; Subtract with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SBC_S	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E4 - CPX Direct Page
	Page	+
;******************************************************************************
;
;	Op_CPX_D ()	Compare X Index Register with Memory
;
;		Setup the effective address
;		Do the CPX operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CPX_D	Proc	Near		; Compare X index with memory procedure
	DoDP				; Setup the effective address
	OpCPX				; Do the CPX operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CPX_D	Endp			; End of compare X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E5 - SBC Direct Page
	Page	+
;******************************************************************************
;
;	Op_SBC_D ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_D	Proc	Near		; Subtract with carry procedure
	DoDP				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_DP_DEC		; Jump if in decimal (BCD) mode
SBC_DP_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_DP_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_D	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E6 - INC Direct Page
	Page	+
;******************************************************************************
;
;	Op_INC_D ()	Increment Memory
;
;		Setup the effective address
;		Do the INC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INC_D	Proc	Near		; Increment memory procedure
	DoDP				; Setup the effective address
	OpINC				; Do the INC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_INC_D	Endp			; End of increment memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E7 - SBC DP Indirect Long		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SBC_DIL ()	Subtract from Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_DIL	Proc	Near		; Subtract with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SBC_DIL	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E8 - INX Implied
	Page	+
;******************************************************************************
;
;	Op_INX ()	Increment X Index Register
;
;		Increment the X index register
;		Update the 65C02 processor flags (n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INX		Proc	Near		; Increment X index register procedure
	inc	ch			; Increment the X index register
	Flgnz				; Update the n and z flags
	Fetch				; Fetch and execute next instruction
Op_INX		Endp			; End of increment X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode E9 - SBC Immediate
	Page	+
;******************************************************************************
;
;	Op_SBC_I ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_I	Proc	Near		; Subtract with carry procedure
	DoImm				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_I_DEC		; Jump if in decimal (BCD) mode
SBC_I_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_I_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_I	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode EA - NOP Implied
	Page	+
;******************************************************************************
;
;	Op_NOP ()	No Operation
;
;		Fetch the next instruction
;
;******************************************************************************
Op_NOP		Proc	Near		; No operation procedure
	Fetch				; Fetch and execute next instruction
Op_NOP		Endp			; End of no operation procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode EB - XBA Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_XBA ()	Exchange the A and B Accumulators
;
;		Fetch the next instruction
;
;******************************************************************************
Op_XBA		Proc	Near		; Exchange A & B accumulators procedure
	Fetch				; Fetch and execute next instruction
Op_XBA		Endp			; End of exchange accumulators procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode EC - CPX Absolute
	Page	+
;******************************************************************************
;
;	Op_CPX_A ()	Compare X Index Register with Memory
;
;		Setup the effective address
;		Do the CPX operation (Update flag bits n, z, c)
;		Fetch the next instruction
;
;******************************************************************************
Op_CPX_A	Proc	Near		; Compare X index with memory procedure
	DoAbs				; Setup the effective address
	OpCPX				; Do the CPX operation (Update n,z,c)
	Fetch				; Fetch and execute next instruction
Op_CPX_A	Endp			; End of compare X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode ED - SBC Absolute
	Page	+
;******************************************************************************
;
;	Op_SBC_A ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_A	Proc	Near		; Subtract with carry procedure
	DoAbs				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_A_DEC		; Jump if in decimal (BCD) mode
SBC_A_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_A_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_A	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode EE - INC Absolute
	Page	+
;******************************************************************************
;
;	Op_INC_A ()	Increment Memory
;
;		Setup the effective address
;		Do the INC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INC_A	Proc	Near		; Increment memory procedure
	DoAbs				; Setup the effective address
	OpINC				; Do the INC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_INC_A	Endp			; End of increment memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode EF - SBC Absolute Long			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SBC_AL ()	Subtract from Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_AL	Proc	Near		; Subtract with carry procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SBC_AL	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F0 - BEQ Program Counter Relative
	Page	+
;******************************************************************************
;
;	Op_BEQ ()	Branch if Equal
;
;		Get the program counter offset byte
;		If the z flag is set
;			Update the program counter
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_BEQ		Proc	Near		; Branch if equal procedure
	lodsb				; Get the program counter offset
	test	dh,CPU_Z		; Check the 65C02 z (Zero) flag
	jz	_BEQ			; Jump if z flag is clear (Not equal)
	cbw				; Convert offset into a full word
	add	si,ax			; Compute the new program counter
_BEQ:
	Fetch				; Fetch and execute next instruction
Op_BEQ		Endp			; End of branch if equal procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F1 - SBC DP Indirect Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_SBC_DIIY ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_DIIY	Proc	Near		; Subtract with carry procedure
	DoDIIY				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_DIIY_DEC		; Jump if in decimal (BCD) mode
SBC_DIIY_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_DIIY_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_DIIY	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F2 - SBC DP Indirect			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_SBC_DI ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_DI	Proc	Near		; Subtract with carry procedure
	DoDI				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_DI_DEC		; Jump if in decimal (BCD) mode
SBC_DI_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_DI_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_DI	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F3 - SBC SR Indirect Indexed, Y		(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SBC_SIIY ()	Subtract from Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_SIIY	Proc	Near		; Subtract with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SBC_SIIY	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F4 - PEA Stack				(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_PEA ()	Push Effective Absolute Address
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_PEA		Proc	Near		; Push absolute address procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_PEA		Endp			; End of push absolute address procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F5 - SBC DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_SBC_DIX ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_DIX	Proc	Near		; Subtract with carry procedure
	DoDIX				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_DIX_DEC		; Jump if in decimal (BCD) mode
SBC_DIX_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_DIX_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_DIX	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F6 - INC DP Indexed, X
	Page	+
;******************************************************************************
;
;	Op_INC_DIX ()	Increment Memory
;
;		Setup the effective address
;		Do the INC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INC_DIX	Proc	Near		; Increment memory procedure
	DoDIX				; Setup the effective address
	OpINC				; Do the INC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_INC_DIX	Endp			; End of increment memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F7 - SBC DP Indirect Long Indexed, Y	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SBC_DILIY () Subtract from Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_DILIY	Proc	Near		; Subtract with carry procedure
	inc	si			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SBC_DILIY	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F8 - SED Implied
	Page	+
;******************************************************************************
;
;	Op_SED ()	Set Decimal Mode Flag
;
;		Set the decimal mode flag
;		Fetch the next instruction
;
;******************************************************************************
Op_SED		Proc	Near		; Set decimal mode flag procedure
	or	dh,CPU_M		; Set the decimal mode flag bit
	Fetch				; Fetch and execute next instruction
Op_SED		Endp			; End of set decimal mode procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode F9 - SBC Absolute Indexed, Y
	Page	+
;******************************************************************************
;
;	Op_SBC_AIY ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_AIY	Proc	Near		; Subtract with carry procedure
	DoAIY				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_AIY_DEC		; Jump if in decimal (BCD) mode
SBC_AIY_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_AIY_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_AIY	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode FA - PLX Stack/Pull			(65C02 ONLY)
	Page	+
;******************************************************************************
;
;	Op_PLX ()	Pull X Index Register from Stack
;
;		Pop X index register from stack
;		Fetch the next instruction
;
;******************************************************************************
Op_PLX		Proc	Near		; Pull X index from stack procedure
	Pop_8				; Get X index register from the stack
	mov	ch,al			; Update the X index register value
	Fetch				; Fetch and execute next instruction
Op_PLX		Endp			; End of pull X index procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode FB - XCE Implied 			(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_XCE ()	Exchange Carry and Emulation Bits
;
;		Fetch the next instruction
;
;******************************************************************************
Op_XCE		Proc	Near		; Exchange carry/emulation procedure
	Fetch				; Fetch and execute next instruction
Op_XCE		Endp			; End of exchange carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode FC - JSR Absolute Indexed Indirect, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_JSR_AIIX ()	Jump to Subroutine
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_JSR_AIIX	Proc	Near		; Jump to subroutine procedure
	add	si,2			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_JSR_AIIX	Endp			; End of jump to subroutine procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode FD - SBC Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_SBC_AIX ()	Subtract from Accumulator with Carry
;
;		Setup the effective address
;		If in decimal mode
;			Do the SBC decimal operation (Update flags n, v, z, c)
;		Else in binary mode
;			Do the SBC binary operation (Update flags n, v, z, c)
;		Endif
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_AIX	Proc	Near		; Subtract with carry procedure
	DoAIX				; Setup the effective address
	test	dh,CPU_M		; Check for in decimal mode (BCD)
	jnz	SBC_AIX_DEC		; Jump if in decimal (BCD) mode
SBC_AIX_BIN:
	OpSBCb				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
SBC_AIX_DEC:
	OpSBCd				; Do the SBC operation (Update n,v,z,c)
	Fetch				; Fetch and execute next instruction
Op_SBC_AIX	Endp			; End of subtract with carry procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode FE - INC Absolute Indexed, X
	Page	+
;******************************************************************************
;
;	Op_INC_AIX ()	Increment Memory
;
;		Setup the effective address
;		Do the INC operation (Update flag bits n, z)
;		Fetch the next instruction
;
;******************************************************************************
Op_INC_AIX	Proc	Near		; Increment memory procedure
	DoAIX				; Setup the effective address
	OpINC				; Do the INC operation (Update n,z)
	Fetch				; Fetch and execute next instruction
Op_INC_AIX	Endp			; End of increment memory procedure
	LineUp	Op_Size 		; Align the next opcode procedure
	Subttl	Opcode FF - SBC Absolute Long Indexed, X	(ILLEGAL)
	Page	+
;******************************************************************************
;
;	Op_SBC_ALIX ()	Subtract from Accumulator with Carry
;
;		Increment to the next opcode
;		Fetch the next instruction
;
;******************************************************************************
Op_SBC_ALIX	Proc	Near		; Subtract with carry procedure
	add	si,3			; Increment to the next opcode
	Fetch				; Fetch and execute next instruction
Op_SBC_ALIX	Endp			; End of subtract with carry procedure
;******************************************************************************
;
;	Define the Emulator Entry Point
;
;******************************************************************************
	LineUp	Op_Size 		; Align the emulator entry point
Emulator	Proc	Near		; Emulator procedure
	call	Initialize		; Call the initialization
Op_Fetch	Label	Near		; Fetch opcode entry point
	Fetch				; Start the emulator
Emulator	Endp			; End of emulator procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
;******************************************************************************
;
;	Define the Emulator Stack Segment
;
;******************************************************************************
Stacker Segment Word Stack 'STACK'      ; Emulator stack segment
	Db	STACK_SIZE dup (?)	; Define emulator stack (4096 Bytes)
Stacker Ends
	End	Emulator		; End of the Emulate module

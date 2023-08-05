	Page	58,132
	Title	INT.ASM 	Interrupt Processor
;******************************************************************************
;
;   Name:	INT.ASM 	Interrupt Processor
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
;	emulator interrupt handler.
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
	Public	Int_Init		; Interrupt initialization routine
	Public	Int_Reset		; Interrupt reset routine
	Public	Int_Update		; Emulator interrupt update routine
	Public	Interrupt		; Interrupt processing routine
	Public	Dummy_Int		; Dummy interrupt processing routine
;
;  External Declarations
;
	Extrn	Timer_Int:Near		; Timer interrupt routine	(TIMER)
	Extrn	Timer_Init:Near 	; Timer initialization routine	(TIMER)
	Extrn	Timer_Reset:Near	; Timer reset routine		(TIMER)
	Extrn	Key_Int:Near		; Keyboard interrupt routine (KEYBOARD)
	Extrn	Emulator:Near		; Emulator entry point	      (EMULATE)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
	Extrn	Int_Table:Word		; Interrupt jump table		 (DATA)
	Extrn	Original_Int_8:Dword	; Original interrupt 8 vector	 (DATA)
	Extrn	Original_Int_9:Dword	; Original interrupt 9 vector	 (DATA)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
	Extrn	Emulate_Flag:Byte	; Emulator interrupt flag byte	 (DATA)
;
;  LOCAL Equates
;
MAX_INTERRUPT	Equ	08h		; Maximum interrupt count value
INT_TIMER	Equ	08h		; Timer hardware interrupt number
INT_KEY 	Equ	09h		; Keyboard hardware interrupt number
INT_MASK	Equ	7Fh		; Dummy interrupt clear mask value
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
	Subttl	Int_Init	Interrupt Initialization
	Page	+
;******************************************************************************
;
;	Int_Init()
;
;		Save the required registers
;		Save the original interrupt 8 (Timer) vector
;		Save the original interrupt 9 (Keyboard) vector
;		Set the new interrupt 8 vector
;		Call the timer initialization routine
;		Set the new interrupt 9 vector
;		Set the interrupt patched flag
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
Int_Init	Proc	Near		; Interrupt initialization procedure
	Save	ax,bx,dx,ds,es		; Save the required registers
	mov	ah,GET_VECTOR		; Get interrupt vector function code
	mov	al,INT_TIMER		; Get timer hardware interrupt (8)
	int	DOS			; Get the current timer interrupt
	mov	Word Ptr cs:[Original_Int_8 + 0],bx
	mov	Word Ptr cs:[Original_Int_8 + 2],es
	mov	ah,GET_VECTOR		; Get interrupt vector function code
	mov	al,INT_KEY		; Get keyboard hardware interrupt (9)
	int	DOS			; Get the current keyboard interrupt
	mov	Word Ptr cs:[Original_Int_9 + 0],bx
	mov	Word Ptr cs:[Original_Int_9 + 2],es
	mov	ax,cs			; Get the current CS register value
	mov	ds,ax			; Setup DS to current CS value
	lea	dx,cs:[Timer_Int]	; Get the new timer interrupt offset
	mov	ah,SET_VECTOR		; Get set interrupt vector function code
	mov	al,INT_TIMER		; Get timer hardware interrupt (8)
	int	DOS			; Set the new timer interrupt
	call	Timer_Init		; Call the timer initialization routine
	lea	dx,cs:[Key_Int] 	; Get the new keyboard interrupt offset
	mov	ah,SET_VECTOR		; Get set interrupt vector function code
	mov	al,INT_KEY		; Get keyboard hardware interrupt (9)
	int	DOS			; Set the new keyboard interrupt
	or	cs:[System_Flag],PATCHED; Set interrupts patched flag
	Restore ax,bx,dx,ds,es		; Restore the required registers
	ret				; Return to the caller
Int_Init	Endp			; End of the Int_Init procedure
	Subttl	Int_Reset	Interrupt Reset
	Page	+
;******************************************************************************
;
;	Int_Reset()
;
;		Save the required registers
;		If interrupts have been patched
;			Call the timer reset routine
;			Restore the original interrupt 8 (Timer) vector
;			Restore the original interrupt 9 (Keyboard) vector
;		Endif interrupts not patched
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
Int_Reset	Proc	Near		; Interrupt reset procedure
	Save	ax,dx,ds		; Save the required registers
	test	cs:[System_Flag],PATCHED; Check for interrupts patched
	jz	Reset_Done		; Jump if interrupts not patched
	call	Timer_Reset		; Call the timer reset routine
	mov	ah,SET_VECTOR		; Get the set interrupt function code
	mov	al,INT_TIMER		; Get timer hardware interrupt (8)
	mov	dx,Word Ptr cs:[Original_Int_8 + 0]
	mov	ds,Word Ptr cs:[Original_Int_8 + 2]
	int	DOS			; Restore original timer interrupt
	mov	ah,SET_VECTOR		; Get the set interrupt function code
	mov	al,INT_KEY		; Get keyboard hardware interrupt (9)
	mov	dx,Word Ptr cs:[Original_Int_9 + 0]
	mov	ds,Word Ptr cs:[Original_Int_9 + 2]
	int	DOS			; Restore original keyboard interrupt
Reset_Done:
	Restore ax,dx,ds		; Restore the required registers
	ret				; Return to the caller
Int_Reset	Endp			; End of the Int_Reset procedure
	Subttl	Int_Update	Emulator Interrupt Update Routine
	Page	+
;******************************************************************************
;
;	Int_Update(RAM_Space, Registers, Address, Stack_Frame)
;
;		Save the required registers
;		If currently executing 65C02 emulator
;			If there is a pending interrupt request
;				Set the emulator interrupt flag bit
;			Endif
;		Endif
;		Restore the required registers
;		Return control to the caller
;
;	Registers on Entry:
;
;		DL    - 65C02 Accumulator
;		DH    - 65C02 processor flags
;		CL    - 65C02 Y index register
;		CH    - 65C02 X index register
;		BX    - 65C02 Stack pointer
;		SI    - 65C02 Program counter
;		DI    - Current opcode address
;		DS    - 65C02 RAM space
;		SS:SP - Stack Frame
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		DH    - Emulator interrupt set if interrupt pending
;
;******************************************************************************
		Even			; Force procedure to even address
Int_Update	Proc	Near		; Emulator interrupt update procedure
	Save	bp			; Save the required registers
	mov	bp,sp			; Setup access to the stack frame
	mov	ax,cs			; Get the Emulate code segment value
	cmp	ax,ss:[bp.Current_CS]	; Check for executing in Emulate segment
	jne	Update_Exit		; Jump if NOT in the Emulate segment
	lea	ax,cs:[Emulator]	; Get emulator entry point address
	cmp	ax,ss:[bp.Current_IP]	; Check for executing 65C02 emulator
	jbe	Update_Exit		; Jump if NOT in 65C02 emulator
	test	cs:[Emulate_Flag],INT_REQUEST
	jz	Update_Exit		; Jump if no pending interrupt
	or	dh,CPU_R		; Set emulator interrupt flag bit
Update_Exit:
	Restore bp			; Restore the required registers
	ret				; Return control to the caller
Int_Update	Endp			; End of the Interrupt procedure
	Subttl	Interrupt	Interrupt Processor
	Page	+
;******************************************************************************
;
;	Interrupt(RAM_Space, Registers, Address)
;
;		Clear the emulator interrupt flag bit
;		Setup Interrupt_Counter (MAX_INTERRUPT - 1 = 7)
;		While Interrupt_Counter >= 0
;			If this interrupt bit is set
;				Jump to the correct routine for interrupt
;			Endif
;			Decrement the Interrupt_Counter
;		Endwhile
;		Go process the next opcode (Never gets here)
;
;	Registers on Entry:
;
;		DL    - 65C02 Accumulator
;		DH    - 65C02 processor flags
;		CL    - 65C02 Y index register
;		CH    - 65C02 X index register
;		BX    - 65C02 Stack pointer
;		SI    - 65C02 Program counter
;		DI    - Current opcode address
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Interrupt	Proc	Near		; Interrupt processing procedure
	and	dh,Not CPU_R		; Clear emulator interrupt flag bit
	mov	ah,MAX_INTERRUPT - 1	; Get the maximum interrupt count - 1
	mov	al,cs:[Emulate_Flag]	; Get the emulator flags (Interrupt)
Interrupt_Loop:
	shr	al,1			; Check for interrupt occurred
	jnc	Next_Interrupt		; Jump if this is not the interrupt
	mov	al,ah			; Get the interrupt number
	xor	ah,ah			; Convert interrupt number to full word
	shl	ax,1			; Convert interrupt to table index
	mov	bp,ax			; Setup to go to the correct routine
	jmp	cs:[bp + Int_Table]	; Jump to the correct interrupt routine
Next_Interrupt:
	dec	ah			; Decrement the interrupt counter
	jns	Interrupt_Loop		; Jump if more interrupts to check
	jmp	di			; Go process next opcode (Never here)
Interrupt	Endp			; End of the Interrupt procedure
	Subttl	Dummy_Int	Dummy Interrupt Routine
	Page	+
;******************************************************************************
;
;	Dummy_Int(Interrupt_Number, RAM_Space, Registers, Address)
;
;		Save the required registers
;		Calculate interrupt mask value
;		Clear the pending dummy interrupt
;		Restore the required registers
;		Go process the next opcode
;
;	Registers on Entry:
;
;		DL    - 65C02 Accumulator
;		DH    - 65C02 processor flags
;		CL    - 65C02 Y index register
;		CH    - 65C02 X index register
;		BX    - 65C02 Stack pointer
;		SI    - 65C02 Program counter
;		AX    - Interrupt number (Doubled)
;		DI    - Current opcode address
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Dummy_Int	Proc	Near		; Interrupt processing procedure
	Save	cx			; Save the required registers
	shr	ax,1			; Restore the interrupt number
	mov	ah,INT_MASK		; Get interrupt mask value
	mov	cl,al			; Get the interrupt number in CL
	ror	ah,cl			; Rotate interrupt mask into position
	and	cs:[Emulate_Flag],ah	; Clear the current dummy interrupt
	Restore cx			; Restore the required registers
	jmp	di			; Go process the current opcode
Dummy_Int	Endp			; End of the Dummy_Int procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Int module

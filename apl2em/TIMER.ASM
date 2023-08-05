	Page	58,132
	Title	TIMER.ASM	Apple Emulator Timer Routines
;******************************************************************************
;
;   Name:	TIMER.ASM	Apple Emulator Timer Routines
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
;		This module contains all the code for the Apple timer
;	routines.
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
	Public	Timer_Init		; Timer initialization routine
	Public	Timer_Reset		; Timer reset routine
	Public	Timer_Int		; Timer interrupt routine
;
;  External Declarations
;
	Extrn	Int_Update:Near 	; Interrupt update routine	  (INT)
	Extrn	Joystick_Update:Near	; Joystick update routine    (JOYSTICK)
	Extrn	Original_Int_8:Dword	; Original interrupt 8 vector	 (DATA)
;
;  LOCAL Equates
;
INT_PORT	Equ	20h		; Interrupt controller port
INT_ACK 	Equ	20h		; Interrupt acknowledge value
TIMER_PORT	Equ	40h		; Timer control port address
NEW_DIVIDER	Equ	2468h		; New timer divider (128 ticks/sec)
OLD_DIVIDER	Equ	0000h		; Old timer divider (18.2 ticks/sec)
FRAC_COUNT	Equ	0708h		; Fractional counter (7.03125)
FRAC_ONE	Equ	0100h		; Fractional constant one (1.00)
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
	Subttl	Timer_Init	Timer Initialization Routine
	Page	+
;******************************************************************************
;
;	Timer_Init()
;
;		Save the required registers
;		Output the new divider value
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
Timer_Init	Proc	Near		; Timer initialization procedure
	Save	ax			; Save the required registers
	mov	al,LOW NEW_DIVIDER	; Get the LSB of the new divider
	out	TIMER_PORT,al		; Output LSB of the new divider
	mov	al,HIGH NEW_DIVIDER	; Get the MSB of the new divider
	out	TIMER_PORT,al		; Output MSB of the new divider
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Timer_Init	Endp			; End of the Timer_Init procedure
	Subttl	Timer_Reset	Timer Reset Routine
	Page	+
;******************************************************************************
;
;	Timer_Reset()
;
;		Save the required registers
;		Reset the timer divider value
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
Timer_Reset	Proc	Near		; Timer reset procedure
	Save	ax			; Save the required registers
	mov	al,LOW OLD_DIVIDER	; Get the LSB of the old divider
	out	TIMER_PORT,al		; Output LSB of the old divider
	mov	al,HIGH OLD_DIVIDER	; Get the MSB of the old divider
	out	TIMER_PORT,al		; Output MSB of the old divider
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Timer_Reset	Endp			; End of the Timer_Reset procedure
	Subttl	Timer_Int	Timer Interrupt Routine
	Page	+
;******************************************************************************
;
;	Timer_Int()
;
;		Save the required registers
;		Call the emulator interrupt update routine
;		Call the joystick update routine
;		Decrement the time counter (Fractional one)
;		If time to call the original interrupt
;			Update the time counter (Fractional)
;			Restore the required registers
;			Jump to the original routine (Will return to caller)
;		Else NOT time to call original interrupt
;			Acknowledge the interrupt controller
;			Restore the required registers
;			Return to the caller (Interrupt Return)
;		Endif
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
Timer_Int	Proc	Near		; Timer interrupt procedure
	Save	ax			; Save the required registers
	call	Int_Update		; Call emulator interrupt update routine
	call	Joystick_Update 	; Call the joystick update routine
	mov	ax,cs:[Time_Count]	; Get the current time counter value
	sub	ax,FRAC_ONE		; Decrement the time counter value
	jnc	Timer_Finish		; Jump if NOT time for original int. 8
	add	ax,FRAC_COUNT		; Update the time counter value
	mov	cs:[Time_Count],ax	; Save the new time counter value
	Restore ax			; Restore the required registers
	jmp	cs:[Original_Int_8]	; Do original interrupt 8 (Never return)
Timer_Finish:
	mov	cs:[Time_Count],ax	; Save the new time counter value
	mov	al,INT_ACK		; Get interrupt acknowledge value
	out	INT_PORT,al		; Send acknowledgement to controller
	Restore ax			; Restore the required registers
	iret				; Return to the caller (Interrupt)
Timer_Int	Endp			; End of the Timer_Int procedure
;******************************************************************************
;
;	Define any timer variables
;
;******************************************************************************
Time_Count	Dw	FRAC_COUNT	; Original rate timer counter
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Timer module

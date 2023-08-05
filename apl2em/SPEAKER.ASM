	Page	58,132
	Title	SPEAKER.ASM	Apple Emulator Speaker Routines
;******************************************************************************
;
;   Name:	SPEAKER.ASM	Apple Emulator Speaker Routines
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
;		This module contains all the code for the Apple speaker
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
	Public	Speaker_Toggle		; Toggle speaker output routine
;
;  LOCAL Equates
;
SPEAKER_PORT	Equ	61h		; Speaker port address
SPEAKER_DATA	Equ	02h		; Speaker data bit
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
	Subttl	Speaker_Toggle	Toggle Speaker Output Routine
	Page	+
;******************************************************************************
;
;	Speaker_Toggle()
;
;		Input the speaker port value
;		Toggle speaker data bit
;		Output the new speaker port value
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Speaker_Toggle	Proc	Near		; Toggle speaker output procedure
	in	al,SPEAKER_PORT 	; Get the current speaker port value
	xor	al,SPEAKER_DATA 	; Toggle the speaker data bit
	out	SPEAKER_PORT,al 	; Output the new speaker port value
	ret				; Return to the caller
Speaker_Toggle	Endp			; End of the Speaker_Toggle procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Speaker module

	Page	58,132
	Title	CASSETTE.ASM	Apple Emulator Cassette Routine
;******************************************************************************
;
;   Name:	CASSETTE.ASM	Apple Emulator Cassette Routines
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
;		This module contains all the code for the Apple cassette
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
	Public	Cassette_Toggle 	; Toggle cassette output routine
	Public	Cassette_Input		; Cassette input routine
;
;  External Declarations
;
;	extrn				;				 (    )
;
;  LOCAL Equates
;
;		Equ			;
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
	Subttl	Cassette_Toggle Toggle Cassette Output Routine
	Page	+
;******************************************************************************
;
;	Cassette_Toggle()
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
Cassette_Toggle Proc	Near		; Toggle cassette output procedure

	ret				; Return to the caller
Cassette_Toggle Endp			; End of the Cassette_Output procedure
	Subttl	Cassette_Input	Cassette Input Routine
	Page	+
;******************************************************************************
;
;	Cassette_Input()
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
Cassette_Input	Proc	Near		; Cassette input procedure

	ret				; Return to the caller
Cassette_Input	Endp			; End of the Cassette_Input procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Cassette module

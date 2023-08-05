	Page	58,132
	Title	JOYSTICK.ASM	Apple Emulator Joystick Routines
;******************************************************************************
;
;   Name:	JOYSTICK.ASM	Apple Emulator Joystick Routines
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
;		This module contains all the code for the Apple joystick
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
	Public	Button_1		; Button 1 input routine (Joystick 1)
	Public	Button_2		; Button 2 input routine (Joystick 1)
	Public	Button_3		; Button 3 input routine
	Public	Joystick_1		; Joystick 1 input routine (X-Axis)
	Public	Joystick_2		; Joystick 2 input routine (Y-Axis)
	Public	Joystick_3		; Joystick 3 input routine
	Public	Joystick_4		; Joystick 4 input routine
	Public	Joystick_Strobe 	; Joystick strobe routine
	Public	Joystick_Mode		; Joystick mode routine
	Public	Joystick_Type		; Joystick type routine (Analog/Binary)
	Public	Joystick_Fast		; Joystick fast response mode routine
	Public	Joystick_Center 	; Joystick self-center routine
	Public	Joystick_Flight 	; Joystick flight mode routine
	Public	Joystick_Reset		; Joystick reset routine
	Public	Joystick_Dummy		; Joystick dummy routine
	Public	Joy_Up_Left		; Joystick up/left routine
	Public	Joy_Up			; Joystick up routine
	Public	Joy_Up_Right		; Joystick up/right routine
	Public	Joy_Left		; Joystick left routine
	Public	Joy_Center		; Joystick center routine
	Public	Joy_Right		; Joystick right routine
	Public	Joy_Down_Left		; Joystick down/left routine
	Public	Joy_Down		; Joystick down routine
	Public	Joy_Down_Right		; Joystick down/right routine
	Public	Joy_X_Res_Inc		; Joystick X resolution increase
	Public	Joy_X_Res_Dec		; Joystick X resolution decrease
	Public	Joy_Y_Res_Inc		; Joystick Y resolution increase
	Public	Joy_Y_Res_Dec		; Joystick Y resolution decrease
	Public	Joy_X_Cen_Inc		; Joystick X center increase
	Public	Joy_X_Cen_Dec		; Joystick X center decrease
	Public	Joy_Y_Cen_Inc		; Joystick Y center increase
	Public	Joy_Y_Cen_Dec		; Joystick Y center decrease
	Public	Joy_Button_1		; Joystick button 1 routine
	Public	Joy_Button_2		; Joystick button 2 routine
	Public	Joystick_Update 	; Joystick update routine
;
;  External Declarations
;
	Extrn	Key_Status:Byte 	; Keyboard status byte	     (KEYBOARD)
	Extrn	Last_Key:Byte		; Last keyboard scan code    (KEYBOARD)
;
;  LOCAL Equates
;
CENTER_VALUE	Equ	7F00h		; Joystick center value (7Fh = 127)
START_RES	Equ	0028h		; Starting resolution (0028h = 0.15625)
MIN_RES 	Equ	0001h		; Minimum resolution (0001h = .0039)
MAX_RES 	Equ	7FFFh		; Maximum resolution (7FFFh = 127.996)
MIN_CENTER	Equ	00001h		; Minimum center (0001h = .0039)
MAX_CENTER	Equ	0FFFFh		; Maximum center (FFFFh = 255.996)
JOY_MIN 	Equ	00000h		; Joystick minimum setting value
JOY_MAX 	Equ	0FFFFh		; Joystick maximum setting value
SMALL_RES	Equ	0001h		; Small resolution change (01h = .004)
NORMAL_RES	Equ	0010h		; Normal resolution change (10h = .0625)
SMALL_CENTER	Equ	0100h		; Small center change value (0100 = 1)
NORMAL_CENTER	Equ	0400h		; Normal center change value (0400 = 4)
RESET_MASK	Equ	0FCh		; Forced reset mask (Direction/Buttons)
BUTTON_DOWN	Equ	80h		; Button down indication value
CHARGED 	Equ	80h		; Joystick charged indication value
RESET_JOY	Equ	BINARY_TYPE	; Joystick reset value (Binary)
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
	Subttl	Button_1	Button 1 Input Routine
	Page	+
;******************************************************************************
;
;	Button_1()	Joystick 1 Button
;
;		Default to button 1 NOT down
;		If button 1 is down
;			Indicate that button 1 is down
;		Endif for button check
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AL    - Joystick button 1 status (00h = Up, 80h = Down)
;
;******************************************************************************
		Even			; Force procedure to even address
Button_1	Proc	Near		; Button 1 input procedure
	xor	al,al			; Default to button NOT down
	test	cs:[Joy_Flag],BUTTON_1_DOWN
	jz	Button_1_Exit		; Jump if button 1 is NOT down
	mov	al,BUTTON_DOWN		; Indicate button 1 is down
Button_1_Exit:
	ret				; Return to the caller
Button_1	Endp			; End of the Button_1 procedure
	Subttl	Button_2	Button 2 Input Routine
	Page	+
;******************************************************************************
;
;	Button_2()	Joystick 2 Button
;
;		Default to button 2 NOT down
;		If button 2 is down
;			Indicate that button 2 is down
;		Endif for button check
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
Button_2	Proc	Near		; Button 2 input procedure
	xor	al,al			; Default to button NOT down
	test	cs:[Joy_Flag],BUTTON_2_DOWN
	jz	Button_2_Exit		; Jump if button 2 is NOT down
	mov	al,BUTTON_DOWN		; Indicate button 2 is down
Button_2_Exit:
	ret				; Return to the caller
Button_2	Endp			; End of the Button_2 procedure
	Subttl	Button_3	Button 3 Input Routine
	Page	+
;******************************************************************************
;
;	Button_3()	NOT SUPPORTED
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
Button_3	Proc	Near		; Button 3 input procedure
	ret				; Return to the caller
Button_3	Endp			; End of the Button_3 procedure
	Subttl	Joystick_1	Joystick 1 Input Routine
	Page	+
;******************************************************************************
;
;	Joystick_1()	Joystick 1 X-Axis
;
;		Save the required registers
;		Default to discharged state
;		If keyboard is in the joystick mode
;			Get the X counter value
;			If the counter value is non-zero
;				Indicate in charged state
;				Decrement the counter value
;				Update the counter value
;			Endif for non-zero counter
;		Endif for keyboard in joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AL    - Joystick status (00h = Discharged, 80h = Charged)
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_1	Proc	Near		; Joystick 1 input procedure
	Save	bx			; Save the required registers
	xor	al,al			; Default to discharged state
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Joy_1_Done		; Jump if NOT in joystick mode
	mov	bl,cs:[Joy_X_Count]	; Get the current X count value
	or	bl,bl			; CHeck for already discharged
	jz	Joy_1_Done		; Jump if already discharged
	mov	al,CHARGED		; Indicate joystick still charged
	dec	bl			; Decrement the X count value
	mov	cs:[Joy_X_Count],bl	; Update the X count value
Joy_1_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joystick_1	Endp			; End of the Joystick_1 procedure
	Subttl	Joystick_2	Joystick 2 Input Routine
	Page	+
;******************************************************************************
;
;	Joystick_2()	Joystick 2 Y-Axis
;
;		Save the required registers
;		Default to discharged state
;		If keyboard is in the joystick mode
;			Get the Y counter value
;			If the counter value is non-zero
;				Indicate in charged state
;				Decrement the counter value
;				Update the counter value
;			Endif for non-zero counter
;		Endif for keyboard in joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AL    - Joystick status (00h = Discharged, 80h = Charged)
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_2	Proc	Near		; Joystick 2 input procedure
	Save	bx			; Save the required registers
	xor	al,al			; Default to discharged state
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Joy_1_Done		; Jump if NOT in joystick mode
	mov	bl,cs:[Joy_Y_Count]	; Get the current Y count value
	or	bl,bl			; CHeck for already discharged
	jz	Joy_2_Done		; Jump if already discharged
	mov	al,CHARGED		; Indicate joystick still charged
	dec	bl			; Decrement the Y count value
	mov	cs:[Joy_Y_Count],bl	; Update the Y count value
Joy_2_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joystick_2	Endp			; End of the Joystick_2 procedure
	Subttl	Joystick_3	Joystick 3 Input Routine
	Page	+
;******************************************************************************
;
;	Joystick_3()	NOT SUPPORTED
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
Joystick_3	Proc	Near		; Joystick 3 input procedure
	ret				; Return to the caller
Joystick_3	Endp			; End of the Joystick_3 procedure
	Subttl	Joystick_4	Joystick 4 Input Routine
	Page	+
;******************************************************************************
;
;	Joystick_4()	NOT SUPPORTED
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
Joystick_4	Proc	Near		; Joystick 4 input procedure
	ret				; Return to the caller
Joystick_4	Endp			; End of the Joystick_4 procedure
	Subttl	Joystick_Strobe Joystick Strobe Routine
	Page	+
;******************************************************************************
;
;	Joystick_Strobe()
;
;		Save the required registers
;		If keyboard in joystick mode
;			Get the current X position
;			Get the current Y position
;			Save X position as X counter
;			Save Y position as Y counter
;		Endif
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
Joystick_Strobe Proc	Near		; Joystick strobe procedure
	Save	ax,bx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Strobe_Done		; Jump if NOT in joystick mode
	mov	ax,cs:[Joy_X_Pos]	; Get the current X position
	mov	bx,cs:[Joy_Y_Pos]	; Get the current Y position
	mov	cs:[Joy_X_Count],ah	; Save X position as the X count value
	mov	cs:[Joy_Y_Count],bh	; Save Y position as the Y count value
Strobe_Done:
	Restore ax,bx			; Restore the required registers
	ret				; Return to the caller
Joystick_Strobe Endp			; End of the Joystick_Strobe procedure
	Subttl	Joystick_Fast	Joystick Fast Response Mode Routine
	Page	+
;******************************************************************************
;
;	Joystick_Fast(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Toggle the joystick fast response mode bit
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_Fast	Proc	Near		; Joystick fast response mode procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Fast_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Fast_Done		; Jump if this is a break code
	xor	Byte Ptr cs:[Joy_Flag],FAST_MODE
Fast_Done:
	ret				; Return to the caller
Joystick_Fast	Endp			; End of the Joystick_Fast procedure
	Subttl	Joystick_Center Joystick Self-Center Mode Routine
	Page	+
;******************************************************************************
;
;	Joystick_Center(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Toggle the joystick self-center mode bit
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_Center Proc	Near		; Joystick self-center mode procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Self_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Self_Done		; Jump if this is a break code
	xor	Byte Ptr cs:[Joy_Flag],SELF_CENTER
Self_Done:
	ret				; Return to the caller
Joystick_Center Endp			; End of the Joystick_Center procedure
	Subttl	Joystick_Flight Joystick Flight Mode Routine
	Page	+
;******************************************************************************
;
;	Joystick_Flight(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Toggle the joystick flight mode bit
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_Flight Proc	Near		; Joystick flight mode procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Flight_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Flight_Done		; Jump if this is a break code
	xor	Byte Ptr cs:[Joy_Flag],FLIGHT_MODE
Flight_Done:
	ret				; Return to the caller
Joystick_Flight Endp			; End of the Joystick_Flight procedure
	Subttl	Joystick_Reset	Joystick Reset Routine
	Page	+
;******************************************************************************
;
;	Joystick_Reset(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Reset joystick position to center
;				Reset joystick center values
;				Reset joystick X/Y resolutions
;				Reset joystick type & mode values
;				Reset the joystick status
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_Reset	Proc	Near		; Joystick reset procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Reset_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Reset_Done		; Jump if this is a break code
	mov	cs:[Joy_X_Pos],CENTER_VALUE
	mov	cs:[Joy_Y_Pos],CENTER_VALUE
	mov	cs:[Joy_X_Center],CENTER_VALUE
	mov	cs:[Joy_Y_Center],CENTER_VALUE
	mov	cs:[Joy_X_Res],START_RES
	mov	cs:[Joy_Y_Res],START_RES
	mov	Byte Ptr cs:[Joy_Flag],RESET_JOY
Reset_Done:
	ret				; Return to the caller
Joystick_Reset	Endp			; End of the Joystick_Reset procedure
	Subttl	Joystick_Mode	Joystick Mode Routine
	Page	+
;******************************************************************************
;
;	Joystick_Mode(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Reset joystick status (Direction and buttons)
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_Mode	Proc	Near		; Joystick mode procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Mode_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Mode_Done		; Jump if this is a break code
	and	Byte Ptr cs:[Joy_Flag],RESET_MASK
Mode_Done:
	ret				; Return to the caller
Joystick_Mode	Endp			; End of the Joystick_Mode procedure
	Subttl	Joystick_Type	Joystick Type Routine
	Page	+
;******************************************************************************
;
;	Joystick_Type(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Toggle the joystick type bit
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joystick_Type	Proc	Near		; Joystick type procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Type_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Type_Done		; Jump if this is a break code
	xor	Byte Ptr cs:[Joy_Flag],BINARY_TYPE
Type_Done:
	ret				; Return to the caller
Joystick_Type	Endp			; End of the Joystick_Type procedure
	Subttl	Joystick_Dummy	Joystick Dummy Routine
	Page	+
;******************************************************************************
;
;	Joystick_Dummy()
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
Joystick_Dummy	Proc	Near		; Joystick dummy procedure
	ret				; Return to the caller
Joystick_Dummy	Endp			; End of the Joystick_Dummy procedure
	Subttl	Joy_Up_Left	Joystick Up/Left Routine
	Page	+
;******************************************************************************
;
;	Joy_Up_Left(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the up/left flag bit
;			If joystick type is binary
;				Set joystick X position to JOY_MIN
;				Set joystick Y position to JOY_MIN
;			Else
;				If joystick mode is fast response
;					If X position is > X center value
;						Set X position to X center value
;					Endif
;					If Y position is > Y center value
;						Set Y position to Y center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the up/left flag bit
;			If this is self-center mode
;				Set joystick X position to X center value
;				Set joystick Y position to Y center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Up_Left	Proc	Near		; Joystick up/left procedure
	Save	bx,cx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Up_Left_Break		; Jump if this is a break code
Up_Left_Make:
	or	Byte Ptr cs:[Joy_Status],UP_LEFT
	mov	bx,cs:[Joy_X_Pos]	; Get the current joystick X position
	mov	cx,cs:[Joy_Y_Pos]	; Get the current joystick Y position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Up_Left_Check		; Jump if NOT in binary mode
	mov	bx,JOY_MIN		; Set X position to joystick minimum
	mov	cx,JOY_MIN		; Set Y position to joystick minimum
	jmp	Short Up_Left_Update	; Go update the X and Y positions
Up_Left_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Up_Left_Done		; Jump if NOT in fast response mode
	cmp	bx,cs:[Joy_X_Center]	; Check the current X position value
	jbe	Up_Left_Test		; Jump if already moving left
	mov	bx,cs:[Joy_X_Center]	; Center the joystick X position
Up_Left_Test:
	cmp	cx,cs:[Joy_Y_Center]	; Check the current Y position value
	jbe	Up_Left_Update		; Jump if already moving up
	mov	cx,cs:[Joy_Y_Center]	; Center the joystick Y position
Up_Left_Update:
	mov	cs:[Joy_X_Pos],bx	; Update the current X position value
	mov	cs:[Joy_Y_Pos],cx	; Update the current Y position value
	jmp	Short Up_Left_Done	; Go return to the caller
Up_Left_Break:
	and	Byte Ptr cs:[Joy_Status],Not UP_LEFT
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Up_Left_Done		; Jump if NOT in self-center mode
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Up_Left_Done:
	Restore bx,cx			; Restore the required registers
	ret				; Return to the caller
Joy_Up_Left	Endp			; End of the Joy_Up_Left procedure
	Subttl	Joy_Up		Joystick Up Routine
	Page	+
;******************************************************************************
;
;	Joy_Up(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the up flag bit
;			If joystick type is binary
;				If joystick mode is NOT flight mode
;					Set joystick X pos. to X center value
;				Endif
;				Set joystick Y position to JOY_MIN
;			Else
;				If joystick mode is fast response
;					If Y position is > Y center value
;						Set Y position to Y center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the up flag bit
;			If this is self-center mode
;				Set joystick Y position to Y center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Up		Proc	Near		; Joystick up procedure
	Save	cx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Up_Break		; Jump if this is a break code
Up_Make:
	or	Byte Ptr cs:[Joy_Status],UP
	mov	cx,cs:[Joy_Y_Pos]	; Get the current joystick Y position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Up_Check		; Jump if NOT in binary mode
	test	cs:[Joy_Flag],FLIGHT_MODE
	jnz	Up_Binary		; Jump if in flight mode
	mov	cx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],cx	; Set X position to center value
Up_Binary:
	mov	cx,JOY_MIN		; Set Y position to joystick minimum
	jmp	Short Up_Update 	; Go update the Y position
Up_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Up_Done 		; Jump if NOT in fast response mode
	cmp	cx,cs:[Joy_Y_Center]	; Check the current Y position value
	jbe	Up_Update		; Jump if already moving up
	mov	cx,cs:[Joy_Y_Center]	; Center the joystick Y position
Up_Update:
	mov	cs:[Joy_Y_Pos],cx	; Update the current Y position value
	jmp	Short Up_Done		; Go return to the caller
Up_Break:
	and	Byte Ptr cs:[Joy_Status],Not UP
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Up_Done 		; Jump if NOT in self-center mode
	mov	cx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],cx	; Set Y position to center value
Up_Done:
	Restore cx			; Restore the required registers
	ret				; Return to the caller
Joy_Up		Endp			; End of the Joy_Up procedure
	Subttl	Joy_Up_Right	Joystick Up/Right Routine
	Page	+
;******************************************************************************
;
;	Joy_Up_Right(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the up/right flag bit
;			If joystick type is binary
;				Set joystick X position to JOY_MAX
;				Set joystick Y position to JOY_MIN
;			Else
;				If joystick mode is fast response
;					If X position is <= X center value
;						Set X position to X center value
;					Endif
;					If Y position is > Y center value
;						Set Y position to Y center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the up/right flag bit
;			If this is self-center mode
;				Set joystick X position to X center value
;				Set joystick Y position to Y center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Up_Right	Proc	Near		; Joystick up/right procedure
	Save	bx,cx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Up_Right_Break		; Jump if this is a break code
Up_Right_Make:
	or	Byte Ptr cs:[Joy_Status],UP_RIGHT
	mov	bx,cs:[Joy_X_Pos]	; Get the current joystick X position
	mov	cx,cs:[Joy_Y_Pos]	; Get the current joystick Y position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Up_Right_Check		; Jump if NOT in binary mode
	mov	bx,JOY_MAX		; Set X position to joystick maximum
	mov	cx,JOY_MIN		; Set Y position to joystick minimum
	jmp	Short Up_Right_Update	; Go update the X and Y positions
Up_Right_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Up_Right_Done		; Jump if NOT in fast response mode
	cmp	bx,cs:[Joy_X_Center]	; Check the current X position value
	ja	Up_Right_Test		; Jump if already moving right
	mov	bx,cs:[Joy_X_Center]	; Center the joystick X position
Up_Right_Test:
	cmp	cx,cs:[Joy_Y_Center]	; Check the current Y position value
	jbe	Up_Right_Update 	; Jump if already moving up
	mov	cx,cs:[Joy_Y_Center]	; Center the joystick Y position
Up_Right_Update:
	mov	cs:[Joy_X_Pos],bx	; Update the current X position value
	mov	cs:[Joy_Y_Pos],cx	; Update the current Y position value
	jmp	Short Up_Right_Done	; Go return to the caller
Up_Right_Break:
	and	Byte Ptr cs:[Joy_Status],Not UP_RIGHT
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Up_Right_Done		; Jump if NOT in self-center mode
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Up_Right_Done:
	Restore bx,cx			; Restore the required registers
	ret				; Return to the caller
Joy_Up_Right	Endp			; End of the Joy_Up_Right procedure
	Subttl	Joy_Left	Joystick Left Routine
	Page	+
;******************************************************************************
;
;	Joy_Left(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the left flag bit
;			If joystick type is binary
;				If joystick mode is NOT flight mode
;					Set joystick Y pos. to Y center value
;				Endif
;				Set joystick X position to JOY_MIN
;			Else
;				If joystick mode is fast response
;					If X position is > X center value
;						Set X position to X center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the up flag bit
;			If this is self-center mode
;				Set joystick X position to X center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Left	Proc	Near		; Joystick left procedure
	Save	bx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Left_Break		; Jump if this is a break code
Left_Make:
	or	Byte Ptr cs:[Joy_Status],LEFT
	mov	bx,cs:[Joy_X_Pos]	; Get the current joystick X position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Left_Check		; Jump if NOT in binary mode
	test	cs:[Joy_Flag],FLIGHT_MODE
	jnz	Left_Binary		; Jump if in flight mode
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Left_Binary:
	mov	bx,JOY_MIN		; Set X position to joystick minimum
	jmp	Short Left_Update	; Go update the X position
Left_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Left_Done		; Jump if NOT in fast response mode
	cmp	bx,cs:[Joy_X_Center]	; Check the current X position value
	jbe	Left_Update		; Jump if already moving left
	mov	bx,cs:[Joy_X_Center]	; Center the joystick X position
Left_Update:
	mov	cs:[Joy_X_Pos],bx	; Update the current X position value
	jmp	Short Left_Done 	; Go return to the caller
Left_Break:
	and	Byte Ptr cs:[Joy_Status],Not LEFT
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Left_Done		; Jump if NOT in self-center mode
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
Left_Done:
	Restore cx			; Restore the required registers
	ret				; Return to the caller
Joy_Left	Endp			; End of the Joy_Left procedure
	Subttl	Joy_Center	Joystick Center Routine
	Page	+
;******************************************************************************
;
;	Joy_Center(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Center the joystick X and Y positions
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Center	Proc	Near		; Joystick center procedure
	Save	bx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Center_Done		; Jump if this is a break code
Center_Make:
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Center_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joy_Center	Endp			; End of the Joy_Center procedure
	Subttl	Joy_Right	Joystick Right Routine
	Page	+
;******************************************************************************
;
;	Joy_Right(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the right flag bit
;			If joystick type is binary
;				If joystick mode is NOT flight mode
;					Set joystick Y pos. to Y center value
;				Endif
;				Set joystick X position to JOY_MAX
;			Else
;				If joystick mode is fast response
;					If X position is <= X center value
;						Set X position to X center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the up flag bit
;			If this is self-center mode
;				Set joystick X position to X center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Right	Proc	Near		; Joystick right procedure
	Save	bx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Right_Break		; Jump if this is a break code
Right_Make:
	or	Byte Ptr cs:[Joy_Status],RIGHT
	mov	bx,cs:[Joy_X_Pos]	; Get the current joystick X position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Right_Check		; Jump if NOT in binary mode
	test	cs:[Joy_Flag],FLIGHT_MODE
	jnz	Right_Binary		; Jump if in flight mode
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Right_Binary:
	mov	bx,JOY_MAx		; Set X position to joystick maximum
	jmp	Short Right_Update	; Go update the X position
Right_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Right_Done		; Jump if NOT in fast response mode
	cmp	bx,cs:[Joy_X_Center]	; Check the current X position value
	ja	Right_Update		; Jump if already moving right
	mov	bx,cs:[Joy_X_Center]	; Center the joystick X position
Right_Update:
	mov	cs:[Joy_X_Pos],bx	; Update the current X position value
	jmp	Short Right_Done	; Go return to the caller
Right_Break:
	and	Byte Ptr cs:[Joy_Status],Not RIGHT
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Right_Done		; Jump if NOT in self-center mode
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
Right_Done:
	Restore cx			; Restore the required registers
	ret				; Return to the caller
Joy_Right	Endp			; End of the Joy_Right procedure
	Subttl	Joy_Down_Left	Joystick Down/Left Routine
	Page	+
;******************************************************************************
;
;	Joy_Down_Left(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the down/left flag bit
;			If joystick type is binary
;				Set joystick X position to JOY_MIN
;				Set joystick Y position to JOY_MAX
;			Else
;				If joystick mode is fast response
;					If X position is > X center value
;						Set X position to X center value
;					Endif
;					If Y position is <= Y center value
;						Set Y position to Y center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the down/left flag bit
;			If this is self-center mode
;				Set joystick X position to X center value
;				Set joystick Y position to Y center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Down_Left	Proc	Near		; Joystick down/left procedure
	Save	bx,cx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Down_Left_Break 	; Jump if this is a break code
Down_Left_Make:
	or	Byte Ptr cs:[Joy_Status],DOWN_LEFT
	mov	bx,cs:[Joy_X_Pos]	; Get the current joystick X position
	mov	cx,cs:[Joy_Y_Pos]	; Get the current joystick Y position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Down_Left_Check 	; Jump if NOT in binary mode
	mov	bx,JOY_MIN		; Set X position to joystick minimum
	mov	cx,JOY_MAX		; Set Y position to joystick maximum
	jmp	Short Down_Left_Update	; Go update the X and Y positions
Down_Left_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Down_Left_Done		; Jump if NOT in fast response mode
	cmp	bx,cs:[Joy_X_Center]	; Check the current X position value
	jbe	Down_Left_Test		; Jump if already moving left
	mov	bx,cs:[Joy_X_Center]	; Center the joystick X position
Down_Left_Test:
	cmp	cx,cs:[Joy_Y_Center]	; Check the current Y position value
	ja	Down_Left_Update	; Jump if already moving down
	mov	cx,cs:[Joy_Y_Center]	; Center the joystick Y position
Down_Left_Update:
	mov	cs:[Joy_X_Pos],bx	; Update the current X position value
	mov	cs:[Joy_Y_Pos],cx	; Update the current Y position value
	jmp	Short Down_Left_Done	; Go return to the caller
Down_Left_Break:
	and	Byte Ptr cs:[Joy_Status],Not DOWN_LEFT
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Down_Left_Done		; Jump if NOT in self-center mode
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Down_Left_Done:
	Restore bx,cx			; Restore the required registers
	ret				; Return to the caller
Joy_Down_Left	Endp			; End of the Joy_Down_Left procedure
	Subttl	Joy_Down	Joystick Down Routine
	Page	+
;******************************************************************************
;
;	Joy_Down(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the down flag bit
;			If joystick type is binary
;				If joystick mode is NOT flight mode
;					Set joystick X pos. to X center value
;				Endif
;				Set joystick Y position to JOY_MAX
;			Else
;				If joystick mode is fast response
;					If Y position is <= X center value
;						Set Y position to Y center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the down flag bit
;			If this is self-center mode
;				Set joystick Y position to Y center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Down	Proc	Near		; Joystick down procedure
	Save	cx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Down_Break		; Jump if this is a break code
Down_Make:
	or	Byte Ptr cs:[Joy_Status],DOWN
	mov	cx,cs:[Joy_Y_Pos]	; Get the current joystick Y position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Down_Check		; Jump if NOT in binary mode
	test	cs:[Joy_Flag],FLIGHT_MODE
	jnz	Down_Binary		; Jump if in flight mode
	mov	cx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],cx	; Set X position to center value
Down_Binary:
	mov	cx,JOY_MAX		; Set Y position to joystick maximum
	jmp	Short Down_Update	; Go update the Y position
Down_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Down_Done		; Jump if NOT in fast response mode
	cmp	cx,cs:[Joy_Y_Center]	; Check the current Y position value
	ja	Down_Update		; Jump if already moving down
	mov	cx,cs:[Joy_Y_Center]	; Center the joystick Y position
Down_Update:
	mov	cs:[Joy_Y_Pos],cx	; Update the current Y position value
	jmp	Short Down_Done 	; Go return to the caller
Down_Break:
	and	Byte Ptr cs:[Joy_Status],Not DOWN
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Down_Done		; Jump if NOT in self-center mode
	mov	cx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],cx	; Set Y position to center value
Down_Done:
	Restore cx			; Restore the required registers
	ret				; Return to the caller
Joy_Down	Endp			; End of the Joy_Down procedure
	Subttl	Joy_Down_Right	Joystick Down/Right Routine
	Page	+
;******************************************************************************
;
;	Joy_Down_Right(Scan_Code)
;
;		Save the required registers
;		If this is a make code
;			Set the down/right flag bit
;			If joystick type is binary
;				Set joystick X position to JOY_MAX
;				Set joystick Y position to JOY_MAX
;			Else
;				If joystick mode is fast response
;					If X position is <= X center value
;						Set X position to X center value
;					Endif
;					If Y position is <= Y center value
;						Set Y position to Y center value
;					Endif
;				Endif for joystick fast response mode
;			Endif for joystick type binary
;		Else this is a break code
;			Reset the down/right flag bit
;			If this is self-center mode
;				Set joystick X position to X center value
;				Set joystick Y position to Y center value
;			Endif for self-center mode
;		Endif for scan code
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Down_Right	Proc	Near		; Joystick down/right procedure
	Save	bx,cx			; Save the required registers
	or	ah,ah			; Check for a make or break code
	js	Down_Right_Break	; Jump if this is a break code
Down_Right_Make:
	or	Byte Ptr cs:[Joy_Status],DOWN_RIGHT
	mov	bx,cs:[Joy_X_Pos]	; Get the current joystick X position
	mov	cx,cs:[Joy_Y_Pos]	; Get the current joystick Y position
	test	cs:[Joy_Flag],BINARY_TYPE
	jz	Down_Right_Check	; Jump if NOT in binary mode
	mov	bx,JOY_MAX		; Set X position to joystick maximum
	mov	cx,JOY_MAX		; Set Y position to joystick maximum
	jmp	Short Down_Right_Update ; Go update the X and Y positions
Down_Right_Check:
	test	cs:[Joy_Flag],FAST_MODE
	jz	Down_Right_Done 	; Jump if NOT in fast response mode
	cmp	bx,cs:[Joy_X_Center]	; Check the current X position value
	ja	Down_Right_Test 	; Jump if already moving right
	mov	bx,cs:[Joy_X_Center]	; Center the joystick X position
Down_Right_Test:
	cmp	cx,cs:[Joy_Y_Center]	; Check the current Y position value
	ja	Down_Right_Update	; Jump if already moving down
	mov	cx,cs:[Joy_Y_Center]	; Center the joystick Y position
Down_Right_Update:
	mov	cs:[Joy_X_Pos],bx	; Update the current X position value
	mov	cs:[Joy_Y_Pos],cx	; Update the current Y position value
	jmp	Short Down_Right_Done	; Go return to the caller
Down_Right_Break:
	and	Byte Ptr cs:[Joy_Status],Not DOWN_RIGHT
	test	cs:[Joy_Flag],SELF_CENTER
	jz	Down_Right_Done 	; Jump if NOT in self-center mode
	mov	bx,cs:[Joy_X_Center]	; Get the current X center value
	mov	cs:[Joy_X_Pos],bx	; Set X position to center value
	mov	bx,cs:[Joy_Y_Center]	; Get the current Y center value
	mov	cs:[Joy_Y_Pos],bx	; Set Y position to center value
Down_Right_Done:
	Restore bx,cx			; Restore the required registers
	ret				; Return to the caller
Joy_Down_Right	Endp			; End of the Joy_Down_Right procedure
	Subttl	Joy_X_Res_Inc	Joystick X Resolution Increase Routine
	Page	+
;******************************************************************************
;
;	Joy_X_Res_Inc(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small X resolution increment
;				Else
;					Do a normal X resolution increment
;				Endif
;				Make sure X resolution is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_X_Res_Inc	Proc	Near		; Joystick X resolution inc. procedure
	Save	bx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	X_Res_Inc_Done		; Jump if NOT in joystick mode
	or	ah,ah			; Check for a make or break code
	js	X_Res_Inc_Done		; Jump if this is a break code
	mov	bx,cs:[Joy_X_Res]	; Get the current X resolution value
	test	cs:[Key_Status],SHIFTED ; Check for shift key down
	jz	Do_X_Res_Inc		; Jump if shift key is NOT held down
	add	bx,SMALL_RES		; Add small change value to resolution
	jmp	Short X_Res_Inc_Check	; Go check the X resolution value
Do_X_Res_Inc:
	add	bx,NORMAL_RES		; Add normal change value to resolution
X_Res_Inc_Check:
	jc	X_Res_Inc_Bad		; Jump if X increment is bad
	cmp	bx,MAX_RES		; Check against maximum resolution
	jbe	X_Res_Inc_Update	; Go update X resolution if in range
X_Res_Inc_Bad:
	mov	bx,MAX_RES		; Set X resolution to maximum value
X_Res_Inc_Update:
	mov	cs:[Joy_X_Res],bx	; Update the X resolution value
X_Res_Inc_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joy_X_Res_Inc	Endp			; End of the Joy_X_Res_Inc procedure
	Subttl	Joy_X_Res_Dec	Joystick X Resolution Decrease Routine
	Page	+
;******************************************************************************
;
;	Joy_X_Res_Dec(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small X resolution decrement
;				Else
;					Do a normal X resolution decrement
;				Endif
;				Make sure X resolution is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_X_Res_Dec	Proc	Near		; Joystick X resolution dec. procedure
	Save	bx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	X_Res_Dec_Done		; Jump if NOT in joystick mode
	or	ah,ah			; Check for a make or break code
	js	X_Res_Dec_Done		; Jump if this is a break code
	mov	bx,cs:[Joy_X_Res]	; Get the current X resolution value
	test	cs:[Key_Status],SHIFTED ; Check for Shift key down
	jz	Do_X_Res_Dec		; Jump if shift key is NOT held down
	sub	bx,SMALL_RES		; Subtract small change value
	jmp	Short X_Res_Dec_Check	; Go check the X resolution value
Do_X_Res_Dec:
	sub	bx,NORMAL_RES		; Subtract normal change value
X_Res_Dec_Check:
	jc	X_Res_Dec_Bad		; Jump if X decrement is bad
	cmp	bx,MIN_RES		; Check against minimum resolution
	jae	X_Res_Dec_Update	; Go update X resolution if in range
X_Res_Dec_Bad:
	mov	bx,MIN_RES		; Set X resolution to minimum value
X_Res_Dec_Update:
	mov	cs:[Joy_X_Res],bx	; Update the X resolution value
X_Res_Dec_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joy_X_Res_Dec	Endp			; End of the Joy_X_Res_Dec procedure
	Subttl	Joy_Y_Res_Inc	Joystick Y Resolution Increase Routine
	Page	+
;******************************************************************************
;
;	Joy_Y_Res_Inc(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small Y resolution increment
;				Else
;					Do a normal Y resolution increment
;				Endif
;				Make sure Y resolution is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Y_Res_Inc	Proc	Near		; Joystick Y resolution inc. procedure
	Save	bx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Y_Res_Inc_Done		; Jump if NOT in joystick mode
	or	ah,ah			; Check for a make or break code
	js	Y_Res_Inc_Done		; Jump if this is a break code
	mov	bx,cs:[Joy_Y_Res]	; Get the current Y resolution value
	test	cs:[Key_Status],SHIFTED ; Check for shift key down
	jz	Do_Y_Res_Inc		; Jump if shift key is NOT held down
	add	bx,SMALL_RES		; Add small change value to resolution
	jmp	Short Y_Res_Inc_Check	; Go check the Y resolution value
Do_Y_Res_Inc:
	add	bx,NORMAL_RES		; Add normal change value to resolution
Y_Res_Inc_Check:
	jc	Y_Res_Inc_Bad		; Jump if Y increment is bad
	cmp	bx,MAX_RES		; Check against maximum resolution
	jbe	Y_Res_Inc_Update	; Go update Y resolution if in range
Y_Res_Inc_Bad:
	mov	bx,MAX_RES		; Set Y resolution to maximum value
Y_Res_Inc_Update:
	mov	cs:[Joy_Y_Res],bx	; Update the Y resolution value
Y_Res_Inc_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joy_Y_Res_Inc	Endp			; End of the Joy_Y_Res_Inc procedure
	Subttl	Joy_Y_Res_Dec	Joystick Y Resolution Decrease Routine
	Page	+
;******************************************************************************
;
;	Joy_Y_Res_Dec(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small Y resolution decrement
;				Else
;					Do a normal Y resolution decrement
;				Endif
;				Make sure Y resolution is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Y_Res_Dec	Proc	Near		; Joystick Y resolution dec. procedure
	Save	bx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Y_Res_Dec_Done		; Jump if NOT joystick mode
	or	ah,ah			; Check for a make or break code
	js	Y_Res_Dec_Done		; Jump if this is a break code
	mov	bx,cs:[Joy_Y_Res]	; Get the current Y resolution value
	test	cs:[Key_Status],SHIFTED ; Check for shift key down
	jz	Do_Y_Res_Dec		; Jump if shift key is NOT held down
	sub	bx,SMALL_RES		; Subtract small change value
	jmp	Short Y_Res_Dec_Check	; Go check the Y resolution value
Do_Y_Res_Dec:
	sub	bx,NORMAL_RES		; Subtract normal change value
Y_Res_Dec_Check:
	jc	Y_Res_Dec_Bad		; Jump if Y decrement is bad
	cmp	bx,MIN_RES		; Check against minimum resolution
	jae	Y_Res_Dec_Update	; Go update Y resolution if in range
Y_Res_Dec_Bad:
	mov	bx,MIN_RES		; Set Y resolution to minimum value
Y_Res_Dec_Update:
	mov	cs:[Joy_Y_Res],bx	; Update the Y resolution value
Y_Res_Dec_Done:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Joy_Y_Res_Dec	Endp			; End of the Joy_Y_Res_Dec procedure
	Subttl	Joy_X_Cen_Inc	Joystick X Center Increase Routine
	Page	+
;******************************************************************************
;
;	Joy_X_Cen_Inc(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small X center increment
;					Do a small X position increment
;				Else
;					Do a normal X center increment
;					Do a normal X position increment
;				Endif
;				Make sure X center is in range
;				make sure X position is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_X_Cen_Inc	Proc	Near		; Joystick X center increment procedure
	Save	bx,cx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	X_Cen_Inc_Done		; Jump if NOT in joystick mode
	or	ah,ah			; Check for a make or break code
	js	X_Cen_Inc_Done		; Jump if this is a break code
	test	cs:[Key_Status],SHIFTED ; Check for shift key down
	jz	Do_X_Cen_Inc		; Jump if shift key is NOT held down
	mov	bx,SMALL_CENTER 	; Setup small change value for center
	mov	cx,SMALL_CENTER 	; Setup small change value for position
	jmp	Short X_Cen_Inc_Check	; Go check the X center value
Do_X_Cen_Inc:
	mov	bx,NORMAL_CENTER	; Setup normal change value for center
	mov	cx,NORMAL_CENTER	; Setup normal change value for position
X_Cen_Inc_Check:
	add	bx,cs:[Joy_X_Center]	; Compute the new X center value
	jc	X_Cen_Inc_Bad		; Jump if X increment is bad
	cmp	bx,MAX_CENTER		; Check against maximum center
	jbe	X_Cen_Inc_Update	; Go update X center if in range
X_Cen_Inc_Bad:
	mov	bx,MAX_CENTER		; Set X center to maximum value
X_Cen_Inc_Update:
	mov	cs:[Joy_X_Center],bx	; Update the X center value
X_Pos_Inc_Check:
	add	cx,cs:[Joy_X_Pos]	; Compute the new X position value
	jnc	X_Pos_Inc_Update	; Jump if X position is ok
	mov	cx,JOY_MAX		; Setup X position to maximum
X_Pos_Inc_Update:
	mov	cs:[Joy_X_Pos],cx	; Update the X position value
X_Cen_Inc_Done:
	Restore bx,cx			; Restore the required registers
	ret				; Return to the caller
Joy_X_Cen_Inc	Endp			; End of the Joy_X_Cen_Inc procedure
	Subttl	Joy_X_Cen_Dec	Joystick X Center Decrease Routine
	Page	+
;******************************************************************************
;
;	Joy_X_Cen_Dec(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small X center decrement
;					Do a small X position decrement
;				Else
;					Do a normal X center decrement
;					Do a normal X position decrement
;				Endif
;				Make sure X center is in range
;				Make sure X position is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_X_Cen_Dec	Proc	Near		; Joystick X center decrement procedure
	Save	ax,bx,cx		; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	X_Cen_Dec_Done		; Jump if NOT in joystick mode
	or	ah,ah			; Check for a make or break code
	js	X_Cen_Dec_Done		; Jump if this is a break code
	test	cs:[Key_Status],SHIFTED ; Check for Shift key down
	jz	Do_X_Cen_Dec		; Jump if shift key is NOT held down
	mov	bx,SMALL_CENTER 	; Setup small change value for center
	mov	cx,SMALL_CENTER 	; Setup small change value for position
	jmp	Short X_Cen_Dec_Check	; Go check the X center value
Do_X_Cen_Dec:
	mov	bx,NORMAL_CENTER	; Setup normal change value for center
	mov	cx,NORMAL_CENTER	; Setup normal change value for position
X_Cen_Dec_Check:
	mov	ax,cs:[Joy_X_Center]	; Get the current X center value
	sub	ax,bx			; Compute the new X center value
	jc	X_Cen_Dec_Bad		; Jump if X decrement is bad
	cmp	ax,MIN_CENTER		; Check against minimum center
	jae	X_Cen_Dec_Update	; Go update X center if in range
X_Cen_Dec_Bad:
	mov	ax,MIN_CENTER		; Set X center to minimum value
X_Cen_Dec_Update:
	mov	cs:[Joy_X_Center],ax	; Update the X center value
X_Pos_Dec_Check:
	mov	ax,cs:[Joy_X_Pos]	; Get the current X position value
	sub	ax,cx			; Compute the new X position value
	jnc	X_Pos_Dec_Update	; Jump if X position is ok
	mov	ax,JOY_MIN		; Setup X position to minimum
X_Pos_Dec_Update:
	mov	cs:[Joy_X_Pos],ax	; Update the X position value
X_Cen_Dec_Done:
	Restore ax,bx,cx		; Restore the required registers
	ret				; Return to the caller
Joy_X_Cen_Dec	Endp			; End of the Joy_X_Cen_Dec procedure
	Subttl	Joy_Y_Cen_Inc	Joystick Y Center Increase Routine
	Page	+
;******************************************************************************
;
;	Joy_Y_Cen_Inc(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small Y center increment
;					Do a small Y position increment
;				Else
;					Do a normal Y center increment
;					Do a normal Y position increment
;				Endif
;				Make sure Y center is in range
;				Make sure Y position is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Y_Cen_Inc	Proc	Near		; Joystick Y center increment procedure
	Save	bx,cx			; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Y_Cen_Inc_Done		; Jump if NOT in joystick mode
	or	ah,ah			; Check for a make or break code
	js	Y_Cen_Inc_Done		; Jump if this is a break code
	test	cs:[Key_Status],SHIFTED ; Check for shift key down
	jz	Do_Y_Cen_Inc		; Jump if shift key is NOT held down
	mov	bx,SMALL_CENTER 	; Setup small change value for center
	mov	cx,SMALL_CENTER 	; Setup small change value for position
	jmp	Short Y_Cen_Inc_Check	; Go check the Y center value
Do_Y_Cen_Inc:
	mov	bx,NORMAL_CENTER	; Setup normal change value for center
	mov	cx,NORMAL_CENTER	; Setup normal change value for position
Y_Cen_Inc_Check:
	add	bx,cs:[Joy_Y_Center]	; Compute the new Y center value
	jc	Y_Cen_Inc_Bad		; Jump if Y increment is bad
	cmp	bx,MAX_CENTER		; Check against maximum center
	jbe	Y_Cen_Inc_Update	; Go update Y center if in range
Y_Cen_Inc_Bad:
	mov	bx,MAX_CENTER		; Set Y center to maximum value
Y_Cen_Inc_Update:
	mov	cs:[Joy_Y_Center],bx	; Update the Y center value
Y_Pos_Inc_Check:
	add	cx,cs:[Joy_Y_Pos]	; Compute the new Y position value
	jnc	Y_Pos_Inc_Update	; Jump if Y position is ok
	mov	cx,JOY_MAX		; Setup Y position to maximum
Y_Pos_Inc_Update:
	mov	cs:[Joy_Y_Pos],cx	; Update the Y position value
Y_Cen_Inc_Done:
	Restore bx,cx			; Restore the required registers
	ret				; Return to the caller
Joy_Y_Cen_Inc	Endp			; End of the Joy_Y_Cen_Inc procedure
	Subttl	Joy_Y_Cen_Dec	Joystick Y Center Decrease Routine
	Page	+
;******************************************************************************
;
;	Joy_Y_Cen_Dec(Scan_Code)
;
;		Save the required registers
;		If this is joystick mode
;			If this is a make code
;				If the shift key is down
;					Do a small Y center decrement
;					Do a small Y position decrement
;				Else
;					Do a normal Y center decrement
;					Do a normal Y position decrement
;				Endif
;				Make sure Y center is in range
;				Make sure Y position is in range
;			Endif this is a break code
;		Endif for joystick mode
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Y_Cen_Dec	Proc	Near		; Joystick Y center decrement procedure
	Save	ax,bx,cx		; Save the required registers
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Y_Cen_Dec_Done		; Jump if NOT joystick mode
	or	ah,ah			; Check for a make or break code
	js	Y_Cen_Dec_Done		; Jump if this is a break code
	test	cs:[Key_Status],SHIFTED ; Check for shift key down
	jz	Do_Y_Cen_Dec		; Jump if shift key is NOT held down
	mov	bx,SMALL_CENTER 	; Setup small change value for center
	mov	cx,SMALL_CENTER 	; Setup small change value for position
	jmp	Short Y_Cen_Dec_Check	; Go check the Y center value
Do_Y_Cen_Dec:
	mov	bx,NORMAL_CENTER	; Setup normal change value for center
	mov	cx,NORMAL_CENTER	; Setup normal change value for position
Y_Cen_Dec_Check:
	mov	ax,cs:[Joy_Y_Center]	; Get the current Y center value
	sub	ax,bx			; Compute the new Y center value
	jc	Y_Cen_Dec_Bad		; Jump if Y decrement is bad
	cmp	ax,MIN_CENTER		; Check against minimum center
	jae	Y_Cen_Dec_Update	; Go update Y center if in range
Y_Cen_Dec_Bad:
	mov	ax,MIN_CENTER		; Set Y center to minimum value
Y_Cen_Dec_Update:
	mov	cs:[Joy_Y_Center],ax	; Update the Y center value
Y_Pos_Dec_Check:
	mov	ax,cs:[Joy_Y_Pos]	; Get the current Y position value
	sub	ax,cx			; Compute the new Y position value
	jnc	Y_Pos_Dec_Update	; Jump if Y position is ok
	mov	ax,JOY_MIN		; Setup Y position to minimum
Y_Pos_Dec_Update:
	mov	cs:[Joy_Y_Pos],ax	; Update the Y position value
Y_Cen_Dec_Done:
	Restore ax,bx,cx		; Restore the required registers
	ret				; Return to the caller
Joy_Y_Cen_Dec	Endp			; End of the Joy_Y_Cen_Dec procedure
	Subttl	Joy_Button_1	Joystick Button 1 Routine
	Page	+
;******************************************************************************
;
;	Joy_Button_1(Scan_Code)
;
;		If this is a make code
;			Set the button 1 pressed flag
;		Else this is a break code
;			Reset the button 1 pressed flag
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Button_1	Proc	Near		; Joystick button 1 procedure
	or	ah,ah			; Check for a make or break code
	js	Button_1_Break		; Jump if this is a break code
Button_1_Make:
	or	Byte Ptr cs:[Joy_Flag],BUTTON_1_DOWN
	jmp	Short Button_1_Done	; Go return to the caller
Button_1_Break:
	and	Byte Ptr cs:[Joy_Flag],Not BUTTON_1_DOWN
Button_1_Done:
	ret				; Return to the caller
Joy_Button_1	Endp			; End of the Joy_Button_1 procedure
	Subttl	Joy_Button_2	Joystick Button 2 Routine
	Page	+
;******************************************************************************
;
;	Joy_Button_2(Scan_Code)
;
;		If this is a make code
;			Set the button 2 pressed flag
;		Else this is a break code
;			Reset the button 2 pressed flag
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Joy_Button_2	Proc	Near		; Joystick button 2 procedure
	or	ah,ah			; Check for a make or break code
	js	Button_2_Break		; Jump if this is a break code
Button_2_Make:
	or	Byte Ptr cs:[Joy_Flag],BUTTON_2_DOWN
	jmp	Short Button_2_Done	; Go return to the caller
Button_2_Break:
	and	Byte Ptr cs:[Joy_Flag],Not BUTTON_2_DOWN
Button_2_Done:
	ret				; Return to the caller
Joy_Button_2	Endp			; End of the Joy_Button_2 procedure
	Subttl	Joystick_Update Joystick Update Routine
	Page	+
;******************************************************************************
;
;	Joystick_Update()
;
;		Save the required registers
;		If in joystick mode
;			If NOT a binary type joystick
;				Zero the X position delta value
;				Zero the Y position delta value
;				If the joystick up is set
;					Subtract Y resolution from Y delta value
;				Endif
;				If the joystick down is set
;					Add Y resolution to Y delta value
;				Endif
;				If the joystick left is set
;					Subtract X resolution from X delta value
;				Endif
;				If the joystick right is set
;					Add X resolution to X delta value
;				Endif
;				Add X delta value to current X position
;				Make sure X position is in range
;				Add Y delta value to current Y position
;				Make sure Y position is in range
;			Endif for binary type
;		Endif for joystick mode
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
Joystick_Update Proc	Near		; Joystick update procedure
	Save	ax,bx,cx		; Save the required registers
	mov	al,cs:[Joy_Status]	; Get the joystick status byte
	xor	bx,bx			; Zero the X position delta value
	xor	cx,cx			; Zero the Y position delta value
	test	cs:[Key_Status],JOY_MODE; Check for keyboard in joystick mode
	jz	Update_Done		; Jump if NOT in joystick mode
	test	cs:[Joy_Flag],BINARY_TYPE
	jnz	Update_Done		; Jump if in binary mode
Up_Test:
	test	al,UP + UP_LEFT + UP_RIGHT
	jz	Down_Test		; Jump if NOT moving in up direction
	sub	cx,cs:[Joy_Y_Res]	; Subtract from Y position delta value
Down_Test:
	test	al,DOWN + DOWN_LEFT + DOWN_RIGHT
	jz	Left_Test		; Jump if NOT moving in down direction
	add	cx,cs:[Joy_Y_Res]	; Add to the Y position delta value
Left_Test:
	test	al,LEFT + UP_LEFT + DOWN_LEFT
	jz	Right_Test		; Jump if NOT moving in left direction
	sub	bx,cs:[Joy_X_Res]	; Subtract from X position delta value
Right_Test:
	test	al,RIGHT + UP_RIGHT + DOWN_RIGHT
	jz	Update_X		; Jump if NOT moving in right direction
	add	bx,cs:[Joy_X_Res]	; Add to the X position delta value
Update_X:
	or	bx,bx			; Check for a positive/negative value
	js	Subtract_X		; Jump if X delta value is negative
Add_X:
	add	bx,cs:[Joy_X_Pos]	; Compute the new X position value
	jnc	Update_Y		; Jump if X update is ok
X_Update_Bad:
	mov	bx,JOY_MAX		; Set X position to joystick maximum
	jmp	Short Update_Y		; Go update the Y position value
Subtract_X:
	add	bx,cs:[Joy_X_Pos]	; Compute the new X position value
	jc	Update_Y		; Jump if X update is ok
Bad_X_Update:
	mov	bx,JOY_MIN		; Set X position to joystick minimum
Update_Y:
	or	cx,cx			; Check for a positive/negative value
	js	Subtract_Y		; Jump if Y delta value is negative
Add_Y:
	add	cx,cs:[Joy_Y_Pos]	; Compute the new Y position value
	jnc	Update_Position 	; Jump if Y update is ok
Y_Update_Bad:
	mov	cx,JOY_MAX		; Set Y position to joystick maximum
	jmp	Short Update_Position	; Go update the joystick position
Subtract_Y:
	add	cx,cs:[Joy_Y_Pos]	; Compute the new Y position value
	jc	Update_Position 	; Jump if Y update is ok
Bad_Y_Update:
	mov	cx,JOY_MIN		; Set Y position to joystick minimum
Update_Position:
	mov	cs:[Joy_X_Pos],bx	; Update the joystick X position
	mov	cs:[Joy_Y_Pos],cx	; Update the joystick Y position
Update_Done:
	Restore ax,bx,cx		; Restore the required registers
	ret				; Return to the caller
Joystick_Update Endp			; End of the Joystick_Update procedure
;******************************************************************************
;
;	Define the joystick status
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Joystick up held down
;	 | | | | | | ---------> Joystick down held down
;	 | | | | | -----------> Joystick left held down
;	 | | | | -------------> Joystick right held down
;	 | | | ---------------> Joystick up/left held down
;	 | | -----------------> Joystick up/right held down
;	 | -------------------> Joystick down/left held down
;	 ---------------------> Joystick down/right held down
;
;******************************************************************************
Joy_Status	Db	0		; Joystick status byte
UP		Equ	01h		; Joystick up position flag
DOWN		Equ	02h		; Joystick down position flag
LEFT		Equ	04h		; Joystick left position flag
RIGHT		Equ	08h		; Joystick right position flag
UP_LEFT 	Equ	10h		; Joystick up/left position flag
UP_RIGHT	Equ	20h		; Joystick up/right position flag
DOWN_LEFT	Equ	40h		; Joystick down/left position flag
DOWN_RIGHT	Equ	80h		; Joystick down/right position flag
;******************************************************************************
;
;	Define the joystick flags
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Button 1 held down
;	 | | | | | | ---------> Button 2 held down
;	 | | | | | -----------> Joystick type (0 = Analog, 1 = Binary)
;	 | | | | -------------> Joystick center mode (0 = Normal, 1 = Self)
;	 | | | ---------------> Joystick flight mode (0 = Normal, 1 = Flight)
;	 | | -----------------> Joystick response mode (0 = Slow, 1 = Fast)
;	 | -------------------> ***** Reserved *****
;	 ---------------------> ***** Reserved *****
;
;******************************************************************************
Joy_Flag	Db	BINARY_TYPE	; Joystick flag byte
BUTTON_1_DOWN	Equ	01h		; Joystick button 1 held down flag
BUTTON_2_DOWN	Equ	02h		; Joystick button 2 held down flag
BINARY_TYPE	Equ	04h		; Joystick binary type flag
SELF_CENTER	Equ	08h		; Joystick self center flag
FLIGHT_MODE	Equ	10h		; Joystick flight mode flag
FAST_MODE	Equ	20h		; Joystick fast mode flag
;******************************************************************************
;
;	Define any other joystick variables
;
;******************************************************************************
Joy_X_Pos	Dw	CENTER_VALUE	; Joystick X axis position value
Joy_Y_Pos	Dw	CENTER_VALUE	; Joystick Y axis position value
Joy_X_Center	Dw	CENTER_VALUE	; Joystick X axis center value
Joy_Y_Center	Dw	CENTER_VALUE	; Joystick Y axis center value
Joy_X_Res	Dw	START_RES	; Joystick X resolution value
Joy_Y_Res	Dw	START_RES	; Joystick Y resolution value
Joy_X_Count	Db	?		; Joystick X counter value
Joy_Y_Count	Db	?		; Joystick Y counter value
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Joystick module

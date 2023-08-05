	Page	58,132
	Title	KEYBOARD.ASM	Apple Emulator Keyboard Routines
;******************************************************************************
;
;   Name:	KEYBOARD.ASM	Apple Emulator Keyboard Routines
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
;		This module contains all the code for the Apple keyboard
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
	Public	Keyboard_Input		; Keyboard input routine
	Public	Clear_Keyboard		; Clear keyboard strobe routine
	Public	Key_Int 		; Keyboard interrupt routine
	Public	Set_LED 		; Set keyboard LED routine
	Public	Flush_Keyboard		; Flush keyboard routine
	Public	Get_Key 		; Get keyboard scan code routine
	Public	Key_Reset		; Keyboard reset routine
	Public	Key_Status		; Keyboard status byte
	Public	Last_Key		; Last actual keyboard code
	Public	Last_Scan		; Last keyboard scan code
;
;  External Declarations
;
	Extrn	Update_Toggle:Near	; Update mode toggle routine	  (EGA)
	Extrn	System_Reset:Near	; System reset routine		(APPLE)
	Extrn	System_Request:Near	; System request routine	(APPLE)
	Extrn	Joystick_Fast:Near	; Joystick fast mode routine (JOYSTICK)
	Extrn	Joystick_Flight:Near	; Joystick flight routine    (JOYSTICK)
	Extrn	Joystick_Center:Near	; Joystick center routine    (JOYSTICK)
	Extrn	Joystick_Reset:Near	; Joystick reset routine     (JOYSTICK)
	Extrn	Joystick_Mode:Near	; Joystick mode routine      (JOYSTICK)
	Extrn	Joystick_Type:Near	; Joystick type routine      (JOYSTICK)
	Extrn	Joystick_Dummy:Near	; Joystick dummy routine     (JOYSTICK)
	Extrn	Joy_Up_Left:Near	; Joystick up/left routine   (JOYSTICK)
	Extrn	Joy_Up:Near		; Joystick up routine	     (JOYSTICK)
	Extrn	Joy_Up_Right:Near	; Joystick up/right routine  (JOYSTICK)
	Extrn	Joy_Left:Near		; Joystick left routine      (JOYSTICK)
	Extrn	Joy_Center:Near 	; Joystick center routine    (JOYSTICK)
	Extrn	Joy_Right:Near		; Joystick right routine     (JOYSTICK)
	Extrn	Joy_Down_Left:Near	; Joystick down/left routine (JOYSTICK)
	Extrn	Joy_Down:Near		; Joystick down routine      (JOYSTICK)
	Extrn	Joy_Down_Right:Near	; Joystick down/right routine(JOYSTICK)
	Extrn	Joy_X_Res_Inc:Near	; Joystick X resolution inc. (JOYSTICK)
	Extrn	Joy_X_Res_Dec:Near	; Joystick X resolution dec. (JOYSTICK)
	Extrn	Joy_Y_Res_Inc:Near	; Joystick Y resolution inc. (JOYSTICK)
	Extrn	Joy_Y_Res_Dec:Near	; Joystick Y resolution dec. (JOYSTICK)
	Extrn	Joy_X_Cen_Inc:Near	; Joystick X center increment(JOYSTICK)
	Extrn	Joy_X_Cen_Dec:Near	; Joystick X center decrement(JOYSTICK)
	Extrn	Joy_Y_Cen_Inc:Near	; Joystick Y center increment(JOYSTICK)
	Extrn	Joy_Y_Cen_Dec:Near	; Joystick Y center decrement(JOYSTICK)
	Extrn	Joy_Button_1:Near	; Joystick button one	     (JOYSTICK)
	Extrn	Joy_Button_2:Near	; Joystick button two	     (JOYSTICK)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
;
;  LOCAL Equates
;
DATA_PORT	Equ	60h		; Keyboard data port address (60h)
COMMAND_PORT	Equ	64h		; Keyboard command port address (64h)
OUTPUT_FULL	Equ	01h		; Output buffer full flag bit
INPUT_EMPTY	Equ	02h		; Input buffer empty flag bit
KEY_CODE	Equ	7Fh		; Keyboard scan code mask value
KEY_MASK	Equ	07h		; Keyboard status mask value
KEY_SHIFT	Equ	03h		; Keyboard shift value
LED_MASK	Equ	0E0h		; Keyboard status LED mask value
LED_SHIFT	Equ	05h		; Keyboard status LED shift value
INT_PORT	Equ	20h		; Interrupt controller port
INT_ACK 	Equ	20h		; Interrupt acknowledge value
KEY_DOWN	Equ	80h		; Key held down flag bit
KEY_STROBE	Equ	80h		; Key has been pressed flag bit
TAB		Equ	09h		; Tab key translated code value
UP_ARROW	Equ	0Bh		; Up arrow translated code value
LEFT_ARROW	Equ	08h		; Left arrow translated code value
RIGHT_ARROW	Equ	15h		; Right arrow translated code value
DOWN_ARROW	Equ	0Ah		; Down arrow translated code value
DEL_CODE	Equ	7Fh		; DEL key translated code value
DISABLE_KEY	Equ	0ADh		; Disable keyboard function code
ENABLE_KEY	Equ	0AEh		; Enable keyboard function code
LED_SET 	Equ	0EDh		; Set keyboard LED's function code
TIME_OUT	Equ	0FFFFh		; 8042 time out counter value
Key_Data	Equ	0C000h		; Keyboard data storage byte
Any_Key 	Equ	0C010h		; Any key down storage byte
Key_LED 	Equ	0097h		; BIOS keyboard LED status byte (40:97h)
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
	Subttl	Keyboard_Input	Keyboard Input Routine
	Page	+
;******************************************************************************
;
;	Keyboard_Input()
;
;		Read the keyboard data byte (C000h)
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AL    - Keyboard data
;
;******************************************************************************
		Even			; Force procedure to even address
Keyboard_Input	Proc	Near		; Keyboard input procedure
	mov	al,ds:[Key_Data]	; Read the keyboard data byte
	ret				; Return to the caller
Keyboard_Input	Endp			; End of the Keyboard_Input procedure
	Subttl	Clear_Keyboard	Clear Keyboard Strobe Routine
	Page	+
;******************************************************************************
;
;	Clear_Keyboard()
;
;		Clear the keyboard strobe (C000h)
;		Clear the any key down flag (C010h)
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
Clear_Keyboard	Proc	Near		; Clear keyboard input procedure
	and	ds:[Key_Data],Not KEY_STROBE
	and	ds:[Any_Key],Not KEY_DOWN
	ret				; Return to the caller
Clear_Keyboard	Endp			; End of the Clear_Keyboard procedure
	Subttl	Key_Int 	Keyboard Interrupt Routine
	Page	+
;******************************************************************************
;
;	Key_Int()
;
;		Save the required registers
;		Get the key from the input port (60h)
;		Translate scan code into keyboard code value
;		If special keyboard scan code
;			Call correct routine to handle scan code
;		Else this is a standard keyboard scan code
;			If this is a make code
;					Set the keyboard strobe bit
;					Save as last keyboard code
;				If keyboard not in input mode
;					Set the any key down flag bit
;					Save the keyboard data value
;				Endif
;			Endif
;		Endif
;		Save the last scan code value
;		Acknowledge the interrupt controller
;		Restore the required registers
;		Return to the caller (Interrupt return)
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
Key_Int 	Proc	Near		; Keyboard interrupt procedure
	Save	ax,bx,cx		; Save the required registers
	in	al,DATA_PORT		; Get the keyboard scan code
	mov	ah,al			; Save scan code value in AH
	and	al,KEY_CODE		; Mask off all but keyboard scan code
	mov	bl,al			; Move scan code into BL register
	xor	bh,bh			; Convert scan code to full word
	mov	cl,cs:[Key_Status]	; Get the keyboard status value
	mov	ch,cl			; Get a copy of the keyboard status
	and	ch,cs:[bx+Caps_Table]	; Mask with the caps table entry
	rol	ch,1			; Shift caps status to shifted bit
	xor	cl,ch			; Set shift status to correct state
	and	cx,KEY_MASK		; Mask off all but desired bits
	shl	bx,KEY_SHIFT		; Convert scan code to table index
	add	bx,cx			; Compute actual table entry
	mov	bl,cs:[bx+Key_Translate]; Translate the keyboard scan code
	or	bl,bl			; Set the status bits correctly
	js	Special_Key		; Jump if this is a special key
	or	ah,ah			; Check for a make/break code
	js	Key_Break		; Jump if this is a break code
Key_Make:
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	cs:[Last_Key],bl	; Save last actual keyboard code
	test	cs:[System_Flag],INPUT	; Check for keyboard in input mode
	jnz	Key_Done		; Jump if NOT in normal keyboard mode
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	mov	ds:[Key_Data],bl	; Save keyboard data for 65C02
	jmp	Short Key_Done		; Go return to the caller
Key_Break:
	and	Byte Ptr ds:[Any_Key],Not KEY_DOWN
	jmp	Short Key_Done		; Go return to the caller
Special_Key:
	shl	bl,1			; Convert key code to table index
	xor	bh,bh			; Convert table index to full word
	call	cs:[bx + Key_Table]	; Call the correct key routine
Key_Done:
	mov	al,INT_ACK		; Get interrupt acknowledge value
	out	INT_PORT,al		; Send acknowledgement to controller
	mov	cs:[Last_Scan],ah	; Save the last scan code value
	Restore ax,bx,cx		; Restore the required registers
	iret				; Return to the caller (Interrupt)
Key_Int 	Endp			; End of the Key_Int procedure
	Subttl	Flush_Keyboard	Flush Keyboard Routine
	Page	+
;******************************************************************************
;
;	Flush_Keyboard()
;
;		Clear the keyboard strobe
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
Flush_Keyboard	Proc	Near		; Flush keyboard input procedure
	and	Byte Ptr cs:[Last_Key],Not KEY_STROBE
	ret				; Return to the caller
Flush_Keyboard	Endp			; End of the Flush_Keyboard procedure
	Subttl	Get_Key 	Get Keyboard Scan Code Routine
	Page	+
;******************************************************************************
;
;	Get_Key()
;
;		While no keyboard strobe
;			Wait for keyboard strobe
;		EndWhile
;		Clear the keyboard strobe
;		Get the keyboard scan code
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AL    - Keyboard scan code
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Key 	Proc	Near		; Clear keyboard input procedure
	test	cs:[Last_Key],KEY_STROBE; Check for a keyboard strobe
	jz	Get_Key 		; Jump if no key is available
	and	Byte Ptr cs:[Last_Key],Not KEY_STROBE
	mov	al,cs:[Last_Key]	; Get the last actual key scan code
	ret				; Return to the caller
Get_Key 	Endp			; End of the Get_Key procedure
	Subttl	Illegal_Key	Illegal Scan Code Routine
	Page	+
;******************************************************************************
;
;	Illegal_Key(Scan_Code)
;
;		Get the last scan code value (No scan code change)
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Scan code value
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Illegal_Key	Proc	Near		; Illegal scan code procedure
	mov	ah,cs:[Last_Scan]	; Get last scan code for key save
	ret				; Return to the caller
Illegal_Key	Endp			; End of the Illegal_Key procedure
	Subttl	Control_Key	Control Key Routine
	Page	+
;******************************************************************************
;
;	Control_Key(Scan_Code)
;
;		If this is a make code
;			Set the control bit in the keyboard status
;		Else this is a break code
;			Clear the control bit in the keyboard status
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Control key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Control_Key	Proc	Near		; Control key procedure
	or	ah,ah			; Check for a make or break code
	js	Control_Break		; Jump if this is a break code
Control_Make:
	or	Byte Ptr cs:[Key_Status],CTRLED
	jmp	Short Control_Done	; Go return to the caller
Control_Break:
	and	Byte Ptr cs:[Key_Status],Not CTRLED
Control_Done:
	ret				; Return to the caller
Control_Key	Endp			; End of the Control_Key procedure
	Subttl	Tab_Key 	Tab Key Routine
	Page	+
;******************************************************************************
;
;	Tab_Key(Scan_Code)
;
;		If NOT in joystick mode
;			If this is a make code
;				Get the tab key code
;				Set the any key down flag bit
;				Set the keyboard strobe bit
;				Save the keyboard data value
;			Endif
;		Else in the joystick mode
;			Call the joystick button 1 routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Tab key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Tab_Key 	Proc	Near		; Tab key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jnz	Do_Button		; Jump if this is joystick mode
	or	ah,ah			; Check for a make or break code
	js	Tab_Done		; Jump if this is a break code
	mov	bl,TAB			; Get the tab translated code
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	ds:[Key_Data],bl	; Save the keyboard data value
	jmp	Short Tab_Done		; Go return to the caller
Do_Button:
	call	Joy_Button_1		; Call the joystick button 1 routine
Tab_Done:
	ret				; Return to the caller
Tab_Key 	Endp			; End of the Tab_Key procedure
	Subttl	Alt_Key 	Alternate Key Routine
	Page	+
;******************************************************************************
;
;	Alt_Key(Scan_Code)
;
;		If this is a make code
;			Set the alternate bit in the keyboard status
;		Else this is a break code
;			Clear the alternate bit in the keyboard status
;		Endif
;		If in joystick mode
;			Call the joystick button 2 routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Control key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Alt_Key 	Proc	Near		; Alternate key procedure
	or	ah,ah			; Check for a make or break code
	js	Alt_Break		; Jump if this is a break code
Alt_Make:
	or	Byte Ptr cs:[Key_Status],ALTED
	jmp	Short Alt_Test		; Go check for joystick mode
Alt_Break:
	and	Byte Ptr cs:[Key_Status],Not ALTED
Alt_Test:
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Alt_Done		; Jump if this is NOT joystick mode
	call	Joy_Button_2		; Call the joystick button 2 routine
Alt_Done:
	ret				; Return to the caller
Alt_Key 	Endp			; End of the Alt_Key procedure
	Subttl	Shift_Key	Shift Key Routine
	Page	+
;******************************************************************************
;
;	Shift_Key(Scan_Code)
;
;		If this is a make code
;			Set the shift bit in the keyboard status
;		Else this is a break code
;			Clear the shift bit in the keyboard status
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Shift key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Shift_Key	Proc	Near		; Shift key procedure
	or	ah,ah			; Check for a make or break code
	js	Shift_Break		; Jump if this is a break code
Shift_Make:
	or	Byte Ptr cs:[Key_Status],SHIFTED
	jmp	Short Shift_Done	; Go return to the caller
Shift_Break:
	and	Byte Ptr cs:[Key_Status],Not SHIFTED
Shift_Done:
	ret				; Return to the caller
Shift_Key	Endp			; End of the Shift_Key procedure
	Subttl	Caps_Lock	Caps Lock Key Routine
	Page	+
;******************************************************************************
;
;	Caps_Lock(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Toggle the caps lock status bit
;			Endif
;		Endif
;		Call routine to update the LED status
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Caps lock key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Caps_Lock	Proc	Near		; Caps lock key procedure
	cmp	ah,cs:[Last_Scan]	; Check for a repeat scan code
	je	Caps_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Caps_Done		; Jump if this is a break code
	xor	Byte Ptr cs:[Key_Status],CAPS_LOCKED
Caps_Done:
	call	Set_LED 		; Update the keyboard LED status
	ret				; Return to the caller
Caps_Lock	Endp			; End of the Caps_Lock procedure
	Subttl	Home_Key	Home Key Routine
	Page	+
;******************************************************************************
;
;	Home_Key(Scan_Code)
;
;		If in joystick mode
;			Call the joystick up/left routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Home key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Home_Key	Proc	Near		; Home key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Home_Done		; Jump if this is NOT joystick mode
	call	Joy_Up_Left		; Call the joystick up/left routine
Home_Done:
	ret				; Return to the caller
Home_Key	Endp			; End of the Home_Key procedure
	Subttl	Up_Key		Up Key Routine
	Page	+
;******************************************************************************
;
;	Up_Key(Scan_Code)
;
;		If NOT in joystick mode
;			If this is a make code
;				Get the up arrow key code
;				Set the any key down flag bit
;				Set the keyboard strobe bit
;				Save the keyboard data value
;			Endif
;		Else in the joystick mode
;			Call the joystick up routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Up key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Up_Key		Proc	Near		; Up key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jnz	Do_Up			; Jump if this is joystick mode
	or	ah,ah			; Check for a make or break code
	js	Up_Done 		; Jump if this is a break code
	mov	bl,UP_ARROW		; Get the up arrow translated code
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	ds:[Key_Data],bl	; Save the keyboard data value
	jmp	Short Up_Done		; Go return to the caller
Do_Up:
	call	Joy_Up			; Call the joystick up routine
Up_Done:
	ret				; Return to the caller
Up_Key		Endp			; End of the Up_Key procedure
	Subttl	PgUp_Key	PgUp Key Routine
	Page	+
;******************************************************************************
;
;	PgUp_Key(Scan_Code)
;
;		If in joystick mode
;			Call the joystick up/right routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - PgUp key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
PgUp_Key	Proc	Near		; PgUp key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	PgUp_Done		; Jump if this is NOT joystick mode
	call	Joy_Up_Right		; Call the joystick up/right routine
PgUp_Done:
	ret				; Return to the caller
PgUp_Key	Endp			; End of the PgUp_Key procedure
	Subttl	Left_Key	Left Key Routine
	Page	+
;******************************************************************************
;
;	Left_Key(Scan_Code)
;
;		If NOT in joystick mode
;			If this is a make code
;				Get the left arrow key code
;				Set the any key down flag bit
;				Set the keyboard strobe bit
;				Save the keyboard data value
;			Endif
;		Else in the joystick mode
;			Call the joystick left routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Left key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Left_Key	Proc	Near		; Left key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jnz	Do_Left 		; Jump if this is joystick mode
	or	ah,ah			; Check for a make or break code
	js	Left_Done		; Jump if this is a break code
	mov	bl,LEFT_ARROW		; Get the left arrow translated code
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	ds:[Key_Data],bl	; Save the keyboard data value
	jmp	Short Left_Done 	; Go return to the caller
Do_Left:
	call	Joy_Left		; Call the joystick left routine
Left_Done:
	ret				; Return to the caller
Left_Key	Endp			; End of the Left_Key procedure
	Subttl	Center_Key	Center Key Routine
	Page	+
;******************************************************************************
;
;	Center_Key(Scan_Code)
;
;		If in joystick mode
;			Call the joystick center routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Center key scan code (Pad 5)
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Center_Key	Proc	Near		; Center key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Center_Done		; Jump if this is NOT joystick mode
	call	Joy_Center		; Call the joystick center routine
Center_Done:
	ret				; Return to the caller
Center_Key	Endp			; End of the Center_Key procedure
	Subttl	Right_Key	Right Key Routine
	Page	+
;******************************************************************************
;
;	Right_Key(Scan_Code)
;
;		If NOT in joystick mode
;			If this is a make code
;				Get the right arrow key code
;				Set the any key down flag bit
;				Set the keyboard strobe bit
;				Save the keyboard data value
;			Endif
;		Else in the joystick mode
;			Call the joystick right routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Right key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Right_Key	Proc	Near		; Right key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jnz	Do_Right		; Jump if this is joystick mode
	or	ah,ah			; Check for a make or break code
	js	Right_Done		; Jump if this is a break code
	mov	bl,RIGHT_ARROW		; Get the right arrow translated code
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	ds:[Key_Data],bl	; Save the keyboard data value
	jmp	Short Right_Done	; Go return to the caller
Do_Right:
	call	Joy_Right		; Call the joystick right routine
Right_Done:
	ret				; Return to the caller
Right_Key	Endp			; End of the Right_Key procedure
	Subttl	End_Key 	End Key Routine
	Page	+
;******************************************************************************
;
;	End_Key(Scan_Code)
;
;		If in joystick mode
;			Call the joystick down/left routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - End key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
End_Key 	Proc	Near		; End key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	End_Done		; Jump if this is NOT joystick mode
	call	Joy_Down_Left		; Call the joystick down/left routine
End_Done:
	ret				; Return to the caller
End_Key 	Endp			; End of the End_Key procedure
	Subttl	Down_Key	Down Key Routine
	Page	+
;******************************************************************************
;
;	Down_Key(Scan_Code)
;
;		If NOT in joystick mode
;			If this is a make code
;				Get the down arrow key code
;				Set the any key down flag bit
;				Set the keyboard strobe bit
;				Save the keyboard data value
;			Endif
;		Else in the joystick mode
;			Call the joystick down routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Down key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Down_Key	Proc	Near		; Down key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jnz	Do_Down 		; Jump if this is joystick mode
	or	ah,ah			; Check for a make or break code
	js	Down_Done		; Jump if this is a break code
	mov	bl,DOWN_ARROW		; Get the down arrow translated code
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	ds:[Key_Data],bl	; Save the keyboard data value
	jmp	Short Down_Done 	; Go return to the caller
Do_Down:
	call	Joy_Down		; Call the joystick down routine
Down_Done:
	ret				; Return to the caller
Down_Key	Endp			; End of the Down_Key procedure
	Subttl	PgDn_Key	PgDn Key Routine
	Page	+
;******************************************************************************
;
;	PgDn_Key(Scan_Code)
;
;		If in joystick mode
;			Call the joystick down/right routine
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - PgDn key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
PgDn_Key	Proc	Near		; PgDn key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	PgDn_Done		; Jump if this is NOT joystick mode
	call	Joy_Down_Right		; Call the joystick down/right routine
PgDn_Done:
	ret				; Return to the caller
PgDn_Key	Endp			; End of the PgDn_Key procedure
	Subttl	Ins_Key 	Ins Key Routine
	Page	+
;******************************************************************************
;
;	Ins_Key(Scan_Code)
;
;		If in joystick mode
;			If Ctrl key is down
;				Call joystick X resolution increase routine
;			Else
;				If Alt key is down
;					Call joystick X center increase routine
;				Endif for Alt key
;			Endif for Ctrl key
;		Endif for joystick mode
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Ins key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Ins_Key 	Proc	Near		; Ins key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Ins_Done		; Jump if this is NOT joystick mode
Ctrl_Ins_Check:
	test	Byte Ptr cs:[Key_Status],CTRLED
	jz	Alt_Ins_Check		; Jump if ctrl key NOT down
	call	Joy_X_Res_Inc		; Call joystick X res. inc. routine
	jmp	Short Ins_Done		; Go return to the caller
Alt_Ins_Check:
	test	Byte Ptr cs:[Key_Status],ALTED
	jz	Ins_Done		; Jump if alt key NOT down
	call	Joy_X_Cen_Inc		; Call joystick X center inc. routine
Ins_Done:
	ret				; Return to the caller
Ins_Key 	Endp			; End of the Ins_Key procedure
	Subttl	Del_Key 	Del Key Routine
	Page	+
;******************************************************************************
;
;	Del_Key(Scan_Code)
;
;		If NOT in joystick mode
;			If this is a make code
;				Get the DEL key code
;				Set the any key down flag bit
;				Set the keyboard strobe bit
;				Save the keyboard data value
;			Endif
;		Else in the joystick mode
;			If Ctrl key is down
;				Call joystick X resolution decrease routine
;			Else
;				If Alt key is down
;					Call joystick X center decrease routine
;				Endif for Alt key
;			Endif for Ctrl key
;		Endif for joystick mode
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Del key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Del_Key 	Proc	Near		; Del key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jnz	Ctrl_Del_Check		; Jump if this is joystick mode
	or	ah,ah			; Check for a make or break code
	js	Del_Done		; Jump if this is a break code
	mov	bl,DEL_CODE		; Get the DEL key translated code
	or	Byte Ptr ds:[Any_Key],KEY_DOWN
	or	bl,KEY_STROBE		; Set the keyboard strobe bit
	mov	ds:[Key_Data],bl	; Save the keyboard data value
	jmp	Short Del_Done		; Go return to the caller
Ctrl_Del_Check:
	test	Byte Ptr cs:[Key_Status],CTRLED
	jz	Alt_Del_Check		; Jump if ctrl key NOT down
	call	Joy_X_Res_Dec		; Call joystick X res. dec. routine
	jmp	Short Del_Done		; Go return to the caller
Alt_Del_Check:
	test	Byte Ptr cs:[Key_Status],ALTED
	jz	Del_Done		; Jump if alt key NOT down
	call	Joy_X_Cen_Dec		; Call joystick X center dec. routine
Del_Done:
	ret				; Return to the caller
Del_Key 	Endp			; End of the Del_Key procedure
	Subttl	Pad_Plus	Pad Plus Key Routine
	Page	+
;******************************************************************************
;
;	Pad_Plus(Scan_Code)
;
;		If in joystick mode
;			If Ctrl key is down
;				Call joystick Y resolution increase routine
;			Else
;				If Alt key is down
;					Call joystick Y center increase routine
;				Endif for Alt key
;			Endif for Ctrl key
;		Endif for joystick mode
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Pad plus key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Pad_Plus	Proc	Near		; Pad plus key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Plus_Done		; Jump if this is NOT joystick mode
Ctrl_Plus_Check:
	test	Byte Ptr cs:[Key_Status],CTRLED
	jz	Alt_Plus_Check		; Jump if ctrl key NOT down
	call	Joy_Y_Res_Inc		; Call joystick Y res. inc. routine
	jmp	Short Plus_Done 	; Go return to the caller
Alt_Plus_Check:
	test	Byte Ptr cs:[Key_Status],ALTED
	jz	Plus_Done		; Jump if alt key NOT down
	call	Joy_Y_Cen_Inc		; Call joystick Y center inc. routine
Plus_Done:
	ret				; Return to the caller
Pad_Plus	Endp			; End of the Pad_Plus procedure
	Subttl	Pad_Minus	Pad Minus Key Routine
	Page	+
;******************************************************************************
;
;	Pad_Minus(Scan_Code)
;
;		If in joystick mode
;			If Ctrl key is down
;				Call joystick Y resolution decrease routine
;			Else
;				If Alt key is down
;					Call joystick Y center decrease routine
;				Endif for Alt key
;			Endif for Ctrl key
;		Endif for joystick mode
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Pad minus key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Pad_Minus	Proc	Near		; Pad minus key procedure
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Minus_Done		; Jump if this is NOT joystick mode
Ctrl_Minus_Check:
	test	Byte Ptr cs:[Key_Status],CTRLED
	jz	Alt_Minus_Check 	; Jump if ctrl key NOT down
	call	Joy_Y_Res_Dec		; Call joystick Y res. dec. routine
	jmp	Short Minus_Done	; Go return to the caller
Alt_Minus_Check:
	test	Byte Ptr cs:[Key_Status],ALTED
	jz	Minus_Done		; Jump if alt key NOT down
	call	Joy_Y_Cen_Dec		; Call joystick Y center dec. routine
Minus_Done:
	ret				; Return to the caller
Pad_Minus	Endp			; End of the Pad_Minus procedure
	Subttl	Num_Lock	Num Lock Key Routine
	Page	+
;******************************************************************************
;
;	Num_Lock(Scan_Code)
;
;		Save the required registers
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				If neither shift/ctrl/alt keys are down
;					Toggle the joystick mode bit
;				Endif
;				If this is joystick mode
;					Call correct joystick routine
;				Endif for joystick mode
;			Endif this is a break code
;		Endif this key is repeating
;		Call routine to update the LED status
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Num lock key scan code
;		AH    - Original scan code
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Num_Lock	Proc	Near		; Num lock key procedure
	Save	bx			; Save the required registers
	cmp	ah,cs:[Last_Scan]	; Check for a repeat scan code
	je	Num_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Num_Done		; Jump if this is a break code
	xor	bh,bh			; Setup to get keyboard status
	mov	bl,cs:[Key_Status]	; Get the keyboard status byte
	and	bl,KEY_MASK		; Save only the desired bits
	jnz	Joy_Test		; Jump if other status bits present
	xor	Byte Ptr cs:[Key_Status],JOY_MODE
Joy_Test:
	test	Byte Ptr cs:[Key_Status],JOY_MODE
	jz	Num_Done		; Jump if NOT in joystick mode
	shl	bx,1			; Convert status bits to table index
	call	cs:[bx + Joy_Table]	; Call the correct joystick routine
Num_Done:
	call	Set_LED 		; Update the keyboard LED status
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Num_Lock	Endp			; End of the Num_Lock procedure
	Subttl	Set_LED 	Set keyboard LED routine
	Page	+
;******************************************************************************
;
;	Set_LED()
;
;		Save the required registers
;		Wait for 8042 input buffer empty
;		Disable the keyboard for LED update
;		Send the set LED command to 8042
;		Wait for ACK from the 8042
;		Wait for 8042 input buffer empty
;		Get the keyboard status byte
;		Mask off all but the LED status bits
;		Toggle scroll lock status to correct state
;		Send the new LED status bits to 8042
;		Wait for ACK from the 8042
;		Wait for 8042 input buffer empty
;		Enable the keyboard after LED update
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
Set_LED 	Proc	Near		; Set keyboard LED procedure
	Save	ax			; Save the required registers
	call	Wait_Input		; Call routine to wait for buffer empty
	jc	Set_Exit		; Jump if buffer never empty
	mov	al,DISABLE_KEY		; Get disable keyboard function code
	out	COMMAND_PORT,al 	; Disable the keyboard
	call	Wait_Output		; Wait for output buffer full
	jc	Skip_Input		; Jump if nothing waiting
	in	al,DATA_PORT		; Read any key that might be there
Skip_Input:
	call	Wait_Input		; Wait for input buffer to go empty
	jc	Set_Enable		; Jump if buffer never empty
	mov	al,LED_SET		; Get set LED function code
	out	DATA_PORT,al		; Send the set LED function code
	call	Wait_Output		; Wait for output buffer full
	jc	Set_Enable		; Jump if buffer never full
	in	al,DATA_PORT		; Get the ACK byte received
	call	Wait_Input		; Wait for input buffer empty
	jc	Set_Enable		; Jump if buffer never empty
	mov	al,cs:[Key_Status]	; Get the current keyboard status
	and	al,LED_MASK		; Mask off all but the LED indicators
	xor	al,SCROLL_LOCKED	; Toggle scroll lock to correct state
	shr	al,LED_SHIFT		; Shift bits into the correct position
	out	DATA_PORT,al		; Output the new LED status byte
	call	Wait_Output		; Wait for output buffer to fill
	jc	Set_Enable		; Jump if buffer never full
	in	al,DATA_PORT		; Get the ACK byte from the buffer
	call	Wait_Input		; Wait for the input buffer to go empty
Set_Enable:
	mov	al,ENABLE_KEY		; Get enable keyboard function code
	out	COMMAND_PORT,al 	; Enable the keyboard
Set_Exit:
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Set_LED 	Endp			; End of the Set_LED procedure
	Subttl	Wait_Input	Wait for Input Buffer Empty routine
	Page	+
;******************************************************************************
;
;	Wait_Input()
;
;		Save the required registers
;		Get counter limit value
;		While counter > 0 and input buffer full
;			Wait till input buffer is empty
;			Decrement counter value
;			If counter is zero
;				Set carry flag indicating never empty
;			Endif
;		Endwhile
;		Restore the required registers
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
Wait_Input	Proc	Near		; Wait for input buffer empty procedure
	Save	cx			; Save the required registers
	mov	cx,TIME_OUT		; Get the time out counter value
Input_Loop:
	in	al,COMMAND_PORT 	; Read the 8042 status
	test	al,INPUT_EMPTY		; Check for input buffer empty
	jz	Input_Exit		; Jump if input buffer is empty
	loop	Input_Loop		; Loop until time out is expired
	stc				; Set carry flag indicating time out
Input_Exit:
	Restore cx			; Restore the required registers
	ret				; Return to the caller
Wait_Input	Endp			; End of the Wait_Input procedure
	Subttl	Wait_Output	Wait for Output Buffer Full routine
	Page	+
;******************************************************************************
;
;	Wait_Output()
;
;		Save the required registers
;		Get counter limit value
;		While counter > 0 and output buffer empty
;			Wait till output buffer is full
;			Decrement counter value
;			If counter is zero
;				Set carry flag indicating never full
;			Endif
;		Endwhile
;		Restore the required registers
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
Wait_Output	Proc	Near		; Wait for output buffer full procedure
	Save	cx			; Save the required registers
	mov	cx,TIME_OUT		; Get the time out counter value
Output_Loop:
	in	al,COMMAND_PORT 	; Read the 8042 status
	test	al,OUTPUT_FULL		; Check for output buffer full
	jz	Output_Exit		; Jump if output buffer is full
	loop	Output_Loop		; Loop until time out is expired
	stc				; Set carry flag indicating time out
Output_Exit:
	Restore cx			; Restore the required registers
	ret				; Return to the caller
Wait_Output	Endp			; End of the Wait_Output procedure
	Subttl	Key_Reset	Keyboard Reset routine
	Page	+
;******************************************************************************
;
;	Key_Reset()
;
;		Save the required registers
;		Wait for 8042 input buffer empty
;		Disable the keyboard for LED update
;		Send the set LED command to 8042
;		Wait for ACK from the 8042
;		Wait for 8042 input buffer empty
;		Get the keyboard shift status (BIOS)
;		Mask off all but the LED status bits
;		Toggle scroll lock status to correct state
;		Send the new LED status bits to 8042
;		Wait for ACK from the 8042
;		Wait for 8042 input buffer empty
;		Enable the keyboard after LED update
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
Key_Reset	Proc	Near		; Keyboard reset procedure
	Save	ax			; Save the required registers
	call	Wait_Input		; Call routine to wait for buffer empty
	jc	Reset_Exit		; Jump if buffer never empty
	mov	al,DISABLE_KEY		; Get disable keyboard function code
	out	COMMAND_PORT,al 	; Disable the keyboard
	call	Wait_Output		; Wait for output buffer full
	jc	Input_Skip		; Jump if nothing waiting
	in	al,DATA_PORT		; Read any key that might be there
Input_Skip:
	call	Wait_Input		; Wait for input buffer to go empty
	jc	Reset_Enable		; Jump if buffer never empty
	mov	al,LED_SET		; Get set LED function code
	out	DATA_PORT,al		; Send the set LED function code
	call	Wait_Output		; Wait for output buffer full
	jc	Reset_Enable		; Jump if buffer never full
	in	al,DATA_PORT		; Get the ACK byte received
	call	Wait_Input		; Wait for input buffer empty
	jc	Reset_Enable		; Jump if buffer never empty
	mov	ah,SHIFT_STATUS 	; Get shift status function code
	int	KEYBOARD		; Get the shift/lock status byte
	shl	al,1			; Shift LED status bits into position
	and	al,LED_MASK		; Mask off all but the LED indicators
	shr	al,LED_SHIFT		; Shift bits into the correct position
	out	DATA_PORT,al		; Output the new LED status byte
	call	Wait_Output		; Wait for output buffer to fill
	jc	Reset_Enable		; Jump if buffer never full
	in	al,DATA_PORT		; Get the ACK byte from the buffer
	call	Wait_Input		; Wait for the input buffer to go empty
Reset_Enable:
	mov	al,ENABLE_KEY		; Get enable keyboard function code
	out	COMMAND_PORT,al 	; Enable the keyboard
Reset_Exit:
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Key_Reset	Endp			; End of the Key_Reset procedure
;******************************************************************************
;
;	Define the keyboard translation table
;
;	None, Shift, Ctrl, Ctrl/Shift, Alt, Alt/Shift, Alt/Ctrl, Alt/Ctrl/Shift
;
;******************************************************************************
Key_Translate	Equ	This Byte	; Keyboard translation table
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 00h - Illegal
	Db	1Bh,1Bh,1Bh,1Bh,80h,80h,80h,80h ; Scan Code 01h - Escape key
	Db	31h,21h,31h,21h,80h,80h,80h,80h ; Scan Code 02h - Keyboard 1
	Db	32h,40h,00h,00h,80h,80h,80h,80h ; Scan Code 03h - Keyboard 2
	Db	33h,23h,33h,23h,80h,80h,80h,80h ; Scan Code 04h - Keyboard 3
	Db	34h,24h,34h,24h,80h,80h,80h,80h ; Scan Code 05h - Keyboard 4
	Db	35h,25h,35h,25h,80h,80h,80h,80h ; Scan Code 06h - Keyboard 5
	Db	36h,5Eh,1Eh,1Eh,80h,80h,80h,80h ; Scan Code 07h - Keyboard 6
	Db	37h,26h,37h,26h,80h,80h,80h,80h ; Scan Code 08h - Keyboard 7
	Db	38h,2Ah,38h,2Ah,80h,80h,80h,80h ; Scan Code 09h - Keyboard 8
	Db	39h,28h,39h,28h,80h,80h,80h,80h ; Scan Code 0Ah - Keyboard 9
	Db	30h,29h,30h,29h,80h,80h,80h,80h ; Scan Code 0Bh - Keyboard 0
	Db	2Dh,5Fh,1Fh,1Fh,80h,80h,80h,80h ; Scan Code 0Ch - Keyboard minus
	Db	3Dh,2Bh,3Dh,2Bh,80h,80h,80h,80h ; Scan Code 0Dh - Equal sign
	Db	08h,08h,08h,08h,80h,80h,80h,80h ; Scan Code 0Eh - Backspace
	Db	82h,82h,82h,82h,80h,80h,80h,80h ; Scan Code 0Fh - Tab
	Db	71h,51h,11h,11h,80h,80h,80h,80h ; Scan Code 10h - Letter Q
	Db	77h,57h,17h,17h,80h,80h,80h,80h ; Scan Code 11h - Letter W
	Db	65h,45h,05h,05h,80h,80h,80h,80h ; Scan Code 12h - Letter E
	Db	72h,52h,12h,12h,80h,80h,80h,80h ; Scan Code 13h - Letter R
	Db	74h,54h,14h,14h,80h,80h,80h,80h ; Scan Code 14h - Letter T
	Db	79h,59h,19h,19h,80h,80h,80h,80h ; Scan Code 15h - Letter Y
	Db	75h,55h,15h,15h,80h,80h,80h,80h ; Scan Code 16h - Letter U
	Db	69h,49h,09h,09h,80h,80h,80h,80h ; Scan Code 17h - Letter I
	Db	6Fh,4Fh,0Fh,0Fh,80h,80h,80h,80h ; Scan Code 18h - Letter O
	Db	70h,50h,10h,10h,80h,80h,80h,80h ; Scan Code 19h - Letter P
	Db	5Bh,7Bh,1Bh,1Bh,80h,80h,80h,80h ; Scan Code 1Ah - Left bracket
	Db	5Dh,7Dh,1Dh,1Dh,80h,80h,80h,80h ; Scan Code 1Bh - Right bracket
	Db	0Dh,0Dh,0Dh,0Dh,80h,80h,80h,80h ; Scan Code 1Ch - Enter
	Db	81h,81h,81h,81h,81h,81h,81h,81h ; Scan Code 1Dh - Ctrl
	Db	61h,41h,01h,01h,80h,80h,80h,80h ; Scan Code 1Eh - Letter A
	Db	73h,53h,13h,13h,80h,80h,80h,80h ; Scan Code 1Fh - Letter S
	Db	64h,44h,04h,04h,80h,80h,80h,80h ; Scan Code 20h - Letter D
	Db	66h,46h,06h,06h,80h,80h,80h,80h ; Scan Code 21h - Letter F
	Db	67h,47h,07h,07h,80h,80h,80h,80h ; Scan Code 22h - Letter G
	Db	68h,48h,08h,08h,80h,80h,80h,80h ; Scan Code 23h - Letter H
	Db	6Ah,4Ah,0Ah,0Ah,80h,80h,80h,80h ; Scan Code 24h - Letter J
	Db	6Bh,4Bh,0Bh,0Bh,80h,80h,80h,80h ; Scan Code 25h - Letter K
	Db	6Ch,4Ch,0Ch,0Ch,80h,80h,80h,80h ; Scan Code 26h - Letter L
	Db	3Bh,3Ah,3Bh,3Ah,80h,80h,80h,80h ; Scan Code 27h - Semi-colon
	Db	27h,22h,27h,22h,80h,80h,80h,80h ; Scan Code 28h - Single quote
	Db	60h,7Eh,60h,7Eh,80h,80h,80h,80h ; Scan Code 29h - Accent mark
	Db	84h,84h,84h,84h,84h,84h,84h,84h ; Scan Code 2Ah - Left shift
	Db	5Ch,7Ch,1Ch,1Ch,80h,80h,80h,80h ; Scan Code 2Bh - Backslash
	Db	7Ah,5Ah,1Ah,1Ah,80h,80h,80h,80h ; Scan Code 2Ch - Letter Z
	Db	78h,58h,18h,18h,80h,80h,80h,80h ; Scan Code 2Dh - Letter X
	Db	63h,43h,03h,03h,80h,80h,80h,80h ; Scan Code 2Eh - Letter C
	Db	76h,56h,16h,16h,80h,80h,80h,80h ; Scan Code 2Fh - Letter V
	Db	62h,42h,02h,02h,80h,80h,80h,80h ; Scan Code 30h - Letter B
	Db	6Eh,4Eh,0Eh,0Eh,80h,80h,80h,80h ; Scan Code 31h - Letter N
	Db	6Dh,4Dh,0Dh,0Dh,80h,80h,80h,80h ; Scan Code 32h - Letter M
	Db	2Ch,3Ch,2Ch,3Ch,80h,80h,80h,80h ; Scan Code 33h - Comma
	Db	2Eh,3Eh,2Eh,3Eh,80h,80h,80h,80h ; Scan Code 34h - Period
	Db	2Fh,3Fh,2Fh,3Fh,80h,80h,80h,80h ; Scan Code 35h - Slash
	Db	84h,84h,84h,84h,84h,84h,84h,84h ; Scan Code 36h - Right shift
	Db	87h,87h,87h,87h,87h,87h,87h,87h ; Scan Code 37h - Prtsc
	Db	83h,83h,83h,83h,83h,83h,83h,83h ; Scan Code 38h - Alt
	Db	20h,20h,20h,20h,80h,80h,80h,80h ; Scan Code 39h - Space bar
	Db	85h,85h,85h,85h,85h,85h,85h,85h ; Scan Code 3Ah - Caps lock
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 3Bh - Function 1
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 3Ch - Function 2
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 3Dh - Function 3
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 3Eh - Function 4
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 3Fh - Function 5
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 40h - Function 6
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 41h - Function 7
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 42h - Function 8
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 43h - Function 9
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 44h - Function 10
	Db	88h,88h,88h,88h,88h,88h,88h,88h ; Scan Code 45h - Numlock
	Db	96h,96h,86h,86h,80h,80h,80h,80h ; Scan Code 46h - Scroll lock
	Db	89h,89h,89h,89h,80h,80h,80h,80h ; Scan Code 47h - Home
	Db	8Ah,8Ah,8Ah,8Ah,80h,80h,80h,80h ; Scan Code 48h - Up arrow
	Db	8Bh,8Bh,8Bh,8Bh,80h,80h,80h,80h ; Scan Code 49h - PgUp
	Db	95h,95h,95h,95h,95h,95h,80h,80h ; Scan Code 4Ah - Pad minus
	Db	8Ch,8Ch,8Ch,8Ch,80h,80h,80h,80h ; Scan Code 4Bh - Left arrow
	Db	8Dh,8Dh,8Dh,8Dh,80h,80h,80h,80h ; Scan Code 4Ch - Pad 5
	Db	8Eh,8Eh,8Eh,8Eh,80h,80h,80h,80h ; Scan Code 4Dh - Right
	Db	94h,94h,94h,94h,94h,94h,80h,80h ; Scan Code 4Eh - Pad plus
	Db	8Fh,8Fh,8Fh,8Fh,80h,80h,80h,80h ; Scan Code 4Fh - End
	Db	90h,90h,90h,90h,80h,80h,80h,80h ; Scan Code 50h - Down arrow
	Db	91h,91h,91h,91h,80h,80h,80h,80h ; Scan Code 51h - PgDn
	Db	92h,92h,92h,92h,92h,92h,80h,80h ; Scan Code 52h - Ins
	Db	93h,93h,93h,93h,93h,93h,80h,80h ; Scan Code 53h - Del
	Db	87h,87h,87h,87h,87h,87h,87h,87h ; Scan Code 54h - System request
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 55h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 56h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 57h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 58h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 59h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 5Ah - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 5Bh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 5Ch - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 5Dh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 5Eh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 5Fh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 60h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 61h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 62h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 63h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 64h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 65h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 66h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 67h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 68h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 69h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 6Ah - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 6Bh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 6Ch - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 6Dh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 6Eh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 6Fh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 70h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 71h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 72h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 73h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 74h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 75h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 76h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 77h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 78h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 79h - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 7Ah - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 7Bh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 7Ch - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 7Dh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 7Eh - Illegal
	Db	80h,80h,80h,80h,80h,80h,80h,80h ; Scan Code 7Fh - Illegal
;******************************************************************************
;
;	Define the keyboard caps lock table
;
;******************************************************************************
Caps_Table	Equ	This Byte	; Keyboard caps lock table
	Db	NOT_AFFECTED		; Scan Code 00h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 01h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 02h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 03h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 04h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 05h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 06h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 07h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 08h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 09h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 0Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 0Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 0Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 0Dh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 0Eh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 0Fh - Non-Shifted key
	Db	AFFECTED		; Scan Code 10h - Shifted Key
	Db	AFFECTED		; Scan Code 11h - Shifted Key
	Db	AFFECTED		; Scan Code 12h - Shifted Key
	Db	AFFECTED		; Scan Code 13h - Shifted Key
	Db	AFFECTED		; Scan Code 14h - Shifted Key
	Db	AFFECTED		; Scan Code 15h - Shifted Key
	Db	AFFECTED		; Scan Code 16h - Shifted Key
	Db	AFFECTED		; Scan Code 17h - Shifted Key
	Db	AFFECTED		; Scan Code 18h - Shifted Key
	Db	AFFECTED		; Scan Code 19h - Shifted Key
	Db	NOT_AFFECTED		; Scan Code 1Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 1Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 1Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 1Dh - Non-Shifted key
	Db	AFFECTED		; Scan Code 1Eh - Shifted Key
	Db	AFFECTED		; Scan Code 1Fh - Shifted Key
	Db	AFFECTED		; Scan Code 20h - Shifted Key
	Db	AFFECTED		; Scan Code 21h - Shifted Key
	Db	AFFECTED		; Scan Code 22h - Shifted Key
	Db	AFFECTED		; Scan Code 23h - Shifted Key
	Db	AFFECTED		; Scan Code 24h - Shifted Key
	Db	AFFECTED		; Scan Code 25h - Shifted Key
	Db	AFFECTED		; Scan Code 26h - Shifted Key
	Db	NOT_AFFECTED		; Scan Code 27h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 28h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 29h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 2Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 2Bh - Non-Shifted key
	Db	AFFECTED		; Scan Code 2Ch - Shifted Key
	Db	AFFECTED		; Scan Code 2Dh - Shifted Key
	Db	AFFECTED		; Scan Code 2Eh - Shifted Key
	Db	AFFECTED		; Scan Code 2Fh - Shifted Key
	Db	AFFECTED		; Scan Code 30h - Shifted Key
	Db	AFFECTED		; Scan Code 31h - Shifted Key
	Db	AFFECTED		; Scan Code 32h - Shifted Key
	Db	NOT_AFFECTED		; Scan Code 33h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 34h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 35h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 36h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 37h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 38h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 39h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 3Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 3Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 3Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 3Dh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 3Eh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 3Fh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 40h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 41h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 42h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 43h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 44h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 45h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 46h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 47h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 48h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 49h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 4Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 4Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 4Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 4Dh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 4Eh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 4Fh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 50h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 51h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 52h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 53h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 54h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 55h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 56h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 57h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 58h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 59h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 5Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 5Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 5Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 5Dh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 5Eh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 5Fh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 60h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 61h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 62h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 63h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 64h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 65h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 66h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 67h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 68h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 69h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 6Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 6Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 6Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 6Dh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 6Eh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 6Fh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 70h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 71h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 72h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 73h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 74h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 75h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 76h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 77h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 78h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 79h - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 7Ah - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 7Bh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 7Ch - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 7Dh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 7Eh - Non-Shifted key
	Db	NOT_AFFECTED		; Scan Code 7Fh - Non-Shifted key
;******************************************************************************
;
;	Define the special keys table
;
;******************************************************************************
Key_Table	Equ	This Word	; Special key table
	Dw	Illegal_Key		; Code 00 - Illegal scan code
	Dw	Control_Key		; Code 01 - Control key
	Dw	Tab_Key 		; Code 02 - Tab key (Button 1)
	Dw	Alt_Key 		; Code 03 - Alternate key (Button 2)
	Dw	Shift_Key		; Code 04 - Shift key was pressed
	Dw	Caps_Lock		; Code 05 - Caps lock was pressed
	Dw	System_Reset		; Code 06 - Ctrl. Scroll lock (Reset)
	Dw	System_Request		; Code 07 - System Request (Break)
	Dw	Num_Lock		; Code 08 - Num lock (Joystick Mode)
	Dw	Home_Key		; Code 09 - Home key (Joystick up/left)
	Dw	Up_Key			; Code 0A - Up arrow (Joystick up)
	Dw	PgUp_Key		; Code 0B - PgUp key (Joystick up/right)
	Dw	Left_Key		; Code 0C - Left arrow (Joystick left)
	Dw	Center_Key		; Code 0D - Center key (Joystick center)
	Dw	Right_Key		; Code 0E - Right arrow (Joystick right)
	Dw	End_Key 		; Code 0F - End key (Joystick down/left)
	Dw	Down_Key		; Code 10 - Down arrow (Joystick down)
	Dw	PgDn_Key		; Code 11 - PgDn key (Joy. down/right)
	Dw	Ins_Key 		; Code 12 - Ins. key (Joy X inc.)
	Dw	Del_Key 		; Code 13 - Del. key (Joy X dec.)
	Dw	Pad_Plus		; Code 14 - Pad plus (Joy Y inc.)
	Dw	Pad_Minus		; Code 15 - Pad minus (Joy Y dec.)
	Dw	Update_Toggle		; Code 16 - Scroll lock (Update type)
;******************************************************************************
;
;	Define the joystick call table
;
;	Numlock +
;
;	None, Shift, Ctrl, Ctrl/Shift, Alt, Alt/Shift, Alt/Ctrl, Alt/Ctrl/Shift
;
;******************************************************************************
Joy_Table	Equ	This Word
	Dw	Joystick_Mode		; Numlock + None
	Dw	Joystick_Type		; Numlock + Shift
	Dw	Joystick_Flight 	; Numlock + Ctrl
	Dw	Joystick_Dummy		; Numlock + Ctrl/Shift
	Dw	Joystick_Center 	; Numlock + Alt
	Dw	Joystick_Dummy		; Numlock + Alt/Shift
	Dw	Joystick_Fast		; Numlock + Alt/Ctrl
	Dw	Joystick_Reset		; Numlock + Alt/Ctrl/Shift
;******************************************************************************
;
;	Define the keyboard status byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Shift key status (0 = Up, 1 = Down)
;	 | | | | | | ---------> Ctrl key status  (0 = Up, 1 = Down)
;	 | | | | | -----------> Alt key status (0 = Up, 1 = Down)
;	 | | | | -------------> ***** Reserved *****
;	 | | | ---------------> ***** Reserved *****
;	 | | -----------------> Scroll lock key status (1 = Locked)
;	 | -------------------> Num lock key status (1 = Locked)
;	 ---------------------> Caps lock key status (1 = Locked)
;
;******************************************************************************
Key_Status	Db	SCROLL_LOCKED + CAPS_LOCKED
;******************************************************************************
;
;	Define any other keyboard variables
;
;******************************************************************************
Last_Key	Db	?		; Last actual keyboard code
Last_Scan	Db	?		; Last actual keyboard scan code
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Keyboard module

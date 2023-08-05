	Page	58,132
	Title	TTY.ASM 	TTY Interface Routines
;******************************************************************************
;
;   Name:	TTY.ASM 	TTY Interface Routines
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
;		This module contains all the code for the TTY interface
;	used by the Apple emulator.
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
	Public	TTY_Init		; Initialize TTY mode routine
	Public	TTY_Reset		; Reset TTY mode routine
	Public	Write_TTY		; Write TTY routine
	Public	Set_Position		; Set current position routine
	Public	Set_Row 		; Set current row routine
	Public	Set_Column		; Set current column routine
	Public	Set_Attribute		; Set current attribute routine
	Public	Set_Foreground		; Set current foreground routine
	Public	Set_Background		; Set current background routine
	Public	Set_Cursor		; Set cursor position routine
	Public	Set_Type		; Set cursor type routine
	Public	Get_Position		; Get current position routine
	Public	Get_Row 		; Get current row routine
	Public	Get_Column		; Get current column routine
	Public	Get_Attribute		; Get current attribute routine
	Public	Get_Foreground		; Get current foreground routine
	Public	Get_Background		; Get current background routine
	Public	Get_Cursor		; Get cursor position routine
	Public	Get_Type		; Get cursor type routine
	Public	Clear_Screen		; Clear screen routine
	Public	Current_Row		; Current screen row number
	Public	Current_Col		; Current screen column number
	Public	Current_Fore		; Current foreground color value
	Public	Current_Back		; Current background color value
;
;  External Declarations
;
	Extrn	Clear_Window:Near	; Clear window routine	       (WINDOW)
	Extrn	Cursor_Off:Near 	; Turn cursor off routine	(VIDEO)
	Extrn	Cursor_On:Near		; Turn cursor on routine	(VIDEO)
	Extrn	Blink_Off:Near		; Turn blink off routine	(VIDEO)
	Extrn	Blink_On:Near		; Turn blink on routine 	(VIDEO)
	Extrn	CGA_Restore:Near	; CGA restore screen routine	  (CGA)
	Extrn	EGA_Restore:Near	; EGA restore screen routine	  (EGA)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
	Extrn	Video_Flag:Byte 	; Video system flag byte	 (DATA)
;
;  LOCAL Equates
;
TEXT_MODE	Equ	00h		; Text mode value (40 x 25)
GRAPH_MODE	Equ	04h		; Graphics mode value (320 x 200)
BACK_SHIFT	Equ	04h		; Background attribute shift value
MAX_ROW 	Equ	19h		; Maximum row number value (25)
MAX_COLUMN	Equ	28h		; Maximum column number value (40)
CURSOR_MASK	Equ	07h		; Cursor type mask value
ATTRIBUTE_MASK	Equ	0Fh		; Foreground/background attribute mask
MAX_TAB 	Equ	24h		; Maximum horizontal tab position (36)
TAB_SIZE	Equ	04h		; Tab stop size value (4)
TAB_MASK	Equ	03h		; Tab count mask value
VIDEO_MEMORY	Equ	0B800h		; Start of video memory segment
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
	Subttl	TTY_Init	Initialize TTY Mode Routine
	Page	+
;******************************************************************************
;
;	TTY_Init()
;
;		Save the required registers
;		Set text mode 0 (40x25)
;		Call routine to turn off cursor
;		Call routine to disable blink (Intensity)
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
TTY_Init	Proc	Near		; Initialize TTY mode procedure
	Save	ax			; Save the required registers
	mov	ah,SET_MODE		; Get set mode video sub-function code
	mov	al,TEXT_MODE		; Get the 40x25 text mode value
	int	VIDEO			; Set video mode to 40x25 text mode
	call	Cursor_Off		; Call routine to turn cursor off
	call	Blink_Off		; Call routine to turn blink off
	Restore ax			; Restore the required registers
	ret				; Return to the caller
TTY_Init	Endp			; End of the TTY_Init procedure
	Subttl	TTY_Reset	Reset TTY Mode Routine
	Page	+
;******************************************************************************
;
;	TTY_Reset()
;
;		If this is a CGA type video
;			Call routine to restore CGA screen
;		Else this is an EGA type video
;			Call routine to restore EGA screen
;		Endif for video type
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
TTY_Reset	Proc	Near		; Reset TTY mode procedure
	test	cs:[System_Flag],EGA_TYPE
	jnz	Reset_Ega		; Jump if this is an EGA type video
Reset_CGA:
	call	CGA_Restore		; Call routine to restore CGA
	jmp	Short Reset_Exit	; Go return to the caller
Reset_EGA:
	call	EGA_Restore		; Call routine to restore EGA
Reset_Exit:
	ret				; Return to the caller
TTY_Reset	Endp			; End of the TTY_Reset procedure
	Subttl	Write_TTY	Write TTY Routine
	Page	+
;******************************************************************************
;
;	Write_TTY(Character)
;
;		Save the required registers
;		If special character
;			Call routine to handle special character
;		Else
;			Calculate the current screen position
;			Get current screen colors (Foreground/Background)
;			Put requested character on the screen
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Character to write
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Write_TTY	Proc	Near		; Write TTY procedure
	Save	ax,bx,cx,dx,di,es	; Save the required registers
	mov	bx,cs			; Setup access to
	mov	es,bx			;		  character table
	mov	cx,SPECIAL_LENGTH	; Get length of special character table
	lea	di,cs:[Special_Table]	; Get pointer to character table
	repne	scasb			; Check for a special character
	jne	Write_Character 	; Jump if NOT a special character
	lea	ax,cs:[Special_Table]	; Calculate
	sub	di,ax			;	    matching
	dec	di			;		     character value
	shl	di,1			; Convert matching number to table index
	call	cs:[di + Special_Jump]	; Call correct special character routine
	jmp	Short Write_Exit	; Go return control to the caller
Write_Character:
	mov	cx,cs:[Current_Row]	; Get the current row number
	mov	bx,cx			; Compute
	shl	bx,2			;	  row number
	add	bx,cx			;		     times five (*80)
	add	bx,VIDEO_MEMORY 	; Compute actual video memory segment
	mov	es,bx			; Setup to access video memory
	mov	di,cs:[Current_Col]	; Compute the actual
	shl	di,1			;		     memory address
	mov	ah,Byte Ptr cs:[Current_Back]
	shl	ah,BACK_SHIFT		; Shift background into position
	or	ah,Byte Ptr cs:[Current_Fore]
	stosw				; Store character into memory
	mov	ax,cs:[Current_Row]	; Get the current
	mov	bx,cs:[Current_Col]	;		  row/column values
	inc	bx			; Increment the column number
	cmp	bx,MAX_COLUMN		; Check against maximum column value
	jb	Write_Update		; Jump if column number valid
	xor	bx,bx			; Reset current column number
	inc	ax			; Increment the row number
	cmp	ax,MAX_ROW		; Check against maximum row value
	jae	Write_Exit		; Jump if invalid row/column values
Write_Update:
	mov	cs:[Current_Row],ax	; Update the current
	mov	cs:[Current_Col],bx	;		     row/column values
Write_Exit:
	Restore ax,bx,cx,dx,di,es	; Restore the required registers
	ret				; Return to the caller
Write_TTY	Endp			; End of the Write_TTY procedure
	Subttl	Special_NULL	Special NULL Character Routine
	Page	+
;******************************************************************************
;
;	Special_NULL()
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
Special_NULL	Proc	Near		; Special NULL character procedure
	ret				; Return to the caller
Special_NULL	Endp			; End of the Special_NULL procedure
	Subttl	Special_BELL	Special BELL Character Routine
	Page	+
;******************************************************************************
;
;	Special_BELL()
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
Special_BELL	Proc	Near		; Special BELL character procedure
	Save				; Save the required registers



	Restore 			; Restore the required registers
	ret				; Return to the caller
Special_BELL	Endp			; End of the Special_BELL procedure
	Subttl	Special_BS	Special BS Character Routine
	Page	+
;******************************************************************************
;
;	Special_BS()
;
;		Save the required registers
;		If current column number greater than zero
;			Decrement the current column number
;			Calculate the current screen position
;			Get current screen colors (Foreground/Background)
;			Put space character on the screen
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
Special_BS	Proc	Near		; Special BS character procedure
	Save	ax,bx,di,es		; Save the required registers
	mov	ax,cs:[Current_Col]	; Get the current column number
	or	ax,ax			; Check for in column zero
	jz	BS_Exit 		; Jump if currently in column zero
	dec	cs:[Current_Col]	; Decrement the current column value
	mov	ax,cs:[Current_Row]	; Get the current row number
	mov	bx,ax			; Compute
	shl	bx,2			;	  row number
	add	ax,bx			;		     times five (*80)
	add	ax,VIDEO_MEMORY 	; Compute actual video memory segment
	mov	es,ax			; Setup to access video memory
	mov	di,cs:[Current_Col]	; Compute the actual
	shl	di,1			;		     memory address
	mov	al,SPACE		; Setup to write a space character
	mov	ah,Byte Ptr cs:[Current_Back]
	shl	ah,BACK_SHIFT		; Shift background into position
	or	ah,Byte Ptr cs:[Current_Fore]
	stosw				; Store character into memory
BS_Exit:
	Restore ax,bx,di,es		; Restore the required registers
	ret				; Return to the caller
Special_BS	Endp			; End of the Special_BS procedure
	Subttl	Special_HT	Special HT Character Routine
	Page	+
;******************************************************************************
;
;	Special_HT()
;
;		Save the required registers
;		If current column less than maximum tab position
;			Calculate number of pad characters required (Spaces)
;			Calculate the current screen position
;			Get current screen colors (Foreground/Background)
;			Update the current column position
;			While more pad characters to display
;				Put pad character on the screen (Space)
;				Decrement the pad counter
;			EndWhile
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
Special_HT	Proc	Near		; Special HT character procedure
	Save	ax,bx,cx,di,es		; Save the required registers
	mov	ax,cs:[Current_Col]	; Get the current column position
	cmp	ax,MAX_TAB		; Check against maximum tab position
	jae	HT_Exit 		; Jump if past maximum tab position
	and	ax,TAB_MASK		; Compute
	mov	cx,TAB_SIZE		;	  the actual
	sub	cx,ax			;		     tab count value
	mov	ax,cs:[Current_Row]	; Get the current row number
	mov	bx,ax			; Compute
	shl	bx,2			;	  row number
	add	ax,bx			;		     times five (*80)
	add	ax,VIDEO_MEMORY 	; Compute actual video memory segment
	mov	es,ax			; Setup to access video memory
	mov	di,cs:[Current_Col]	; Compute the actual
	shl	di,1			;		     memory address
	mov	al,SPACE		; Setup to write a space character
	mov	ah,Byte Ptr cs:[Current_Back]
	shl	ah,BACK_SHIFT		; Shift background into position
	or	ah,Byte Ptr cs:[Current_Fore]
	add	cs:[Current_Col],cx	; Update the current column position
	rep	stosw			; Store the horizontal pad characters
HT_Exit:
	Restore ax,bx,cx,di,es		; Restore the required registers
	ret				; Return to the caller
Special_HT	Endp			; End of the Special_HT procedure
	Subttl	Special_LF	Special LF Character Routine
	Page	+
;******************************************************************************
;
;	Special_LF()
;
;		Save the required registers
;		If not on the bottom row
;			Increment the current row value
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
Special_LF	Proc	Near		; Special LF character procedure
	Save	ax			; Save the required registers
	mov	ax,cs:[Current_Row]	; Get the current row position
	cmp	ax,MAX_ROW - 1		; Check for on the bottom row
	jae	LF_Exit 		; Jump if currently on the last row
	inc	cs:[Current_Row]	; Increment to the next row
LF_Exit:
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Special_LF	Endp			; End of the Special_LF procedure
	Subttl	Special_VT	Special VT Character Routine
	Page	+
;******************************************************************************
;
;	Special_VT()
;
;		Save the required registers
;		If not on the bottom row
;			Increment the current row value
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
Special_VT	Proc	Near		; Special VT character procedure
	Save	ax			; Save the required registers
	mov	ax,cs:[Current_Row]	; Get the current row position
	cmp	ax,MAX_ROW - 1		; Check for on the bottom row
	jae	VT_Exit 		; Jump if currently on the last row
	inc	cs:[Current_Row]	; Increment to the next row
VT_Exit:
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Special_VT	Endp			; End of the Special_VT procedure
	Subttl	Special_FF	Special FF Character Routine
	Page	+
;******************************************************************************
;
;	Special_FF()
;
;		Save the required registers
;		Call routine to clear the screen
;		Set row position to zero
;		Set column position to zero
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
Special_FF	Proc	Near		; Special FF character procedure
	Save	ax			; Save the required registers
	call	Clear_Screen		; Call routine to clear the screen
	xor	ax,ax			; Setup to zero current position (Home)
	mov	cs:[Current_Row],ax	; Zero the current
	mov	cs:[Current_Col],ax	;		   row/column position
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Special_FF	Endp			; End of the Special_FF procedure
	Subttl	Special_CR	Special CR Character Routine
	Page	+
;******************************************************************************
;
;	Special_CR()
;
;		Save the required registers
;		Set current column position to zero
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
Special_CR	Proc	Near		; Special CR character procedure
	Save	ax			; Save the required registers
	xor	ax,ax			; Setup to zero column position
	mov	cs:[Current_Col],ax	; Zero current column position value
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Special_CR	Endp			; End of the Special_CR procedure
	Subttl	Set_Position	Set Current Position Routine
	Page	+
;******************************************************************************
;
;	Set_Position(Row, Column)
;
;		If new row position is valid
;			If new column position is valid
;				Set current row to new row
;				Set current column to new column
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - New row number
;		BX    - New column number
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Position	Proc	Near		; Set current position procedure
	cmp	ax,MAX_ROW		; Check the new row number value
	jae	Position_Exit		; Jump if new row value is invalid
	cmp	bx,MAX_COLUMN		; Check the new column number value
	jae	Position_Exit		; Jump if new column value is invalid
	mov	cs:[Current_Row],ax	; Update the current
	mov	cs:[Current_Col],bx	;		     row/column values
Position_Exit:
	ret				; Return to the caller
Set_Position	Endp			; End of the Set_Position procedure
	Subttl	Set_Row 	Set Current Row Position Routine
	Page	+
;******************************************************************************
;
;	Set_Row(Row)
;
;		If new row position is valid
;			Set current row to new row
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - New row number
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Row 	Proc	Near		; Set current row position procedure
	cmp	ax,MAX_ROW		; Check the new row number value
	jae	Row_Exit		; Jump if new row value is invalid
	mov	cs:[Current_Row],ax	; Update the current row value
Row_Exit:
	ret				; Return to the caller
Set_Row 	Endp			; End of the Set_Row procedure
	Subttl	Set_Column	Set Current Column Position Routine
	Page	+
;******************************************************************************
;
;	Set_Column(Column)
;
;		If new column position is valid
;			Set current column to new column
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - New column number
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Column	Proc	Near		; Set current column position procedure
	cmp	ax,MAX_COLUMN		; Check the new column number value
	jae	Column_Exit		; Jump if new column value is invalid
	mov	cs:[Current_Col],ax	; Update the current column value
Column_Exit:
	ret				; Return to the caller
Set_Column	Endp			; End of the Set_Column procedure
	Subttl	Set_Attribute	Set Current Attribute Routine
	Page	+
;******************************************************************************
;
;	Set_Attribute(Foreground, Background)
;
;		Set current foreground color to new value
;		Set current background color to new value
;		Mask off the foreground value
;		Mask off the background value
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - New foreground color
;		BX    - New background color
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Attribute	Proc	Near		; Set current attribute procedure
	mov	cs:[Current_Fore],ax	; Save new foreground
	mov	cs:[Current_Back],bx	;		      background colors
	and	cs:[Current_Fore],ATTRIBUTE_MASK
	and	cs:[Current_Back],ATTRIBUTE_MASK
	ret				; Return to the caller
Set_Attribute	Endp			; End of the Set_Attribute procedure
	Subttl	Set_Foreground	Set Current Foreground Routine
	Page	+
;******************************************************************************
;
;	Set_Foreground(Foreground)
;
;		Set current foreground color to new value
;		Mask off the foreground value
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - New foreground color
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Foreground	Proc	Near		; Set current foreground procedure
	mov	cs:[Current_Fore],ax	; Save new foreground color value
	and	cs:[Current_Fore],ATTRIBUTE_MASK
	ret				; Return to the caller
Set_Foreground	Endp			; End of the Set_Foreground procedure
	Subttl	Set_Background	Set Current Background Routine
	Page	+
;******************************************************************************
;
;	Set_Background(Background)
;
;		Set current background color to new value
;		Mask off the background value
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - New background color
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Background	Proc	Near		; Set current background procedure
	mov	cs:[Current_Back],ax	; Save new background color value
	and	cs:[Current_Back],ATTRIBUTE_MASK
	ret				; Return to the caller
Set_Background	Endp			; End of the Set_Background procedure
	Subttl	Set_Cursor	Set Cursor Position Routine
	Page	+
;******************************************************************************
;
;	Set_Cursor(Row, Column)
;
;		Save the required registers
;		If new row position is valid
;			If new column position is valid
;				Set new cursor position
;			Endif
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Cursor row number
;		BX    - Cursor column number
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Cursor	Proc	Near		; Set cursor position procedure
	Save	ax,bx,dx		; Save the required registers
	cmp	ax,MAX_ROW		; Check the new row number value
	jae	Cursor_Exit		; Jump if new row value is invalid
	cmp	bx,MAX_COLUMN		; Check the new column number value
	jae	Cursor_Exit		; Jump if new column value is invalid
	mov	dh,al			; Setup the cursor
	mov	dl,bl			;		   row and column values
	xor	bh,bh			; Setup for video page zero
	mov	ah,WRITE_CURSOR 	; Get write cursor position function
	int	VIDEO			; Set the new cursor position
Cursor_Exit:
	Restore ax,bx,dx		; Restore the required registers
	ret				; Return to the caller
Set_Cursor	Endp			; End of the Set_Cursor procedure
	Subttl	Set_Type	Set Cursor Type Routine
	Page	+
;******************************************************************************
;
;	Set_Type(Start, End)
;
;		Save the required registers
;		Mask off the cursor start value
;		Mask off the cursor end value
;		Set the new cursor type value
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Cursor start row number (0 - 7)
;		BX    - Cursor end row number (0 - 7)
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Set_Type	Proc	Near		; Set cursor type procedure
	Save	ax,cx			; Save the required registers
	mov	ch,al			; Get and mask
	and	ch,CURSOR_MASK		;	       cursor start value
	mov	cl,bl			; Get and mask
	and	cl,CURSOR_MASK		;	       cursor end value
	mov	ah,CURSOR_TYPE		; Get set cursor type function code
	int	VIDEO			; Set the new cursor type value
	Restore ax,cx			; Restore the required registers
	ret				; Return to the caller
Set_Type	Endp			; End of the Set_Type procedure
	Subttl	Get_Position	Get Current Position Routine
	Page	+
;******************************************************************************
;
;	Get_Position()
;
;		Get the current row value
;		Get the current column vlaue
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Current row number
;		BX    - Current column number
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Position	Proc	Near		; Get current position procedure
	mov	ax,cs:[Current_Row]	; Get the current
	mov	bx,cs:[Current_Col]	;		  row/column values
	ret				; Return to the caller
Get_Position	Endp			; End of the Get_Position procedure
	Subttl	Get_Row 	Get Current Row Position Routine
	Page	+
;******************************************************************************
;
;	Get_Row()
;
;		Get the current row value
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Current row number
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Row 	Proc	Near		; Get current row position procedure
	mov	ax,cs:[Current_Row]	; Get the current row value
	ret				; Return to the caller
Get_Row 	Endp			; End of the Get_Row procedure
	Subttl	Get_Column	Get Current Column Position Routine
	Page	+
;******************************************************************************
;
;	Get_Column()
;
;		Get the current column vlaue
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Current column number
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Column	Proc	Near		; Get current column position procedure
	mov	ax,cs:[Current_Col]	; Get the current column value
	ret				; Return to the caller
Get_Column	Endp			; End of the Get_Column procedure
	Subttl	Get_Attribute	Get Current Attribute Routine
	Page	+
;******************************************************************************
;
;	Get_Attribute()
;
;		Get the current foreground color
;		Get the current background color
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Current foreground color
;		BX    - Current background color
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Attribute	Proc	Near		; Get current attribute procedure
	mov	ax,cs:[Current_Fore]	; Get foreground/
	mov	bx,cs:[Current_Back]	;		 background colors
	ret				; Return to the caller
Get_Attribute	Endp			; End of the Get_Attribute procedure
	Subttl	Get_Foreground	Get Current Foreground Routine
	Page	+
;******************************************************************************
;
;	Get_Foreground()
;
;		Get the current foreground color
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Current foreground color
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Foreground	Proc	Near		; Get current foreground procedure
	mov	ax,cs:[Current_Fore]	; Get the current foreground color
	ret				; Return to the caller
Get_Foreground	Endp			; End of the Get_Foreground procedure
	Subttl	Get_Background	Get Current Background Routine
	Page	+
;******************************************************************************
;
;	Get_Background()
;
;		Get the current background color
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Current background color
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Background	Proc	Near		; Get current background procedure
	mov	ax,cs:[Current_Back]	; Get the current background color
	ret				; Return to the caller
Get_Background	Endp			; End of the Get_Background procedure
	Subttl	Get_Cursor	Get Cursor Position Routine
	Page	+
;******************************************************************************
;
;	Get_Cursor()
;
;		Save the required registers
;		Get current cursor position
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Cursor row number
;		BX    - Cursor column number
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Cursor	Proc	Near		; Get cursor position procedure
	Save	cx,dx			; Save the required registers
	xor	bh,bh			; Setup for video page zero
	mov	ah,READ_CURSOR		; Get read cursor position function
	int	VIDEO			; Get the current cursor position
	mov	al,dh			; Get the current
	xor	ah,ah			;		  row position value
	mov	bl,dl			; Get the current
	xor	bh,bh			;		  column position value
	Restore cx,dx			; Restore the required registers
	ret				; Return to the caller
Get_Cursor	Endp			; End of the Get_Cursor procedure
	Subttl	Get_Type	Get Cursor Type Routine
	Page	+
;******************************************************************************
;
;	Get_Type()
;
;		Save the required registers
;		Get current cursor type
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		AX    - Cursor start row number (0 - 7)
;		BX    - Cursor end row number (0 - 7)
;
;******************************************************************************
		Even			; Force procedure to even address
Get_Type	Proc	Near		; Get cursor type procedure
	Save	cx,dx			; Save the required registers
	xor	bh,bh			; Setup for video page zero
	mov	ah,READ_CURSOR		; Get read cursor position function
	int	VIDEO			; Get the current cursor position
	mov	al,ch			; Get cursor start
	xor	ah,ah			;		   row position value
	mov	bl,cl			; Get cursor end
	xor	bh,bh			;		 row position value
	Restore cx,dx			; Restore the required registers
	ret				; Return to the caller
Get_Type	Endp			; End of the Get_Type procedure
	Subttl	Clear_Screen	Clear Screen Routine
	Page	+
;******************************************************************************
;
;	Clear_Screen()
;
;		Save the required registers
;		Set window to entire screen
;		Call routine to clear window
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
Clear_Screen	Proc	Near		; Clear screen procedure
	Save	ax,bx,cx,dx		; Save the required registers
	xor	ax,ax			; Setup
	xor	bx,bx			;	window
	mov	cx,MAX_ROW - 1		;	       to the
	mov	dx,MAX_COLUMN - 1	;		      entire screen
	call	Clear_Window		; Call routine to clear the window
	Restore ax,bx,cx,dx		; Restore the required registers
	ret				; Return to the caller
Clear_Screen	Endp			; End of the Clear_Screen procedure
	Subttl			TTY Interface Data Areas
	Page	+
;******************************************************************************
;
;	Define any data areas needed by the TTY interface
;
;******************************************************************************
Special_Table	Equ	This Byte	; Special character table
		Db	NULL		; Null character
		Db	BELL		; Bell character
		Db	BS		; Backspace character
		Db	HT		; Horizontal tab character
		Db	LF		; Line feed character
		Db	VT		; Vertical tab character
		Db	FF		; Form feed character
		Db	CR		; Carriage return character
SPECIAL_LENGTH	Equ	This Byte - Special_Table
Special_Jump	Equ	This Word	; Special character jump table
		Dw	Special_NULL	; Null character routine
		Dw	Special_BELL	; Bell character routine
		Dw	Special_BS	; Backspace character routine
		Dw	Special_HT	; Horizontal tab character routine
		Dw	Special_LF	; Line feed character routine
		Dw	Special_VT	; Vertical tab character routine
		Dw	Special_FF	; Form feed character routine
		Dw	Special_CR	; Carriage return character routine
Current_Row	Dw	0		; Current screen row number
Current_Col	Dw	0		; Current screen column number
Current_Fore	Dw	INTENSE_WHITE	; Current foreground color value
Current_Back	Dw	GRAY		; Current background color value
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the TTY module

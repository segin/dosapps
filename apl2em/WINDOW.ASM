	Page	58,132
	Title	WINDOW.ASM	Window Routines
;******************************************************************************
;
;   Name:	WINDOW.ASM	Window Routines
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
;		This module contains all the code for the window routines
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
	Public	Scroll_Up		; Scroll window up routine
	Public	Scroll_Down		; Scroll window down routine
	Public	Clear_Window		; Clear window routine
	Public	Save_Window		; Save window routine
	Public	Restore_Window		; Restore window routine
;
;  External Declarations
;
	Extrn	Cursor_Off:Near 	; Turn cursor off routine	(VIDEO)
	Extrn	Cursor_On:Near		; Turn cursor on routine	(VIDEO)
	Extrn	Blink_Off:Near		; Turn blink off routine	(VIDEO)
	Extrn	Blink_On:Near		; Turn blink on routine 	(VIDEO)
	Extrn	CGA_Restore:Near	; CGA restore screen routine	  (CGA)
	Extrn	EGA_Restore:Near	; EGA restore screen routine	  (EGA)
	Extrn	Current_Fore:Word	; Current foreground color value  (TTY)
	Extrn	Current_Back:Word	; Current background color value  (TTY)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
	Extrn	Video_Flag:Byte 	; Video system flag byte	 (DATA)
;
;  LOCAL Equates
;
BACK_SHIFT	Equ	04h		; Background attribute shift value
MAX_ROW 	Equ	19h		; Maximum row number value (25)
MAX_COLUMN	Equ	28h		; Maximum column number value (40)
PARA_ROUND	Equ	0Fh		; Bytes to paragraphs rounding value
PARA_SHIFT	Equ	04h		; Bytes to paragraphs shift value
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
	Subttl	Scroll_Up	Scroll Window Up Routine
	Page	+
;******************************************************************************
;
;	Scroll_Up(Window, Count)
;
;		Save the required registers
;		If window coordinates are valid
;			Setup access to video memory
;			Calculate source and destination rows values
;			Compute the actual window size
;			Compute and save the column count
;			Calculate source and destination addresses
;			Compute address increment value
;			Save the address increment value
;			If scroll count greater than window size
;				Limit scroll to entire window
;			Endif
;			Save the scroll count value
;			Compute the number of rows to move
;			While more rows to move
;				Setup the column count value
;				While more columns to move
;					Move the next column
;					Decrement the column count
;				EndWhile
;				Update the screen addresses
;				Decrement the row count
;			EndWhile
;			Restore the scroll count value
;			Setup the clear character (Space)
;			While more rows to clear
;				Setup the column count value
;				While more columns to clear
;					Store the clear character (Space)
;					Decrement the column count
;				EndWhile
;				Update the screen address
;				Decrement the row count
;			EndWhile
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Upper left window row coordinate
;		BX    - Upper left window column coordinate
;		CX    - Lower right window row coordinate
;		DX    - Lower right window column coordinate
;		BP    - Scroll count (Lines)
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Scroll_Up	Proc	Near		; Scroll window up procedure
	Save	ax,bx,cx,dx,si,di,bp,ds,es
	cmp	ax,cx			; Check the row coordinate values
	ja	Up_Exit 		; Jump if row coordinates are invalid
	cmp	bx,dx			; Check column coordinate values
	ja	Up_Exit 		; Jump if column coordinates are invalid
	cmp	ax,MAX_ROW		; Check upper left row value
	jnc	Up_Exit 		; Jump if invalid row value
	cmp	bx,MAX_COLUMN		; Check upper left column value
	jnc	Up_Exit 		; Jump if invalid column value
	cmp	cx,MAX_ROW		; Check lower right row value
	jnc	Up_Exit 		; Jump if invalid row value
	cmp	dx,MAX_COLUMN		; Check lower right column value
	jnc	Up_Exit 		; Jump if invalid column value
	mov	si,VIDEO_MEMORY 	; Setup access
	mov	ds,si			;	       to video
	mov	es,si			;			memory
	mov	si,ax			; Compute the source
	add	si,bp			;		     row number
	mov	di,ax			; Get the destination row number
	sub	cx,ax			; Compute the actual
	inc	cx			;		     window size (Rows)
	sub	dx,bx			; Compute and save
	inc	dx			;		   the column count
	shl	si,4			; Compute
	mov	ax,si			;	  source
	shl	ax,2			;		 row times
	add	si,ax			;			   eighty
	shl	di,4			; Compute
	mov	ax,di			;	  destination
	shl	ax,2			;		      times
	add	di,ax			;			    eighty
	shl	bx,1			; Compute column offset value
	add	si,bx			; Compute the actual source address
	add	di,bx			; Compute actual destination address
	mov	bx,MAX_COLUMN		; Compute and save
	sub	bx,dx			;		   increment value
	cmp	cx,bp			; Check the scroll count value
	ja	Up_Move 		; Jump if partial window scroll
	mov	bp,cx			; Limit scroll to entire window
Up_Move:
	Save	bp			; Save the scroll count value
	sub	cx,bp			; Compute and save
	mov	bp,cx			;		   the move count
	jz	Up_Clear		; Jump if entire window scroll
Move_Up_Loop:
	mov	cx,dx			; Setup the column count value
	rep	movsw			; Move an entire row
	add	si,bx			; Update the
	add	di,bx			;	     screen addresses
	dec	bp			; Decrement the row count value
	jnz	Move_Up_Loop		; Loop till all rows are moved
Up_Clear:
	Restore bp			; Restore the row count value
	mov	al,SPACE		; Setup to write a space character
	mov	ah,Byte Ptr cs:[Current_Back]
	shl	ah,BACK_SHIFT		; Shift background into position
	or	ah,Byte Ptr cs:[Current_Fore]
Clear_Up_Loop:
	mov	cx,dx			; Setup the column count value
	rep	stosw			; Clear an entire row
	add	di,bx			; Update the screen address
	dec	bp			; Decrement the row count value
	jnz	Clear_Up_Loop		; Loop till all rows are cleared
Up_Exit:
	Restore ax,bx,cx,dx,si,di,bp,ds,es
	ret				; Return to the caller
Scroll_Up	Endp			; End of the Scroll_Up procedure
	Subttl	Scroll_Down	Scroll Window Down Routine
	Page	+
;******************************************************************************
;
;	Scroll_Down(Window, Count)
;
;		Save the required registers
;		If window coordinates are valid
;			Setup access to video memory
;			Calculate source and destination rows values
;			Compute the actual window size
;			Compute and save the column count
;			Calculate source and destination addresses
;			Compute address decrement value
;			Save the address decrement value
;			If scroll count greater than window size
;				Limit scroll to entire window
;			Endif
;			Save the scroll count value
;			Compute the number of rows to move
;			While more rows to move
;				Setup the column count value
;				While more columns to move
;					Move the next column
;					Decrement the column count
;				EndWhile
;				Update the screen addresses
;				Decrement the row count
;			EndWhile
;			Restore the scroll count value
;			Setup the clear character (Space)
;			While more rows to clear
;				Setup the column count value
;				While more columns to clear
;					Store the clear character (Space)
;					Decrement the column count
;				EndWhile
;				Update the screen address
;				Decrement the row count
;			EndWhile
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Upper left window row coordinate
;		BX    - Upper left window column coordinate
;		CX    - Lower right window row coordinate
;		DX    - Lower right window column coordinate
;		BP    - Scroll count (Lines)
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Scroll_Down	Proc	Near		; Scroll window down procedure
	Save	ax,bx,cx,dx,si,di,bp,ds,es
	cmp	ax,cx			; Check the row coordinate values
	ja	Down_Exit		; Jump if row coordinates are invalid
	cmp	bx,dx			; Check column coordinate values
	ja	Down_Exit		; Jump if column coordinates are invalid
	cmp	ax,MAX_ROW		; Check upper left row value
	jnc	Down_Exit		; Jump if invalid row value
	cmp	bx,MAX_COLUMN		; Check upper left column value
	jnc	Down_Exit		; Jump if invalid column value
	cmp	cx,MAX_ROW		; Check lower right row value
	jnc	Down_Exit		; Jump if invalid row value
	cmp	dx,MAX_COLUMN		; Check lower right column value
	jnc	Down_Exit		; Jump if invalid column value
	mov	si,VIDEO_MEMORY 	; Setup access
	mov	ds,si			;	       to video
	mov	es,si			;			memory
	mov	si,cx			; Compute the source
	sub	si,bp			;		     row number
	mov	di,cx			; Get the destination row number
	sub	cx,ax			; Compute the actual
	inc	cx			;		     window size (Rows)
	sub	dx,bx			; Compute and save
	inc	dx			;		   the column count
	shl	si,4			; Compute
	mov	ax,si			;	  source
	shl	ax,2			;		 row times
	add	si,ax			;			   eighty
	shl	di,4			; Compute
	mov	ax,di			;	  destination
	shl	ax,2			;		      times
	add	di,ax			;			    eighty
	shl	bx,1			; Compute column offset value
	add	si,bx			; Compute the actual source address
	add	di,bx			; Compute actual destination address
	mov	bx,MAX_COLUMN		; Compute and
	add	bx,dx			;	      save decrement
	shl	bx,1			;			     value
	cmp	cx,bp			; Check the scroll count value
	ja	Down_Move		; Jump if partial window scroll
	mov	bp,cx			; Limit scroll to entire window
Down_Move:
	Save	bp			; Save the scroll count value
	sub	cx,bp			; Compute and save
	mov	bp,cx			;		   the move count
	jz	Down_Clear		; Jump if entire window scroll
Move_Down_Loop:
	mov	cx,dx			; Setup the column count value
	rep	movsw			; Move an entire row
	sub	si,bx			; Update the
	sub	di,bx			;	     screen addresses
	dec	bp			; Decrement the row count value
	jnz	Move_Down_Loop		; Loop till all rows are moved
Down_Clear:
	Restore bp			; Restore the row count value
	mov	al,SPACE		; Setup to write a space character
	mov	ah,Byte Ptr cs:[Current_Back]
	shl	ah,BACK_SHIFT		; Shift background into position
	or	ah,Byte Ptr cs:[Current_Fore]
Clear_Down_Loop:
	mov	cx,dx			; Setup the column count value
	rep	stosw			; Clear an entire row
	sub	di,bx			; Update the screen address
	dec	bp			; Decrement the row count value
	jnz	Clear_Down_Loop 	; Loop till all rows are cleared
Down_Exit:
	Restore ax,bx,cx,dx,si,di,bp,ds,es
	ret				; Return to the caller
Scroll_Down	Endp			; End of the Scroll_Down procedure
	Subttl	Clear_Window	Clear Window Routine
	Page	+
;******************************************************************************
;
;	Clear_Window(Window)
;
;		Save the required registers
;		If window coordinates are valid
;			Calculate starting address
;			Compute and save the row count
;			Compute address increment value
;			Compute and save the column count
;			Save the address increment value
;			Setup the clear character (Space)
;			While more rows to clear
;				Setup the column count value
;				While more columns to clear
;					Store the clear character (Space)
;					Decrement the column count
;				EndWhile
;				Update the screen address
;				Decrement the row count
;			EndWhile
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Upper left window row coordinate
;		BX    - Upper left window column coordinate
;		CX    - Lower right window row coordinate
;		DX    - Lower right window column coordinate
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Clear_Window	Proc	Near		; Clear window procedure
	Save	ax,bx,cx,dx,si,di,es	; Save the required registers
	cmp	ax,cx			; Check the row coordinate values
	ja	Clear_Exit		; Jump if row coordinates are invalid
	cmp	bx,dx			; Check column coordinate values
	ja	Clear_exit		; Jump if column coordinates are invalid
	cmp	ax,MAX_ROW		; Check upper left row value
	jnc	Clear_Exit		; Jump if invalid row value
	cmp	bx,MAX_COLUMN		; Check upper left column value
	jnc	Clear_Exit		; Jump if invalid column value
	cmp	cx,MAX_ROW		; Check lower right row value
	jnc	Clear_Exit		; Jump if invalid row value
	cmp	dx,MAX_COLUMN		; Check lower right column value
	jnc	Clear_Exit		; Jump if invalid column value
	mov	di,ax			; Compute
	shl	di,2			;	  row number
	add	di,ax			;		     times five (*80)
	add	di,VIDEO_MEMORY 	; Compute actual video memory segment
	mov	es,di			; Setup to access video memory
	mov	di,bx			; Compute the actual
	shl	di,1			;		     memory address
	mov	si,cx			; Compute and
	sub	si,ax			;	      save the
	inc	si			;		       row count
	mov	ax,MAX_COLUMN - 1	; Compute
	sub	ax,dx			;	  address
	add	ax,bx			;		  increment
	shl	ax,1			;			    value
	sub	dx,bx			; Compute and save
	inc	dx			;		   the column count
	mov	bx,ax			; Save the address increment value
	mov	al,SPACE		; Setup to write a space character
	mov	ah,Byte Ptr cs:[Current_Back]
	shl	ah,BACK_SHIFT		; Shift background into position
	or	ah,Byte Ptr cs:[Current_Fore]
Clear_Loop:
	mov	cx,dx			; Setup the column count value
	rep	stosw			; Clear an entire row
	add	di,bx			; Update the screen address
	dec	si			; Decrement the row count value
	jnz	Clear_Loop		; Loop till all rows are cleared
Clear_Exit:
	Restore ax,bx,cx,dx,si,di,es	; Restore the required registers
	ret				; Return to the caller
Clear_Window	Endp			; End of the Clear_Window procedure
	Subttl	Save_Window	Save Window Routine
	Page	+
;******************************************************************************
;
;	Save_Window(Window)
;
;		Save the required registers
;		If window coordinates are valid
;			Calculate amount of storage required
;			If enough memory is available
;				Save the window coordinates
;				Calculate starting address
;				Compute and save the row count
;				Compute address increment value
;				Compute and save the column count
;				Save the address increment value
;				While more rows to save
;					Setup the column count value
;					While more columns to save
;						Save the next column
;						Decrement the column count
;					EndWhile
;					Update the screen address
;					Decrement the row count
;				EndWhile
;				Setup the window handle value
;			Endif
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Upper left window row coordinate
;		BX    - Upper left window column coordinate
;		CX    - Lower right window row coordinate
;		DX    - Lower right window column coordinate
;
;	Registers on Exit:
;
;		BP    - Window save handle (If no errors)
;
;******************************************************************************
		Even			; Force procedure to even address
Save_Window	Proc	Near		; Save window procedure
	Save	ax,bx,cx,dx,si,di,ds,es ; Save the required registers
	cmp	ax,cx			; Check the row coordinate values
	ja	Save_Exit		; Jump if row coordinates are invalid
	cmp	bx,dx			; Check column coordinate values
	ja	Save_exit		; Jump if column coordinates are invalid
	cmp	ax,MAX_ROW		; Check upper left row value
	jnc	Save_Exit		; Jump if invalid row value
	cmp	bx,MAX_COLUMN		; Check upper left column value
	jnc	Save_Exit		; Jump if invalid column value
	cmp	cx,MAX_ROW		; Check lower right row value
	jnc	Save_Exit		; Jump if invalid row value
	cmp	dx,MAX_COLUMN		; Check lower right column value
	jnc	Save_Exit		; Jump if invalid column value
	Save	ax,bx,cx,dx		; Save the window coordinates
	sub	cx,ax			; Compute the
	inc	cx			;	      number of rows
	sub	dx,bx			; Compute the
	inc	dx			;	      number of columns
	mov	ax,cx			; Compute amount
	mul	dx			;		 of storage
	shl	ax,1			;			    required
	mov	bx,ax			; Compute the
	add	bx,PARA_ROUND + 8	;	      number of
	shr	bx,PARA_SHIFT		;			paragraphs
	mov	ah,ALLOCATE_MEMORY	; Get allocate memory function code
	int	DOS			; Try to allocate the memory
	mov	es,ax			; Save the returned memory address
	Restore ax,bx,cx,dx		; Restore the window coordinates
	jc	Save_Exit		; Jump if unable to allocate memory
	xor	di,di			; Setup to access the memory area
	stosw				; Save the
	xchg	ax,bx			;	   upper left
	stosw				;		      coordinate
	xchg	ax,cx			; Save the
	stosw				;	   lower
	xchg	ax,dx			;		 right
	stosw				;		       coordinate
	xchg	ax,bx			; Restore the
	xchg	cx,dx			;	      window
	xchg	bx,dx			;		     coordinates
	mov	si,ax			; Compute
	shl	si,2			;	  row number
	add	si,ax			;		     times five (*80)
	add	si,VIDEO_MEMORY 	; Compute actual video memory segment
	mov	ds,si			; Setup to access video memory
	mov	si,bx			; Compute the actual
	shl	si,1			;		     memory address
	mov	bp,cx			; Compute and
	sub	bp,ax			;	      save the
	inc	bp			;		       row count
	mov	ax,MAX_COLUMN - 1	; Compute
	sub	ax,dx			;	  address
	add	ax,bx			;		  increment
	shl	ax,1			;			    value
	sub	dx,bx			; Compute and save
	inc	dx			;		   the column count
	mov	bx,ax			; Save the address increment value
Save_Loop:
	mov	cx,dx			; Setup the column count value
	rep	movsw			; Save an entire row
	add	si,bx			; Update the screen address
	dec	bp			; Decrement the row count value
	jnz	Save_Loop		; Loop till all rows are saved
	mov	bp,es			; Get the window handle value
Save_Exit:
	Restore ax,bx,cx,dx,si,di,ds,es ; Restore the required registers
	ret				; Return to the caller
Save_Window	Endp			; End of the Save_Window procedure
	Subttl	Restore_Window	Restore Window Routine
	Page	+
;******************************************************************************
;
;	Restore_Window(Handle)
;
;		Save the required registers
;		Setup access to the window data
;		Get the window coordinates
;		Calculate starting address
;		Compute and save the row count
;		Compute address increment value
;		Compute and save the column count
;		Save the address increment value
;		While more rows to restore
;			Setup the column count value
;			While more columns to restore
;				Restore the next column
;				Decrement the column count
;			EndWhile
;			Update the screen address
;			Decrement the row count
;		EndWhile
;		Free the allocated memory
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		BP    - Window handle to restore
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Restore_Window	Proc	Near		; Restore window procedure
	Save	ax,bx,cx,dx,si,di,bp,ds,es
	mov	ds,bp			; Setup access to
	xor	si,si			;		  the window data
	lodsw				; Restore
	mov	dx,ax			;	  upper left
	lodsw				;		     window
	mov	bx,ax			;			    coordinate
	lodsw				; Restore
	mov	cx,ax			;	  lower right
	lodsw				;		      window
	xchg	ax,dx			;			     coordinate
	mov	di,ax			; Compute
	shl	di,2			;	  row number
	add	di,ax			;		     times five (*80)
	add	di,VIDEO_MEMORY 	; Compute actual video memory segment
	mov	es,di			; Setup to access video memory
	mov	di,bx			; Compute the actual
	shl	di,1			;		     memory address
	mov	bp,cx			; Compute and
	sub	bp,ax			;	      save the
	inc	bp			;		       row count
	mov	ax,MAX_COLUMN - 1	; Compute
	sub	ax,dx			;	  address
	add	ax,bx			;		  increment
	shl	ax,1			;			    value
	sub	dx,bx			; Compute and save
	inc	dx			;		   the column count
	mov	bx,ax			; Save the address increment value
Restore_Loop:
	mov	cx,dx			; Setup the column count value
	rep	movsw			; Restore an entire row
	add	di,bx			; Update the screen address
	dec	bp			; Decrement the row count value
	jnz	Restore_Loop		; Loop till all rows are restored
	mov	ax,ds			; Setup to free
	mov	es,ax			;		the allocated memory
	mov	ah,FREE_MEMORY		; Get free memory function code
	int	DOS			; Try to free the allocated memory
Restore_Exit:
	Restore ax,bx,cx,dx,si,di,bp,ds,es
	ret				; Return to the caller
Restore_Window	Endp			; End of the Restore_Window procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Window module

	Page	58,132
	Title	PRINTF.ASM	Generic Printf Routine
;******************************************************************************
;
;   Name:	PRINTF.ASM	Generic Printf Routine
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
;	Printf - Prints a formatted string of arguments to
;		 the requested handle.
;
;	Calling Sequence:
;
;		lea	bx,ds:[args]	; Get a pointer to the arguments
;		lea	si,ds:[format]	; Get a pointer to the format string
;		call	printf		; Call the printf routine
;
;	The conversion characters are as follows:
;
;		%% - Print percent sign to handle
;		%c - Output the next argument as a character
;		%s - Output the next argument as a string
;		%x - Output the next argument as a hex number using abcdef
;		%X - Output the next argument as a hex number using ABCDEF
;		%h - Output the next argument as a hex number using abcdef
;		%H - Output the next argument as a hex number using ABCDEF
;		%d - Output the next argument as a decimal number (Signed)
;		%u - Output the next argument as a decimal number (Unsigned)
;		%o - Output the next argument as a octal number
;		%b - Output the next argument as a binary number
;		%f - Output the next argument as a fractional number (Signed)
;
;	Other format specifiers may precede the conversion character:
;
;		-  - Left justify the field
;		+  - Set signed field
;		n  - Specify the field width/precision
;		t  - Specify short value
;		l  - Specify long value
;		#  - Specify far argument pointer
;		*  - Variable precision/width value (From argument list)
;
;	All arguments must be pointers to the actual values.
;
;	The following escape sequences are also handled:
;
;		\\   -	Backslash
;		\n   -	Newline
;		\t   -	Horizontal Tab
;		\v   -	Vertical Tab
;		\b   -	Backspace
;		\r   -	Carriage Return
;		\f   -	Form Feed
;		\ddd -	ASCII Character (Octal Notation)
;		\xdd -	ASCII Character (Hexadecimal Notation)
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
;	Public Declarations
;
	Public	Printf			; Generic Printf routine
;
;  External Declarations
;
	Extrn	Write_TTY:Near		; Write TTY routine		  (TTY)
;
;	Define the Local Equates
;
FORMAT_CHAR	Equ	"%"             ; Format specification character
ESCAPE_CHAR	Equ	"\"             ; Escape sequence character
HEX		Equ	16		; Base 16 - Hexadecimal
DECIMAL 	Equ	10		; Base 10 - Decimal
OCTAL		Equ	8		; Base 8  - Octal
BINARY		Equ	2		; Base 2  - Binary
FORMAT_LENGTH	Equ	5		; Maximum format number width
ESCAPE_LENGTH	Equ	3		; Escape sequence number width (Decimal)
HEX_LENGTH	Equ	2		; Escape sequence number width (Hex)
MAX_WORD	Equ	0FFFFh		; Maximum 16-bit count value
MAX_BYTE	Equ	0FFh		; Maximum 8-bit count value
SPACE_PAD	Equ	" "             ; Space pad character
ZERO_PAD	Equ	"0"             ; Zero pad character
LEFT_JUST	Equ	8000h		; Left justification flag
SHORT_SPEC	Equ	4000h		; Short specification flag
LONG_SPEC	Equ	2000h		; Long specification flag
UPPER_CASE	Equ	1000h		; Upper case hexadecimal flag
SIGNED_CONV	Equ	0800h		; Signed conversion flag
SIGNED_TYPE	Equ	0400h		; Signed type flag
SIGNED_VAL	Equ	0200h		; Signed value flag
PRE_PAD 	Equ	0100h		; Pre-pad sign character flag
FAR_SPEC	Equ	0080h		; Far argument specification flag
OVER_FLOW	Equ	0040h		; Field overflow flag
FRACTIONAL	Equ	0020h		; Fractional integer flag
VAR_WIDTH	Equ	0010h		; Variable width flag
VAR_PRE 	Equ	0008h		; Variable precision flag
PAD_CHAR	Equ	0004h		; Pad character flag (0=Space, 1=Zero)
SIGNED		Equ	8000h		; Sign flag test mask
WRITE_HANDLE	Equ	40h		; MS-DOS write handle function code
DECIMAL_ADJUST	Equ	30h		; ASCII decimal to binary adjust value
HEX_ADJUST	Equ	07h		; ASCII hex to binary adjust value
UPPER_MASK	Equ	0DFh		; Lower to upper case mask value
DOS		Equ	21h		; MS-DOS interrupt call number
FAR_SIZE	Equ	4h		; Far argument pointer size   (4 bytes)
NEAR_SIZE	Equ	2h		; Near argument pointer size  (2 bytes)
LONG_SIZE	Equ	4h		; Long numeric argument size  (4 bytes)
SHORT_SIZE	Equ	2h		; Short numeric argument size (2 bytes)
BUFF_SIZE	Equ	64		; Numeric build buffer size
DIGIT_MAX	Equ	39h		; Maximum ASCII digit value
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
	.286c				; Include 80286 instructions
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	Printf		Generic Printf Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Printf(Format_String, Arguments, Handle)
;
;		Save the required registers
;		While next character from Format_String <> 0
;			If next character is a format character (percent sign)
;				Get the next character from Format_String
;				If a format specifier (+,-,n,l,#,*)
;					Set the appropriate specifier flag
;				Else not a format specifier
;					If a conversion character (c,s,x,d,o,b)
;						Print argument using conversion
;						Increment argument pointer
;					Else not a conversion character
;						Ignore this format
;					Endif
;				Endif
;			Else the character is not a format character
;				If character is a escape character (backslash)
;					Get next character from Format_String
;					If a valid escape sequence
;						Handle the escape sequence
;					Else an invalid escape sequence
;						Print the character to Handle
;					Endif
;				Else the character is not an escape character
;					Print the character to Handle
;				Endif
;			Endif
;		Endwhile
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:BX = Pointer to Argument List
;		DS:SI = Pointer to Format String
;
;	Registers on Exit:
;
;		Direction flag is cleared (Move forward)
;
;******************************************************************************
Printf		Proc	Near		; Generic printf procedure
	Save	ax,bx,cx,dx,si,di,bp,ds,es
	mov	ah,al			; Save print handle in AH
	cld				; Clear the direction flag (Forward)
Get_Char:
	call	Clear_Flags		; Clear all of the specifier flags
	lodsb				; Get a character from format string
	cmp	al,FORMAT_CHAR		; Check for a format character (%)
	je	Do_Format		; Jump if a format character
	cmp	al,ESCAPE_CHAR		; Check for an escape character (\)
	je	Do_Escape		; Jump if a escape character
	or	al,al			; Check for end of the format string
	jnz	Normal_Output		; Jump if a normal character to output
	jmp	Printf_Exit		; Jump if end of the format string
Do_Escape:
	lodsb				; Get next character from format string
	push	cs			; Put copy of CS onto the stack
	pop	es			; Put copy of current CS into ES
	lea	di,cs:[Escape_Table]	; Setup the escape character table
	mov	cx,ESCAPE_SIZE		; Get the escape character table size
	repne	scasb			; Scan the escape table for a match
	je	Go_Escape		; Jump if an there was a table match
	mov	ch,OCTAL		; Set the current base value to OCTAL
	mov	cl,ESCAPE_LENGTH	; Set the escape maximum number count
	call	Check_Digit		; Check for numeric digit (Character)
	jnc	Get_Code		; Jump if an octal number sequence
	jmp	Normal_Output		; Jump if an unknown escape character
Get_Code:
	dec	si			; Backup to the start of the number
	push	dx			; Save the field width/precision
	call	Get_Number		; Call routine to get the number
	mov	al,dl			; Put the character number into AL
	pop	dx			; Restore the field width/precision
	jmp	Normal_Output		; Go get next format string character
Go_Escape:
	mov	di,ESCAPE_SIZE		; Get the escape table size
	sub	di,cx			; Compute the matching entry number
	dec	di			; Convert number to zero based
	shl	di,1			; Make number into jump table index
	call	cs:[di+Escape_Jump]	; Call the correct routine
	jmp	Get_Char		; Go get the next character
Normal_Output:
	call	Write_TTY		; Not a special character, output it
	jmp	Get_Char		; Go get next format string character
Do_Convert:
	lea	di,cs:[Convert_Table]	; Setup the convert character table
	mov	cx,CONVERT_SIZE 	; Get the convert character table size
	repne	scasb			; Scan the convert table for a match
	jne	Get_Char		; Jump if an unknown convert character
	mov	di,CONVERT_SIZE 	; Get the convert table size
	sub	di,cx			; Compute the matching entry number
	dec	di			; Convert number to zero based
	shl	di,1			; Make number into jump table index
	call	cs:[di+Convert_Jump]	; Call the correct routine
	jmp	Get_Char		; Go get the next character
Do_Format:
	lodsb				; Get next character from format string
	push	cs			; Put copy of CS onto the stack
	pop	es			; Put copy of current CS into ES
	lea	di,cs:[Format_Table]	; Setup the format character table
	mov	cx,FORMAT_SIZE		; Get the format character table size
	repne	scasb			; Scan the format table for a match
	je	Go_Format		; Jump if an there was a table match
	mov	ch,DECIMAL		; Set the current base value to DECIMAL
	mov	cl,FORMAT_LENGTH	; Set the format maximum number count
	cmp	al,POINT		; Check for a decimal point
	jne	Chk_Var 		; Jump if no decimal point found
	dec	si			; Correct pointer for no width value
	xor	dh,dh			; Setup a width value of zero
	jmp	Chk_Pre 		; Go check for a precision value
Chk_Var:
	cmp	al,ASTERISK		; Check for variable width field
	jne	Do_Width		; Jump if not a variable width field
	or	bp,VAR_WIDTH		; Set variable width flag bit
	mov	dh,MAX_BYTE		; Set width value as already set
	jmp	Chk_Pre 		; Go check for a precision value
Do_Width:
	call	Check_Digit		; Check for numeric digit (Field width)
	jc	Do_Convert		; Jump if an unknown format character
	dec	si			; Backup to the start of the number
	or	al,al			; Check for a leading zero
	jnz	Get_Width		; Jump if first digit not a zero
	or	bp,PAD_CHAR		; First digit zero, use zero pad
	or	bp,PRE_PAD		; Set pre-pad sign character flag
Get_Width:
	call	Get_Number		; Call routine to get the field width
	mov	dh,dl			; Save the field width in DH
	cmp	Byte Ptr ds:[si],ASTERISK
	jne	Chk_Pre 		; Jump if not a variable width field
	inc	si			; Increment past variable character
	or	bp,VAR_WIDTH		; Set variable width flag bit
	mov	dh,MAX_BYTE		; Set width value as already set
Chk_Pre:
	xor	dl,dl			; Setup a precision of zero
	cmp	Byte Ptr ds:[si],POINT	; Check for a decimal point
	jne	Do_Format		; Jump if no precision given
	or	bp,FRACTIONAL		; Set the fractional conversion flag
	dec	dl			; Set precision as already set
	inc	si			; Increment past the decimal point
	cmp	Byte Ptr ds:[si],ASTERISK
	jne	Get_Pre 		; Jump if not a variable precision
	inc	si			; Increment past variable character
	or	bp,VAR_PRE		; Set variable precision flag bit
	jmp	Do_Format		; Go check for more format characters
Get_Pre:
	call	Get_Number		; Call routine to get the precision
	jmp	Do_Format		; Go check for more format characters
Go_Format:
	mov	di,FORMAT_SIZE		; Get the format table size
	sub	di,cx			; Compute the matching entry number
	dec	di			; Convert number to zero based
	shl	di,1			; Make number into jump table index
	call	cs:[di+Format_Jump]	; Call the correct routine
	jmp	Do_Format		; Go check for more format characters
Printf_Exit:
	Restore ax,bx,cx,dx,si,di,bp,ds,es
	ret				; Return to the caller
Printf		Endp			; End of the Printf procedure
	Subttl			Format Specifier Routines
	Page	+
;******************************************************************************
;
;	Format Specifier Routines
;
;
;		These routines handle the following format specifiers:
;
;
;	Specifier		Action Taken
;	---------		------------
;
;	    -		The following field will be left justified.
;
;	    +		The following field will be have a sign (+/-)
;			if it is a signed type field (d).
;
;	    t		The following field is a short value.
;
;	    T		The following field is a short value.
;
;	    l		The following field is a long value.
;
;	    L		The following field is a long value.
;
;	    #		The following argument has a far address.
;
;
;		These routines simply set or reset flags which are
;	used later during actual conversion to perform the special
;	formatting options.
;
;******************************************************************************
	Subttl	Left_Justify	Left Justify Specifier Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Left_Justify()
;
;		Set the left justification flag
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		BP    - Left justification flag set
;
;******************************************************************************
Left_Justify	Proc	Near		; Left justify procedure
	or	bp,LEFT_JUST		; Set the left justification flag
	ret				; Return to the caller
Left_Justify	Endp			; End of the Left_Justify procedure
	Subttl	Set_Signed	Set Signed Conversion Specifier Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Set_Signed()
;
;		Set the signed flag
;		If the field width is non-zero
;			Set the pre-pad sign flag
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		DH    - Field width (Not given if zero)
;
;	Registers on Exit:
;
;		BP    - Signed flag set
;
;******************************************************************************
Set_Signed	Proc	Near		; Set signed procedure
	or	bp,SIGNED_CONV		; Set the signed conversion flag
	or	dh,dh			; Check the field width
	jz	Sign_Ret		; Jump if field width not set
	or	bp,PRE_PAD		; Set the pre-pad sign flag
Sign_Ret:
	ret				; Return to the caller
Set_Signed	Endp			; End of the Set_Signed procedure
	Subttl	Short_Specify	Set Short Value Specifier Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Short_Specify()
;
;		Set the short specification flag
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		BP    - Short specification flag set
;
;******************************************************************************
Short_Specify	Proc	Near		; Short specify procedure
	or	bp,SHORT_SPEC		; Set the short specification flag
	ret				; Return to the caller
Short_Specify	Endp			; End of the Short_Specify procedure
	Subttl	Long_Specify	Set Long Value Specifier Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Long_Specify()
;
;		Set the long specification flag
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		BP    - Long specification flag set
;
;******************************************************************************
Long_Specify	Proc	Near		; Long specify procedure
	or	bp,LONG_SPEC		; Set the long specification flag
	ret				; Return to the caller
Long_Specify	Endp			; End of the Long_Specify procedure
	Subttl	Far_Specify	Set Far Address Specifier Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Far_Specify()
;
;		Set the far specification flag
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		BP    - Far specification flag set
;
;******************************************************************************
Far_Specify	Proc	Near		; Far specify procedure
	or	bp,FAR_SPEC		; Set the far specification flag
	ret				; Return to the caller
Far_Specify	Endp			; End of the Far_Specify procedure
	Subttl			Escape Sequence Routines
	Page	+
;******************************************************************************
;
;	Escape Sequence Routines
;
;
;		These routines handle the following escape sequences:
;
;
;	Character		Escape Sequence
;	---------		---------------
;
;	    n		Newline is output to requested handle
;
;	    t		Horizontal tab is output to requested handle
;
;	    v		Vertical tab is output to requested handle
;
;	    b		Backspace is output to requested handle
;
;	    r		Carriage return is output to requested handle
;
;	    f		Form feed is output to requested handle
;
;	    x		Character is output to requested handle (Hex code)
;
;
;		All of these routines except for the "x" escape
;	sequence simply send the desired character(s) out to the
;	requested handle. The "x" routine get the hexadecimal
;	number given and outputs the corresponding character to
;	the requested handle.
;
;******************************************************************************
	Subttl	New_Line	New Line Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	New_Line(Handle)
;
;		Output carriage return to handle
;		Output line feed to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
New_Line	Proc	Near		; Output new line procedure
	mov	al,CR			; Get carriage return ASCII character
	call	Write_TTY		; Output the carriage return to handle
	mov	al,LF			; Get a line feed ASCII character
	call	Write_TTY		; Output the line feed to handle
	ret				; Return to the caller
New_Line	Endp			; End of the New_Line procedure
	Subttl	Horz_Tab	Horizontal Tab Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Horz_Tab(Handle)
;
;		Output horizontal tab to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
Horz_Tab	Proc	Near		; Output horizontal tab procedure
	mov	al,HT			; Get horizontal tab ASCII character
	call	Write_TTY		; Output the horizontal tab to handle
	ret				; Return to the caller
Horz_Tab	Endp			; End of the Horz_Tab procedure
	Subttl	Vert_Tab	Vertical Tab Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Vert_Tab(Handle)
;
;		Output vertical tab to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
Vert_Tab	Proc	Near		; Output vertical tab procedure
	mov	al,VT			; Get vertical tab ASCII character
	call	Write_TTY		; Output the vertical tab to handle
	ret				; Return to the caller
Vert_Tab	Endp			; End of the Vert_Tab procedure
	Subttl	Back_Space	Back Space Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Back_Space(Handle)
;
;		Output backspace to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
Back_Space	Proc	Near		; Output backspace procedure
	mov	al,BS			; Get backspace ASCII character
	call	Write_TTY		; Output the backspace to handle
	ret				; Return to the caller
Back_Space	Endp			; End of the Back_Space procedure
	Subttl	Carr_Ret	Carriage Return Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Carr_Ret(Handle)
;
;		Output carriage return to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
Carr_Ret	Proc	Near		; Output carriage return procedure
	mov	al,CR			; Get carriage return ASCII character
	call	Write_TTY		; Output the carriage return to handle
	ret				; Return to the caller
Carr_Ret	Endp			; End of the Carr_Ret procedure
	Subttl	Form_Feed	Form Feed Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Form_Feed(Handle)
;
;		Output form feed to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;
;******************************************************************************
Form_Feed	Proc	Near		; Output form feed procedure
	mov	al,FF			; Get form feed ASCII character
	call	Write_TTY		; Output the form feed to handle
	ret				; Return to the caller
Form_Feed	Endp			; End of the Form_Feed procedure
	Subttl	Out_Hex 	Output Hex Escape Sequence Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Out_Hex(String, Handle)
;
;		Set number base to hexadecimal
;		Set maximum number length
;		Call routine to get the number
;		Output the number (Character) to handle
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:SI - Pointer to number
;
;	Registers on Exit:
;
;		AL    - Destroyed
;		CX    - Destroyed
;		DL    - Destroyed
;		DS:SI - Pointer set to first character past number
;
;******************************************************************************
Out_Hex 	Proc	Near		; Output hex character procedure
	mov	ch,HEX			; Set number base to hexadecimal
	mov	cl,HEX_LENGTH		; Set maximum hex digit length
	call	Get_Number		; Call routine to get the number
	jc	Out_Exit		; Jump if no number present
	mov	al,dl			; Move the number value into AL
	call	Write_TTY		; Output the corresponding character
Out_Exit:
	ret				; Return to the caller
Out_Hex 	Endp			; End of the Out_Hex procedure
	Subttl			Conversion Formatting Routines
	Page	+
;******************************************************************************
;
;	Conversion Formatting Routines
;
;
;		These routines handle the following conversion types:
;
;
;	Character		Conversion Done
;	---------		---------------
;
;	    c		Convert next argument as a character
;
;	    s		Convert next argument as a string
;
;	    x		Convert next argument as a hex number using abcdef
;
;	    X		Convert next argument as a hex number using ABCDEF
;
;	    d		Convert next argument as a decimal number (Signed)
;
;	    u		Convert next argument as a decimal number (Unsigned)
;
;	    o		Convert next argument as a octal number
;
;	    b		Convert next argument as a binary number
;
;
;		These routines format the arguments passed to them.
;	Numeric arguments can be either word or double word (long)
;	values and for the decimal option it can be formatted as
;	signed or unsigned. All arguments are passed as pointers,
;	either near or far, to the actual argument value.
;
;******************************************************************************
	Subttl	Do_Char 	Character Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Char(Argument, Handle, Flags)
;
;		Save the required registers
;		Call routine to get the character address
;		If field width is not set (Zero)
;			Set field width to character value (1)
;		Endif
;		If character length (1) > field width
;			Set the field overflow flag
;			Set character length to field width
;		Endif
;		Set pad character to a space
;		Call routine to calculate pad counts
;		Call routine to output pre-string pad characters
;		Get character to output
;		Call routine to output character to handle
;		Call routine to output post-string pad characters
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		AL    - Destroyed
;		BX    - Points to next argument
;		CX    - Destroyed
;		DL    - Destroyed
;		DI    - Destroyed
;		ES    - Destroyed
;
;******************************************************************************
Do_Char 	Proc	Near		; Character formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	call	Get_Address		; Call routine to get argument address
	mov	cl,1			; Set actual width to character value
	or	dh,dh			; Check the current field width
	jnz	Width_Chk		; Jump if field width specified
	mov	dh,1			; Set field width to character length
Width_Chk:
	cmp	cl,dh			; Compare actual width to given width
	jbe	Send_Pre		; Jump if string fits in field width
	or	bp,OVER_FLOW		; Set the field overflow flag
	mov	cl,dh			; Clip string to the field width
Send_Pre:
	mov	al,cl			; Save the actual string length
	and	bp,Not PAD_CHAR 	; Set current pad character to a space
	call	Calculate		; Call routine to calculate pad values
	call	Pad			; Call routine to send pad characters
Send_Char:
	lodsb				; Get the character to output
	call	Write_TTY		; Call routine to output the character
Send_Post:
	mov	cl,ch			; Get the calculated pad counts
	call	Pad			; Call routine to send pad characters
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Char 	Endp			; End of the Do_Char procedure
	Subttl	Do_String	String Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_String(Argument, Handle, Width, Flags)
;
;		Save the required registers
;		Call routine to get the string address
;		Call routine to compute string length
;		If field width is not set (Zero)
;			Set field width to string length
;		Endif
;		If string length > field width
;			Set the field overflow flag
;			Set string length to field width
;		Endif
;		Set pad character to a space
;		Call routine to calculate pad counts
;		Call routine to output pre-string pad characters
;		While length > 0
;			Get next character of string
;			Call routine to output character to handle
;			Decrement the length
;		Endwhile
;		Call routine to output post-string pad characters
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		AL    - Destroyed
;		BX    - Points to next argument
;		CX    - Destroyed
;		DL    - Destroyed
;		DI    - Destroyed
;		ES    - Destroyed
;
;******************************************************************************
Do_String	Proc	Near		; String formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	call	Get_Address		; Call routine to get argument address
	call	Get_Length		; Call routine to get string length
	jz	String_Exit		; Jump if nothing to output
	or	dh,dh			; Check the current field width
	jnz	Chk_Width		; Jump if field width specified
	mov	dh,cl			; Set field width to string length
Chk_Width:
	cmp	cl,dh			; Compare actual width to given width
	jbe	Do_Pre			; Jump if string fits in field width
	or	bp,OVER_FLOW		; Set the field overflow flag
	mov	cl,dh			; Clip string to the field width
Do_Pre:
	mov	al,cl			; Save the actual string length
	and	bp,Not PAD_CHAR 	; Set current pad character to a space
	call	Calculate		; Call routine to calculate pad values
	mov	dl,al			; Setup the string output length
	call	Pad			; Call routine to send pad characters
Send_String:
	lodsb				; Get the next string character
	call	Write_TTY		; Call routine to output the character
	dec	dl			; Decrement the output length
	jnz	Send_String		; Go get next character if more left
Do_Post:
	mov	cl,ch			; Get the calculated pad counts
	call	Pad			; Call routine to send pad characters
String_Exit:
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_String	Endp			; End of the Do_String procedure
	Subttl	Do_Hex		Hexadecimal Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Hex(Argument, Handle, Width, Precision, Flags, Type)
;
;		Save the required registers
;		If type is uppercase
;			Set the uppercase format flag
;		Endif
;		Set current number base to hexadecimal
;		Call routine to get the argument address
;		Call routine to output the numeric string
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		BX    - Points to next argument
;
;******************************************************************************
Do_Hex		Proc	Near		; Hexadecimal formatting procedure
Do_Hex_Upper	Label	Near		; Do_Hex_Upper entry point (ABCDEF)
	or	bp,UPPER_CASE		; Set uppercase formatting flag
Do_Hex_Lower	Label	Near		; Do_Hex_Lower entry point (abcdef)
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	mov	ch,HEX			; Set the current number base to hex
	call	Get_Address		; Call routine to get argument address
	call	Compute 		; Call routine to output number
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Hex		Endp			; End of the Do_Hex procedure
	Subttl	Do_Decimal	Decimal Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Decimal(Argument, Handle, Width, Precision, Flags)
;
;		Save the required registers
;		Set the signed type formatting flag
;		Set current number base to decimal
;		Call routine to get the argument address
;		Call routine to output the numeric string
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		BX    - Points to next argument
;
;******************************************************************************
Do_Decimal	Proc	Near		; Decimal formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	or	bp,SIGNED_TYPE		; Set signed type formatting flag
	mov	ch,DECIMAL		; Set current number base to decimal
	call	Get_Address		; Call routine to get argument address
	call	Compute 		; Call routine to output number
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Decimal	Endp			; End of the Do_Decimal procedure
	Subttl	Do_Unsigned	Unsigned Decimal Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Unsigned(Argument, Handle, Width, Precision, Flags)
;
;		Save the required registers
;		Set current number base to decimal
;		Call routine to get the argument address
;		Call routine to output the numeric string
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		BX    - Points to next argument
;
;******************************************************************************
Do_Unsigned	Proc	Near		; Unsigned decimal formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	mov	ch,DECIMAL		; Set current number base to decimal
	call	Get_Address		; Call routine to get argument address
	call	Compute 		; Call routine to output number
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Unsigned	Endp			; End of the Do_Unsigned procedure
	Subttl	Do_Octal	Octal Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Octal(Argument, Handle, Width, Precision, Flags)
;
;		Save the required registers
;		Set current number base to octal
;		Call routine to get the argument address
;		Call routine to output the numeric string
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		BX    - Points to next argument
;
;******************************************************************************
Do_Octal	Proc	Near		; Octal formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	mov	ch,OCTAL		; Set current number base to octal
	call	Get_Address		; Call routine to get argument address
	call	Compute 		; Call routine to output number
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Octal	Endp			; End of the Do_Octal procedure
	Subttl	Do_Binary	Binary Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Binary(Argument, Handle, Width, Precision, Flags)
;
;		Save the required registers
;		Set current number base to binary
;		Call routine to get the argument address
;		Call routine to output the numeric string
;		Retore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		BX    - Points to next argument
;
;******************************************************************************
Do_Binary	Proc	Near		; Binary formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	mov	ch,BINARY		; Set current number base to binary
	call	Get_Address		; Call routine to get argument address
	call	Compute 		; Call routine to output number
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Binary	Endp			; End of the Do_Binary procedure
	Subttl	Do_Fractional	Fractional Formatting Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Do_Fractional(Argument, Handle, Width, Precision, Flags)
;
;		Save the required registers
;		Set the signed type formatting flag
;		Set current number base to decimal
;		Call routine to get the argument address
;		Call routine to output the numeric string
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:BX - Pointer to argument
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		BX    - Points to next argument
;
;******************************************************************************
Do_Fractional	Proc	Near		; Fractional formatting procedure
	Save	si,ds			; Save the required registers
	call	Variable		; Call routine to check width/precision
	or	bp,SIGNED_TYPE		; Set signed type formatting flag
	or	bp,FRACTIONAL		; Set the fractional formatting flag
	mov	ch,DECIMAL		; Set current number base to decimal
	call	Get_Address		; Call routine to get argument address
	call	Compute 		; Call routine to output number
	Restore si,ds			; Restore the required registers
	ret				; Return to the caller
Do_Fractional	Endp			; End of the Do_Fractional procedure
	Subttl	Get_Address	Get Argument Address Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Get_Address(Argument, Flags)
;
;		If far format specifier has been set
;			Set DS:SI to far pointer at DS:BX
;			Increment BX to next argument (4)
;		Else no far specifier
;			Set SI to near pointer at DS:BX
;			Increment BX to next argument (2)
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:BX - Pointer to argument list
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		DS:SI - New address pointer (Character or string)
;		BX    - Points to the next argument
;
;******************************************************************************
Get_Address	Proc	Near		; Get address procedure
	test	bp,FAR_SPEC		; Check for far specifier set
	jz	Near_Addr		; Jump if a normal near address
Far_Addr:
	lds	si,Dword Ptr ds:[bx]	; Load the far address into DS:SI
	add	bx,FAR_SIZE		; Update the argument pointer value
	jmp	Get_Exit		; Go return to the caller
Near_Addr:
	mov	si,Word Ptr ds:[bx]	; Load the near address into SI
	add	bx,NEAR_SIZE		; Update the argument pointer value
Get_Exit:
	ret				; Return to the caller
Get_Address	Endp			; End of the Get_Address procedure
	Subttl	Variable	Get Variable Value Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Variable(Width, Precision, Flags)
;
;		Save the required registers
;		If variable width specified
;			Get the actual width value (Byte)
;		Endif
;		If variable precision specified
;			Get the actual precision value (Byte)
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:BX - Pointer to argument list
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		DH    - Actual width value
;		DL    - Actual precision value
;		BX    - Points to the next argument
;
;******************************************************************************
Variable	Proc	Near		; Get variable width/precision procedure
	Save	si			; Save the required registers
	test	bp,VAR_WIDTH		; Check for a variable width value
	jz	Pre_Chk 		; Jump if no variable width
	mov	si,Word Ptr ds:[bx]	; Load the near address into SI
	add	bx,NEAR_SIZE		; Update the argument pointer value
	mov	dh,Byte Ptr ds:[si]	; Get the actual field width value
Pre_Chk:
	test	bp,VAR_PRE		; Check for a variable precision value
	jz	Var_Exit		; Jump if no variable precision
	mov	si,Word Ptr ds:[bx]	; Load the near address into SI
	add	bx,NEAR_SIZE		; Update the argument pointer value
	mov	dl,Byte Ptr ds:[si]	; Get the actual precision value
Var_Exit:
	Restore si			; Restore the required registers
	ret				; Return to the caller
Variable	Endp			; End of the Variable procedure
	Subttl	Get_Length	Get String Length Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Get_Length(String)
;
;		Calculate the length of the string (Null terminator)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - Pointer to string
;
;	Registers on Exit:
;
;		AL    - Destroyed
;		CX    - String length
;		DI    - Destroyed
;		ES    - Destroyed
;		ZR    - Zero set if zero length
;
;******************************************************************************
Get_Length	Proc	Near		; Get string length procedure
	push	ds			; Put a copy of DS onto the stack
	pop	es			; Set ES to the current DS value
	mov	di,si			; Set DI to the current SI value
	mov	al,NULL 		; Setup to scan for null terminator
	mov	cx,MAX_WORD		; Setup to scan for maximum length
	repne	scasb			; Scan for the string terminator
	not	cx			; Correct the count value
	dec	cx			; Adjust to get actual string length
	ret				; Return to the caller
Get_Length	Endp			; End of the Get_Length procedure
	Subttl	Calculate	Calculate Pad Lengths Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Calculate(Width, Length)
;
;		Save the required registers
;		Calculate total pad length
;		If total pad length > 0
;			If left justification is not requested
;				Set pre pad count to total
;				Zero post pad count
;			Else left justification requested
;				Set post pad count to total
;				Zero pre pad count
;			Endif
;		Else total pad length < 0
;			Set pre pad count to zero
;			Set post pad count to zero
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		CL    - Length of the string
;		DH    - Field width
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		CH    - Post string pad count
;		CL    - Pre string pad count
;
;******************************************************************************
Calculate	Proc	Near		; Calculate pad length procedure
	Save	ax			; Save the required registers
	mov	al,dh			; Get the current field width
	mov	ah,cl			; Get the length of the output string
	xor	cx,cx			; Default pre/post pad counts to zero
	sub	al,ah			; Compute the total pad count
	jbe	Calc_Exit		; Jump if no pad necessary
	mov	cl,al			; Default to right justification
	test	bp,LEFT_JUST		; Check if left justify was specified
	jz	Calc_Exit		; Jump if no left justification
	mov	ch,cl			; Make post pad count the total count
	xor	cl,cl			; Zero the pre pad count value
Calc_Exit:
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Calculate	Endp			; End of the Calculate procedure
	Subttl	Pad		Output Pad Characters Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Pad(Handle, Pad, Count)
;
;		Save the required registers
;		While count > 0
;			Output the current pad character
;			Decrement the count
;		Endwhile
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		CL    - Pad count
;
;	Registers on Exit:
;
;		CL    - Destroyed
;
;******************************************************************************
Pad		Proc	Near		; Pad character procedure
	Save	ax			; Save the required registers
	or	cl,cl			; Check for no padding required
	jz	Pad_Exit		; Jump if no padding is required
	mov	al,SPACE_PAD		; Default to a space pad character
	test	bp,PAD_CHAR		; Check for a zero pad character
	jz	Pad_Loop		; Jump if using a space pad character
	mov	al,ZERO_PAD		; Setup to use a zero pad character
Pad_Loop:
	call	Write_TTY		; Call routine to output pad character
	dec	cl			; Decrement the pad count
	jnz	Pad_Loop		; Jump if more pad characters to send
Pad_Exit:
	Restore ax			; Restore the required registers
	ret				; Return to the caller
Pad		Endp			; End of the Pad procedure
	Subttl	Clear_Flags	Clear All Flags Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Clear_Flags(Flags)
;
;		Clear the formatting flags
;		Default to space padding
;		Zero the current field width
;		Clear direction flag (All string operations forward)
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		BP    - Destroyed (BP contains the flags and is zeroed)
;		DH    - Set to zero (Current field width)
;		DL    - Set to zero (Current field precision)
;
;******************************************************************************
Clear_Flags	Proc	Near		; Clear formatting flags procedure
	xor	bp,bp			; Clear all of the formatting flags
	xor	dh,dh			; Zero the current field width
	xor	dl,dl			; Zero the current field precision
	cld				; Clear the direction flag
	ret				; Return to the caller
Clear_Flags	Endp			; End of the Clear_Flags procedure
	Subttl	Print_Format	Print Format Character Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Print_Format(Handle)
;
;		Save the required registers
;		Output format specification character to handle
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;
;	Registers on Exit:
;
;		AL    - Destroyed
;		None
;
;******************************************************************************
Print_Format	Proc	Near		; Output format specifier procedure
	mov	al,FORMAT_CHAR		; Get format specifier character
	call	Write_TTY		; Output the format specifier to handle
	ret				; Return to the caller
Print_Format	Endp			; End of the Print_Format procedure
	Subttl	Check_Digit	Check Digit Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Check_Digit(Base, Character)
;
;		Save the required registers
;		Call routine to convert character to binary
;		If the character can be converted
;			If value is greater than base
;				Set carry flag (Character not a digit)
;			Endif
;		Else character cannot be converted
;			Set carry flag (Character not a digit)
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Digit to check (ASCII)
;		CH    - Number system base
;
;	Registers on Exit:
;
;		AL    - Binary value of digit (If it is a digit)
;		CY    - Set if character is not a digit in current base
;
;******************************************************************************
Check_Digit	Proc	Near		; Check digit procedure
	Save	bx			; Save the required registers
	Save	ax			; Save the original digit value
	call	Convert_Char		; Call routine to convert character
	mov	bl,al			; Save converted value in BL
	Restore ax			; Restore the original digit value
	jc	Check_Exit		; Jump if could not be converted
	cmp	bl,ch			; Check against current number base
	cmc				; Set correct carry flag state
	jc	Check_Exit		; Jump if not valid for this base
	mov	al,bl			; Digit is valid, save binary value
Check_Exit:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Check_Digit	Endp			; End of the Check_Digit procedure
	Subttl	Convert_Char	Convert to Binary Conversion Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Convert_Char(Character)
;
;		If character is a decimal digit (0 to 9)
;			Convert ASCII digit to binary (Subtract 30h)
;			Clear the carry flag (Character could be converted)
;		Else character is not a decimal digit
;			Convert character to uppercase
;			If character is a hex digit (A to F)
;				Convert ASCII digit to binary (Subtract 37h)
;				Clear carry flag (Character could be converted)
;			Else character is not a hex digit
;				Set carry flag (Could not be converted)
;			Endif
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Digit to check (ASCII)
;		CH    - Number system base
;
;	Registers on Exit:
;
;		AL    - Binary value of digit (If it is a digit)
;		CY    - Set if character is not a digit in current base
;
;******************************************************************************
Convert_Char	Proc	Near		; Convert character procedure
	sub	al,DECIMAL_ADJUST	; Adjust character for ASCII decimal
	jc	Convert_Exit		; Jump if below decimal limit
	cmp	al,DECIMAL		; Check for a valid decimal character
	cmc				; Set carry flag to correct state
	jnc	Convert_Exit		; Jump if there is a valid digit
	and	al,UPPER_MASK		; Convert anything else to uppercase
	sub	al,HEX_ADJUST		; Adjust character for ASCII hexadecimal
	cmp	al,DECIMAL		; Check for a valid hex character
	jc	Convert_Exit		; Jump if below hexadecimal limit
	cmp	al,HEX			; Check against upper hex limit
	cmc				; Set carry flag to correct state
Convert_Exit:
	ret				; Return to caller with value and flag
Convert_Char	Endp			; End of the Convert_Char procedure
	Subttl	Get_Number	ASCII to Binary Conversion Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Get_Number(String, Base, Length)
;
;		Save the required registers
;		While length > 0
;			Decrement the length
;			Get the next character from string
;			Call routine to check for a valid digit
;			If character is a valid digit
;				Add new value into total
;			Endif
;		Endwhile
;		Decrement pointer back to last character
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		CH    - Number Base
;		CL    - Maximum number length
;		DS:SI - Current string pointer
;
;	Registers on Exit:
;
;		CL    - Destroyed
;		DL    - Number retrieved (Zero if none)
;		DS:SI - Pointer to character following number
;		CY    - Carry set if no number was found
;		ZR    - Zero set if zero number found
;
;******************************************************************************
Get_Number	Proc	Near		; Get number procedure
	Save	ax,bx			; Save the required registers
	mov	dl,MAX_BYTE		; Get maximum value for a byte
	xor	al,al			; Initialize the current total
Get_Loop:
	mov	bx,ax			; Save current total in BX register
	lodsb				; Get the next string character
	call	Check_Digit		; Call routine to check for digit
	jc	Number_Exit		; Jump if this is not a valid digit
	inc	dl			; Increment no number present flag
	cbw				; Convert binary value into full word
	xchg	ax,bx			; Move total to AX, digit value in BX
	mul	ch			; Multiply current total by number base
	add	ax,bx			; Add in the new digit to current total
	dec	cl			; Decrement the number length count
	jnz	Get_Loop		; Jump if more digits are allowed
	mov	bx,ax			; Move the current total into BX
	inc	si			; Increment to next character
Number_Exit:
	dec	si			; Decrement back to non-digit character
	add	dl,0			; Set carry to indicate presence
	mov	dl,bl			; Save the computed number in DL
	or	dl,dl			; Set zero flag for zero result
	Restore ax,bx			; Restore the required registers
	ret				; Return to the caller
Get_Number	Endp			; End of the Get_Number procedure
	Subttl	Compute 	Convert Argument Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Compute(Argument, Handle, Width, Precision, Base, Flags)
;
;		Save the required registers
;		Allocate buffer space on the stack
;		If argument value is long
;			Get the long numeric value (4 bytes)
;		Else if argument value is short
;			Get the short numeric value (1 byte)
;			Convert short to long value
;		Else argument value is normal
;			Get the normal numeric value (2 bytes)
;			Convert normal to long value
;		Endif
;		If signed type is specified
;			If the value is signed
;				Set the signed value flag
;				Take the twos complement of the value
;			Endif
;		Endif
;		Zero the fraction value (Integer default)
;		If fractional type conversion
;			Separate number into integer and fraction
;		Endif
;		Convert integer to ASCII string in buffer
;		If fractional type conversion
;			Convert fraction to ASCII string in buffer
;		Endif
;		Calculate the numeric string length
;		Default to no sign character
;		If signed type conversion
;			If numeric value was signed (Negative)
;				Setup minus sign as sign character
;				Increment the string length (For sign character)
;			Else numeric value was not signed
;				If signed conversion was specified
;					Setup plus sign as sign character
;					Increment the string length
;				Endif
;			Endif
;		Endif
;		If field width is not set (Zero)
;			Set field width to string length
;		Endif
;		If string length > field width
;			Set the field overflow flag
;			Set string length to field width - 1
;		Endif
;		Call routine to calculate pad counts
;		If sign character is present
;			If pre-pad sign character
;				Output sign character to handle
;				Call routine to output pre-string pad characters
;			Else post-pad sign character
;				Call routine to output pre-string pad characters
;				Output sign character to handle
;			Endif
;		Else sign character is not present
;			Call routine to output pre-string pad characters
;		Endif
;		While length > 0
;			Get next character of string
;			Call routine to output character to handle
;			Decrement the length
;		Endwhile
;		Set current pad character to a space
;		Call routine to output post-string pad characters
;		If the field overflow flag is set
;			Output the overflow character
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Handle
;		DS:SI - Pointer to argument
;		CH    - Current number base
;		DH    - Current field width
;		DL    - Current field precision
;		BP    - Formatting flags
;
;	Registers on Exit:
;
;		Direction flag is cleared (Move Forward)
;
;******************************************************************************
Compute 	Proc	Near		; Output numeric string procedure
	Save	bx,si,ds		; Save the required registers
	sub	sp,BUFF_SIZE		; Allocate buffer space on the stack
	mov	di,sp			; Setup the buffer pointer
	add	di,BUFF_SIZE/2		; Set the starting buffer position
	push	ax			; Save the output handle value
	push	dx			; Save the field width/precision
	xor	dh,dh			; Convert precision to a full word
	push	dx			; Save the field precision
	mov	cl,ch			; Move current base value into CL
	xor	ch,ch			; Make current base value into a word
	xor	ax,ax			; Default to an unsigned
	xor	dx,dx			;			 non-long value
	test	bp,SHORT_SPEC		; Check for short value specified
	jnz	Get_Short		; Jump if short value specified
	test	bp,LONG_SPEC		; Check for long value specified
	jnz	Get_Long		; Jump if long value specified
	mov	ax,ds:[si]		; Get the normal value (2 Bytes)
	test	bp,SIGNED_TYPE		; Check for a signed conversion
	jz	Chk_Frac		; Jump if not a signed conversion
	cwd				; Signed conversion, do sign extension
	jmp	Chk_Sign		; Go check for signed argument
Get_Short:
	mov	al,ds:[si]		; Get the short value (1 Byte)
	test	bp,SIGNED_TYPE		; Check for a signed conversion
	jz	Chk_Frac		; Jump if not a signed conversion
	cbw				; Signed conversion,
	cwd				;		     do sign extension
	jmp	Chk_Sign		; Go check for signed argument
Get_Long:
	mov	ax,ds:[si]		; Get the
	mov	dx,ds:[si + 2]		;	  long value (4 Bytes)
Chk_Sign:
	test	bp,SIGNED_TYPE		; Check for a signed type
	jz	Chk_Frac		; Jump if not signed
	test	dx,SIGNED		; Check the number for signed
	jz	Chk_Frac		; Jump if number is not signed
	or	bp,SIGNED_VAL		; Set the signed value flag
	not	ax			; Ones complement of the LSW
	not	dx			; Ones complement of the MSW
	add	ax,1			; Twos complement of the LSW
	adc	dx,0			; Twos complement of the MSW
Chk_Frac:
	mov	si,ss			; Get the current stack segment
	mov	ds,si			; Setup DS to current stack segment
	mov	es,si			; Setup ES to current stack segment
	xor	bx,bx			; Zero fraction value (Integer default)
	test	bp,FRACTIONAL		; Check for fractional conversion
	jz	Do_Integer		; Jump if standard integer conversion
	test	bp,SHORT_SPEC		; Check for short value specified
	jnz	Do_Short		; Jump if a short fractional value
	test	bp,LONG_SPEC		; Check for long value specified
	jnz	Do_Long 		; Jump if a long fractional value
	mov	bh,al			; Move fraction value to MSB (BH)
	xor	bl,bl			; Zero the lower LSB of fraction (BL)
	mov	al,ah			; Move integer value to LSB (AL)
	xor	ah,ah			; Zero the upper MSB of integer (AH)
	xor	dx,dx			; Zero the upper MSW of integer (DX)
	jmp	Do_Integer		; Go convert the integer portion
Do_Long:
	mov	bx,ax			; Move fraction value to BX
	mov	ax,dx			; Move integer value to LSW (AX)
	xor	dx,dx			; Zero the upper MSW of integer (DX)
	jmp	Do_Integer		; Go convert the integer portion
Do_Short:
	mov	bh,al			; Move fraction value to MSB (BH)
	xor	bl,bl			; Zero the lower LSB of fraction (BL)
	xor	ax,ax			; Zero the lower LSW of integer (AX)
	xor	dx,dx			; Zero the upper MSW of integer (DX)
Do_Integer:
	push	di			; Save the starting position
	cld				; Clear direction flag (Move forward)
Integer_Loop:
	mov	si,ax			; Save LSW of value in SI register
	mov	ax,dx			; Move MSW of value into AX
	xor	dx,dx			; Setup to do the first divide
	div	cx			; Divide the MSW by the current base
	xchg	ax,si			; Setup for the second division
	div	cx			; Divide the result by the current base
	xchg	ax,dx			; Put the remainder into AX
	call	Digit			; Call routine to convert it to a digit
	stosb				; Store the ASCII digit into buffer
	xchg	ax,dx			; Restore quotient of second division
	mov	dx,si			; Restore quotient of first division
	or	si,ax			; Check for a zero result
	jnz	Integer_Loop		; Jump if more digits to get
Do_Fraction:
	pop	dx			; Restore the starting position
	pop	si			; Restore the field precision
	mov	ax,bx			; Get the fraction value into AX
	mov	bx,di			; Save the final position in BX
	mov	di,dx			; Get the starting position
	test	bp,FRACTIONAL		; Check for fractional conversion
	jz	Calc_Length		; Jump if standard integer conversion
	dec	di			; Decrement to get new start position
	std				; Set direction flag (Move Backward)
	mov	Byte Ptr es:[di],POINT	; Put a decimal point into buffer
	or	si,si			; Check for zero precision
	jz	Calc_Length		; Jump if no digits to compute
	dec	di			; Update pointer for decimal point
Fraction_Loop:
	mul	cx			; Multiply by the current base
	xchg	ax,dx			; Put the MSW of result into AX
	call	Digit			; Call routine to convert it to a digit
	stosb				; Store the ASCII digit into buffer
	xchg	ax,dx			; Restore fraction from multiply
	dec	si			; Decrement the precision count
	jnz	Fraction_Loop		; Jump if more digits left to do
	inc	di			; Correct for length calculation
Do_Round:
	mul	cx			; Compute the next actual digit
	shl	dx,1			; Multiply digit value by two
	cmp	dx,cx			; Compare value to current base
	jb	Calc_Length		; Jump if below current base value
	push	di			; Save the current position
	mov	ch,cl			; Move current base to CH
Round_Loop:
	mov	al,es:[di]		; Get the digit to round
	call	Convert_Char		; Convert the ASCII to binary
	inc	al			; Round the digit up
	mov	ah,al			; Save the rounded value in AH
	call	Digit			; Convert the binary digit to ASCII
	cmp	ah,ch			; Check the value against current base
	jb	Round_Done		; Jump if rounding is complete
	xor	al,al			; Zero the AL register value
	call	Digit			; Convert to an ASCII zero value
	mov	es:[di],al		; Zero the current digit value
	inc	di			; Increment to the next digit position
	cmp	di,bx			; Check against final position
	jbe	Round_Loop		; Jump if more digits to round with
	mov	bx,di			; Update the new final position
	xor	al,al			; Zero the AL register value
	inc	al			; Increment AL to a one value
	call	Digit			; Convert the one value to ASCII
Round_Done:
	mov	es:[di],al		; Save the last rounded digit
	pop	di			; Restore the current position
Calc_Length:
	pop	dx			; Restore field width/precision
	pop	ax			; Restore the file handle
	mov	cx,bx			; Get the final buffer pointer
	sub	cx,di			; Compute the numeric string length
	xor	al,al			; Default to no sign character
	test	bp,SIGNED_TYPE		; Check for signed type
	jz	Do_Check		; Jump if not a signed type
	test	bp,SIGNED_VAL		; Check for a signed value
	jz	Chk_Conv		; Jump if not a signed value
	mov	al,MINUS		; Setup minus as sign character
	inc	cx			; Increment the string length
	jmp	Do_Check		; Go check the field width
Chk_Conv:
	test	bp,SIGNED_CONV		; Check for a signed conversion
	jz	Do_Check		; Jump if not a signed type
	mov	al,PLUS 		; Setup plus as sign character
	inc	cx			; Increment the string length
Do_Check:
	or	dh,dh			; Check the current field width
	jnz	Width_Check		; Jump if field width specified
	mov	dh,cl			; Set field width to string length
Width_Check:
	cmp	cl,dh			; Check actual width to field width
	jbe	Do_Calc 		; Jump if string fits in the field
	or	bp,OVER_FLOW		; Set the field overflow flag
	mov	cl,dh			; Set string width to field width
	dec	cl			; Adjust for the overflow character
	jz	Compute_Exit		; Jump if no more room in the field
Do_Calc:
	push	ax			; Save the sign character (If any)
	mov	al,cl			; Save the actual string length
	call	Calculate		; Call routine to calculate pad values
	mov	dl,al			; Setup the string output length
	pop	ax			; Restore the sign character (If any)
	test	bp,PRE_PAD		; Check for pre pad sign character
	jz	Do_Pad			; Jump if not pre pad sign character
	or	al,al			; Check for a sign needed
	jz	Do_Pad			; Jump if no sign is needed
	call	Write_TTY		; Call routine to output sign character
	dec	dl			; Decrement the output count
	jz	Compute_Exit		; Jump if no more room in field
Do_Pad:
	call	Pad			; Call routine to output pad characters
	test	bp,PRE_PAD		; Check for post pad sign character
	jnz	Do_Setup		; Jump if not post pad sign character
	or	al,al			; Check for a sign needed
	jz	Do_Setup		; Jump if no sign character needed
	call	Write_TTY		; Call routine to output the sign
	dec	dl			; Decrement the output count
	jz	Compute_Exit		; Jump if no more room in field
Do_Setup:
	mov	si,bx			; Setup the source pointer to buffer
	dec	si			; Point back to first character
	std				; Set direction flag (Reverse order)
Send_Loop:
	lodsb				; Get the next character to output
	call	Write_TTY		; Call routine to output character
	dec	dl			; Decrement the output count
	jnz	Send_Loop		; Jump if more characters to output
	mov	cl,ch			; Get the calculated pad counts
	and	bp,Not PAD_CHAR 	; Set pad character to a space
	call	Pad			; Call routine to send pad characters
Compute_Exit:
	test	bp,OVER_FLOW		; Check for field overflow
	jz	Compute_Done		; Jump if no field overflow
	mov	al,ASTERISK		; Get the field overflow character (*)
	call	Write_TTY		; Output the field overflow character
Compute_Done:
	add	sp,BUFF_SIZE		; Deallocate the buffer area
	Restore bx,si,ds		; Restore the required registers
	cld				; Clear the direction flag
	ret				; Return to the caller
Compute 	Endp			; End of the Compute procedure
	Subttl	Digit		Binary to Character Conversion Routine
	Page	+
;******************************************************************************
;
;  Routine Functional Description
;
;	Digit(Value, Flags)
;
;		Save the required registers
;		Translate character to ASCII value
;		If uppercase flag is set
;			If ASCII value is not a digit (abcdef)
;				Convert to uppercase  (ABCDEF)
;			Endif
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Binary value (0 - 15)
;
;	Registers on Exit:
;
;		AL    - ASCII character
;
;******************************************************************************
Digit		Proc	Near		; Convert to ASCII digit procedure
	Save	bx			; Save the required registers
	lea	bx,cs:[Digit_Table]	; Get pointer to digit translate table
	xlat	byte ptr cs:[bx]	; Translate to ASCII digit
	test	bp,UPPER_CASE		; Check for uppercase flag
	jz	Digit_Exit		; Jump if no uppercase flag set
	cmp	al,DIGIT_MAX		; Check for uppercase adjust needed
	jbe	Digit_Exit		; Jump if adjustment not needed
	and	al,UPPER_MASK		; Convert character to uppercase
Digit_Exit:
	Restore bx			; Restore the required registers
	ret				; Return to the caller
Digit		Endp			; End of the Digit procedure
	Subttl			Define the Printf Data Areas
	Page	+
;******************************************************************************
;
;	Define any data tables needed by the Printf routine
;
;******************************************************************************
Format_Table	Label	Byte
	Db	'-'                     ; Left justify format specifier
	Db	'+'                     ; Set signed specifier
	Db	't'                     ; Short format specifier
	Db	'T'                     ; Short format specifier
	Db	'l'                     ; Long format specifier
	Db	'L'                     ; Long format specifier
	Db	'#'                     ; Far format specifier
FORMAT_SIZE	Equ	This Byte - Format_Table
Format_Jump	Label	Word
	Dw	Left_Justify		; Left justify format specifier
	Dw	Set_Signed		; Set signed specifier
	Dw	Short_Specify		; Short format specifier
	Dw	Short_Specify		; Short format specifier
	Dw	Long_Specify		; Long format specifier
	Dw	Long_Specify		; Long format specifier
	Dw	Far_Specify		; Far format specifier
Escape_Table	Label	Byte
	Db	'n'                     ; Newline escape character
	Db	't'                     ; Horizontal tab escape character
	Db	'v'                     ; Vertical tab escape character
	Db	'b'                     ; Backspace escape character
	Db	'r'                     ; Carriage return escape character
	Db	'f'                     ; Form feed escape character
	Db	'x'                     ; Output character (Hex representation)
ESCAPE_SIZE	Equ	This Byte - Escape_Table
Escape_Jump	Label	Word
	Dw	New_Line		; Newline escape character
	Dw	Horz_Tab		; Horizontal tab escape character
	Dw	Vert_Tab		; Vertical tab escape character
	Dw	Back_Space		; Backspace escape character
	Dw	Carr_Ret		; Carriage return escape character
	Dw	Form_Feed		; Form feed escape character
	Dw	Out_Hex 		; Output character (Hex representation)
Convert_Table	Label	Byte
	Db	'%'                     ; Print the percent sign
	Db	'c'                     ; Print next argument as a character
	Db	'C'                     ; Print next argument as a character
	Db	's'                     ; Print next argument as a string
	Db	'S'                     ; Print next argument as a string
	Db	'x'                     ; Print next argument as HEX (abcdef)
	Db	'X'                     ; Print next argument as HEX (ABCDEF)
	Db	'h'                     ; Print next argument as HEX (abcdef)
	Db	'H'                     ; Print next argument as HEX (ABCDEF)
	Db	'd'                     ; Print next argument as DECIMAL (+/-)
	Db	'D'                     ; Print next argument as DECIMAL (+/-)
	Db	'u'                     ; Print next argument as UNSIGNED
	Db	'U'                     ; Print next argument as UNSIGNED
	Db	'o'                     ; Print next argument as OCTAL
	Db	'O'                     ; Print next argument as OCTAL
	Db	'b'                     ; Print next argument as BINARY
	Db	'B'                     ; Print next argument as BINARY
	Db	'f'                     ; Print next argument as FRACTIONAL
	Db	'F'                     ; Print next argument as FRACTIONAL
CONVERT_SIZE	Equ	This Byte - Convert_Table
Convert_Jump	Label	Word
	Dw	Print_Format		; Print format routine
	Dw	Do_Char 		; Print character routine
	Dw	Do_Char 		; Print character routine
	Dw	Do_String		; Print string routine
	Dw	Do_String		; Print string routine
	Dw	Do_Hex_Lower		; Print lowercase hexadecimal routine
	Dw	Do_Hex_Upper		; Print uppercase hexadecimal routine
	Dw	Do_Hex_Lower		; Print lowercase hexadecimal routine
	Dw	Do_Hex_Upper		; Print uppercase hexadecimal routine
	Dw	Do_Decimal		; Print signed decimal routine
	Dw	Do_Decimal		; Print signed decimal routine
	Dw	Do_Unsigned		; Print unsigned decimal routine
	Dw	Do_Unsigned		; Print unsigned decimal routine
	Dw	Do_Octal		; Print octal routine
	Dw	Do_Octal		; Print octal routine
	Dw	Do_Binary		; Print binary routine
	Dw	Do_Binary		; Print binary routine
	Dw	Do_Fractional		; Print decimal fractional routine
	Dw	Do_Fractional		; Print decimal fractional routine
Digit_Table	Label	Byte		; Digit translation table
	Db	"0123456789abcdef"
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Printf module

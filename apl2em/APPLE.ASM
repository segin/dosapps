	Page	58,132
	Title	APPLE.ASM	Apple Emulator (65C02 Processor)
;******************************************************************************
;
;   Name:	APPLE.ASM	Apple Emulator (65C02 Processor)
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
;	specific part of the Apple emulator.
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
	Public	Initialize		; Apple emulator initialization routine
	Public	Read_Memory		; Read 65C02 Apple memory routine
	Public	Write_Memory		; Write 65C02 Apple memory routine
	Public	System_Reset		; Apple system reset routine (Interrupt)
	Public	System_Request		; System request routine (Interrupt)
	Public	Reset_System		; Apple reset system routine
	Public	Request_System		; Apple request system routine
	Public	Error			; Apple emulator error routine
	Public	Exit			; Apple emulator exit routine
;
;  External Declarations
;
	Extrn	Memory_Init:Near	; Memory initialization routine(MEMORY)
	Extrn	Device_Init:Near	; Device initialization routine(DEVICE)
	Extrn	Video_Init:Near 	; Video initialization routine	(VIDEO)
	Extrn	Video_Reset:Near	; Video reset routine		(VIDEO)
	Extrn	Int_Init:Near		; Interrupt initialization	  (INT)
	Extrn	Int_Reset:Near		; Interrupt reset routine	  (INT)
	Extrn	TTY_Init:Near		; Initialize TTY mode routine	  (TTY)
	Extrn	TTY_Reset:Near		; Reset TTY mode routine	  (TTY)
	Extrn	Write_TTY:Near		; Write TTY routine		  (TTY)
	Extrn	Set_Position:Near	; Set current position routine	  (TTY)
	Extrn	Set_Row:Near		; Set current row routine	  (TTY)
	Extrn	Set_Column:Near 	; Set current column routine	  (TTY)
	Extrn	Set_Attribute:Near	; Set current attribute routine   (TTY)
	Extrn	Set_Foreground:Near	; Set current foreground routine  (TTY)
	Extrn	Set_Background:Near	; Set current background routine  (TTY)
	Extrn	Set_Cursor:Near 	; Set cursor position routine	  (TTY)
	Extrn	Set_Type:Near		; Set cursor type routine	  (TTY)
	Extrn	Get_Position:Near	; Get current position routine	  (TTY)
	Extrn	Get_Row:Near		; Get current row routine	  (TTY)
	Extrn	Get_Column:Near 	; Get current column routine	  (TTY)
	Extrn	Get_Attribute:Near	; Get current attribute routine   (TTY)
	Extrn	Get_Foreground:Near	; Get current foreground routine  (TTY)
	Extrn	Get_Background:Near	; Get current background routine  (TTY)
	Extrn	Get_Cursor:Near 	; Get cursor position routine	  (TTY)
	Extrn	Get_Type:Near		; Get cursor type routine	  (TTY)
	Extrn	Clear_Screen:Near	; Clear screen routine		  (TTY)
	Extrn	Scroll_Up:Near		; Scroll window up routine     (WINDOW)
	Extrn	Scroll_Down:Near	; Scroll window down routine   (WINDOW)
	Extrn	Clear_Window:Near	; Clear window routine	       (WINDOW)
	Extrn	Save_Window:Near	; Save window routine	       (WINDOW)
	Extrn	Restore_Window:Near	; Restore window routine       (WINDOW)
	Extrn	Flush_Keyboard:Near	; Flush keyboard routine     (KEYBOARD)
	Extrn	Get_Key:Near		; Get keyboard code routine  (KEYBOARD)
	Extrn	Printf:Near		; Generic Printf routine       (PRINTF)
	Extrn	Set_LED:Near		; Set keyboard LED routine   (KEYBOARD)
	Extrn	Key_Reset:Near		; Keyboard reset routine     (KEYBOARD)
	Extrn	Key_Status:Byte 	; Keyboard status byte	     (KEYBOARD)
	Extrn	Last_Key:Byte		; Last keyboard scan code    (KEYBOARD)
	Extrn	Error_Table:Word	; Error string table		 (DATA)
	Extrn	System_ROM:Word 	; Apple system ROM file name	 (DATA)
	Extrn	Read_Table:Word 	; Read memory page table	 (DATA)
	Extrn	Write_Table:Word	; Write memory page table	 (DATA)
	Extrn	System_Flag:Byte	; Apple emulator system flag byte(DATA)
	Extrn	Emulate_Flag:Byte	; Emulator system flag byte	 (DATA)
	Extrn	RAM_Space:Word		; RAM space segment value	 (DATA)
	Extrn	ALT_Space:Word		; Alternate RAM space segment	 (DATA)
	Extrn	ERR_NO_MEMORY:Abs	; Not enough memory error code	 (DATA)
	Extrn	ERR_NO_SYSTEM_FILE:Abs	; No system ROM file error code  (DATA)
	Extrn	ERR_BAD_SYSTEM_FILE:Abs ; Bad system ROM file error code (DATA)
	Extrn	ERR_BAD_SYSTEM_IMAGE:abs; Bad system ROM image error code(DATA)
;
;  LOCAL Equates
;
SYSTEM_ADDRESS	Equ	0D000h		; Apple system ROM load address
SYSTEM_SIZE	Equ	3000h		; Apple system ROM size (Bytes)
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
	Subttl	Initialize	Initialize the Apple Emulator
	Page	+
;******************************************************************************
;
;	Initialize()
;
;		Clear direction flag (All moves are forward)
;		Try to allocate the 65C02 RAM space (64k)
;		If able to allocate the RAM space
;			Call routine to initialize memory
;			Call routine to load the Apple system ROM
;			Call routine to initialize expansion slot devices
;			Call routine to initialize interrupts
;			Call routine to initialize video system
;			Call routine to initilize keyboard LED's
;			Try to allocate the alternate 65C02 RAM space (64k)
;			If able to allocate the RAM space
;				Save the alternate RAM space segment
;				Call routine to initialize memory
;				Call routine to setup 65C02 registers (Reset)
;			Else unable to allocate the needed RAM space
;				Set error code to not enough memory
;				Call the error routine
;				Call routine to exit the emulator
;			Endif
;		Else unable to allocate the needed RAM space
;			Set error code to not enough memory
;			Call the error routine
;			Call routine to exit the emulator
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		None
;
;	Registers on Exit:
;
;		DL    - Accumulator initialized        (0h)
;		DH    - 65C02 flags initialized        (0h)
;		CL    - Y index register initialized   (0h)
;		CH    - X index register initialized   (0h)
;		BX    - Stack pointer initialized    (1FFh)
;		SI    - Program counter initialized (FFFCh)
;		DS    - 65C02 RAM space
;		ES    - Video RAM segment
;
;******************************************************************************
		Even			; Force procedure to even address
Initialize	Proc	Near		; Emulator initialization procedure
	cld				; Clear direction flag (All forward)
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,RAM_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate the 65C02 RAM space
	jnc	Continue		; Jump if no errors allocating space
Memory_Error:
	mov	al,ERR_NO_MEMORY	; Get not enough memory error code
	call	Error			; Call routine to print the error
	call	Exit			; Call routine to exit the emulator
Continue:
	mov	ds,ax			; Setup RAM space segment address
	mov	cs:[RAM_Space],ax	; Save the RAM space segment address
	call	Memory_Init		; Call routine to initialize memory
	call	Load_System		; Call routine to load system ROM
	call	Device_Init		; Call routine to initialize devices
	call	Int_Init		; Call routine to initialize interrupts
	call	Video_Init		; Call routine to initialize video
	call	Set_LED 		; Call routine to initialize LED's
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,RAM_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate the 65C02 RAM space
	jc	Memory_Error		; Jump if errors allocating space
	mov	cs:[ALT_Space],ax	; Save alternate RAM space segment
	mov	ds,ax			; Setup RAM space segment address
	call	Memory_Init		; Call routine to initialize memory
	mov	ds,cs:[RAM_Space]	; Setup the 65C02 RAM space segment
	call	CPU_Init		; Call CPU initialize routine
	ret				; Return to the caller
Initialize	Endp			; End of the Initialize procedure
	Subttl	Load_System	Load the Apple System ROM
	Page	+
;******************************************************************************
;
;	Load_System(RAM_Space)
;
;		Try to open the Apple System ROM data file
;		If no errors opening the System ROM file
;			Try to read in the System ROM image
;			If errors reading the System ROM
;				Set error code to bad System ROM file
;				Call the error routine
;				Call routine to exit the emulator
;			Endif
;			Close the System ROM file
;		Else errors opening the System ROM file
;			Set error code to no System ROM file
;			Call the error routine
;			Call routine to exit the emulator
;		Endif
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Load_System	Proc	Near		; Load System ROM procedure
	mov	ax,cs			; Get the current code segment value
	mov	bx,ds			; Save 65C02 RAM space segment value
	mov	ds,ax			; Setup to open the system ROM file
	mov	ah,OPEN_FILE		; Get the open file function code
	mov	al,READ_ONLY		; Get the read file access code
	lea	dx,cs:[System_ROM]	; Get pointer to system ROM file name
	int	DOS			; Try to open the system ROM file
	jnc	Read_System_ROM 	; Jump if no errors opening file
	mov	al,ERR_NO_SYSTEM_FILE	; Get no system ROM file error code
System_ROM_Error:
	call	Error			; Call routine to print the error
	call	Exit			; Call routine to exit emulator
Read_System_ROM:
	mov	ds,bx			; Restore 65C02 RAM space segment value
	mov	bx,ax			; Move file handle to BX register
	mov	ah,READ_FILE		; Get read file function code
	mov	dx,SYSTEM_ADDRESS	; Setup the data buffer address
	mov	cx,SYSTEM_SIZE		; Get the system ROM image size (12k)
	int	DOS			; Try to read the system ROM image
	mov	cx,ax			; Save ROM image size in CX register
	mov	al,ERR_BAD_SYSTEM_FILE	; Get bad system ROM file error code
	jc	System_ROM_Error	; Jump if error trying to read the file
	cmp	cx,SYSTEM_SIZE		; Check for all of image read in
	mov	al,ERR_BAD_SYSTEM_IMAGE ; Get bad system ROM image error code
	jne	System_ROM_Error	; Jump if part of image missing
	mov	ah,CLOSE_FILE		; Get close file function code
	int	DOS			; Close the system ROM file
	ret				; Return to the caller
Load_System	Endp			; End of the Load_System procedure
	Subttl	CPU_Init	Initialize the 65C02 CPU Registers
	Page	+
;******************************************************************************
;
;	CPU_Init()
;
;		Initialize the accumulator register			(0h)
;		Initialize the X index register 			(0h)
;		Initialize the Y index register 			(0h)
;		Initialize the stack pointer register		      (1FFh)
;		Initialize the program counter register 	     (FFFCh)
;		Initialize the 65C02 processor status register		(0h)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		DL    - Accumulator initialized        (0h)
;		DH    - 65C02 flags initialized        (0h)
;		CL    - Y index register initialized   (0h)
;		CH    - X index register initialized   (0h)
;		BX    - Stack pointer initialized    (1FFh)
;		SI    - PC initialized	     (Reset Vector)
;
;******************************************************************************
		Even			; Force procedure to even address
CPU_Init	Proc	Near		; Initialize CPU registers procedure
	xor	dl,dl			; Initialize the accumualtor register
	xor	ch,ch			; Initialize the X index register
	xor	cl,cl			; Initialize the Y index register
	mov	bx,STACK_TOP		; Initialize the stack pointer
	mov	si,ds:[RST_VECTOR]	; Initialize the program counter
	xor	dh,dh			; Initialize 65C02 processor flags
	ret				; Return to the caller
CPU_Init	Endp			; End of the CPU_Init procedure
	Subttl	Error		Emulator Error Routine
	Page	+
;******************************************************************************
;
;	Error(Error_Code)
;
;		Save the required registers
;		Print the correct error message
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Error code
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Error		Proc	Near		; Emulator error procedure
	Save	ds			; Save the required registers
	xor	ah,ah			; Convert error code to full word
	shl	ax,1			; Convert error code to table index
	mov	bx,ax			; Move table index into BX register
	mov	si,cs:[bx+Error_Table]	; Get the error string address
	mov	ax,cs			; Get current CS register value
	mov	ds,ax			; Setup to access the error string
	mov	ah,WRITE_FILE		; Get write file function code
	mov	bx,STD_ERROR		; Get the standard error handle
	lodsb				; Get the length of the error string
	mov	cl,al			; Move string length into CL register
	xor	ch,ch			; Convert string length into full word
	mov	dx,si			; Setup error string address
	int	DOS			; Print the error string to handle
	Restore ds			; Restore the required registers
	ret				; Return to the caller
Error		Endp			; End of the Error procedure
	Subttl	Exit		Emulator Exit Routine
	Page	+
;******************************************************************************
;
;	Exit()
;
;		Call routine to reset interrupt vectors
;		Call routine to reset video
;		Call routine to reset keyboard
;		Zero the return code
;		Exit to DOS
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
Exit		Proc	Near		; Emulator exit procedure
	call	Int_Reset		; Call the interrupt reset routine
	call	Video_Reset		; Call the video reset routine
	call	Key_Reset		; Call the keyboard reset routine
	mov	ah,TERMINATE		; Get the terminate function code
	xor	al,al			; Zero the return code
	int	DOS			; Return control to MS-DOS
	ret				; Return to the caller (Never executed)
Exit		Endp			; End of the Exit procedure
	Subttl	Read_Memory	Read 65C02 Apple Memory Routine
	Page	+
;******************************************************************************
;
;	Read_Memory(Effective_Address)
;
;		Get the memory page from effective address
;		Jump to correct routine to process read
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - 65C02 Memory value
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Read_Memory	Proc	Near		; Read 65C02 Apple memory procedure
	mov	bp,di			; Get the effective address
	shr	bp,8			; Get page number into BP register
	shl	bp,1			; Convert page number to table index
	jmp	cs:[bp + Read_Table]	; Jump to correct routine to read
	ret				; Return to the caller (Never executed)
Read_Memory	Endp			; End of the Read_Memory procedure
	Subttl	Write_Memory	Write 65C02 Apple Memory Routine
	Page	+
;******************************************************************************
;
;	Write_Memory(Effective_Address, Data_Value)
;
;		Get the memory page from effective address
;		Jump to correct routine to process write
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;		AL    - 65C02 Memory value
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		DI    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Write_Memory	Proc	Near		; Write 65C02 Apple memory procedure
	mov	bp,ax			; Save memory value in BP register
	mov	ax,di			; Get the effective address
	shr	ax,8			; Get page number into AX register
	shl	ax,1			; Convert page number to table index
	xchg	bp,ax			; Setup to jump to correct routine
	jmp	cs:[bp + Write_Table]	; Jump to correct routine to write
	ret				; Return to the caller (Never executed)
Write_Memory	 Endp			; End of the Write_Memory procedure
	Subttl	System_Reset	Apple System Reset Routine
	Page	+
;******************************************************************************
;
;	System_Reset(Scan_Code)
;
;		If the last scan code does NOT match (NOT a repeat)
;			If this is a make code
;				Set system reset interrupt type
;			Endif this is a break code
;		Endif this key is repeating
;		Return control to the caller
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
System_Reset	Proc	Near		; Apple system reset procedure
	cmp	ah,cs:[Last_Key]	; Check for a repeat scan code
	je	Reset_Done		; Jump if this key is repeating
	or	ah,ah			; Check for a make or break code
	js	Reset_Done		; Jump if this is a break code
	or	cs:[Emulate_Flag],SYS_RESET
Reset_Done:
	ret				; Return to the caller
System_Reset	 Endp			; End of the System_Reset procedure
	Subttl	System_Request	Emulator System Request Routine
	Page	+
;******************************************************************************
;
;	System_Request()
;
;		If this is a make code
;			Set system request interrupt type
;		Endif this is a break code
;		Return control to the caller
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
System_Request	Proc	Near		; Emulator system request procedure
	or	ah,ah			; Check for a make or break code
	js	Request_Done		; Jump if this is a break code
	test	cs:[Emulate_Flag],SYS_REQUEST
	jnz	Request_Done		; Jump if already in system procedure
	or	cs:[Emulate_Flag],SYS_REQUEST
Request_Done:
	ret				; Return to the caller
System_Request	 Endp			; End of the System_Request procedure
	Subttl	Reset_System	Reset System Routine
	Page	+
;******************************************************************************
;
;	Reset_System(Interrupt_Number, RAM_Space, Registers, Address)
;
;		Clear the system reset interrupt bit
;		Call routine to reset the processor registers
;		Setup to execute the next opcode (No interrupt check)
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
;		DL    - Accumulator initialized        (0h)
;		DH    - 65C02 flags initialized        (0h)
;		CL    - Y index register initialized   (0h)
;		CH    - X index register initialized   (0h)
;		BX    - Stack pointer initialized    (1FFh)
;		SI    - Program counter initialized (FFFCh)
;		DI    - Set to new opcode address
;
;******************************************************************************
		Even			; Force procedure to even address
Reset_System	Proc	Near		; Reset system procedure
	and	cs:[Emulate_Flag],Not SYS_RESET
	call	CPU_Init		; Call routine to initialize registers
	Setup				; Setup the new opcode address
	jmp	di			; Go process the new opcode
Reset_System	Endp			; End of the Reset_System procedure
	Subttl	Request_System	Request System Routine
	Page	+
;******************************************************************************
;
;	Request_System(Interrupt_Number, RAM_Space, Registers, Address)
;
;
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
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Request_System	Proc	Near		; Request system procedure
	or	cs:[System_Flag],INPUT	; Put keyboard into input mode
	call	Flush_Keyboard		; Call routine to flush the keyboard
	call	TTY_Init		; Call routine to initialize TTY console
	call	Clear_Screen		; Call routine to clear the screen
Request_Exit:
	and	cs:[System_Flag],Not INPUT
	and	cs:[Emulate_Flag],Not SYS_REQUEST
	call	Exit			; Call routine to exit the emulator
	ret				; Return control to the caller
Request_System	Endp			; End of the Request_System procedure
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Apple module

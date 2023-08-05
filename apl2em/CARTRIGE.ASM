	Page	58,132
	Title	CARTRIGE.ASM	Cartridge Routines
;******************************************************************************
;
;   Name:	CARTRIGE.ASM	Cartridge Routines
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
;	cartridge.
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
	Public	Cart_ID 		; Cartridge ID string
	Public	Cart_Init		; Cartridge initialization routine
	Public	Cart_Ctrl		; Cartridge control routine
	Public	Cart_Rd 		; Cartridge read routine
	Public	Cart_Wrt		; Cartridge write routine
	Public	Cart_Mem_Rd		; Cartridge memory read routine
	Public	Cart_Mem_Wrt		; Cartridge memory write routine
	Public	Cart_Exp_Rd		; Cartridge expansion read routine
	Public	Cart_Exp_Wrt		; Cartridge expansion write routine
	Public	Cart_Data		; Cartridge data segment pointers
;
;  External Declarations
;
	Extrn	Slot_Address:Near	; Get expansion slot address   (DEVICE)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
	Extrn	ERR_NO_MEMORY:Abs	; Not enough memory error code	 (DATA)
;
;  LOCAL Equates
;
CART_SIZE	Equ	0805h		; Cartridge memory size (32K)
CART_MAX	Equ	8000h		; Maximum cartridge size (32k Bytes)
AREA_MAX	Equ	0400h		; Maximum area size (2k/1k Bytes/Words)
AREA_START	Equ	0C800h		; Area starting address
AREA_SHIFT	Equ	03h		; Area shift count value
CTRL_INIT	equ	0FFh		; Cartridge control initialization
CONTROL_MASK	Equ	0Fh		; Cartridge control bits mask
ASCII_CONVERT	Equ	30h		; ASCII conversion value (Slot)
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
	Include 	StrucS.inc	; Include the structure definitions
	.286c				; Include 80286 instructions
	Page
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	Cart_Init	Cartridge Initialization
	Page	+
;******************************************************************************
;
;	Cart_Init(RAM_Space, Slot_Number)
;
;		Try to allocate memory for the cartridge area
;		If errors allocating memory
;			Set error code to not enough memory
;			Call the error routine
;			Call routine to exit the emulator
;		Endif
;		Save address of cartridge data area
;		Initialize the cartridge control byte
;		Try to open the cartridge file
;		If no errors opening cartridge file
;			Try to read the cartridge image
;		Endif for opening cartridge file
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Slot number (0 - 7)
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Init	Proc	Near		; Cartridge initialization procedure
	mov	di,ax			; Get the language card slot number
	shl	di,1			; Convert slot number to table index
Cart_Allocate:
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,CART_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate cartridge space
	jnc	Cart_Setup		; Jump if no errors allocating space
Memory_Error:
	mov	al,ERR_NO_MEMORY	; Get not enough memory error code
	call	Error			; Call routine to print the error
	call	Exit			; Call routine to exit the emulator
Cart_Setup:
	Save	ds,es			; Save the DS and ES register values
	mov	ds,ax			; Setup cartridge segment address
	mov	cs:[di + Cart_Data],ax	; Save cartridge segment address
	mov	ds:[Cart_Byte],CTRL_INIT; Initialize the cartridge control byte
	mov	ax,ds			; Get the cartridge segment
	mov	es,ax			; Set ES to cartridge segment
	mov	ax,cs			; Get current CS register value
	mov	ds,ax			; Set DS to current CS register value
	mov	dx,di			; Get the cartridge slot index
	shr	dx,1			; Convert slot index to slot number
	add	dl,ASCII_CONVERT	; Convert slot to ASCII
	lea	si,cs:[Base_File]	; Get pointer to base file name
	mov	di,Cart_File		; Get pointer to cartridge file name
	mov	cx,Size Cart_Name	; Get length of the base file name
	rep	movsb			; Setup base file name for drive A
	mov	es:[Cart_File.Cart_Slot],dl
	mov	ax,es			; Get cartridge segment value
	mov	ds,ax			; Set DS to cartridge segment
Open_Cart_File:
	mov	ah,OPEN_FILE		; Get the open file function code
	mov	al,READ_ONLY		; Get read only file access code
	mov	dx,Cart_File		; Get pointer to file name
	int	DOS			; Try to open cartridge file
	jc	Cart_Exit		; Jump if errors opening the file
Read_Cart_File:
	mov	bx,ax			; Move file handle to BX register
	mov	ah,READ_FILE		; Get read file function code
	mov	dx,Cart_Image		; Setup the buffer address
	mov	cx,CART_MAX		; Get maximum cartridge size (32k)
	int	DOS			; Try to read the cartridge image
	mov	ah,CLOSE_FILE		; Get close file function code
	int	DOS			; Close the disk ROM file
Cart_Exit:
	Restore ds,es			; Restore the DS and ES register values
	ret				; Return to the caller
Cart_Init	Endp			; End of the Cart_Init procedure
	Subttl	Cart_Ctrl	Cartridge Control
	Page	+
;******************************************************************************
;
;	Cart_Ctrl(RAM_Space, Slot_Number)
;
;
;		Return to the caller
;
;	Registers on Entry:
;
;		AX    - Slot number (0 - 7)
;		DS    - 65C02 RAM space
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Ctrl	Proc	Near		; Cartridge card control procedure

	ret				; Return to the caller
Cart_Ctrl	Endp			; End of the Cart_Ctrl procedure
	Subttl	Cart_Rd 	Cartridge Read
	Page	+
;******************************************************************************
;
;	Cart_Rd(Effective_Address, Slot_Index)
;
;		Save the required registers
;		Setup the cartridge data segment
;		Get the cartridge control bits (From effective address)
;		Get the current control bits value
;		Update the control bits value
;		Call the cartridge update routine
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		BP    - Slot index (Slot number * 2)
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;		AH    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Rd 	Proc	Near		; Cartridge read procedure
	Save	es			; Save the required registers
	mov	es,cs:[bp + Cart_Data]	; Setup the cartridge data segment
	mov	ax,di			; Get the effective address
	and	ax,CONTROL_MASK 	; Mask off all but the control bits
	mov	ah,es:[Cart_Byte]	; Get the current control bit values
	mov	es:[Cart_Byte],al	; Update the control bits value
	call	Cart_Update		; Call the cartridge update routine
Cart_Rd_Exit:
	Restore es			; Restore the required registers
	ret				; Return to the caller
Cart_Rd 	Endp			; End of the Cart_Rd procedure
	Subttl	Cart_Wrt	Cartridge Write
	Page	+
;******************************************************************************
;
;	Cart_Wrt(Effective_Address, Slot_Index, Memory_Value)
;
;		Save the required registers
;		Setup the cartridge data segment
;		Get the cartridge control bits (From effective address)
;		Get the current control bits value
;		Update the control bits value
;		Call the cartridge update routine
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		BP    - Slot index (Slot number * 2)
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Wrt	Proc	Near		; Cartridge write procedure
	Save	ax,es			; Save the required registers
	mov	es,cs:[bp + Cart_Data]	; Setup the cartridge data segment
	mov	ax,di			; Get the effective address
	and	ax,CONTROL_MASK 	; Mask off all but the control bits
	mov	ah,es:[Cart_Byte]	; Get the current control bit values
	mov	es:[Cart_Byte],al	; Update the control bits value
	call	Cart_Update		; Call the cartridge update routine
Cart_Wrt_Exit:
	Restore ax,es			; Restore the required registers
	ret				; Return to the caller
Cart_Wrt	Endp			; End of the Cart_Wrt procedure
	Subttl	Cart_Mem_Rd	Cartridge Memory Read
	Page	+
;******************************************************************************
;
;	Cart_Mem_Rd(Effective_Address)
;
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Mem_Rd	Proc	Near		; Cartridge memory read procedure
	ret				; Return to the caller
Cart_Mem_Rd	Endp			; End of the Cart_Mem_Rd procedure
	Subttl	Cart_Mem_Wrt	Cartridge Memory Write
	Page	+
;******************************************************************************
;
;	Cart_Mem_Wrt(Effective_Address)
;
;		Return to the caller
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Mem_Wrt	Proc	Near		; Cartridge memory write procedure
	ret				; Return to the caller
Cart_Mem_Wrt	Endp			; End of the Cart_Mem_Wrt procedure
	Subttl	Cart_Exp_Rd	Cartridge Expansion Read
	Page	+
;******************************************************************************
;
;	Cart_Exp_Rd(Effective_Address)
;
;		Read the memory location value (Byte)
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		AL    - Memory value
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Exp_Rd	Proc	Near		; Cartridge expansion read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Cart_Exp_Rd	Endp			; End of the Cart_Exp_Rd procedure
	Subttl	Cart_Exp_Wrt	Cartridge Expansion Write
	Page	+
;******************************************************************************
;
;	Cart_Exp_Wrt(Effective_Address)
;
;		Return to the caller (Cartridge is NOT writable)
;
;	Registers on Entry:
;
;		AL    - Memory value
;		DS:DI - 65C02 Effective address
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Exp_Wrt	Proc	Near		; Cartridge expansion write procedure
	ret				; Return to the caller
Cart_Exp_Wrt	Endp			; End of the Cart_Exp_Wrt procedure
	Subttl	Cart_Update	Cartridge Update Routine
	Page	+
;******************************************************************************
;
;	Cart_Update(Old_Control, New_Control, RAM_Space, Cart_Segment)
;
;		Save the required registers
;		If control bits have changed
;			Get the size of area to update
;			Compute the source address
;			Setup destination to area
;			Update the memory area from cartridge
;		Endif for control bits
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Old control bits
;		AL    - New control bits
;		DS    - 65C02 RAM space
;		ES    - Cartridge segment
;
;	Registers on Exit:
;
;		AX-BX - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Cart_Update	Proc	Near		; Cartridge update procedure
	Save	cx,si,di,ds,es		; Save the required registers
	cmp	al,ah			; Check for control bits change
	je	Update_Done		; Jump if control bits identical
	mov	cx,AREA_MAX		; Get area maximum size (Words)
	mov	ah,al			; Get the new control bit settings
	xor	al,al			; Convert control bits to full word
	shl	ax,AREA_SHIFT		; Shift control bits into position
	mov	si,ax			; Setup the source index value
	add	si,Cart_Image		; Compute the actual source index
	mov	ax,ds			; Get the 65C02 RAM space segment
	mov	di,es			; Get the cartridge segment value
	mov	ds,di			; Setup DS to the cartridge segment
	mov	es,ax			; Setup ES to the 65C02 RAM space
	mov	di,AREA_START		; Setup destination to the area
	rep	movsw			; Move correct section into the area
Update_Done:
	Restore cx,si,di,ds,es		; Restore the required registers
Update_Exit:
	ret				; Return to the caller
Cart_Update	Endp			; End of the Cart_Update procedure
;******************************************************************************
;
;	Define the cartridge data areas
;
;******************************************************************************
Cart_Data	Equ	This Word	; Define the cartridge pointers
		Slot_Data	<>	; Pointers to the cartridge data areas
Base_File	Cart_Name	<>	; Define base cartridge file name
Cart_ID 	Equ	This Byte	; Cartridge ID string
		Db	"Cartridge",0
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Cartrige module

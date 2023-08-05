	Page	58,132
	Title	DISK.ASM	Disk Controller
;******************************************************************************
;
;   Name:	DISK.ASM	Disk Controller
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
;	disk drive controller.
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
	Public	Disk_ID 		; Disk controller ID string
	Public	Disk_Init		; Disk controller initialize routine
	Public	Disk_Ctrl		; Disk controller control routine
	Public	Disk_Rd 		; Disk controller read routine
	Public	Disk_Wrt		; Disk controller write routine
	Public	Disk_Mem_Rd		; Disk controller memory read routine
	Public	Disk_Mem_Wrt		; Disk controller memory write routine
	Public	Disk_Exp_Rd		; Disk ctrl. expansion read routine
	Public	Disk_Exp_Wrt		; Disk ctrl. expansion write routine
	Public	Disk_Data		; Disk controller data segment pointers
;
;  External Declarations
;
	Extrn	Slot_Address:Near	; Get expansion slot address   (DEVICE)
	Extrn	Error:Near		; Apple emulator error routine	(APPLE)
	Extrn	Exit:Near		; Apple emulator exit routine	(APPLE)
	Extrn	Disk_ROM:Word		; Apple disk ctrl. ROM file name (DATA)
	Extrn	Current_Slot:Byte	; Current active slot number	 (DATA)
	Extrn	ERR_NO_DISK_FILE:Abs	; No disk ROM file error code	 (DATA)
	Extrn	ERR_BAD_DISK_FILE:Abs	; Bad disk ROM file error code	 (DATA)
	Extrn	ERR_BAD_DISK_IMAGE:abs	; Bad disk ROM image error code  (DATA)
	Extrn	ERR_NO_MEMORY:Abs	; Not enough memory error code	 (DATA)
;
;  LOCAL Equates
;
DISK_SIZE	Equ	0100h		; Apple disk controller ROM size (Bytes)
CTRL_SIZE	Equ	030Ah		; Disk controller memory size (12K)
BUFFER_SIZE	Equ	0020h		; Pre-nibblization buffer size (.5K)
TRACK_SIZE	Equ	0100h		; Track buffer size (4K)
ASCII_CONVERT	Equ	4130h		; ASCII conversion value (Drive/Slot)
FLAG_INIT	Equ	04		; Disk flag init. value (Disk present)
PHASE_INIT	Equ	00h		; Disk phase initialization value
CONTROL_MASK	Equ	0Fh		; Disk controller control bits mask
READ		Equ	01h		; Read only file attribute bit
DRIVE_A 	Equ	00h		; Drive A selected value
DRIVE_B 	Equ	01h		; Drive B selected value
DISK_PROTECT	Equ	80h		; Apple disk drive protect bit
HIDDEN		Equ	02h		; Hidden file attribute bit
SYSTEM		Equ	04h		; System file attribute bit
SEARCH_ATTR	Equ	HIDDEN+SYSTEM	; File search attribute (Hidden/System)
PHASE_INCREMENT Equ	001h		; Phase increment value (+1)
PHASE_DECREMENT Equ	0FFh		; Phase decrement value (-1)
PHASE_WRAP	Equ	03h		; Phase wrap check value (3)
PHASE_MAX	Equ	50h		; Maximum phase value + 1 (80)
GAP_1		Equ	40h		; Gap 1 size (64 Bytes)
GAP_2		Equ	08h		; Gap 2 size (8 Bytes)
GAP_3		Equ	08h		; Gap 3 size (8 Bytes)
COUNT_13	Equ	0Dh		; 13 Sector disk sector limit value
COUNT_16	Equ	10h		; 16 Sector disk sector limit value
SELF_SYNC	Equ	0FFh		; Self sync byte value (Gap filler byte)
TRACK_MASK	Equ	0FEh		; Track phase mask value
SECTOR_MASK	Equ	0FF00h		; Sector pointer mask value
DISK_VOLUME	Equ	0FEh		; Dummy disk volume number
PRO_ADDR_1	Equ	0D5h		; Address
PRO_ADDR_2	Equ	0AAh		;	  mark prologue
PRO_ADDR_3	Equ	096h		;			string value
EPI_ADDR_1	Equ	0DEh		; Address
EPI_ADDR_2	Equ	0AAh		;	  mark epilogue
EPI_ADDR_3	Equ	0EBh		;			string value
PRO_DATA_1	Equ	0D5h		; Data
PRO_DATA_2	Equ	0AAh		;      mark prologue
PRO_DATA_3	Equ	0ADh		;		     string value
EPI_DATA_1	Equ	0DEh		; Data
EPI_DATA_2	Equ	0AAh		;      mark epilogue
EPI_DATA_3	Equ	0EBh		;		     string value
NIBBLE_BREAK	Equ	0100h		; Nibble buffer sector break point
START_5_3	Equ	0033h		; Starting byte for 5 to 3 nibblization
BREAK_5_3	Equ	009Ah		; Break point for 5 to 3 nibblization
START_6_2	Equ	0001h		; Starting byte for 6 to 2 nibblization
BREAK_6_2	Equ	0056h		; Break point for 6 to 2 nibblization
DECODE_MASK	Equ	7Fh		; Decode bits mask value
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
	Include 	Strucs.inc	; Include the structure definitions
	.286c				; Include 80286 instructions
	Page
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
	Subttl	Disk_Init	Disk Controller Initialization
	Page	+
;******************************************************************************
;
;	Disk_Init(RAM_Space, Slot_Number)
;
;		Call routine to get expansion slot address
;		Try to open the Disk Controller ROM data file
;		If no errors opening the Disk Controller ROM file
;			Try to read in the Disk Controller ROM image
;			If errors reading the Disk Controller ROM
;				Set error code to bad Disk Controller ROM file
;				Call the error routine
;				Call routine to exit the emulator
;			Endif
;			Close the Disk Controller ROM file
;			If nibblization buffer has not been allocated
;				Try to allocate memory for nibblization
;				If errors allocating memory
;					Set error code to not enough memory
;					Call the error routine
;					Call routine to exit the emulator
;				Endif
;				Save nibblization buffer segment
;				Try to allocate memory for track buffer
;				If errors allocating memory
;					Set error code to not enough memory
;					Call the error routine
;					Call routine to exit the emulator
;				Endif
;				Save track buffer segment
;			Endif for nibblization buffer
;			Try to allocate memory for the disk controller
;			If no errors allocating memory
;				Save address of disk controller data area
;			Else not enough memory available
;				Set error code to not enough memory
;				Call the error routine
;				Call routine to exit the emulator
;			Endif
;			Initialize the disk controller current drive (Drive A)
;			Initialize drive file names
;			Initialize disk flag value
;			Initialize drive phase values
;			Initialize drive track buffer pointer
;			Initialize track limit value (16 Sector)
;			Initialize track buffer size (16 Sector)
;			Initialize sector limit value (16)
;			Try to get information on the disk file
;			If no errors getting information
;				Try to open the disk file
;				If no errors opening the disk file
;					If a system type file (13 Sector)
;						Set the old style flag bit
;						Update track limit (13 Sector)
;						Update track size (13 Sector)
;						Update sector limit (13)
;					Endif for system type file
;				Else error opening the disk file
;					Zero the file handle (No disk file)
;					Clear disk present flag bit
;				Endif for opening disk file
;			Else error getting information
;				Zero the disk file handle
;				Clear disk present flag bit
;			Endif for getting information
;			Save the disk file handle
;		Else errors opening the Disk Controller ROM file
;			Set error code to no Disk Controller ROM file
;			Call the error routine
;			Call routine to exit the emulator
;		Endif
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
Disk_Init	Proc	Near		; Disk controller init. procedure
	mov	di,ax			; Get the disk controller slot number
	shl	di,1			; Convert slot number to table index
	call	Slot_Address		; Call routine to get slot address
	mov	ax,cs			; Get the current code segment value
	mov	bx,ds			; Save 65C02 RAM space segment value
	mov	ds,ax			; Setup to open the disk ROM file
	mov	ah,OPEN_FILE		; Get the open file function code
	mov	al,READ_ONLY		; Get the read file access code
	lea	dx,cs:[Disk_ROM]	; Get pointer to disk ROM file name
	int	DOS			; Try to open the disk ROM file
	jnc	Read_Disk_ROM		; Jump if no errors opening file
	mov	al,ERR_NO_DISK_FILE	; Get no disk ROM file error code
Disk_ROM_Error:
	call	Error			; Call routine to print the error
	call	Exit			; Call routine to exit emulator
Read_Disk_ROM:
	mov	ds,bx			; Restore 65C02 RAM space segment value
	mov	bx,ax			; Move file handle to BX register
	mov	ah,READ_FILE		; Get read file function code
	mov	dx,si			; Setup the data buffer address
	mov	cx,DISK_SIZE		; Get the disk ROM image size (.25k)
	int	DOS			; Try to read the disk ROM image
	mov	cx,ax			; Save ROM image size in CX register
	mov	al,ERR_BAD_DISK_FILE	; Get bad disk ROM file error code
	jc	Disk_ROM_Error		; Jump if error trying to read the file
	cmp	cx,DISK_SIZE		; Check for all of image read in
	mov	al,ERR_BAD_DISK_IMAGE	; Get bad disk ROM image error code
	jne	Disk_ROM_Error		; Jump if part of image missing
	mov	ah,CLOSE_FILE		; Get close file function code
	int	DOS			; Close the disk ROM file
	mov	ax,cs:[Nibble_Save]	; Get nibblization buffer segment
	or	ax,ax			; Check for buffer area allocated
	jnz	Disk_Allocate		; Jump if area already allocated
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,BUFFER_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate the ROM save area
	jnc	Track_Allocate		; Jump if no errors allocating space
Memory_Error:
	mov	al,ERR_NO_MEMORY	; Get not enough memory error code
	call	Error			; Call routine to print the error
	call	Exit			; Call routine to exit the emulator
Track_Allocate:
	mov	cs:[Nibble_Save],ax	; Save nibblization segment value
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,TRACK_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate the ROM save area
	jc	Memory_Error		; Jump if errors allocating space
	mov	cs:[Track_Save],ax	; Save track buffer segment value
Disk_Allocate:
	mov	ah,ALLOCATE_MEMORY	; Get the allocate memory function code
	mov	bx,CTRL_SIZE		; Get number of paragraphs to allocate
	int	DOS			; Try to allocate disk controller space
	jc	Memory_Error		; Jump if errors allocating space
	Save	ds,es			; Save the DS and ES register values
	mov	ds,ax			; Setup disk controller segment address
	mov	cs:[di + Disk_Data],ax	; Save disk controller segment address
	mov	ds:[Disk_Current],Disk_Drive_A
	mov	ax,ds			; Get the disk controller segment
	mov	es,ax			; Set ES to disk controller segment
	mov	ax,cs			; Get current CS register value
	mov	ds,ax			; Set DS to current CS register value
	mov	dx,di			; Get the disk controller slot index
	shr	dx,1			; Convert slot index to slot number
	add	dx,ASCII_CONVERT	; Convert drive/slot to ASCII
	lea	si,cs:[Base_File]	; Get pointer to base file name
	mov	di,Disk_Drive_A.Disk_File
	mov	cx,Size Disk_Name	; Get length of the base file name
	rep	movsb			; Setup base file name for drive A
	lea	si,cs:[Base_File]	; Get pointer to base file name
	mov	di,Disk_Drive_B.Disk_File
	mov	cx,Size Disk_Name	; Get length of the base file name
	rep	movsb			; Setup base file name for drive B
	mov	es:[Disk_Drive_A.Disk_File.Disk_Slot],dl
	mov	es:[Disk_Drive_A.Disk_File.Disk_Letter],dh
	inc	dh			; Increment the drive letter
	mov	es:[Disk_Drive_B.Disk_File.Disk_Slot],dl
	mov	es:[Disk_Drive_B.Disk_File.Disk_Letter],dh
	mov	ah,SET_DTA		; Get set DTA function code
	lea	dx,cs:[Find_Data]	; Get pointer to find match data area
	int	DOS			; Set DTA to the find match data area
	mov	ax,es			; Get disk controller card segment
	mov	ds,ax			; Set DS to disk controller segment
Initialize_Values:
	xor	ax,ax			; Setup AX as a zero value
	mov	ds:[Disk_Drive_A.Disk_Flag],FLAG_INIT
	mov	ds:[Disk_Drive_B.Disk_Flag],FLAG_INIT
	mov	ds:[Disk_Drive_A.Disk_Last],PHASE_INIT
	mov	ds:[Disk_Drive_B.Disk_Last],PHASE_INIT
	mov	ds:[Disk_Drive_A.Disk_Curr],PHASE_INIT
	mov	ds:[Disk_Drive_B.Disk_Curr],PHASE_INIT
	mov	ds:[Disk_Drive_A.Disk_Pointer],ax
	mov	ds:[Disk_Drive_B.Disk_Pointer],ax
	mov	ds:[Disk_Drive_A.Disk_Limit],Size Track_16
	mov	ds:[Disk_Drive_B.Disk_Limit],Size Track_16
	mov	ds:[Disk_Drive_A.Disk_Track],Size Buffer_16
	mov	ds:[Disk_Drive_B.Disk_Track],Size Buffer_16
	mov	ds:[Disk_Drive_A.Disk_Sector],COUNT_16
	mov	ds:[Disk_Drive_B.Disk_Sector],COUNT_16
	mov	ds:[Disk_Current],Disk_Drive_A
Check_File_A:
	mov	ah,FIND_FIRST		; Get find first function code
	mov	cx,SEARCH_ATTR		; Get the search attribute byte
	mov	dx,Disk_Drive_A.Disk_File
	int	DOS			; Get information on drive A file
	jc	Error_File_A		; Jump if error on information call
Open_Drive_A:
	mov	ah,OPEN_FILE		; Get the open file function code
	mov	al,READ_WRITE		; Get read/write file access code
	mov	dx,Disk_Drive_A.Disk_File
	test	Byte Ptr cs:[Find_Data.File_Attr],READ
	jz	Open_File_A		; Jump if file is not write only
	mov	al,READ_ONLY		; Get read only file access code
Open_File_A:
	int	DOS			; Try to open disk drive A file
	jnc	Set_A_Handle		; Jump if no errors opening the file
Error_File_A:
	xor	ax,ax			; Zero the handle number (No disk)
	and	ds:[Disk_Drive_A.Disk_Flag],Not DISK_PRESENT
Set_A_Handle:
	mov	ds:[Disk_Drive_A.Disk_Handle],ax
	or	ax,ax			; Check for error opening the file
	jz	Check_File_B		; Jump if error opening the file
Check_Type_A:
	test	Byte Ptr cs:[Find_Data.File_Attr],SYSTEM
	jz	Check_Protect_A 	; Jump if NOT an old style disk file
	or	ds:[Disk_Drive_A.Disk_Flag],OLD_STYLE
	mov	ds:[Disk_Drive_A.Disk_Limit],Size Track_13
	mov	ds:[Disk_Drive_A.Disk_Track],Size Buffer_13
	mov	ds:[Disk_Drive_A.Disk_Sector],COUNT_13
Check_Protect_A:
	test	Byte Ptr cs:[Find_Data.File_Attr],READ
	jz	Check_File_B		; Jump if NOT a read only disk file
	or	ds:[Disk_Drive_A.Disk_Flag],WRITE_PROTECT
Check_File_B:
	mov	ah,FIND_FIRST		; Get find first function code
	mov	cx,SEARCH_ATTR		; Get the search attribute byte
	mov	dx,Disk_Drive_B.Disk_File
	int	DOS			; Get information on drive B file
	jc	Error_File_B		; Jump if error on information call
Open_Drive_B:
	mov	ah,OPEN_FILE		; Get the open file function code
	mov	al,READ_WRITE		; Get read/write file access code
	mov	dx,Disk_Drive_B.Disk_File
	test	Byte Ptr cs:[Find_Data.File_Attr],READ
	jz	Open_File_B		; Jump if file is not write only
	mov	al,READ_ONLY		; Get read only file access code
Open_File_B:
	int	DOS			; Try to open disk drive B file
	jnc	Set_B_Handle		; Jump if no errors opening the file
Error_File_B:
	xor	ax,ax			; Zero the handle number (No disk)
	and	ds:[Disk_Drive_B.Disk_Flag],Not DISK_PRESENT
Set_B_Handle:
	mov	ds:[Disk_Drive_B.Disk_Handle],ax
	or	ax,ax			; Check for error opening the file
	jz	Disk_Exit		; Jump if error opening the file
Check_Type_B:
	test	Byte Ptr cs:[Find_Data.File_Attr],SYSTEM
	jz	Check_Protect_B 	; Jump if NOT an old style disk file
	or	ds:[Disk_Drive_B.Disk_Flag],OLD_STYLE
	mov	ds:[Disk_Drive_B.Disk_Limit],Size Track_13
	mov	ds:[Disk_Drive_B.Disk_Track],Size Buffer_13
	mov	ds:[Disk_Drive_B.Disk_Sector],COUNT_13
Check_Protect_B:
	test	Byte Ptr cs:[Find_Data.File_Attr],READ
	jz	Disk_Exit		; Jump if NOT a read only disk file
	or	ds:[Disk_Drive_B.Disk_Flag],WRITE_PROTECT
Disk_Exit:
	Restore ds,es			; Restore the DS and ES register values
	ret				; Return to the caller
Disk_Init	Endp			; End of the Disk_Init procedure
	Subttl	Disk_Ctrl	Disk Controller Control
	Page	+
;******************************************************************************
;
;	Disk_Ctrl(RAM_Space, Slot_Number)
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
;		AX-DX - Destroyed
;		SI-DI - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Disk_Ctrl	Proc	Near		; Disk controller control procedure

	ret				; Return to the caller
Disk_Ctrl	Endp			; End of the Disk_Ctrl procedure
	Subttl	Disk_Rd 	Disk Controller Read
	Page	+
;******************************************************************************
;
;	Disk_Rd(Effective_Address, Slot_Index)
;
;		Save the required registers
;		Setup the disk controller data segment
;		Get the disk controller control bits (From effective address)
;		Call the correct routine to handle the update
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
;		AL    - Disk value
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Disk_Rd 	Proc	Near		; Disk controller read procedure
	Save	bx,es			; Save the required registers
	mov	es,cs:[bp + Disk_Data]	; Setup disk controller data segment
	mov	bx,di			; Get the effective address
	and	bx,CONTROL_MASK 	; Mask off all but the control bits
	shl	bx,1			; Convert control bits to table index
	call	cs:[bx + Disk_Table]	; Call correct routine to handle update
Disk_Rd_Exit:
	Restore bx,es			; Restore the required registers
	ret				; Return to the caller
Disk_Rd 	Endp			; End of the Disk_Rd procedure
	Subttl	Disk_Wrt	Disk Controller Write
	Page	+
;******************************************************************************
;
;	Disk_Wrt(Effective_Address, Slot_Index, Memory_Value)
;
;		Save the required registers
;		Setup the disk controller data segment
;		Get the disk controller control bits (From effective address)
;		Call the correct routine to handle the update
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
Disk_Wrt	Proc	Near		; Disk controller write procedure
	Save	ax,bx,es		; Save the required registers
	mov	es,cs:[bp + Disk_Data]	; Setup disk controller data segment
	mov	bx,di			; Get the effective address
	and	bx,CONTROL_MASK 	; Mask off all but the control bits
	shl	bx,1			; Convert control bits to table index
	call	cs:[bx + Disk_Table]	; Call correct routine to handle update
Disk_Wrt_Exit:
	Restore ax,bx,es		; Restore the required registers
	ret				; Return to the caller
Disk_Wrt	Endp			; End of the Disk_Wrt procedure
	Subttl	Disk_Mem_Rd	Disk Controller Memory Read
	Page	+
;******************************************************************************
;
;	Disk_Mem_Rd(Effective_Address)
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
Disk_Mem_Rd	Proc	Near		; Disk controller memory read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Disk_Mem_Rd	Endp			; End of the Disk_Mem_Rd procedure
	Subttl	Disk_Mem_Wrt	Disk Controller Memory Write
	Page	+
;******************************************************************************
;
;	Disk_Mem_Wrt(Effective_Address)
;
;		Return to the caller (ROM is NOT writable)
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
Disk_Mem_Wrt	Proc	Near		; Disk controller memory write procedure
	ret				; Return to the caller
Disk_Mem_Wrt	Endp			; End of the Disk_Mem_Wrt procedure
	Subttl	Disk_Exp_Rd	Disk Controller Expansion Read
	Page	+
;******************************************************************************
;
;	Disk_Exp_Rd(Effective_Address)
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
Disk_Exp_Rd	Proc	Near		; Disk ctrl. expansion read procedure
	mov	al,ds:[di]		; Read the memory location
	ret				; Return to the caller
Disk_Exp_Rd	Endp			; End of the Disk_Exp_Rd procedure
	Subttl	Disk_Exp_Wrt	Disk Controller Expansion Write
	Page	+
;******************************************************************************
;
;	Disk_Exp_Wrt(Effective_Address)
;
;		Return to the caller (Area is NOT writable)
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
Disk_Exp_Wrt	Proc	Near		; Disk ctrl. expansion write procedure
	ret				; Return to the caller
Disk_Exp_Wrt	Endp			; End of the Disk_Exp_Wrt procedure
	Subttl	No_Operation	Disk Controller No Operation Routine
	Page	+
;******************************************************************************
;
;	No_Operation(RAM_Space, Disk_Segment)
;
;		Get currently selected disk drive (A or B)
;		Return to the caller (With current phase value)
;
;	Registers on Entry:
;
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current disk phase
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
No_Operation	Proc	Near		; No operation procedure
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	al,es:[bx.Disk_Curr]	; Get the current disk phase value
	ret				; Return to the caller
No_Operation	Endp			; End of the No_Operation procedure
	Subttl	Disk_Phase	Disk Controller Phase Routine
	Page	+
;******************************************************************************
;
;	Disk_Phase(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Get the new phase value (Control_Index / 2)
;		Get currently selected disk drive (A or B)
;		Compute change between last and current phase
;		Update the last phase value
;		If phase change made (Change <> 0)
;			If the track buffer is valid
;				If this track has been modified
;					Call routine to write this track
;				Endif for track modified
;			Endif for track buffer valid
;			If change is positive (Step up)
;				Setup for phase increment
;			Else change is negative (Step down)
;				Setup for phase decrement
;			Endif for phase setup
;			Update the current phase value
;			If track value has changed
;				Reset track buffer valid flag
;			Endif for track value
;		Endif for phase change
;		Return to the caller (With current phase value)
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current disk phase
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Disk_Phase	Proc	Near		; Disk phase procedure
	mov	ax,bx			; Get the control index value
	shr	ax,1			; Get the new phase value
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	ah,al			; Move copy of new phase to AH
	sub	ah,es:[bx.Disk_Last]	; Compute the phase change value
	mov	es:[bx.Disk_Last],al	; Update the last phase value
	mov	al,PHASE_INCREMENT	; Default to a phase increment
	jz	Phase_Exit		; Jump if no phase change
	jnc	Wrap_Check		; Jump if positive phase change
	mov	al,PHASE_DECREMENT	; Setup for a phase decrement
	not	ah			; Compute the
	inc	ah			;	      positive phase change
Wrap_Check:
	cmp	ah,PHASE_WRAP		; Check for a phase wrap-around
	jc	Track_Check		; Jump if phase did NOT wrap around
	not	al			; Toggle the phase
	inc	al			;		   increment value
Track_Check:
	test	es:[bx.Disk_Flag],BUFFER_VALID
	jz	Phase_Update		; Jump if buffer is invalid
	test	es:[bx.Disk_Flag],TRACK_MODIFIED
	jz	Phase_Update		; Jump if track was NOT modified
	call	Write_Track		; Call routine to write this track
Phase_Update:
	add	al,es:[bx.Disk_Curr]	; Compute the new disk phase value
	cmp	al,PHASE_MAX		; Check against phase maximum
	jnc	Phase_Exit		; Jump if new phase value is illegal
	mov	ah,es:[bx.Disk_Curr]	; Get the current disk phase value
	mov	es:[bx.Disk_Curr],al	; Update the disk phase value
	and	ah,TRACK_MASK		; Compute the current track phase value
	cmp	ah,al			; Check against current phase value
	je	Phase_Exit		; Jump if still on the same track
	and	es:[bx.Disk_Flag],Not BUFFER_VALID
Phase_Exit:
	mov	al,es:[bx.Disk_Curr]	; Get the current disk phase value
	ret				; Return to the caller
Disk_Phase	Endp			; End of the Disk_Phase procedure
	Subttl	Disk_Off	Disk Controller Motor Off Routine
	Page	+
;******************************************************************************
;
;	Disk_Off(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Set drive motor A status to off
;		If the track buffer is valid
;			If this track has been modified
;				Call routine to write this track
;			Endif for track modified
;		Endif for track buffer valid
;		Set drive motor B status to off
;		If the track buffer is valid
;			If this track has been modified
;				Call routine to write this track
;			Endif for track modified
;		Endif for track buffer valid
;		Return to the caller (With currently selected drive)
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current drive selected
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Disk_Off	Proc	Near		; Disk motor off procedure
	mov	bx,Disk_Drive_A 	; Get drive A structure pointer
	and	es:[bx.Disk_Flag],Not MOTOR_ON
	test	es:[bx.Disk_Flag],BUFFER_VALID
	jz	B_Off			; Jump if track buffer is invalid
	test	es:[bx.Disk_Flag],TRACK_MODIFIED
	jz	B_Off			; Jump if track has NOT been modified
	call	Write_Track		; Call routine to write this track
B_Off:
	mov	bx,Disk_Drive_B 	; Get drive B structure pointer
	and	es:[bx.Disk_Flag],Not MOTOR_ON
	test	es:[bx.Disk_Flag],BUFFER_VALID
	jz	Off_Done		; Jump if track buffer is invalid
	test	es:[bx.Disk_Flag],TRACK_MODIFIED
	jz	Off_Done		; Jump if track has NOT been modified
	call	Write_Track		; Call routine to write this track
Off_Done:
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	al,DRIVE_A		; Default to drive A selected
	cmp	bx,Disk_Drive_A 	; Check for disk drive B selected
	je	Off_Exit		; Jump if drive B is NOT selected
	mov	al,DRIVE_B		; Indicate drive B selected
Off_Exit:
	ret				; Return to the caller
Disk_Off	Endp			; End of the Disk_Off procedure
	Subttl	Disk_On 	Disk Controller Motor On Routine
	Page	+
;******************************************************************************
;
;	Disk_On(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Set drive motor A status to on
;		Set drive motor B status to on
;		Return to the caller (With currently selected drive)
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current drive selected
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Disk_On 	Proc	Near		; Disk motor on procedure
	mov	bx,Disk_Drive_A 	; Get drive A structure pointer
	or	es:[bx.Disk_Flag],MOTOR_ON
	mov	bx,Disk_Drive_B 	; Get drive B structure pointer
	or	es:[bx.Disk_Flag],MOTOR_ON
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	al,DRIVE_A		; Default to drive A selected
	cmp	bx,Disk_Drive_A 	; Check for disk drive B selected
	je	On_Exit 		; Jump if drive B is NOT selected
	mov	al,DRIVE_B		; Indicate drive B selected
On_Exit:
	ret				; Return to the caller
Disk_On 	Endp			; End of the Disk_On procedure
	Subttl	Select_A	Disk Controller Select Drive A Routine
	Page	+
;******************************************************************************
;
;	Select_A(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Set current drive to drive A
;		Return to the caller (With currently selected drive) [A]
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current drive selected (A)
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Select_A	Proc	Near		; Select drive A procedure
	mov	es:[Disk_Current],Disk_Drive_A
	mov	al,DRIVE_A		; Indicate drive A selected
	ret				; Return to the caller
Select_A	Endp			; End of the Select_A procedure
	Subttl	Select_B	Disk Controller Select Drive B Routine
	Page	+
;******************************************************************************
;
;	Select_B(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Set current drive to drive B
;		Return to the caller (With currently selected drive) [B]
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current drive selected (B)
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Select_B	Proc	Near		; Select drive B procedure
	mov	es:[Disk_Current],Disk_Drive_B
	mov	al,DRIVE_B		; Indicate drive B selected
	ret				; Return to the caller
Select_B	Endp			; End of the Select_B procedure
	Subttl	Data_Strobe	Disk Controller Data Strobe Routine
	Page	+
;******************************************************************************
;
;	Data_Strobe(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Get currently selected disk drive (A or B)
;		If in output mode
;			If disk is present
;				Call routine to write a byte
;				Set the buffer valid flag bit
;				Set the track modified flag bit
;			Endif for disk present
;		Else in input mode
;			If disk is present
;				If track buffer is invalid
;					Call routine to read the track
;				Endif for track buffer invalid
;				Call routine to read a byte
;			Endif for disk present
;		Endif for controller mode
;		Return to the caller
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Data value (If read)
;		AH    - Destroyed
;		BX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Data_Strobe	Proc	Near		; Disk data strobe procedure
	not	al			; Fake the disk ready (Data changing)
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	ah,es:[bx.Disk_Flag]	; Get the disk drive flag byte
	test	ah,OUTPUT_MODE		; Check for controller in output mode
	jz	Read_Mode		; Jump if controller in input mode
Write_Mode:
	test	ah,DISK_PRESENT 	; Check for a disk present
	jz	Strobe_Exit		; Jump if no disk is installed
	call	Write_Byte		; Call routine to write a byte
	or	es:[bx.Disk_Flag],TRACK_MODIFIED + BUFFER_VALID
	jmp	Short Strobe_Exit	; Go return to the caller
Read_Mode:
	test	ah,DISK_PRESENT 	; Check for a disk present
	jz	Strobe_Exit		; Jump if no disk is installed
	test	ah,BUFFER_VALID 	; Check for track buffer valid
	jnz	Data_Read		; Jump if buffer is valid
	call	Read_Track		; Call routine to read a track
Data_Read:
	call	Read_Byte		; Call routine to read a byte
Strobe_Exit:
	ret				; Return to the caller
Data_Strobe	Endp			; End of the Data_Strobe procedure
	Subttl	Load_Latch	Disk Controller Load Latch Routine
	Page	+
;******************************************************************************
;
;	Load_Latch(RAM_Space, Disk_Segment, Control_Index, Slot_Index, Data)
;
;		Get currently selected disk drive (A or B)
;		Save data value to the disk latch
;		Return to the caller (With currently selected drive)
;
;	Registers on Entry:
;
;		AL    - Data value
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current drive selected
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Load_Latch	Proc	Near		; Load data latch procedure
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	es:[bx.Disk_Latch],al	; Save the disk data latch value
	mov	al,DRIVE_A		; Default to drive A selected
	cmp	bx,Disk_Drive_A 	; Check for disk drive B selected
	je	Latch_Exit		; Jump if drive B is NOT selected
	mov	al,DRIVE_B		; Indicate drive B selected
Latch_Exit:
	ret				; Return to the caller
Load_Latch	Endp			; End of the Load_Latch procedure
	Subttl	Prepare_Input	Disk Controller Prepare Input Routine
	Page	+
;******************************************************************************
;
;	Prepare_Input(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Set drive A controller mode to input
;		Set drive B controller mode to input
;		Get currently selected disk drive (A or B)
;		Get disk drive write protect status
;		Return to the caller (With write protect status)
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Write protect status
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Prepare_Input	Proc	Near		; Prepare disk input procedure
	and	es:[Disk_Drive_A.Disk_Flag],Not OUTPUT_MODE
	and	es:[Disk_Drive_A.Disk_Flag],Not OUTPUT_MODE
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	xor	al,al			; Default to drive NOT write protected
	test	es:[bx.Disk_Flag],WRITE_PROTECT
	jz	Input_Exit		; Jump if disk is NOT write protected
	or	al,DISK_PROTECT 	; Set the disk write protected flag
Input_Exit:
	ret				; Return to the caller
Prepare_Input	Endp			; End of the Prepare_Input procedure
	Subttl	Prepare_Output	Disk Controller Prepare Output Routine
	Page	+
;******************************************************************************
;
;	Prepare_Output(RAM_Space, Disk_Segment, Control_Index, Slot_Index)
;
;		Set drive A controller mode to output
;		Set drive B controller mode to output
;		Get currently selected disk drive (A or B)
;		Return to the caller (With currently selected drive)
;
;	Registers on Entry:
;
;		BX    - Control bits index (Control bits * 2)
;		BP    - Slot index (Slot number * 2)
;		DS    - 65C02 RAM space
;		ES    - Disk controller segment
;
;	Registers on Exit:
;
;		AL    - Current drive selected
;		AH    - Destroyed
;		BX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Prepare_Output	Proc	Near		; Prepare disk output procedure
	or	es:[Disk_Drive_A.Disk_Flag],OUTPUT_MODE
	or	es:[Disk_Drive_A.Disk_Flag],OUTPUT_MODE
	mov	bx,es:[Disk_Current]	; Get the currently selected drive
	mov	al,DRIVE_A		; Default to drive A selected
	cmp	bx,Disk_Drive_A 	; Check for disk drive B selected
	je	Output_Exit		; Jump if drive B is NOT selected
	mov	al,DRIVE_B		; Indicate drive B selected
Output_Exit:
	ret				; Return to the caller
Prepare_Output	Endp			; End of the Prepare_Output procedure
	Subttl	Read_Track	Disk Controller Read Track Routine
	Page	+
;******************************************************************************
;
;	Read_Track(Drive_Structure)
;
;		Save the required registers
;		Get the disk file handle
;		Get the current phase value
;		Compute the current track (Phase / 2)
;		Try to seek to the correct position
;		If no errors seeking to the correct position
;			Get the track buffer segment
;			Get the track buffer size (13/16 Sector disk)
;			Try to read the requested track
;			If no errors reading the requested track
;				Call routine to encrypt the track
;			Endif for reading the track
;		Endif for seeking to track
;		Set the track buffer valid flag
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		ES:BX - Disk drive structure pointer
;
;	Registers on Exit:
;
;		AX    - Destroyed
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Read_Track	Proc	Near		; Disk read track procedure
	Save	cx,dx,ds		; Save the required registers
	mov	bp,es:[bx.Disk_Handle]	; Get the disk file handle
	xchg	bx,bp			; Move file handle to BX register
	mov	al,es:[bp.Disk_Curr]	; Get the current disk phase value
	shr	al,1			; Convert phase to track value (/ 2)
	xor	ah,ah			; Convert track value to full word
	mul	es:[bp.Disk_Track]	; Compute the track offset value (DX:AX)
	mov	cx,dx			; Move track offset
	mov	dx,ax			;		    to CX:DX reg. pair
	mov	ah,SEEK_FILE		; Get the seek file function code
	mov	al,ABSOLUTE		; Get the absolute seek type code
	int	DOS			; Seek to correct position
	jc	Read_Exit		; Jump if error during seek operation
	mov	ds,cs:[Track_Save]	; Get the track buffer segment
	xor	dx,dx			; Zero the offset value
	mov	cx,es:[bp.Disk_Track]	; Get the track buffer size (Bytes)
	mov	ah,READ_FILE		; Get read file function code
	int	DOS			; Try to read the desired track
	jc	Read_Exit		; Jump if errors reading track
	call	Encrypt_Track		; Call routine to encrypt the track
Read_Exit:
	xchg	bx,bp			; Restore the drive structure pointer
	or	es:[bx.Disk_Flag],BUFFER_VALID
	Restore cx,dx,ds		; Restore the required registers
	ret				; Return to the caller
Read_Track	Endp			; End of the Read_Track procedure
	Subttl	Write_Track	Disk Controller Write Track Routine
	Page	+
;******************************************************************************
;
;	Write_Track(Drive_Structure)
;
;		Save the required registers
;		Get pointer to track buffer area
;		Call routine to decrypt the track
;		Get the disk file handle
;		Get the current phase value
;		Compute the current track (Phase / 2)
;		Try to seek to the correct position
;		If no errors seeking to the correct position
;			Get the track buffer size (13/16 Sector disk)
;			Try to write the requested track
;		Endif for seeking to track
;		Restore the required registers
;		Clear the track modified flag
;		Return to the caller
;
;	Registers on Entry:
;
;		ES:BX - Disk drive structure pointer
;
;	Registers on Exit:
;
;		BP    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Write_Track	Proc	Near		; Disk write track procedure
	Save	ax,cx,dx,ds		; Save the required registers
	mov	ds,cs:[Track_Save]	; Get the track buffer segment
	xor	dx,dx			; Zero the offset value
	mov	bp,es:[bx.Disk_Handle]	; Get the disk file handle
	xchg	bx,bp			; Move file handle to BX register
	call	Decrypt_Track		; Call routine to decrypt the track
	mov	al,es:[bp.Disk_Curr]	; Get the current disk phase value
	shr	al,1			; Convert phase to track value (/ 2)
	xor	ah,ah			; Convert track value to full word
	mul	es:[bp.Disk_Track]	; Compute the track offset value (DX:AX)
	mov	cx,dx			; Move track offset
	mov	dx,ax			;		    to CX:DX reg. pair
	mov	ah,SEEK_FILE		; Get the seek file function code
	mov	al,ABSOLUTE		; Get the absolute seek type code
	int	DOS			; Seek to correct position
	jc	Write_Exit		; Jump if error during seek operation
	mov	cx,es:[bp.Disk_Track]	; Get the track buffer size (Bytes)
	xor	dx,dx			; Zero the track buffer offset value
	mov	ah,WRITE_FILE		; Get write file function code
	int	DOS			; Try to write the desired track
Write_Exit:
	xchg	bx,bp			; Restore the drive structure pointer
	and	es:[bx.Disk_Flag],Not TRACK_MODIFIED
	Restore ax,cx,dx,ds		; Restore the required registers
	ret				; Return to the caller
Write_Track	Endp			; End of the Write_Track procedure
	Subttl	Encrypt_Track	Disk Controller Encrypt Track Routine
	Page	+
;******************************************************************************
;
;	Encrypt_Track(Track_Buffer, Drive_Structure)
;
;		Save the required registers
;		Get pointer to track data area
;		Fill in the gap 1 area
;		Get the track number
;		Get pointer to sector skew table
;		Initialize the sector count (13/16)
;		While sector count > 0
;			Get the correct sector number
;			Get pointer to sector data
;			Call routine to encrypt the sector
;			Decrement the sector count
;		Endwhile for sector count
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DX - Pointer to track buffer area
;		ES:BP - Disk drive structure pointer
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Encrypt_Track	Proc	Near		; Encrypt track procedure
	Save	bx,cx,si,di		; Save the required registers
	lea	di,es:[bp.Disk_Buffer]	; Get pointer to disk track buffer
	Fill	GAP_1, SELF_SYNC	; Fill in gap 1 area with self sync's
	mov	ah,es:[bp.Disk_Curr]	; Get the current disk phase
	shr	ah,1			; Convert current phase to track number
	lea	bx,cs:[Skew_Table]	; Get pointer to sector skew table
	mov	cl,es:[bp.Disk_Sector]	; Get the number of sectors per. track
	mov	ch,cl			; Move copy of sectors/track to CH
Encrypt_Loop:
	mov	al,ch			; Get the number of sectors/track
	sub	al,cl			; Compute the current sector number
	xlat	cs:[bx] 		; Get the actual sector number
	xchg	al,ah			; Move sector number into AH register
	mov	si,ax			; Move sector pointer into SI
	and	si,SECTOR_MASK		; Mask off all but the sector pointer
	xchg	al,ah			; Restore the track/sector order
	mov	al,ch			; Get the number of sectors/track
	sub	al,cl			; Compute the current sector number
	call	Encrypt_Sector		; Call routine to encrypt this sector
	dec	cl			; Decrement the sector counter
	jnz	Encrypt_Loop		; Jump if more sectors to encrypt
Encrypt_Exit:
	Restore bx,cx,si,di		; Restore the required registers
	ret				; Return to the caller
Encrypt_Track	Endp			; End of the Encrypt_Track procedure
	Subttl	Decrypt_Track	Disk Controller Decrypt Track Routine
	Page	+
;******************************************************************************
;
;	Decrypt_Track(Track_Buffer, Drive_Structure)
;
;		Save the required registers
;		Get pointer to track data area
;		While pointer < track_limit
;			Search for a address mark
;			If address mark found
;				Search for a data mark
;				If data mark found
;					Compute address of sector (Skew table)
;					Call routine to decrypt sector
;				Endif for data mark
;			Endif for address mark
;			Increment the pointer
;		Endwhile
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:DX - Pointer to track buffer area
;		ES:BP - Disk drive structure pointer
;
;	Registers on Exit:
;
;		AX    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Decrypt_Track	Proc	Near		; Decrypt track procedure
	Save	bx,cx,si,di		; Save the required registers
	lea	bx,es:[bp.Disk_Buffer]	; Get pointer to disk buffer
	xor	di,di			; Zero the buffer offset (Start)
Address_Loop:
	cmp	Byte Ptr es:[bx+di],PRO_ADDR_1
	jne	Address_Byte		; Jump if NOT address prologue byte 1
	inc	di			; Increment the buffer pointer
	cmp	Byte Ptr es:[bx+di],PRO_ADDR_2
	jne	Next_Address		; Jump if NOT address prologue byte 2
	inc	di			; Increment the buffer pointer
	cmp	Byte Ptr es:[bx+di],PRO_ADDR_3
	jne	Next_Address		; Jump if NOT address prologue byte 3
	inc	di			; Increment the buffer pointer
	add	di,Track - Volume	; Increment past disk volume to track
	mov	ax,es:[bx+di]		; Get the encrypted track number
	Decrypt_Byte			; Decrypt the track value
	mov	ch,al			; Save track number in CH register
	inc	di			; Increment past
	inc	di			;		 encrypted track number
	mov	ax,es:[bx+di]		; Get the encrypted sector number
	Decrypt_Byte			; Decrypt the sector number
	mov	cl,al			; Save sector number in CL register
	inc	di			; Increment past
	inc	di			;		 encrypted sector number
	jmp	Short Data_Loop 	; Go search for matching data mark
Address_Byte:
	inc	di			; Increment the buffer pointer
Next_Address:
	cmp	di,es:[bp.Disk_Limit]	; Check pointer against track limit
	jb	Address_Loop		; Jump if more data in the buffer
	jmp	Short Decrypt_Exit	; Go return to the caller
Data_Loop:
	cmp	Byte Ptr es:[bx+di],PRO_DATA_1
	jne	Data_Byte		; Jump if NOT data prologue byte 1
	inc	di			; Increment the buffer pointer
	cmp	Byte Ptr es:[bx+di],PRO_DATA_2
	jne	Next_Data		; Jump if NOT data prologue byte 2
	inc	di			; Increment the buffer pointer
	cmp	Byte Ptr es:[bx+di],PRO_DATA_3
	jne	Next_Data		; Jump if NOT data prologue byte 3
	inc	di			; Increment the buffer pointer
	mov	al,cl			; Get the sector number in AL
	xor	ah,ah			; Convert sector number to full word
	xchg	ax,bx			; Put sector number into BX
	mov	bl,cs:[bx + Skew_Table] ; Get the actual sector number
	xchg	ax,bx			; Put actual sector number into AX
	xchg	al,ah			; Compute actual sector address (* 256)
	mov	si,ax			; Move sector address to SI register
	call	Decrypt_Sector		; Call routine to decrypt the sector
	jmp	Short Next_Address	; Go search for next address mark
Data_Byte:
	inc	di			; Increment the buffer pointer
Next_Data:
	cmp	di,es:[bp.Disk_Limit]	; Check pointer against track limit
	jb	Data_Loop		; Jump if more data in the buffer
Decrypt_Exit:
	Restore bx,cx,si,di		; Restore the required registers
	ret				; Return to the caller
Decrypt_Track	Endp			; End of the Decrypt_Track procedure
	Subttl	Encrypt_Sector	Disk Controller Encrypt Sector Routine
	Page	+
;******************************************************************************
;
;	Encrypt_Sector(Track, Sector, Sector_Area, Drive_Structure, Buffer_Area)
;
;		Save the required registers
;		Store address mark prologue in buffer
;		Encrypt disk volume and store in buffer
;		Encrypt track number and store in buffer
;		Encrypt sector number and store in buffer
;		Compute address mark checksum (Volume, Track, and Sector)
;		Encrypt checksum and store in buffer
;		Store address mark epilogue in buffer
;		Fill in the gap 2 area
;		Store data mark prologue in buffer
;		Call routine to pre-nibblize the sector data
;		Setup encryption table based on disk type
;		Set byte count to sector size
;		While byte count > 0
;			Encrypt data byte from pre-nibble buffer
;			Store encrypted byte in buffer
;			Decrement the byte counter
;		Endwhile
;		Encrypt checksum and store in buffer
;		Store data mark epilogue in buffer
;		Fill in the gap 3 area
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		AH    - Track number
;		AL    - Sector number
;		DS:SI - Pointer to sector area
;		ES:DI - Pointer to buffer area
;		ES:BP - Disk drive structure pointer
;
;	Registers on Exit:
;
;		SI    - Destroyed
;		DI    - Updated to point to next sector
;
;******************************************************************************
		Even			; Force procedure to even address
Encrypt_Sector	Proc	Near		; Encrypt sector procedure
	Save	ax,bx,cx,ds		; Save the required registers
	mov	bx,ax			; Save track/sector number in BX
	mov	al,PRO_ADDR_1		; Get address mark prologue byte 1
	stosb				; Store progogue byte in buffer
	mov	al,PRO_ADDR_2		; Get address mark prologue byte 2
	stosb				; Store prologue byte in buffer
	mov	al,PRO_ADDR_3		; Get address mark prologue byte 3
	stosb				; Store prologue byte in buffer
	mov	al,DISK_VOLUME		; Get the dummy disk volume number
	Encrypt_Byte			; Encrypt the disk volume number
	stosw				; Store the disk volume number
	mov	al,bh			; Get the disk track number
	Encrypt_Byte			; Encrypt the disk track number
	stosw				; Store the disk track number
	mov	al,bl			; Get the disk sector number
	Encrypt_Byte			; Encrypt the disk sector number
	stosw				; Store the disk sector number
	mov	al,DISK_VOLUME		; Get disk volume to compute checksum
	xor	al,bh			; Add track number to checksum
	xor	al,bl			; Add sector number to checksum
	Encrypt_Byte			; Encrypt the checksum value
	stosw				; Store the checksum value
	mov	al,EPI_ADDR_1		; Get address mark epilogue byte 1
	stosb				; Store epilogue byte in buffer
	mov	al,EPI_ADDR_2		; Get address mark epilogue byte 2
	stosb				; Store epilogue byte in buffer
	mov	al,EPI_ADDR_3		; Get address mark epilogue byte 3
	stosb				; Store epilogue byte in buffer
	Fill	GAP_2, SELF_SYNC	; Fill in gap 2 area with self sync's
	mov	al,PRO_DATA_1		; Get data mark prologue byte 1
	stosb				; Store progogue byte in buffer
	mov	al,PRO_DATA_2		; Get data mark prologue byte 2
	stosb				; Store prologue byte in buffer
	mov	al,PRO_DATA_3		; Get data mark prologue byte 3
	stosb				; Store prologue byte in buffer
	call	Pre_Nibble		; Call routine to pre-nibblize sector
	mov	ds,cs:[Nibble_Save]	; Get nibblization buffer segment
	lea	bx,cs:[Nibble_6_2]	; Get 6 to 2 nibble encoding table
	mov	si,BREAK_6_2 - 1	; Get 6 to 2 break point value - 1
	test	es:[bp.Disk_Flag],OLD_STYLE
	jz	Pre_Setup		; Jump if a 16 sector type disk
	lea	bx,cs:[Nibble_5_3]	; Get 5 to 3 nibble encoding table
	mov	si,BREAK_5_3 - 1	; Get 5 to 3 break point value - 1
Pre_Setup:
	xor	al,al			; Start checksum value with a zero
	mov	cx,NIBBLE_BREAK 	; Get nibble break point (Sector size)
Break_Loop:
	xor	al,ds:[si+NIBBLE_BREAK] ; Compute the next byte value
	xlat	cs:[bx] 		; Encode the byte value through table
	stosb				; Store the byte in the track buffer
	mov	al,ds:[si+NIBBLE_BREAK] ; Get next byte for encoding
	dec	si			; Decrement the index value
	jns	Break_Loop		; Jump if more nibble break to process
	inc	si			; Restore SI index to zero
Sector_Loop:
	xor	al,ds:[si]		; Compute the next byte value
	xlat	cs:[bx] 		; Encode the byte value through table
	stosb				; Store the byte in the track buffer
	mov	al,ds:[si]		; Get next byte for encoding
	inc	si			; Increment the index value
	loop	Sector_Loop		; Loop till all sector data processed
	xlat	cs:[bx] 		; Encode the checksum byte value
	stosb				; Store checksum byte value in buffer
	mov	al,EPI_DATA_1		; Get data mark epilogue byte 1
	stosb				; Store epilogue byte in buffer
	mov	al,EPI_DATA_2		; Get data mark epilogue byte 2
	stosb				; Store epilogue byte in buffer
	mov	al,EPI_DATA_3		; Get data mark epilogue byte 3
	stosb				; Store epilogue byte in buffer
	Fill	GAP_3, SELF_SYNC	; Fill in gap 3 area with self sync's
	Restore ax,bx,cx,ds		; Restore the required registers
	ret				; Return to the caller
Encrypt_Sector	Endp			; End of the Encrypt_Sector procedure
	Subttl	Decrypt_Sector	Disk Controller Decrypt Sector Routine
	Page	+
;******************************************************************************
;
;	Decrypt_Sector(Sector_Area, Track_Buffer, Drive_Structure)
;
;		Save the required registers
;		Setup decryption table based on disk type
;		Set byte count to sector size
;		While byte count > 0
;			Decrypt data byte from track buffer
;			Store decrypted byte in nibble buffer
;			Decrement the byte counter
;		Endwhile
;		Call routine to post-nibblize sector
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - Pointer to sector area
;		ES:BX - Pointer to buffer area
;		ES:BP - Disk drive structure pointer
;		DI    - Offset into buffer area
;
;	Registers on Exit:
;
;		SI    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Decrypt_Sector	Proc	Near		; Decrypt sector procedure
	Save	ax,bx,cx,dx,di		; Save the required registers
	add	bx,di			; Compute actual track buffer offset
	Save	si,di,ds,es		; Save the buffer pointers
	mov	si,bx			; Setup track buffer offset value
	mov	ax,es			; Get the track buffer segment
	mov	ds,ax			; Set DS to the track buffer segment
	lea	dx,cs:[Decode_6_2]	; Get 6 to 2 nibble decoding table
	mov	di,BREAK_6_2 - 1	; Get 6 to 2 break point value - 1
	test	es:[bp.Disk_Flag],OLD_STYLE
	jz	Post_Setup		; Jump if a 16 sector type disk
	lea	dx,cs:[Decode_5_3]	; Get 5 to 3 nibble decoding table
	mov	di,BREAK_5_3 - 1	; Get 5 to 3 break point value - 1
Post_Setup:
	xor	ah,ah			; Start checksum value with a zero
	mov	cx,NIBBLE_BREAK 	; Get nibble break point (Sector size)
	mov	es,cs:[Nibble_Save]	; Get nibblization buffer segment
Loop_Break:
	lodsb				; Get the next data byte to decode
	and	al,DECODE_MASK		; Mask off all but the decode bits
	xchg	bx,dx			; Get the decoding table into BX
	xlat	cs:[bx] 		; Decode the byte value through table
	xchg	bx,dx			; Restore the buffer index value
	xor	al,ah			; Compute the next data byte value
	mov	es:[di+NIBBLE_BREAK],al ; Store the byte in the nibble buffer
	mov	ah,al			; Move current byte to AH register
	dec	di			; Decrement the index value
	jns	Loop_Break		; Jump if more nibble break to process
	inc	di			; Restore DI index to zero
Loop_Sector:
	lodsb				; Get the next data byte to decode
	and	al,DECODE_MASK		; Mask off all but the decode bits
	xchg	bx,dx			; Get the decoding table into BX
	xlat	cs:[bx] 		; Decode the byte value through table
	xchg	bx,dx			; Restore the buffer index value
	xor	al,ah			; Compute the next data byte value
	mov	es:[di],al		; Store the byte in the nibble buffer
	mov	ah,al			; Move current byte to AH register
	inc	di			; Increment the index value
	loop	Loop_Sector		; Loop till all sector data processed
	Restore si,di,ds,es		; Restore the buffer pointers
	call	Post_Nibble		; Call routine to post-nibblize sector
	Restore ax,bx,cx,dx,di		; Restore the required registers
	ret				; Return to the caller
Decrypt_Sector	Endp			; End of the Decrypt_Sector procedure
	Subttl	Read_Byte	Disk Controller Read Byte Routine
	Page	+
;******************************************************************************
;
;	Read_Byte(Drive_Structure)
;
;		Save the required registers
;		Get the track buffer pointer
;		Get data byte from the buffer
;		Increment the track buffer pointer
;		If buffer pointer past limit value
;			Zero the track buffer pointer
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		ES:BX - Disk drive structure pointer
;
;	Registers on Exit:
;
;		AL    - Disk drive byte value
;
;******************************************************************************
		Even			; Force procedure to even address
Read_Byte	Proc	Near		; Disk read byte procedure
	Save	si			; Save the required registers
	mov	si,es:[bx.Disk_Pointer] ; Get the current track buffer pointer
	mov	al,es:[bx.Disk_Buffer+si]
	inc	si			; Increment track buffer pointer
	cmp	si,es:[bx.Disk_Limit]	; Check against track buffer limit
	jb	Rd_Exit 		; Jump if track pointer valid
	xor	si,si			; Zero the track pointer value
Rd_Exit:
	mov	es:[bx.Disk_Pointer],si ; Update current track buffer pointer
	Restore si			; Restore the required registers
	ret				; Return to the caller
Read_Byte	Endp			; End of the Read_Byte procedure
	Subttl	Write_Byte	Disk Controller Write Byte Routine
	Page	+
;******************************************************************************
;
;	Write_Byte(Drive_Structure)
;
;		Save the required registers
;		Get the track buffer pointer
;		Get the data byte to write (Write latch)
;		If the data byte is valid (High order bit set)
;			Write data byte to the buffer
;		Endif
;		Increment the track buffer pointer
;		If buffer pointer past limit value
;			Zero the track buffer pointer
;		Endif
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		ES:BX - Disk drive structure pointer
;
;	Registers on Exit:
;
;		None
;
;******************************************************************************
		Even			; Force procedure to even address
Write_Byte	Proc	Near		; Disk write byte procedure
	Save	si			; Save the required registers
	mov	si,es:[bx.Disk_Pointer] ; Get the current track buffer pointer
	mov	al,es:[bx.Disk_Latch]	; Get the data byte to write
	or	al,al			; Check for a valid data byte value
	jns	Skip_Write		; Jump if illegal data byte value
	mov	es:[bx.Disk_Buffer+si],al
Skip_Write:
	inc	si			; Increment track buffer pointer
	cmp	si,es:[bx.Disk_Limit]	; Check against track buffer limit
	jb	Wr_Exit 		; Jump if track pointer valid
	xor	si,si			; Zero the track pointer value
Wr_Exit:
	mov	es:[bx.Disk_Pointer],si ; Update current track buffer pointer
	Restore si			; Restore the required registers
	ret				; Return to the caller
Write_Byte	Endp			; End of the Write_Byte procedure
	Subttl	Pre_Nibble	Disk Controller Pre-Nibblization Routine
	Page	+
;******************************************************************************
;
;	Pre_Nibble(Sector_Area, Drive_Structure)
;
;		Save the required registers
;		Get pointer to nibblization buffer
;		Get nibble buffer sector break point (256 Bytes)
;		Get desired type nibble break point (Counter value)
;		Get starting buffer byte for nibblization
;		While counter value > 0
;			Get bytes from the sector buffer
;			Rotate bits into position
;			Update the nibblization buffer
;			Update nibble buffer break area
;			Update nibble and buffer pointers (Decrement counter)
;		Endwhile
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - Pointer to sector area
;		ES:BP - Disk drive structure pointer
;
;	Registers on Exit:
;
;		BX    - Destroyed
;		SI    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Pre_Nibble	Proc	Near		; Disk pre-nibblization procedure
	Save	cx,di,bp,es		; Save the required registers
	test	es:[bp.Disk_Flag],OLD_STYLE
	jz	Nibble_New		; Jump if a 16 sector type disk
Nibble_Old:
	mov	es,cs:[Nibble_Save]	; Get the nibble buffer segment
	xor	di,di			; Zero the nibble buffer offset
	mov	bp,NIBBLE_BREAK 	; Get nibble buffer sector break point
	mov	cx,BREAK_5_3		; Get 5 to 3 nibble break point
	mov	bx,START_5_3		; Get 5 to 3 starting byte
Loop_5_3:
	xor	ax,ax			; Zero the AX register value
	mov	ah,ds:[si+bx]		; Get a byte from the sector buffer
	shr	ah,1			; Rotate
	rcl	al,1			;	 bits
	shr	ah,1			;	      into
	rcl	al,1			;		   the
	shr	ah,1			;		       correct
	rcl	al,1			;			       position
	mov	es:[di+bx],ah		; Update byte in the nibble buffer
	sub	bl,BREAK_5_3		; Move to next byte in nibblization
	mov	ah,ds:[si+bx]		; Get next byte from sector buffer
	shr	ah,1			; Rotate
	rcl	al,1			;	 bits
	shr	ah,1			;	      into
	rcl	al,1			;		   the
	shr	ah,1			;		       correct
	rcl	al,1			;			       position
	mov	es:[di+bx],ah		; Update byte in the nibble buffer
	sub	bl,BREAK_5_3		; Move to next byte in nibblization
	mov	es:[di+bp],al		; Update nibble buffer break area
	add	bl,START_5_3		; Correct the sector buffer pointer
	inc	bp			; Correct nibble break pointer
	loop	Loop_5_3		; Loop till all bytes processed
	jmp	Short Pre_Exit		; Go return to the caller
Nibble_New:
	mov	es,cs:[Nibble_Save]	; Get the nibble buffer segment
	xor	di,di			; Zero the nibble buffer offset
	mov	bp,NIBBLE_BREAK 	; Get nibble buffer sector break point
	mov	cx,BREAK_6_2		; Get 6 to 2 nibble break point
	mov	bx,START_6_2		; Get 6 to 2 starting byte
Loop_6_2:
	xor	ax,ax			; Zero the AX register value
	mov	ah,ds:[si+bx]		; Get a byte from the sector buffer
	shr	ah,1			; Rotate
	rcl	al,1			;	 bits into
	shr	ah,1			;		   correct
	rcl	al,1			;			   position
	mov	es:[di+bx],ah		; Update byte in the nibble buffer
	sub	bl,BREAK_6_2		; Move to next byte in nibblization
	mov	ah,ds:[si+bx]		; Get next byte from sector buffer
	shr	ah,1			; Rotate
	rcl	al,1			;	 bits into
	shr	ah,1			;		   correct
	rcl	al,1			;			   position
	mov	es:[di+bx],ah		; Update byte in the nibble buffer
	sub	bl,BREAK_6_2		; Move to next byte in nibblization
	mov	ah,ds:[si+bx]		; Get next byte from sector buffer
	shr	ah,1			; Rotate
	rcl	al,1			;	 bits into
	shr	ah,1			;		   correct
	rcl	al,1			;			   position
	mov	es:[di+bx],ah		; Update byte in the nibble buffer
	sub	bl,BREAK_6_2		; Move to next byte in nibblization
	mov	es:[di+bp],al		; Update nibble buffer break area
	add	bl,START_6_2		; Correct the sector buffer pointer
	inc	bp			; Correct nibble break pointer
	loop	Loop_6_2		; Loop till all bytes processed
Pre_Exit:
	Restore cx,di,bp,es		; Restore the required registers
	ret				; Return to the caller
Pre_Nibble	Endp			; End of the Pre_Nibble procedure
	Subttl	Post_Nibble	Disk Controller Post-Nibblization Routine
	Page	+
;******************************************************************************
;
;	Post_Nibble(Sector_Area, Drive_Structure)
;
;		Save the required registers
;		Get pointer to nibblization buffer
;		Get nibble buffer sector break point (256 Bytes)
;		Get desired type nibble break point (Counter value)
;		Get starting buffer byte for nibblization
;		While counter value > 0
;			Get bytes from the nibble buffer
;			Rotate bits into position
;			Update the sector buffer area
;			Update nibble and buffer pointers (Decrement counter)
;		Endwhile
;		Restore the required registers
;		Return to the caller
;
;	Registers on Entry:
;
;		DS:SI - Pointer to sector area
;		ES:BP - Disk drive structure pointer
;
;	Registers on Exit:
;
;		BX    - Destroyed
;		SI    - Destroyed
;
;******************************************************************************
		Even			; Force procedure to even address
Post_Nibble	Proc	Near		; Disk post-nibblization procedure
	Save	cx,di,bp,es		; Save the required registers
	test	es:[bp.Disk_Flag],OLD_STYLE
	jz	New_Nibble		; Jump if a 16 sector type disk
Old_Nibble:
	mov	es,cs:[Nibble_Save]	; Get the nibble buffer segment
	xor	di,di			; Zero the nibble buffer offset
	mov	bp,NIBBLE_BREAK 	; Get nibble buffer sector break point
	mov	cx,BREAK_5_3		; Get 5 to 3 nibble break point
	mov	bx,BREAK_5_3 - 1	; Get 5 to 3 starting byte
Next_5_3:
	mov	al,es:[di+bp]		; Get break byte from nibble buffer
	mov	ah,es:[di+bx]		; Get a byte from the nibble buffer
	shr	al,1			; Rotate
	rcl	ah,1			;	 bits
	shr	al,1			;	      into
	rcl	ah,1			;		   the
	shr	al,1			;		       correct
	rcl	ah,1			;			       position
	mov	ds:[si+bx],ah		; Update byte in the sector buffer
	add	bl,BREAK_5_3		; Move to next byte in nibblization
	mov	ah,es:[di+bx]		; Get next byte from nibble buffer
	shr	al,1			; Rotate
	rcl	ah,1			;	 bits
	shr	al,1			;	      into
	rcl	ah,1			;		   the
	shr	al,1			;		       correct
	rcl	ah,1			;			       position
	mov	ds:[si+bx],ah		; Update byte in the sector buffer
	add	bl,BREAK_5_3		; Move to next byte in nibblization
	sub	bl,START_5_3 + 2	; Correct the sector buffer pointer
	inc	bp			; Correct nibble break pointer
	loop	Next_5_3		; Loop till all bytes processed
	jmp	Short Post_Exit 	; Go return to the caller
New_Nibble:
	mov	es,cs:[Nibble_Save]	; Get the nibble buffer segment
	xor	di,di			; Zero the nibble buffer offset
	mov	bp,NIBBLE_BREAK 	; Get nibble buffer sector break point
	mov	cx,BREAK_6_2		; Get 6 to 2 nibble break point
	mov	bx,BREAK_6_2 - 1	; Get 6 to 2 starting byte
Next_6_2:
	mov	al,es:[di+bp]		; Get break byte from nibble buffer
	mov	ah,es:[di+bx]		; Get a byte from the nibble buffer
	shr	al,1			; Rotate
	rcl	ah,1			;	 bits into
	shr	al,1			;		   correct
	rcl	ah,1			;			   position
	mov	ds:[si+bx],ah		; Update byte in the sector buffer
	add	bl,BREAK_6_2		; Move to next byte in nibblization
	mov	ah,es:[di+bx]		; Get next byte from nibble buffer
	shr	al,1			; Rotate
	rcl	ah,1			;	 bits into
	shr	al,1			;		   correct
	rcl	ah,1			;			   position
	mov	ds:[si+bx],ah		; Update byte in the sector buffer
	add	bl,BREAK_6_2		; Move to next byte in nibblization
	mov	ah,es:[di+bx]		; Get next byte from nibble buffer
	shr	al,1			; Rotate
	rcl	ah,1			;	 bits into
	shr	al,1			;		   correct
	rcl	ah,1			;			   position
	mov	ds:[si+bx],ah		; Update byte in the sector buffer
	add	bl,BREAK_6_2		; Move to next byte in nibblization
	sub	bl,START_6_2 + 2	; Correct the sector buffer pointer
	inc	bp			; Correct nibble break pointer
	loop	Next_6_2		; Loop till all bytes processed
Post_Exit:
	Restore cx,di,bp,es		; Restore the required registers
	ret				; Return to the caller
Post_Nibble	Endp			; End of the Post_Nibble procedure
	Page
;******************************************************************************
;
;	Define the disk controller data structures
;
;******************************************************************************
Disk_Data	Equ	This Word	; Define the disk data pointers
		Slot_Data	<>	; Pointers to the disk data areas
Nibble_Save	Equ	This Word	; Define nibblization save pointer
		Dw	0000h		; Pointer to nibblization segment
Track_Save	Equ	This Word	; Define track buffer save pointer
		Dw	0000h		; Pointer to track buffer segment
Base_File	Disk_Name	<>	; Define the base disk file name
Find_Data	Find_Match	<>	; Define find match data area
Disk_Table	Equ	This Word	; Define disk controller jump table
		Dw	No_Operation	; Location C0x0h routine address
		Dw	Disk_Phase	; Location C0x1h routine address
		Dw	No_Operation	; Location C0x2h routine address
		Dw	Disk_Phase	; Location C0x3h routine address
		Dw	No_Operation	; Location C0x4h routine address
		Dw	Disk_Phase	; Location C0x5h routine address
		Dw	No_Operation	; Location C0x6h routine address
		Dw	Disk_Phase	; Location C0x7h routine address
		Dw	Disk_Off	; Location C0x8h routine address
		Dw	Disk_On 	; Location C0x9h routine address
		Dw	Select_A	; Location C0xAh routine address
		Dw	Select_B	; Location C0xBh routine address
		Dw	Data_Strobe	; Location C0xCh routine address
		Dw	Load_Latch	; Location C0xDh routine address
		Dw	Prepare_Input	; Location C0xEh routine address
		Dw	Prepare_Output	; Location C0xFh routine address
Nibble_5_3	Equ	This Byte	; Define the 5 and 3 nibble table
		Db	0ABh, 0ADh, 0AEh, 0AFh, 0B5h, 0B6h, 0B7h, 0BAh
		Db	0BBh, 0BDh, 0BEh, 0BFh, 0D6h, 0D7h, 0DAh, 0DBh
		Db	0DDh, 0DEh, 0DFh, 0EAh, 0EBh, 0EDh, 0EEh, 0EFh
		Db	0F5h, 0F6h, 0F7h, 0FAh, 0FBh, 0FDh, 0FEh, 0FFh
Nibble_6_2	Equ	This Byte	; Define the 6 and 2 nibble table
		Db	096h, 097h, 09Ah, 09Bh, 09Dh, 09Eh, 09Fh, 0A6h
		Db	0A7h, 0ABh, 0ACh, 0ADh, 0AEh, 0AFh, 0B2h, 0B3h
		Db	0B4h, 0B5h, 0B6h, 0B7h, 0B9h, 0BAh, 0BBh, 0BCh
		Db	0BDh, 0BEh, 0BFh, 0CBh, 0CDh, 0CEh, 0CFh, 0D3h
		Db	0D6h, 0D7h, 0D9h, 0DAh, 0DBh, 0DCh, 0DDh, 0DEh
		Db	0DFh, 0E5h, 0E6h, 0E7h, 0E9h, 0EAh, 0EBh, 0ECh
		Db	0EDh, 0EEh, 0EFh, 0F2h, 0F3h, 0F4h, 0F5h, 0F6h
		Db	0F7h, 0F9h, 0FAh, 0FBh, 0FCh, 0FDh, 0FEh, 0FFh
Decode_5_3	Equ	This Byte	; Define the 5 and 3 decode table
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 001h, 002h, 003h
		Db	003h, 003h, 003h, 003h, 003h, 004h, 005h, 006h
		Db	006h, 006h, 007h, 008h, 008h, 009h, 00Ah, 00Bh
		Db	00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh
		Db	00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh
		Db	00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Bh, 00Ch, 00Dh
		Db	00Dh, 00Dh, 00Eh, 00Fh, 00Fh, 010h, 011h, 012h
		Db	012h, 012h, 012h, 012h, 012h, 012h, 012h, 012h
		Db	012h, 012h, 013h, 014h, 014h, 015h, 016h, 017h
		Db	017h, 017h, 017h, 017h, 017h, 018h, 019h, 01Ah
		Db	01Ah, 01Ah, 01Bh, 01Ch, 01Ch, 01Dh, 01Eh, 01Fh
Decode_6_2	Equ	This Byte	; Define the 6 and 2 decode table
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		Db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 001h
		Db	001h, 001h, 002h, 003h, 003h, 004h, 005h, 006h
		Db	006h, 006h, 006h, 006h, 006h, 006h, 007h, 008h
		Db	008h, 008h, 008h, 009h, 00Ah, 00Bh, 00Ch, 00Dh
		Db	00Dh, 00Dh, 00Eh, 00Fh, 010h, 011h, 012h, 013h
		Db	013h, 014h, 015h, 016h, 017h, 018h, 019h, 01Ah
		Db	01Ah, 01Ah, 01Ah, 01Ah, 01Ah, 01Ah, 01Ah, 01Ah
		Db	01Ah, 01Ah, 01Ah, 01Bh, 01Bh, 01Ch, 01Dh, 01Eh
		Db	01Eh, 01Eh, 01Eh, 01Fh, 01Fh, 01Fh, 020h, 021h
		Db	021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
		Db	028h, 028h, 028h, 028h, 028h, 029h, 02Ah, 02Bh
		Db	02Bh, 02Ch, 02Dh, 02Eh, 02Fh, 030h, 031h, 032h
		Db	032h, 032h, 033h, 034h, 035h, 036h, 037h, 038h
		Db	038h, 039h, 03Ah, 03Bh, 03Ch, 03Dh, 03Eh, 03Fh
Skew_Table	Equ	This Byte	; Sector skew table (Read skewing)
		Db	00h, 07h, 0Eh, 06h, 0Dh, 05h, 0Ch, 04h
		Db	0Bh, 03h, 0Ah, 02h, 09h, 01h, 08h, 0Fh
Disk_ID 	Equ	This Byte	; Disk controller ID string
		Db	"Disk Controller",0
;******************************************************************************
;
;	Define the end of the Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the Disk module

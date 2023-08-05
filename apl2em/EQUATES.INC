	.Xlist
	Page	58,132
	Subttl	EQUATES.INC	Apple Emulator (65C02 Processor)
;******************************************************************************
;
;   Name:	EQUATES 	Apple Emulator (65C02 Processor)
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
;		This module contains all the equates needed by the
;	Apple emulator. This module can be included with any needed
;	source files to define the Apple emulator equates.
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
STACK_SIZE	Equ	1000h			; Define the emulator stack size
RAM_SIZE	Equ	1000h			; Apple RAM space size (64k)
CGA_SEGMENT	Equ	0B800h			; CGA Video RAM segment value
EGA_SEGMENT	Equ	0A000h			; EGA Video RAM segment value
STACK_TOP	Equ	01FFh			; Default 65C02 stack top
FILLER		Equ	00h			; Filler byte value
SLOT_MAX	Equ	08h			; Number of expansion slots
HARDWARE_PAGE	Equ	0C0h			; Hardware page number
PAGE_SIZE	Equ	0100h			; 65C02 memory page size (Bytes)
BIOS		Equ	0040h			; ROM BIOS data segment
;******************************************************************************
;
;	Define the 65C02 Interrupt Vector Addresses
;
;******************************************************************************
IRQ_VECTOR	Equ	0FFFEh			; IRQ interrupt vector address
BRK_VECTOR	Equ	0FFFEh			; BRK interrupt vector address
RST_VECTOR	Equ	0FFFCh			; RESET interrupt vector address
NMI_VECTOR	Equ	0FFFAh			; NMI interrupt vector address
ABT_VECTOR	Equ	0FFF8h			; ABORT interrupt vector address
;******************************************************************************
;
;	Define the BIOS equates needed
;
;******************************************************************************
VIDEO		Equ	10h			; BIOS video interrupt number
SET_MODE	Equ	00h			; Video set mode function code
CURSOR_TYPE	Equ	01h			; Video set cursor type code
WRITE_CURSOR	Equ	02h			; Video set cursor position code
READ_CURSOR	Equ	03h			; Video get cursor function code
SET_PALETTE	Equ	10h			; Video set pal. function code
SET_ALL 	Equ	02h			; Program all sub-function
PROGRAM_BLINK	Equ	03h			; Program blink sub-function
INTENSITY	Equ	00h			; Blink off value (Intensity)
BLINK		Equ	01h			; Blink on value (Blink)
ALT_SELECT	Equ	12h			; Alt. select function code
EGA_INFO	Equ	10h			; Return EGA info. sub-function
KEYBOARD	Equ	16h			; BIOS keyboard int. number
CHECK_KEY	Equ	01h			; Check key status function code
SHIFT_STATUS	Equ	02h			; Get shift status function code
;******************************************************************************
;
;	Define the MS-DOS equates needed
;
;******************************************************************************
DOS		Equ	21h			; MS-DOS interrupt number
SET_DTA 	Equ	1Ah			; Set DTA function code
SET_VECTOR	Equ	25h			; Set interrupt vector code
GET_VECTOR	Equ	35h			; Get interrupt vector code
OPEN_FILE	Equ	3Dh			; Open file function code
READ_ONLY	Equ	00h			; Read only access code
WRITE_ONLY	Equ	01h			; Write only access code
READ_WRITE	Equ	02h			; Read/write access code
CLOSE_FILE	Equ	3Eh			; Close file function code
READ_FILE	Equ	3Fh			; Read file function code
WRITE_FILE	Equ	40h			; Write file function code
SEEK_FILE	Equ	42h			; Seek file function code
ABSOLUTE	Equ	00h			; Absolute file seek code
RELATIVE	Equ	01h			; Relative file seek code
ALLOCATE_MEMORY Equ	48h			; Allocate memory function code
FREE_MEMORY	Equ	49h			; Free memory function code
TERMINATE	Equ	4Ch			; Terminate function code
FIND_FIRST	Equ	4Eh			; Find first function code
FIND_NEXT	Equ	4Fh			; Find next function code
;******************************************************************************
;
;	Define the Standard MS-DOS File Handles
;
;******************************************************************************
STD_INPUT	Equ	00h			; Standard input handle
STD_OUTPUT	Equ	01h			; Standard output handle
STD_ERROR	Equ	02h			; Standard error handle
STD_AUX 	Equ	03h			; Standard auxiliary handle
STD_PRINT	Equ	04h			; Standard print handle
;******************************************************************************
;
;	Define the 65C02 CPU flag byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Carry flag (0 = No carry, 1 = Carry)
;	 | | | | | | ---------> Mode flag (0 = Binary, 1 = Decimal [BCD])
;	 | | | | | -----------> Interrupt flag (0 = Not masked, 1 = Masked)
;	 | | | | -------------> Overflow flag (0 = No overflow, 1 = Overflow)
;	 | | | ---------------> Break flag (0 = Hardware, 1 = Software)
;	 | | -----------------> Reserved flag (Used for emulator break)
;	 | -------------------> Zero flag (0 = Non-zero, 1 = Zero)
;	 ---------------------> Negative flag (0 = Positive, 1 = Negative)
;
;******************************************************************************
CPU_C		Equ	01h			; CPU carry flag
CPU_M		Equ	02h			; CPU mode flag
CPU_I		Equ	04h			; CPU interrupt disable flag
CPU_V		Equ	08h			; CPU overflow flag
CPU_B		Equ	10h			; CPU break flag
CPU_R		Equ	20h			; CPU reserved flag (Break)
CPU_Z		Equ	40h			; CPU zero flag
CPU_N		Equ	80h			; CPU negative flag
;******************************************************************************
;
;	Define the Apple system flag byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Video type (0 = CGA, 1 = EGA)
;	 | | | | | | ---------> Display type (0 = CGA, 1 = EGA)
;	 | | | | | -----------> Interrupt status (0 = Normal, 1 = Patched)
;	 | | | | -------------> Video status (0 = Normal, 1 = Initialized)
;	 | | | ---------------> Keyboard status (0 = Normal, 1 = Input)
;	 | | -----------------> ***** Reserved *****
;	 | -------------------> ***** Reserved *****
;	 ---------------------> ***** Reserved *****
;
;******************************************************************************
EGA_TYPE	Equ	01h			; EGA type system video
EGA_DISPLAY	Equ	02h			; EGA type display attached
PATCHED 	Equ	04h			; Interrupts have been patched
INITIALIZED	Equ	08h			; Video has been initialized
INPUT		Equ	10h			; Keyboard is in input mode
;******************************************************************************
;
;	Define the Video system flag byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Video Mode	(0 = Text,   1 = Graphics)
;	 | | | | | | ---------> Page Number	(0 = Page 1, 1 = Page 2)
;	 | | | | | -----------> Resolution	(0 = Low,    1 = High)
;	 | | | | -------------> Mixed Mode	(0 = Normal, 1 = Mixed)
;	 | | | ---------------> Video Mode	(1 = Text,   0 = Graphics)
;	 | | -----------------> Page Number	(1 = Page 1, 0 = Page 2)
;	 | -------------------> Resolution	(1 = Low,    0 = High)
;	 ---------------------> Mixed Mode	(1 = Normal, 0 = Mixed)
;
;******************************************************************************
VIDEO_MODE	Equ	01h		; Video mode test bit flag
PAGE_NUMBER	Equ	02h		; Page number test bit flag
RESOLUTION	Equ	04h		; Resolution test bit flag
MIXED_MODE	Equ	08h		; Mixed mode test bit flag
VIDEO_INV	Equ	10h		; Video mode inverted bit flag
PAGE_INV	Equ	20h		; Page number inverted bit flag
RES_INV 	Equ	40h		; Resolution inverted bit flag
MIXED_INV	Equ	80h		; Mixed mode inverted bit flag
;******************************************************************************
;
;	Define the Emulator system flag byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> System Request Interrupt has Occurred
;	 | | | | | | ---------> System Reset Interrupt has Occurred
;	 | | | | | -----------> ***** Reserved ***** (Dummy interrupt)
;	 | | | | -------------> ***** Reserved ***** (Dummy interrupt)
;	 | | | ---------------> ***** Reserved ***** (Dummy interrupt)
;	 | | -----------------> ***** Reserved ***** (Dummy interrupt)
;	 | -------------------> ***** Reserved ***** (Dummy interrupt)
;	 ---------------------> ***** Reserved ***** (Dummy interrupt)
;
;******************************************************************************
SYS_REQUEST	Equ	01h		; System request interrupt
SYS_RESET	Equ	02h		; System reset interrupt
INT_REQUEST	Equ	0FFh		; Any interrupt occurred test value
;******************************************************************************
;
;	Define the Language card flag byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Write enable
;	 | | | | | | ---------> ***** Reserved *****
;	 | | | | | -----------> ***** Reserved *****
;	 | | | | -------------> ***** Reserved *****
;	 | | | ---------------> ***** Reserved *****
;	 | | -----------------> ***** Reserved *****
;	 | -------------------> ***** Reserved *****
;	 ---------------------> Read enable (Language RAM)
;
;******************************************************************************
WRITE_ENABLE	Equ	01h		; Language card write enable flag
READ_ENABLE	Equ	80h		; Language card read enable flag
;******************************************************************************
;
;	Define the Disk Drive flag byte
;
;	-----------------
;	|7|6|5|4|3|2|1|0|
;	-----------------
;	 | | | | | | | |
;	 | | | | | | | -------> Disk type (0 = 16, 1 = 13)
;	 | | | | | | ---------> Write protect (0 = Writable, 1 = Write protect)
;	 | | | | | -----------> Disk present (0 = No disk, 1 = Disk present)
;	 | | | | -------------> Motor status (0 = Off, 1 = On)
;	 | | | ---------------> Controller mode (0 = Input, 1 = Output)
;	 | | -----------------> Track modified (0 = Un-modified, 1 = Modified)
;	 | -------------------> Buffer valid (0 = Invalid, 1 = Valid)
;	 ---------------------> ***** Reserved *****
;
;******************************************************************************
OLD_STYLE	Equ	01h		; Old style disk type (13 Sectors/track)
WRITE_PROTECT	Equ	02h		; Disk write protect flag
DISK_PRESENT	Equ	04h		; Disk present flag
MOTOR_ON	Equ	08h		; Disk drive motor on flag
OUTPUT_MODE	Equ	10h		; Disk controller mode flag
TRACK_MODIFIED	Equ	20h		; Disk track modified flag
BUFFER_VALID	Equ	40h		; Disk track buffer valid flag
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
SCROLL_LOCKED	Equ	20h		; Scroll locked (Special update mode)
TYPE_SPECIAL	Equ	SCROLL_LOCKED	; Special update mode in effect
NUM_LOCKED	Equ	40h		; Num locked (Joystick mode)
JOY_MODE	Equ	NUM_LOCKED	; Joystick mode in effect
CAPS_LOCKED	Equ	80h		; Caps locked (All caps)
SHIFTED 	Equ	01h		; Shift key is being held down
CTRLED		Equ	02h		; Ctrl key is being held down
ALTED		Equ	04h		; Alt key is being held down
AFFECTED	Equ	CAPS_LOCKED	; Affected by CAPS lock status
NOT_AFFECTED	Equ	00h		; Not affected by CAPS lock status
;******************************************************************************
;
;	Define the CGA color set equates
;
;	Color Number		Color Name
;	------------		----------
;
;	     0			Black
;	     1			Blue
;	     2			Green
;	     3			Cyan
;	     4			Red
;	     5			Magenta
;	     6			Brown
;	     7			White
;	     8			Gray
;	     9			Light Blue
;	     A			Light Green
;	     B			Light Cyan
;	     C			Light Red
;	     D			Light Magenta
;	     E			Yellow
;	     F			Intense White
;
;******************************************************************************
BLACK		Equ	00h		; Color 00h - Black
BLUE		Equ	01h		; Color 01h - Blue
GREEN		Equ	02h		; Color 02h - Green
CYAN		Equ	03h		; Color 03h - Cyan
RED		Equ	04h		; Color 04h - Red
MAGENTA 	Equ	05h		; Color 05h - Magneta
BROWN		Equ	06h		; Color 06h - Brown
WHITE		Equ	07h		; Color 07h - White
GRAY		Equ	08h		; Color 08h - Gray
LIGHT_BLUE	Equ	09h		; Color 09h - Light Blue
LIGHT_GREEN	Equ	0Ah		; Color 0Ah - Light Green
LIGHT_CYAN	Equ	0Bh		; Color 0Bh - Light Cyan
LIGHT_RED	Equ	0Ch		; Color 0Ch - Light Red
LIGHT_MAGENTA	Equ	0Dh		; Color 0Dh - Light Magenta
YELLOW		Equ	0Eh		; Color 0Eh - Yellow
INTENSE_WHITE	Equ	0Fh		; Color 0Fh - Intense White
;******************************************************************************
;
;	Define the ASCII Character Equate Values
;
;******************************************************************************
NULL		Equ	00h			; ASCII code for null
BELL		Equ	07h			; ASCII code for bell
BS		Equ	08h			; ASCII code for backspace
HT		Equ	09h			; ASCII code for horizontal tab
LF		Equ	0Ah			; ASCII code for line feed
VT		Equ	0Bh			; ASCII code for vertical tab
FF		Equ	0Ch			; ASCII code for form feed
CR		Equ	0Dh			; ASCII code for carriage return
SPACE		Equ	" "                     ; Space character
COMMA		Equ	","                     ; Comma character
SEMI_COLON	Equ	";"                     ; Semi-colon character
PLUS		Equ	"+"                     ; Plus sign character
MINUS		Equ	"-"                     ; Minus sign character
EQUAL		Equ	"="                     ; Equal sign character
ASTERISK	Equ	"*"                     ; Asterisk character
POINT		Equ	"."                     ; Decimal point character
PERIOD		Equ	"."                     ; Period character
SLASH		Equ	"/"                     ; Slash character
BACK_SLASH	Equ	"\"                     ; Back-slash character
	.List

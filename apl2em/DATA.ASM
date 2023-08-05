	Page	58,132
	Title	DATA.ASM	Apple Emulator (65C02 Processor)
;******************************************************************************
;
;   Name:	DATA.ASM	Apple Emulator (65C02 Processor)
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
;		This module contains all of the data areas for the
;	Apple emulator. (All data is in the code segment) This module
;	MUST be the last module linked.
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
	Public	Error_Table		; Error string table
	Public	Read_Table		; Read memory page table
	Public	Write_Table		; Write memory page table
	Public	Int_Table		; Interrupt table
	Public	IO_Read_Table		; I/O read table
	Public	IO_Write_Table		; I/O write table
	Public	CGA_Table		; CGA I/O routines table
	Public	EGA_Table		; EGA I/O routines table
	Public	Slot_ID 		; Expansion slot name table
	Public	Slot_Init		; Expansion slot initialization table
	Public	Slot_Ctrl		; Expansion slot control table
	Public	Slot_Read		; Expansion slot read table
	Public	Slot_Write		; Expansion slot write table
	Public	Mem_Read		; Expansion slot memory read table
	Public	Mem_Write		; Expansion slot memory write table
	Public	Exp_Read		; Expansion memory read table
	Public	Exp_Write		; Expansion memory write table
	Public	Device_Table		; Device type table
	Public	Flag_Encode		; CPU flag encoding table
	Public	Flag_Decode		; CPU flag decoding table
	Public	System_ROM		; Apple system ROM data file name
	Public	Disk_ROM		; Apple disk ctrl. ROM data file name
	Public	Current_Slot		; Current active slot number
	Public	Emulate_Flag		; Emulator system flag byte
	Public	System_Flag		; Apple system flag byte
	Public	Video_Flag		; Video system flag byte
	Public	Original_Int_8		; Original interrupt 8 vector storage
	Public	Original_Int_9		; Original interrupt 9 vector storage
	Public	RAM_Space		; RAM space segment value
	Public	ALT_Space		; Alternate RAM space segment value
;
;  External Declarations
;
	Extrn	STD_Mem_Read:Near	; Standard memory read routine (MEMORY)
	Extrn	STD_Mem_Write:Near	; Standard memory write routine(MEMORY)
	Extrn	ROM_Mem_Read:Near	; ROM memory read routine      (MEMORY)
	Extrn	ROM_Mem_Write:Near	; ROM memory write routine     (MEMORY)
	Extrn	Special_Read:Near	; Special none selected read   (MEMORY)
	Extrn	Special_Write:Near	; Special none selected write  (MEMORY)
	Extrn	Text_Read_1:Near	; Low res/text page 1 read	(VIDEO)
	Extrn	Text_Read_2:Near	; Low res/text page 2 read	(VIDEO)
	Extrn	Graph_Read_1:Near	; High res page 1 read		(VIDEO)
	Extrn	Graph_Read_2:Near	; High res page 2 read		(VIDEO)
	Extrn	Hardware_Read:Near	; Hardware read routine      (HARDWARE)
	Extrn	Hardware_Write:Near	; Hardware write routine     (HARDWARE)
	Extrn	Utility_Strobe:Near	; Apple utility strobe	     (HARDWARE)
	Extrn	Output_0_Off:Near	; Annunciator output 0 off   (HARDWARE)
	Extrn	Output_0_On:Near	; Annunciator output 0 on    (HARDWARE)
	Extrn	Output_1_Off:Near	; Annunciator output 1 off   (HARDWARE)
	Extrn	Output_1_On:Near	; Annunciator output 1 on    (HARDWARE)
	Extrn	Output_2_Off:Near	; Annunciator output 2 off   (HARDWARE)
	Extrn	Output_2_On:Near	; Annunciator output 2 on    (HARDWARE)
	Extrn	Output_3_Off:Near	; Annunciator output 3 off   (HARDWARE)
	Extrn	Output_3_On:Near	; Annunciator output 3 on    (HARDWARE)
	Extrn	Do_Nothing:Near 	; Do nothing		     (HARDWARE)
	Extrn	Keyboard_Input:Near	; Keyboard input	     (KEYBOARD)
	Extrn	Clear_Keyboard:Near	; Clear keyboard strobe      (KEYBOARD)
	Extrn	Speaker_Toggle:Near	; Speaker output toggle       (SPEAKER)
	Extrn	Cassette_Toggle:Near	; Cassette output toggle     (CASSETTE)
	Extrn	Cassette_Input:Near	; Cassette input	     (CASSETTE)
	Extrn	Button_1:Near		; Button 1 input	     (JOYSTICK)
	Extrn	Button_2:Near		; Button 2 input	     (JOYSTICK)
	Extrn	Button_3:Near		; Button 3 input	     (JOYSTICK)
	Extrn	Joystick_1:Near 	; Joystick 1 input	     (JOYSTICK)
	Extrn	Joystick_2:Near 	; Joystick 2 input	     (JOYSTICK)
	Extrn	Joystick_3:Near 	; Joystick 3 input	     (JOYSTICK)
	Extrn	Joystick_4:Near 	; Joystick 4 input	     (JOYSTICK)
	Extrn	Joystick_Strobe:Near	; Joystick clear strobe      (JOYSTICK)
	Extrn	Exp_Slot_Read:Near	; Expansion slot read routine  (DEVICE)
	Extrn	Exp_Slot_Write:Near	; Expansion slot write routine (DEVICE)
	Extrn	Exp_Mem_Read:Near	; Expansion mem. read routine  (DEVICE)
	Extrn	Exp_Mem_Write:Near	; Expansion mem. write routine (DEVICE)
	Extrn	Dummy_Int:Near		; Dummy interrupt routine	  (INT)
	Extrn	Reset_System:Near	; Reset system interrupt routine(APPLE)
	Extrn	Request_System:Near	; System request int. routine	(APPLE)
	Extrn	CGA_Text_1:Near 	; Low resolution/text page 1 write(CGA)
	Extrn	CGA_Text_2:Near 	; Low resolution/text page 2 write(CGA)
	Extrn	CGA_Graph_1:Near	; High resolution page 1 write	  (CGA)
	Extrn	CGA_Graph_2:Near	; High resolution page 2 write	  (CGA)
	Extrn	CGA_Text_Off:Near	; Text mode off (Graphics)	  (CGA)
	Extrn	CGA_Text_On:Near	; Text mode on (Text)		  (CGA)
	Extrn	CGA_Mixed_Off:Near	; Mixed off (Text / Graphics)	  (CGA)
	Extrn	CGA_Mixed_On:Near	; Mixed on (Text & Graphics)	  (CGA)
	Extrn	CGA_Page_1:Near 	; Select page 1 (Text & Graphics) (CGA)
	Extrn	CGA_Page_2:Near 	; Select page 2 (Text & Graphics) (CGA)
	Extrn	CGA_Low_Res:Near	; Select low res. (Graphics)	  (CGA)
	Extrn	CGA_High_Res:Near	; Select high res. (Graphics)	  (CGA)
	Extrn	EGA_Text_1:Near 	; Low resolution/text page 1 write(EGA)
	Extrn	EGA_Text_2:Near 	; Low resolution/text page 2 write(EGA)
	Extrn	EGA_Graph_1:Near	; High resolution page 1 write	  (EGA)
	Extrn	EGA_Graph_2:Near	; High resolution page 2 write	  (EGA)
	Extrn	EGA_Text_Off:Near	; Text mode off (Graphics)	  (EGA)
	Extrn	EGA_Text_On:Near	; Text mode on (Text)		  (EGA)
	Extrn	EGA_Mixed_Off:Near	; Mixed off (Text / Graphics)	  (EGA)
	Extrn	EGA_Mixed_On:Near	; Mixed on (Text & Graphics)	  (EGA)
	Extrn	EGA_Page_1:Near 	; Select page 1 (Text & Graphics) (EGA)
	Extrn	EGA_Page_2:Near 	; Select page 2 (Text & Graphics) (EGA)
	Extrn	EGA_Low_Res:Near	; Select low res. (Graphics)	  (EGA)
	Extrn	EGA_High_Res:Near	; Select high res. (Graphics)	  (EGA)
;
;  Define any include files needed
;
	Include 	Macros.inc	; Include the macro definitions
	Include 	Equates.inc	; Include the equate definitions
;
;  Define the different device types (Generate needed externals)
;
	Device	<Empty> 		; Define empty slot device	(EMPTY)
	Device	<Lang>			; Define language card device(LANGUAGE)
	Device	<Serial>		; Define serial port device    (SERIAL)
	Device	<Disk>			; Define disk controller device  (DISK)
	Device	<Cart>			; Define cartridge device    (CARTRIGE)
	.286c				; Include 80286 instructions
	Page
;
;  Define the emulator code segment
;
Emulate Segment Word Public 'EMULATE'   ; Emulator code segment
	Assume	cs:Emulate, ds:Nothing, es:Nothing
;******************************************************************************
;
;	Define the Error Strings and Error Table
;
;******************************************************************************
_Err_Cnt	=	0		; Start error code number
		Err_Str NO_MEMORY,<"Not enough memory for emulator">
		Err_Str NO_SYSTEM_FILE,<"Missing system ROM file">
		Err_Str BAD_SYSTEM_FILE,<"Bad system ROM file">
		Err_Str BAD_SYSTEM_IMAGE,<"Bad system ROM image">
		Err_Str BAD_ADAPTER,<"Color graphics adapter required">
		Err_Str NO_DISK_FILE,<"Missing disk controller ROM file">
		Err_Str BAD_DISK_FILE,<"Bad disk controller ROM file">
		Err_Str BAD_DISK_IMAGE,<"Bad disk controller ROM image">
		Err_Tbl
;******************************************************************************
;
;	Define the Expansion Slot and Device Tables
;
;******************************************************************************
		Even			; Force table to even address
		Slot	0,Lang		; Expansion slot 0 - Langauge card
		Slot	1,Serial	; Expansion slot 1 - Serial port card
		Slot	2,Empty 	; Expansion slot 2 - Empty slot
		Slot	3,Empty 	; Expansion slot 3 - Empty slot
		Slot	4,Empty 	; Expansion slot 4 - Empty slot
		Slot	5,Empty 	; Expansion slot 5 - Empty slot
		Slot	6,Disk		; Expansion slot 6 - Disk controller
		Slot	7,Cart		; Expansion slot 7 - Cartridge
		Table			; Define the expansion slot tables
;******************************************************************************
;
;	Define the Interrupt Table
;
;******************************************************************************
		Even			; Force table to even address
Int_Table	Equ	This Word	; Interrupt table
		Dw	Dummy_Int	; Emulate bit 7 - Dummy interrupt
		Dw	Dummy_Int	; Emulate bit 6 - Dummy interrupt
		Dw	Dummy_Int	; Emulate bit 5 - Dummy interrupt
		Dw	Dummy_Int	; Emulate bit 4 - Dummy interrupt
		Dw	Dummy_Int	; Emulate bit 3 - Dummy interrupt
		Dw	Dummy_Int	; Emulate bit 2 - Dummy interrupt
		Dw	Reset_System	; Emulate bit 1 - System reset int.
		Dw	Request_System	; Emulate bit 0 - System request int.
;******************************************************************************
;
;	Define the Video I/O Routines Tables
;
;******************************************************************************
		Even			; Force table to even address
CGA_Table	Equ	This Word	; CGA video I/O routines table
		Dw	CGA_Text_1	; Low resolution/text page 1 write
		Dw	CGA_Text_2	; Low resolution/text page 2 write
		Dw	CGA_Graph_1	; High resolution page 1 write
		Dw	CGA_Graph_2	; High resolution page 2 write
		Dw	CGA_Text_Off	; Text mode off (Graphics)
		Dw	CGA_Text_On	; Text mode on (Text)
		Dw	CGA_Mixed_Off	; Mixed off (Text / Graphics)
		Dw	CGA_Mixed_On	; Mixed on (Text & Graphics)
		Dw	CGA_Page_1	; Select video page 1 (Text & Graphics)
		Dw	CGA_Page_2	; Select video page 2 (Text & Graphics)
		Dw	CGA_Low_Res	; Select low resolution (Graphics)
		Dw	CGA_High_Res	; Select high resolution (Graphics)
EGA_Table	Equ	This Word	; EGA video I/O routines table
		Dw	EGA_Text_1	; Low resolution/text page 1 write
		Dw	EGA_Text_2	; Low resolution/text page 2 write
		Dw	EGA_Graph_1	; High resolution page 1 write
		Dw	EGA_Graph_2	; High resolution page 2 write
		Dw	EGA_Text_Off	; Text mode off (Graphics)
		Dw	EGA_Text_On	; Text mode on (Text)
		Dw	EGA_Mixed_Off	; Mixed off (Text / Graphics)
		Dw	EGA_Mixed_On	; Mixed on (Text & Graphics)
		Dw	EGA_Page_1	; Select video page 1 (Text & Graphics)
		Dw	EGA_Page_2	; Select video page 2 (Text & Graphics)
		Dw	EGA_Low_Res	; Select low resolution (Graphics)
		Dw	EGA_High_Res	; Select high resolution (Graphics)
;******************************************************************************
;
;	Define the Read Memory Page Table
;
;******************************************************************************
		Even			; Force table to even address
Read_Table	Equ	This Word	; Read memory page table
		Dw	STD_Mem_Read	; Page 00h - Standard memory read
		Dw	STD_Mem_Read	; Page 01h - Standard memory read
		Dw	STD_Mem_Read	; Page 02h - Standard memory read
		Dw	STD_Mem_Read	; Page 03h - Standard memory read
		Dw	Text_Read_1	; Page 04h - Low res/text page 1 read
		Dw	Text_Read_1	; Page 05h - Low res/text page 1 read
		Dw	Text_Read_1	; Page 06h - Low res/text page 1 read
		Dw	Text_Read_1	; Page 07h - Low res/text page 1 read
		Dw	Text_Read_2	; Page 08h - Low res/text page 2 read
		Dw	Text_Read_2	; Page 09h - Low res/text page 2 read
		Dw	Text_Read_2	; Page 0Ah - Low res/text page 2 read
		Dw	Text_Read_2	; Page 0Bh - Low res/text page 2 read
		Dw	STD_Mem_Read	; Page 0Ch - Standard memory read
		Dw	STD_Mem_Read	; Page 0Dh - Standard memory read
		Dw	STD_Mem_Read	; Page 0Eh - Standard memory read
		Dw	STD_Mem_Read	; Page 0Fh - Standard memory read
		Dw	STD_Mem_Read	; Page 10h - Standard memory read
		Dw	STD_Mem_Read	; Page 11h - Standard memory read
		Dw	STD_Mem_Read	; Page 12h - Standard memory read
		Dw	STD_Mem_Read	; Page 13h - Standard memory read
		Dw	STD_Mem_Read	; Page 14h - Standard memory read
		Dw	STD_Mem_Read	; Page 15h - Standard memory read
		Dw	STD_Mem_Read	; Page 16h - Standard memory read
		Dw	STD_Mem_Read	; Page 17h - Standard memory read
		Dw	STD_Mem_Read	; Page 18h - Standard memory read
		Dw	STD_Mem_Read	; Page 19h - Standard memory read
		Dw	STD_Mem_Read	; Page 1Ah - Standard memory read
		Dw	STD_Mem_Read	; Page 1Bh - Standard memory read
		Dw	STD_Mem_Read	; Page 1Ch - Standard memory read
		Dw	STD_Mem_Read	; Page 1Dh - Standard memory read
		Dw	STD_Mem_Read	; Page 1Eh - Standard memory read
		Dw	STD_Mem_Read	; Page 1Fh - Standard memory read
		Dw	Graph_Read_1	; Page 20h - High res page 1 read
		Dw	Graph_Read_1	; Page 21h - High res page 1 read
		Dw	Graph_Read_1	; Page 22h - High res page 1 read
		Dw	Graph_Read_1	; Page 23h - High res page 1 read
		Dw	Graph_Read_1	; Page 24h - High res page 1 read
		Dw	Graph_Read_1	; Page 25h - High res page 1 read
		Dw	Graph_Read_1	; Page 26h - High res page 1 read
		Dw	Graph_Read_1	; Page 27h - High res page 1 read
		Dw	Graph_Read_1	; Page 28h - High res page 1 read
		Dw	Graph_Read_1	; Page 29h - High res page 1 read
		Dw	Graph_Read_1	; Page 2Ah - High res page 1 read
		Dw	Graph_Read_1	; Page 2Bh - High res page 1 read
		Dw	Graph_Read_1	; Page 2Ch - High res page 1 read
		Dw	Graph_Read_1	; Page 2Dh - High res page 1 read
		Dw	Graph_Read_1	; Page 2Eh - High res page 1 read
		Dw	Graph_Read_1	; Page 2Fh - High res page 1 read
		Dw	Graph_Read_1	; Page 30h - High res page 1 read
		Dw	Graph_Read_1	; Page 31h - High res page 1 read
		Dw	Graph_Read_1	; Page 32h - High res page 1 read
		Dw	Graph_Read_1	; Page 33h - High res page 1 read
		Dw	Graph_Read_1	; Page 34h - High res page 1 read
		Dw	Graph_Read_1	; Page 35h - High res page 1 read
		Dw	Graph_Read_1	; Page 36h - High res page 1 read
		Dw	Graph_Read_1	; Page 37h - High res page 1 read
		Dw	Graph_Read_1	; Page 38h - High res page 1 read
		Dw	Graph_Read_1	; Page 39h - High res page 1 read
		Dw	Graph_Read_1	; Page 3Ah - High res page 1 read
		Dw	Graph_Read_1	; Page 3Bh - High res page 1 read
		Dw	Graph_Read_1	; Page 3Ch - High res page 1 read
		Dw	Graph_Read_1	; Page 3Dh - High res page 1 read
		Dw	Graph_Read_1	; Page 3Eh - High res page 1 read
		Dw	Graph_Read_1	; Page 3Fh - High res page 1 read
		Dw	Graph_Read_2	; Page 40h - High res page 2 read
		Dw	Graph_Read_2	; Page 41h - High res page 2 read
		Dw	Graph_Read_2	; Page 42h - High res page 2 read
		Dw	Graph_Read_2	; Page 43h - High res page 2 read
		Dw	Graph_Read_2	; Page 44h - High res page 2 read
		Dw	Graph_Read_2	; Page 45h - High res page 2 read
		Dw	Graph_Read_2	; Page 46h - High res page 2 read
		Dw	Graph_Read_2	; Page 47h - High res page 2 read
		Dw	Graph_Read_2	; Page 48h - High res page 2 read
		Dw	Graph_Read_2	; Page 49h - High res page 2 read
		Dw	Graph_Read_2	; Page 4Ah - High res page 2 read
		Dw	Graph_Read_2	; Page 4Bh - High res page 2 read
		Dw	Graph_Read_2	; Page 4Ch - High res page 2 read
		Dw	Graph_Read_2	; Page 4Dh - High res page 2 read
		Dw	Graph_Read_2	; Page 4Eh - High res page 2 read
		Dw	Graph_Read_2	; Page 4Fh - High res page 2 read
		Dw	Graph_Read_2	; Page 50h - High res page 2 read
		Dw	Graph_Read_2	; Page 51h - High res page 2 read
		Dw	Graph_Read_2	; Page 52h - High res page 2 read
		Dw	Graph_Read_2	; Page 53h - High res page 2 read
		Dw	Graph_Read_2	; Page 54h - High res page 2 read
		Dw	Graph_Read_2	; Page 55h - High res page 2 read
		Dw	Graph_Read_2	; Page 56h - High res page 2 read
		Dw	Graph_Read_2	; Page 57h - High res page 2 read
		Dw	Graph_Read_2	; Page 58h - High res page 2 read
		Dw	Graph_Read_2	; Page 59h - High res page 2 read
		Dw	Graph_Read_2	; Page 5Ah - High res page 2 read
		Dw	Graph_Read_2	; Page 5Bh - High res page 2 read
		Dw	Graph_Read_2	; Page 5Ch - High res page 2 read
		Dw	Graph_Read_2	; Page 5Dh - High res page 2 read
		Dw	Graph_Read_2	; Page 5Eh - High res page 2 read
		Dw	Graph_Read_2	; Page 5Fh - High res page 2 read
		Dw	STD_Mem_Read	; Page 60h - Standard memory read
		Dw	STD_Mem_Read	; Page 61h - Standard memory read
		Dw	STD_Mem_Read	; Page 62h - Standard memory read
		Dw	STD_Mem_Read	; Page 63h - Standard memory read
		Dw	STD_Mem_Read	; Page 64h - Standard memory read
		Dw	STD_Mem_Read	; Page 65h - Standard memory read
		Dw	STD_Mem_Read	; Page 66h - Standard memory read
		Dw	STD_Mem_Read	; Page 67h - Standard memory read
		Dw	STD_Mem_Read	; Page 68h - Standard memory read
		Dw	STD_Mem_Read	; Page 69h - Standard memory read
		Dw	STD_Mem_Read	; Page 6Ah - Standard memory read
		Dw	STD_Mem_Read	; Page 6Bh - Standard memory read
		Dw	STD_Mem_Read	; Page 6Ch - Standard memory read
		Dw	STD_Mem_Read	; Page 6Dh - Standard memory read
		Dw	STD_Mem_Read	; Page 6Eh - Standard memory read
		Dw	STD_Mem_Read	; Page 6Fh - Standard memory read
		Dw	STD_Mem_Read	; Page 70h - Standard memory read
		Dw	STD_Mem_Read	; Page 71h - Standard memory read
		Dw	STD_Mem_Read	; Page 72h - Standard memory read
		Dw	STD_Mem_Read	; Page 73h - Standard memory read
		Dw	STD_Mem_Read	; Page 74h - Standard memory read
		Dw	STD_Mem_Read	; Page 75h - Standard memory read
		Dw	STD_Mem_Read	; Page 76h - Standard memory read
		Dw	STD_Mem_Read	; Page 77h - Standard memory read
		Dw	STD_Mem_Read	; Page 78h - Standard memory read
		Dw	STD_Mem_Read	; Page 79h - Standard memory read
		Dw	STD_Mem_Read	; Page 7Ah - Standard memory read
		Dw	STD_Mem_Read	; Page 7Bh - Standard memory read
		Dw	STD_Mem_Read	; Page 7Ch - Standard memory read
		Dw	STD_Mem_Read	; Page 7Dh - Standard memory read
		Dw	STD_Mem_Read	; Page 7Eh - Standard memory read
		Dw	STD_Mem_Read	; Page 7Fh - Standard memory read
		Dw	STD_Mem_Read	; Page 80h - Standard memory read
		Dw	STD_Mem_Read	; Page 81h - Standard memory read
		Dw	STD_Mem_Read	; Page 82h - Standard memory read
		Dw	STD_Mem_Read	; Page 83h - Standard memory read
		Dw	STD_Mem_Read	; Page 84h - Standard memory read
		Dw	STD_Mem_Read	; Page 85h - Standard memory read
		Dw	STD_Mem_Read	; Page 86h - Standard memory read
		Dw	STD_Mem_Read	; Page 87h - Standard memory read
		Dw	STD_Mem_Read	; Page 88h - Standard memory read
		Dw	STD_Mem_Read	; Page 89h - Standard memory read
		Dw	STD_Mem_Read	; Page 8Ah - Standard memory read
		Dw	STD_Mem_Read	; Page 8Bh - Standard memory read
		Dw	STD_Mem_Read	; Page 8Ch - Standard memory read
		Dw	STD_Mem_Read	; Page 8Dh - Standard memory read
		Dw	STD_Mem_Read	; Page 8Eh - Standard memory read
		Dw	STD_Mem_Read	; Page 8Fh - Standard memory read
		Dw	STD_Mem_Read	; Page 90h - Standard memory read
		Dw	STD_Mem_Read	; Page 91h - Standard memory read
		Dw	STD_Mem_Read	; Page 92h - Standard memory read
		Dw	STD_Mem_Read	; Page 93h - Standard memory read
		Dw	STD_Mem_Read	; Page 94h - Standard memory read
		Dw	STD_Mem_Read	; Page 95h - Standard memory read
		Dw	STD_Mem_Read	; Page 96h - Standard memory read
		Dw	STD_Mem_Read	; Page 97h - Standard memory read
		Dw	STD_Mem_Read	; Page 98h - Standard memory read
		Dw	STD_Mem_Read	; Page 99h - Standard memory read
		Dw	STD_Mem_Read	; Page 9Ah - Standard memory read
		Dw	STD_Mem_Read	; Page 9Bh - Standard memory read
		Dw	STD_Mem_Read	; Page 9Ch - Standard memory read
		Dw	STD_Mem_Read	; Page 9Dh - Standard memory read
		Dw	STD_Mem_Read	; Page 9Eh - Standard memory read
		Dw	STD_Mem_Read	; Page 9Fh - Standard memory read
		Dw	STD_Mem_Read	; Page A0h - Standard memory read
		Dw	STD_Mem_Read	; Page A1h - Standard memory read
		Dw	STD_Mem_Read	; Page A2h - Standard memory read
		Dw	STD_Mem_Read	; Page A3h - Standard memory read
		Dw	STD_Mem_Read	; Page A4h - Standard memory read
		Dw	STD_Mem_Read	; Page A5h - Standard memory read
		Dw	STD_Mem_Read	; Page A6h - Standard memory read
		Dw	STD_Mem_Read	; Page A7h - Standard memory read
		Dw	STD_Mem_Read	; Page A8h - Standard memory read
		Dw	STD_Mem_Read	; Page A9h - Standard memory read
		Dw	STD_Mem_Read	; Page AAh - Standard memory read
		Dw	STD_Mem_Read	; Page ABh - Standard memory read
		Dw	STD_Mem_Read	; Page ACh - Standard memory read
		Dw	STD_Mem_Read	; Page ADh - Standard memory read
		Dw	STD_Mem_Read	; Page AEh - Standard memory read
		Dw	STD_Mem_Read	; Page AFh - Standard memory read
		Dw	STD_Mem_Read	; Page B0h - Standard memory read
		Dw	STD_Mem_Read	; Page B1h - Standard memory read
		Dw	STD_Mem_Read	; Page B2h - Standard memory read
		Dw	STD_Mem_Read	; Page B3h - Standard memory read
		Dw	STD_Mem_Read	; Page B4h - Standard memory read
		Dw	STD_Mem_Read	; Page B5h - Standard memory read
		Dw	STD_Mem_Read	; Page B6h - Standard memory read
		Dw	STD_Mem_Read	; Page B7h - Standard memory read
		Dw	STD_Mem_Read	; Page B8h - Standard memory read
		Dw	STD_Mem_Read	; Page B9h - Standard memory read
		Dw	STD_Mem_Read	; Page BAh - Standard memory read
		Dw	STD_Mem_Read	; Page BBh - Standard memory read
		Dw	STD_Mem_Read	; Page BCh - Standard memory read
		Dw	STD_Mem_Read	; Page BDh - Standard memory read
		Dw	STD_Mem_Read	; Page BEh - Standard memory read
		Dw	STD_Mem_Read	; Page BFh - Standard memory read
		Dw	Hardware_Read	; Page C0h - Hardware page read
		Dw	Exp_Slot_Read	; Page C1h - Expansion slot 1 read
		Dw	Exp_Slot_Read	; Page C2h - Expansion slot 2 read
		Dw	Exp_Slot_Read	; Page C3h - Expansion slot 3 read
		Dw	Exp_Slot_Read	; Page C4h - Expansion slot 4 read
		Dw	Exp_Slot_Read	; Page C5h - Expansion slot 5 read
		Dw	Exp_Slot_Read	; Page C6h - Expansion slot 6 read
		Dw	Exp_Slot_Read	; Page C7h - Expansion slot 7 read
		Dw	Exp_Mem_Read	; Page C8h - Expansion memory read
		Dw	Exp_Mem_Read	; Page C9h - Expansion memory read
		Dw	Exp_Mem_Read	; Page CAh - Expansion memory read
		Dw	Exp_Mem_Read	; Page CBh - Expansion memory read
		Dw	Exp_Mem_Read	; Page CCh - Expansion memory read
		Dw	Exp_Mem_Read	; Page CDh - Expansion memory read
		Dw	Exp_Mem_Read	; Page CEh - Expansion memory read
		Dw	Exp_Mem_Read	; Page CFh - Expansion memory read
		Dw	ROM_Mem_Read	; Page D0h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D1h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D2h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D3h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D4h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D5h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D6h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D7h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D8h - System ROM memory read
		Dw	ROM_Mem_Read	; Page D9h - System ROM memory read
		Dw	ROM_Mem_Read	; Page DAh - System ROM memory read
		Dw	ROM_Mem_Read	; Page DBh - System ROM memory read
		Dw	ROM_Mem_Read	; Page DCh - System ROM memory read
		Dw	ROM_Mem_Read	; Page DDh - System ROM memory read
		Dw	ROM_Mem_Read	; Page DEh - System ROM memory read
		Dw	ROM_Mem_Read	; Page DFh - System ROM memory read
		Dw	ROM_Mem_Read	; Page E0h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E1h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E2h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E3h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E4h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E5h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E6h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E7h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E8h - System ROM memory read
		Dw	ROM_Mem_Read	; Page E9h - System ROM memory read
		Dw	ROM_Mem_Read	; Page EAh - System ROM memory read
		Dw	ROM_Mem_Read	; Page EBh - System ROM memory read
		Dw	ROM_Mem_Read	; Page ECh - System ROM memory read
		Dw	ROM_Mem_Read	; Page EDh - System ROM memory read
		Dw	ROM_Mem_Read	; Page EEh - System ROM memory read
		Dw	ROM_Mem_Read	; Page EFh - System ROM memory read
		Dw	ROM_Mem_Read	; Page F0h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F1h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F2h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F3h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F4h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F5h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F6h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F7h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F8h - System ROM memory read
		Dw	ROM_Mem_Read	; Page F9h - System ROM memory read
		Dw	ROM_Mem_Read	; Page FAh - System ROM memory read
		Dw	ROM_Mem_Read	; Page FBh - System ROM memory read
		Dw	ROM_Mem_Read	; Page FCh - System ROM memory read
		Dw	ROM_Mem_Read	; Page FDh - System ROM memory read
		Dw	ROM_Mem_Read	; Page FEh - System ROM memory read
		Dw	ROM_Mem_Read	; Page FFh - System ROM memory read
;******************************************************************************
;
;	Define the Write Memory Page Table
;
;******************************************************************************
		Even			; Force table to even address
Write_Table	Equ	This Word	; Write memory page table
		Dw	STD_Mem_Write	; Page 00h - Standard memory write
		Dw	STD_Mem_Write	; Page 01h - Standard memory write
		Dw	STD_Mem_Write	; Page 02h - Standard memory write
		Dw	STD_Mem_Write	; Page 03h - Standard memory write
		Dw	0000h		; Page 04h - Low res/text page 1 write
		Dw	0000h		; Page 05h - Low res/text page 1 write
		Dw	0000h		; Page 06h - Low res/text page 1 write
		Dw	0000h		; Page 07h - Low res/text page 1 write
		Dw	0000h		; Page 08h - Low res/text page 2 write
		Dw	0000h		; Page 09h - Low res/text page 2 write
		Dw	0000h		; Page 0Ah - Low res/text page 2 write
		Dw	0000h		; Page 0Bh - Low res/text page 2 write
		Dw	STD_Mem_Write	; Page 0Ch - Standard memory write
		Dw	STD_Mem_Write	; Page 0Dh - Standard memory write
		Dw	STD_Mem_Write	; Page 0Eh - Standard memory write
		Dw	STD_Mem_Write	; Page 0Fh - Standard memory write
		Dw	STD_Mem_Write	; Page 10h - Standard memory write
		Dw	STD_Mem_Write	; Page 11h - Standard memory write
		Dw	STD_Mem_Write	; Page 12h - Standard memory write
		Dw	STD_Mem_Write	; Page 13h - Standard memory write
		Dw	STD_Mem_Write	; Page 14h - Standard memory write
		Dw	STD_Mem_Write	; Page 15h - Standard memory write
		Dw	STD_Mem_Write	; Page 16h - Standard memory write
		Dw	STD_Mem_Write	; Page 17h - Standard memory write
		Dw	STD_Mem_Write	; Page 18h - Standard memory write
		Dw	STD_Mem_Write	; Page 19h - Standard memory write
		Dw	STD_Mem_Write	; Page 1Ah - Standard memory write
		Dw	STD_Mem_Write	; Page 1Bh - Standard memory write
		Dw	STD_Mem_Write	; Page 1Ch - Standard memory write
		Dw	STD_Mem_Write	; Page 1Dh - Standard memory write
		Dw	STD_Mem_Write	; Page 1Eh - Standard memory write
		Dw	STD_Mem_Write	; Page 1Fh - Standard memory write
		Dw	0000h		; Page 20h - High res page 1 write
		Dw	0000h		; Page 21h - High res page 1 write
		Dw	0000h		; Page 22h - High res page 1 write
		Dw	0000h		; Page 23h - High res page 1 write
		Dw	0000h		; Page 24h - High res page 1 write
		Dw	0000h		; Page 25h - High res page 1 write
		Dw	0000h		; Page 26h - High res page 1 write
		Dw	0000h		; Page 27h - High res page 1 write
		Dw	0000h		; Page 28h - High res page 1 write
		Dw	0000h		; Page 29h - High res page 1 write
		Dw	0000h		; Page 2Ah - High res page 1 write
		Dw	0000h		; Page 2Bh - High res page 1 write
		Dw	0000h		; Page 2Ch - High res page 1 write
		Dw	0000h		; Page 2Dh - High res page 1 write
		Dw	0000h		; Page 2Eh - High res page 1 write
		Dw	0000h		; Page 2Fh - High res page 1 write
		Dw	0000h		; Page 30h - High res page 1 write
		Dw	0000h		; Page 31h - High res page 1 write
		Dw	0000h		; Page 32h - High res page 1 write
		Dw	0000h		; Page 33h - High res page 1 write
		Dw	0000h		; Page 34h - High res page 1 write
		Dw	0000h		; Page 35h - High res page 1 write
		Dw	0000h		; Page 36h - High res page 1 write
		Dw	0000h		; Page 37h - High res page 1 write
		Dw	0000h		; Page 38h - High res page 1 write
		Dw	0000h		; Page 39h - High res page 1 write
		Dw	0000h		; Page 3Ah - High res page 1 write
		Dw	0000h		; Page 3Bh - High res page 1 write
		Dw	0000h		; Page 3Ch - High res page 1 write
		Dw	0000h		; Page 3Dh - High res page 1 write
		Dw	0000h		; Page 3Eh - High res page 1 write
		Dw	0000h		; Page 3Fh - High res page 1 write
		Dw	0000h		; Page 40h - High res page 2 write
		Dw	0000h		; Page 41h - High res page 2 write
		Dw	0000h		; Page 42h - High res page 2 write
		Dw	0000h		; Page 43h - High res page 2 write
		Dw	0000h		; Page 44h - High res page 2 write
		Dw	0000h		; Page 45h - High res page 2 write
		Dw	0000h		; Page 46h - High res page 2 write
		Dw	0000h		; Page 47h - High res page 2 write
		Dw	0000h		; Page 48h - High res page 2 write
		Dw	0000h		; Page 49h - High res page 2 write
		Dw	0000h		; Page 4Ah - High res page 2 write
		Dw	0000h		; Page 4Bh - High res page 2 write
		Dw	0000h		; Page 4Ch - High res page 2 write
		Dw	0000h		; Page 4Dh - High res page 2 write
		Dw	0000h		; Page 4Eh - High res page 2 write
		Dw	0000h		; Page 4Fh - High res page 2 write
		Dw	0000h		; Page 50h - High res page 2 write
		Dw	0000h		; Page 51h - High res page 2 write
		Dw	0000h		; Page 52h - High res page 2 write
		Dw	0000h		; Page 53h - High res page 2 write
		Dw	0000h		; Page 54h - High res page 2 write
		Dw	0000h		; Page 55h - High res page 2 write
		Dw	0000h		; Page 56h - High res page 2 write
		Dw	0000h		; Page 57h - High res page 2 write
		Dw	0000h		; Page 58h - High res page 2 write
		Dw	0000h		; Page 59h - High res page 2 write
		Dw	0000h		; Page 5Ah - High res page 2 write
		Dw	0000h		; Page 5Bh - High res page 2 write
		Dw	0000h		; Page 5Ch - High res page 2 write
		Dw	0000h		; Page 5Dh - High res page 2 write
		Dw	0000h		; Page 5Eh - High res page 2 write
		Dw	0000h		; Page 5Fh - High res page 2 write
		Dw	STD_Mem_Write	; Page 60h - Standard memory write
		Dw	STD_Mem_Write	; Page 61h - Standard memory write
		Dw	STD_Mem_Write	; Page 62h - Standard memory write
		Dw	STD_Mem_Write	; Page 63h - Standard memory write
		Dw	STD_Mem_Write	; Page 64h - Standard memory write
		Dw	STD_Mem_Write	; Page 65h - Standard memory write
		Dw	STD_Mem_Write	; Page 66h - Standard memory write
		Dw	STD_Mem_Write	; Page 67h - Standard memory write
		Dw	STD_Mem_Write	; Page 68h - Standard memory write
		Dw	STD_Mem_Write	; Page 69h - Standard memory write
		Dw	STD_Mem_Write	; Page 6Ah - Standard memory write
		Dw	STD_Mem_Write	; Page 6Bh - Standard memory write
		Dw	STD_Mem_Write	; Page 6Ch - Standard memory write
		Dw	STD_Mem_Write	; Page 6Dh - Standard memory write
		Dw	STD_Mem_Write	; Page 6Eh - Standard memory write
		Dw	STD_Mem_Write	; Page 6Fh - Standard memory write
		Dw	STD_Mem_Write	; Page 70h - Standard memory write
		Dw	STD_Mem_Write	; Page 71h - Standard memory write
		Dw	STD_Mem_Write	; Page 72h - Standard memory write
		Dw	STD_Mem_Write	; Page 73h - Standard memory write
		Dw	STD_Mem_Write	; Page 74h - Standard memory write
		Dw	STD_Mem_Write	; Page 75h - Standard memory write
		Dw	STD_Mem_Write	; Page 76h - Standard memory write
		Dw	STD_Mem_Write	; Page 77h - Standard memory write
		Dw	STD_Mem_Write	; Page 78h - Standard memory write
		Dw	STD_Mem_Write	; Page 79h - Standard memory write
		Dw	STD_Mem_Write	; Page 7Ah - Standard memory write
		Dw	STD_Mem_Write	; Page 7Bh - Standard memory write
		Dw	STD_Mem_Write	; Page 7Ch - Standard memory write
		Dw	STD_Mem_Write	; Page 7Dh - Standard memory write
		Dw	STD_Mem_Write	; Page 7Eh - Standard memory write
		Dw	STD_Mem_Write	; Page 7Fh - Standard memory write
		Dw	STD_Mem_Write	; Page 80h - Standard memory write
		Dw	STD_Mem_Write	; Page 81h - Standard memory write
		Dw	STD_Mem_Write	; Page 82h - Standard memory write
		Dw	STD_Mem_Write	; Page 83h - Standard memory write
		Dw	STD_Mem_Write	; Page 84h - Standard memory write
		Dw	STD_Mem_Write	; Page 85h - Standard memory write
		Dw	STD_Mem_Write	; Page 86h - Standard memory write
		Dw	STD_Mem_Write	; Page 87h - Standard memory write
		Dw	STD_Mem_Write	; Page 88h - Standard memory write
		Dw	STD_Mem_Write	; Page 89h - Standard memory write
		Dw	STD_Mem_Write	; Page 8Ah - Standard memory write
		Dw	STD_Mem_Write	; Page 8Bh - Standard memory write
		Dw	STD_Mem_Write	; Page 8Ch - Standard memory write
		Dw	STD_Mem_Write	; Page 8Dh - Standard memory write
		Dw	STD_Mem_Write	; Page 8Eh - Standard memory write
		Dw	STD_Mem_Write	; Page 8Fh - Standard memory write
		Dw	STD_Mem_Write	; Page 90h - Standard memory write
		Dw	STD_Mem_Write	; Page 91h - Standard memory write
		Dw	STD_Mem_Write	; Page 92h - Standard memory write
		Dw	STD_Mem_Write	; Page 93h - Standard memory write
		Dw	STD_Mem_Write	; Page 94h - Standard memory write
		Dw	STD_Mem_Write	; Page 95h - Standard memory write
		Dw	STD_Mem_Write	; Page 96h - Standard memory write
		Dw	STD_Mem_Write	; Page 97h - Standard memory write
		Dw	STD_Mem_Write	; Page 98h - Standard memory write
		Dw	STD_Mem_Write	; Page 99h - Standard memory write
		Dw	STD_Mem_Write	; Page 9Ah - Standard memory write
		Dw	STD_Mem_Write	; Page 9Bh - Standard memory write
		Dw	STD_Mem_Write	; Page 9Ch - Standard memory write
		Dw	STD_Mem_Write	; Page 9Dh - Standard memory write
		Dw	STD_Mem_Write	; Page 9Eh - Standard memory write
		Dw	STD_Mem_Write	; Page 9Fh - Standard memory write
		Dw	STD_Mem_Write	; Page A0h - Standard memory write
		Dw	STD_Mem_Write	; Page A1h - Standard memory write
		Dw	STD_Mem_Write	; Page A2h - Standard memory write
		Dw	STD_Mem_Write	; Page A3h - Standard memory write
		Dw	STD_Mem_Write	; Page A4h - Standard memory write
		Dw	STD_Mem_Write	; Page A5h - Standard memory write
		Dw	STD_Mem_Write	; Page A6h - Standard memory write
		Dw	STD_Mem_Write	; Page A7h - Standard memory write
		Dw	STD_Mem_Write	; Page A8h - Standard memory write
		Dw	STD_Mem_Write	; Page A9h - Standard memory write
		Dw	STD_Mem_Write	; Page AAh - Standard memory write
		Dw	STD_Mem_Write	; Page ABh - Standard memory write
		Dw	STD_Mem_Write	; Page ACh - Standard memory write
		Dw	STD_Mem_Write	; Page ADh - Standard memory write
		Dw	STD_Mem_Write	; Page AEh - Standard memory write
		Dw	STD_Mem_Write	; Page AFh - Standard memory write
		Dw	STD_Mem_Write	; Page B0h - Standard memory write
		Dw	STD_Mem_Write	; Page B1h - Standard memory write
		Dw	STD_Mem_Write	; Page B2h - Standard memory write
		Dw	STD_Mem_Write	; Page B3h - Standard memory write
		Dw	STD_Mem_Write	; Page B4h - Standard memory write
		Dw	STD_Mem_Write	; Page B5h - Standard memory write
		Dw	STD_Mem_Write	; Page B6h - Standard memory write
		Dw	STD_Mem_Write	; Page B7h - Standard memory write
		Dw	STD_Mem_Write	; Page B8h - Standard memory write
		Dw	STD_Mem_Write	; Page B9h - Standard memory write
		Dw	STD_Mem_Write	; Page BAh - Standard memory write
		Dw	STD_Mem_Write	; Page BBh - Standard memory write
		Dw	STD_Mem_Write	; Page BCh - Standard memory write
		Dw	STD_Mem_Write	; Page BDh - Standard memory write
		Dw	STD_Mem_Write	; Page BEh - Standard memory write
		Dw	STD_Mem_Write	; Page BFh - Standard memory write
		Dw	Hardware_Write	; Page C0h - Hardware write
		Dw	Exp_Slot_Write	; Page C1h - Expansion slot 1 write
		Dw	Exp_Slot_Write	; Page C2h - Expansion slot 2 write
		Dw	Exp_Slot_Write	; Page C3h - Expansion slot 3 write
		Dw	Exp_Slot_Write	; Page C4h - Expansion slot 4 write
		Dw	Exp_Slot_Write	; Page C5h - Expansion slot 5 write
		Dw	Exp_Slot_Write	; Page C6h - Expansion slot 6 write
		Dw	Exp_Slot_Write	; Page C7h - Expansion slot 7 write
		Dw	Exp_Mem_Write	; Page C8h - Expansion memory write
		Dw	Exp_Mem_Write	; Page C9h - Expansion memory write
		Dw	Exp_Mem_Write	; Page CAh - Expansion memory write
		Dw	Exp_Mem_Write	; Page CBh - Expansion memory write
		Dw	Exp_Mem_Write	; Page CCh - Expansion memory write
		Dw	Exp_Mem_Write	; Page CDh - Expansion memory write
		Dw	Exp_Mem_Write	; Page CEh - Expansion memory write
		Dw	Exp_Mem_Write	; Page CFh - Expansion memory write
		Dw	ROM_Mem_Write	; Page D0h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D1h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D2h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D3h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D4h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D5h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D6h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D7h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D8h - System ROM memory write
		Dw	ROM_Mem_Write	; Page D9h - System ROM memory write
		Dw	ROM_Mem_Write	; Page DAh - System ROM memory write
		Dw	ROM_Mem_Write	; Page DBh - System ROM memory write
		Dw	ROM_Mem_Write	; Page DCh - System ROM memory write
		Dw	ROM_Mem_Write	; Page DDh - System ROM memory write
		Dw	ROM_Mem_Write	; Page DEh - System ROM memory write
		Dw	ROM_Mem_Write	; Page DFh - System ROM memory write
		Dw	ROM_Mem_Write	; Page E0h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E1h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E2h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E3h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E4h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E5h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E6h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E7h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E8h - System ROM memory write
		Dw	ROM_Mem_Write	; Page E9h - System ROM memory write
		Dw	ROM_Mem_Write	; Page EAh - System ROM memory write
		Dw	ROM_Mem_Write	; Page EBh - System ROM memory write
		Dw	ROM_Mem_Write	; Page ECh - System ROM memory write
		Dw	ROM_Mem_Write	; Page EDh - System ROM memory write
		Dw	ROM_Mem_Write	; Page EEh - System ROM memory write
		Dw	ROM_Mem_Write	; Page EFh - System ROM memory write
		Dw	ROM_Mem_Write	; Page F0h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F1h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F2h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F3h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F4h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F5h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F6h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F7h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F8h - System ROM memory write
		Dw	ROM_Mem_Write	; Page F9h - System ROM memory write
		Dw	ROM_Mem_Write	; Page FAh - System ROM memory write
		Dw	ROM_Mem_Write	; Page FBh - System ROM memory write
		Dw	ROM_Mem_Write	; Page FCh - System ROM memory write
		Dw	ROM_Mem_Write	; Page FDh - System ROM memory write
		Dw	ROM_Mem_Write	; Page FEh - System ROM memory write
		Dw	ROM_Mem_Write	; Page FFh - System ROM memory write
;******************************************************************************
;
;	Define the I/O Read Table
;
;******************************************************************************
		Even			; Force table to even address
IO_Read_Table	Equ	This Word	; I/O read table
		Dw	Keyboard_Input	; Location 00h - Keyboard input
		Dw	Keyboard_Input	; Location 01h - Keyboard input
		Dw	Keyboard_Input	; Location 02h - Keyboard input
		Dw	Keyboard_Input	; Location 03h - Keyboard input
		Dw	Keyboard_Input	; Location 04h - Keyboard input
		Dw	Keyboard_Input	; Location 05h - Keyboard input
		Dw	Keyboard_Input	; Location 06h - Keyboard input
		Dw	Keyboard_Input	; Location 07h - Keyboard input
		Dw	Keyboard_Input	; Location 08h - Keyboard input
		Dw	Keyboard_Input	; Location 09h - Keyboard input
		Dw	Keyboard_Input	; Location 0Ah - Keyboard input
		Dw	Keyboard_Input	; Location 0Bh - Keyboard input
		Dw	Keyboard_Input	; Location 0Ch - Keyboard input
		Dw	Keyboard_Input	; Location 0Dh - Keyboard input
		Dw	Keyboard_Input	; Location 0Eh - Keyboard input
		Dw	Keyboard_Input	; Location 0Fh - Keyboard input
		Dw	Clear_Keyboard	; Location 10h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 11h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 12h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 13h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 14h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 15h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 16h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 17h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 18h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 19h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Ah - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Bh - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Ch - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Dh - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Eh - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Fh - Clear keyboard strobe
		Dw	Cassette_Toggle ; Location 20h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 21h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 22h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 23h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 24h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 25h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 26h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 27h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 28h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 29h - Cassette output toggle
		Dw	Cassette_Toggle ; Location 2Ah - Cassette output toggle
		Dw	Cassette_Toggle ; Location 2Bh - Cassette output toggle
		Dw	Cassette_Toggle ; Location 2Ch - Cassette output toggle
		Dw	Cassette_Toggle ; Location 2Dh - Cassette output toggle
		Dw	Cassette_Toggle ; Location 2Eh - Cassette output toggle
		Dw	Cassette_Toggle ; Location 2Fh - Cassette output toggle
		Dw	Speaker_Toggle	; Location 30h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 31h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 32h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 33h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 34h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 35h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 36h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 37h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 38h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 39h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Ah - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Bh - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Ch - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Dh - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Eh - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Fh - Speaker output toggle
		Dw	Utility_Strobe	; Location 40h - Utility output strobe
		Dw	Utility_Strobe	; Location 41h - Utility output strobe
		Dw	Utility_Strobe	; Location 42h - Utility output strobe
		Dw	Utility_Strobe	; Location 43h - Utility output strobe
		Dw	Utility_Strobe	; Location 44h - Utility output strobe
		Dw	Utility_Strobe	; Location 45h - Utility output strobe
		Dw	Utility_Strobe	; Location 46h - Utility output strobe
		Dw	Utility_Strobe	; Location 47h - Utility output strobe
		Dw	Utility_Strobe	; Location 48h - Utility output strobe
		Dw	Utility_Strobe	; Location 49h - Utility output strobe
		Dw	Utility_Strobe	; Location 4Ah - Utility output strobe
		Dw	Utility_Strobe	; Location 4Bh - Utility output strobe
		Dw	Utility_Strobe	; Location 4Ch - Utility output strobe
		Dw	Utility_Strobe	; Location 4Dh - Utility output strobe
		Dw	Utility_Strobe	; Location 4Eh - Utility output strobe
		Dw	Utility_Strobe	; Location 4Fh - Utility output strobe
		Dw	0000h		; Location 50h - Text off (Graphics)
		Dw	0000h		; Location 51h - Text on (Text)
		Dw	0000h		; Location 52h - Mixed off
		Dw	0000h		; Location 53h - Mixed on (Text/Graph)
		Dw	0000h		; Location 54h - Select page 1
		Dw	0000h		; Location 55h - Select page 2
		Dw	0000h		; Location 56h - Low res. graphics
		Dw	0000h		; Location 57h - High res. graphics
		Dw	Output_0_Off	; Location 58h - Output 0 Off
		Dw	Output_0_On	; Location 59h - Output 0 On
		Dw	Output_1_Off	; Location 5Ah - Output 1 Off
		Dw	Output_1_On	; Location 5Bh - Output 1 On
		Dw	Output_2_Off	; Location 5Ch - Output 2 Off
		Dw	Output_2_On	; Location 5Dh - Output 2 On
		Dw	Output_3_Off	; Location 5Eh - Output 3 Off
		Dw	Output_3_On	; Location 5Fh - Output 3 On
		Dw	Cassette_Input	; Location 60h - Cassette input
		Dw	Button_1	; Location 61h - Button 1 input
		Dw	Button_2	; Location 62h - Button 2 input
		Dw	Button_3	; Location 63h - Button 3 input
		Dw	Joystick_1	; Location 64h - Joystick 1 input
		Dw	Joystick_2	; Location 65h - Joystick 2 input
		Dw	Joystick_3	; Location 66h - Joystick 3 input
		Dw	Joystick_4	; Location 67h - Joystick 4 input
		Dw	Cassette_Input	; Location 68h - Cassette input
		Dw	Button_1	; Location 69h - Button 1 input
		Dw	Button_2	; Location 6Ah - Button 2 input
		Dw	Button_3	; Location 6Bh - Button 3 input
		Dw	Joystick_1	; Location 6Ch - Joystick 1 input
		Dw	Joystick_2	; Location 6Dh - Joystick 2 input
		Dw	Joystick_3	; Location 6Eh - Joystick 3 input
		Dw	Joystick_4	; Location 6Fh - Joystick 4 input
		Dw	Joystick_Strobe ; Location 70h - Joystick strobe
		Dw	Joystick_Strobe ; Location 71h - Joystick strobe
		Dw	Joystick_Strobe ; Location 72h - Joystick strobe
		Dw	Joystick_Strobe ; Location 73h - Joystick strobe
		Dw	Joystick_Strobe ; Location 74h - Joystick strobe
		Dw	Joystick_Strobe ; Location 75h - Joystick strobe
		Dw	Joystick_Strobe ; Location 76h - Joystick strobe
		Dw	Joystick_Strobe ; Location 77h - Joystick strobe
		Dw	Joystick_Strobe ; Location 78h - Joystick strobe
		Dw	Joystick_Strobe ; Location 79h - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Ah - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Bh - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Ch - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Dh - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Eh - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Fh - Joystick strobe
;******************************************************************************
;
;	Define the I/O Write Table
;
;******************************************************************************
		Even			; Force table to even address
IO_Write_Table	Equ	This Word	; I/O write table
		Dw	Do_Nothing	; Location 00h - Do nothing
		Dw	Do_Nothing	; Location 01h - Do nothing
		Dw	Do_Nothing	; Location 02h - Do nothing
		Dw	Do_Nothing	; Location 03h - Do nothing
		Dw	Do_Nothing	; Location 04h - Do nothing
		Dw	Do_Nothing	; Location 05h - Do nothing
		Dw	Do_Nothing	; Location 06h - Do nothing
		Dw	Do_Nothing	; Location 07h - Do nothing
		Dw	Do_Nothing	; Location 08h - Do nothing
		Dw	Do_Nothing	; Location 09h - Do nothing
		Dw	Do_Nothing	; Location 0Ah - Do nothing
		Dw	Do_Nothing	; Location 0Bh - Do nothing
		Dw	Do_Nothing	; Location 0Ch - Do nothing
		Dw	Do_Nothing	; Location 0Dh - Do nothing
		Dw	Do_Nothing	; Location 0Eh - Do nothing
		Dw	Do_Nothing	; Location 0Fh - Do nothing
		Dw	Clear_Keyboard	; Location 10h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 11h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 12h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 13h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 14h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 15h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 16h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 17h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 18h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 19h - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Ah - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Bh - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Ch - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Dh - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Eh - Clear keyboard strobe
		Dw	Clear_Keyboard	; Location 1Fh - Clear keyboard strobe
		Dw	Do_Nothing	; Location 20h - Do nothing
		Dw	Do_Nothing	; Location 21h - Do nothing
		Dw	Do_Nothing	; Location 22h - Do nothing
		Dw	Do_Nothing	; Location 23h - Do nothing
		Dw	Do_Nothing	; Location 24h - Do nothing
		Dw	Do_Nothing	; Location 25h - Do nothing
		Dw	Do_Nothing	; Location 26h - Do nothing
		Dw	Do_Nothing	; Location 27h - Do nothing
		Dw	Do_Nothing	; Location 28h - Do nothing
		Dw	Do_Nothing	; Location 29h - Do nothing
		Dw	Do_Nothing	; Location 2Ah - Do nothing
		Dw	Do_Nothing	; Location 2Bh - Do nothing
		Dw	Do_Nothing	; Location 2Ch - Do nothing
		Dw	Do_Nothing	; Location 2Dh - Do nothing
		Dw	Do_Nothing	; Location 2Eh - Do nothing
		Dw	Do_Nothing	; Location 2Fh - Do nothing
		Dw	Speaker_Toggle	; Location 30h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 31h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 32h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 33h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 34h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 35h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 36h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 37h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 38h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 39h - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Ah - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Bh - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Ch - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Dh - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Eh - Speaker output toggle
		Dw	Speaker_Toggle	; Location 3Fh - Speaker output toggle
		Dw	Utility_Strobe	; Location 40h - Utility output strobe
		Dw	Utility_Strobe	; Location 41h - Utility output strobe
		Dw	Utility_Strobe	; Location 42h - Utility output strobe
		Dw	Utility_Strobe	; Location 43h - Utility output strobe
		Dw	Utility_Strobe	; Location 44h - Utility output strobe
		Dw	Utility_Strobe	; Location 45h - Utility output strobe
		Dw	Utility_Strobe	; Location 46h - Utility output strobe
		Dw	Utility_Strobe	; Location 47h - Utility output strobe
		Dw	Utility_Strobe	; Location 48h - Utility output strobe
		Dw	Utility_Strobe	; Location 49h - Utility output strobe
		Dw	Utility_Strobe	; Location 4Ah - Utility output strobe
		Dw	Utility_Strobe	; Location 4Bh - Utility output strobe
		Dw	Utility_Strobe	; Location 4Ch - Utility output strobe
		Dw	Utility_Strobe	; Location 4Dh - Utility output strobe
		Dw	Utility_Strobe	; Location 4Eh - Utility output strobe
		Dw	Utility_Strobe	; Location 4Fh - Utility output strobe
		Dw	0000h		; Location 50h - Text off (Graphics)
		Dw	0000h		; Location 51h - Text on (Text)
		Dw	0000h		; Location 52h - Mixed off
		Dw	0000h		; Location 53h - Mixed on (Text/Graph)
		Dw	0000h		; Location 54h - Select page 1
		Dw	0000h		; Location 55h - Select page 2
		Dw	0000h		; Location 56h - Low res. graphics
		Dw	0000h		; Location 57h - High res. graphics
		Dw	Output_0_Off	; Location 58h - Output 0 Off
		Dw	Output_0_On	; Location 59h - Output 0 On
		Dw	Output_1_Off	; Location 5Ah - Output 1 Off
		Dw	Output_1_On	; Location 5Bh - Output 1 On
		Dw	Output_2_Off	; Location 5Ch - Output 2 Off
		Dw	Output_2_On	; Location 5Dh - Output 2 On
		Dw	Output_3_Off	; Location 5Eh - Output 3 Off
		Dw	Output_3_On	; Location 5Fh - Output 3 On
		Dw	Do_Nothing	; Location 60h - Do nothing
		Dw	Do_Nothing	; Location 61h - Do nothing
		Dw	Do_Nothing	; Location 62h - Do nothing
		Dw	Do_Nothing	; Location 63h - Do nothing
		Dw	Do_Nothing	; Location 64h - Do nothing
		Dw	Do_Nothing	; Location 65h - Do nothing
		Dw	Do_Nothing	; Location 66h - Do nothing
		Dw	Do_Nothing	; Location 67h - Do nothing
		Dw	Do_Nothing	; Location 68h - Do nothing
		Dw	Do_Nothing	; Location 69h - Do nothing
		Dw	Do_Nothing	; Location 6Ah - Do nothing
		Dw	Do_Nothing	; Location 6Bh - Do nothing
		Dw	Do_Nothing	; Location 6Ch - Do nothing
		Dw	Do_Nothing	; Location 6Dh - Do nothing
		Dw	Do_Nothing	; Location 6Eh - Do nothing
		Dw	Do_Nothing	; Location 6Fh - Do nothing
		Dw	Joystick_Strobe ; Location 70h - Joystick strobe
		Dw	Joystick_Strobe ; Location 71h - Joystick strobe
		Dw	Joystick_Strobe ; Location 72h - Joystick strobe
		Dw	Joystick_Strobe ; Location 73h - Joystick strobe
		Dw	Joystick_Strobe ; Location 74h - Joystick strobe
		Dw	Joystick_Strobe ; Location 75h - Joystick strobe
		Dw	Joystick_Strobe ; Location 76h - Joystick strobe
		Dw	Joystick_Strobe ; Location 77h - Joystick strobe
		Dw	Joystick_Strobe ; Location 78h - Joystick strobe
		Dw	Joystick_Strobe ; Location 79h - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Ah - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Bh - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Ch - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Dh - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Eh - Joystick strobe
		Dw	Joystick_Strobe ; Location 7Fh - Joystick strobe
;******************************************************************************
;
;	Define the Flag Encoding Table
;
;******************************************************************************
		Even			; Force table to even address
Flag_Encode	Equ	This Byte	; CPU flag encoding table
		Encode	<00000000b>	; Flag value 00000000b encoded
		Encode	<00000001b>	; Flag value 00000001b encoded
		Encode	<00000010b>	; Flag value 00000010b encoded
		Encode	<00000011b>	; Flag value 00000011b encoded
		Encode	<00000100b>	; Flag value 00000100b encoded
		Encode	<00000101b>	; Flag value 00000101b encoded
		Encode	<00000110b>	; Flag value 00000110b encoded
		Encode	<00000111b>	; Flag value 00000111b encoded
		Encode	<00001000b>	; Flag value 00001000b encoded
		Encode	<00001001b>	; Flag value 00001001b encoded
		Encode	<00001010b>	; Flag value 00001010b encoded
		Encode	<00001011b>	; Flag value 00001011b encoded
		Encode	<00001100b>	; Flag value 00001100b encoded
		Encode	<00001101b>	; Flag value 00001101b encoded
		Encode	<00001110b>	; Flag value 00001110b encoded
		Encode	<00001111b>	; Flag value 00001111b encoded
		Encode	<00010000b>	; Flag value 00010000b encoded
		Encode	<00010001b>	; Flag value 00010001b encoded
		Encode	<00010010b>	; Flag value 00010010b encoded
		Encode	<00010011b>	; Flag value 00010011b encoded
		Encode	<00010100b>	; Flag value 00010100b encoded
		Encode	<00010101b>	; Flag value 00010101b encoded
		Encode	<00010110b>	; Flag value 00010110b encoded
		Encode	<00010111b>	; Flag value 00010111b encoded
		Encode	<00011000b>	; Flag value 00011000b encoded
		Encode	<00011001b>	; Flag value 00011001b encoded
		Encode	<00011010b>	; Flag value 00011010b encoded
		Encode	<00011011b>	; Flag value 00011011b encoded
		Encode	<00011100b>	; Flag value 00011100b encoded
		Encode	<00011101b>	; Flag value 00011101b encoded
		Encode	<00011110b>	; Flag value 00011110b encoded
		Encode	<00011111b>	; Flag value 00011111b encoded
		Encode	<00100000b>	; Flag value 00100000b encoded
		Encode	<00100001b>	; Flag value 00100001b encoded
		Encode	<00100010b>	; Flag value 00100010b encoded
		Encode	<00100011b>	; Flag value 00100011b encoded
		Encode	<00100100b>	; Flag value 00100100b encoded
		Encode	<00100101b>	; Flag value 00100101b encoded
		Encode	<00100110b>	; Flag value 00100110b encoded
		Encode	<00100111b>	; Flag value 00100111b encoded
		Encode	<00101000b>	; Flag value 00101000b encoded
		Encode	<00101001b>	; Flag value 00101001b encoded
		Encode	<00101010b>	; Flag value 00101010b encoded
		Encode	<00101011b>	; Flag value 00101011b encoded
		Encode	<00101100b>	; Flag value 00101100b encoded
		Encode	<00101101b>	; Flag value 00101101b encoded
		Encode	<00101110b>	; Flag value 00101110b encoded
		Encode	<00101111b>	; Flag value 00101111b encoded
		Encode	<00110000b>	; Flag value 00110000b encoded
		Encode	<00110001b>	; Flag value 00110001b encoded
		Encode	<00110010b>	; Flag value 00110010b encoded
		Encode	<00110011b>	; Flag value 00110011b encoded
		Encode	<00110100b>	; Flag value 00110100b encoded
		Encode	<00110101b>	; Flag value 00110101b encoded
		Encode	<00110110b>	; Flag value 00110110b encoded
		Encode	<00110111b>	; Flag value 00110111b encoded
		Encode	<00111000b>	; Flag value 00111000b encoded
		Encode	<00111001b>	; Flag value 00111001b encoded
		Encode	<00111010b>	; Flag value 00111010b encoded
		Encode	<00111011b>	; Flag value 00111011b encoded
		Encode	<00111100b>	; Flag value 00111100b encoded
		Encode	<00111101b>	; Flag value 00111101b encoded
		Encode	<00111110b>	; Flag value 00111110b encoded
		Encode	<00111111b>	; Flag value 00111111b encoded
		Encode	<01000000b>	; Flag value 01000000b encoded
		Encode	<01000001b>	; Flag value 01000001b encoded
		Encode	<01000010b>	; Flag value 01000010b encoded
		Encode	<01000011b>	; Flag value 01000011b encoded
		Encode	<01000100b>	; Flag value 01000100b encoded
		Encode	<01000101b>	; Flag value 01000101b encoded
		Encode	<01000110b>	; Flag value 01000110b encoded
		Encode	<01000111b>	; Flag value 01000111b encoded
		Encode	<01001000b>	; Flag value 01001000b encoded
		Encode	<01001001b>	; Flag value 01001001b encoded
		Encode	<01001010b>	; Flag value 01001010b encoded
		Encode	<01001011b>	; Flag value 01001011b encoded
		Encode	<01001100b>	; Flag value 01001100b encoded
		Encode	<01001101b>	; Flag value 01001101b encoded
		Encode	<01001110b>	; Flag value 01001110b encoded
		Encode	<01001111b>	; Flag value 01001111b encoded
		Encode	<01010000b>	; Flag value 01010000b encoded
		Encode	<01010001b>	; Flag value 01010001b encoded
		Encode	<01010010b>	; Flag value 01010010b encoded
		Encode	<01010011b>	; Flag value 01010011b encoded
		Encode	<01010100b>	; Flag value 01010100b encoded
		Encode	<01010101b>	; Flag value 01010101b encoded
		Encode	<01010110b>	; Flag value 01010110b encoded
		Encode	<01010111b>	; Flag value 01010111b encoded
		Encode	<01011000b>	; Flag value 01011000b encoded
		Encode	<01011001b>	; Flag value 01011001b encoded
		Encode	<01011010b>	; Flag value 01011010b encoded
		Encode	<01011011b>	; Flag value 01011011b encoded
		Encode	<01011100b>	; Flag value 01011100b encoded
		Encode	<01011101b>	; Flag value 01011101b encoded
		Encode	<01011110b>	; Flag value 01011110b encoded
		Encode	<01011111b>	; Flag value 01011111b encoded
		Encode	<01100000b>	; Flag value 01100000b encoded
		Encode	<01100001b>	; Flag value 01100001b encoded
		Encode	<01100010b>	; Flag value 01100010b encoded
		Encode	<01100011b>	; Flag value 01100011b encoded
		Encode	<01100100b>	; Flag value 01100100b encoded
		Encode	<01100101b>	; Flag value 01100101b encoded
		Encode	<01100110b>	; Flag value 01100110b encoded
		Encode	<01100111b>	; Flag value 01100111b encoded
		Encode	<01101000b>	; Flag value 01101000b encoded
		Encode	<01101001b>	; Flag value 01101001b encoded
		Encode	<01101010b>	; Flag value 01101010b encoded
		Encode	<01101011b>	; Flag value 01101011b encoded
		Encode	<01101100b>	; Flag value 01101100b encoded
		Encode	<01101101b>	; Flag value 01101101b encoded
		Encode	<01101110b>	; Flag value 01101110b encoded
		Encode	<01101111b>	; Flag value 01101111b encoded
		Encode	<01110000b>	; Flag value 01110000b encoded
		Encode	<01110001b>	; Flag value 01110001b encoded
		Encode	<01110010b>	; Flag value 01110010b encoded
		Encode	<01110011b>	; Flag value 01110011b encoded
		Encode	<01110100b>	; Flag value 01110100b encoded
		Encode	<01110101b>	; Flag value 01110101b encoded
		Encode	<01110110b>	; Flag value 01110110b encoded
		Encode	<01110111b>	; Flag value 01110111b encoded
		Encode	<01111000b>	; Flag value 01111000b encoded
		Encode	<01111001b>	; Flag value 01111001b encoded
		Encode	<01111010b>	; Flag value 01111010b encoded
		Encode	<01111011b>	; Flag value 01111011b encoded
		Encode	<01111100b>	; Flag value 01111100b encoded
		Encode	<01111101b>	; Flag value 01111101b encoded
		Encode	<01111110b>	; Flag value 01111110b encoded
		Encode	<01111111b>	; Flag value 01111111b encoded
		Encode	<10000000b>	; Flag value 10000000b encoded
		Encode	<10000001b>	; Flag value 10000001b encoded
		Encode	<10000010b>	; Flag value 10000010b encoded
		Encode	<10000011b>	; Flag value 10000011b encoded
		Encode	<10000100b>	; Flag value 10000100b encoded
		Encode	<10000101b>	; Flag value 10000101b encoded
		Encode	<10000110b>	; Flag value 10000110b encoded
		Encode	<10000111b>	; Flag value 10000111b encoded
		Encode	<10001000b>	; Flag value 10001000b encoded
		Encode	<10001001b>	; Flag value 10001001b encoded
		Encode	<10001010b>	; Flag value 10001010b encoded
		Encode	<10001011b>	; Flag value 10001011b encoded
		Encode	<10001100b>	; Flag value 10001100b encoded
		Encode	<10001101b>	; Flag value 10001101b encoded
		Encode	<10001110b>	; Flag value 10001110b encoded
		Encode	<10001111b>	; Flag value 10001111b encoded
		Encode	<10010000b>	; Flag value 10010000b encoded
		Encode	<10010001b>	; Flag value 10010001b encoded
		Encode	<10010010b>	; Flag value 10010010b encoded
		Encode	<10010011b>	; Flag value 10010011b encoded
		Encode	<10010100b>	; Flag value 10010100b encoded
		Encode	<10010101b>	; Flag value 10010101b encoded
		Encode	<10010110b>	; Flag value 10010110b encoded
		Encode	<10010111b>	; Flag value 10010111b encoded
		Encode	<10011000b>	; Flag value 10011000b encoded
		Encode	<10011001b>	; Flag value 10011001b encoded
		Encode	<10011010b>	; Flag value 10011010b encoded
		Encode	<10011011b>	; Flag value 10011011b encoded
		Encode	<10011100b>	; Flag value 10011100b encoded
		Encode	<10011101b>	; Flag value 10011101b encoded
		Encode	<10011110b>	; Flag value 10011110b encoded
		Encode	<10011111b>	; Flag value 10011111b encoded
		Encode	<10100000b>	; Flag value 10100000b encoded
		Encode	<10100001b>	; Flag value 10100001b encoded
		Encode	<10100010b>	; Flag value 10100010b encoded
		Encode	<10100011b>	; Flag value 10100011b encoded
		Encode	<10100100b>	; Flag value 10100100b encoded
		Encode	<10100101b>	; Flag value 10100101b encoded
		Encode	<10100110b>	; Flag value 10100110b encoded
		Encode	<10100111b>	; Flag value 10100111b encoded
		Encode	<10101000b>	; Flag value 10101000b encoded
		Encode	<10101001b>	; Flag value 10101001b encoded
		Encode	<10101010b>	; Flag value 10101010b encoded
		Encode	<10101011b>	; Flag value 10101011b encoded
		Encode	<10101100b>	; Flag value 10101100b encoded
		Encode	<10101101b>	; Flag value 10101101b encoded
		Encode	<10101110b>	; Flag value 10101110b encoded
		Encode	<10101111b>	; Flag value 10101111b encoded
		Encode	<10110000b>	; Flag value 10110000b encoded
		Encode	<10110001b>	; Flag value 10110001b encoded
		Encode	<10110010b>	; Flag value 10110010b encoded
		Encode	<10110011b>	; Flag value 10110011b encoded
		Encode	<10110100b>	; Flag value 10110100b encoded
		Encode	<10110101b>	; Flag value 10110101b encoded
		Encode	<10110110b>	; Flag value 10110110b encoded
		Encode	<10110111b>	; Flag value 10110111b encoded
		Encode	<10111000b>	; Flag value 10111000b encoded
		Encode	<10111001b>	; Flag value 10111001b encoded
		Encode	<10111010b>	; Flag value 10111010b encoded
		Encode	<10111011b>	; Flag value 10111011b encoded
		Encode	<10111100b>	; Flag value 10111100b encoded
		Encode	<10111101b>	; Flag value 10111101b encoded
		Encode	<10111110b>	; Flag value 10111110b encoded
		Encode	<10111111b>	; Flag value 10111111b encoded
		Encode	<11000000b>	; Flag value 11000000b encoded
		Encode	<11000001b>	; Flag value 11000001b encoded
		Encode	<11000010b>	; Flag value 11000010b encoded
		Encode	<11000011b>	; Flag value 11000011b encoded
		Encode	<11000100b>	; Flag value 11000100b encoded
		Encode	<11000101b>	; Flag value 11000101b encoded
		Encode	<11000110b>	; Flag value 11000110b encoded
		Encode	<11000111b>	; Flag value 11000111b encoded
		Encode	<11001000b>	; Flag value 11001000b encoded
		Encode	<11001001b>	; Flag value 11001001b encoded
		Encode	<11001010b>	; Flag value 11001010b encoded
		Encode	<11001011b>	; Flag value 11001011b encoded
		Encode	<11001100b>	; Flag value 11001100b encoded
		Encode	<11001101b>	; Flag value 11001101b encoded
		Encode	<11001110b>	; Flag value 11001110b encoded
		Encode	<11001111b>	; Flag value 11001111b encoded
		Encode	<11010000b>	; Flag value 11010000b encoded
		Encode	<11010001b>	; Flag value 11010001b encoded
		Encode	<11010010b>	; Flag value 11010010b encoded
		Encode	<11010011b>	; Flag value 11010011b encoded
		Encode	<11010100b>	; Flag value 11010100b encoded
		Encode	<11010101b>	; Flag value 11010101b encoded
		Encode	<11010110b>	; Flag value 11010110b encoded
		Encode	<11010111b>	; Flag value 11010111b encoded
		Encode	<11011000b>	; Flag value 11011000b encoded
		Encode	<11011001b>	; Flag value 11011001b encoded
		Encode	<11011010b>	; Flag value 11011010b encoded
		Encode	<11011011b>	; Flag value 11011011b encoded
		Encode	<11011100b>	; Flag value 11011100b encoded
		Encode	<11011101b>	; Flag value 11011101b encoded
		Encode	<11011110b>	; Flag value 11011110b encoded
		Encode	<11011111b>	; Flag value 11011111b encoded
		Encode	<11100000b>	; Flag value 11100000b encoded
		Encode	<11100001b>	; Flag value 11100001b encoded
		Encode	<11100010b>	; Flag value 11100010b encoded
		Encode	<11100011b>	; Flag value 11100011b encoded
		Encode	<11100100b>	; Flag value 11100100b encoded
		Encode	<11100101b>	; Flag value 11100101b encoded
		Encode	<11100110b>	; Flag value 11100110b encoded
		Encode	<11100111b>	; Flag value 11100111b encoded
		Encode	<11101000b>	; Flag value 11101000b encoded
		Encode	<11101001b>	; Flag value 11101001b encoded
		Encode	<11101010b>	; Flag value 11101010b encoded
		Encode	<11101011b>	; Flag value 11101011b encoded
		Encode	<11101100b>	; Flag value 11101100b encoded
		Encode	<11101101b>	; Flag value 11101101b encoded
		Encode	<11101110b>	; Flag value 11101110b encoded
		Encode	<11101111b>	; Flag value 11101111b encoded
		Encode	<11110000b>	; Flag value 11110000b encoded
		Encode	<11110001b>	; Flag value 11110001b encoded
		Encode	<11110010b>	; Flag value 11110010b encoded
		Encode	<11110011b>	; Flag value 11110011b encoded
		Encode	<11110100b>	; Flag value 11110100b encoded
		Encode	<11110101b>	; Flag value 11110101b encoded
		Encode	<11110110b>	; Flag value 11110110b encoded
		Encode	<11110111b>	; Flag value 11110111b encoded
		Encode	<11111000b>	; Flag value 11111000b encoded
		Encode	<11111001b>	; Flag value 11111001b encoded
		Encode	<11111010b>	; Flag value 11111010b encoded
		Encode	<11111011b>	; Flag value 11111011b encoded
		Encode	<11111100b>	; Flag value 11111100b encoded
		Encode	<11111101b>	; Flag value 11111101b encoded
		Encode	<11111110b>	; Flag value 11111110b encoded
		Encode	<11111111b>	; Flag value 11111111b encoded
;******************************************************************************
;
;	Define the Flag Decoding Table
;
;******************************************************************************
		Even			; Force table to even address
Flag_Decode	Equ	This Byte	; CPU flag decoding table
		Decode	<00000000b>	; Flag value 00000000b decoded
		Decode	<00000001b>	; Flag value 00000001b decoded
		Decode	<00000010b>	; Flag value 00000010b decoded
		Decode	<00000011b>	; Flag value 00000011b decoded
		Decode	<00000100b>	; Flag value 00000100b decoded
		Decode	<00000101b>	; Flag value 00000101b decoded
		Decode	<00000110b>	; Flag value 00000110b decoded
		Decode	<00000111b>	; Flag value 00000111b decoded
		Decode	<00001000b>	; Flag value 00001000b decoded
		Decode	<00001001b>	; Flag value 00001001b decoded
		Decode	<00001010b>	; Flag value 00001010b decoded
		Decode	<00001011b>	; Flag value 00001011b decoded
		Decode	<00001100b>	; Flag value 00001100b decoded
		Decode	<00001101b>	; Flag value 00001101b decoded
		Decode	<00001110b>	; Flag value 00001110b decoded
		Decode	<00001111b>	; Flag value 00001111b decoded
		Decode	<00010000b>	; Flag value 00010000b decoded
		Decode	<00010001b>	; Flag value 00010001b decoded
		Decode	<00010010b>	; Flag value 00010010b decoded
		Decode	<00010011b>	; Flag value 00010011b decoded
		Decode	<00010100b>	; Flag value 00010100b decoded
		Decode	<00010101b>	; Flag value 00010101b decoded
		Decode	<00010110b>	; Flag value 00010110b decoded
		Decode	<00010111b>	; Flag value 00010111b decoded
		Decode	<00011000b>	; Flag value 00011000b decoded
		Decode	<00011001b>	; Flag value 00011001b decoded
		Decode	<00011010b>	; Flag value 00011010b decoded
		Decode	<00011011b>	; Flag value 00011011b decoded
		Decode	<00011100b>	; Flag value 00011100b decoded
		Decode	<00011101b>	; Flag value 00011101b decoded
		Decode	<00011110b>	; Flag value 00011110b decoded
		Decode	<00011111b>	; Flag value 00011111b decoded
		Decode	<00100000b>	; Flag value 00100000b decoded
		Decode	<00100001b>	; Flag value 00100001b decoded
		Decode	<00100010b>	; Flag value 00100010b decoded
		Decode	<00100011b>	; Flag value 00100011b decoded
		Decode	<00100100b>	; Flag value 00100100b decoded
		Decode	<00100101b>	; Flag value 00100101b decoded
		Decode	<00100110b>	; Flag value 00100110b decoded
		Decode	<00100111b>	; Flag value 00100111b decoded
		Decode	<00101000b>	; Flag value 00101000b decoded
		Decode	<00101001b>	; Flag value 00101001b decoded
		Decode	<00101010b>	; Flag value 00101010b decoded
		Decode	<00101011b>	; Flag value 00101011b decoded
		Decode	<00101100b>	; Flag value 00101100b decoded
		Decode	<00101101b>	; Flag value 00101101b decoded
		Decode	<00101110b>	; Flag value 00101110b decoded
		Decode	<00101111b>	; Flag value 00101111b decoded
		Decode	<00110000b>	; Flag value 00110000b decoded
		Decode	<00110001b>	; Flag value 00110001b decoded
		Decode	<00110010b>	; Flag value 00110010b decoded
		Decode	<00110011b>	; Flag value 00110011b decoded
		Decode	<00110100b>	; Flag value 00110100b decoded
		Decode	<00110101b>	; Flag value 00110101b decoded
		Decode	<00110110b>	; Flag value 00110110b decoded
		Decode	<00110111b>	; Flag value 00110111b decoded
		Decode	<00111000b>	; Flag value 00111000b decoded
		Decode	<00111001b>	; Flag value 00111001b decoded
		Decode	<00111010b>	; Flag value 00111010b decoded
		Decode	<00111011b>	; Flag value 00111011b decoded
		Decode	<00111100b>	; Flag value 00111100b decoded
		Decode	<00111101b>	; Flag value 00111101b decoded
		Decode	<00111110b>	; Flag value 00111110b decoded
		Decode	<00111111b>	; Flag value 00111111b decoded
		Decode	<01000000b>	; Flag value 01000000b decoded
		Decode	<01000001b>	; Flag value 01000001b decoded
		Decode	<01000010b>	; Flag value 01000010b decoded
		Decode	<01000011b>	; Flag value 01000011b decoded
		Decode	<01000100b>	; Flag value 01000100b decoded
		Decode	<01000101b>	; Flag value 01000101b decoded
		Decode	<01000110b>	; Flag value 01000110b decoded
		Decode	<01000111b>	; Flag value 01000111b decoded
		Decode	<01001000b>	; Flag value 01001000b decoded
		Decode	<01001001b>	; Flag value 01001001b decoded
		Decode	<01001010b>	; Flag value 01001010b decoded
		Decode	<01001011b>	; Flag value 01001011b decoded
		Decode	<01001100b>	; Flag value 01001100b decoded
		Decode	<01001101b>	; Flag value 01001101b decoded
		Decode	<01001110b>	; Flag value 01001110b decoded
		Decode	<01001111b>	; Flag value 01001111b decoded
		Decode	<01010000b>	; Flag value 01010000b decoded
		Decode	<01010001b>	; Flag value 01010001b decoded
		Decode	<01010010b>	; Flag value 01010010b decoded
		Decode	<01010011b>	; Flag value 01010011b decoded
		Decode	<01010100b>	; Flag value 01010100b decoded
		Decode	<01010101b>	; Flag value 01010101b decoded
		Decode	<01010110b>	; Flag value 01010110b decoded
		Decode	<01010111b>	; Flag value 01010111b decoded
		Decode	<01011000b>	; Flag value 01011000b decoded
		Decode	<01011001b>	; Flag value 01011001b decoded
		Decode	<01011010b>	; Flag value 01011010b decoded
		Decode	<01011011b>	; Flag value 01011011b decoded
		Decode	<01011100b>	; Flag value 01011100b decoded
		Decode	<01011101b>	; Flag value 01011101b decoded
		Decode	<01011110b>	; Flag value 01011110b decoded
		Decode	<01011111b>	; Flag value 01011111b decoded
		Decode	<01100000b>	; Flag value 01100000b decoded
		Decode	<01100001b>	; Flag value 01100001b decoded
		Decode	<01100010b>	; Flag value 01100010b decoded
		Decode	<01100011b>	; Flag value 01100011b decoded
		Decode	<01100100b>	; Flag value 01100100b decoded
		Decode	<01100101b>	; Flag value 01100101b decoded
		Decode	<01100110b>	; Flag value 01100110b decoded
		Decode	<01100111b>	; Flag value 01100111b decoded
		Decode	<01101000b>	; Flag value 01101000b decoded
		Decode	<01101001b>	; Flag value 01101001b decoded
		Decode	<01101010b>	; Flag value 01101010b decoded
		Decode	<01101011b>	; Flag value 01101011b decoded
		Decode	<01101100b>	; Flag value 01101100b decoded
		Decode	<01101101b>	; Flag value 01101101b decoded
		Decode	<01101110b>	; Flag value 01101110b decoded
		Decode	<01101111b>	; Flag value 01101111b decoded
		Decode	<01110000b>	; Flag value 01110000b decoded
		Decode	<01110001b>	; Flag value 01110001b decoded
		Decode	<01110010b>	; Flag value 01110010b decoded
		Decode	<01110011b>	; Flag value 01110011b decoded
		Decode	<01110100b>	; Flag value 01110100b decoded
		Decode	<01110101b>	; Flag value 01110101b decoded
		Decode	<01110110b>	; Flag value 01110110b decoded
		Decode	<01110111b>	; Flag value 01110111b decoded
		Decode	<01111000b>	; Flag value 01111000b decoded
		Decode	<01111001b>	; Flag value 01111001b decoded
		Decode	<01111010b>	; Flag value 01111010b decoded
		Decode	<01111011b>	; Flag value 01111011b decoded
		Decode	<01111100b>	; Flag value 01111100b decoded
		Decode	<01111101b>	; Flag value 01111101b decoded
		Decode	<01111110b>	; Flag value 01111110b decoded
		Decode	<01111111b>	; Flag value 01111111b decoded
		Decode	<10000000b>	; Flag value 10000000b decoded
		Decode	<10000001b>	; Flag value 10000001b decoded
		Decode	<10000010b>	; Flag value 10000010b decoded
		Decode	<10000011b>	; Flag value 10000011b decoded
		Decode	<10000100b>	; Flag value 10000100b decoded
		Decode	<10000101b>	; Flag value 10000101b decoded
		Decode	<10000110b>	; Flag value 10000110b decoded
		Decode	<10000111b>	; Flag value 10000111b decoded
		Decode	<10001000b>	; Flag value 10001000b decoded
		Decode	<10001001b>	; Flag value 10001001b decoded
		Decode	<10001010b>	; Flag value 10001010b decoded
		Decode	<10001011b>	; Flag value 10001011b decoded
		Decode	<10001100b>	; Flag value 10001100b decoded
		Decode	<10001101b>	; Flag value 10001101b decoded
		Decode	<10001110b>	; Flag value 10001110b decoded
		Decode	<10001111b>	; Flag value 10001111b decoded
		Decode	<10010000b>	; Flag value 10010000b decoded
		Decode	<10010001b>	; Flag value 10010001b decoded
		Decode	<10010010b>	; Flag value 10010010b decoded
		Decode	<10010011b>	; Flag value 10010011b decoded
		Decode	<10010100b>	; Flag value 10010100b decoded
		Decode	<10010101b>	; Flag value 10010101b decoded
		Decode	<10010110b>	; Flag value 10010110b decoded
		Decode	<10010111b>	; Flag value 10010111b decoded
		Decode	<10011000b>	; Flag value 10011000b decoded
		Decode	<10011001b>	; Flag value 10011001b decoded
		Decode	<10011010b>	; Flag value 10011010b decoded
		Decode	<10011011b>	; Flag value 10011011b decoded
		Decode	<10011100b>	; Flag value 10011100b decoded
		Decode	<10011101b>	; Flag value 10011101b decoded
		Decode	<10011110b>	; Flag value 10011110b decoded
		Decode	<10011111b>	; Flag value 10011111b decoded
		Decode	<10100000b>	; Flag value 10100000b decoded
		Decode	<10100001b>	; Flag value 10100001b decoded
		Decode	<10100010b>	; Flag value 10100010b decoded
		Decode	<10100011b>	; Flag value 10100011b decoded
		Decode	<10100100b>	; Flag value 10100100b decoded
		Decode	<10100101b>	; Flag value 10100101b decoded
		Decode	<10100110b>	; Flag value 10100110b decoded
		Decode	<10100111b>	; Flag value 10100111b decoded
		Decode	<10101000b>	; Flag value 10101000b decoded
		Decode	<10101001b>	; Flag value 10101001b decoded
		Decode	<10101010b>	; Flag value 10101010b decoded
		Decode	<10101011b>	; Flag value 10101011b decoded
		Decode	<10101100b>	; Flag value 10101100b decoded
		Decode	<10101101b>	; Flag value 10101101b decoded
		Decode	<10101110b>	; Flag value 10101110b decoded
		Decode	<10101111b>	; Flag value 10101111b decoded
		Decode	<10110000b>	; Flag value 10110000b decoded
		Decode	<10110001b>	; Flag value 10110001b decoded
		Decode	<10110010b>	; Flag value 10110010b decoded
		Decode	<10110011b>	; Flag value 10110011b decoded
		Decode	<10110100b>	; Flag value 10110100b decoded
		Decode	<10110101b>	; Flag value 10110101b decoded
		Decode	<10110110b>	; Flag value 10110110b decoded
		Decode	<10110111b>	; Flag value 10110111b decoded
		Decode	<10111000b>	; Flag value 10111000b decoded
		Decode	<10111001b>	; Flag value 10111001b decoded
		Decode	<10111010b>	; Flag value 10111010b decoded
		Decode	<10111011b>	; Flag value 10111011b decoded
		Decode	<10111100b>	; Flag value 10111100b decoded
		Decode	<10111101b>	; Flag value 10111101b decoded
		Decode	<10111110b>	; Flag value 10111110b decoded
		Decode	<10111111b>	; Flag value 10111111b decoded
		Decode	<11000000b>	; Flag value 11000000b decoded
		Decode	<11000001b>	; Flag value 11000001b decoded
		Decode	<11000010b>	; Flag value 11000010b decoded
		Decode	<11000011b>	; Flag value 11000011b decoded
		Decode	<11000100b>	; Flag value 11000100b decoded
		Decode	<11000101b>	; Flag value 11000101b decoded
		Decode	<11000110b>	; Flag value 11000110b decoded
		Decode	<11000111b>	; Flag value 11000111b decoded
		Decode	<11001000b>	; Flag value 11001000b decoded
		Decode	<11001001b>	; Flag value 11001001b decoded
		Decode	<11001010b>	; Flag value 11001010b decoded
		Decode	<11001011b>	; Flag value 11001011b decoded
		Decode	<11001100b>	; Flag value 11001100b decoded
		Decode	<11001101b>	; Flag value 11001101b decoded
		Decode	<11001110b>	; Flag value 11001110b decoded
		Decode	<11001111b>	; Flag value 11001111b decoded
		Decode	<11010000b>	; Flag value 11010000b decoded
		Decode	<11010001b>	; Flag value 11010001b decoded
		Decode	<11010010b>	; Flag value 11010010b decoded
		Decode	<11010011b>	; Flag value 11010011b decoded
		Decode	<11010100b>	; Flag value 11010100b decoded
		Decode	<11010101b>	; Flag value 11010101b decoded
		Decode	<11010110b>	; Flag value 11010110b decoded
		Decode	<11010111b>	; Flag value 11010111b decoded
		Decode	<11011000b>	; Flag value 11011000b decoded
		Decode	<11011001b>	; Flag value 11011001b decoded
		Decode	<11011010b>	; Flag value 11011010b decoded
		Decode	<11011011b>	; Flag value 11011011b decoded
		Decode	<11011100b>	; Flag value 11011100b decoded
		Decode	<11011101b>	; Flag value 11011101b decoded
		Decode	<11011110b>	; Flag value 11011110b decoded
		Decode	<11011111b>	; Flag value 11011111b decoded
		Decode	<11100000b>	; Flag value 11100000b decoded
		Decode	<11100001b>	; Flag value 11100001b decoded
		Decode	<11100010b>	; Flag value 11100010b decoded
		Decode	<11100011b>	; Flag value 11100011b decoded
		Decode	<11100100b>	; Flag value 11100100b decoded
		Decode	<11100101b>	; Flag value 11100101b decoded
		Decode	<11100110b>	; Flag value 11100110b decoded
		Decode	<11100111b>	; Flag value 11100111b decoded
		Decode	<11101000b>	; Flag value 11101000b decoded
		Decode	<11101001b>	; Flag value 11101001b decoded
		Decode	<11101010b>	; Flag value 11101010b decoded
		Decode	<11101011b>	; Flag value 11101011b decoded
		Decode	<11101100b>	; Flag value 11101100b decoded
		Decode	<11101101b>	; Flag value 11101101b decoded
		Decode	<11101110b>	; Flag value 11101110b decoded
		Decode	<11101111b>	; Flag value 11101111b decoded
		Decode	<11110000b>	; Flag value 11110000b decoded
		Decode	<11110001b>	; Flag value 11110001b decoded
		Decode	<11110010b>	; Flag value 11110010b decoded
		Decode	<11110011b>	; Flag value 11110011b decoded
		Decode	<11110100b>	; Flag value 11110100b decoded
		Decode	<11110101b>	; Flag value 11110101b decoded
		Decode	<11110110b>	; Flag value 11110110b decoded
		Decode	<11110111b>	; Flag value 11110111b decoded
		Decode	<11111000b>	; Flag value 11111000b decoded
		Decode	<11111001b>	; Flag value 11111001b decoded
		Decode	<11111010b>	; Flag value 11111010b decoded
		Decode	<11111011b>	; Flag value 11111011b decoded
		Decode	<11111100b>	; Flag value 11111100b decoded
		Decode	<11111101b>	; Flag value 11111101b decoded
		Decode	<11111110b>	; Flag value 11111110b decoded
		Decode	<11111111b>	; Flag value 11111111b decoded
;******************************************************************************
;
;	Define the Apple ROM Data File
;
;******************************************************************************
System_ROM	Db	"Apple.ROM",0   ; Apple system ROM data file
Disk_ROM	Db	"Disk.ROM",0    ; Apple disk controller ROM data file
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
;	 | | | ---------------> ***** Reserved *****
;	 | | -----------------> ***** Reserved *****
;	 | -------------------> ***** Reserved *****
;	 ---------------------> ***** Reserved *****
;
;******************************************************************************
		Even			; Force byte to even address
System_Flag	Db	00h		; System flag byte
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
		Even			; Force byte to even address
Video_Flag	Db	0E1h		; Video flag byte (Graphics Mode)
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
		Even			; Force byte to even address
Emulate_Flag	Db	00h		; Emulator flag byte
;******************************************************************************
;
;	Define the interrupt vector save area
;
;******************************************************************************
		Even			; Force dwords to even address
Original_Int_8	Dd	?		; Original interrupt 8 (Timer) vector
Original_Int_9	Dd	?		; Original interrupt 9 (Keyboard) vector
;******************************************************************************
;
;	Define all other needed data values
;
;******************************************************************************
		Even			; Force byte to even address
Current_Slot	Db	SLOT_MAX	; Current active expansion slot
RAM_Space	Dw	(?)		; RAM space segment save area
ALT_Space	Dw	(?)		; Alternate RAM space segment save area
;******************************************************************************
;
;	Define the end of the Apple Emulator Code Segment
;
;******************************************************************************
Emulate Ends
	End				; End of the data module

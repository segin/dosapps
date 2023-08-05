	.Xlist
	Page	58,132
	Subttl	STRUCS.INC	Apple Emulator (65C02 Processor)
;******************************************************************************
;
;   Name:	STRUCS		Apple Emulator (65C02 Processor)
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
;		This module contains all the structures needed by the
;	Apple emulator. This module can be included with any needed
;	source files to define the Apple emulator structures.
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
Slot_Data	Struc				; Slot data pointer structure
Slot_0		Dw	(?)			; Slot 0 data pointer
Slot_1		Dw	(?)			; Slot 1 data pointer
Slot_2		Dw	(?)			; Slot 2 data pointer
Slot_3		Dw	(?)			; Slot 3 data pointer
Slot_4		Dw	(?)			; Slot 4 data pointer
Slot_5		Dw	(?)			; Slot 5 data pointer
Slot_6		Dw	(?)			; Slot 6 data pointer
Slot_7		Dw	(?)			; Slot 7 data pointer
Slot_Data	Ends				; End of Slot_Data structure
;******************************************************************************
;
;	Define the language card structure
;
;******************************************************************************
Lang_Card	Struc				; Language card structure
Lang_Byte	Db	(?)			; Language card control byte
Lang_Flag	Db	(?)			; Language card flag byte
Lang_Reserved	Db	14 Dup (?)		; Language card reserved area
Lang_Card	Ends				; End of Lang_Card structure
;******************************************************************************
;
;	Define the language card data area structure
;
;******************************************************************************
Lang_Card_Data	Struc				; Language card data structure
Lang_Area	Db	16 Dup (?)		; Language card control area
Seg_1_Bank_1	Db	4096 Dup (?)		; Lang. card segment 1 bank 1
Seg_1_Bank_2	Db	4096 Dup (?)		; Lang. card segment 1 bank 2
Seg_1_RAM	Db	8192 Dup (?)		; Lang. card segment 1 RAM
Seg_2_Bank_1	Db	4096 Dup (?)		; Lang. card segment 2 bank 1
Seg_2_Bank_2	Db	4096 Dup (?)		; Lang. card segment 2 bank 2
Seg_2_RAM	Db	8192 Dup (?)		; Lang. card segment 2 RAM
Lang_Card_Data	Ends				; End Lang_Card_Data structure
;******************************************************************************
;
;	Define the cartridge structure
;
;******************************************************************************
Cartridge	Struc				; Cartridge structure
Cart_File	Db	64 Dup (?)		; Cartridge file name
Cart_Byte	Db	(?)			; Cartridge control byte
Cart_Reserved	Db	15 Dup (?)		; Cartridge reserved area
Cart_Image	Db	32768 Dup (?)		; Cartridge image area
Cartridge	Ends				; End of Cartridge structure
;******************************************************************************
;
;	Define the cartridge file name structure
;
;******************************************************************************
Cart_Name	Struc				; Cartridge file name structure
Cart_Base	Db	"Cart"                  ; Cartridge base file name
Cart_Slot	Db	"x"                     ; Cartridge base slot number
Cart_Ext	Db	".crt",0                ; Cartridge base extension
Cart_Name	Ends				; End of Cart_Name structure
;******************************************************************************
;
;	Define the disk controller structure
;
;******************************************************************************
Disk_Card	Struc				; Disk controller structure
Disk_Current	Dw	(?)			; Disk ctrl. current drive ptr.
Disk_Drive_A	Db	6223 Dup (?)		; Disk drive A structure
Disk_Drive_B	Db	6223 Dup (?)		; Disk drive B structure
Disk_Card	Ends				; End of Disk_Card structure
;******************************************************************************
;
;	Define the disk drive structure
;
;******************************************************************************
Disk_Drive	Struc				; Disk drive structure
Disk_File	Db	64 Dup (?)		; Disk drive file name
Disk_Flag	Db	(?)			; Disk drive flag byte
Disk_Last	Db	(?)			; Disk drive last phase
Disk_Curr	Db	(?)			; Disk drive current phase
Disk_Latch	Db	(?)			; Disk drive write data latch
Disk_Handle	Dw	(?)			; Disk drive handle number
Disk_Pointer	Dw	(?)			; Disk track buffer pointer
Disk_Limit	Dw	(?)			; Disk track pointer limit
Disk_Track	Dw	(?)			; Disk track size
Disk_Sector	Db	(?)			; Disk sector size (13/16)
Disk_Reserved	Db	2 Dup (?)		; Disk drive reserved area
Disk_Buffer	Db	6144 Dup (?)		; Disk drive track buffer
Disk_Drive	Ends				; End of Disk_Drive structure
;******************************************************************************
;
;	Define the base drive disk file name structure
;
;******************************************************************************
Disk_Name	Struc				; Disk file name structure
Disk_Base	Db	"Disk"                  ; Disk drive base file name
Disk_Slot	Db	"x"                     ; Disk drive base slot number
Disk_Letter	Db	"y"                     ; Disk drive base drive letter
Disk_Ext	Db	".dsk",0                ; Disk drive base extension
Disk_Name	Ends				; End of Disk_Name structure
;******************************************************************************
;
;	Define the unencrypted track buffer structure (13 Sector Disk)
;
;******************************************************************************
Buffer_13	Struc				; Unencrypted track structure
Buffer_0_13	Db	256 Dup (?)		; Unencrypted sector 0
Buffer_1_13	Db	256 Dup (?)		; Unencrypted sector 1
Buffer_2_13	Db	256 Dup (?)		; Unencrypted sector 2
Buffer_3_13	Db	256 Dup (?)		; Unencrypted sector 3
Buffer_4_13	Db	256 Dup (?)		; Unencrypted sector 4
Buffer_5_13	Db	256 Dup (?)		; Unencrypted sector 5
Buffer_6_13	Db	256 Dup (?)		; Unencrypted sector 6
Buffer_7_13	Db	256 Dup (?)		; Unencrypted sector 7
Buffer_8_13	Db	256 Dup (?)		; Unencrypted sector 8
Buffer_9_13	Db	256 Dup (?)		; Unencrypted sector 9
Buffer_A_13	Db	256 Dup (?)		; Unencrypted sector A
Buffer_B_13	Db	256 Dup (?)		; Unencrypted sector B
Buffer_C_13	Db	256 Dup (?)		; Unencrypted sector C
Buffer_13	Ends				; End of Buffer_13 structure
;******************************************************************************
;
;	Define the unencrypted track buffer structure (16 Sector Disk)
;
;******************************************************************************
Buffer_16	Struc				; Unencrypted track structure
Buffer_0_16	Db	256 Dup (?)		; Unencrypted sector 0
Buffer_1_16	Db	256 Dup (?)		; Unencrypted sector 1
Buffer_2_16	Db	256 Dup (?)		; Unencrypted sector 2
Buffer_3_16	Db	256 Dup (?)		; Unencrypted sector 3
Buffer_4_16	Db	256 Dup (?)		; Unencrypted sector 4
Buffer_5_16	Db	256 Dup (?)		; Unencrypted sector 5
Buffer_6_16	Db	256 Dup (?)		; Unencrypted sector 6
Buffer_7_16	Db	256 Dup (?)		; Unencrypted sector 7
Buffer_8_16	Db	256 Dup (?)		; Unencrypted sector 8
Buffer_9_16	Db	256 Dup (?)		; Unencrypted sector 9
Buffer_A_16	Db	256 Dup (?)		; Unencrypted sector A
Buffer_B_16	Db	256 Dup (?)		; Unencrypted sector B
Buffer_C_16	Db	256 Dup (?)		; Unencrypted sector C
Buffer_D_16	Db	256 Dup (?)		; Unencrypted sector D
Buffer_E_16	Db	256 Dup (?)		; Unencrypted sector E
Buffer_F_16	Db	256 Dup (?)		; Unencrypted sector F
Buffer_16	Ends				; End of Buffer_16 structure
;******************************************************************************
;
;	Define the encrypted track buffer structure (13 Sector Disk)
;
;******************************************************************************
Track_13	Struc				; 13 Sector track structure
Gap_1_13	Db	64 Dup (?)		; 13 Sector disk - Gap 1
Sector_0_13	Db	447 Dup (?)		; 13 Sector disk - Sector 0
Sector_1_13	Db	447 Dup (?)		; 13 Sector disk - Sector 1
Sector_2_13	Db	447 Dup (?)		; 13 Sector disk - Sector 2
Sector_3_13	Db	447 Dup (?)		; 13 Sector disk - Sector 3
Sector_4_13	Db	447 Dup (?)		; 13 Sector disk - Sector 4
Sector_5_13	Db	447 Dup (?)		; 13 Sector disk - Sector 5
Sector_6_13	Db	447 Dup (?)		; 13 Sector disk - Sector 6
Sector_7_13	Db	447 Dup (?)		; 13 Sector disk - Sector 7
Sector_8_13	Db	447 Dup (?)		; 13 Sector disk - Sector 8
Sector_9_13	Db	447 Dup (?)		; 13 Sector disk - Sector 9
Sector_A_13	Db	447 Dup (?)		; 13 Sector disk - Sector A
Sector_B_13	Db	447 Dup (?)		; 13 Sector disk - Sector B
Sector_C_13	Db	447 Dup (?)		; 13 Sector disk - Sector C
Track_13	Ends				; End of Track_13 structure
;******************************************************************************
;
;	Define the encrypted track buffer structure (16 Sector Disk)
;
;******************************************************************************
Track_16	Struc				; 16 Sector track structure
Gap_1_16	Db	64 Dup (?)		; 16 Sector disk - Gap 1
Sector_0_16	Db	379 Dup (?)		; 16 Sector disk - Sector 0
Sector_1_16	Db	379 Dup (?)		; 16 Sector disk - Sector 1
Sector_2_16	Db	379 Dup (?)		; 16 Sector disk - Sector 2
Sector_3_16	Db	379 Dup (?)		; 16 Sector disk - Sector 3
Sector_4_16	Db	379 Dup (?)		; 16 Sector disk - Sector 4
Sector_5_16	Db	379 Dup (?)		; 16 Sector disk - Sector 5
Sector_6_16	Db	379 Dup (?)		; 16 Sector disk - Sector 6
Sector_7_16	Db	379 Dup (?)		; 16 Sector disk - Sector 7
Sector_8_16	Db	379 Dup (?)		; 16 Sector disk - Sector 8
Sector_9_16	Db	379 Dup (?)		; 16 Sector disk - Sector 9
Sector_A_16	Db	379 Dup (?)		; 16 Sector disk - Sector A
Sector_B_16	Db	379 Dup (?)		; 16 Sector disk - Sector B
Sector_C_16	Db	379 Dup (?)		; 16 Sector disk - Sector C
Sector_D_16	Db	379 Dup (?)		; 16 Sector disk - Sector D
Sector_E_16	Db	379 Dup (?)		; 16 Sector disk - Sector E
Sector_F_16	Db	379 Dup (?)		; 16 Sector disk - Sector F
Track_16	Ends				; End of Track_16 structure
;******************************************************************************
;
;	Define the sector structure (13 Sector Disk)
;
;******************************************************************************
Sector_13	Struc				; 13 Sector structure
Prologue_13	Db	3 Dup (?)		; 13 Sector prologue (D5 AA AD)
Data_13 	Db	410 Dup (?)		; 13 Sector data bytes
Checksum_13	Db	1 Dup (?)		; 13 Sector checksum
Epilogue_13	Db	3 Dup (?)		; 13 Sector epilogue (DE AA EB)
Sector_13	Ends				; End of Sector_13 structure
;******************************************************************************
;
;	Define the sector structure (16 Sector Disk)
;
;******************************************************************************
Sector_16	Struc				; 16 Sector structure
Prologue_16	Db	3 Dup (?)		; 16 Sector prologue (D5 AA AD)
Data_16 	Db	342 Dup (?)		; 16 Sector data bytes
Checksum_16	Db	1 Dup (?)		; 16 Sector checksum
Epilogue_16	Db	3 Dup (?)		; 16 Sector epilogue (DE AA EB)
Sector_16	Ends				; End of Sector_16 structure
;******************************************************************************
;
;	Define the address structure (13/16 Sector Disk)
;
;******************************************************************************
Disk_Address	Struc				; Disk track address structure
Prologue	Db	3 Dup (?)		; Address prologue (D5 AA 96)
Volume		Db	2 Dup (?)		; Disk volume number
Track		Db	2 Dup (?)		; Disk track number
Sector		Db	2 Dup (?)		; Disk sector number
Checksum	Db	2 Dup (?)		; Address checksum
Epilogue	Db	2 Dup (?)		; Address epilogue (DE AA EB)
Disk_Address	Ends				; End of Disk_Address structure
;******************************************************************************
;
;	Define the find matching file structure
;
;******************************************************************************
Find_Match	Struc				; Find matching structure
DOS_Reserved	Db	21 Dup (?)		; MS-DOS reserved area
File_Attr	Db	(?)			; File attribute byte
File_Time	Dw	(?)			; File time value
File_Date	Dw	(?)			; File data value
File_Size_Low	Dw	(?)			; File size value (LSW)
File_Size_High	Dw	(?)			; File size value (MSW)
File_Name	Db	13 Dup (?)		; File name/extension/zero byte
Find_Match	Ends				; End of Find_Match structure
;******************************************************************************
;
;	Define the debug opcode structure
;
;******************************************************************************
Opcode		Struc				; Opcode debug structure
Op_Type 	Db	?			; Opcode type value
Op_Address	Db	?			; Opcode addressing type
Opcode		Ends				; End of Opcode structure
;******************************************************************************
;
;	Define the Int_Update stack frame structure
;
;******************************************************************************
Stack_Frame	Struc			; Int_Update stack frame definition
BP_Save 	Dw	?		; Saved BP register value
Return_Address	Dw	?		; Caller return address
AX_Save 	Dw	?		; Saved AX register (From Interrupt)
Current_IP	Dw	?		; Currently executing IP register
Current_CS	Dw	?		; Currently executing CS register
Current_Flag	Dw	?		; Currently executing flag register
Stack_Frame	Ends			; End of stack frame definition
	.List

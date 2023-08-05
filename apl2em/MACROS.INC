	.Xlist
	Page	58,132
	Subttl	MACROS.INC	Apple Emulator (65C02 Processor)
;******************************************************************************
;
;   Name:	MACROS		Apple Emulator (65C02 Processor)
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
;		This module contains all the macros needed by the
;	Apple emulator. This module can be included with any needed
;	source files to define the Apple emulator macros.
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
LineUp	Macro	divide,filler
	.Xlist
	Ifb	<filler>
_fill	=	00h
	Else
_fill	=	filler
	Endif
_addr	=	$ - emulate
_amt	=	_addr MOD divide
	If	_amt NE 0
_amt	=	divide - _amt
	Db	_amt dup (filler)	; Reserved required space to line up
	Endif
	.List
	Endm

String	Macro	Str
_cnt	=	0
	Irpc	x,<Str>
_cnt	=	_cnt + 1
	Endm
	Db	_cnt,Str,0Dh,0Ah	; Define the requested string
	Endm

Err_Str Macro	Name, Str
	Def_Err %_Err_Cnt,Name,<Str>
_Err_Cnt	=	_Err_Cnt + 1
	Endm

Def_Err Macro	Number,Name,Str
ERR_&Name	Equ	&Number 	; Define the error name
	public	ERR_&Name
Error_&Number	Equ	This Word	; Define the error string
	String	<Str>
	Endm

Err_Tbl Macro
Error_Table	Equ	This Word	; Declare start of error table
_Err_Num	=	0
	Rept	_Err_Cnt
		Def_Tbl %_Err_Num
_Err_Num	=	_Err_Num + 1
	Endm
	Endm

Def_Tbl Macro	Number
	Dw	Error_&Number		; Define the error table entry
	Endm

Reverse Macro	String
	.Xlist
_Value	=	00h
_Shift	=	00h
	Irpc	c,<String>
_Value	=	_Value + (c Shl _Shift)
_Shift	=	_Shift + 1
	Endm
	Db	_Value			; Define the reversed value
	.List
	Endm

Color	Macro	String
	.Xlist
_Value	=	00h
	Irpc	c,<String>
_Color	=	00h
		Ifidn	<C>,<B>
_Color	=	00h
		Endif
		Ifidn	<C>,<G>
_Color	=	01h
		Endif
		Ifidn	<C>,<P>
_Color	=	02h
		Endif
_Value	=	(_Value Shl 2) + _Color
	Endm
_Value	=	_Value Shl 2
	Dw	_Value			; Define the color word value
	.List
	Endm

Shift	Record	Word_Shift:4,Byte_Shift:4

Map	Macro	Color_1,Color_2
	Entry	Color_1,%&Color_2
	Endm

Entry	Macro	Apple_Color,IBM_Color
_map_&Apple_Color	Equ	IBM_Color
	Endm

Convert Macro	Background,Foreground
	.Xlist
	Db	_map_&Background Shl 4 + _map_&Foreground
	.List
	Endm

_device_cnt	=	0		; Initialize the device type counter

Device	Macro	Type
	Extrn	&Type&_Init:Near	; Define device initialization routine
	Extrn	&Type&_Ctrl:Near	; Define device control routine
	Extrn	&Type&_Rd:Near		; Define device read routine
	Extrn	&Type&_Wrt:Near 	; Define device write routine
	Extrn	&Type&_Mem_Rd:Near	; Define device memory read routine
	Extrn	&Type&_Mem_Wrt:Near	; Define device memory write routine
	Extrn	&Type&_Exp_Rd:Near	; Define device expansion read routine
	Extrn	&Type&_Exp_Wrt:Near	; Define device expansion write routine
	Extrn	&Type&_ID:Byte		; Define device ID name string
	Declare %_device_cnt,Type	; Declare the device type
_device_cnt	=	_device_cnt + 1 ; Increment the device counter
	Endm

Declare Macro	Number,Type
_dev_&Number&_id	Equ	&Type&_ID
_dev_&Number&_init	Equ	&Type&_Init
_dev_&Number&_ctrl	Equ	&Type&_Ctrl
_dev_&Number&_rd	Equ	&Type&_Rd
_dev_&Number&_wrt	Equ	&Type&_Wrt
_dev_&Number&_mem_rd	Equ	&Type&_Mem_Rd
_dev_&Number&_mem_wrt	Equ	&Type&_Mem_Wrt
_dev_&Number&_exp_rd	Equ	&Type&_Exp_Rd
_dev_&Number&_exp_wrt	Equ	&Type&_Exp_Wrt
	Endm

Slot	Macro	Number,Type
_slot_&Number&_id	Equ	&Type&_ID
_slot_&Number&_init	Equ	&Type&_Init
_slot_&Number&_ctrl	Equ	&Type&_Ctrl
_slot_&Number&_rd	Equ	&Type&_Rd
_slot_&Number&_wrt	Equ	&Type&_Wrt
_slot_&Number&_mem_rd	Equ	&Type&_Mem_Rd
_slot_&Number&_mem_wrt	Equ	&Type&_Mem_Wrt
_slot_&Number&_exp_rd	Equ	&Type&_Exp_Rd
_slot_&Number&_exp_wrt	Equ	&Type&_Exp_Wrt
	Endm

Table	Macro
	.Xlist
Slot_ID 	Equ	This Word	; Define exp. slot ID name table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,id
_cnt	=	_cnt + 1
	Endm
Slot_Init	Equ	This Word	; Define exp. slot initialize table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,init
_cnt	=	_cnt + 1
	Endm
Slot_Ctrl	Equ	This Word	; Define exp. slot control table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,ctrl
_cnt	=	_cnt + 1
	Endm
Slot_Read	Equ	This Word	; Define exp. slot write table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,rd
_cnt	=	_cnt + 1
	Endm
Slot_Write	Equ	This Word	; Define exp. slot read table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,wrt
_cnt	=	_cnt + 1
	Endm
Mem_Read	Equ	This Word	; Define exp. slot memory read table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,mem_rd
_cnt	=	_cnt + 1
	Endm
Mem_Write	Equ	This Word	; Define exp. slot memory write table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,mem_wrt
_cnt	=	_cnt + 1
	Endm
Exp_Read	Equ	This Word	; Define exp. slot ROM/RAM read table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,exp_rd
_cnt	=	_cnt + 1
	Endm
	Dw	Special_Read		; Define the special read routine
Exp_Write	Equ	This Word	; Define exp. slot ROM/RAM write table
_cnt	=	0
	Rept	SLOT_MAX
		Build	slot,%_cnt,exp_wrt
_cnt	=	_cnt + 1
	Endm
	Dw	Special_Write		; Define the special write routine
Device_Table	Equ	This Word	; Define the device table
	Dw	_device_cnt
_cnt	=	0
	Rept	_device_cnt
		Build	dev,%_cnt,id
		Build	dev,%_cnt,init
		Build	dev,%_cnt,ctrl
		Build	dev,%_cnt,rd
		Build	dev,%_cnt,wrt
		Build	dev,%_cnt,mem_rd
		Build	dev,%_cnt,mem_wrt
		Build	dev,%_cnt,exp_rd
		Build	dev,%_cnt,exp_wrt
_cnt	=	_cnt + 1
	Endm
	Endm

Build	Macro	Name,Number,Type
	Dw	_&Name&_&Number&_&Type	  ; Build the table entry
	.List
	Endm

CGA	Macro	String
	.Xlist
_value	=	0
	Irpc	c,<String>
		Ifidn	<c>,<I>
_value	=	_value + 10h
		Endif
		Ifidn	<c>,<r>
_value	=	_value + 04h
		Endif
		Ifidn	<c>,<g>
_value	=	_value + 02h
		Endif
		Ifidn	<c>,<b>
_value	=	_value + 01h
		Endif
	Endm
	Db	_value			; Define the CGA color value
	.List
	Endm

EGA	Macro	String
	.Xlist
_value	=	0
	Irpc	c,<String>
		Ifidn	<c>,<R>
_value	=	_value + 20h
		Endif
		Ifidn	<c>,<G>
_value	=	_value + 10h
		Endif
		Ifidn	<c>,<B>
_value	=	_value + 08h
		Endif
		Ifidn	<c>,<r>
_value	=	_value + 04h
		Endif
		Ifidn	<c>,<g>
_value	=	_value + 02h
		Endif
		Ifidn	<c>,<b>
_value	=	_value + 01h
		Endif
	Endm
	Db	_value			; Define the EGA color value
	.List
	Endm

Encrypt_Byte	Macro
	mov	ah,al			; Move a copy of byte to AH register
	shr	al,1			; Shift byte value into position
	or	ax,1010101010101010b	; Odd/even encrypt the byte value
	Endm

Decrypt_Byte	Macro
	rol	al,1			; Rotate byte value into position
	and	al,ah			; Odd/even decrypt the byte value
	Endm

Encode	Macro	Value
_base	=	Value And 10110101b
_flag_Z =	(Value And 01000000b) Shr 6
_flag_V =	(Value And 00001000b) Shr 3
_flag_M =	(Value And 00000010b) Shr 1
_value	=	_base + (_flag_V Shl 6) + (_flag_M Shl 3) + (_flag_Z Shl 1)
	Db	_value			; Define the encoded byte value
	Endm

Decode	Macro	Value
_base	=	Value And 10110101b
_flag_V =	(Value And 01000000b) Shr 6
_flag_M =	(Value And 00001000b) Shr 3
_flag_Z =	(Value And 00000010b) Shr 1
_value	=	_base + (_flag_Z Shl 6) + (_flag_V Shl 3) + (_flag_M Shl 1)
	Db	_value			; Define the decoded byte value
	Endm

Fill	Macro	Count,Filler
	mov	al,&Filler		; Get the filler byte value
	mov	cx,&Count		; Get the filler byte count
	rep	stosb			; Fill the gap area will filler byte
	Endm

Address Macro	Name, Routine
	If2
		Ifndef	_Address_Count
_Address_Count	=	0
		Endif
TYPE_&Name	=	_Address_Count	; Define the addressing type
_Address_Count	=	_Address_Count + 2
	Endif
	Dw	Routine 		; Define the addressing routine
	Endm

Mnemonic	Macro	Name,String
	If2
		Ifndef	_Mnemonic_Count
_Mnemonic_Count =	0
		Endif
OP_&Name	=	_Mnemonic_Count ; Define the mnemonic opcode
_Mnemonic_Count =	_Mnemonic_Count + 1
	Endif
	Db	String,0		; Define the mnemonic string
	Endm

Save	Macro	a,b,c,d,e,f,g,h,i,j
	.Xlist
	Irp	x,<a,b,c,d,e,f,g,h,i,j>
		Ifnb	<x>
			push	x	; Save the requested register
		Endif
	Endm
	.List
	Endm

Restore Macro	a,b,c,d,e,f,g,h,i,j
	.Xlist
	Irp	x,<j,i,h,g,f,e,d,c,b,a>
		Ifnb	<x>
			pop	x	; Restore the requested register
		Endif
	Endm
	.List
	Endm

Fetch	Macro
	local	_addr
	lodsb				; Load the next opcode byte
	xor	ah,ah			; Convert opcode to full word
	shl	ax,Op_Base		; Convert opcode to address
	mov	di,ax			; Move routine address to DI
	test	dh,CPU_R		; Check for emulator interrupt
	jnz	_addr			; Jump if emulator interrupt request
	jmp	di			; Jump to correct opcode routine
_addr:
	jmp	Interrupt		; Go process the emulator interrupt
	Endm

Setup	Macro
	lodsb				; Load the next opcode byte
	xor	ah,ah			; Convert opcode to full word
	shl	ax,Op_Base		; Convert opcode to address
	mov	di,ax			; Move routine address to DI
	Endm

Flgnz	Macro
	lahf				; Load flags into AH register
	and	ah,CPU_N + CPU_Z	; Mask off all but sign/zero flags
	and	dh,Not (CPU_N + CPU_Z)	; Clear the n and z flags
	or	dh,ah			; Update the 65C02 status flags
	Endm

Flgnzc	Macro
	lahf				; Load flags into AH register
	and	ah,CPU_N + CPU_Z + CPU_C; Mask off all but sign/carry/zero flags
	and	dh,Not (CPU_N + CPU_Z + CPU_C)
	or	dh,ah			; Update the 65C02 status flags
	Endm

Flgnvzc Macro
	pushf				; Push the processor flags
	pop	ax			; Pop flags into AX register
	and	ax,0000100011000001b	; Mask all but overflow/sign/zero/carry
	or	al,ah			; Logically OR in overflow flag
	and	dh,Not (CPU_N + CPU_V + CPU_Z + CPU_C)
	or	dh,al			; Update the 65C02 status flags
	Endm

Push_16 Macro
	dec	bl			; Decrement the stack pointer
	mov	ds:[bx],ax		; Push the 16-bit value
	dec	bl			; Decrement the stack pointer
	Endm

Push_8	Macro
	mov	ds:[bx],al		; Push the 8-bit value
	dec	bl			; Decrement the stack pointer
	Endm

Pop_16	Macro
	inc	bl			; Increment the stack pointer
	mov	ax,ds:[bx]		; Pop the 16-bit value
	inc	bl			; Increment the stack pointer
	Endm

Pop_8	Macro
	inc	bl			; Increment the stack pointer
	mov	al,ds:[bx]		; Pop the 8-bit value
	Endm

DoImm	Macro
_type	=	000h
	mov	di,si			; Setup the effective address
	inc	si			; Update the program counter
	Endm

DoAbs	Macro
_type	=	0FFh
	lodsw				; Get the absolute address
	mov	di,ax			; Setup the effective address
	Endm

DoDP	Macro
_type	=	000h
	lodsb				; Get the direct page offset
	xor	ah,ah			; Convert to direct page address
	mov	di,ax			; Setup the effective address
	Endm

DoDIX	Macro
_type	=	000h
	lodsb				; Get the direct page offset
	add	al,ch			; Add in the X index value
	xor	ah,ah			; Convert to direct page address
	mov	di,ax			; Setup the effective address
	Endm

DoDIY	Macro
_type	=	000h
	lodsb				; Get the direct page offset
	add	al,cl			; Add in the Y index value
	xor	ah,ah			; Convert to direct page address
	mov	di,ax			; Setup the effective address
	Endm

DoAIX	Macro
_type	=	0FFh
	lodsw				; Get the absolute address
	add	al,ch			; Add in the X index value
	adc	ah,0			; Do 16-bit arithmetic
	mov	di,ax			; Setup the effective address
	Endm

DoAIY	Macro
_type	=	0FFh
	lodsw				; Get the absolute address
	add	al,cl			; Add in the Y index value
	adc	ah,0			; Do 16-bit arithmetic
	mov	di,ax			; Setup the effective address
	Endm

DoAI	Macro
_type	=	0FFh
	lodsw				; Get the absolute address
	mov	di,ax			; Setup to do the indirection
	mov	di,ds:[di]		; Setup the effective address
	Endm

DoDI	Macro
_type	=	0FFh
	lodsb				; Get the direct page offset
	xor	ah,ah			; Convert to direct page address
	mov	di,ax			; Setup to do the indirection
	mov	di,ds:[di]		; Setup the effective address
	Endm

DoAIIX	Macro
_type	=	0FFh
	lodsw				; Get the absolute address
	add	al,ch			; Add in the X index value
	adc	ah,0			; Do 16-bit arithmetic
	mov	di,ax			; Setup to do the indirection
	mov	di,ds:[di]		; Setup the effective address
	Endm

DoDIIX	Macro
_type	=	0FFh
	lodsb				; Get the direct page offset
	add	al,ch			; Add in the X index value
	xor	ah,ah			; Convert to direct page address
	mov	di,ax			; Setup to do the indirection
	mov	di,ds:[di]		; Setup the effective address
	Endm

DoDIIY	Macro
_type	=	0FFh
	lodsb				; Get the direct page offset
	xor	ah,ah			; Convert to direct page address
	mov	di,ax			; Setup to do the indirection
	mov	di,ds:[di]		; Do the indirection
	mov	al,cl			; Get the Y index value
	add	di,ax			; Setup the effective address
	Endm

OpADCb	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ah,dh			; Copy 65C02 flags into AH register
	shr	ah,1			; Shift 65C02 carry into real carry
	adc	dl,al			; Add with carry to accumulator
	Flgnvzc 			; Update the 65C02 processor flags
	Endm

OpADCd	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ah,dh			; Copy 65C02 flags into AH register
	shr	ah,1			; Shift 65C02 carry into real carry
	adc	al,dl			; Add with carry to accumulator
	daa				; Do the adjust for decimal mode
	mov	dl,al			; Update the accumulator value
	Flgnvzc 			; Update the 65C02 processor flags
	Endm

OpAND	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	and	dl,al			; AND accumulator with memory
	Flgnz				; Update the 65C02 processor flags
	Endm

OpASL	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	shl	al,1			; Shift the memory location left
	mov	bp,ax			; Save the memory location value
	Flgnzc				; Update the 65C02 processor flags
	mov	ax,bp			; Restore the memory location value
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpBIT	Macro
	Local	_addr
	and	dh,Not (CPU_N + CPU_V + CPU_Z)
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	test	dl,al			; AND accumulator with memory value
	jnz	_addr			; Jump if the value is non-zero
	or	dh,CPU_Z		; Zero result, set the zero flag
_addr:
	and	al,11000000b		; Mask off all but upper two bits
	xor	ah,ah			; Convert flag bits to full word
	mov	bp,ax			; Setup to decode the flag value
	or	dh,cs:[bp + Flag_Decode]; Set correct bits in 65C02 status
	Endm

OpBITz	Macro
	Local	_addr
	and	dh,Not CPU_Z		; Clear the z flag
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	test	dl,al			; AND accumulator with memory value
	jnz	_addr			; Jump if the value is non-zero
	or	dh,CPU_Z		; Zero result, set the zero flag
_addr:
	Endm

OpCMP	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	cmp	dl,al			; Compare accumulator with memory
	cmc				; Toggle carry to the correct state
	Flgnzc				; Update the 65C02 processor flags
	Endm

OpCPX	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	cmp	ch,al			; Compare X index register with memory
	cmc				; Toggle carry to the correct state
	Flgnzc				; Update the 65C02 processor flags
	Endm

OpCPY	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	cmp	cl,al			; Compare Y index register with memory
	cmc				; Toggle carry to the correct state
	Flgnzc				; Update the 65C02 processor flags
	Endm

OpDEC	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	dec	al			; Decrement the memory location
	mov	bp,ax			; Save the memory location value
	Flgnz				; Update the 65C02 processor flags
	mov	ax,bp			; Restore the memory location value
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpEOR	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	xor	dl,al			; Exclusive-OR accumulator with memory
	Flgnz				; Update the 65C02 processor flags
	Endm

OpINC	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	inc	al			; Increment the memory location
	mov	bp,ax			; Save the memory location value
	Flgnz				; Update the 65C02 processor flags
	mov	ax,bp			; Restore the memory location value
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpJMP	Macro
	mov	si,di			; Update the program counter
	Endm

OpJSR	Macro
	mov	ax,si			; Get the current program counter
	dec	ax			; Point to last instruction byte
	Push_16 			; Save the return address on the stack
	mov	si,di			; Update the program counter
	Endm

OpLDA	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	dl,al			; Load accumulator from memory
	or	dl,dl			; Set the status flags correctly
	Flgnz				; Update the 65C02 processor flags
	Endm

OpLDX	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ch,al			; Load X index register from memory
	or	ch,ch			; Set the status flags correctly
	Flgnz				; Update the 65C02 processor flags
	Endm

OpLDY	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	cl,al			; Load Y index register from memory
	or	cl,cl			; Set the status flags correctly
	Flgnz				; Update the 65C02 processor flags
	Endm

OpLSR	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	shr	al,1			; Shift the memory location right
	mov	bp,ax			; Save the memory location value
	Flgnzc				; Update the 65C02 processor flags
	mov	ax,bp			; Restore the memory location value
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpORA	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	or	dl,al			; OR accumulator with memory
	Flgnz				; Update the 65C02 processor flags
	Endm

OpROL	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ah,dh			; Copy 65C02 flags into AH register
	shr	ah,1			; Shift 65C02 carry into real carry
	rcl	al,1			; Rotate the memory location left
	rcr	ah,1			; Save carry result in AH register
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	or	al,al			; Set the n and z flags correctly
	rcl	ah,1			; Restore the carry result
	Flgnzc				; Update the 65C02 processor flags
	Endm

OpROR	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ah,dh			; Copy 65C02 flags into AH register
	shr	ah,1			; Shift 65C02 carry into real carry
	rcr	al,1			; Rotate the memory location right
	rcr	ah,1			; Save carry result in AH register
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	or	al,al			; Set the n and z flags correctly
	rcl	ah,1			; Restore the carry result
	Flgnzc				; Update the 65C02 processor flags
	Endm

OpSBCb	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ah,dh			; Copy 65C02 flags into AH register
	shr	ah,1			; Shift 65C02 carry into real carry
	cmc				; Invert carry to correct state
	sbb	dl,al			; Subtract from accumulator with borrow
	cmc				; Invert carry back to correct state
	Flgnvzc 			; Update the 65C02 processor flags
	Endm

OpSBCd	Macro
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	mov	ah,dh			; Copy 65C02 flags into AH register
	shr	ah,1			; Shift 65C02 carry into real carry
	cmc				; Invert carry to correct state
	xchg	al,dl			; Get the current accumulator value
	sbb	al,dl			; Subtract from accumulator with borrow
	das				; Do the adjust for decimal mode
	mov	dl,al			; Update the accumulator value
	cmc				; Invert carry to correct state
	Flgnvzc 			; Update the 65C02 processor flags
	Endm

OpSTA	Macro
	mov	al,dl			; Store the accumulator in memory
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpSTX	Macro
	mov	al,ch			; Store X index register in memory
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpSTY	Macro
	mov	al,cl			; Store Y index register in memory
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpSTZ	Macro
	xor	al,al			; Store zero in memory
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	Endm

OpTRB	Macro
	Local	_addr
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	and	dh,Not CPU_Z		; Clear the z flag
	mov	ah,dl			; Get a copy of the accumulator
	not	ah			; Invert the accumulator value
	and	al,ah			; Mask off the desired memory bits
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	not	ah			; Restore the accumulator value
	and	ah,al			; AND accumulator with memory
	jnz	_addr			; Jump if the result is non-zero
	or	dh,CPU_Z		; Zero result, set the z flag
_addr:
	Endm

OpTSB	macro
	Local	_addr
	If	_type
		call	Read_Memory	; Call routine to read 65C02 memory
	Else
		mov	al,ds:[di]	; Read the 65C02 memory value
	Endif
	and	dh,Not CPU_Z		; Clear the z flag
	mov	ah,dl			; Get a copy of the accumulator
	or	al,ah			; Set the desired memory bits
	If	_type
		call	Write_Memory	; Call routine to write 65C02 memory
	Else
		mov	ds:[di],al	; Write the 65C02 memory value
	Endif
	and	ah,al			; AND accumulator with memory
	jnz	_addr			; Jump if the result is non-zero
	or	dh,CPU_Z		; Zero result, set the z flag
_addr:
	Endm
	.List

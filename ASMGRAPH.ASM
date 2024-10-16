FORMAT MZ
entry main:start

segment main
        start:
                ; set variable segment
                FINIT
                MOV AX, variables
                MOV DS, AX
                MOV ES, AX
                CALL memfill
                MOV AX, 0x0000
                MOV [SCREEN.stride], AX
                MOV [SCREEN.mode], AX
                MOV AX, 800
                MOV [SCREEN.width], AX
                MOV AX, 600
                MOV [SCREEN.height], AX
;                MOV AL, 0x20 ; 32 bit
;               MOV AL, 0x10 ; 16 bit
;                MOV AL, 0x0F ; 15 bit
                MOV AL, 0x08  ; 256 color
;               MOV AL, 0x04  ; 16 color
                MOV [SCREEN.bpp], AL
                CALL vesa:find_mode
                ; check that we got a valid mode, or default to 0x0013
                MOV AX, [SCREEN.mode]
                CMP AX, 0x0000
                JNE .valid_mode
                MOV AX, 0x0013
                MOV [SCREEN.mode], AX
                MOV AX, 0x0140
                MOV [SCREEN.stride], AX
                MOV AX, 0xFFFF
                MOV [SCREEN.gran], AX
                MOV AX, 320
                MOV [SCREEN.width], AX
                MOV AX, 200
                MOV [SCREEN.height], AX
                .valid_mode:
                ; 0x0111 works -- 640x480x16
                ; 0x0110 works -- 640x480x15
                ; 0x010E works -- 320x200x16
                ; 0x010A works --
                ; 0x0109 works -- text mode
                ; 0x0105 works -- out of range
                ; 0x0104 works -- out of range
                ; 0x0103 works -- 800x600x8
                ; 0x0102 works -- 800x600x4
                ; 0x0101 works -- 640x480x8
                MOV DX, [SCREEN.width]
                CALL text:int_print

                MOV DX, [SCREEN.height]
                CALL text:int_print

                MOV DX, [SCREEN.stride]
                CALL text:int_print

                MOV DX, [SCREEN.gran]
                CALL text:int_print

                MOV AX, 0x0056
                MOV BX, SCREEN.stride
                MUL BX
                MOV DX, AX
                CALL text:int_print

                MOV BX, [SCREEN.mode]
                MOV AX, 0x4f02


;                MOV AX, 0x013
                INT 10H

                MOV AX, 0x0001
                MOV [BOX.startx], AX
                MOV [BOX.starty], AX
                MOV AX, [SCREEN.width]
                SUB AX, 0x1
;                MOV AX, 0x013E
                MOV [BOX.endx], AX
                MOV AX, [SCREEN.height]
                SUB AX, 0x1
;                MOV AX, 0x0056
                MOV [BOX.endy], AX

                MOV AL, 0x0F
                MOV [COLOR], AL
                CALL graphic:box_fill

                MOV AL, 0x03
                MOV [COLOR], AL
                CALL graphic:render_box
                CALL main:keywait
                CALL graphic:render_star
                MOV AX, 0x0020
                MOV [BOX.startx], AX
                MOV [BOX.starty], AX
                MOV AX, 0x00B0
                MOV [BOX.endx], AX
                MOV [BOX.endy], AX
                CALL graphic:box_fill
                CALL graphic:render_star

                CALL main:keywait

                MOV AX, 0x0000
                MOV [COLOR], AL
                MOV [BOX.startx], AX
                MOV [BOX.starty], AX
                MOV AX, [SCREEN.width]
                MOV [BOX.endx], AX
                MOV AX, [SCREEN.height]
                MOV [BOX.endy], AX
                CALL graphic:box_fill
                MOV AL, 0x0C
                MOV [COLOR], AL


                MOV AX, [SCREEN.width]
                SHR AX, 1
;               MOV AX, 300
                MOV [CIRCLE.x], AX

               MOV AX, [SCREEN.height]
               SHR AX, 1
                MOV [CIRCLE.y], AX

                MOV [CIRCLE.r], AX
;                CALL graphic:render_circle
                CALL graphic:render_conic
        exit_to_dos:
                CALL main:keywait
                MOV DX, 0x0000
                MOV AX, 0x0003
                INT 10H
                MOV AX, 0x4C00
                INT 21H

        keywait:
                        ; WAIT FOR ENTER
                PUSH AX
                PUSH DX
                MOV DX, 0x0000
                MOV AX, 0x0A00
                INT 0x21
                POP DX
                POP AX
                RETF


        memfill:
                MOV BX, VESA_INFO
                MOV DI, 0x1FF
                MOV AX, 0x0000
                .fill:
                MOV [BX+DI], AX
                DEC DI
                DEC DI
                JGE .fill
                MOV BX, MODE_INFO
                MOV DI, 0x1FF
                .filll:
                MOV [BX+DI], AX
                DEC DI
                DEC DI
                JGE .filll
               .fill_exit:
                RET

segment text use16


        char_print:
                PUSH AX
                MOV AX, 0x200
                INT 21H
                POP AX
                RETF

        string_print:
                PUSH AX
                PUSH DX
                PUSH DI
                MOV AX, DX
                MOV DI, AX
                MOV DH, 0x00
                MOV AX, 0x200
                .str_loop:
                MOV DL, [DI]
                INT 21h
                INC DI
                CMP DL, 0x07
                JGE .str_loop
                POP DI
                POP DX
                POP AX
                RETF

        int_print:
                PUSH AX
                PUSH CX
                ; setup for character output
                MOV AX, 0200H
                ; stash a copy of DX and print high nibble
                PUSH DX
                MOV CL, 12
                ROR DX, CL
                AND DX, 000Fh
                CALL .print_hex
                ; refresh DX and set up for low nubble of high byte
                POP DX
                PUSH DX
                MOV CL, 8
                ROR DX, CL
                AND DX, 000Fh
                CALL .print_hex
                ; refresh DX and set up for high nibble of low byte
                POP DX
                PUSH DX
                MOV CL, 4
                ROR DX, CL
                AND DX, 000Fh
                CALL .print_hex
                POP DX
                PUSH DX
                AND DX, 000Fh
                CALL .print_hex
                MOV DL, 13
                INT 21H
                MOV DL, 10
                INT 21H
                POP DX
                POP CX
                POP AX
	        RETF                     ; DONE

        .print_hex:
                PUSH DX
                CMP DL, 09h
                JLE .print_hex_intval
                ADD DL, 07h
        .print_hex_intval:
                ADD DL, 30h
                INT 21H
                POP DX
                RET



segment vesa use16

        find_mode:

                PUSH AX
                PUSH BX
                PUSH DX
                PUSH CX
                PUSH DI
                PUSH ES

                CALL vesa:get_info

                MOV ES, word [VESA_INFO.mode_list+2]
                MOV DI, word [VESA_INFO.mode_list]
                .mode_loop:

                MOV CX, [DI]
                INC DI
                INC DI
;                MOV AX, [SCREEN.mode]
;                CMP AX, 0x0000
 ;               JNE .invalid_mode
                CALL vesa:get_mode_info
                ; MODE_INFO now has the details for the mode we want to check
                ; check this against the information in SCREEN
                MOV AX, [SCREEN.width]
                CMP AX, [MODE_INFO.width]
                JNE .invalid_mode

                MOV AX, [SCREEN.height]
                CMP AX, [MODE_INFO.height]
                JNE .invalid_mode

                MOV AL, [SCREEN.bpp]
                CMP AL, [MODE_INFO.bpp]
                JNE .invalid_mode
                MOV [SCREEN.mode], CX
                MOV AX, [MODE_INFO.stride]
                MOV [SCREEN.stride], AX
                MOV AX, [MODE_INFO.granularity]
                SHL AX, 10 ; in sets of granularity/4 bytes
;                MOV AX, 0x4000 ; fixed 16K chunk
                MOV [SCREEN.gran], AX

;                CALL vesa:print_mode_info


                .invalid_mode:
                CMP CX, 0xFFFF
                JNZ .mode_loop
                .mode_search_exit:
;                MOV DL, 13
;                CALL text:char_print
;                MOV DL, 10
 ;               CALL text:char_print
                POP ES
                POP BX
                POP DX
                POP CX
                POP DI
                POP AX
                RETF



;                CALL vesa:print_modes
                CALL main:keywait
                RETF

        get_info:
                PUSH AX
                PUSH DX
                PUSH DI

                MOV byte [VESA_INFO.signature], 0x56
                MOV byte [VESA_INFO.signature+1], 0x42
                MOV byte [VESA_INFO.signature+2], 0x45
                MOV byte [VESA_INFO.signature+3], 0x32

                MOV DI, VESA_INFO
                MOV AX, 0x4F00
                INT 10H
                POP DI
                POP DX
                POP AX
                RETF


        print_modes:
                PUSH BX
                PUSH DX
                PUSH CX
                PUSH DI
                PUSH ES

                MOV ES, word [VESA_INFO.mode_list+2]
                MOV DI, word [VESA_INFO.mode_list]
                .mode_loop:

                MOV DL, 0x20
                CALL text:char_print
                MOV DX, [DI]
                INC DI
                INC DI
                CALL text:int_print
                MOV CX, DX
                CALL vesa:get_mode_info
                CALL vesa:print_mode_info


                CMP DX, 0xFFFF
                JNZ .mode_loop

                MOV DL, 13
                CALL text:char_print
                MOV DL, 10
                CALL text:char_print
                POP ES
                POP BX
                POP DX
                POP CX
                POP DI
                RETF


        get_mode_info:
                PUSH AX
                PUSH DX
                PUSH DI

                MOV AX, 0x200
                MOV DX, 0x0000
                MOV DI, MODE_INFO
                MOV AX, 0x4F01

                INT 0x10
                POP DI
                POP DX
                POP AX
                RETF

        print_info:
                PUSH DX
                PUSH CX
                PUSH BX
                PUSH AX
                MOV AX, 0x200
                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV BX, VESA_INFO
                ; signature
                MOV DL, [BX]
                INT 0x21
                MOV DL, [BX+1]
                INT 0x21
                MOV DL, [BX+2]
                INT 0x21
                MOV DL, [BX+3]
                INT 0x21

                MOV DL, 0x20
                INT 0x21
                ; version
                MOV DX, [BX+4]
                CALL text:int_print
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21

                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21


                ; OEM String
                MOV DX, [BX+6]
                CALL text:int_print
                MOV DX, [BX+8]
                CALL text:int_print


                MOV DL, 0x09
                INT 0x21
                ; VBE2 Vendor Name
                MOV DX, [BX+22]
                CALL text:int_print
                MOV DX, [BX+24]
                CALL text:int_print

                MOV DL, 0x09
                INT 0x21
                ; VBE2 Product Name
                MOV DX, [BX+26]
                CALL text:int_print
                MOV DX, [BX+28]
                CALL text:int_print
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                ; Capabilites Flags
                MOV DX, [BX+10]
                CALL text:int_print
                MOV DX, [BX+12]
                CALL text:int_print


                ; VESA 2 Capabilities

                MOV DL, 0x09
                INT 0x21
                MOV DX, [BX+34]
                CALL text:int_print

                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21

                ; VESA Modes
                MOV DX, [BX+14]
                CALL text:int_print
                MOV DX, [BX+16]
                CALL text:int_print

                ; VESA 2 Accellerated Modes

                MOV DL, 0x09
                INT 0x21
                MOV DX, [BX+36]
                CALL text:int_print

                MOV DX, [BX+38]
                CALL text:int_print
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21

                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21

                ; Memory (Blocks)
                MOV DX, [BX+18]
                CALL text:int_print

                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21

                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                ; VBE2 Software Version
                MOV DX, [BX+20]
                CALL text:int_print

                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                ; VBE2 Revision String
                MOV DX, [BX+30]
                CALL text:int_print
                MOV DX, [BX+32]
                CALL text:int_print

                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21

                POP AX
                POP BX
                POP CX
                POP DX
                RETF

        print_card_info:
                PUSH DS
                PUSH AX
                PUSH DX
                MOV DX, word[VESA_INFO.oem_name]
                MOV AX, word[VESA_INFO.oem_name+2]
                MOV DS, AX
                CALL text:string_print
;                MOV AX, 0x0900
;                INT 0x21

                MOV AX, 0x0200
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV DX, word[VESA_INFO.vend_name]
                MOV AX, word[VESA_INFO.vend_name+2]
                MOV DS, AX
                CALL text:string_print
;                MOV AX, 0x0900
;                INT 0x21

                MOV AX, 0x0200
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                MOV DX, word[VESA_INFO.prod_name]
                MOV AX, word[VESA_INFO.prod_name+2]
                MOV DS, AX
                CALL text:string_print
;                MOV AX, 0x0900
;                INT 0x21

                MOV AX, 0x0200
                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                POP DX
                POP AX
                POP DS
                RETF

        print_mode_info:
                PUSH DX
                PUSH CX
                PUSH BX
                PUSH AX
                MOV AX, 0x200
                MOV DL, 0xCD
                INT 0x21
                INT 0x21
                INT 0x21
                MOV DL, 9
                INT 0x21
                MOV DX, MODE_INFO.mode_attr
                CALL text:int_print
                MOV BX, MODE_INFO
                ; resolution
                MOV DX, [MODE_INFO.width]
                CALL text:int_print

                MOV DX, [MODE_INFO.height]
                CALL text:int_print

                MOV DX, [MODE_INFO.stride]
                CALL text:int_print
                MOV DH, 0x00
                MOV DL, [MODE_INFO.bpp]
                CALL text:int_print

                MOV DL, 10
                INT 0x21
                MOV DL, 13
                INT 0x21
                POP AX
                POP BX
                POP CX
                POP DX
                RETF


segment graphic

        render_star:
                PUSH AX
                ; init color experiment
;                MOV AL, 0x00
;                MOV [COLOR], AL

                ; calculate the midpoint and load to LINE.start

                MOV AX, [BOX.endx]
                SUB AX, [BOX.startx]
                SAR AX, 1
                ADD AX, [BOX.startx]
                MOV [LINE.startx], AX

                MOV AX, [BOX.endy]
                SUB AX, [BOX.starty]
                SAR AX, 1
                ADD AX, [BOX.starty]
                MOV [LINE.starty], AX

                ; SET LINE.endx to BOX.endx to draw the right side
                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX

                ; start at the bottom with line.endy
                MOV AX, [BOX.endy]
                MOV [LINE.endy], AX
                ; section to draw the low slope (sides) of the star
                .draw_low:
                ; draw a line
                CALL graphic:draw_line
                ; color experiment
                MOV AX, [COLOR]
                ADD AX, 1
                MOV [COLOR], AX
                ; subtract a gap from the Y position
                MOV AX, [LINE.endy]
                SUB AX, 0x0005
                MOV [LINE.endy], AX

                ; loop until we reach the top of the area
                CMP AX, [BOX.starty]
                JNS .draw_low
                ;check which side we just drew
                ; jmp to high draw routine if we just did the left side
                MOV AX, [LINE.endx]
                CMP AX, [BOX.startx]
                JE .box_high
                ; if we just did the right, then set up for the left
                MOV AX, [BOX.startx]
                MOV [LINE.endx], AX
                ; reset endy to draw the left and jump
                ; start at the bottom with line.endy
                MOV AX, [BOX.endy]
                MOV [LINE.endy], AX
                JMP .draw_low

                ; done drawing the sides (low slope)
                ; now to draw the high slope sections
                .box_high:


                ; SET LINE.endx to BOX.endx to draw the bottom
                MOV AX, [BOX.endy]
                MOV [LINE.endy], AX

                ; start at the right with line.endx
                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX
                ; section to draw the high slope (top/bot) of the star
                ; draw a line
                .draw_high:
                CALL graphic:draw_line

                ; color experiment
                MOV AX, [COLOR]
                ADD AX, 1
                MOV [COLOR], AX
                ; subtract a gap from the X position
                MOV AX, [LINE.endx]
                SUB AX, 0x0005
                MOV [LINE.endx], AX

                ; loop until we reach the right of the area
                CMP AX, [BOX.startx]
                JNS .draw_high
                ;check which side we just drew
                ; jmp to exit if we just did the top
                MOV AX, [LINE.endy]
                CMP AX, [BOX.starty]
                JE .star_exit
                ; if we just did the bottom, then set up for the top
                MOV AX, [BOX.starty]
                MOV [LINE.endy], AX
                ; reset endy to draw the left and jump
                ; start at the bottom with line.endy
                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX
                JMP .draw_high


                .star_exit:
                POP AX
                RETF

        render_conic:
                PUSH DX
                .conic_loop:
                CALL graphic:render_circle
                MOV DL, [COLOR]
                INC DL
                MOV [COLOR], DL
                MOV DX, [CIRCLE.r]
                DEC DX
                MOV [CIRCLE.r], DX
                CMP DX, 0
                JNE .conic_loop
                POP DX


        render_circle:


	        PUSH AX
        	PUSH DX

	        ; DX == endX
        	MOV 	DX, [CIRCLE.r]
;	        SHR 	DX, 1
        	MOV AX, [CIRCLE.r]
	        MOV [CIRCLE.curry], AX
        	MOV [CIRCLE.currx], 0
                MOV AX, [CIRCLE.x]
                MOV [POINT.x], AX
                MOV AX, [CIRCLE.y]
                MOV [POINT.y], AX
                INC byte[COLOR]
                CALL graphic:point
                DEC byte[COLOR]
	        .circle_loop:
		CALL plot_circle
		INC [CIRCLE.currx]
		CALL y_calc
                ; check if we need to stop here
                FILD word[CIRCLE.currx]
                FMUL st0, st0
	        FILD word[CIRCLE.curry]
                FMUL st0, st0
                FADD st0, st1
                FSQRT
                FISTP word[FLOAT]
                MOV DX, [FLOAT]
                FISTP word[FLOAT]
	        CMP DX, [CIRCLE.r]
        	JLE  .circle_loop

        	POP DX
	        POP AX
        	RETF

        plot_circle:
	        PUSH AX


        	MOV AX, [CIRCLE.currx]
	        ADD AX, [CIRCLE.x]
        	MOV [POINT.x], AX

        	MOV AX, [CIRCLE.curry]
	        ADD AX, [CIRCLE.y]
        	MOV [POINT.y], AX
        	CALL graphic:point

                MOV AX, [CIRCLE.y]
                SUB AX, [CIRCLE.curry]
        	MOV [POINT.y], AX
	        CALL graphic:point

        	MOV AX, [CIRCLE.x]
	        SUB AX, [CIRCLE.currx]
        	MOV [POINT.x], AX

        	MOV AX, [CIRCLE.curry]
	        ADD AX, [CIRCLE.y]
        	MOV [POINT.y], AX
        	CALL graphic:point

                MOV AX, [CIRCLE.y]
                SUB AX, [CIRCLE.curry]
        	MOV [POINT.y], AX
	        CALL graphic:point



        	MOV AX, [CIRCLE.currx]
	        ADD AX, [CIRCLE.y]
        	MOV [POINT.y], AX

        	MOV AX, [CIRCLE.curry]
	        ADD AX, [CIRCLE.x]
        	MOV [POINT.x], AX
        	CALL graphic:point

                MOV AX, [CIRCLE.x]
                SUB AX, [CIRCLE.curry]
        	MOV [POINT.x], AX
	        CALL graphic:point

        	MOV AX, [CIRCLE.y]
	        SUB AX, [CIRCLE.currx]
        	MOV [POINT.y], AX

        	MOV AX, [CIRCLE.curry]
	        ADD AX, [CIRCLE.x]
        	MOV [POINT.x], AX
        	CALL graphic:point

                MOV AX, [CIRCLE.x]
                SUB AX, [CIRCLE.curry]
        	MOV [POINT.x], AX
	        CALL graphic:point


        	POP AX
	        RET

        y_calc:
	        PUSH BX
        	PUSH AX
                FILD word[CIRCLE.currx]
                FMUL st0, st0
	        FILD word[CIRCLE.curry]
                FMUL st0, st0
                FADD st0, st1
                FSQRT
                FISTP word[FLOAT]
                MOV BX, [FLOAT]
                FISTP word[FLOAT]
	        CMP BX, [CIRCLE.r]
        	JLE  .done
		MOV AX, [CIRCLE.curry]
		DEC AX
		MOV [CIRCLE.curry], AX
	        .done:
        	POP AX
	        POP BX
                RET



        render_box:
                PUSH AX
                ; DRAW LEFT
                MOV AX, [BOX.startx]
                MOV [LINE.startx], AX
                MOV AX, [BOX.starty]
                MOV [LINE.starty], AX

                MOV AX, [BOX.startx]
                MOV [LINE.endx], AX
                MOV AX, [BOX.endy]
                MOV [LINE.endy], AX
                CALL graphic:draw_line


                ; DRAW TOP
                MOV AX, [BOX.startx]
                MOV [LINE.startx], AX
                MOV AX, [BOX.starty]
                MOV [LINE.starty], AX

                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX
                MOV AX, [BOX.starty]
                MOV [LINE.endy], AX
                CALL graphic:hline
;                CALL graphic:draw_line

                ; DRAW BOTTOM
                MOV AX, [BOX.startx]
                MOV [LINE.startx], AX
                MOV AX, [BOX.endy]
                MOV [LINE.starty], AX

                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX
                MOV AX, [BOX.endy]
                MOV [LINE.endy], AX
                CALL graphic:hline
;                CALL graphic:draw_line

                ; DRAW RIGHT
                MOV AX, [BOX.endx]
                MOV [LINE.startx], AX
                MOV AX, [BOX.starty]
                MOV [LINE.starty], AX

                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX
                MOV AX, [BOX.endy]
                MOV [LINE.endy], AX
                CALL graphic:draw_line
                POP AX
                RETF

        box_fill:
                PUSH CX
                ; check direction and correct
                MOV CX, [BOX.endy]
                SUB CX, [BOX.starty]
                JNS .positive
                MOV CX, [BOX.endy]
                MOV [LINE.endy], CX
                MOV CX, [BOX.starty]
                MOV [BOX.endy], CX
                MOV CX, [LINE.endy]
                MOV [BOX.starty], CX
                MOV CX, [BOX.endy]
                SUB CX, [BOX.starty]
                .positive:
                ; load the static horizontal position
                MOV AX, [BOX.startx]
                MOV [LINE.startx], AX
                MOV AX, [BOX.endx]
                MOV [LINE.endx], AX
        	MOV AX, [BOX.endy]       ; load the Y coordinate to AX
                MOV [LINE.starty], AX
                MOV [LINE.endy], AX
                .fill_draw:
                CALL graphic:hline
                MOV AX, [LINE.starty]
                DEC AX
                MOV [LINE.starty], AX
                MOV [LINE.endy], AX
                DEC CX
                JNZ .fill_draw
                POP CX
                RETF

        draw_line:
                ; LINE FLAGS
                ; bit 0 == Y_SIGN, 1=POS 0=NEG
                ; bit 1 == X_SIGN, 1=POS, 0=NEG
                ; bit 2 == slope flag 1= < 1 0, = > 1
                PUSH AX
                PUSH DX
                PUSH BX
                ; initialize LINE_FLAGS
                MOV BL, 0x00
                OR BL, 0x07
                MOV [LINE_FLAGS], BL
                ; calculate X Delta
                ; dx = x1 - x0
                MOV AX, [LINE.endx]
                SUB AX, [LINE.startx]
                MOV [DELTA.x], AX
                CMP AX, 0
                JGE .posx
                MOV BL, [LINE_FLAGS]
                XOR BL, 0x02
                MOV [LINE_FLAGS], BL
                MOV AX, 0
                SUB AX, [DELTA.x]
                MOV [DELTA.x], AX

                .posx:
                ; calculate Y Delta
                ; dy = y1 - y2
                MOV AX, [LINE.endy]
;                SUB AX, [Y_START]
                SUB AX, [LINE.starty]
                MOV [DELTA.y], AX
                ; if Y_DELTA < 0
                CMP AX, 0
                JGE .posy
                ; Y_SIGN -=2
                ;Y_DELTA = -Y_DELTA
                MOV BL, [LINE_FLAGS]
                XOR BL, 0x01
                MOV [LINE_FLAGS], BL
                MOV AX, 0x0000
                SUB AX, [DELTA.y]
                MOV [DELTA.y], AX
                ; endif
                .posy:
;                PUSH AX
                low_slope:
                MOV AX, [DELTA.x]
                SUB AX, [DELTA.y]
                JNS .bres_low_jmp
                CALL bres_line:bres_high
;                CALL main:keywait
                POP BX
                POP DX
                POP AX
                RETF

                .bres_low_jmp:
                CALL bres_line:bres_low
                POP BX
                POP DX
                POP AX
                RETF


        hline:
                PUSH AX
                PUSH BX
                PUSH CX
			; proc to plot a hline on the screen

                ; check direction and correct
                MOV CX, [LINE.endx]
                SUB CX, [LINE.startx]
                JNS .positive
                MOV CX, [LINE.endx]
                MOV [LINE.endy], CX
                MOV CX, [LINE.startx]
                MOV [LINE.endx], CX
                MOV CX, [LINE.endy]
                MOV [LINE.startx], CX
                MOV CX, [LINE.endx]
                SUB CX, [LINE.startx]
                .positive:
        	MOV AX, [LINE.starty]       ; load the Y coordinate to AX
;	        MOV BX, 0140h   ; 320 pixel multiplier for Y
;                MOV BX, [SCREEN.stride]
;        	MUL BX          ; 320*Y for Y memory offset
                CALL get_Y_address
	        MOV BX, [LINE.endx]; load X offset replacing multiplier
        	ADD AX, BX      ; add X offset
	        MOV DI, AX      ; move pixel offset to index
        	MOV BH, [COLOR] ; load COLOR to accumulator
	        MOV AX, 0A000h  ; load segment offset to VGA RAM
                PUSH DS
	        MOV DS, AX      ; set segment offset for VGA RAM
                .draw:
        	MOV [DI], BH    ; set pixel at offset to color
                DEC DI
                DEC CX
                JNZ .draw
                POP DS

                POP CX
                POP BX
                POP AX
                RETF

        calc_slope:
                FILD [LINE.startx]
                FILD [LINE.endx]
                FSUB st0, st1
                FILD [LINE.starty]
                FILD [LINE.endy]
                FSUB st0, st1
                FDIV st0, st1
                FISTP word[FLOAT]
                MOV DX, [FLOAT]
                FISTP word[FLOAT]
                FISTP word[FLOAT]
                FISTP word[FLOAT]
                FISTP word[FLOAT]
                RET
        point:
                PUSH AX
                PUSH BX
                PUSH CX
;		; proc to plot a point on the screen
;                MOV DX, 0x0000
                ; calculate the start offset for the beginning of the row
                MOV AX, [POINT.y]
                CALL get_Y_address
                MOV BX, [POINT.x]; load X offset
                MOV CL, [SCREEN.bpp]
                CMP CL, 14
                JLE .onebyte

        	ADD AX, BX      ; add X offset
                .onebyte:
        	ADD AX, BX      ; add X offset
                MOV [POINT.addr], AX
                CALL point_set_color
                POP CX
                POP BX
                POP AX
                RETF
        get_Y_address:

                PUSH EBX
                PUSH ECX
                PUSH EDX
                ; convert AX Y coordinate to 32 bit
                MOV EBX, 0x00000000
                MOV BX, AX
                MOV EAX, 0x0
                MOV AX, BX
                ; convert screen granularity to 32 bit
                MOV ECX, 0x0
                MOV CX, [SCREEN.gran]
                MOV EDX, 0x0
                ; calculate the 32 bit offset
                MOV BX, [SCREEN.stride]
                MUL EBX

                ; adjust GPU window until we are in a 16 bit window
                .check_overflow:
                CMP EAX, ECX
                JLE .found_offset
                INC DX
                SUB EAX, ECX
                JMP .check_overflow
                .found_offset:
                ; set the GPU memory offset
                MOV CX, AX
                MOV AX, 0x4F05
                MOV BX, 0x0000
                INT 0x10
                ; set the return value
                MOV EAX, 0x0
                MOV AX, CX
                POP EDX
                POP ECX
                POP EBX
                RET

        point_set_color:
                PUSH AX
                PUSH BX
                PUSH DI
                PUSH DS
                MOV AX, [POINT.addr]
                MOV DI, AX
                MOV BX, 0x0000
                MOV BH, [COLOR]
                MOV AX, 0xA000
                MOV DS, AX
        	MOV [DI], BH    ; set pixel at offset to color
                POP DS
                POP DI
                POP BX
                POP AX
                RET

segment bres_line
        bres_low:

                PUSH AX
                PUSH DX
                PUSH BX

                ; D = 2(dy) - dx
                MOV AX, [DELTA.y]
                ADD AX, [DELTA.y]
                SUB AX, [DELTA.x]
                MOV [DIFF], AX
                ; INIT LOOP
                MOV AX, [LINE.starty]
                MOV [POINT.y], AX
                MOV DX, [DELTA.x]
                ; X_POINT = X+START
                MOV AX, [LINE.startx]
                MOV [POINT.x], AX
                ; FOR X_POINT = X_START TO X_END
                .line_loop:
                CALL graphic:point
                ; IF D > 0
                MOV AX, [DIFF]
                CMP AX, 0
                JLE .diffz
                  ; Y++
                  MOV AX, [POINT.y]
                  MOV BL, 0x01
                  AND BL, [LINE_FLAGS]
                  CMP BL, 0
                  JNE .addone
                  SUB AX, 0x02
                  .addone:
                  ADD AX, 0x01
                  MOV [POINT.y], AX
                  ; D = D - 2DX
                  MOV AX, [DIFF]
                  SUB AX, [DELTA.x]
                  SUB AX, [DELTA.x]
                  MOV [DIFF], AX
                  ; ENDIF
                .diffz:
                ; D = D + 2DY
                MOV AX, [DIFF]
                ADD AX, [DELTA.y]
                ADD AX, [DELTA.y]
                MOV [DIFF], AX
                ; NEXT X
                MOV AX, [POINT.x]
                MOV BL, [LINE_FLAGS]
                AND BL, 0x02
                CMP BL, 0x02
                JZ .add_pos_x
                SUB AX, 0x02
                .add_pos_x:
                ADD AX, 1
                MOV [POINT.x], AX
                CMP AX, [LINE.endx]
                JNE .line_loop
                POP BX
                POP DX
                POP AX
                RETF


        bres_high:

                PUSH AX
                PUSH DX
                PUSH BX

                ; D = 2(dx) - dy
                MOV AX, [DELTA.x]
                ADD AX, [DELTA.x]
                SUB AX, [DELTA.y]
                MOV [DIFF], AX
                ; INIT LOOP
                 MOV AX, [LINE.startx]
                MOV [POINT.x], AX
                MOV DX, [DELTA.y]
                ; Y_POINT = Y_START
                MOV AX, [LINE.starty]
                MOV [POINT.y], AX
                ; FOR X_POINT = X_START TO X_END
                .line_loop:
                CALL graphic:point
                ; IF D > 0
                MOV AX, [DIFF]
                CMP AX, 0
                JLE .diffz
                  ; Y++
                  MOV AX, [POINT.x]
                  MOV BL, 0x02
                  AND BL, [LINE_FLAGS]
                  CMP BL, 0
                  JNE .addone
                  SUB AX, 0x02
                  .addone:
                  ADD AX, 0x01
                  MOV [POINT.x], AX
                  ; D = D - 2DX
                  MOV AX, [DIFF]
                  SUB AX, [DELTA.y]
                  SUB AX, [DELTA.y]
                  MOV [DIFF], AX
                  ; ENDIF
                .diffz:
                ; D = D + 2DY
                MOV AX, [DIFF]
                ADD AX, [DELTA.x]
                ADD AX, [DELTA.x]
                MOV [DIFF], AX
                ; NEXT X
                MOV AX, [POINT.y]
                MOV BL, [LINE_FLAGS]
                AND BL, 0x01
                CMP BL, 0x01
                JZ .add_pos_x
                SUB AX, 0x02
                .add_pos_x:
                ADD AX, 1
                MOV [POINT.y], AX
                CMP AX, [LINE.endy]
                JNE .line_loop
                POP BX
                POP DX
                POP AX
                RETF


;       VARIABLE DEFINITIONS
segment variables use16

COLOR:          DB 0
LINE_FLAGS:     DB 0
DIFF:           DW 0
FLOAT:          RD 1

BOX:
        .startx DW 0
        .starty DW 0
        .endx   DW 0
        .endy   DW 0

LINE:
        .startx DW 0
        .starty DW 0
        .endx   DW 0
        .endy   DW 0

POINT:
        .x      DW 0
        .y      DW 0
        .offset DW 0
        .addr   DW 0


CIRCLE:
	.x	RW 1
	.y	RW 1
	.r	RW 1
	.currx	RW 1
	.curry	RW 1

DELTA:
        .x      DW 0
        .y      DW 0
SCREEN:
        .mode           RW 1
        .width          RW 1
        .height         RW 1
        .bpp            RB 1
        .gran           RW 1
        .stride         RW 1
        .valid          RB 1

VESA_INFO:
        .signature      RB 4
        .version        RW 1
        .oem_name       RD 1
        .capabilities   RD 1
        .mode_list      RD 1
        .memory         RW 1
        .OEM_ver        RW 1
        .vend_name      RD 1
        .prod_name      RD 1
        .prod_rev       RD 1
        .vbe_cap        RW 1
        .vbe_modes      RD 1
        .reserved       RB 464


MODE_INFO:
        ; VESA 1.0
        .mode_attr      RW 1
        .wina_attr      RB 1
        .winb_attr      RB 1
        .granularity    RW 1
        .win_size       RW 1
        .segment_a      RW 1
        .segment_b      RW 1
        .far_func       RD 1
        .stride         RW 1
        ; optional for VESA 1.0/1.1
        .width          RW 1
        .height         RW 1
        .char_width     RB 1
        .char_height    RB 1
        .planes         RB 1
        .bpp            RB 1
        .banks          RB 1
        .mem_model      RB 1
        .bank_size      RB 1
        .pages          RB 1
        .vesa_3         RB 1
        ; VBE 1.2
        .red_mask       RB 1
        .red_field      RB 1
        .green_mask     RB 1
        .green_field    RB 1
        .blue_mask      RB 1
        .blue_field     RB 1
        .res_mask_size  RB 1
        .res_mask_pos   RB 1
        .color_mode     RB 1
        ; VBE 2.0
        .lin_buffer     RD 1
        .offscreen      RD 1
        ; VBE 3.0
        .lin_stride     RW 1
        .bank_images    RB 1
        .lin_images     RB 1
        .dir_mask_size  RB 1
        .dir_mask_pos   RB 1

        .reserved       RB 458

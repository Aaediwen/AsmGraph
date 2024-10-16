FORMAT MZ
entry main:start
stack 200h

segment main
        start:
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
;                MOV BX, 0x0114
;                MOV AX, 0x4f02
                ;\\\\\\\\\\\\\\\\\\\\\\\
                MOV AX, variables
                MOV DS, AX
                MOV ES, AX
                ;\\\\\\\\\\\\\\\\\\\
                CALL memfill
                MOV DL, 0x45
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, ES
                CALL text:int_print
                MOV DL, 0x44
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, DS
                CALL text:int_print

                MOV DL, 0x43
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, CS
                CALL text:int_print
                MOV DL, 0x56
               CALL text:char_print
               MOV DL, 0x53
               CALL text:char_print
               MOV DL, 0x20
               CALL text:char_print
               MOV DX, VESA_INFO
               CALL text:int_print
                MOV DL, 0x57
               CALL text:char_print
               MOV DL, 0x53
               CALL text:char_print
               MOV DL, 0x20
               CALL text:char_print
;               MOV DX, SEGS
;               CALL text:int_print

                MOV DL, 10
                CALL text:char_print
                MOV DL, 13
                CALL text:char_print
                MOV DL, 0x45
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, ES
                CALL text:int_print
                MOV DL, 0x44
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, DS
                CALL text:int_print

                MOV DL, 0x43
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, CS
                CALL text:int_print
                MOV DL, 0x56
               CALL text:char_print
               MOV DL, 0x53
               CALL text:char_print
               MOV DL, 0x20
               CALL text:char_print
               MOV DX, MODE_INFO
               CALL text:int_print

                MOV DL, 10
                CALL text:char_print
                MOV DL, 13
                CALL text:char_print


                CALL vesa:get_info
                CALL vesa:print_info
                CALL vesa:print_modes
                CALL vesa:print_card_info
;                MOV CX, 0x0103
;                CALL vesa:get_mode_info
;                CALL vesa:print_mode_info

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
                MOV DX, 0000H
                MOV AX, 0C0AH
                INT 21H
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


segment vesa use16

        get_info:
                PUSH AX
                PUSH DX
                PUSH CX
                PUSH DI
                MOV DL, 0x45
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, ES
                CALL text:int_print
                MOV DL, 0x44
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, DS
                CALL text:int_print

                MOV DL, 0x43
                CALL text:char_print
                MOV DL, 0x53
                CALL text:char_print
                MOV DL, 0x20
                CALL text:char_print
                MOV DX, CS
                CALL text:int_print
                MOV DL, 0x56
               CALL text:char_print
               MOV DL, 0x53
               CALL text:char_print
               MOV DL, 0x20
               CALL text:char_print
               MOV DX, VESA_INFO
               CALL text:int_print

                MOV DL, 13
                CALL text:char_print
                MOV DL, 10
                CALL text:char_print

                MOV byte [VESA_INFO], 0x56
;                MOV byte [VESA_INFO+1], 0x45
;                MOV byte [VESA_INFO+2], 0x53
;                MOV byte [VESA_INFO+3], 0x41

                MOV byte [VESA_INFO+1], 0x42
                MOV byte [VESA_INFO+2], 0x45
                MOV byte [VESA_INFO+3], 0x32

                MOV byte [VESA_INFO+4], 0x41
                MOV byte [VESA_INFO+5], 0x00
                MOV byte [VESA_INFO+6], 0x00
                MOV byte [VESA_INFO+7], 0x00
                MOV byte [VESA_INFO+8], 0x00

                MOV DI, VESA_INFO
                MOV AX, 0x4F00
                INT 10H
                POP DI
                POP CX
                POP DX
                POP AX
                RETF


        print_modes:
                PUSH BX
                PUSH DX
                PUSH CX
                PUSH DI
                PUSH ES

                MOV ES, [VESA_INFO+16]
                MOV DI, [VESA_INFO+14]
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
 ;               MOV DL, 13
 ;               INT 0x21
 ;               MOV DL, 10
 ;               INT 0x21

;                CALL main:keywait
;               MOV DX, MODE_INFO
;               CALL text:int_print

;                MOV DL, 13
;                INT 0x21
;                MOV DL, 10
;                INT 0x21
                MOV DX, 0x0000
                MOV DI, MODE_INFO
                MOV AX, 0x4F01

 ;               CALL main:keywait
                INT 0x10
;                MOV DX, AX
;                CALL text:int_print
 ;               CALL main:keywait
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
;                AND DX, 0x0020
;                ADD DX, 0x40
 ;               MOV DL, 13
;                INT 0x21
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


                MOV DX, [MODE_INFO.granularity]
                CALL text:int_print

                MOV DX, [MODE_INFO.win_size]
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
                MOV DL, 0x20
                INT 21H
;                MOV DL, 13
;                INT 21H
;                MOV DL, 10
;                INT 21H
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

segment variables use16

buffer: RB 8

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

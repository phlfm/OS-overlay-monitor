; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; User Mod 2 program to demonstrate use of overlay manager
; Size = 0x28 bytes
pos_root equ $10000
pos_lvl1 equ $70
pos_lvl2 equ $D0
pos_lvl3 equ $130
pos_lvl4 equ $190
pos_lvl5 equ $1F0

           ORG     pos_root+pos_lvl2
           addi.L  #%00000100,D6        ; D6 will register which modules where visited

           ; Load Level 3
           SUB.L   D0,D0
           SUB.L   D1,D1
           LEA     str_mod3,A0         ; Point A0 to module name
           addi.b  #03,D0              ; Set module level to 1
           addi.b  #$08,D1             ; Set module size
           trap    #03                 ; Call overlay monitor
           BSR     (pos_root+pos_lvl3)
           RTS


str_mod3      dc.b        "OM01_mod3",0
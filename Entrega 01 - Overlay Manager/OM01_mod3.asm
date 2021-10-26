; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; User Mod 3 program to demonstrate use of overlay manager
; Size = 0x08 bytes
pos_root equ $10000
pos_lvl1 equ $70
pos_lvl2 equ $D0
pos_lvl3 equ $130
pos_lvl4 equ $190
pos_lvl5 equ $1F0

           ORG     pos_root+pos_lvl3
           addi.L  #%00001000,D6        ; D6 will register which modules where visited
           RTS
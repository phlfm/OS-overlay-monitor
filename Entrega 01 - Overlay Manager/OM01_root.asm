; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; User root program to demonstrate use of overlay manager
; Size 0x66
pos_root equ $10000
pos_lvl1 equ $70
pos_lvl2 equ $D0
pos_lvl3 equ $130
pos_lvl4 equ $190
pos_lvl5 equ $1F0


           ORG     pos_root
; Do work
           addi.b  #01,D7
           addi.b  #01,D7
           addi.b  #01,D7

; Load Module Level 1 A
           LEA     str_mod1A,A0        ; Point A0 to module name
           addi.b  #01,D0              ; Set module level to 1
           addi.b  #(pos_lvl2-pos_lvl1),D1      ; Set module size
           trap    #03                 ; Call overlay monitor

; Call mod 1
           BSR     (pos_root+pos_lvl1)

; Return from mod 1
           addi.b #$FF,D7

; Load Module Level 1 B
           LEA     str_mod1B,A0 ; Point A0 to module name
           SUB.L   D1,D1
           addi.b  #$08,D1      ; Set module size
           trap    #03         ; Call overlay monitor

; Call mod 1
           BSR     (pos_root+pos_lvl1)

; Load Module Level 2
           LEA     str_mod2,A0 ; Point A0 to module name
           addi.b  #01,D0      ; Set module level = 2
           SUB.L   D1,D1
           addi.b  #$28,D1     ; Set module size
           trap    #03         ; Call overlay monitor

; Call mod 2
           BSR     (pos_root+pos_lvl2)

; Exit
           trap    #15
           dc.w    t15EXIT             ; exit
           stop    #$2700



str_mod1A      dc.b        "OM01_mod1A",0
str_mod1B      dc.b        "OM01_mod1B",0
str_mod2       dc.b        "OM01_mod2",0

t15EXIT       equ     0
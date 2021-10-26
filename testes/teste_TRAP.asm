; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; Teste de TRAP
;
;

; From 0x000 up to 0x3FF we have interruption tables and simulator data
; So our program starts at 0x400
           org         $400

; TRAP address'es are 0x80 + 4*vector value
; TRAP #3 = 0x8C
trap3vec   equ         $8C

; Load overlay monitor's address in TRAP #3
           LEA         ovrlymontor,A0  ; Load effective address of ovrlymontor into A0
           MOVE.L      A0,trap3vec     ; Put address of ovrlymontor into the trap vector table #3

; Jump to user code WITHOUT supervisor mode
           MOVE.L      #$10000,-(SP)   ; Push $10000 (beggining of user space) in stack
           MOVE.W      SR,-(SP)        ; Push SR in stack
           ANDI        #$DFFF,(SP)     ; Remove supervisor mode from stack SR (set bit 14 to zero)
           RTE                         ; Return from Exception (SR <= pop stack, PC <= pop stack)
           ; RTE puts SR equal to last stack.W and PC equal to last stack.L
           ; That's why we pushed 10000 and (SR without supervisor) into stack.


; Beggining of user code
           org $10000
           add.l #$100, D0
           TRAP #3
           add.l #$30000, D2



; Offset just to separate code
           org         $450
; Overlay monitor
ovrlymontor:
           add.l #$2000, D1
           rte
; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; Example code to fill memory

pos_start     equ $10000
pos_fillUntil equ $10040


           ORG     pos_start
           LEA     END,A0;             ; A0 <= points at instructions end
           LEA     pos_fillUntil,A1    ; A1 <= pos_fillUntil

FillMemory:
           MOVE.B  (END), (A0)+        ; Write byte in "END" at (A0) and increment A0
           CMPA.L  A0,A1               ; Set flags in SR
           BHS.S   FillMemory          ; Loop while A1 >= A0

           TRAP    #15                 ; Exit
           DC.W    0

END        DC.B    $FF
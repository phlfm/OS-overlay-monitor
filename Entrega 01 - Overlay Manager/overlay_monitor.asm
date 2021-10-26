; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; Overlay monitor implementation
; Overlay monitor has been implemented in such a manner that it is relocable;
;
;
; Overlay monitor will be called by user using TRAP
; User must put address to module name (as null terminated string) in A0
; D0.BYTE <= Module Level (1 to max)
; D1.BYTE <= Module Size
; User must obey maxUserLvl
; Even using A0, D0 and D1 as parameters, they are NOT edited by the rotine
maxUserLvl equ     $5
maxUserLvlChar equ '5'


           ORG     $4A0 ; Put overlay monitor at ... (it is relocable)

; Save user registers
           MOVEM.L D0/D1/D7/A1,-(SP)
; Check if overlay monitor has been initialized
           MOVE.B  (OM_init,PC), D7
           BEQ.S   OM_initialize       ; Goto clear table if not initialized
OM_initialized:


; Check if module level is compatible (Between 1 and maxUserLvl)
           TST     D0                  ; Check if D0 == 0
           BEQ.S   error_exceedLvl
           CMPI.B  #maxUserLvl, D0
           BHI.S   error_exceedLvl     ; Check if D0 > maxUserLvl (BHI is unsigned, BGT is NOT)

; Determine entry position in module size table
           LEA     (Table,PC), A1      ; A1 points to table (index 0)
           ADD.W   D0,A1               ; A1 points to user module position +1
           SUBQ.L  #1,A1               ; A1 points to correct user level table position

           ; A1 holds position to table(module_level)
; If new module size < old module size, calculate memory difference
           MOVE.B  (ZERO,PC),D7        ; Set memory difference to zero
           CMP.B   (A1),D1
           BHS.S   OM_LoadMod          ; size at Table+D0 <= D1, no need to clear memory (BGE is unsigned, BHS is NOT)
           MOVE.B  (A1),D7
           SUB.B   D1,D7               ; D7 holds size difference of new module to old module
           ; A1 holds position to table(module_level)
           ; D7 holds difference between module sizes (how many bytes to clear)

OM_LoadMod:
; Load new module
           ; Save new module size in table
           MOVE.B  D1,(A1)
           SUB.L   D0,D0       ; Make D0 = zero so kernel loader doesn't offset
           ; A0 should contain address to module name, provided by user
           TRAP    #0          ; Kernel loader
           ; D0 will be set to program begginning

; Clear memory
           ; D7 holds difference between module sizes (how many bytes to clear)
           ; D0 is where the loaded module starts
           TST D7
           BEQ OM_restore      ; if D7 = 0, no need to clear memory
     ; Here we have to use long bc D0 will probably be >= 10000 for user code
           MOVE.L  D0,A1       ; A1 <= D0 = module start
           ADD.L   D1,A1       ; A1 <= D0+D1 = module Start + module size
           ADD.L   D7,A1       ; A1 <= D0+D1+D7 = module start + module size + difference to old module
           SUBI.L  #1,D7       ; Correction to index
     OM_clearDiff:
           MOVE.B  (ZERO,PC),-(A1)
           SUBQ.B  #$01,D7
           BNE.S   OM_clearDiff ; Clear while D7 != 0

; Restore users registers and return
OM_restore:
           MOVEM.L (SP)+,D0/D1/D7/A1
           RTE

; OM_initialize used A1 and D7
OM_initialize:
           ; Loop through table writing zero in it
           LEA     (OM_init,PC),A1
           MOVE.B  (ONE,PC), (A1)      ; Set OM_init to 01
           LEA     (Table,PC),A1
           MOVE.B  (ZERO,PC), D7       ; D7 = zero
           ADDI.B  #maxUserLvl, D7     ; D7 = maxUserlvl
    OM_initialize_loop:
           MOVE.B  (ZERO,PC), (A1)+    ; Erase content at (A1) and increment A1
           SUBQ.B  #$1, D7
           BNE.S   OM_initialize_loop  ; Loop while D7 != 0
           BRA.S   OM_initialized      ; return to overlay monitor call


error_exceedLvl:
           lea     str_errUsrLvl,A0
           trap    #15
           dc.w    t15PRTSTR           ; print error msg
           trap    #15
           dc.w    t15EXIT             ; exit
           stop    #$2700

OM_init    ds.b    1
ZERO       dc.b    $00
ONE        dc.b    $01

; This table stores each levels max size
Table      ds.b    maxUserLvl

; Strings with null ending
str_errUsrLvl        dc.b        "ERROR: User exceeded ",maxUserLvlChar, " levels or used level zero",CR,LF,0

; ASCII characters
LF         equ     $0A
CR         equ     $0D

; TRAP #15 Codes
t15PRTSTR     equ     7
t15EXIT       equ     0
t15PRTNUM     equ     5
t15GETNUM     equ     6
t15LOAD       equ     19
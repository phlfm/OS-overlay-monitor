; Escola Politecnica da USP
; PCS 3446 - Sistemas Operacionais 2020
; Pedro H. L. F. de Mendonca
;
; Kernel Implementation
;
; Kernel system calls:
;    Trap #0 - Loader (A0 should point to module name as null terminated string and D0 will be overwritten with entry point)
;    Trap #3 - overlay monitor (A0 should point to module name as null terminated string, D0 should be module level and D1 module size)
;
; This kernel loads the overlay monitor (in TRAP #3) and the user root programs
; This implementation uses 44 bytes + overlay monitor
; User program must be at $10000 and is allocated $1000_hex (4096_dec) bytes.
;
;

; From 0x000 up to 0x3FF we have interruption tables and simulator data
; So our program starts at 0x400
           org     $400

; TRAP address'es are 0x80 + 4*vector value
trap0vec   equ     $80 ; Loader
; TRAP #3 = 0x8C
trap3vec   equ     $8C

; Set system stack pointer and loader in trap table
setup:
           LEA     sysSP, SP
           LEA     loader, A0
           MOVE.L  A0,trap0vec         ; Put address of loader into the trap vector table #0
           BRA.S   start

loader:
           ; A0 should contain address of module to load (as null terminated string)
           ; D0 will be overwritten with loaded modules position in memory
           TRAP    #15
           DC.W    t15LOAD             ; load child, entry point in D0
           BEQ.S   loader_error        ; D0 = 0 on error
           RTE
    loader_error:
           ; A0 already points to modules name
           trap    #15
           dc.w    t15PRTSTR           ; print modulename first
           lea     errmsg,A0
           trap    #15
           dc.w    t15PRTSTR           ; followed by error message
           trap    #15
           dc.w    t15EXIT             ; exit
           stop    #$2700
errmsg  dc.b        ": error loading module",CR,LF,0

start:
; Load overlay monitor
           LEA     str_ovrlaymon,A0    ; get name of module to load
           TRAP    #0                  ; Call loader
           MOVE.L  D0,trap3vec         ; Put address of overlay monitor into the trap vector table #3
           SUB.L   D0,D0               ; Make D0 = 0 so other loads don't offset

; Load user code
           LEA     str_userModule,A0   ; get name of module to load
           TRAP    #0                  ; D0 is loaded with beggining of user program

; Allocate space for user and jump to their code WITHOUT supervisor mode
           MOVE.L  D0,-(SP)            ; Push D0 (beggining of user space) in stack
           MOVE.W  #$0,-(SP)           ; Push user SR in stack
           ADDI.L  #usrMemSize,D0      ; Allocate usrMemSize for user (D0 = usr beggining + usr mem size)
           MOVE.L  D0,A0               ; Allocate usrMemSize for user (A0 <= D0)
           MOVE.L  A0,USP              ; Allocate usrMemSize for user (User stack pointer <= A0) (USP <= D0 is invalid)
           SUB.L   D0,D0               ; Leave registers in known state for user
           SUB.L   A0,A0               ; Leave registers in known state for user
           RTE                         ; Return from Exception (SR <= pop stack = usr SR, PC <= pop stack = usr program)
           ; RTE puts SR equal to last stack.W and PC equal to last stack.L
           ; That's why we pushed 10000 and (SR without supervisor) into stack.




sysSP      equ     $600
usrMemSize equ     $1000              ; User SP points to here initially


; Strings with null ending
str_ovrlaymon      dc.b        "overlay_monitor",0

str_userModule     dc.b        "OM01_root",0
; ASCII characters
LF         equ     $0A
CR         equ     $0D
; TRAP #15 Codes
t15PRTSTR     equ     7
t15EXIT       equ     0
t15PRTNUM     equ     5
t15GETNUM     equ     6
t15LOAD       equ     19
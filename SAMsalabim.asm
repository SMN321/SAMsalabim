
 ; SAMsalabim.asm
 ;
 ; Created: 04.04.2021
 ; Author: Simon Wilhelmstätter
 ;
 ; This implementation of the Square-And-Multiply (SAM) algorithm currently supports a^b mod 256.
 ; Just put the arguments in the SAM_BASE and SAM_EXP registers, call sam and simsalabim: SAM_RES contains the result 

.IFNDEF SAMSALABIM_ASM_INCLUDE_GUARD
.EQU SAMSALABIM_ASM_INCLUDE_GUARD = 0

.IFNDEF SAM_BASE
.DEF SAM_BASE = r20
.ENDIF  ; SAM_BASE

.IFNDEF SAM_EXP
.DEF SAM_EXP = r19
.ENDIF  ; SAM_EXP

.IFNDEF SAM_RES
.DEF SAM_RES = r18
.ENDIF  ; SAM_RES

.IFNDEF SAM_COUNT
.DEF SAM_COUNT = r17    ; must be r16<=SAM_COUNT<=r31 because of ldi
.ENDIF  ; SAM_COUNT

.IFNDEF SAM_TEMP
.DEF SAM_TEMP = r16
.ENDIF  ; SAM_TEMP

 ; plan: 
 ;  - implement a module 256 version first, then continue with the unreduced form
 ;  - expect the arguments in working-registers, then add support for stack-arguments

sam:
    push    SAM_COUNT       ; store copies of the used registers on the stack to not introduce any side effects
    push    SAM_TEMP
    push    SAM_EXP
    push    SAM_BASE
    in      SAM_TEMP, SREG  ; store the SREG on the stack as well
    push    SAM_TEMP

    clr     SAM_RES         ; workaround to ldi SAM_RES, 1 because that would need an r16..r31
    inc     SAM_RES
    ldi     SAM_COUNT, 8
sam_calc:
    rcall   sam_square      ; square SAM_RES every time
    sbrc    SAM_EXP, 7      ; skip if bit 7 is cleared
    rcall   sam_multiply    ; only multiply SAM_RES with SAM_BASE if the current MSB is set
    lsl     SAM_EXP         ; next bit
    dec     SAM_COUNT
    brne    sam_calc        ; return to sam_calc if the counter is not at 0 yet

    pop     SAM_TEMP        ; restore the SREG from the stack
    out     SREG, SAM_TEMP
    pop     SAM_BASE        ; restore the values from the stack
    pop     SAM_EXP
    pop     SAM_TEMP
    pop     SAM_COUNT
    ret                     ; otherwise we're done --> return

sam_multiply:   ; multiply SAM_BASE with SAM_RES, maybe change this to a jump instead of a call
    push    SAM_COUNT       ; use the same counter-register as in the main loop
    push    SAM_BASE        ; store a copy of SAM_BASE on the stack to restore it later
    ldi     SAM_COUNT, 8
    clr     SAM_TEMP        ; this register will store the intermediate results
sam_multiply_loop:
    lsl     SAM_TEMP
                                ; for a full multiplicaton (without modulo), add an left-shift with overflow to the upper temp-register here
    lsl     SAM_BASE
    brcc    sam_multiply_no_add ; don't add SAM_RES to SAM_TEMP if the MSB of SAM_BASE is 0
    add     SAM_TEMP, SAM_RES
                                ; for a full multiplicaton (without modulo), add an addition with carry to the upper temp-register here
sam_multiply_no_add:
    dec     SAM_COUNT
    brne    sam_multiply_loop   ; next round if the counter is not yet at 0
    mov     SAM_RES, SAM_TEMP   ; move the result from the temporary register to the result-register
    pop     SAM_BASE            ; deconstruct the stack (in reversed order)
    pop     SAM_COUNT
    ret

sam_square:     ; square the content of SAM_RES
    push    SAM_BASE            ; store a copy of SAM_BASE on the stack
    mov     SAM_BASE, SAM_RES   ; copy SAM_RES to SAM_BASE
    rcall   sam_multiply        ; use the multiply routine with the adjusted value of SAM_BASE
    pop     SAM_BASE            ; restore the copy of SAM_BASE from the stack
    ret

.ENDIF  ; SAMSALABIM_ASM_INLUDE_GUARD

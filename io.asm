; Input/Output for NASM.
; Operations allowed are output and input. Output string ends with 0.
; Use as below:
;               output string
;               input  buffer, buffer_length

%macro          output          1
                
                push            eax
                mov             eax, %1
                call            print
                pop             eax

%endmacro

%macro          input           2
                
                mov             ecx, %1
                mov             edx, %2
                call            input_

%endmacro

section .bss

arg             resb            50
arg_len         equ             $ - arg
index           resb            1


section .text


print:
                push            ebx
                push            ecx
                push            edx
                push            edi

                mov             edi, -1
                call            get_string

                mov             ecx, eax
                mov             edx, edi
                mov             eax, 4
                mov             ebx, 1
                int             80h

                pop             edi
                pop             edx
                pop             ecx
                pop             ebx
                ret

get_string:
                inc             edi
                cmp     byte    [eax + edi], 0
                jne             get_string
                ret


input_:
                mov             eax, 3
                mov             ebx, 0
                int             80h
                

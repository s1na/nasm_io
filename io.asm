; Input/Output for NASM.
; Operations allowed are output and input.
; Use as below:
;               output string, string_length
;               input  buffer, buffer_length

%macro          output          1
                
                mov             arg, %1
                call            print
                sub             esp, [arg_len]

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
                push            eax
                push            ebx
                push            ecx
                push            edx

                mov             index, -1
                call            get_string

                mov             ecx, arg
                mov             edx, arg_len
                mov             eax, 4
                mov             ebx, 1
                int             80h

                pop             edx
                pop             ecx
                pop             ebx
                pop             eax
                ret

get_string:
                inc             index
                cmp             [arg + index], 0
                jne             get_string

                mov             arg_len, index



input_:
                mov             eax, 3
                mov             ebx, 0
                int             80h
                

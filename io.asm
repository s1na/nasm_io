; Input/Output for NASM.
; Operations allowed are output and input.
; Use as below:
;               output string, string_length
;               input  buffer, buffer_length

%macro          output          2
                
                mov             ecx, %1
                mov             edx, %2
                call            print

%endmacro

%macro          input           2
                
                mov             ecx, %1
                mov             edx, %2
                call            input_

%endmacro

section .text


print:
                mov             eax, 4
                mov             ebx, 1
                int             80h
                ret

input_:
                mov             eax, 3
                mov             ebx, 0
                int             80h
                

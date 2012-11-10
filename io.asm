; Input/Output for NASM.
; Operations allowed are output, input and atod. Output string ends with 0.
; Use as below:
;               output string
;               input  buffer, buffer_length
;               atod   string
;               dtoa   buffer, number
;
; Notes:
;    If the number isnt fit for a doubleword in atod the higher part is ignored.
;    Dtoa counts the number signed and puts a '-' before it.
;    Dtoa buffer should be exactly 11 bytes. If the number is smaller however\
;     leading spaces are used to fill the remaining bytes.

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

%macro          atod            1

                mov             edx, %1
                call            convert_ascii

%endmacro

%macro          dtoa            2

                push            ebx
                push            ecx

                mov             ebx, %1
                mov             ecx, %2
                call            convert_decimal

                pop             ecx
                pop             ebx

%endmacro



section .data
sign:           db              0


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
                cmp    byte     [eax + edi], 0
                jne             get_string
                ret


input_:
                push            eax
                push            ebx


                mov             eax, 3
                mov             ebx, 0
                int             80h


                pop             ebx
                pop             eax
                ret
                

convert_ascii:
                ; The ascii code's address is in edx, calculations will happen in eax
                ; bh contains the sign. Ecx will have the result temporarily, then it'll
                ; be moved to eax.

                push            edi
                push            ebx
                push            ecx

                
                mov             edi, -1
                mov             ecx, 0
                mov    byte     [sign], 0
                mov             eax, 0
                call            determine_sign
                call            determine_decimal

                cmp    byte     [sign], 1
                je              negate

                mov             eax, ecx

                pop             ecx
                pop             ebx
                pop             edi
                ret

determine_sign:
                cmp    byte     [edx], 2dh
                je              non_positive
                ret

non_positive:
                mov    byte     [sign], 1
                inc             edi
                ret

determine_decimal:
                mov             ebx, 0
                inc             edi
                cmp    byte     [edx + edi], 30h
                jl              return                          ; The char is not an integer.            
                cmp    byte     [edx + edi], 39h
                jg              return

                mov             ebx, 0
                mov             bl, [edx + edi]
                sub             bl, 30h                         ; Get the decimal num.

                push            edx
                mov             eax, ecx
                mov             ecx, 10
                mul    dword    ecx
                mov             ecx, eax
                add             ecx, ebx
                pop             edx
                jmp             determine_decimal

convert_decimal:
                ; The memory addr of buffer is kept in ebx, the number itself is in ecx.
                ; Eax and edx are used for computations.
                ; Beware that numbers are assumed signed.

                push            eax
                push            edx
                push            edi

                mov             edi, 10
                mov    byte     [ebx + 11], 0
                mov    byte     [sign], 0
                add             ecx, 0
                js              negate
                call            determine_ascii
                cmp    byte     [sign], 1
                je              minus_sign

                mov             eax, 0
                mov             al, 1                           ; If there's no minus sign,
                sub             al, [sign]                      ; there should be an additional
                add             edi, eax                        ; space.

                call            empty_left


                pop             edi
                pop             edx
                pop             eax
                ret

minus_sign:
                mov    byte     [ebx + edi], 2dh
                neg             ecx
                inc             edi

determine_ascii:
                dec             edi
                cmp             ecx, 0
                je              return

                mov             eax, ecx
                mov             ecx, 10
                mov             edx, 0
                div             ecx
                mov             ecx, eax
                add             edx, 30h
                mov    byte     [ebx + edi], dl
                jmp             determine_ascii

empty_left:
                dec             edi
                cmp             edi, 0
                jge             leading_space
                ret

leading_space:
                mov    byte     [ebx + edi], 20h
                jmp             empty_left

negate:
                neg             ecx
                mov    byte     [sign], 1                       ; This is for dtoa

return:
                ret



; Input/Output for NASM.
; Operations allowed are output, input and atod. Output string ends with 0.
; Use as below:
;               output string
;               input  buffer, buffer_length
;               atod   string
;               dtoa   destination = memory adress , source = register, buffer_lenght
;
; Notes:
;               dtoa macro does not check the lenght of Integer and Memory,

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

%macro          dtoa            2-3 11

	push	eax				
	push	ebx
	push	edi
				
	mov	ebx, %1
	mov	eax, %2
	mov	edi, %3 
	call            convert_double

	pop	edi
	pop	ebx
	pop	eax

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

;macro DoubleToAscii
convert_double:
	push	ecx
	push	esi

	sub	ecx, ecx
	mov	esi, 10
	mov    byte     [sign], 0
	cmp	eax, 0
	jl	_negetive
	jmp	get_numbers
_negetive:
	neg	eax
	mov   byte	[sign], 1
get_numbers:
	cmp	eax, 0
	jz	put_numbers
	cdq
	div	esi
	add	dl, 30h
	push	dx
	inc	ecx
	jmp	get_numbers
put_numbers:
	cmp   byte	[sign], 0
	je	add_numbers
add_negation:	
	mov   byte	[ebx],'-'
                inc	ebx
	dec	edi
add_numbers:
	cmp	edi, 1
	je	_done
	pop	dx
	mov   byte	[ebx], dl
	inc	ebx
	dec	edi
	loop	add_numbers
_done:
	inc             ebx
	mov   byte	[ebx], 0

	pop	esi
	pop	ecx
	ret
;endmacro DoubleToAscii

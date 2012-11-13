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

%macro          dtoa            2

				;EBX is adress of destination
				;EAX is source
				push			eax	
				push			ebx
				
				mov				ebx, %1
				mov				eax, %2
				call            convert_double

				pop				ebx
				pop				eax

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

negate:
				neg				ecx
				mov		byte	[sign], 0
				ret

return:
				ret
;macro DoubleToAscii
convert_double:
				pushad
				;ECX determine number of digits in EAX as Source
				sub				ecx, ecx
				mov				esi, 10				;ESI is for getting first number of EAX
				mov		byte    [sign], 0			;sign of EAX
				cmp				eax, 0
				je				eax_is_zero
				jl				_negetive
				jmp				get_numbers
_negetive:											;negate EAX and put 1 in sign
				neg				eax
				mov  	 byte	[sign], 1
get_numbers:										;get numbers of EAX and increase ECX
				cmp				eax, 0
				jz				put_numbers
				cdq
				div				esi
				add				dl, 30h				;Put first number of EAX to Stack
				push			edx
				inc				ecx
				jmp				get_numbers
put_numbers:
				cmp 	  byte	[sign], 0
				je				add_numbers
add_negation:	
				mov  	byte	[ebx],'-'			;if sign is 1 add '-' character to buffer
				inc				ebx
add_numbers:										;pop from stack and put in buffer the number character
				pop				edx					; to buffer
				mov   	byte	[ebx], dl
				inc				ebx
				loop			add_numbers
_done:
				inc             ebx
				mov  	 byte	[ebx], 0			;add 0 to the end of  buffer to show the end of string
				popad 
				ret 
eax_is_zero:
				mov		byte	[ebx], 30h
				inc				ebx
				mov		byte	[ebx], 0
				popad
				ret
;endmacro DoubleToAscii

%include "lib.inc"

global find_word

section .text

; размер указателя на некст элемент
%define PNT 8

; rdi - pointer to value string
; rsi - pointer to the first entry
; rax - returns addres of entry, 0 if not found
; проходит по всему словарю, сравнивает rdi 
find_word:
        push r12
        mov r12, rsi                             ; текущий адрес энтри
        mov r9, rdi                             ; искомое значение

        .loop:
                test r12, r12
                jz .nope

                mov rdi, r9
                lea rsi, [r12+PNT]               ; пишем указатель на строку
                push r12
                push r9
                call string_equals
                pop r9
                pop r12
                test rax, rax
                jnz .yep

                mov r12, [r12]

                jmp .loop

        .yep:
                mov rax, r12
                pop r12
                ret

        .nope:
                xor rax, rax
                pop r12
                ret


; find_word:
; 	push r12
; 	push r13
; 	mov r12, rdi            ; искомое значение
; 	mov r13, rsi            ; адрес энтри
; 	.loop:
; 		test r13, r13 ; Проверка на пустой узел (достижение конца словаря)
; 		jz .not_found

; 		mov rdi, r12
; 		lea rsi, [r13 + 8]
; 		call string_equals
; 		test rax, rax
; 		jnz .found
; 		mov r13, [r13]
; 		jmp .loop
; 	.found:
; 		mov rax, r13
; 		pop r13
; 		pop r12
; 		ret
; 	.not_found:
; 		xor rax, rax
; 		pop r13
; 		pop r12
; 		ret


; dict_example:
; x1:
;         dq x2
;         dq 100

; x2: 
;         dq x3
;         dq 200

; x3: 
;         dq 0
;         dq 300
